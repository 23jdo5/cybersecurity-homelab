
# Active Directory Lab

## Objective

Deploy a Windows Server domain controller and create a simulated corporate Active Directory environment.

## Environment

- Windows Server 2025
- Active Directory Domain Services
- DNS
- Proxmox VE

## Domain

`<redacted>.home.arpa`

## Domain Controller

`DC01`

## Organizational Units

- Corp-Users
  - IT
  - HR
  - Finance
  - Sales
  - Engineering
- Corp-Computers
  - Workstations
  - Servers
- Groups
- Service-Accounts

## Security Groups

- GG_IT
- GG_HR
- GG_FINANCE
- GG_SALES
- GG_ENGINEERING

## Deployment

1. Created a Windows Server VM in Proxmox.
2. Installed VirtIO storage drivers.
3. Installed VirtIO network drivers.
4. Configured a static IPv4 address.
5. Installed Active Directory Domain Services.
6. Created a new Active Directory forest.
7. Configured DNS.
8. Promoted DC01 to a domain controller.
9. Created organizational units, users, and groups using PowerShell.

## Troubleshooting

### Windows installer could not detect the virtual disk

Windows Server initially did not detect the SCSI virtual disk.

Solution:

Mounted the VirtIO driver ISO and loaded the VirtIO SCSI driver during Windows installation.

### Network adapter missing

Windows Server did not initially detect the VirtIO network adapter.

Solution:

Installed the NetKVM network driver from the VirtIO driver ISO.

### PowerShell provisioning script failed

The original PowerShell script referenced the wrong domain distinguished name.

Solution:

Corrected the domain DN and reran the provisioning script successfully.
