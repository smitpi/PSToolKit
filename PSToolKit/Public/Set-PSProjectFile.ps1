
<#PSScriptInfo

.VERSION 0.1.0

.GUID 239df09a-30cf-4b5a-9e42-e2d2ce19324a

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
Created [11/01/2022_18:41] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Creates and modify needed files for a PS project from existing module files

#>


<#
.SYNOPSIS
Creates and modify needed files for a PS project from existing module files.

.DESCRIPTION
Creates and modify needed files for a PS project from existing module files.

.PARAMETER ModuleName
Path to module .psm1 file.

.PARAMETER CopyNestedModules
Will copy the required modules to the folder.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER mkdocs
Create and test the mkdocs site

.PARAMETER GitPush
Run Git Push when done.

.EXAMPLE
Set-PSProjectFiles -ModuleName blah -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/CTXOnPrem/Convert-PSModule')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[System.IO.FileInfo]$ModuleName,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'CombineOnly',
		[ValidateSet('serve', 'deploy')]
		[string]$mkdocs = 'None',
		[switch]$CopyNestedModules = $false,
		[Switch]$GitPush = $false
	)
	
	#region module
	Write-Color '[Starting]', 'Module Import' -Color Yellow, DarkCyan
	try {
		$modulefile = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath ".\PowerShell\ProdModules\$($ModuleName)\$($ModuleName)\$($ModuleName).psm1") | Get-Item -ErrorAction Stop
		Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
		Import-Module $modulefile -Force -ErrorAction Stop
		$module = Get-Module $ModuleName -ErrorAction Stop
	} catch {Write-Error "Error: Importing Module `nMessage:$($_.Exception.message)"; exit}

	if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
		try {
			$ModuleManifestFileTMP = Get-Item ($module.Path).Replace('.psm1', '.psd1')
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName -ErrorAction Stop).version 

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				FunctionsToExport = (Get-Command -Module $module.Name | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties -ErrorAction Stop
		} catch {Write-Error "Error: Updateing Version `nMessage:$($_.Exception.message)"; exit}
	} 

	try {
		$ModuleManifestFile = Get-Item ($module.Path).Replace('.psm1', '.psd1')
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object * -ErrorAction Stop
		$FileContent = Get-Content $ModuleManifestFile -ErrorAction Stop
		$DateLine = Select-String -InputObject $ModuleManifestFile -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $ModuleManifestFile -Force -ErrorAction Stop
	} catch {Write-Error "Error: Update versions `nMessage:$($_.Exception.message)"; exit}
		
	#endregion

	#region Create Folders
	Write-Color '[Starting]', 'Creating Folder Structure' -Color Yellow, DarkCyan
	$ModuleBase = ((Get-Item $module.ModuleBase).Parent).fullname
	$ModuleOutput = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
	$Moduledocs = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
	$ModuleExternalHelp = [IO.Path]::Combine($ModuleOutput, 'en-US')
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$ModulePublicFunctions = [IO.Path]::Combine($module.ModuleBase, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($module.ModuleBase, 'Private') | Get-Item
	$ModuleMkdocss = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocss.yml')
	$ModuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	[System.Collections.ArrayList]$Issues = @()

	try {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop; Start-Sleep 5 }
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
		if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssuesExcel) {Remove-Item $ModuleIssuesExcel -Force -ErrorAction Stop }	
	} catch {throw 'Unable to delete old folders.' ; exit}

	try {
		$ModuleOutput = New-Item $ModuleOutput -ItemType Directory -Force | Get-Item -ErrorAction Stop
		$Moduledocs = New-Item $Moduledocs -ItemType Directory -Force | Get-Item -ErrorAction Stop
		$ModuleExternalHelp = New-Item $ModuleExternalHelp -ItemType Directory -Force | Get-Item -ErrorAction Stop
	} catch {Write-Error "Error: Creating folders `nMessage:$($_.Exception.message)"; exit}

	#endregion

	#region platyps
	try {
		Write-Color '[Starting]', 'Creating External help files' -Color Yellow, DarkCyan
		$markdownParams = @{
			Module         = $module.Name
			OutputFolder   = $Moduledocs.FullName
			WithModulePage = $false
			Locale         = 'en-US'
			HelpVersion    = $ModuleManifest.Version.ToString()
		}
		New-MarkdownHelp @markdownParams
	} catch {Write-Error "Error: MarkdownHelp `nMessage:$($_.Exception.message)"; exit}

	try {
		Compare-Object -ReferenceObject (Get-ChildItem $ModulePublicFunctions).BaseName -DifferenceObject (Get-ChildItem $Moduledocs).BaseName | Where-Object { $_.SideIndicator -like '<=' } | ForEach-Object {
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'External Help'
					File     = $_.InputObject
					details  = 'Did not create the .md file'
				})
		}

		$MissingDocumentation = Select-String -Path (Join-Path $Moduledocs.FullName -ChildPath '\*.md') -Pattern '({{.*}})'
		$group = $MissingDocumentation | Group-Object -Property Line
		foreach ($gr in $group) {
			foreach ($item in $gr.Group) {
				$object = Get-Item $item.Path
				$mod = Get-Content -Path $object.FullName
				Write-Color "$($object.name):", "$($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])" -Color Cyan, Yellow
				[void]$Issues.Add([PSCustomObject]@{
						Catagory = 'External Help'
						File     = $object.name
						details  = "$($object.name) - $($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])"
					})
			}
		}
	} catch {Write-Error "Error: Docs check `nMessage:$($_.Exception.message)"; exit}

	try {
		New-ExternalHelp -Path $Moduledocs.FullName -OutputPath $ModuleExternalHelp.FullName -Force -ShowProgress

		$aboutfile = [System.Collections.Generic.List[string]]::new()
		$aboutfile.Add('')
		$aboutfile.Add("$($module.Name)")
		$aboutfile.Add("`t about_$($module.Name)")
		$aboutfile.Add(' ')
		$aboutfile.Add('SHORT DESCRIPTION')
		$aboutfile.Add("`t $(($ModuleManifest.Description | Out-String))")
		$aboutfile.Add(' ')
		$aboutfile.Add('NOTES')
		$aboutfile.Add('Functions in this module:')
	(Get-Command -Module $module).Name | ForEach-Object { ($aboutfile.Add("`t $_ -- $((Get-Help $_).synopsis)")) }
		$aboutfile.Add(' ')
		$aboutfile.Add('SEE ALSO')
		$aboutfile.Add("`t $(($ModuleManifest.ProjectUri.AbsoluteUri | Out-String))")
		$aboutfile.Add("`t $(($ModuleManifest.HelpInfoUri | Out-String))")
		$aboutfile | Set-Content -Path (Join-Path $ModuleExternalHelp.FullName -ChildPath "\about_$($module.Name).help.txt") -Force

		if (!(Test-Path $ModulesInstuctions)) {
			$instructions = [System.Collections.Generic.List[string]]::new()
			$instructions.add("# $($module.Name)")
			$instructions.Add(' ')
			$instructions.add('## Description')
			$instructions.add("$(($ModuleManifest.Description | Out-String).Trim())")
			$instructions.Add(' ')
			$instructions.Add('## Getting Started')
			$instructions.Add("- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/$($module.Name))")
			$instructions.Add('```')
			$instructions.Add("Install-Module -Name $($module.Name) -Verbose")
			$instructions.Add('```')
			$instructions.Add("- or from GitHub [GitHub Repo](https://github.com/smitpi/$($module.Name))")
			$instructions.Add('```')
			$instructions.Add("git clone https://github.com/smitpi/$($module.Name) (Join-Path (get-item (Join-Path (Get-Item `$profile).Directory 'Modules')).FullName -ChildPath $($Module.Name))")
			$instructions.Add('```')
			$instructions.Add('- Then import the module into your session')
			$instructions.Add('```')
			$instructions.Add("Import-Module $($module.Name) -Verbose -Force")
			$instructions.Add('```')
			$instructions.Add('- or run these commands for more help and details.')
			$instructions.Add('```')
			$instructions.Add("Get-Command -Module $($module.Name)")
			$instructions.Add("Get-Help about_$($module.Name)")
			$instructions.Add('```')
			$instructions.Add("Documentation can be found at: [Github_Pages](https://smitpi.github.io/$($module.Name))")
			$instructions | Set-Content -Path $ModulesInstuctions
		}

		$readme = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $readme.add($_) }
		$readme.add(' ')
		$readme.add('## Functions')
	(Get-Command -Module $module).Name | ForEach-Object { $readme.add("- [$_](https://smitpi.github.io/$($module.Name)/#$_) -- " + (Get-Help $_).SYNOPSIS) }
		$readme | Set-Content -Path $ModuleReadme

		$mkdocssFunc = [System.Collections.Generic.List[string]]::new()
		$mkdocssFunc.add("site_name: `'$($module.Name)`'")
		$mkdocssFunc.add("site_description: `'Documentation for PowerShell Module: $($module.Name)`'")
		$mkdocssFunc.add("site_author: `'$(($ModuleManifest.Author | Out-String).Trim())`'")
		$mkdocssFunc.add("site_url: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocssFunc.add(' ')
		$mkdocssFunc.add("repo_url: `'https://github.com/smitpi/$($module.Name)`'")
		$mkdocssFunc.add("repo_name:  `'smitpi/$($module.Name)`'")
		$mkdocssFunc.add(' ')
		$mkdocssFunc.add("copyright: `'$(($ModuleManifest.Copyright | Out-String).Trim())`'")
		$mkdocssFunc.add(' ')
		$mkdocssFunc.add('extra:')
		$mkdocssFunc.add('  manifest: manifest.webmanifest')
		$mkdocssFunc.add('  social:')
		$mkdocssFunc.add('    - icon: fontawesome/brands/github-square')
		$mkdocssFunc.add("      link: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocssFunc.add(' ')
		$mkdocssFunc.add('markdown_extensions:')
		$mkdocssFunc.add('  - pymdownx.keys')
		$mkdocssFunc.add('  - pymdownx.snippets')
		$mkdocssFunc.add('  - pymdownx.superfences')
		$mkdocssFunc.add(' ')
		$mkdocssFunc.add('theme:')
		$mkdocssFunc.add('  name: material')
		$mkdocssFunc.add('  features:')
		$mkdocssFunc.add('    - navigation.instant')
		$mkdocssFunc.add('  language: en')
		$mkdocssFunc.add("  favicon: `'`'")
		$mkdocssFunc.add("  logo: `'`'")
		$mkdocssFunc.add('  palette:')
		$mkdocssFunc.add('    - media: "(prefers-color-scheme: light)"')
		$mkdocssFunc.add('      primary: blue grey')
		$mkdocssFunc.add('      accent: indigo')
		$mkdocssFunc.add('      scheme: default')
		$mkdocssFunc.add('      toggle:')
		$mkdocssFunc.add('        icon: material/toggle-switch-off-outline')
		$mkdocssFunc.add('        name: Switch to dark mode')
		$mkdocssFunc.add('    - media: "(prefers-color-scheme: dark)"')
		$mkdocssFunc.add('      primary: blue grey')
		$mkdocssFunc.add('      accent: indigo')
		$mkdocssFunc.add('      scheme: slate')
		$mkdocssFunc.add('      toggle:')
		$mkdocssFunc.add('        icon: material/toggle-switch')
		$mkdocssFunc.add('        name: Switch to light mode')
		$mkdocssFunc | Set-Content -Path $ModuleMkdocss -Force

		$indexFile = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
		$indexFile.add(' ')
		$indexFile.add('## Functions')
	(Get-Command -Module $module).Name | ForEach-Object { $indexFile.add("- [$_](https://smitpi.github.io/$($module.Name)/#$_) -- " + (Get-Help $_).SYNOPSIS) }
		$indexFile | Set-Content -Path $ModuleIndex -Force
	} catch {Write-Error "Error: Other Files `nMessage:$($_.Exception.message)"; exit}
	
	#endregion
	
	#region Combine files
	Write-Color '[Starting]', 'Creating new module files' -Color Yellow, DarkCyan

	$ModuleOutput = Get-Item $ModuleOutput
	$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))

	Copy-Item -Path $ModuleManifestFile.FullName -Destination $ModuleOutput.fullname -Force
	$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
	if ($null -notlike $PrivateFiles) {
		Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
	}

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

	$versionfile = [System.Collections.Generic.List[PSObject]]::New()
	$versionfile.add([pscustomobject]@{
			version = $($moduleManifest.version).ToString()
			Author  = $($moduleManifest.author)
			Date    = (Get-Date -Format u)
		})
	$versionfile | ConvertTo-Json | Set-Content (Join-Path $ModuleBase -ChildPath 'Version.json') -Force

	$newfunction = ((Select-String -Path $rootModule -Pattern '^# source:').Line).Replace('# source:', '').Replace('.ps1', '').Trim()
	$ModCommands = Get-Command -Module $module | ForEach-Object { $_.name }

	Compare-Object -ReferenceObject $ModCommands -DifferenceObject $newfunction | ForEach-Object {
		[void]$Issues.Add([PSCustomObject]@{
				Catagory = 'Not Copied'
				File     = $_.InputObject
				details  = $_.SideIndicator
			})
	}
	#endregion
	
	#region NestedModules
	if ($CopyNestedModules) {
		Write-Color '[Starting]', 'Copying nested modules' -Color Yellow, DarkCyan

		if (-not(Test-Path $(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules'))) {
			New-Item -Path "$(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules')" -ItemType Directory -Force | Out-Null
		}
		foreach ($required in $ModuleManifest.RequiredModules) {
			$latestmod = $null
			Import-Module $required -Force -Verbose
			$latestmod = Get-Module $required | Sort-Object -Property Version | Select-Object -First 1
			if (-not($latestmod)) { $latestmod = Get-Module $required -ListAvailable | Sort-Object -Property Version | Select-Object -First 1}
			
			Write-Color "`t[Copying]", "$($required.Name)" -Color Yellow, DarkCyan
			Copy-Item -Path (Get-Item $latestmod.Path).Directory -Destination ([IO.Path]::Combine($ModuleOutput, 'NestedModules', $($required.Name), $($latestmod.Version))) -Recurse
		}
		$nestedmodules = @()
		$nestedmodules = (Get-ChildItem -Path "$ModuleOutput\NestedModules\*.psm1" -Recurse).FullName | ForEach-Object {$_.Replace("$($ModuleOutput)\", '')}
		$rootManifest = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))

		$manifest = Import-PowerShellDataFile $ModuleManifest.Path
		$manifest.Remove('CmdletsToExport')
		$manifest.Remove('AliasesToExport')
		$manifest.Remove('PrivateData')
		if ($ModuleManifest.Tags) { $manifest.Add('Tags', $ModuleManifest.Tags)}
		if ($ModuleManifest.LicenseUri) { $manifest.Add('LicenseUri', $ModuleManifest.LicenseUri)}
		if ($ModuleManifest.ProjectUri) { $manifest.Add('ProjectUri', $ModuleManifest.ProjectUri)}
		if ($ModuleManifest.IconUri) { $manifest.Add('IconUri', $ModuleManifest.IconUri)}
		if ($ModuleManifest.ReleaseNotes) { $manifest.Add('ReleaseNotes', $ModuleManifest.ReleaseNotes)}

		if (Test-Path $rootManifest) {Remove-Item $rootManifest -Force}
		New-ModuleManifest -Path $rootManifest.FullName -NestedModules $nestedmodules @manifest

		$FileContent = Get-Content $rootManifest
		$DateLine = Select-String -InputObject $rootManifest -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $rootManifest -Force
	}
	#endregion

	#region report issues
	if ($null -notlike $Issues) { 
		$issues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName Other -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow 
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add('<style>')
		$fragments.Add('table {')
		$fragments.Add('    border-collapse: collapse;')
		$fragments.Add('}')
		$fragments.Add('table, th, td {')
		$fragments.Add('   border: 1px solid black;')
		$fragments.Add('}')
		$fragments.Add('blockquote {')
		$fragments.Add('    border-left: solid blue;')
		$fragments.Add('	padding-left: 10px;')
		$fragments.Add('}')
		$fragments.Add('@import url(http://fonts.googleapis.com/css?family=Open+Sans:300italic,300);')
		$fragments.Add('body {')
		$fragments.Add('  color: #444;')
		$fragments.Add("  font-family: 'Open Sans', Helvetica, sans-serif;")
		$fragments.Add('  font-weight: 300;')
		$fragments.Add('}')
		$fragments.Add('</style>')
		$fragments.Add((New-MDHeader "$($module.Name): Issues"))
		$Fragments.Add("---`n")
		$fragments.Add((New-MDTable -Object $Issues))
		$Fragments.Add("---`n")
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File -FilePath $ModuleIssues -Encoding utf8 -Force
	}
	#endregion
	#region mkdocss
	Write-Color '[Starting]', 'mkdocss' -Color Yellow, DarkCyan
	if ($mkdocs -like 'serve') {
		Set-Location (Split-Path -Path $Moduledocs -Parent)
		mkdocs.exe serve 2>&1 | Write-Host -ForegroundColor Yellow
		Start-Sleep 5
		Start-Process "http://127.0.0.1:8000/$($module.Name)/"
	}
	if ($mkdocs -like 'deploy') {
		Set-Location (Split-Path -Path $Moduledocs -Parent)
		mkdocs.exe gh-deploy 2>&1 | Write-Host -ForegroundColor Yellow 
	}
	#endregion

	#region Git push
	if ($GitPush) {
		if (Get-Command git.exe -ErrorAction SilentlyContinue) {
			Write-Color '[Starting]', 'Git Push' -Color Yellow, DarkCyan
			Set-Location $ModuleBase 
			Start-Sleep 5
			git add --all 2>&1 | Write-Host -ForegroundColor Yellow
			git commit --all -m "To Version: $($moduleManifest.version.tostring())" 2>&1 | Write-Host -ForegroundColor Yellow
			git push 2>&1 | Write-Host -ForegroundColor Yellow
		} else {Write-Warning 'Git is not installed'}
	}
	#endregion

}#end Function
 
$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	Get-ChildItem -Path 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\*' | Select-Object -ExpandProperty Name
}
Register-ArgumentCompleter -CommandName Set-PSProjectFile -ParameterName ModuleName -ScriptBlock $scriptBlock
