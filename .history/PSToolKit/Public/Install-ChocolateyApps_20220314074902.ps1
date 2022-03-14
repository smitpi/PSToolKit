
<#PSScriptInfo

.VERSION 0.1.0

.GUID 1ed79a25-fb1f-4090-aab6-c183a872dc09

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
Created [15/01/2022_12:32] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Install chocolatey apps from a json list

#>


<#
.SYNOPSIS
 Install chocolatey apps from a json list.

.DESCRIPTION
 Install chocolatey apps from a json list.

.PARAMETER BaseApps
Use build in base app list

.PARAMETER ExtendedApps
Use build in extended app list

.PARAMETER OtherApps
Specify your own json list file

.PARAMETER JsonPath
Path to the json file

.EXAMPLE
Install-ChocolateyApps -BaseApps

#>
Function Install-ChocolateyApps {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyApps')]
	PARAM(
		[Parameter(ParameterSetName = 'Set1')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$BaseApps = $false,
		[Parameter(ParameterSetName = 'Set1')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$ExtendedApps = $false,
		[Parameter(ParameterSetName = 'Set2')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$OtherApps = $false,
		[Parameter(ParameterSetName = 'Set2')]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$JsonPath
	)
	try {
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path does not exist' }
	if ($BaseApps) { $AppList = (Join-Path $ConPath.FullName -ChildPath BaseAppList.json) }
	if ($ExtendedApps) { $AppList = (Join-Path $ConPath.FullName -ChildPath ExtendedAppsList.json) }
	if ($OtherApps) { $AppList = Get-Item $JsonPath }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	[System.Collections.ArrayList]$installs = @()
	[System.Collections.ArrayList]$installs = Get-Content $AppList -Raw | ConvertFrom-Json

	foreach ($app in $installs) {
		$ChocoApp = choco search $app.name --exact --local-only --limit-output
		$ChocoAppOnline = choco search $app.name --exact --limit-output
		if ($null -eq $ChocoApp) {
			Write-Color 'Installing App: ', $($app.name), ' from source ', $app.Source -Color Cyan, Yellow, Cyan, Yellow
			choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
			if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
		} else {
			Write-Color 'Using Installed App: ', $($ChocoApp.split('|')[0]), " -- (version: $($ChocoApp.split('|')[1]))" -Color Cyan, Green, Yellow
			if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
				Write-Color 'Update Available: ', $($app.name)," (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', $app.Source -Color Cyan,green, Yellow, Cyan, Yellow
				choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
				if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
			}
		}
	}


} #end Function
