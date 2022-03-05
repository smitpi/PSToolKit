
<#PSScriptInfo

.VERSION 0.1.0

.GUID 783559da-d93b-4661-8c9b-1c73b6dca04b

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
Created [26/10/2021_22:33] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Update PowerShell ScriptFileInfo

#>

<#
.SYNOPSIS
Update PowerShell ScriptFileInfo

.DESCRIPTION
Update PowerShell ScriptFileInfo

.PARAMETER FullName
FullName of the script

.PARAMETER Author
Who wrote it

.PARAMETER Description
What it does

.PARAMETER tag
Tags for searching

.PARAMETER MinorUpdate
Minor version increase

.PARAMETER ChangesMade
What has changed.

.EXAMPLE
Update-PSScriptInfo -FullName .\PSToolKit\Public\Start-ClientPSProfile.ps1 -ChangesMade "blah"

#>
Function Update-PSScriptInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSScriptInfo')]
	[OutputType([System.Collections.Hashtable])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.ps1') })]
		[System.IO.FileInfo]$FullName,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $false)]
		[string]$Description,
		[Parameter(Mandatory = $false)]
		[string[]]$tag = 'ps',
		[Parameter(Mandatory = $false)]
		[switch]$MinorUpdate = $false,
		[Parameter(Mandatory = $true)]
		[string]$ChangesMade = (Read-Host 'Changes Made '))

	$Script = Get-Item -Path $FullName
	$ValidVerb = (Get-Verb -Verb ($Script.BaseName.Split('-'))[0])
	if ([bool]$ValidVerb -ne $true) { Write-Warning 'Script name is not valid, Needs to be in verb-noun format'; break }
	else {
		try {
			$currentinfo = $null
			$currentinfo = Test-ScriptFileInfo -Path $FullName -ErrorAction SilentlyContinue
		}
		catch {
			Write-Warning "$($Script.name): No Script Info found, using default values"

		}
		if ([bool]$currentinfo -eq $true) {
			[version]$ver = $currentinfo.Version
			if ($MinorUpdate) { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, ($ver.Minor + 1), $ver.Build }
			else { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, $ver.Minor, ($ver.Build + 1) }
			$guid = $currentinfo.Guid
			$ReleaseNotes = @()
			$ReleaseNotes = $currentinfo.ReleaseNotes
			$ReleaseNotes += 'Updated [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] ' + $ChangesMade
			if ($Description -like '') { $Description = $currentinfo.Description }
			if ($currentinfo.Author -notlike '') { $Author = $currentinfo.Author }
			[string[]]$tags += $tag
			[string[]]$tags += $currentinfo.Tags | Where-Object { $_ -ne '' } | Sort-Object -Unique
			if ($currentinfo.CompanyName -like '') { [string]$company = 'HTPCZA Tech' }
			else { [string]$company = $currentinfo.CompanyName }
		}
		else {
			[version]$Version = '0.1.0'
			$guid = New-Guid
			$ReleaseNotes = @()
			$ReleaseNotes += 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initial Script creation'
			[string]$Description = "Description for script $($script.name) needs an update"
			[string]$company = 'HTPCZA Tech'
		}


		$manifestProperties = @{
			Path         = $Script.FullName
			GUID         = $guid
			Version      = $Version
			Author       = $Author
			Description  = $Description
			CompanyName  = $company
			Tags         = $tags | Where-Object { $_ -ne '' } | Sort-Object -Unique
			ReleaseNotes = $ReleaseNotes
		}
		$manifestProperties
		Write-Color -Text 'Updating: ', "$($Script.Name)" -Color Cyan, green -LinesBefore 1 -NoNewLine
		Update-ScriptFileInfo @manifestProperties -Force
		Write-Color ' Done' -Color Yellow -LinesAfter 1
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] Processing file: $($Script.Name)"
	}

}
