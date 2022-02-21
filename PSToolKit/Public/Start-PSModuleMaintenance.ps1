
<#PSScriptInfo

.VERSION 0.1.0

.GUID 00b3d690-33fa-4d68-bf6f-c7114700bc16

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
Goes through all the installed modules, and allow you to upgrade(If available), or remove old versions

#>


<#
.SYNOPSIS
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

.DESCRIPTION
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

.PARAMETER ListUpdateAvailable
Filter to show only the modules with update available.

.PARAMETER PerformUpdate
Performs the update-module function on modules with updates available.

.PARAMETER RemoveDuplicates
Checks if a module is installed in more than one location, and reinstall it the all users profile.

.PARAMETER RemoveOldVersions
Delete the old versions of existing modules.

.PARAMETER ForceRemove
If unable to remove, then the directory will be deleted.

.EXAMPLE
Start-PSModuleMaintenance -ListUpdateAvailable -PerformUpdate

#>
Function Start-PSModuleMaintenance {
	[Cmdletbinding(DefaultParameterSetName = 'Update', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSModuleMaintenance')]
	PARAM(
		[Parameter(ParameterSetName = 'Update')]
		[switch]$ListUpdateAvailable = $false,
		[Parameter(ParameterSetName = 'Update')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$PerformUpdate = $false,
		[Parameter(ParameterSetName = 'Duplicate')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$RemoveDuplicates = $false,
		[Parameter(ParameterSetName = 'Remove')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$RemoveOldVersions = $false,
		[Parameter(ParameterSetName = 'Remove')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$ForceRemove = $false
	)

	if (-not ($RemoveOldVersions) -and (-not $RemoveDuplicates)) {
		$index = 0
		[System.Collections.ArrayList]$moduleReport = @()
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }
		Write-Host 'Collecting Online Modules, this might take some time' -ForegroundColor Cyan
		$AllOnlineModules = Find-Module *
		foreach ($SingleModule in $InstalledModules) {
			$index++
			Write-Host "Checking Module $index of"$InstalledModules.count -NoNewline -ForegroundColor Green; Write-Host ' '$SingleModule.Name -ForegroundColor Yellow
			try {
				$OnlineModule = $AllOnlineModules | Where-Object { $_.name -like $SingleModule.Name }
				if ($SingleModule.Version -lt $OnlineModule.Version) { $ModuleUpdate = 'UpdateAvailable' }
				else { $ModuleUpdate = 'NoUpdate' }
			}
			catch { $OnlineModule = $null }
			$moduleReport.Add([pscustomobject]@{
					Name                 = $SingleModule.Name
					Description          = $SingleModule.Description
					InstalledVersion     = $SingleModule.Version
					Functions            = $OnlineModule.AdditionalMetadata.Functions
					lastUpdated          = $OnlineModule.AdditionalMetadata.lastUpdated
					downloadCount        = $OnlineModule.AdditionalMetadata.downloadCount
					versionDownloadCount = $OnlineModule.AdditionalMetadata.versionDownloadCount
					OnlineVersion        = $OnlineModule.Version
					OnlineLastUpdated    = $OnlineModule.AdditionalMetadata.lastUpdated
					Update               = $ModuleUpdate
					InstalledPath        = $SingleModule.InstalledLocation
				})
		}

		if ($ListUpdateAvailable) { return $moduleReport | Where-Object { $_.Update -like 'UpdateAvailable' } }
		if ($PerformUpdate) {
			$moduleReport | Where-Object { $_.Update -like 'ListUpdateAvailable' } | ForEach-Object {
				Write-Color 'Performing update on: ', $_.name -Color Green, Yellow
				Update-Module -Name $_.name -Force }
		}
		if (-not($ListUpdateAvailable) -and (-not($PerformUpdate))) { return $moduleReport }
	}
	if ($RemoveOldVersions) {
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }
		foreach ($SingleModule in $InstalledModules) {
			$CheckOldMod = $null
			$CheckOldMod = Get-Module $SingleModule.Name
			if ($null -eq $CheckOldMod) { $CheckOldMod = Get-Module $SingleModule.Name -ListAvailable }
			if ($CheckOldMod.count -gt 1) {
				$TopVersion = $CheckOldMod | Sort-Object -Property version -Descending | Select-Object -First 1
				foreach ($removemod in ($CheckOldMod | Where-Object { $_.Version -lt $TopVersion.Version } )) {
					try {
						Remove-Module -Name $removemod.Name -Force -ErrorAction SilentlyContinue
						Write-Color "[$($removemod.name)]", "[$(((Get-Item $removemod.Path).Directory).Parent.FullName)]", ' Removing ', $removemod.Version -Color Yellow, DarkCyan, Red, DarkYellow
						Get-InstalledModule -Name $removemod.Name -RequiredVersion $removemod.Version | Uninstall-Module -Force -ErrorAction Stop
					}
					catch {
						Write-Warning "Unable to uninstall $($removemod.name):`n $($_.Exception.Message)"
						if ($ForceRemove) {
							try {
								Write-Color "[$($removemod.name)]", "[$(((Get-Item $removemod.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
								Remove-Item -Path (Get-Item $removemod.Path).Directory -Recurse -Force
							}
							catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
						}
					}
				}
			}
		}
	}
	if ($RemoveDuplicates) {
		[System.Collections.ArrayList]$duplicates = @()
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }

		foreach ($SingleModule in $InstalledModules) {
			$DupMod = $null
			$DupMod = Get-Module $SingleModule.Name
			if ($null -eq $DupMod) { $DupMod = Get-Module $SingleModule.Name -ListAvailable }
			if ($DupMod.path.count -gt 1) {
				$DupMod | ForEach-Object {
					[void]$duplicates.Add($_)
				}
			}
		}

		foreach ($dup in $duplicates) {
			try {
				Write-Color "[$($dup.name)]", " - $($dup.path)", 'Remove Duplicate' -Color Yellow, DarkCyan, Red
				Remove-Module $dup.name -Force -ErrorAction SilentlyContinue
				Get-InstalledModule -Name $dup.name -RequiredVersion $dup.Version -ErrorAction SilentlyContinue | Uninstall-Module -Force -ErrorAction Stop
			}
			catch { Write-Warning "Unable to remove:`n $($_.Exception.Message)" }
			try {
				if (Test-Path (Get-Item $dup.Path).Directory) {
					Write-Color "[$($dup.name)]", "[$(((Get-Item $dup.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
					Remove-Item -Path ((Get-Item $dup.Path).Directory).FullName -Recurse -Force -ErrorAction Stop
				}
			}
			catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
		}

		Write-Color 'Reinstall Module:' -Color Cyan
		$duplicates.name | Sort-Object -Unique | ForEach-Object {
			try {
				Write-Color "[$($_)]" -Color Yellow
				Install-Module -Name $_ -Scope AllUsers -AllowClobber -Force -ErrorAction Stop
			}
			catch { Write-Warning "Unable to install from:`n $($_.Exception.Message)" }
		}
	}
} #end Function
