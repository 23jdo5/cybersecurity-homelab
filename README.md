# Cybersecurity Homelab

A small enterprise-style lab for practicing virtualization, Windows and Linux administration, Active Directory, networking, security monitoring, and incident response.

## Hardware

| System | Specifications | Role |
|---|---|---|
| Lab PC 1 | ASUS H81M-P, Intel Core i5-4440, 12 GB DDR3 RAM, 120 GB SSD | Proxmox host for company servers |
| Lab PC 2 | ASUS H81M-P, Intel Core i5-4440, 8 GB DDR3 RAM, 120 GB SSD | Planned attacker system |
| Lab PC 3 | ASUS H81M-P, Intel Core i5-4440, 8 GB DDR3 RAM, 120 GB SSD | Planned security monitoring system |
| Personal PC — PowerSpec G525 | AMD Ryzen 5 7600X3D, 32 GB RAM, AMD Radeon RX 9060 XT 16 GB, 1 TB storage | Hyper-V host for the employee workstation |

**Networking:** TP-Link Gigabit Ethernet switch.

## Virtual Environment

| VM | Host | Operating System | Resources | Purpose |
|---|---|---|---|---|
| DC01 — VM 101 | Proxmox | Windows Server 2025 | 2 vCPUs, 4 GB RAM, 50 GB virtual disk | Active Directory and DNS |
| Ubuntu — VM 100 | Proxmox | Ubuntu Server | 2 vCPUs, 2 GB RAM, 20 GB virtual disk | Linux administration and SSH; planned file server |
| Employee workstation | Hyper-V | Windows 11 Pro | 2 vCPUs, 6 GB RAM, 80 GB virtual disk | Domain login and Group Policy testing |

The employee VM is joined to the lab domain. The personal PC’s Windows installation remains separate.

Virtual disk sizes are configured capacities, not current physical storage usage.

## Active Directory

**Domain:** `<redacted>.home.arpa`

The directory contains department OUs for **IT, HR, Finance, Sales, and Engineering**, along with workstation, server, group, and service-account OUs. Sample users and department security groups were created using PowerShell.

## Completed

- Installed and updated Proxmox VE.
- Deployed Ubuntu Server and verified SSH access.
- Deployed Windows Server 2025 with VirtIO drivers.
- Configured Active Directory Domain Services and DNS.
- Created organizational units, users, and security groups.
- Deployed a Windows 11 employee VM and joined it to the domain.
- Verified employee domain login.
- Applied and verified a workstation screen-lock Group Policy.
- Resolved a clock synchronization issue that prevented Group Policy updates.

## Planned Work

- Configure departmental file shares and test access permissions.
- Deploy Wazuh and Sysmon for centralized security monitoring.
- Configure and verify network isolation before attack exercises.
- Perform controlled attacks and document detection and investigation.
- Explore network monitoring and intrusion detection.
- Test backups and recovery.
- Migrate company servers to another host with a validation and rollback plan.

## Project Files

- [Documentation](docs/) — Setup guides, troubleshooting, and test results
- [Scripts](scripts/) — Administration and automation scripts
- [Screenshots](screenshots/) — Configuration and validation evidence
- [Diagrams](diagrams/) — Lab architecture and network layout
