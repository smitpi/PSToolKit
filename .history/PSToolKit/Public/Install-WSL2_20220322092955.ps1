
<#PSScriptInfo

.VERSION 0.1.0

.GUID 62b9e7e7-90c0-4f13-902d-79818c2cdb3f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [22/03/2022_09:27] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Enable Windows-Subsystem-Linux 

#> 


<#
.SYNOPSIS
Enable Windows-Subsystem-Linux

.DESCRIPTION
Enable Windows-Subsystem-Linux

.EXAMPLE
Install-WSL2

#>
Function Install-WSL2 {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-WSL2')]
	[OutputType([System.Object[]])]
	PARAM()

wsl /?

	Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online
	Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online

} #end Function
