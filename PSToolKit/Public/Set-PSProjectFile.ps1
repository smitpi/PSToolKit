
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

.PARAMETER BuildHelpFiles
Use Platyps to build markdown help files.

.PARAMETER CopyNestedModules
Will copy the required modules to the nested modules folder.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER ReleaseNotes
Add release notes to the manifest file.

.PARAMETER DeployMKDocs
Create or test the mkdocs site

.PARAMETER RunScriptAnalyzer
Run RunScriptAnalyzer functions.

.PARAMETER GitPush
Run Git Push when done.

.PARAMETER CopyToModulesFolder
Copies the module to program files.

.PARAMETER ShowReport
Will open the issues report in a browser.

.EXAMPLE
Set-PSProjectFiles -ModuleScriptFile blah.psm1 -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[System.IO.FileInfo]$ModuleScriptFile,
		[ValidateSet('Minor', 'Build', 'CombineOnly', 'Revision')]
		[string]$VersionBump = 'Revision',
		[string]$ReleaseNotes = 'Updated Module Online Help Files',
		[switch]$BuildHelpFiles,
		[switch]$DeployMKDocs,
		[switch]$RunScriptAnalyzer,
		[Switch]$GitPush = $false,
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$CopyToModulesFolder = $false,
		[switch]$CopyNestedModules = $false,
		[switch]$ShowReport

	)
	
	#region module import
	try {
		$modulefile = $ModuleScriptFile | Get-Item -ErrorAction Stop
		Remove-Module $modulefile.BaseName -Force -ErrorAction SilentlyContinue
		$module = Import-Module $modulefile.FullName -Force -PassThru -ErrorAction Stop
		$OriginalModuleVer = (Import-PowerShellDataFile -Path $modulefile.FullName.Replace('.psm1', '.psd1')).ModuleVersion
		Write-Color '[Creating]', ' PowerShell Project: ', "$($module.Name)", " [ver $($OriginalModuleVer.tostring())]" -Color Yellow, Gray, Green, Yellow -LinesBefore 2 -LinesAfter 2
		Write-Color '[Starting]', ' Module Changes' -Color Yellow, DarkCyan
	} catch { Write-Error "Error: Importing Module `nMessage:$($_.Exception.message)"; return }
	#endregion

	#region Defining Folders
	$ModuleBase = ((Get-Item $module.ModuleBase).Parent).fullname
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$VersionFilePath = [IO.Path]::Combine($ModuleBase, 'Version.json')
	$ModulePublicFunctions = [IO.Path]::Combine($module.ModuleBase, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($module.ModuleBase, 'Private') | Get-Item
	$ModuleControlScripts = [IO.Path]::Combine($module.ModuleBase, 'Control_Scripts') | Get-Item -ErrorAction SilentlyContinue
	$Modulemkdocs = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocs.yml')
	$ModuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	$ScriptInfoArchive = [IO.Path]::Combine($ModuleBase, 'ScriptInfo.zip')
	[System.Collections.ArrayList]$Issues = @()
	#endregion
	
	#region Remove folders
	Write-Color "`t[Deleting]: ", 'Output Folder' -Color yello, Gray
	try {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssuesExcel) { Remove-Item $ModuleIssuesExcel -Force -ErrorAction Stop }
		if (Test-Path $VersionFilePath) { Remove-Item $VersionFilePath -Force -ErrorAction Stop }	
	} catch {
		try {
			Write-Warning "Error: Deleting Output Folders `nMessage:$($_.Exception.message)`nRetrying"
			Start-Sleep 10
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop }
		} catch { throw 'Error Removing Output Folder' ; return }
 }
	#endregion
    
	#region version bump
	if ($VersionBump -notlike 'CombineOnly' ) {
		try {
			Write-Color "`t[Processing]: ", 'Module Version Increase' -Color yello, Gray
			$ModuleManifestFileTMP = Get-Item $modulefile.FullName.Replace('.psm1', '.psd1')
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName -ErrorAction Stop).version 

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), 0 }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }
			if ($VersionBump -like 'Revision') { [version]$ModuleversionTMP = '{0}.{1}.{2}.{3}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, $ModuleversionTMP.Build, ($ModuleversionTMP.Revision + 1) }

			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				ReleaseNotes      = "Updated [$(Get-Date -Format dd/MM/yyyy_HH:mm)] $($ReleaseNotes)"
				FunctionsToExport = (Get-Command -Module $module.Name -CommandType Function | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties -ErrorAction Stop
		} catch { Write-Error "Error: Updateing Version bump `nMessage:$($_.Exception.message)"; return }
	} 
	#endregion
	
	#region add dateline
	Write-Color "`t[Processing]: ", 'Adding verbose date' -Color yello, Gray
	try {
		$ModuleManifestFile = Get-Item $modulefile.FullName.Replace('.psm1', '.psd1')
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object * -ErrorAction Stop
		$FileContent = Get-Content $ModuleManifestFile -ErrorAction Stop
		$DateLine = Select-String -InputObject $ModuleManifestFile -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $ModuleManifestFile -Force -ErrorAction Stop
	} catch { Write-Error "Error: Updating Date in Module Manifest File  `nMessage:$($_.Exception.message)"; return }
	#endregion
	
	#region Create Folders
	Write-Color "`t[Processing]: ", 'Creating Output Folder' -Color yello, Gray
	try {
		$ModuleOutputFolder = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
		$ModuleOutput = New-Item $ModuleOutputFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop
	} catch { Write-Error "Error:Creating Output Folder `nMessage:$($_.Exception.message)"; return }
	#endregion

	#region platyps
	if ($BuildHelpFiles) {
		Write-Color '[Starting]', ' Building Help Files' -Color Yellow, DarkCyan
		Write-Color "`t[Deleting]: ", 'Docs Folder' -Color yello, Gray
		try {
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
			if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force -ErrorAction Stop }	
		} catch {
			try {
				Write-Warning "Error: Deleting Docs Folders `nMessage:$($_.Exception.message)`nRetrying"
				Start-Sleep 10
				if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
			} catch { throw 'Error Removing Docs folder' ; return }
		}
		try {
			Write-Color "`t[Processing]: ", 'Creating Mardown Help Files' -Color yello, Gray
			$ModuledocsFolder = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
			$Moduledocs = New-Item $ModuledocsFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop
			$ModuleExternalHelpFolder = [IO.Path]::Combine($ModuleOutput, 'en-US')
			$ModuleExternalHelp = New-Item $ModuleExternalHelpFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop

			$markdownParams = @{
				Module         = $module.Name
				OutputFolder   = $Moduledocs.FullName
				WithModulePage = $true
				Locale         = 'en-US'
				HelpVersion    = $ModuleManifest.Version.ToString()
			}
			#New-MarkdownHelp @markdownParams -Force
            New-MarkdownCommandHelp  @markdownParams -Force

		} catch { Write-Error "Error: Creating Mardown Help Files `nMessage:$($_.Exception.message)"; return }

		try {
			Compare-Object -ReferenceObject (Get-ChildItem $ModulePublicFunctions).BaseName -DifferenceObject (Get-ChildItem $Moduledocs).BaseName | Where-Object { $_.SideIndicator -like '<=' } | ForEach-Object {
				[void]$Issues.Add([PSCustomObject]@{
						Catagory = 'External Help'
						File     = $_.InputObject
						details  = 'Did not create the .md file'
					})
			}

			[void]$Issues.Add([PSCustomObject]@{
					Catagory = $null
					File     = $null
					details  = $null
				})

			$MissingDocumentation = Select-String -Path (Join-Path $Moduledocs.FullName -ChildPath '\*.md') -Pattern '({{.*}})'
			$group = $MissingDocumentation | Group-Object -Property Line
			foreach ($gr in $group) {
				foreach ($item in $gr.Group) {
					$object = Get-Item $item.Path
					$mod = Get-Content -Path $object.FullName
					Write-Color "`t$($object.name):", "$($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])" -Color Yellow, Red
					[void]$Issues.Add([PSCustomObject]@{
							Catagory = 'External Help'
							File     = $object.name
							details  = "$($object.name) - $($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])"
						})
				}
			}
		} catch { Write-Error "Error: Docs check `nMessage:$($_.Exception.message)"; return }

		try {
			Write-Color "`t[Processing]: ", 'External Help Files' -Color yello, Gray
			New-ExternalHelp -Path $Moduledocs.FullName -OutputPath $ModuleExternalHelp.FullName -Force | Out-Null

			Write-Color "`t[Processing]: ", 'About Help Files' -Color yello, Gray
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
				Write-Color "`t[Processing]: ", 'Instructions Files' -Color yello, Gray
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
				$instructions.Add("- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/$($module.Name))")
				$instructions.Add('```')
				$instructions.Add("`$CurrentLocation = Get-Item .")
				$instructions.Add("`$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item `$profile).Directory 'Modules')).FullName -ChildPath $($Module.Name))")
				$instructions.Add("git clone --depth 1 https://github.com/smitpi/$($module.Name) `$ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow")
				$instructions.Add("Set-Location `$ModuleDestination")
				$instructions.Add('git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow')
				$instructions.Add("Set-Location `$CurrentLocation")
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

			Write-Color "`t[Processing]: ", 'Readme Files' -Color yello, Gray
			$readme = [System.Collections.Generic.List[string]]::new()
			Get-Content -Path $ModulesInstuctions | ForEach-Object { $readme.add($_) }
			$readme.add(' ')
			$readme.add('## PS Controller Scripts')
			Get-ChildItem $ModuleControlScripts.FullName | ForEach-Object {$readme.add("- $($_.name)")}
			$readme.add(' ')
			$readme.add('## Functions')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $readme.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
			$readme | Set-Content -Path $ModuleReadme

			Write-Color "`t[Processing]: ", 'MKDocs Config Files' -Color yello, Gray
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
			$mkdocsFunc.add('theme: material')
			$mkdocsFunc | Set-Content -Path $Modulemkdocs -Force

			Write-Color "`t[Processing]: ", 'MKDocs Index Files' -Color yello, Gray
			$indexFile = [System.Collections.Generic.List[string]]::new()
			Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
			$indexFile.add(' ')
			$indexFile.add('## PS Controller Scripts')
			Get-ChildItem $ModuleControlScripts.FullName | ForEach-Object {$indexFile.add("- $($_.name)")}
			$indexFile.add(' ')
			$indexFile.add('## Functions')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $indexFile.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
			$indexFile | Set-Content -Path $ModuleIndex -Force

			Write-Color "`t[Processing]: ", 'Versioning Files' -Color yello, Gray
			$versionfile = [System.Collections.Generic.List[PSObject]]::New()
			$versionfile.add([pscustomobject]@{
					version = $($moduleManifest.version).ToString()
					Author  = $($moduleManifest.author)
					Date    = (Get-Date -Format u)
				})
			$versionfile | ConvertTo-Json | Set-Content $VersionFilePath -Force
		} catch { Write-Error "Error: Creating Other Files `nMessage:$($_.Exception.message)"; return }
	}
	#endregion
	
	#region Combine files
	Write-Color '[Starting]', ' Creating Monolithic Module Files ' -Color Yellow, DarkCyan

	$ModuleOutput = Get-Item $ModuleOutput
	$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))

	Copy-Item -Path $ModuleManifestFile.FullName -Destination $ModuleOutput.fullname -Force
	$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
	if ($null -notlike $PrivateFiles) {
		Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
	}
	Copy-Item -Path $ModuleControlScripts.FullName -Destination $ModuleOutput.fullname -Recurse -Force -ErrorAction SilentlyContinue

	$private = @(Get-ChildItem -Path "$($ModulePrivateFunctions.FullName)\*.ps1" -ErrorAction Stop | Sort-Object -Property Name)
	$public = @(Get-ChildItem -Path "$($ModulePublicFunctions.FullName)\*.ps1" -Recurse -ErrorAction Stop | Sort-Object -Property Name)

	$file = [System.Collections.Generic.List[string]]::new()
	if ($private) {
		$file.add('#region Private Functions')
		foreach ($PrivateItem in $private) {
			$file.add("#region $($PrivateItem.name)")
			$file.Add('########### Private Function ###############')
			$file.Add(('{0,-20}{1}' -f '# Source:', $($PrivateItem.name)))
			$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
			$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
			$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
			$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($PrivateItem.CreationTime)))
			$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($PrivateItem.LastWriteTime)))
			$file.Add('############################################')
			Write-Color "`t[Processing]: ", $($PrivateItem.name) -Color Yellow, Gray
			Get-Content $PrivateItem.fullname | ForEach-Object { $file.add($_) }
			$file.add('#endregion')
		}
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#region Public Functions')
	foreach ($PublicItem in $public) {
		$author = $ModuleManifest.Author
		try {
			$ScriptInfo = Test-ScriptFileInfo -Path $PublicItem.fullName -ErrorAction Stop
			$author = $ScriptInfo.author
		} catch {
			Write-Warning "`tCould not read script info [$($PublicItem.BaseName)], default values used."
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'ScriptFileInfo'
					File     = $($PublicItem.BaseName)
					details  = $_.Exception.Message
				})
			try {
				$PublicItem.fullName | Compress-Archive -DestinationPath $ScriptInfoArchive -Update
				$PatternBegin = Select-String -Path $PublicItem.fullName -Pattern '<#'
				$SCInfoRequires = Select-String -Path $PublicItem.fullName -Pattern '#Requires' | ForEach-Object {$_.Line.Replace('#Requires -Module ', $null)}
				$SCInfoVersion = ((Select-String -Path $PublicItem.fullName -Pattern '.VERSION' -CaseSensitive).Line.Replace('.VERSION ', $null)).Trim()
				$SCInfoAuthor = ((Select-String -Path $PublicItem.fullName -Pattern '.AUTHOR' -CaseSensitive).Line.Replace('.AUTHOR ', $null)).Trim()
				$SCInfoCompany = ((Select-String -Path $PublicItem.fullName -Pattern '.COMPANYNAME' -CaseSensitive).Line.Replace('.COMPANYNAME ', $null)).Trim()
				$ScriptContent = (Get-Content $PublicItem.fullName)[($PatternBegin[2].LineNumber - 1)..((Get-Content $PublicItem.fullName).Length)]

				Clear-Content -Path $PublicItem.fullName
				if ($SCInfoRequires) {Update-ScriptFileInfo -Path $PublicItem.fullName -Version $SCInfoVersion -Author $SCInfoAuthor -Guid (New-Guid) -CompanyName $SCInfoCompany -Description (Get-Help $PublicItem.BaseName).SYNOPSIS -RequiredModules $SCInfoRequires -Force}
				else {Update-ScriptFileInfo -Path $PublicItem.fullName -Version $SCInfoVersion -Author $SCInfoAuthor -Guid (New-Guid) -CompanyName $SCInfoCompany -Description (Get-Help $PublicItem.BaseName).SYNOPSIS -Force}
				$NewContent = Get-Content $PublicItem.fullName | Where-Object {$_ -notlike 'PARAM()'}
				Set-Content -Value $NewContent -Path $PublicItem.fullName
				Add-Content -Value $ScriptContent -Path $PublicItem.fullName
				$ScriptInfo = Test-ScriptFileInfo -Path $PublicItem.fullName
				$author = $ScriptInfo.author
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		}

		$file.add("#region $($PublicItem.name)")
		$file.Add("######## Function $($public.IndexOf($PublicItem) + 1) of $($public.Count) ##################")
		$file.Add(('{0,-20}{1}' -f '# Function:', $($PublicItem.BaseName)))
		$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
		$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
		$file.Add(('{0,-20}{1}' -f '# Author:', $($author)))
		$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
		$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($PublicItem.CreationTime)))
		$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($PublicItem.LastWriteTime)))
		$file.Add(('{0,-20}{1}' -f '# Synopsis:', $((Get-Help $($PublicItem.BaseName)).synopsis)))
		$file.Add('#############################################')
		$file.Add(' ')
		Write-Color "`t[Processing]: ", $($PublicItem.name) -Color Yellow, Gray

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
	#endregion

	#region Checking Monolithic module
	Write-Color '[Starting]', ' Running Tests on Monolithic Module' -Color Yellow, DarkCyan
	Write-Color "`t[Confirming]: ", 'All files are created.' -Color Yellow, Gray

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

	#region ScriptAnalyzer
	if ($RunScriptAnalyzer) {
		[void]$Issues.Add([PSCustomObject]@{
				Catagory = $null
				File     = $null
				details  = $null
			})
		Write-Color "`t[Processing]: ", 'ScriptAnalyzer Tests.' -Color Yellow, Gray
	
    
		[System.Collections.Generic.List[pscustomobject]]$RulesObject = @()
		Invoke-ScriptAnalyzer -IncludeSuppressed -Settings CodeFormatting -Recurse -Path $ModuleOutput.FullName -Fix | ForEach-Object {$RulesObject.Add($_)}
		Invoke-ScriptAnalyzer -IncludeSuppressed -Settings PSGallery -Recurse -Path $ModulePublicFunctions.PSParentPath | ForEach-Object {$RulesObject.Add($_)}
		Invoke-ScriptAnalyzer -IncludeSuppressed -Settings ScriptSecurity -Recurse -Path $ModulePublicFunctions.PSParentPath | ForEach-Object {$RulesObject.Add($_)}
		Invoke-ScriptAnalyzer -IncludeSuppressed -Settings ScriptFunctions -Recurse -Path $ModulePublicFunctions.PSParentPath | ForEach-Object {$RulesObject.Add($_)}
		Invoke-ScriptAnalyzer -IncludeSuppressed -Settings ScriptingStyle -Recurse -Path $ModulePublicFunctions.PSParentPath | ForEach-Object {$RulesObject.Add($_)}

		$RulesObject | ForEach-Object {
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'ScriptAnalyzer'
					File     = $_.ScriptName
					details  = "[$($_.Severity)]($($_.rulename))L $($_.Line): $($_.Message)"
				})
		}
		[void]$Issues.Add([PSCustomObject]@{
				Catagory = $null
				File     = $null
				details  = $null
			})
	}
	#endregion
	
	#region NestedModules
	if ($CopyNestedModules) {
		Write-Color '[Starting]', ' Copying Nested Modules' -Color Yellow, DarkCyan

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

	#region Copy to Modules Dir
	if ($CopyToModulesFolder) {
		Write-Color '[Starting]', ' Copy to Modules Folder' -Color Yellow, DarkCyan
		$ModuleFolders = @([IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules'),
			[IO.Path]::Combine($env:ProgramFiles, 'PowerShell', 'Modules'),
			[IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell', 'Modules'),
			[IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'PowerShell', 'Modules')
		)
		try {
			$DeleteFolders = (Get-ChildItem $ModuleFolders -Directory).FullName | Where-Object {$_ -like "*$($modulefile.basename)*"}
			$DeleteFolders | ForEach-Object {
				Write-Color "`t[Deleting] ", "$($_)" -Color Yellow, Gray -NoNewLine
				Remove-Item $_ -Force -Recurse -ErrorAction Stop
				Write-Host (' Complete') -ForegroundColor Green
			}
		} catch {Write-Warning "`nError: `n`tMessage:$($_.Exception.Message)"}

		try {
			Write-Color "`t[Copying]", " C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" -Color Yellow, Gray -NoNewLine
			if (-not(Test-Path "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)")) { New-Item "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" -ItemType Directory -Force | Out-Null }
			Copy-Item -Path $ModuleOutput.FullName -Destination "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)\" -Force -Recurse -ErrorAction Stop
			Write-Host (' Complete') -ForegroundColor Green

			Write-Color "`t[Copying]", " C:\Program Files\PowerShell\Modules\$($modulefile.basename)" -Color Yellow, Gray -NoNewLine
			if (-not(Test-Path "C:\Program Files\PowerShell\Modules\$($modulefile.basename)")) { New-Item "C:\Program Files\PowerShell\Modules\$($modulefile.basename)" -ItemType Directory -Force | Out-Null }
			Copy-Item -Path $ModuleOutput.FullName -Destination "C:\Program Files\PowerShell\Modules\$($modulefile.basename)\" -Force -Recurse -ErrorAction Stop
			Write-Host (' Complete') -ForegroundColor Green
		} catch {Write-Warning "`nError: `n`tMessage:$($_.Exception.Message)"}
	}
	#endregion

	#region mkdocs
	if ($DeployMKDocs) {
		Write-Color '[Starting]', ' Creating Online Help Files ' -Color Yellow, DarkCyan
		Write-Color "`t[MKDocs]", ' Theme Install:' -Color Yellow, Gray -NoNewLine
		Start-Process -FilePath pip.exe -ArgumentList 'install  mkdocs-windmill' -NoNewWindow -Wait -PassThru | Out-Null
		if (-not($?)) {
			$excode = $LASTEXITCODE
			Write-Host (' Failed') -ForegroundColor Red
			Write-Host (" [$($excode)]") -ForegroundColor Yellow
		} else {Write-Host (' Complete') -ForegroundColor Green}

		Write-Color "`t[MKDocs]", ' Deploy:' -Color Yellow, Gray -NoNewLine
		Start-Process -FilePath mkdocs.exe -ArgumentList gh-deploy -WorkingDirectory (Split-Path -Path $Moduledocs -Parent) -NoNewWindow -Wait | Out-Null
		if (-not($?)) {
			$excode = $LASTEXITCODE
			Write-Host (' Failed') -ForegroundColor Red
			Write-Host (" [$($excode)]") -ForegroundColor Yellow
		} else {Write-Host (' Complete') -ForegroundColor Green}
	}
	#endregion

	#region Git push
	if ($GitPush) {
		try {
			if (Get-Command git.exe -ErrorAction SilentlyContinue) {
				Write-Color '[Starting]', ' Git Actions' -Color Yellow, DarkCyan
		
				Write-Color "`t[Git]", ' Add:' -Color Yellow, Gray -NoNewLine
				Start-Process -FilePath git.exe -ArgumentList 'add --all' -WorkingDirectory $ModuleBase -Wait | Out-Null
				if (-not($?)) {
					$excode = $LASTEXITCODE
					Write-Host (' Failed') -ForegroundColor Red
					Write-Host (" [$($excode)]") -ForegroundColor Yellow
				} else {Write-Host (' Complete') -ForegroundColor Green}

				Write-Color "`t[Git]", ' Commit:' -Color Yellow, Gray -NoNewLine
				Start-Process -FilePath git.exe -ArgumentList "commit -m `"To Version: $($moduleManifest.version.tostring())`"" -WorkingDirectory $ModuleBase -Wait | Out-Null
				if (-not($?)) {
					$excode = $LASTEXITCODE
					Write-Host (' Failed') -ForegroundColor Red
					Write-Host (" [$($excode)]") -ForegroundColor Yellow
				} else {Write-Host (' Complete') -ForegroundColor Green}
				Write-Color "`t[Git]", ' Push:' -Color Yellow, Gray -NoNewLine
				Start-Process -FilePath git.exe -ArgumentList 'push' -WorkingDirectory $ModuleBase -Wait | Out-Null
				if (-not($?)) {
					$excode = $LASTEXITCODE
					Write-Host (' Failed') -ForegroundColor Red
					Write-Host (" [$($excode)]") -ForegroundColor Yellow
				} else {Write-Host (' Complete') -ForegroundColor Green}			
			} else { Write-Warning 'Git is not installed' }
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}
	#endregion

	#region report issues
	if (-not([string]::IsNullOrEmpty($Issues))) { 
		Write-Color '[Starting]', ' Creating Issues Reports' -Color Yellow, DarkCyan
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
		$fragments.Add('    padding-left: 10px;')
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
		if ($ShowReport) { 
			Start-Process -FilePath $ModuleIssues
			Start-Process -FilePath $ModuleIssuesExcel
			Start-Process $ModuleManifest.HelpInfoUri
		}
	}
	#endregion

	Write-Color '[Complete]', ' PowerShell Project: ', "$($module.Name)", " [ver $($ModuleManifest.Version.ToString())]" -Color Green, Gray, Green, Yellow -LinesBefore 2 -LinesAfter 2
}#end Function
 
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$here = (Get-Item .)
	(Get-ChildItem -Path .\*.psm1 -Recurse).FullName | ForEach-Object { $_.Replace("$($here.FullName)", '.') | Where-Object {$_ -like "*$wordToComplete*"}}
}
Register-ArgumentCompleter -CommandName Set-PSProjectFile -ParameterName ModuleScriptFile -ScriptBlock $scriptBlock
