
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

.PARAMETER ModulePSM1
Path to module .psm1 file.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER mkdocs
Create and test the mkdocs site

.EXAMPLE
Set-PSProjectFiles -ModulePSM1 c:\temp\blah.psm1 -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFiles {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psm1') })]
		[System.IO.FileInfo]$ModulePSM1,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'None',
		[ValidateSet('serve', 'gh-deploy')]
		[string]$mkdocs = 'None'
	)

	#region module
	Write-Color '[Starting]', 'Module Import' -Color Yellow, DarkCyan
 try {

		if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
			$ModuleManifestFileTMP = Get-Item ((Get-Item $ModulePSM1).FullName.Replace('psm1', 'psd1'))
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName).version

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

			$ModuleFunctionFile = Get-Item $ModulePSM1
			$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			if ((Get-Module $module.Name).count -gt 1) {
				Remove-Module $module.Name -Force | Out-Null
				$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			}
			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				FunctionsToExport = (Get-Command -Module $module.Name | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties
		} else {
			$ModuleFunctionFile = Get-Item $ModulePSM1
			$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			if ((Get-Module $module.Name).count -gt 1) {
				Remove-Module $module.Name -Force | Out-Null
				$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			}
		}
		$ModuleManifestFile = Get-Item ($ModuleFunctionFile.FullName.Replace('psm1', 'psd1'))
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object *
	} catch { Write-Error 'Unable to load module.'; exit }

	Write-Color '[Starting]', 'Creating Folder Structure' -Color Yellow, DarkCyan
	$ModuleBase = Get-Item ((Get-Item $ModuleFunctionFile.Directory).Parent).FullName
	$ModuleOutput = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
	$Moduledocs = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
	$ModuleExternalHelp = [IO.Path]::Combine($ModuleOutput, 'en-US')
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$ModulePublicFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Private') | Get-Item
	$ModuleMkdocs = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocs.yml')
	$ModfuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	[System.Collections.ArrayList]$Issues = @()
	[System.Collections.ArrayList]$ScriptAnalyzerIssues = @()
	#endregion

	function exthelp {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force }
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force }
		if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force }
		if (Test-Path $ModuleIssuesExcel) { Remove-Item $ModuleIssuesExcel -Force }
		if (Test-Path $ModuleMkdocs) { Remove-Item $ModuleMkdocs -Force }

		$ModuleOutput = New-Item $ModuleOutput -ItemType Directory -Force | Get-Item
		$Moduledocs = New-Item $Moduledocs -ItemType Directory -Force | Get-Item
		$ModuleExternalHelp = New-Item $ModuleExternalHelp -ItemType Directory -Force | Get-Item


		#region platyps
		Write-Color '[Starting]', 'Creating External help files' -Color Yellow, DarkCyan
		$markdownParams = @{
			Module         = $module.Name
			OutputFolder   = $Moduledocs.FullName
			WithModulePage = $false
			Locale         = 'en-US'
			HelpVersion    = $ModuleManifest.Version.ToString()
		}
		New-MarkdownHelp @markdownParams

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

		$mkdocsFunc = [System.Collections.Generic.List[string]]::new()
		$mkdocsFunc.add("site_name: `'$($module.Name)`'")
		$mkdocsFunc.add("site_description: `'Documentation for PowerShell Module: $($module.Name)`'")
		$mkdocsFunc.add("site_author: `'$(($ModuleManifest.Author | Out-String).Trim())`'")
		$mkdocsFunc.add("site_url: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add("repo_url: `'https://github.com/smitpi/$($module.Name)`'")
		$mkdocsFunc.add("repo_name:  `'smitpi/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add("copyright: `'$(($ModuleManifest.Copyright | Out-String).Trim())`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('extra:')
		$mkdocsFunc.add('  manifest: manifest.webmanifest')
		$mkdocsFunc.add('  social:')
		$mkdocsFunc.add('    - icon: fontawesome/brands/github-square')
		$mkdocsFunc.add("      link: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('markdown_extensions:')
		$mkdocsFunc.add('  - pymdownx.keys')
		$mkdocsFunc.add('  - pymdownx.snippets')
		$mkdocsFunc.add('  - pymdownx.superfences')
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('theme:')
		$mkdocsFunc.add('  name: material')
		$mkdocsFunc.add('  features:')
		$mkdocsFunc.add('    - navigation.instant')
		$mkdocsFunc.add('  language: en')
		$mkdocsFunc.add("  favicon: `'`'")
		$mkdocsFunc.add("  logo: `'`'")
		$mkdocsFunc.add('  palette:')
		$mkdocsFunc.add('    - media: "(prefers-color-scheme: light)"')
		$mkdocsFunc.add('      primary: blue grey')
		$mkdocsFunc.add('      accent: indigo')
		$mkdocsFunc.add('      scheme: default')
		$mkdocsFunc.add('      toggle:')
		$mkdocsFunc.add('        icon: material/toggle-switch-off-outline')
		$mkdocsFunc.add('        name: Switch to dark mode')
		$mkdocsFunc.add('    - media: "(prefers-color-scheme: dark)"')
		$mkdocsFunc.add('      primary: blue grey')
		$mkdocsFunc.add('      accent: indigo')
		$mkdocsFunc.add('      scheme: slate')
		$mkdocsFunc.add('      toggle:')
		$mkdocsFunc.add('        icon: material/toggle-switch')
		$mkdocsFunc.add('        name: Switch to light mode')
		$mkdocsFunc | Set-Content -Path $ModuleMkdocs -Force

		$indexFile = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
		$indexFile.add(' ')
		$indexFile.add('## Functions')
	(Get-Command -Module $module).Name | ForEach-Object { $indexFile.add("- [$_](https://smitpi.github.io/$($module.Name)/#$_) -- " + (Get-Help $_).SYNOPSIS) }
		$indexFile | Set-Content -Path $ModfuleIndex -Force
		#endregion
	}
	function combine {
		#region copy files
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
			$file.Add('########### Private Function ###############')
			$file.Add("# source: $($privateitem.name)")
			$file.Add("# Module: $($module.Name)")
			$file.Add('############################################')
			Write-Color '[Processing]: ', $($privateitem.name) -Color Cyan, Yellow
			Get-Content $privateitem.fullname | ForEach-Object { $file.add($_) }
		}
		$file.add('#endregion')
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
		$file | Set-Content -Path $rootModule -Encoding utf8 -Force

		$versionfile = [System.Collections.Generic.List[string]]::new()
		$versionfile.add()
		


	$versionfile = [System.Collections.Generic.List[PSObject]]::New()
	$versionfile.add([pscustomobject]@{
		version =  $($moduleManifest.version)
		Author =  $($moduleManifest.author)
		Date = (Get-Date -Format u)
			})


		$newfunction = ((Select-String -Path $rootModule -Pattern '^# source:').Line).Replace('# source:', '').Replace('.ps1', '').Trim()
		$ModCommands = Get-Command -Module $module | ForEach-Object { $_.name }

		Compare-Object -ReferenceObject $ModCommands -DifferenceObject $newfunction | ForEach-Object {
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'Not Copied'
					File     = $_.InputObject
					details  = $_.SideIndicator
				})
		}
	}
	function mkdocs {
		#region mkdocs
		Write-Color '[Starting]', 'mkdocs' -Color Yellow, DarkCyan
		if ($mkdocs -like 'serve') {
			Set-Location (Split-Path -Path $Moduledocs -Parent)
			Start-Process mkdocs serve
			Start-Sleep 5
			Start-Process "http://127.0.0.1:8000/$($module.Name)/"
		}
		if ($mkdocs -like 'gh-deploy') {
			Set-Location (Split-Path -Path $Moduledocs -Parent)
			Start-Process mkdocs gh-deploy
		}
		#endregion
	}

	if ($VersionBump -like 'CombineOnly') { 
		combine
		mkdocs
	} else {
		exthelp
		combine
		mkdocs
	}
	if ($null -notlike $Issues) { $issues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName Other -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow }

	#endregion

} #end Function