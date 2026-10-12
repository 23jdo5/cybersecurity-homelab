# Windows Client Setup

## Objective

Deploy an employee workstation, join it to Active Directory, and verify domain login, Group Policy, and departmental file access.

## VM Configuration

| Setting | Value |
|---|---|
| Host | Personal PC running Windows 11 Pro |
| Hypervisor | Hyper-V |
| Guest OS | Windows 11 Pro |
| Generation | 2 |
| Virtual processors | 2 |
| Memory | 6 GB; Dynamic Memory disabled |
| Virtual disk | 80 GB, dynamically expanding |
| Secure Boot | Enabled; Microsoft Windows template |
| Virtual TPM | Enabled |
| Network connection | Hyper-V Default Switch |

## Installation

1. Enabled Hyper-V on the personal PC and restarted.
2. Created the employee VM.
3. Configured processors, memory, storage, Secure Boot, and virtual TPM.
4. Attached the Windows 11 ISO and installed Windows 11 Pro.
5. Connected the VM to the Default Switch.
6. Selected work or school setup, then Domain join instead.
7. Created a local administrator account named `LabAdmin`.

The local administrator account is separate from employee domain accounts. The personal Windows installation remains outside the lab domain.

## Domain Join

1. Configured the VM’s preferred DNS server to use DC01.
2. Left IP address assignment automatic.
3. Verified connectivity to DC01’s DNS port:
   ```powershell
   Test-NetConnection -ComputerName <DC01-IP> -Port 53
   ```
4. Verified domain-controller discovery:
   ```text
   nslookup -type=SRV _ldap._tcp.dc._msdcs.<domain>
   ```
5. Joined the workstation to the domain using domain administrator credentials.
6. Restarted the workstation.
7. Signed in with the Engineering user `echen`.
8. Verified the domain identity:
   ```text
   whoami
   ```
9. Moved the computer account into `Corp-Computers → Workstations` on DC01.

Replace placeholders with the actual lab address and domain before running commands.

## Group Policy Validation

Applied the `Workstations - Screen Lock` GPO, configured with a machine inactivity limit of 900 seconds.

Refreshed policy:

```text
gpupdate /force
```

Both computer and user policy updates completed successfully after resolving DC01’s clock synchronization issue.

Verified the applied value:

```text
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs
```

Result: `0x384`, equivalent to 900 seconds.

The workstation locked earlier than 15 minutes during observation. The configured policy was verified, but the reason for the earlier lock remains unconfirmed.

## Departmental File-Access Testing

Used separate domain-user sessions to test the Ubuntu Engineering share.

| Account | Department | Test | Result |
|---|---|---|---|
| Ethan Chen — `echen` | Engineering | Open the share and save a text file | Allowed |
| Sarah Miller — `smiller` | HR | Open the same share | Denied |

Ethan created `engineering-access-test.txt` and saved content, confirming write access.

Signed out before testing Sarah’s account. Ethan’s credentials were not supplied during the HR test.

### Hostname Access

Initially accessed the share through:

```text
\\UBUNTU-IP\Engineering
```

After adding Ubuntu’s DNS record on DC01, cleared the client DNS cache:

```text
ipconfig /flushdns
```

Verified resolution:

```text
nslookup ubuntu01.<domain>
```

Then successfully opened:

```text
\\ubuntu01.<domain>\Engineering
```

Server configuration and access-test screenshots are documented in [Samba File Sharing](file-sharing.md).

## Troubleshooting

### Hyper-V Enhanced Session blocked employee login

The employee account received an error stating it lacked permission to sign in through Remote Desktop Services.

Disabled Enhanced Session and signed in through the basic VM console. No additional privileges were granted to the employee account.

### Group Policy failed because of clock skew

DC01’s clock was approximately seven hours ahead of the workstation. Correcting DC01’s time synchronization resolved the policy update failure.

The server-side diagnosis and fix are documented in [Active Directory Lab](active-directory.md).

### Group Policy failed while DC01 was unavailable

A policy refresh stalled while the Proxmox server and DC01 were off.

After bringing DC01 online, additional lookup and authentication errors occurred. Checks confirmed:

- DC01’s hostname resolved.
- Domain-controller discovery succeeded.
- The clocks matched.
- The workstation’s domain secure channel was healthy.

Signed out, signed back in as Ethan, and ran `gpupdate /force` from a normal Command Prompt. Both policy updates then succeeded.

The precise cause of the remaining session errors was not independently established.

### File share worked by IP but not hostname

The Ubuntu hostname returned `Non-existent domain`.

After adding its A record on DC01 and clearing the workstation’s DNS cache, hostname resolution and share access succeeded.

## Evidence

<img width="996" height="668" alt="Screenshot 2026-10-11 170456" src="https://github.com/user-attachments/assets/bb9e8c3b-f929-4fb7-a043-0882228fd9cb" />

The screenshot records:

- The domain identity returned by `whoami`.
- Successful computer and user policy updates.
- `InactivityTimeoutSecs` set to `0x384`.

File-access evidence is included in [Samba File Sharing](file-sharing.md).

## Result

The employee workstation successfully:

- Joined the Active Directory domain.
- Authenticated domain users.
- Received the configured workstation policy.
- Accessed the Engineering share as an authorized user.
- Demonstrated denied access for an HR user.
- Accessed the file server using its DNS hostname.


