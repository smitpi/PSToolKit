
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

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Profile"
	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$psfolder = Get-Item (Get-Item $profile).DirectoryName
	}
	else { $psfolder = Get-Item (Get-Item $profile).DirectoryName }

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Powershell Script Execution' -ForegroundColor Yellow
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Powershell Gallery' -ForegroundColor Yellow
	$null = Install-PackageProvider Nuget -Force
	$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
	$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Needed Powershell modules' -ForegroundColor Yellow
	Install-Module ImportExcel, PSWriteHTML, PSWriteColor, PSScriptTools, PoshRegistry, Microsoft.PowerShell.Archive -Scope AllUsers

	#Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-PSToolKit.ps1'))
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://community.chocolatey.org/install.ps1', "$($env:TEMP)\choco-install.ps1")
	& "$($env:TEMP)\choco-install.ps1"

	Update-PSToolKit -AllUsers

	Import-Module PSToolKit -Force
	New-PSProfile
	Start-PSProfile
	if ($LabSetup) {
		Set-PSToolKitSystemSettings -RunAll
        Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule
		Install-PSModules -BaseModules
		Install-PS7
		Install-ChocolateyClient
		Install-ChocolateyApps -BaseApps
	}
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Installing Other Modules' -ForegroundColor Yellow
		Install-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
	}
} #end Function