
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
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (-Not (Test-Path $_) ) { stop }
				$true
			})]
		[string[]]$PathToSharedProfile
	)

	$PersonalDocuments = [Environment]::GetFolderPath('MyDocuments')
	$PersonalPSFolder = $PersonalDocuments + '\WindowsPowerShell'
	if ((Test-Path $PersonalPSFolder) -eq $true ) {
		Write-Warning 'Folder exists, renamig now...'
		Rename-Item -Path $PersonalPSFolder -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose
	}

	if ((Test-Path $PersonalPSFolder) -eq $false ) {
		New-Item -ItemType SymbolicLink -Name WindowsPowerShell -Path $PersonalDocuments -Value (Get-Item $PathToSharedProfile).FullName

		Write-Host 'Move PS Profile to the shared location: ' -ForegroundColor Cyan -NoNewline
		Write-Host Completed -ForegroundColor green
	}
 else {
		Write-Warning "$($PersonalPSFolder) Already Exists, remove old profile fist"
	}
}

