
<#PSScriptInfo

.VERSION 0.1.0

.GUID f1b01792-3b70-49b0-bc9b-dadb891a093e

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
Created [30/05/2022_18:48] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Combines ps1 files into one psm1 file 

#> 


<#
.SYNOPSIS
Combines ps1 files into one psm1 file

.DESCRIPTION
Combines ps1 files into one psm1 file

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Build-MonolithicModule -Export HTML -ReportPath C:\temp

#>
Function Build-MonolithicModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psm1') })]
		[System.IO.FileInfo]$ModulePSM1,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'None',
		[switch]$CopyNestedModules = $false,
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$OutputFolder = 'C:\Temp'
	)
	

	#region module
	Write-Color '[Starting]', 'Module Import' -Color Yellow, DarkCyan
 try {
		$ModuleFunctionFile = Get-Item $ModulePSM1
		$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
		if ((Get-Module $module.Name).count -gt 1) {
			Remove-Module $module.Name -Force | Out-Null
			$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
		}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	#endregion

	#region Create output folder
	try {
		Write-Color '[Starting]', 'Creating Folder Structure' -Color Yellow, DarkCyan
		$Folder = (Join-Path $OutputFolder -ChildPath $module.name) 
		if (Test-Path $Folder) {
			Rename-Item $Folder -NewName "$($module.name)-$(Get-Date -Format yyyy.MM.dd_HH.mm)" -Force
			$ModuleOutput = New-Item $Folder -ItemType Directory -Force
		} else {$ModuleOutput = New-Item $Folder -ItemType Directory -Force}
	} catch {throw 'Unable rename old folders.'}
	#endregion
	
	#region copy files	
	Write-Color '[Starting]', 'Creating new module files' -Color Yellow, DarkCyan
	try {
		
    $OldManifest = Get-Item ($module.Path.Replace('.psm1', '.psd1')) -ErrorAction Stop
    $moduleManifest = Test-ModuleManifest -Path $OldManifest.FullName
	Copy-Item -Path $OldManifest -Destination $ModuleOutput.fullname -Force -ErrorAction Stop

	$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))
	$ModulePublicFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Private') | Get-Item

	$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
	if ($null -notlike $PrivateFiles) {
		Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
	}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

	#endregion

	#region create psm1 file
	$public = @(Get-ChildItem -Path "$($ModulePublicFunctions.FullName)\*.ps1" -Recurse -ErrorAction Stop)
	$private = @(Get-ChildItem -Path "$($ModulePrivateFunctions.FullName)\*.ps1" -ErrorAction Stop)
	$file = [System.Collections.Generic.List[string]]::new()
	$file.add('#region Private Functions')
	foreach ($privateitem in $private) {
		$file.add("#region $($privateitem.name)")
		$file.Add('########### Private Function ###############')
		$file.Add("# source: $($privateitem.name)")
		$file.Add("# Module: $($module.Name)")
		$file.Add('############################################')
		Write-Color '[Processing]: ', $($privateitem.name) -Color Cyan, Yellow
		Get-Content $privateitem.fullname | ForEach-Object { $file.add($_) }
		$file.add('#endregion')
	}
	$file.add('#endregion')
	$file.Add(' ')
	$file.Add(' ')
	$file.add('#region Public Functions')
	foreach ($publicitem in $public) {
		$file.add("#region $($publicitem.name)")
		$file.Add('############################################')
		$file.Add("# source: $($publicitem.name)")
		$file.Add("# Module: $($module.Name)")
		$file.Add("# version: $($moduleManifest.version)")
		$file.Add("# Author: $($moduleManifest.author)")
		$file.Add("# Company: $($moduleManifest.CompanyName)")
		$file.Add('#############################################')
		$file.Add(' ')
		Write-Color '[Processing]: ', $($publicitem.name) -Color Cyan, Yellow

		[int]$StartIndex = (Select-String -InputObject $publicitem -Pattern '.SYNOPSIS*').LineNumber[0] - 2
		[int]$EndIndex = (Get-Content $publicitem.FullName).length
		Get-Content -Path $publicitem.FullName | Select-Object -Index ($StartIndex..$EndIndex) | ForEach-Object { $file.Add($_) }
		$file.Add(' ')
		$file.Add("Export-ModuleMember -Function $($publicitem.BaseName)")
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#endregion')
	$file.Add(' ')
	$file | Set-Content -Path $rootModule -Encoding utf8 -Force
	#endregion

	if ($CopyNestedModules) {
		Write-Color '[Starting]', 'Copying nested modules' -Color Yellow, DarkCyan

		if (-not(Test-Path $(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules'))) {
			New-Item -Path "$(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules')" -ItemType Directory -Force | Out-Null
		}
		foreach ($required in $ModuleManifest.RequiredModules) {
			$latestmod = $null
			Import-Module $required -Force
			$latestmod = Get-Module $required | Sort-Object -Property Version | Select-Object -First 1
			if (-not($latestmod)) { $latestmod = Get-Module $required -ListAvailable | Sort-Object -Property Version | Select-Object -First 1}
			
			Write-Color "`t[Copying]", "$($required.Name)" -Color Yellow, DarkCyan
			Copy-Item -Path (Get-Item $latestmod.path).Directory -Destination ([IO.Path]::Combine($ModuleOutput, 'NestedModules', $($required.Name),$latestmod.Version)) -Recurse
		}
		New-Item -Path (Join-Path -Path $ModuleOutput -ChildPath '\NestedModules\Import-NestedModules.ps1') -ItemType File -Value "Get-ChildItem `$PSScriptRoot\*.psm1 -recurse | Import-Module" -Force | Out-Null
		$nestedmodules = @()
		$nestedmodules = Get-ChildItem -Path "$ModuleOutput\NestedModules" -Directory | ForEach-Object {"NestedModules\$($_.name)"}
		$rootManifest = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))

		$manifest = Import-PowerShellDataFile $ModuleManifest.Path
		$manifest.Remove('CmdletsToExport')
		#$manifest.Remove('RequiredModules')
		$manifest.Remove('AliasesToExport')
		$manifest.Remove('PrivateData')
		$manifest.Add('ScriptsToProcess', 'NestedModules\Import-NestedModules.ps1')
		if ($ModuleManifest.Tags) { $manifest.Add('Tags', $ModuleManifest.Tags)}
		if ($ModuleManifest.LicenseUri) { $manifest.Add('LicenseUri', $ModuleManifest.LicenseUri)}
		if ($ModuleManifest.ProjectUri) { $manifest.Add('ProjectUri', $ModuleManifest.ProjectUri)}
		if ($ModuleManifest.IconUri) { $manifest.Add('IconUri', $ModuleManifest.IconUri)}
		if ($ModuleManifest.ReleaseNotes) { $manifest.Add('ReleaseNotes', $ModuleManifest.ReleaseNotes)}

		if (Test-Path $rootManifest) {Remove-Item $rootManifest -Force}
		New-ModuleManifest -Path $rootManifest.FullName -NestedModules $nestedmodules @manifest
	}

	if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
		$ModuleManifestFileTMP = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))
		[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName).version

		if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
		if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

		$manifestProperties = @{
			Path              = $ModuleManifestFileTMP.FullName
			ModuleVersion     = $ModuleversionTMP
			FunctionsToExport = (Get-Command -Module $module.Name | Select-Object name).name | Sort-Object
		}
		try {
			Update-ModuleManifest @manifestProperties
		} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}
	
    try {
		$rootManifest = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))
		$FileContent = Get-Content $rootManifest
		$DateLine = Select-String -InputObject $rootManifest -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $rootManifest -Force
	} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)"}

}#end Function