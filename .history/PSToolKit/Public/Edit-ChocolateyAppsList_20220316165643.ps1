
<#PSScriptInfo

.VERSION 0.1.0

.GUID 621b247a-ed41-411e-9ec6-a94b39444672

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
Created [05/03/2022_06:36] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Add or remove apps from the json file used in Install-ChocolateyApps

#>

<#
.SYNOPSIS
Add or remove apps from the json file used in Install-ChocolateyApps


.DESCRIPTION
Add or remove apps from the json file used in Install-ChocolateyApps


.PARAMETER ShowCurrent
List current apps in the json file

.PARAMETER AddApp
add an app to the list.

.PARAMETER ChocoID
Name or ID of the app.

.PARAMETER ChocoSource
The source where the app is hosted

.PARAMETER RemoveApp
Remove app from the list

.PARAMETER List
Which list to use.

.EXAMPLE
Edit-ChocolateyAppsList -AddApp -ChocoID 7zip -ChocoSource chocolatey

#>
Function Edit-ChocolateyAppsList {
	[Cmdletbinding(DefaultParameterSetName = 'Current', HelpURI = 'https://smitpi.github.io/PSToolKit/Edit-ChocolateyAppsList')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateSet('BaseApps', 'ExtendedApps')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$List,
		[Parameter(ParameterSetName = 'Current')]
		[switch]$ShowCurrent,
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Remove')]
		[switch]$RemoveApp,
		[Parameter(ParameterSetName = 'Add')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$AddApp,
		[Parameter(ParameterSetName = 'Add')]
		[string]$ChocoSource = 'chocolatey'
	)

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path foes not exist'; exit }

	if ($List -like 'BaseApps') { $AppList = (Join-Path $ConPath.FullName -ChildPath BaseAppList.json) }
	if ($List -like 'ExtendedApps') { $AppList = (Join-Path $ConPath.FullName -ChildPath ExtendedAppsList.json) }


	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
	function ListApps {
		PARAM($arg)
		$index = 0
		foreach ($inst in $arg) {
			Write-Color "$($index)) ", $($inst) -Color Cyan, Yellow
			++$index
		}
	}

	if ($ShowCurrent) { listapps $installs.name }

	if ($removeApp) {
		do {
			Clear-Host
			ListApps $installs.name
			Write-Color 'Q) ', 'To Exit'
			$select = Read-Host 'Make a selection'
			if ($select.ToUpper() -ne 'Q') { $installs.RemoveAt($select) }
		}
		until ($select.toupper() -eq 'Q')
		$installs | Sort-Object -Property Name -Unique | ConvertTo-Json | Set-Content -Path $AppList
		[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
		ListApps $installs.name
	}

	if ($AddApp) {
		$AppSearch = choco search $($ChocoID) --source=$($ChocoSource) --limit-output | ForEach-Object { ($_ -split '\|')[0] }
		if ($null -like $AppSearch) { Write-Error "Could not find the app in source: $($ChocoSource)" }
		if ($AppSearch.count -eq 1) {
			$tmp = New-Object -TypeName psobject -Property @{
				'Name'   = $ChocoID
				'Source' = $ChocoSource
			}
			$installs.Add($tmp)
		}
		if ($AppSearch.count -gt 1) {
			ListApps $AppSearch
			$select = Read-Host 'Make a selection: '
			$tmp = New-Object -TypeName psobject -Property @{
				'Name'   = $AppSearch[$select]
				'Source' = $ChocoSource
			}
			$installs.Add($tmp)
		}
		$installs | Sort-Object -Property Name -Unique | ConvertTo-Json | Set-Content -Path $AppList
		[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
		ListApps $installs.name
	}

} #end Function

Register-ArgumentCompleter -CommandName Edit-ChocolateyAppsList -ParameterName ChocoSource -ScriptBlock {
	choco source --limit-output | ForEach-Object { ($_ -split '\|')[0] }
}
