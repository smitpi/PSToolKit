
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3d0f3d53-1164-484c-937f-c567a1c794ba

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
Created [30/03/2022_15:37] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Install ps7

#>


<#
.SYNOPSIS
Install ps7

.DESCRIPTION
Install ps7

.EXAMPLE
Install-PowerShell7x

#>
Function Install-PowerShell7x {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PowerShell7x')]
	PARAM()

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

	try {
		$ReleaseModule = Get-Module PSReleaseTools
		if ($null -like $ReleaseModule) {$ReleaseModule = Get-Module PSReleaseTools -ListAvailable}
		if ($null -like $ReleaseModule) {
			Write-Color '[Installing] ', 'Required Modules: ', 'PSReleaseTools' -Color Yellow, green, Cyan
			Install-Module -Name PSReleaseTools -Scope CurrentUser -AllowClobber -Force
		}
		Import-Module PSReleaseTools -Force
		if ((Test-Path 'C:\Program Files\PowerShell\7') -eq $false) {
			Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
			Write-Color '[Installing] ', 'PowerShell 7.x ', 'Complete' -Color Yellow, Cyan, Green
		}elseif (($PSVersionTable.PSVersion) -lt ([version]((Get-PSReleaseCurrent).version).replace('v', $null))) {
				Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
				Write-Color '[Upgrading] ', 'PowerShell 7.x ', 'Complete' -Color Yellow, Cyan, Green
			}
		else {
			Write-Color '[Installing] ', 'PowerShell 7.x: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
		}
	} catch { Write-Warning "[Installing] PowerShell 7.x: Failed:`n $($_.Exception.Message)" }

} #end Function
