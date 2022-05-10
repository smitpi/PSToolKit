
<#PSScriptInfo

.VERSION 0.1.0

.GUID b91e8dbd-ece2-4d77-86ad-3a7d15772257

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Get user AD details

#>



<#
.SYNOPSIS
Exstact user details from the domain

.DESCRIPTION
Exstact user details from the domain

.PARAMETER UserToQuery
User id to searh for.

.PARAMETER DomainFQDN
Domain to search

.PARAMETER DomainCredential
Userid to connect to that domain.

.EXAMPLE
Get-FullADUserDetail -UserToQuery ps

#>
Function Get-FullADUserDetail {
	[Cmdletbinding(DefaultParameterSetName = 'CurrentDomain' , HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FullADUserDetail')]
	PARAM(
		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$UserToQuery,
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[string]$DomainFQDN,
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[pscredential]$DomainCredential
	)

	if ($null -notlike $DomainFQDN) {
		if (-not($DomainCredential)) {$DomainCredential = Get-Credential -Message "Account to connnect to $($DomainFQDN)"}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
		try {
			$AllUserDetails = Get-ADUser -Identity $UserToQuery -server $DomainFQDN -Credential $DomainCredential -Properties *
			[pscustomobject]@{
				UserSummary    = $AllUserDetails | Select-Object Name, GivenName, Surname, UserPrincipalName, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				AllUserDetails = $AllUserDetails
				MemberOf       = $AllUserDetails.memberof | ForEach-Object { 
					$Cname = $_
					$Split = (($Cname.Split(',DC=')) | Where-Object {$null -notlike $_})
					$NewDomain = "$($Split[-3]).$($Split[-2]).$($Split[-1])"
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Connecting] to doamin: $($Domain)"
					Get-ADGroup -Identity $_ -Server $NewDomain -Credential $DomainCredential
				}
			}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	} else {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
		try {
			$AllUserDetails = Get-ADUser -Identity $UserToQuery -Properties *
			[pscustomobject]@{
				UserSummary    = $AllUserDetails | Select-Object Name, GivenName, Surname, UserPrincipalName, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				AllUserDetails = $AllUserDetails
				MemberOf       = $AllUserDetails.memberof | ForEach-Object { 
					$Cname = $_
					$Split = (($Cname.Split(',DC=')) | Where-Object {$null -notlike $_})
					$NewDomain = "$($Split[-3]).$($Split[-2]).$($Split[-1])"
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Connecting] to doamin: $($Domain)"
					Get-ADGroup -Identity $_ -Server $NewDomain
				}
			}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}
} #end Function