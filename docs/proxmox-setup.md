# Proxmox Setup

## Objective

Deploy a Proxmox VE host for the cybersecurity homelab’s company servers.

## Hardware

| Component | Specification |
|---|---|
| Motherboard | ASUS H81M-P |
| CPU | Intel Core i5-4440 |
| Memory | 12 GB DDR3 RAM |
| Storage | 120 GB SSD |
| Networking | Gigabit Ethernet through a TP-Link switch |
| Hostname | `pve01` |

## Installation

1. Created a bootable Proxmox VE USB installer.
2. Enabled Intel Virtualization Technology in BIOS.
3. Installed Proxmox VE onto the host SSD.
4. Assigned the server a static IPv4 address.
5. Configured the local router as the gateway and DNS resolver.
6. Connected the server through the gigabit Ethernet switch.
7. Accessed the Proxmox web interface remotely.
8. Disabled enterprise repositories.
9. Enabled the no-subscription repository.
10. Updated and rebooted the host.

## Virtual Machines

| VM ID | System | Resources | Role |
|---|---|---|---|
| 100 | Ubuntu Server 26.04.1 LTS | 2 vCPUs, 2 GB RAM, 20 GB virtual disk | AD-integrated Samba file server |
| 101 | DC01 — Windows Server 2025 | 2 vCPUs, 4 GB RAM, 50 GB virtual disk | Active Directory and DNS |

Ubuntu was initially deployed to practice VM creation, Linux installation, updates, and SSH access. It now hosts an Engineering file share authenticated through Active Directory.

Configuration and access tests are documented in [Samba File Sharing](file-sharing.md).

## Storage Layout

- **local:** Directory storage used for installation ISOs and other supported content.
- **local-lvm:** LVM-thin storage used for VM disks.

At the recorded checkpoint:

| Storage | Used | Total |
|---|---:|---:|
| local | 18.13 GB | 39.31 GB |
| local-lvm | 31.91 GB | 52.47 GB |

These figures are historical measurements, not live usage.

The two VM disks have a combined configured capacity of 70 GB. Thin provisioning allows physical storage to be consumed as data is written, so configured capacity can exceed the pool’s size. Actual usage must be monitored to prevent the pool from filling.

## Employee Workstation Placement

The Windows 11 employee VM was deployed on the personal PC using Hyper-V because the Proxmox host had limited remaining storage.

DC01 and Ubuntu remain on Proxmox. The employee VM connects to their services over the network.

See [Windows Client Setup](windows-client-setup.md) and [Lab Network Layout](network-layout.md).

## Service Dependencies

- DC01 provides domain authentication and DNS.
- Ubuntu provides the Engineering file share.
- Both VMs should be running during domain-authenticated file-sharing tests.
- A running Proxmox host does not necessarily mean its guest VMs are running; their status must also be checked.

## Troubleshooting

### Windows Server VM failed to boot

**Problem:** The VM remained at the Windows logo.

**Resolution:** Changed the VM’s CPU type to `host`.

**Validation:** Windows Server subsequently booted successfully.

## Open Follow-Up Items

- Investigate DC01’s reported high memory usage.
- Confirm clean shutdown behavior after the reported shutdown difficulty.
- Monitor available storage as the server VMs grow.

The causes of the memory and shutdown issues have not yet been established.

## Planned Improvements

- Configure and test VM backups.
- Document a successful restore.
- Review storage capacity before adding workloads.
- Later migrate the company servers to another host, preserving backups and documenting a rollback plan.
