
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
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Install-MSUpdates")]
                PARAM(
					[switch]$PerformReboot = $false
				)


} #end Function
