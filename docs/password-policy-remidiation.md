# Password Policy Remediation with Wazuh and Group Policy

## Objective

Use Wazuh to identify a weak workstation password policy, remediate it through Active Directory Group Policy, and verify the result.

## Environment

- DC01: Windows Server 2025 domain controller
- Employee workstation: Domain-joined Windows 11 VM
- Wazuh: Centralized security monitoring on a dedicated Ubuntu server

## Finding

Wazuh Security Configuration Assessment flagged:

> Ensure minimum password length is set to 14 or more characters.

The check initially showed **Failed**.

On the employee workstation, the following command confirmed a minimum password length of **7 characters**:

    net accounts

This check evaluates the password policy, not the length of an individual user's existing password.

## Remediation

On DC01, edited the Default Domain Policy at:

Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy

Changed **Minimum password length** from **7** to **14 characters**.

On the employee workstation, refreshed Group Policy from an elevated PowerShell window:

    gpupdate /force

## Verification

Ran the following command on the employee workstation:

    net accounts

Confirmed that **Minimum password length** now showed **14**.

Restarted the Wazuh agent from an elevated PowerShell window to trigger a new security assessment:

    Restart-Service -Name WazuhSvc

After the assessment completed, the minimum password length check changed from **Failed** to **Passed**.

## Evidence

### Before: Failed Wazuh check

TBD
### Applied workstation policy

TBD
### After: Passed Wazuh check

TBD
## Result

Remediated one security configuration finding and verified both the applied Windows policy and the updated Wazuh assessment.

The new minimum applies when passwords are changed or reset. It does not automatically replace existing passwords or prove that they already contain 14 characters.
