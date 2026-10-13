# Security Monitoring with Wazuh

## Objective

Deploy centralized security monitoring and use an employee workstation to practice identifying, remediating, and verifying security configuration findings.

## Environment

| System | Role | Status |
|---|---|---|
| PC 3 — wazuh01 | Wazuh server, indexer, and dashboard | Operational |
| Windows 11 employee VM | Wazuh agent | Connected and Active |
| DC01 | Active Directory and DNS | Agent deployment planned |
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

Approximately **95 GB was available** after expansion and before installing Wazuh.

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
5. Started the agent service:

```powershell
Start-Service -Name WazuhSvc
```

6. Confirmed the workstation appeared as **Active** in the dashboard.

The agent is installed inside the employee VM. The personal PC’s host Windows installation is separate.

## Initial Connection Checks

The agent initially appeared as **Never connected**.

Checked its service:

```powershell
Get-Service -Name WazuhSvc
```

Result: **Running**.

Tested connectivity to the Wazuh server:

```powershell
Test-NetConnection -ComputerName <WAZUH-SERVER-IP> -Port 1514
```

Result: **TcpTestSucceeded: True**.

The agent subsequently changed to **Active**. No configuration change was confirmed as necessary to resolve the initial status.

## Security Configuration Assessment

The employee workstation’s initial assessment reported:

| Result | Count |
|---|---:|
| Passed | 126 |
| Failed | 347 |
| Not applicable | 9 |
| Score | 26% |

These are the initial baseline results, not the current totals after remediation.

The score measures compliance with the assessment’s configuration checks. It does not indicate whether the workstation has been compromised.

## First Verified Remediation

Wazuh flagged a minimum password length below 14 characters.

The workstation initially reported a minimum of 7 characters. After updating Group Policy and refreshing the workstation’s policy, it reported 14.

Restarting the Wazuh agent triggered a new assessment, and the check changed from **Failed** to **Passed**.

See [Password Policy Remediation](password-policy-remediation.md) for the steps and before-and-after evidence.

## Evidence

### Employee Agent Connected

![Employee agent showing Active status](../screenshots/wazuh-employee-agent-active.png)

### Initial Security Assessment

![Initial employee security assessment](../screenshots/wazuh-employee-security-assessment.png)

## Current Scope

Verified:

- Wazuh dashboard access.
- Employee agent connectivity.
- Receipt of workstation security assessment results.
- Remediation and reassessment of one password-policy finding.

Not yet verified:

- Collection of DC01 or Ubuntu file-server events.
- Sysmon event collection.
- Detection of a controlled attack.
- Alert retention, backup, and recovery.

## Next Steps

- Enroll DC01 and the Ubuntu file server.
- Verify security event collection from each system.
- Deploy Sysmon on Windows systems.
- Perform a controlled detection test and document the resulting alert.
- Configure log retention appropriate for the server’s storage.
- Establish network isolation before attack exercises.
