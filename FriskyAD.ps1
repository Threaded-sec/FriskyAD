# Prompt for username and password
$uname = Read-Host "Enter your username"
$pass = Read-Host "Enter your password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($uname, $pass)

# Query machine account quota on the domain controller
$quota = Get-ADObject -Identity ((Get-ADDomain).distinguishedname) -Properties ms-DS-MachineAccountQuota

Write-Host "Machine Account Quota on Domain Controller: $quota"

# Get domain's password policy
$passwordPolicy = Get-ADDefaultDomainPasswordPolicy -Credential $cred
Write-Host "Domain Password Policy:"
Write-Host "MaxPasswordAge: $($passwordPolicy.MaxPasswordAge)"
Write-Host "MinPasswordAge: $($passwordPolicy.MinPasswordAge)"
Write-Host "MinPasswordLength: $($passwordPolicy.MinPasswordLength)"
Write-Host "PasswordHistoryCount: $($passwordPolicy.PasswordHistoryCount)"
Write-Host "PasswordComplexity: $($passwordPolicy.PasswordComplexity)"

#  Get users whose password age is more than 1 year
$oneYearAgo = (Get-Date).AddYears(+1)
$oldUsers = Get-ADUser -Filter {Enabled -eq $true -and PasswordLastSet -lt $oneYearAgo} -Credential $cred
Write-Host "Users with Password Age > 1 year:"
$oldUsers | Select-Object Name, SamAccountName, PasswordLastSet

# Get machine accounts with unconstrained delegation
$unconstrainedAccounts = Get-ADComputer -Filter {UserAccountControl -band 0x800} -Credential $cred
Write-Host "Machine Accounts with Unconstrained Delegation:"
$unconstrainedAccounts | Select-Object Name, SamAccountName
