
<#PSScriptInfo

.VERSION 0.1.0

.GUID 2709e068-607f-4c46-a69d-e141f55a0505

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
 Install modules from .json file

#>

<#
.SYNOPSIS
 Install modules from .json file.

.DESCRIPTION
 Install modules from .json file.

.PARAMETER BaseModules
Only base list.

.PARAMETER ExtendedModules
Use longer list.

.PARAMETER Scope
Scope to install modules (CurrentUser or AllUsers).

.PARAMETER OtherModules
Use Manual list.

.PARAMETER JsonPath
Path to manual list.

.PARAMETER ForceInstall
Force reinstall.

.PARAMETER RemoveAll
Remove the modules.

.EXAMPLE
Install-PSModule -BaseModules -Scope AllUsers

#>
Function Install-PSModule {
	[Cmdletbinding(DefaultParameterSetName = 'List', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSModules')]
	PARAM(
		[Parameter(ParameterSetName = 'List')]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[string]$List = 'ExtendedModules',

		[Parameter(ParameterSetName = 'Other', ValueFromPipeline)]
		[string[]]$ModuleNamesList,	

		[Parameter(ParameterSetName = 'download')]
		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[switch]$DownloadModules,

		[Parameter(ParameterSetName = 'download', Mandatory)]
		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$Path = 'C:\Temp',

		[string]$Repository = 'PSGallery',

		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[validateset('CurrentUser', 'AllUsers')]
		[string]$Scope = 'AllUsers'

	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path foes not exist'; exit }
	if ($List -like 'BaseModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) | ConvertFrom-Json).name}
	elseif ($List -like 'ExtendedModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) | ConvertFrom-Json).name }
	elseif ($ModuleNamesList) {$mods = $ModuleNamesList}

	if (-not($mods)) {throw 'Couldnt get a valid modules list'}

	if ($DownloadModules) {
		$mods | ForEach-Object {
			Write-Color '[Downloading] ', $($_), ' to folder: ', $($Path), ' from ', $($Repository) -Color Yellow, Cyan, Green, Cyan, Green, Cyan
			#Save-Module -Name $_ -Repository $Repository -Path $Path -AcceptLicense -Force
			Save-Package -Name $_ -Provider NuGet -Source https://www.powershellgallery.com/api/v2 -Path $Path | Out-Null
		}
	} else {
		foreach ($mod in $mods) {
			$PSModule = Get-Module -Name $mod -ListAvailable | Select-Object -First 1
			if ($PSModule.Name -like '') {
				Write-Color '[Installing] ', $($mod), ' to Scope: ', $($Scope), ' from ', $($Repository) -Color Yellow, Cyan, Green, Cyan, Green, Cyan
				Install-Module -Name $mod -Scope $Scope -AllowClobber -Force -Repository $Repository
			} else {
				Write-Color '[Installing] ', "$($PSModule.Name): ", "(Path: $($PSModule.Path))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
				$OnlineMod = Find-Module -Name $mod -Repository $Repository
				if ($PSModule.Version -lt $OnlineMod.Version) {
					Write-Color "`t[Upgrading] ", "$($PSModule.Name): ", 'to version ', "$($OnlineMod.Version)" -Color Yellow, Cyan, Green, DarkRed
					try {
						Get-Module -Name $PSModule.Name -ListAvailable | Select-Object -First 1 | Update-Module -Force -ErrorAction Stop
					} catch {Get-Module -Name $PSModule.Name -ListAvailable | Select-Object -First 1 | install-module -Scope $Scope -Force -AllowClobber}
				}
			}
		}
	}
}


$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	(Get-PSRepository).Name
}
Register-ArgumentCompleter -CommandName Install-PSModule -ParameterName Repository -ScriptBlock $scriptBlock
