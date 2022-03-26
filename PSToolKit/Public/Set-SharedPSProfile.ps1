
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
Redirects PowerShell profile to network share.

.DESCRIPTION
Redirects PowerShell profile to network share.

.PARAMETER PathToSharedProfile
The new path.

.EXAMPLE
Set-SharedPSProfile PathToSharedProfile "\\nas01\profile"

#>
function Set-SharedPSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-SharedPSProfile')]
	param (
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (Test-Path $_) { $true }
                else {throw "Not a valid Location"}
			})]
		[System.IO.DirectoryInfo]$PathToSharedProfile
	)

try{
	$PersonalDocuments = [Environment]::GetFolderPath('MyDocuments')
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
} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

	if (-not(Test-Path $WindowsPowerShell) -and -not(Test-Path $PowerShell)) {
	    $NewWindowsPowerShell = [IO.Path]::Combine($PathToSharedProfile, 'WindowsPowerShell')
	    $NewPowerShell = [IO.Path]::Combine($PathToSharedProfile, 'PowerShell')

		New-Item -ItemType SymbolicLink -Name WindowsPowerShell -Path $PersonalDocuments -Value $NewWindowsPowerShell
		New-Item -ItemType SymbolicLink -Name PowerShell -Path $PersonalDocuments -Value $NewPowerShell

		Write-Host 'Move PS Profile to the shared location: ' -ForegroundColor Cyan -NoNewline
		Write-Host Completed -ForegroundColor green
	}
 else {
		Write-Warning "$($PersonalPSFolder) Already Exists, remove old profile fist"
	}
}

