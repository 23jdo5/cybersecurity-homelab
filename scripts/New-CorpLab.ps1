Import-Module ActiveDirectory

# Base paths
$DomainDN = "DC=smittycorp,DC=home,DC=arpa"
$UsersOU = "OU=Corp-Users,$DomainDN"
$ComputersOU = "OU=Corp-Computers,$DomainDN"
$GroupsOU = "OU=Groups,$DomainDN"
$ServiceOU = "OU=Service-Accounts,$DomainDN"

# Create top-level OUs
$TopLevelOUs = @(
    @{Name="Corp-Users"; Path=$DomainDN},
    @{Name="Corp-Computers"; Path=$DomainDN},
    @{Name="Groups"; Path=$DomainDN},
    @{Name="Service-Accounts"; Path=$DomainDN}
)

foreach ($ou in $TopLevelOUs) {
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$($ou.Name))" -SearchBase $ou.Path -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path
    }
}

# Create department OUs
$Departments = @(
    "IT",
    "HR",
    "Finance",
    "Sales",
    "Engineering"
)

foreach ($dept in $Departments) {
    $DeptPath = "OU=$dept,$UsersOU"

    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$dept)" -SearchBase $UsersOU -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $dept -Path $UsersOU
    }
}

# Create computer OUs
$ComputerOUs = @(
    "Workstations",
    "Servers"
)

foreach ($ou in $ComputerOUs) {
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$ou)" -SearchBase $ComputersOU -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $ComputersOU
    }
}

# Create global security groups
foreach ($dept in $Departments) {
    $GroupName = "GG_$($dept.ToUpper())"

    if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $GroupName `
            -SamAccountName $GroupName `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $GroupsOU
    }
}

# Temporary lab password
$Password = ConvertTo-SecureString "NOTHING_TO_SEE_HERE!" -AsPlainText -Force

# Sample users
$Users = @(
    @{
        First="Alice"
        Last="Nguyen"
        Username="anguyen"
        Department="IT"
    },
    @{
        First="Marcus"
        Last="Lee"
        Username="mlee"
        Department="IT"
    },
    @{
        First="Sarah"
        Last="Miller"
        Username="smiller"
        Department="HR"
    },
    @{
        First="Daniel"
        Last="Kim"
        Username="dkim"
        Department="Finance"
    },
    @{
        First="Jessica"
        Last="Brown"
        Username="jbrown"
        Department="Sales"
    },
    @{
        First="Ethan"
        Last="Chen"
        Username="echen"
        Department="Engineering"
    },
    @{
        First="Priya"
        Last="Patel"
        Username="ppatel"
        Department="Engineering"
    }
)

foreach ($user in $Users) {

    $Name = "$($user.First) $($user.Last)"
    $UserOU = "OU=$($user.Department),$UsersOU"
    $UPN = "$($user.Username)@smittycorp.home.arpa"

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.Username)'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name $Name `
            -GivenName $user.First `
            -Surname $user.Last `
            -SamAccountName $user.Username `
            -UserPrincipalName $UPN `
            -Department $user.Department `
            -Path $UserOU `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Add-ADGroupMember `
            -Identity "GG_$($user.Department.ToUpper())" `
            -Members $user.Username
    }
}

Write-Host "CORP Active Directory structure created successfully."
