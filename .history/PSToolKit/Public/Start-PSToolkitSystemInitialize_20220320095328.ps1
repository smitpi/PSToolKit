
<#PSScriptInfo

.VERSION 0.1.0

.GUID 20a11041-b860-4f1e-bf1a-1e0becbd672e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [24/02/2022_05:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Commands for a new system

#>


<#
.SYNOPSIS
Initialize a blank machine.

.DESCRIPTION
Initialize a blank machine with PSToolKit tools and dependencies.

.PARAMETER LabSetup
Commands only for my HomeLab

.PARAMETER InstallMyModules
Install my other published modules.

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false
	)

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution' -ForegroundColor Cyan
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Gallery' -ForegroundColor Cyan
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted' ) {
		$null = Install-PackageProvider Nuget -Force
		$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
		$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	}
	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Needed Powershell modules' -ForegroundColor Cyan

	'ImportExcel', 'PSWriteHTML', 'PSWriteColor', 'PSScriptTools', 'PoshRegistry', 'Microsoft.PowerShell.Archive' | ForEach-Object {
		$module = $_
		if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
			try {
				Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
				Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
			} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
		}
	}

	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PSToolKit Module' -ForegroundColor Cyan
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-PSToolKit.ps1', "$($env:TEMP)\Update-PSToolKit.ps1")
	$full = Get-Item "$($env:TEMP)\Update-PSToolKit.ps1"
	Import-Module $full.FullName -Force
	Update-PSToolKit -AllUsers
	Remove-Item $full.FullName

	Import-Module PSToolKit -Force
	if ($LabSetup) {
		Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule
		Install-PSModules -BaseModules -Scope AllUsers
		Install-ChocolateyClient
		Install-ChocolateyApps -BaseApps
	}
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Installing Other Modules' -ForegroundColor Cyan
		'CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck' | ForEach-Object {
			$module = $_
			Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
			if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
				try {
					Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
					Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
				} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
			} else {
				$LocalMod = Get-Module $module
				if (-not($LocalMod)) {$LocalMod = Get-Module $module -ListAvailable}
				if (($LocalMod[0].Version) -lt (Find-Module $module).Version) {
					try {
						Write-Host '[Upgrading] Module: ' -NoNewline -ForegroundColor Cyan; Write-Host "$($module)" -ForegroundColor Yellow
						Update-Module -Name $module -Force -Scope AllUsers
					} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
				}
			}
		}
	}
	Start-PSProfile -ClearHost -AddFun -ShowModuleList -GalleryStats
} #end Function
