
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3b0bff71-01b7-4383-b539-798ea6b03096

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ad

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [27/05/2022_08:34] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Compare two users AD group memberships 

#> 


<#
.SYNOPSIS
Compare two users AD group memberships

.DESCRIPTION
Compare two users AD group memberships

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Compare-ADMembership -Export HTML -ReportPath C:\temp

#>
Function Compare-ADMembership {
	[Cmdletbinding(DefaultParameterSetName = 'CurrentDomain', HelpURI = 'https://smitpi.github.io/PSToolKit/Compare-ADMembership')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$ReferenceUser,

		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$DifferenceUser,

		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[string]$DomainFQDN,

		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[pscredential]$DomainCredential
	)

	if ($null -notlike $DomainFQDN) {
		if (-not($DomainCredential)) {$DomainCredential = Get-Credential -Message "Account to connnect to $($DomainFQDN)"}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		try {
			$FullReferenceUser = Get-ADUser -Identity $ReferenceUser -Properties * -Server $DomainFQDN -Credential $DomainCredential
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		try {
			$FullDifferenceUser = Get-ADUser -Identity $DifferenceUser -Properties * -Server $DomainFQDN -Credential $DomainCredential
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}

		$Compare = Compare-Object -ReferenceObject $FullReferenceUser.memberof -DifferenceObject $FullDifferenceUser.memberof -IncludeEqual

		$DiffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '=>'}).InputObject | ForEach-Object {
			$ADgroup = Get-ADGroup -Identity $_ -Server $DomainFQDN -Credential $DomainCredential
			[PSCustomObject]@{
				UserName               = $FullDifferenceUser.DisplayName
				UserSamAccountName     = $FullDifferenceUser.SamAccountName
				UserUPN                = $FullDifferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$ReffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '<='}).InputObject | ForEach-Object {
			$ADgroup = Get-ADGroup -Identity $_ -Server $DomainFQDN -Credential $DomainCredential
			[PSCustomObject]@{
				UserName               = $FullReferenceUser.DisplayName
				UserSamAccountName     = $FullReferenceUser.SamAccountName
				UserUPN                = $FullReferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$EqualMembers = ($Compare | Where-Object {$_.SideIndicator -like '=='}).InputObject | ForEach-Object {Get-ADGroup -Identity $_ -Server $DomainFQDN -Credential $DomainCredential | Select-Object Name, DistinguishedName}
		
		[PSCustomObject]@{
			DiffUserMissing = $DiffUserMissing
			ReffUserMissing = $ReffUserMissing
			EqualMembers    = $EqualMembers
		}
	} else {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		try {
			$FullReferenceUser = Get-ADUser -Identity $ReferenceUser -Properties *
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		try {
			$FullDifferenceUser = Get-ADUser -Identity $DifferenceUser -Properties *
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}

		$Compare = Compare-Object -ReferenceObject $FullReferenceUser.memberof -DifferenceObject $FullDifferenceUser.memberof -IncludeEqual

		$DiffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '=>'}).InputObject | ForEach-Object {
			$ADgroup = Get-ADGroup -Identity $_
			[PSCustomObject]@{
				UserName               = $FullDifferenceUser.DisplayName
				UserSamAccountName     = $FullDifferenceUser.SamAccountName
				UserUPN                = $FullDifferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$ReffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '<='}).InputObject | ForEach-Object {
			$ADgroup = Get-ADGroup -Identity $_
			[PSCustomObject]@{
				UserName               = $FullReferenceUser.DisplayName
				UserSamAccountName     = $FullReferenceUser.SamAccountName
				UserUPN                = $FullReferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$EqualMembers = ($Compare | Where-Object {$_.SideIndicator -like '=='}).InputObject | ForEach-Object {Get-ADGroup -Identity $_ | Select-Object Name, DistinguishedName}
		[PSCustomObject]@{
			DiffUserMissing = $DiffUserMissing
			ReffUserMissing = $ReffUserMissing
			EqualMembers    = $EqualMembers
		}
	}
} #end Function
