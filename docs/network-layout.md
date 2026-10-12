# Lab Network Layout

## Objective

Document how the lab systems communicate and distinguish the current network from planned security isolation.

## Current Connections

- Lab PC 1 runs Proxmox and connects through a TP-Link Gigabit Ethernet switch to the home network.
- DC01 and Ubuntu run as VMs on Lab PC 1.
- The personal PC connects to the home network over Wi-Fi.
- The Windows employee VM runs on the personal PC using Hyper-V’s Default Switch.
- The Default Switch provides a private virtual network with NAT through the personal PC’s connection.

The employee VM is not directly bridged onto the home network. Connections initiated by the VM can reach accessible home-network services through NAT.

## Logical Layout

```text
Home network / Spectrum router
├── TP-Link Gigabit Ethernet switch
│   └── Lab PC 1 — Proxmox
│       ├── DC01 — Active Directory and DNS
│       └── Ubuntu — Samba file server
│
└── Wi-Fi
    └── Personal PC — Hyper-V
        └── Default Switch — private network / NAT
            └── Windows employee VM
```

This diagram shows logical connections, not exact physical port assignments.

## Addressing and DNS

| System | Configuration |
|---|---|
| Proxmox host | Static home-network IPv4 address |
| DC01 | Static IPv4 address; provides DNS for the lab domain |
| Ubuntu | Automatic IPv4 assignment with a reservation on the Spectrum router |
| Ubuntu DNS | Configured through Netplan to use DC01 |
| Employee VM | Automatic IP assignment through the Default Switch |
| Employee VM preferred DNS | DC01’s IPv4 address |

Actual addresses are omitted from this document. Replace placeholders before running commands.

### Ubuntu DHCP Reservation

Reserved Ubuntu’s current IPv4 address using its `ens18` MAC address in the Spectrum router settings.

After restarting Ubuntu, verified that:

- It retained the reserved address.
- The employee workstation could still access the Engineering share.

### Ubuntu DNS Record

Created an A record named `ubuntu01` on DC01, pointing to Ubuntu’s reserved address.

Verified resolution from the employee workstation:

```text
nslookup ubuntu01.<domain>
```

Then successfully accessed:

```text
\\ubuntu01.<domain>\Engineering
```

The missing-record investigation and zone-classification findings are documented in [Samba File Sharing](file-sharing.md).

## Verified Connectivity

### Employee Workstation to DC01

- TCP connectivity to DNS port 53 succeeded.
- The domain’s LDAP SRV lookup returned DC01.
- The workstation successfully joined the domain.
- A domain user successfully signed in.
- Group Policy updates completed after correcting DC01’s clock.

### Ubuntu to Domain Services

- Ubuntu resolved DC01 and the domain’s LDAP SRV record.
- Public DNS resolution also succeeded.
- Ubuntu joined Active Directory through Samba and Winbind.
- Domain users and group memberships resolved successfully.

### Employee Workstation to Ubuntu

- Ethan accessed the Engineering share and created a file.
- Sarah from HR was denied access.
- Access worked through both the reserved IP address and the DNS hostname.
- Access by IP remained functional after Ubuntu restarted.

These access tests demonstrate permissions for the tested users; they do not establish network isolation.

## Current Boundaries

- The personal PC’s Windows installation is not joined to the domain.
- The employee VM and Ubuntu file server are joined to the domain.
- Dedicated lab network isolation has not yet been configured or verified.
- The Default Switch’s NAT connection is not a substitute for an isolated attack lab.
- Inbound connections from other lab machines to the employee VM have not been validated.
- No port-forwarding rule was required for the local file-sharing setup.

## Planned Networking Work

Before introducing attack exercises:

1. Document router and switch capabilities.
2. Choose an isolated network design for lab systems.
3. Define permitted communication between attacker, company, and monitoring systems.
4. Verify separation from unrelated home devices.
5. Validate connectivity required for monitoring and administration.

PC 2 is planned as the attacker system. PC 3 is planned for centralized monitoring. Neither is represented as operational in this layout.
