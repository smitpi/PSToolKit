
<#PSScriptInfo

.VERSION 0.1.0

.GUID 5a6964c3-1f7f-48e1-9963-524b2f2b4dc2

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [19/02/2022_11:19] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Creates a God Mode Folder

#>


<#
.SYNOPSIS
Creates a God Mode Folder

.DESCRIPTION
Creates a God Mode Folder

.EXAMPLE
New-GodModeFolder

#>
Function New-GodModeFolder {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-GodModeFolder')]
	PARAM()


	New-Item -Path ([Environment]::GetFolderPath('Desktop')) -Name 'God Mode .{ED7BA470-8E54-465E-825C-99712043E01C}' -ItemType directory -Force

} #end Function
