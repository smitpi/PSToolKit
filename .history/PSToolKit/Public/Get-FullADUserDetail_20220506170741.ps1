
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
Extract handy info of an AD user

.DESCRIPTION
Extract handy info of an AD user

.PARAMETER UserToQuery
AD User name to search.

.EXAMPLE
Get-FullADUserDetail -UserToQuery ps

#>
Function Get-FullADUserDetail {
	[Cmdletbinding(DefaultParameterSetName = 'CurrentDomain' , HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FullADUserDetail')]
	PARAM(
		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$UserToQuery,
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[string]$DomainFQDN = $($env:USERDNSDOMAIN),
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[pscredential]$DomainCredential
		)

		if ($DomainCredential) {

			
		}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
	$UserSummery = Get-ADUser $UserToQuery -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
	$AllUserDetails = Get-ADUser $UserToQuery -Properties *
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] User Groups"
	$AllUserGroups = Get-ADUser $UserToQuery -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ }
	$CusObject = New-Object PSObject -Property @{
		DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		UserSummery    = $UserSummery
		AllUserDetails = $AllUserDetails
		AllUserGroups  = $AllUserGroups
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] User Details"
	$CusObject

} #end Function

