# Lab Network Layout

## Objective

Document how the current lab systems communicate and distinguish the existing network from planned security isolation.

## Current Connections

- Lab PC 1 runs Proxmox and connects through a TP-Link Gigabit Ethernet switch to the home network.
- DC01 and Ubuntu run as VMs on Lab PC 1.
- The personal PC connects to the home network over Wi-Fi.
- The Windows employee VM runs on the personal PC and uses Hyper-V’s Default Switch.
- The Default Switch provides a private virtual network with NAT through the personal PC’s connection.

The employee VM is not directly bridged onto the home network. Connections initiated by the VM can reach accessible home-network services through NAT.

## Logical Layout

```text
Home network / router
├── TP-Link Gigabit Ethernet switch
│   └── Lab PC 1 — Proxmox
│       ├── DC01 — Active Directory and DNS
│       └── Ubuntu Server
│
└── Wi-Fi
    └── Personal PC — Hyper-V
        └── Default Switch — private network / NAT
            └── Windows employee VM
```

This diagram shows the logical connections, not exact physical port assignments.

## Addressing and DNS

| System | Configuration |
|---|---|
| Proxmox host | Static home-network IPv4 address |
| DC01 | Static IPv4 address; provides DNS for the lab domain |
| Employee VM | Automatic IP assignment through the Default Switch |
| Employee VM preferred DNS | DC01’s IPv4 address |

Actual IP addresses and the domain name are omitted from this public documentation.

DC01’s DNS service allows the employee VM to locate the domain controller and join the Active Directory domain.

## Verified Connectivity

From the employee VM:

- A TCP connection to DC01’s DNS port 53 succeeded.
- The domain’s LDAP SRV lookup returned DC01.
- The workstation successfully joined the domain.
- A domain user successfully signed in.
- Group Policy updates completed after correcting the server’s clock.

## Current Boundaries

- The personal PC’s Windows installation is not joined to the lab domain.
- The employee VM is joined to the domain.
- Dedicated lab network isolation has not yet been configured or verified.
- The Default Switch’s NAT connection is not a substitute for a deliberately isolated attack lab.
- Inbound connections from other lab machines to the employee VM have not been validated.

## Planned Networking Work

Before introducing attack exercises:

1. Document the router and switch capabilities.
2. Choose an isolated network design for lab systems.
3. Define permitted communication between the attacker, company systems, and monitoring server.
4. Verify that lab exercises cannot reach unrelated home devices.
5. Validate connectivity required for monitoring and administration.

PC 2 is planned as the attacker system. PC 3 is planned for centralized security monitoring. Neither is represented as operational in the current layout.
