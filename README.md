# Cybersecurity Homelab

A small enterprise-style lab for practicing Active Directory, Windows and Linux administration, networking, and security monitoring.

## Lab Layout

| System | Role | Status |
|---|---|---|
| PC 1 — Proxmox | Hosts Windows Server DC01 and Ubuntu Server | Operational |
| Personal PC — Hyper-V | Hosts a Windows 11 employee workstation | Operational |
| PC 2 | Attacker system | Planned |
| PC 3 | Centralized security monitoring | Planned |

The employee VM is joined to the lab domain. The personal PC’s Windows installation remains separate.

## Technologies

Proxmox VE · Hyper-V · Windows Server 2025 · Windows 11 Pro · Ubuntu Server · Active Directory · DNS · Group Policy · PowerShell

## Completed

- Deployed Windows and Linux server VMs.
- Configured Active Directory and DNS.
- Created department OUs, sample users, and security groups with PowerShell.
- Joined an employee workstation to the domain and verified domain login.
- Applied and verified a workstation security policy.

## Next Steps

- Configure departmental file shares and test access permissions.
- Deploy Wazuh and Sysmon for security monitoring.
- Establish lab network isolation and run controlled attack-and-detection exercises.
- Practice backup, recovery, and server migration.

## Project Files

- [Documentation](docs/) — Setup notes, troubleshooting, and validation
- [Scripts](scripts/) — Administration automation
- [Screenshots](screenshots/) — Evidence of completed work
- [Diagrams](diagrams/) — Lab architecture and networking
