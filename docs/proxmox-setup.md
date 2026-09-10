
# Proxmox Setup

## Objective

Deploy a Proxmox VE virtualization host for the cybersecurity homelab.

## Hardware

- Intel Core i5-4690K
- 12 GB DDR3 RAM
- ~120 GB SSD
- Gigabit Ethernet

## Installation

1. Created a bootable Proxmox VE USB installer.
2. Enabled Intel Virtualization Technology in BIOS.
3. Installed Proxmox VE onto the host SSD.
4. Assigned the server a static IPv4 address.
5. Configured the local router as the gateway and DNS resolver.
6. Connected the server to the network through a gigabit Ethernet switch.
7. Accessed the Proxmox web interface remotely.
8. Disabled enterprise repositories.
9. Enabled the no-subscription repository.
10. Updated and rebooted the Proxmox host.

## Troubleshooting

### Windows Server VM failed to boot

The Windows Server VM initially remained at the Windows logo.

Solution:

Changed the Proxmox VM CPU type to:

`host`

After changing the CPU model, Windows Server booted successfully.
