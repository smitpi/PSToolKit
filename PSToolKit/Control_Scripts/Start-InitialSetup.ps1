
<#PSScriptInfo

.VERSION 0.1.0

.GUID d5ba2e17-aac4-4e99-9177-982a1f2f21ac

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
Created [18/12/2022_02:26] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Start Setup 

#> 


<#
.SYNOPSIS
Start Setup

.DESCRIPTION
Start Setup

.PARAMETER DomainName
The domain name to join.

.PARAMETER DomainUser
The domain user to join with.

.PARAMETER DomainPassword
The domain password to join with.

.PARAMETER GitHubToken
The GitHub token to use.

.EXAMPLE
Start-InitialSetup -DomainName 'xxx.local' -DomainUser 'Administrator' -DomainPassword 'P@ssw0rd'

#>
Function Start-InitialSetup {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-InitialSetup')]
	#region Parameter
	PARAM(
		[string]$DomainName,
		[string]$DomainUser,
		[securestring]$DomainPassword,
		[string]$GitHubToken
	)
	#endregion

	If (!(Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain) {
		Write-Host -ForegroundColor Red 'This machine is not part of a domain. Adding now.'
		$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, $DomainPassword)
    
		Rename-Computer -ComputerName $env:COMPUTERNAME -NewName "Dev-$(Get-Random -Maximum 5000)"
		Start-Sleep 5
		Add-Computer -DomainName $DomainName -Credential $labcred -Options JoinWithNewName, AccountCreate -Force -Restart
	}

	$PSTemp = "$env:TEMP\PSTemp"
	if (Test-Path $PSTemp) {Remove-Item $PSTemp -Force -Recurse}
	$PSDownload = New-Item $PSTemp -ItemType Directory -Force

	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
	$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
	Import-Module $full.FullName -Force
	Start-PSToolkitSystemInitialize -GitHubToken $GitHubToken -LabSetup -InstallMyModules
	Remove-Item $full.FullName
} #end Function
