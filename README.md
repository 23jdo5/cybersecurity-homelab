# Cybersecurity Homelab

## Goal

Build a small enterprise-style cybersecurity environment to practice virtualization, Windows Server administration, Active Directory, Linux, networking, security monitoring, and incident response.

## Hardware

- 3x Intel Core i5-4690K desktop systems
- Primary Proxmox host: 12 GB DDR3 RAM
- Secondary systems: 8 GB DDR3 RAM each
- ~120 GB SSDs
- TP-Link Gigabit Ethernet switch

## Current Environment

- Proxmox VE
- Ubuntu Server
- Windows Server 2025
- Active Directory Domain Services
- DNS
- PowerShell automation

## Active Directory Domain

Domain:

`<redacted>.home.arpa`

## Active Directory Structure

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

## Current Progress

- Installed and updated Proxmox VE
- Created Ubuntu Server VM
- Configured SSH and Linux administration tools
- Created Windows Server 2025 VM
- Installed VirtIO storage and network drivers
- Configured static networking
- Installed Active Directory Domain Services
- Promoted Windows Server to a Domain Controller
- Created Organizational Units, users, and security groups with PowerShell

## Planned Work

- Deploy Windows client workstation
- Join workstation to Active Directory
- Configure Group Policy
- Deploy centralized security monitoring
- Install Sysmon
- Deploy Wazuh
- Add network monitoring and IDS
- Perform controlled attack/detection exercises
