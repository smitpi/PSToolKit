
<#PSScriptInfo

.VERSION 0.1.0

.GUID 555d3710-ae10-4a0c-b647-5b049f334056

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
Creates a new PowerShell module.

#>

<#
.SYNOPSIS
Creates a new PowerShell module.

.DESCRIPTION
Creates a new PowerShell module.

.PARAMETER ModulePath
Path to where it will be saved.

.PARAMETER ModuleName
Name of module

.PARAMETER Author
Who wrote it

.PARAMETER Description
What it does

.PARAMETER Tag
Tags for reaches.

.EXAMPLE
New-PSModule -ModulePath C:\Temp\ -ModuleName blah -Description 'blah' -Tag ps

#>
function New-PSModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSModule')]
	PARAM(
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$ModulePath = $pwd,
		[Parameter(Mandatory = $true)]
		[string]$ModuleName,
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $true)]
		[string]$Description = (Read-Host Description),
		[Parameter(Mandatory = $true)]
		[string[]]$Tag = (Read-Host Tag)
	)

	$ModuleFullPath = Join-Path (Get-Item $ModulePath).FullName -ChildPath $ModuleName
	if ((Test-Path $ModuleFullPath) -eq $true) { Write-Warning 'Already exits'; break }

	if ((Test-Path -Path $ModuleFullPath) -eq $false) {
		New-Item -Path $ModuleFullPath -ItemType Directory
		New-Item -Path $ModuleFullPath\Private -ItemType Directory
		New-Item -Path $ModuleFullPath\Public -ItemType Directory
		New-Item -Path $ModuleFullPath\en-US -ItemType Directory
		New-Item -Path $ModuleFullPath\docs -ItemType Directory
		#Create the module and related files
		$ModuleStartup = @('
Set-StrictMode -Version Latest
# Get public and private function definition files.

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files.
foreach ($import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
		. $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

## Export all of the public functions making them available to the user
foreach ($file in $Public) {
    Export-ModuleMember -Function $file.BaseName
}
')

		$ModuleStartup | Out-File "$ModuleFullPath\$ModuleName.psm1" -Force
		New-Item "$ModuleFullPath\$ModuleName.Format.ps1xml" -ItemType File
		New-ModuleManifest -Path "$ModuleFullPath\$ModuleName.psd1" -RootModule "$ModuleName.psm1" -Guid (New-Guid) -Description $Description -Author $Author -ModuleVersion '0.1.0' -CompanyName 'HTPCZA Tech'-Tags $tag

	}
}

