# Active Directory File Sharing with Samba

## Objective

Configure Ubuntu as a domain-connected file server and enforce departmental access using Active Directory security groups.

## Environment

| Component | Configuration |
|---|---|
| File server | Ubuntu 26.04.1 LTS, Proxmox VM 100 |
| Domain controller | DC01, Windows Server 2025 |
| Client | Domain-joined Windows 11 Pro employee VM |
| File-sharing software | Samba |
| Domain integration | realmd and Winbind |
| Authorized group | `GG_ENGINEERING` |
| Share | `Engineering` |
| Folder | `/srv/samba/engineering` |

Domain names and IP addresses are omitted from this document. Replace placeholders before running commands.

## DNS Configuration

Ubuntu initially used the router for DNS and could not resolve DC01’s domain hostname.

Updated `/etc/netplan/00-installer-config.yaml` to use DC01 for DNS while retaining automatic IP assignment. The existing interface matching and naming settings were preserved.

Relevant settings under `ens18`:

```yaml
dhcp4: true
dhcp6: true
dhcp4-overrides:
  use-dns: false
dhcp6-overrides:
  use-dns: false
nameservers:
  addresses:
    - DC01-IP
```

Validated and applied the configuration:

```bash
sudo netplan generate
sudo netplan try
```

Confirmed that Ubuntu could resolve:

- DC01’s domain hostname.
- The domain’s LDAP SRV record.
- `archive.ubuntu.com`.

### Configuration Troubleshooting

Initial Netplan validation failed because of a misspelled `addresses` key and an incorrectly formatted address list.

Correcting the key and using a properly indented list resolved the errors.

## Domain Integration

Installed Samba and realmd:

```bash
sudo apt install realmd samba
```

Discovered the domain:

```bash
realm discover <domain>
```

Joined using Samba and Winbind:

```bash
sudo realm join --verbose --membership-software=samba --client-software=winbind --user=Administrator <domain>
```

Entered the domain administrator password interactively.

Verified the join:

```bash
sudo net ads testjoin
```

Result:

```text
Join is OK
```

Restarted Winbind and verified the employee account:

```bash
sudo systemctl restart winbind
getent passwd 'echen@<domain>'
id 'echen@<domain>'
```

The account resolved successfully, and its group membership included `GG_ENGINEERING`.

## Folder Permissions

Created the Engineering folder and assigned its group ownership:

```bash
LAB_DOMAIN=$(wbinfo --own-domain)
sudo mkdir -p /srv/samba/engineering
sudo chown "root:${LAB_DOMAIN}\\GG_ENGINEERING" /srv/samba/engineering
sudo chmod 2770 /srv/samba/engineering
```

The permissions provide:

- Full directory access for the owner and Engineering group.
- No directory access for other users.
- Group inheritance for newly created content through the setgid bit.

Verified ownership and permissions:

```bash
ls -ld /srv/samba/engineering
```

Expected permission string:

```text
drwxrws---
```

## Samba Share Configuration

Backed up the existing configuration:

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```

Preserved the domain membership settings and appended:

```ini
[Engineering]
    path = /srv/samba/engineering
    browseable = yes
    read only = no
    guest ok = no
    inherit permissions = yes
```

Access is enforced by the underlying directory permissions and Active Directory group membership. Disabling guest access requires authentication.

Validated the configuration:

```bash
sudo testparm -s
```

The output showed `ROLE_DOMAIN_MEMBER` and the Engineering share.

Activated the share:

```bash
sudo systemctl restart smbd
systemctl is-active smbd
```

Result:

```text
active
```

## Access-Control Testing

Accessed the share from File Explorer using:

```text
\\UBUNTU-IP\Engineering
```

| Account | Department | Test | Result |
|---|---|---|---|
| Ethan Chen — `echen` | Engineering | Open the share and create a text file | Allowed |
| Sarah Miller — `smiller` | HR | Open the Engineering share | Denied |

### Engineering User

Signed in to the employee VM as Ethan and created:

```text
engineering-access-test.txt
```

Saved the following content:

```text
Created by Ethan Chen to verify Engineering share access.
```

This verified write access, not just the ability to open the folder.

### HR User

Signed out of Ethan’s session and signed in as Sarah. Attempted to open the same share without supplying Ethan’s credentials.

Access was denied, confirming that the tested HR account could not access the Engineering folder.

## Evidence

### Domain Membership and Folder Permissions

<img width="1279" height="863" alt="Screenshot 2026-10-11 175038" src="https://github.com/user-attachments/assets/76566073-f362-47ac-8b7d-f32cfd09e854" />

### Samba Configuration
<img width="1278" height="863" alt="Screenshot 2026-10-11 175527" src="https://github.com/user-attachments/assets/40509f25-9781-4f45-8ff8-690539bf3e9c" />


### Engineering Access Allowed
<img width="1012" height="858" alt="Screenshot 2026-10-11 180230" src="https://github.com/user-attachments/assets/a97c4d4f-f127-43d9-8415-4249af5c9c9a" />


### HR Access Denied
<img width="1013" height="866" alt="Screenshot 2026-10-11 180717" src="https://github.com/user-attachments/assets/0910acde-ae3d-4d83-a836-1bdaecd4b3d7" />

## DHCP Reservation and Reboot Validation

Created a DHCP reservation on the Spectrum router for Ubuntu’s `ens18` interface using its MAC address and current IPv4 address.

After restarting Ubuntu, verified that:

- Ubuntu retained its reserved IPv4 address.
- The employee workstation could still access the Engineering share.

## Hostname Access and DNS Troubleshooting

The share worked by IP address, but access through `ubuntu01.<domain>` initially failed.

On the employee workstation, the following lookup returned `Non-existent domain`:

```text
nslookup ubuntu01.<domain>
```

### Investigation

DNS Manager displayed the domain zones under Reverse Lookup Zones and did not provide the expected New Host menu option.

Inspected the zone classification on DC01:

```powershell
Get-DnsServerZone | Format-Table ZoneName, ZoneType, IsReverseLookupZone
```

Both the domain zone and its `_msdcs` zone reported `IsReverseLookupZone = True`.

### Resolution

Created an A record directly through administrator PowerShell on DC01:

```powershell
$UbuntuIP = Read-Host "Enter Ubuntu's reserved IPv4 address"
Add-DnsServerResourceRecordA -Name "ubuntu01" -ZoneName "<domain>" -IPv4Address $UbuntuIP
```

Replaced `<domain>` with the actual lab domain. Existing zones and records were preserved.

Cleared the employee workstation’s DNS cache and repeated the lookup:

```text
ipconfig /flushdns
nslookup ubuntu01.<domain>
```

The hostname resolved to Ubuntu’s reserved IPv4 address. Ethan then successfully accessed:

```text
\\ubuntu01.<domain>\Engineering
```

The missing host record was resolved. The zone classification itself was not changed.

## Outcome

- Ubuntu joined Active Directory and recognized domain users and groups.
- Ethan from Engineering successfully created a file in the share.
- Sarah from HR was denied access.
- Ubuntu retained its reserved IP address after a reboot.
- The share was successfully accessed using its DNS hostname.

## Remaining Work

- Collect and monitor file-access events.
- Back up the share and test restoration.
