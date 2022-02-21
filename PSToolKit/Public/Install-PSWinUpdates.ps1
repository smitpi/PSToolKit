
<#PSScriptInfo

.VERSION 0.1.0

.GUID 46defaa6-a281-4aae-aee1-01f8f5ad66bb

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
 Install windows updates

#>

<#
.SYNOPSIS
Install windows updates

.DESCRIPTION
Install windows updates

.EXAMPLE
Install-PSWinUpdates

#>
function Install-PSWinUpdates {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSWinUpdates')]
	PARAM()
	Try {
		Install-WindowsUpdate -MicrosoftUpdate -UpdateType Software -AcceptAll -IgnoreReboot
		Install-WindowsUpdate -MicrosoftUpdate -UpdateType Driver -AcceptAll -IgnoreReboot

		Test-PendingReboot -ComputerName $env:computername
	}
	Catch {
		Write-Warning -Message $("Failed to update computer $($env:computername). Error: " + $_.Exception.Message)
		Break;
	}
}
