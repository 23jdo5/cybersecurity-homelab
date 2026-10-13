# Security Monitoring with Wazuh

## Objective

Deploy centralized security monitoring, collect Windows security events, and practice identifying, remediating, and verifying security configuration findings.

## Environment

| System | Role | Monitoring status |
|---|---|---|
| PC 3 — wazuh01 | Wazuh server, indexer, and dashboard | Operational |
| Windows 11 employee VM | Domain-joined employee workstation | Agent connected and Active |
| DC01 | Active Directory and DNS | Agent connected and Active; Windows Security events verified |
| Ubuntu file server | Samba departmental file sharing | Agent deployment planned |

## Monitoring Server

| Component | Configuration |
|---|---|
| Hardware | Intel Core i5-4440, 8 GB RAM, 120 GB SSD |
| Operating system | Ubuntu Server 24.04.5 LTS |
| Network | Ethernet with a DHCP reservation |
| Administration | SSH |
| Wazuh deployment | All central components on one server |

## Server Preparation

1. Installed Ubuntu Server on PC 3.
2. Enabled SSH for remote administration.
3. Configured the Ethernet interface, `enp3s0`, to obtain an IPv4 address through DHCP.
4. Verified remote SSH access after restarting the server.
5. Updated Ubuntu packages.
6. Expanded the Ubuntu logical volume and filesystem to use the remaining free space in its LVM storage pool.
7. Reserved the server’s IP address in the router.

### Storage Allocation

The Ubuntu installation initially assigned approximately half of the SSD’s available LVM space to the root logical volume.

Inspected the allocation:

```bash
lsblk
sudo vgs
df -h /
```

Expanded the logical volume and filesystem:

```bash
sudo lvextend -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv
```

Verified the result:

```bash
df -h /
```

Approximately **95 GiB was available** after expansion and before installing Wazuh.

## Wazuh Installation

Downloaded the official Wazuh 4.14 installation assistant:

```bash
curl -fSLo wazuh-install.sh https://packages.wazuh.com/4.14/wazuh-install.sh
```

Installed the server, indexer, and dashboard:

```bash
sudo bash ./wazuh-install.sh -a
```

After installation:

- Saved the generated administrator credentials privately.
- Opened the dashboard over HTTPS using the monitoring server’s address.
- Signed in and confirmed dashboard access.

Passwords and installer-generated credential files are excluded from this documentation.

## Employee Workstation Enrollment

1. Opened **Deploy new agent** in the Wazuh dashboard.
2. Selected Windows.
3. Entered the Wazuh server’s reserved IP address.
4. Ran the generated installation command in an elevated PowerShell window inside the employee VM.
5. Started the agent service using `Start-Service -Name WazuhSvc`.
6. Confirmed the workstation appeared as **Active** in the dashboard.

The agent is installed inside the employee VM. The personal PC’s host Windows installation is separate.

### Initial Connection Checks

The employee agent initially appeared as **Never connected**.

Checked its service:

```powershell
Get-Service -Name WazuhSvc
```

Result: **Running**.

Tested connectivity to the Wazuh server:

```powershell
Test-NetConnection -ComputerName <WAZUH-SERVER-IP> -Port 1514
```

Replace `<WAZUH-SERVER-IP>` with the monitoring server’s reserved address.

Result: **TcpTestSucceeded: True**.

The agent subsequently changed to **Active**. No configuration change was confirmed as necessary to resolve the initial status.

### Initial Security Configuration Assessment

| Result | Value |
|---|---:|
| Passed | 126 |
| Failed | 347 |
| Not applicable | 9 |
| Score | 26% |

These are the initial baseline results, not the current totals after remediation.

The score measures compliance with the assessment’s configuration checks. Failed checks do not, by themselves, indicate a compromise.

### First Verified Remediation

Wazuh flagged a minimum password length below 14 characters.

The workstation initially reported a minimum of 7 characters. After updating Group Policy and refreshing the workstation’s policy, it reported 14.

Restarted the Wazuh agent from an elevated PowerShell window:

```powershell
Restart-Service -Name WazuhSvc
```

A new assessment completed, and the check changed from **Failed** to **Passed**.

See [Password Policy Remediation](password-policy-remediation.md) for the steps and before-and-after evidence.

## DC01 Enrollment

1. Generated a Windows agent installation command in the Wazuh dashboard.
2. Set the server address to the Wazuh server’s reserved IP address.
3. Set the agent name to `DC01`.
4. Ran the generated command in an elevated PowerShell window on DC01.
5. Started the agent service using `Start-Service -Name WazuhSvc`.
6. Confirmed DC01 appeared as **Active** in the dashboard.

### Initial Security Configuration Assessment

| Result | Value |
|---|---:|
| Passed | 106 |
| Failed | 292 |
| Score | 26% |

These results establish DC01’s baseline for future configuration reviews. The assessment findings have not all been investigated or remediated.

### Windows Security Event Collection

Opened **Threat hunting** for DC01 and inspected an event containing:

| Field | Observed value |
|---|---|
| `agent.name` | `DC01` |
| `data.win.system.channel` | `Security` |
| `data.win.system.eventID` | `4624` |

Event ID **4624** records a successful Windows logon.

This verifies that Wazuh is receiving Windows Security events from DC01. It does not yet demonstrate detection of an attack.

## Evidence

### Windows Agents Connected

![DC01 and employee workstation agents showing Active status](../screenshots/wazuh-windows-agents-active.png)

### Employee Workstation Baseline

![Initial employee security assessment](../screenshots/wazuh-employee-security-assessment.png)

### DC01 Baseline

![Initial DC01 security assessment](../screenshots/wazuh-dc01-security-assessment-before.png)

### DC01 Windows Security Event

![DC01 Security event 4624](../screenshots/wazuh-dc01-security-event.png)

Password-policy remediation screenshots are included in the [remediation document](password-policy-remediation.md).

## Current Scope

Verified:

- Wazuh dashboard access.
- Active agent connections from the employee workstation and DC01.
- Security configuration assessment results from both Windows systems.
- Remediation and reassessment of one workstation password-policy finding.
- Collection of a successful Windows logon event from DC01.

Not yet verified:

- Collection of Ubuntu file-server events.
- Sysmon event collection.
- Detection of a controlled attack.
- Alert retention, backup, and recovery.

## Next Steps

- Enroll the Ubuntu file server and verify event collection.
- Deploy Sysmon on Windows systems and verify its events reach Wazuh.
- Review security assessment findings individually before applying changes.
- Configure log retention appropriate for the monitoring server’s storage.
- Configure and test backups and recovery.
- Establish and verify network isolation before attack exercises.
- Perform a controlled detection test and document the resulting alert and investigation.
