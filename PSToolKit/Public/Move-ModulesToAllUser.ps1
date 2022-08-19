
<#PSScriptInfo

.VERSION 0.1.0

.GUID 31df1f87-a5fb-40dc-87b5-6aea00de4b77

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
Created [04/08/2022_16:37] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Move modules from current user to all users

#>


<#
.SYNOPSIS
Move modules from current user to all users

.DESCRIPTION
Move modules from current user to all users

.PARAMETER AllUsers
Check if the user is an admin.

.EXAMPLE
Move-ModulesToAllUser

.NOTES
General notes
#>
Function Move-ModulesToAllUser {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Move-ModulesToAllUser')]
	[OutputType([System.Object[]])]
	PARAM(
	)

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Write-Error 'Must be running an elevated prompt run this function'; exit}

	$PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell', 'Modules')
	$PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell', 'Modules')

	if (Test-Path $PersonalWindowsPowerShell) {
		$modules = Get-ChildItem $PersonalWindowsPowerShell -Directory
		foreach ($mod in $modules) {
			Write-PSToolKitMessage -Action Moving -Object $mod.name -Message 'From WindowsPowerShell','To AllUsers' -MessageColor Gray,Green
			try {
				Move-Item -Path $mod.FullName -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction Stop
			} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		}
	}
	if (Test-Path $PersonalPowerShell) {
		$modules = Get-ChildItem $PersonalPowerShell -Directory
		foreach ($mod in $modules) {
			Write-PSToolKitMessage -Action Moving -Object $mod.name -Message 'From PowerShell','To AllUsers' -MessageColor Gray,Green
			try {
				Move-Item -Path $mod.FullName -Destination 'C:\Program Files\PowerShell\Modules' -ErrorAction Stop
			} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		}
	}
} #end Function
