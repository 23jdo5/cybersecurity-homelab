# Windows Client Setup

## Objective

Deploy an employee workstation, join it to Active Directory, and verify domain login and Group Policy.

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
3. Configured its processors, memory, storage, Secure Boot, and virtual TPM.
4. Attached the Windows 11 ISO and installed Windows 11 Pro.
5. Connected the VM to the Default Switch.
6. Selected work or school setup, then Domain join instead.
7. Created a local administrator account named `LabAdmin`.

The local administrator account is separate from employee domain accounts.

## Domain Join

1. Configured the VM’s preferred DNS server to use DC01’s IPv4 address.
2. Left the VM’s IP address assignment automatic.
3. Verified access to DC01’s DNS port:
   ```powershell
   Test-NetConnection -ComputerName <DC01-IP> -Port 53
   ```
4. Verified domain-controller discovery:
   ```text
   nslookup -type=SRV _ldap._tcp.dc._msdcs.<domain>
   ```
5. Joined the workstation to the lab domain using domain administrator credentials.
6. Restarted the workstation.
7. Signed in with the Engineering user `echen`.
8. Verified the domain identity:
   ```text
   whoami
   ```
9. Moved the computer account into `Corp-Computers → Workstations` on DC01.

Replace placeholders with the lab’s actual address and domain when running commands.

## Group Policy Validation

Applied the `Workstations - Screen Lock` GPO, configured with a machine inactivity limit of 900 seconds.

Refreshed policy on the workstation:

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

## Troubleshooting

### Hyper-V Enhanced Session blocked employee login

The employee account received an error stating it lacked permission to sign in through Remote Desktop Services.

Disabled Enhanced Session in the VM connection window and signed in through the basic console. No additional privileges were granted to the employee account.

### Group Policy failed because of clock skew

DC01’s clock was approximately seven hours ahead of the workstation. Correcting DC01’s time synchronization resolved the policy update failure.

The server-side diagnosis and fix are documented in [Active Directory Lab](active-directory.md).

## Evidence

Screenshot location:

<img width="996" height="668" alt="Screenshot 2026-10-11 170456" src="https://github.com/user-attachments/assets/bb9e8c3b-f929-4fb7-a043-0882228fd9cb" />

The screenshot should show:

- `whoami` identifying the domain user `echen`.
- Successful computer and user policy updates.
- `InactivityTimeoutSecs` set to `0x384`.

## Result

The employee workstation successfully joined the domain, authenticated a domain user, and received the configured workstation policy.
