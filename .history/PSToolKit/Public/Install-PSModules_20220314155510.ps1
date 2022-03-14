
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

.PARAMETER UpdateModules
Update the modules.

.PARAMETER RemoveAll
Remove the modules.

.EXAMPLE
Install-PSModules -BaseModules -Scope AllUsers

#>
Function Install-PSModules {
	[Cmdletbinding(DefaultParameterSetName = 'base', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSModules')]
	PARAM(
		[Parameter(ParameterSetName = 'base')]
		[switch]$BaseModules = $false,
		[Parameter(ParameterSetName = 'ext')]
		[switch]$ExtendedModules = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[validateset('CurrentUser', 'AllUsers')]
		[string]$Scope = 'CurrentUser',
		[Parameter(ParameterSetName = 'other')]
		[switch]$OtherModules = $false,
		[Parameter(ParameterSetName = 'other')]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JsonPath,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$ForceInstall = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$UpdateModules = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$RemoveAll = $false
	)

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Throw "Config path does not exist`nRun Update-PSToolKitConfigFiles to install the config files" }
	if ($BaseModules) { $ModuleList = (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) }
	if ($ExtendedModules) { $ModuleList = (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) }
	if ($OtherModules) { $ModuleList = Get-Item $JsonPath }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$mods = Get-Content $ModuleList | ConvertFrom-Json
	if ($RemoveAll) {
		try {
			$mods | ForEach-Object { 
				Write-Color '[Removing] ', $($_.Name) -Color Yellow, Cyan
				Get-Module -Name $_.Name -ListAvailable | Uninstall-Module -AllVersions -Force
			}
		} catch {Write-Warning "Error Uninstalling $($mod.Name) `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}
	if ($UpdateModules) {
		try {
			$mods | ForEach-Object {
				Write-Color '[Installing] ', $($_.Name) -Color Yellow, Cyan
				Get-Module -Name $_.Name -ListAvailable | Select-Object -First 1 | Update-Module -Force
			}
		} catch {Write-Warning "Error Updating: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}

	foreach ($mod in $mods) {
		if ($ForceInstall -eq $false) { $PSModule = Get-Module -Name $mod.Name -ListAvailable | Select-Object -First 1 }
		if ($PSModule.Name -like '') {
			Write-Color '[Installing] ', $($mod.Name), ' to Scope: ', $($Scope) -Color Yellow, Cyan, Green, Cyan
			Install-Module -Name $mod.Name -Scope $Scope -AllowClobber -Force
		} else {
			Write-Color '[Installing] ',"$($PSModule.Name): ", 'Already Installed - ',  " (Path: $($PSModule.Path))", -Color Yellow, Cyan, DarkRed, Cyan
		}
	}
}
