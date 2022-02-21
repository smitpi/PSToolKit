
<#PSScriptInfo

.VERSION 0.1.0

.GUID 2c8e55fa-28b5-4a7e-b2ae-525d12ed9c55

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
 Install PS7 on the device

#>

<#
.SYNOPSIS
 Install PS7 on the device

.DESCRIPTION
 Install PS7 on the device

.EXAMPLE
 Install-PS7

.NOTES
General notes
#>
function Install-PS7 {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PS7')]
	PARAM()
 if ((Test-Path 'C:\Program Files\PowerShell\7') -eq $false) {
	 Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
	 Write-Host 'PowerShell 7 Installation:' -ForegroundColor Cyan -NoNewline
	 Write-Host 'Successfull' -ForegroundColor Yellow
	}
 else {
	 Write-Host 'PowerShell 7 Installation:' -ForegroundColor Cyan -NoNewline
 	Write-Host 'Already Installed' -ForegroundColor Yellow
	}
}
