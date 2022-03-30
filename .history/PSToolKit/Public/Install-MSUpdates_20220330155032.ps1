
<#PSScriptInfo

.VERSION 0.1.0

.GUID 326a9303-0edf-4c9a-b446-ea1460b24f13

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
Created [30/03/2022_15:43] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Perform windows update

#>


<#
.SYNOPSIS
Perform windows update

.DESCRIPTION
Perform windows update

.EXAMPLE
Install-MSUpdates

#>
Function Install-MSUpdates {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MSUpdates')]
	PARAM(
		[switch]$PerformReboot = $false
	)

	try {
		$UpdateModule = Get-Module PSWindowsUpdate
		if ($null -like $UpdateModule) {$UpdateModule = Get-Module PSWindowsUpdate -ListAvailable}
		if ($null -like $UpdateModule) {
			Write-Color '[Installing] ', 'Required Modules: ', 'PSWindowsUpdate' -Color Yellow, green, Cyan
			Install-Module -Name PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
		}
		Import-Module PSWindowsUpdate -Force
		Write-Color '[Installing] ', 'Windows Updates:', ' Software' -Color Yellow, Cyan, Green
		Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Software
		Write-Color '[Installing] ', 'Windows Updates:', ' Drivers' -Color Yellow, Cyan, Green
		Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Driver
	} catch { Write-Warning "[Installing] Windows Updates: Failed:`n $($_.Exception.Message)" }

	if ($PerformReboot) {
		try {
			Write-Color '[Checking] ', 'Pending Reboot' -Color Yellow, Cyan
			$checkreboot = Test-PendingReboot -ComputerName $env:computername
			if ($checkreboot.IsPendingReboot -like 'True') {
				Write-Color '[Checking] ', 'Reboot Required', ' (Reboot in 15 sec)' -Color Yellow, DarkRed, Cyan
				Start-Sleep -Seconds 15
				Restart-Computer -Force
			} else {
				Write-Color '[Checking] ', 'Reboot Not Required' -Color Yellow, Cyan
			}
		} catch { Write-Warning "[Checking] Required Reboot: Failed:`n $($_.Exception.Message)" }
	}
} #end Function
