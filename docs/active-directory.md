# Active Directory Lab

## Objective

Deploy a Windows Server domain controller, create a simulated corporate directory, and validate domain authentication, workstation policies, and departmental file access.

## Environment

| Component | Configuration |
|---|---|
| Domain controller | DC01 — Windows Server 2025 |
| Virtualization host | Proxmox VE |
| DC01 resources | 2 vCPUs, 4 GB RAM, 50 GB virtual disk |
| Server roles | Active Directory Domain Services and DNS |
| Domain | `<redacted>.home.arpa` |
| Employee workstation | Windows 11 Pro VM hosted in Hyper-V |
| File server | Ubuntu Server with Samba and Winbind |

## Directory Structure

```text
<domain>
├── Corp-Users
│   ├── IT
│   ├── HR
│   ├── Finance
│   ├── Sales
│   └── Engineering
├── Corp-Computers
│   ├── Workstations
│   └── Servers
├── Groups
└── Service-Accounts
```

## Security Groups

- `GG_IT`
- `GG_HR`
- `GG_FINANCE`
- `GG_SALES`
- `GG_ENGINEERING`

Sample users were assigned to their department OUs and security groups using PowerShell.

## Domain Controller Deployment

1. Created a Windows Server VM in Proxmox.
2. Installed Windows Server with the VirtIO SCSI storage driver.
3. Installed the VirtIO network driver.
4. Configured a static IPv4 address.
5. Installed Active Directory Domain Services.
6. Promoted DC01 to a domain controller, creating a new forest and installing DNS.
7. Created organizational units, sample users, and security groups using PowerShell.

## Employee Workstation Integration

1. Created a Windows 11 Pro VM in Hyper-V.
2. Configured its preferred DNS server to use DC01.
3. Verified domain-controller discovery:
   ```text
   nslookup -type=SRV _ldap._tcp.dc._msdcs.<redacted>.home.arpa
   ```
4. Joined the workstation to the domain and restarted it.
5. Signed in with the Engineering user `echen`.
6. Verified the signed-in identity:
   ```text
   whoami
   ```
7. Moved the computer account into `Corp-Computers → Workstations`.

Replace `<redacted>` with the actual domain label when running commands.

Detailed client setup is documented in [Windows Client Setup](windows-client-setup.md).

## Workstation Group Policy

Created a GPO named `Workstations - Screen Lock` and linked it to the Workstations OU.

Configured:

```text
Computer Configuration
→ Policies
→ Windows Settings
→ Security Settings
→ Local Policies
→ Security Options
→ Interactive logon: Machine inactivity limit
```

Value: **900 seconds (15 minutes)**.

Refreshed policy on the workstation:

```text
gpupdate /force
```

Verified the applied setting:

```text
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs
```

The returned value was `0x384`, equivalent to 900 seconds.

The workstation locked earlier than 15 minutes during observation. The policy value was verified, but the cause of the earlier lock remains unconfirmed.

## Ubuntu File Server Integration

Joined Ubuntu to the domain using Samba and Winbind.

Verified domain membership:

```bash
sudo net ads testjoin
```

Result:

```text
Join is OK
```

Confirmed that Ubuntu recognized Ethan’s domain account and membership in `GG_ENGINEERING`.

Used that group to control access to the Engineering share:

| Account | Department | Test | Result |
|---|---|---|---|
| Ethan Chen — `echen` | Engineering | Open the share and create a file | Allowed |
| Sarah Miller — `smiller` | HR | Open the Engineering share | Denied |

Added an A record for `ubuntu01` on DC01, pointing to Ubuntu’s reserved IPv4 address. Verified DNS resolution and access to the share by hostname.

Full configuration and evidence are documented in [Samba File Sharing](file-sharing.md).

## Troubleshooting

### Windows installer could not detect the virtual disk

**Problem:** Windows Server did not detect the SCSI virtual disk.

**Resolution:** Mounted the VirtIO driver ISO and loaded the VirtIO SCSI driver during installation.

### Network adapter missing

**Problem:** Windows Server did not detect the VirtIO network adapter.

**Resolution:** Installed the NetKVM network driver from the VirtIO driver ISO.

### PowerShell provisioning script failed

**Problem:** The provisioning script referenced the wrong domain distinguished name.

**Resolution:** Corrected the domain DN and reran the script successfully. Domain-specific paths and user principal names must match the intended environment.

### Group Policy failed because of clock skew

**Problem:** The workstation reported that Group Policy could not update because its clock was not synchronized.

**Diagnosis:** Compared UTC timestamps on DC01, the workstation, and the personal host:

```powershell
[DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
```

DC01 was approximately seven hours ahead. Checking its time source returned `Local CMOS Clock`:

```text
w32tm /query /source
```

**Resolution:** On DC01, ran the following in an elevated PowerShell window:

```powershell
w32tm /config /manualpeerlist:"time.windows.com,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /rediscover
```

These settings were applied to DC01 as the lab’s only domain controller, not to the employee workstation.

**Validation:** After time synchronization, computer and user Group Policy updates completed successfully.

### Employee login blocked by Remote Desktop permissions

**Problem:** The standard employee account received a Remote Desktop Services sign-in permission error through Hyper-V Enhanced Session.

**Resolution:** Disabled Enhanced Session and signed in through the basic VM console.

**Validation:** The employee could sign in without being granted administrator or Remote Desktop permissions.

### Group Policy failed after the lab server was powered off

**Problem:** A policy refresh stalled while DC01 was off. After restarting the server, the workstation also reported domain lookup and authentication errors.

**Diagnosis:** Verified DC01’s DNS resolution, domain-controller discovery, matching clocks, and a healthy workstation secure channel.

**Resolution:** With DC01 running, signed out of the employee session, signed back in, and repeated the policy refresh.

**Validation:** Computer and user policy updates succeeded. The precise cause of the remaining session errors was not independently established.

### Ubuntu hostname did not resolve

**Problem:** The Engineering share worked by IP address, but the Ubuntu hostname returned `Non-existent domain`.

**Diagnosis:** DNS Manager displayed the domain zones under Reverse Lookup Zones. PowerShell confirmed that both reported `IsReverseLookupZone = True`.

**Resolution:** Added Ubuntu’s A record directly through PowerShell without deleting or recreating the existing zones, then cleared the workstation’s DNS cache.

**Validation:** Ubuntu’s hostname resolved to its reserved IP address, and Ethan could access the share by hostname. The zone classification itself was not changed.

Detailed commands and screenshots are recorded in [Samba File Sharing](file-sharing.md).

## Validation Summary

- Employee workstation successfully joined the domain.
- Engineering user successfully signed in.
- `whoami` confirmed the domain identity.
- Computer account was placed in the Workstations OU.
- Computer and user Group Policy updates succeeded.
- The screen-lock policy registry value matched the configured setting.
- Ubuntu successfully joined the domain and recognized domain group membership.
- Engineering write access and HR denial were verified.
- Ubuntu’s DNS hostname resolved and supported share access.

## Evidence

The screenshot below shows the employee’s domain identity, successful Group Policy updates, and the configured inactivity limit.

![Domain login and Group Policy verification](../screenshots/domain-login-and-policy.png)

File-server membership, permissions, and access-test screenshots are included in [Samba File Sharing](file-sharing.md).

## Next Steps

- Collect authentication and policy-related security events.
- Forward logs to centralized monitoring.
- Test domain-controller backup and recovery.
