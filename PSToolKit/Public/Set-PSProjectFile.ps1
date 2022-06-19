
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

.PARAMETER ModuleScriptFile
Path to module .psm1 file.

.PARAMETER CopyNestedModules
Will copy the required modules to the folder.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER mkdocs
Create and test the mkdocs site

.PARAMETER GitPush
Run Git Push when done.

.PARAMETER CopyToModulesFolder
Copies the module to program files.

.EXAMPLE
Set-PSProjectFiles -ModuleScriptFile blah -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[System.IO.FileInfo]$ModuleScriptFile,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'CombineOnly',
		[ValidateSet('serve', 'deploy')]
		[string]$mkdocs = 'None',
		[switch]$CopyNestedModules = $false,
		[Switch]$GitPush = $false,
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$CopyToModulesFolder = $false
	)
	
	#region module
	Write-Color '[Starting]', ' Module Import' -Color Yellow, DarkCyan
	try {
		$modulefile = $ModuleScriptFile | Get-Item -ErrorAction Stop
		$module = Import-Module $modulefile.FullName -Force -PassThru -ErrorAction Stop
	}
 catch { Write-Error "Error: Importing Module `nMessage:$($_.Exception.message)"; exit }
	#endregion

	#region deleting Folders
	Write-Color '[Starting]', ' Removing Old Folders' -Color Yellow, DarkCyan
	$ModuleBase = ((Get-Item $module.ModuleBase).Parent).fullname
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$ModulePublicFunctions = [IO.Path]::Combine($module.ModuleBase, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($module.ModuleBase, 'Private') | Get-Item
	$Modulemkdocs = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocs.yml')
	$ModuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	[System.Collections.ArrayList]$Issues = @()

	try {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop; Start-Sleep 5 }
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
		if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssuesExcel) { Remove-Item $ModuleIssuesExcel -Force -ErrorAction Stop }	
	}
	catch {
		try {
			Write-Warning "Error: Deleting Old Folders `nMessage:$($_.Exception.message)`nRetrying"
			Start-Sleep 10
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop; Start-Sleep 5 }
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
		}
		catch { throw 'Error removing Folder Structure' ; exit }
 }
	#endregion
    
	#region version bump
	if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
		try {
			Write-Color '[Starting]', ' Version increase' -Color Yellow, DarkCyan
			$ModuleManifestFileTMP = Get-Item ($module.Path).Replace('.psm1', '.psd1')
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName -ErrorAction Stop).version 

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				FunctionsToExport = (Get-Command -Module $module.Name -CommandType Function | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties -ErrorAction Stop
		}
		catch { Write-Error "Error: Updateing Version bump `nMessage:$($_.Exception.message)"; exit }
	} 
	#endregion
	#region Folders
	try {
		Write-Color '[Starting]', ' Creating New Folder Structure' -Color Yellow, DarkCyan
		$ModuleManifestFile = Get-Item ($module.Path).Replace('.psm1', '.psd1')
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object * -ErrorAction Stop
		$FileContent = Get-Content $ModuleManifestFile -ErrorAction Stop
		$DateLine = Select-String -InputObject $ModuleManifestFile -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $ModuleManifestFile -Force -ErrorAction Stop
	}
	catch { Write-Error "Error: Updating Date in Module Manifest File  `nMessage:$($_.Exception.message)"; exit }
	try {
		$ModuleOutputFolder = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
		$ModuleOutput = New-Item $ModuleOutputFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop

		$ModuledocsFolder = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
		$Moduledocs = New-Item $ModuledocsFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop

		$ModuleExternalHelpFolder = [IO.Path]::Combine($ModuleOutput, 'en-US')
		$ModuleExternalHelp = New-Item $ModuleExternalHelpFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop
	}
	catch { Write-Error "Error: Creating folders `nMessage:$($_.Exception.message)"; exit }
	#endregion

	#region platyps
	try {
		Write-Color '[Starting]', ' Creating Markdown help files' -Color Yellow, DarkCyan
		$markdownParams = @{
			Module         = $module.Name
			OutputFolder   = $Moduledocs.FullName
			WithModulePage = $false
			Locale         = 'en-US'
			HelpVersion    = $ModuleManifest.Version.ToString()
		}
		New-MarkdownHelp @markdownParams -Force
	}
 catch { Write-Error "Error: MarkdownHelp `nMessage:$($_.Exception.message)"; exit }

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
	}
 catch { Write-Error "Error: Docs check `nMessage:$($_.Exception.message)"; exit }

	try {
		Write-Color '[Starting]', ' Creating External help files' -Color Yellow, DarkCyan
		New-ExternalHelp -Path $Moduledocs.FullName -OutputPath $ModuleExternalHelp.FullName -Force -ShowProgress

		Write-Color '[Starting]', ' Creating About help files' -Color Yellow, DarkCyan
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
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { ($aboutfile.Add("`t $_ -- $((Get-Help $_).synopsis)")) }
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
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $readme.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
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
		$mkdocsFunc | Set-Content -Path $Modulemkdocs -Force

		$indexFile = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
		$indexFile.add(' ')
		$indexFile.add('## Functions')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $indexFile.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
		$indexFile | Set-Content -Path $ModuleIndex -Force

		$versionfile = [System.Collections.Generic.List[PSObject]]::New()
		$versionfile.add([pscustomobject]@{
				version = $($moduleManifest.version).ToString()
				Author  = $($moduleManifest.author)
				Date    = (Get-Date -Format u)
			})
		$versionfile | ConvertTo-Json | Set-Content (Join-Path $ModuleBase -ChildPath 'Version.json') -Force
	}
 catch { Write-Error "Error: Creating Other Files `nMessage:$($_.Exception.message)"; exit }
	#endregion
	
	#region Combine files
	Write-Color '[Starting]', ' Creating new module files' -Color Yellow, DarkCyan

	$ModuleOutput = Get-Item $ModuleOutput
	$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))

	Copy-Item -Path $ModuleManifestFile.FullName -Destination $ModuleOutput.fullname -Force
	$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
	if ($null -notlike $PrivateFiles) {
		Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
	}

	$private = @(Get-ChildItem -Path "$($ModulePrivateFunctions.FullName)\*.ps1" -ErrorAction Stop | Sort-Object -Property Name)
	$public = @(Get-ChildItem -Path "$($ModulePublicFunctions.FullName)\*.ps1" -Recurse -ErrorAction Stop | Sort-Object -Property Name)

	$file = [System.Collections.Generic.List[string]]::new()
	if ($private) {
		$file.add('#region Private Functions')
		foreach ($privateitem in $private) {
			$file.add("#region $($privateitem.name)")
			$file.Add('########### Private Function ###############')
			$file.Add(('{0,-20}{1}' -f '# Source:', $($privateitem.name)))
			$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
			$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
			$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
			$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($privateitem.CreationTime)))
			$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($privateitem.LastWriteTime)))
			$file.Add('############################################')
			Write-Color '[Processing]: ', $($privateitem.name) -Color Cyan, Yellow
			Get-Content $privateitem.fullname | ForEach-Object { $file.add($_) }
			$file.add('#endregion')
		}
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#region Public Functions')
	foreach ($PublicItem in $public) {
		$file.add("#region $($PublicItem.name)")
		$file.Add("### Function $($public.IndexOf($PublicItem)) of $($public.Count) ###")
		$file.Add(('{0,-20}{1}' -f '# Function:', $($PublicItem.BaseName)))
		$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
		$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
		$file.Add(('{0,-20}{1}' -f '# Author:', $($moduleManifest.author)))
		$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
		$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($PublicItem.CreationTime)))
		$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($PublicItem.LastWriteTime)))
		$file.Add(('{0,-20}{1}' -f '# Synopsis:', $((Get-Help $($PublicItem.BaseName)).synopsis)))
		$file.Add('#############################################')
		$file.Add(' ')
		Write-Color '[Processing]: ', $($PublicItem.name) -Color Cyan, Yellow

		[int]$StartIndex = (Select-String -InputObject $PublicItem -Pattern '.SYNOPSIS*').LineNumber[0] - 2
		[int]$EndIndex = (Get-Content $PublicItem.FullName).length
		Get-Content -Path $PublicItem.FullName | Select-Object -Index ($StartIndex..$EndIndex) | ForEach-Object { $file.Add($_) }
		$file.Add(' ')
		$file.Add("Export-ModuleMember -Function $($PublicItem.BaseName)")
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#endregion')
	$file.Add(' ')
	$file | Set-Content -Path $rootModule -Encoding utf8 -Force

	$newfunction = ((Select-String -Path $rootModule -Pattern '^# Function:').Line).Replace('# Function:', '').Trim()
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
		Write-Color '[Starting]', ' Copying nested modules' -Color Yellow, DarkCyan

		if (-not(Test-Path $(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules'))) {
			New-Item -Path "$(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules')" -ItemType Directory -Force | Out-Null
		}
		foreach ($required in $ModuleManifest.RequiredModules) {
			$latestmod = $null
			Import-Module $required -Force -Verbose
			$latestmod = Get-Module $required | Sort-Object -Property Version | Select-Object -First 1
			if (-not($latestmod)) { $latestmod = Get-Module $required -ListAvailable | Sort-Object -Property Version | Select-Object -First 1 }
			
			Write-Color "`t[Copying]", "$($required.Name)" -Color Yellow, DarkCyan
			Copy-Item -Path (Get-Item $latestmod.Path).Directory -Destination ([IO.Path]::Combine($ModuleOutput, 'NestedModules', $($required.Name), $($latestmod.Version))) -Recurse
		}
		$nestedmodules = @()
		$nestedmodules = (Get-ChildItem -Path "$ModuleOutput\NestedModules\*.psm1" -Recurse).FullName | ForEach-Object { $_.Replace("$($ModuleOutput)\", '') }
		$rootManifest = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))

		$manifest = Import-PowerShellDataFile $ModuleManifest.Path
		$manifest.Remove('CmdletsToExport')
		$manifest.Remove('AliasesToExport')
		$manifest.Remove('PrivateData')
		if ($ModuleManifest.Tags) { $manifest.Add('Tags', $ModuleManifest.Tags) }
		if ($ModuleManifest.LicenseUri) { $manifest.Add('LicenseUri', $ModuleManifest.LicenseUri) }
		if ($ModuleManifest.ProjectUri) { $manifest.Add('ProjectUri', $ModuleManifest.ProjectUri) }
		if ($ModuleManifest.IconUri) { $manifest.Add('IconUri', $ModuleManifest.IconUri) }
		if ($ModuleManifest.ReleaseNotes) { $manifest.Add('ReleaseNotes', $ModuleManifest.ReleaseNotes) }

		if (Test-Path $rootManifest) { Remove-Item $rootManifest -Force }
		New-ModuleManifest -Path $rootManifest.FullName -NestedModules $nestedmodules @manifest

		$FileContent = Get-Content $rootManifest
		$DateLine = Select-String -InputObject $rootManifest -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $rootManifest -Force
	}
	#endregion

	#region report issues
	if ($null -notlike $Issues) { 
		Write-Color '[Starting]', ' Creating Issues Reports' -Color Yellow, DarkCyan
		$issues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName Other -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow 
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add((New-MDHeader "$($module.Name): Issues"))
		$Fragments.Add("---`n")
		$fragments.Add((New-MDTable -Object $Issues))
		$Fragments.Add("---`n")
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File -FilePath $ModuleIssues -Encoding utf8 -Force
	}
	#endregion
	
	#region mkdocs
	if ($mkdocs -like 'serve') {
		Write-Color '[Starting]', ' Creating MKDocs help files' -Color Yellow, DarkCyan
		Start-Process -FilePath mkdocs.exe -ArgumentList 'serve -a localhost:7070 --livereload --dirtyreload' -WorkingDirectory (Split-Path -Path $Moduledocs -Parent) -WindowStyle Normal
		Start-Sleep 5
		Start-Process "http://127.0.0.1:7070/$($module.Name)/"
	}
	if ($mkdocs -like 'deploy') {
		Start-Process -FilePath mkdocs.exe -ArgumentList gh-deploy -WorkingDirectory (Split-Path -Path $Moduledocs -Parent) -NoNewWindow 2>&1 | Write-Host -ForegroundColor Yellow 
	}
	#endregion

	#region Git push
	if ($GitPush) {
		if (Get-Command git.exe -ErrorAction SilentlyContinue) {
			Write-Color '[Starting]', ' Git Push' -Color Yellow, DarkCyan
			Set-Location $ModuleBase 
			Start-Sleep 5
			git add --all 2>&1 | Write-Host -ForegroundColor DarkCyan
			git commit --all -m "To Version: $($moduleManifest.version.tostring())" 2>&1 | Write-Host -ForegroundColor DarkGreen
			git push 2>&1 | Write-Host -ForegroundColor DarkRed
		}
		else { Write-Warning 'Git is not installed' }
	}
	#endregion

	#region Copy to Dir
	if ($CopyToModulesFolder) {
		Write-Color '[Copying]', ' New Module ', "$($modulefile.basename) ver:($($ModuleManifest.Version.ToString())) ", 'to Program Files' -Color Yellow, DarkCyan, Green, DarkCyan
		if (-not(Test-Path "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)")) { New-Item "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" -ItemType Directory -Force | Out-Null }
		Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" | Compress-Archive -DestinationPath "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)\$($modulefile.basename)-bck.zip" -Update
		Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" | Remove-Item -Recurse -Force
		Copy-Item -Path $ModuleOutput.FullName -Destination "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)\" -Force -Recurse
	}
	#endregion

}#end Function
 
$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
	$here = (Get-Item .)
	(Get-ChildItem -Path .\*.psm1 -Recurse).FullName | ForEach-Object { $_.Replace("$($here.FullName)", '.') }
}
Register-ArgumentCompleter -CommandName Set-PSProjectFile -ParameterName ModuleScriptFile -ScriptBlock $scriptBlock
