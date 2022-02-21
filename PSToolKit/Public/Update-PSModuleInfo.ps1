
<#PSScriptInfo

.VERSION 0.1.0

.GUID 986271d5-b9a4-4982-b4ec-65cce5d64821

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
Created [27/10/2021_04:26] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Update PowerShell module manifest file

#>

<#
.SYNOPSIS
Update PowerShell module manifest file

.DESCRIPTION
Update PowerShell module manifest file

.PARAMETER ModuleManifestPath
Path to .psd1 file

.PARAMETER Author
Who wrote the moduke

.PARAMETER Description
What it does

.PARAMETER tag
Tags for searching

.PARAMETER MinorUpdate
Major update increase

.PARAMETER ChangesMade
What has changed in the module.

.EXAMPLE
Update-PSModuleInfo -ModuleManifestPath .\PSLauncher.psd1 -ChangesMade 'Added button to add more panels'

#>
Function Update-PSModuleInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSModuleInfo')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psd1') })]
		[System.IO.FileInfo]$ModuleManifestPath,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $false)]
		[string]$Description,
		[Parameter(Mandatory = $false)]
		[string[]]$tag,
		[Parameter(Mandatory = $false)]
		[switch]$MinorUpdate = $false,
		[Parameter(Mandatory = $false)]
		[string]$ChangesMade = 'Module Info was updated')


	if ((Test-Path -Path $ModuleManifestPath) -eq $true ) {
		$Module = Get-Item -Path $ModuleManifestPath | Select-Object *
		try {
			$currentinfo = Test-ModuleManifest -Path $Module.fullname
			$currentinfo | Select-Object Path, RootModule, ModuleVersion, Author, Description, CompanyName, Tags, ReleaseNotes, GUID, FunctionsToExport | Format-List
		}
		catch { Write-Host 'No module Info found, using default values' -ForegroundColor Cyan }
	}
	if ([bool]$currentinfo -eq $true) {
		[version]$ver = $currentinfo.Version
		if ($MinorUpdate) { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, ($ver.Minor + 1), $ver.Build }
		else { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, $ver.Minor, ($ver.Build + 1) }
		$guid = $currentinfo.Guid
		$ReleaseNotes = 'Updated [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] ' + $ChangesMade
		if ($Description -like '') { $Description = $currentinfo.Description }
		$company = $currentinfo.CompanyName
		if ($Author -like '') { $Author = $currentinfo.Author }
		[string[]]$tags += $tag
		$tags += $currentinfo.Tags | Where-Object { $_ -ne '' } | Sort-Object -Unique

	}
	$manifestProperties = @{
		Path              = $Module.FullName
		RootModule        = $Module.Name.Replace('.psd1', '.psm1')
		ModuleVersion     = $Version
		Author            = $Author
		Description       = $Description
		CompanyName       = $company
		Tags              = [string[]]$($Tags) | Where-Object { $_ -ne '' } | Sort-Object -Unique
		ReleaseNotes      = @($ReleaseNotes)
		GUID              = $guid
		FunctionsToExport = @((Get-ChildItem -Path ($Module.DirectoryName + '\Public') -Include *.ps1 -Recurse | Select-Object basename).basename | Sort-Object)
	}

	$manifestProperties
	Update-ModuleManifest @manifestProperties
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] Processing file: $($Script.FullName)"

	#else { Write-Host "Path to script is invalid"; break }


} #end Function
