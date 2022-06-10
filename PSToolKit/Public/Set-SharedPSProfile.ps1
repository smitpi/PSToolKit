﻿
<#PSScriptInfo

.VERSION 0.1.0

.GUID ffbca034-b277-4b80-bddb-2ef15dc7f585

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
 Redirects PowerShell profile to network share

#>


<#
.SYNOPSIS
Redirects PowerShell and WindowsPowerShell profile folder to another path.

.DESCRIPTION
Redirects PowerShell and WindowsPowerShell profile folder to another path.

.PARAMETER CurrentUser
Will change the currenly logged on user's folders.

.PARAMETER OtherUser
Will change another user's folders.

.PARAMETER OtherUserName
The username of the other user.

.PARAMETER PathToSharedProfile
Path to new folder. Folders PowerShell and WindowsPowerShell will be created if it doesnt exists.

.EXAMPLE
Set-SharedPSProfile -CurrentUser -PathToSharedProfile "\\nas01\profile"

.NOTES
General notes
#>
function Set-SharedPSProfile {
	[Cmdletbinding(DefaultParameterSetName = 'Current', HelpURI = 'https://smitpi.github.io/PSToolKit/Set-SharedPSProfile')]
	param (
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Current')]
		[switch]$CurrentUser,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Other')]
		[switch]$OtherUser,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Other')]
		[string]$OtherUserName,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (Test-Path $_) { $true }
				else { throw 'Not a valid Location' }
			})]
		[Parameter(ParameterSetName = 'Other')]
		[Parameter(ParameterSetName = 'Current')]
		[System.IO.DirectoryInfo]$PathToSharedProfile
	)

	try {
		if ($CurrentUser) {	$PersonalDocuments = [Environment]::GetFolderPath('MyDocuments') }
		if ($OtherUser) { $PersonalDocuments = [IO.Path]::Combine("$($env:HOMEDRIVE)", 'Users', $($OtherUserName), 'Documents') }
		if ($null -like $PersonalDocuments) { throw 'No User selected.' }

		$WindowsPowerShell = [IO.Path]::Combine($PersonalDocuments, 'WindowsPowerShell')
		$PowerShell = [IO.Path]::Combine($PersonalDocuments, 'PowerShell')

		if ((Test-Path $WindowsPowerShell) -eq $true ) {
			Write-Warning 'Folder exists, renamig now...'
			Rename-Item -Path $WindowsPowerShell -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose

		}

		if ((Test-Path $PowerShell) -eq $true ) {
			Write-Warning 'Folder exists, renamig now...'
			Rename-Item -Path $PowerShell -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose
		}
	}
 catch { Write-Warning "Error: `nMessage:$($_.Exception.Message)" }

	if (-not(Test-Path $WindowsPowerShell) -and -not(Test-Path $PowerShell)) {
		$NewWindowsPowerShell = [IO.Path]::Combine($PathToSharedProfile, 'WindowsPowerShell')
		$NewPowerShell = [IO.Path]::Combine($PathToSharedProfile, 'PowerShell')

		if (-not(Test-Path $NewWindowsPowerShell)) { New-Item $NewWindowsPowerShell -ItemType Directory -Force }
		if (-not(Test-Path $NewPowerShell)) { New-Item $NewPowerShell -ItemType Directory -Force }

		New-Item -ItemType SymbolicLink -Name WindowsPowerShell -Path $PersonalDocuments -Value $NewWindowsPowerShell
		New-Item -ItemType SymbolicLink -Name PowerShell -Path $PersonalDocuments -Value $NewPowerShell

		Write-Host 'Move PS Profile to the shared location: ' -ForegroundColor Cyan -NoNewline
		Write-Host Completed -ForegroundColor green
	}
 else {
		Write-Warning "$($PersonalPSFolder) Already Exists, remove old profile fist"
	}
}


$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	Get-ChildItem -Path (Join-Path -Path $($env:HOMEDRIVE) -ChildPath '\Users') | Select-Object -ExpandProperty Name
}
Register-ArgumentCompleter -CommandName Set-SharedPSProfile -ParameterName OtherUserName -ScriptBlock $scriptBlock
