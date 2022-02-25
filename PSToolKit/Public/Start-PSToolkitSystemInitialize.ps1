
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

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder"
	if ((Test-Path C:\Temp) -eq $false ) { New-Item -ItemType Directory -Path C:\Temp -Force }
	if ((Test-Path C:\Temp\private.zip) -eq $true ) { Remove-Item C:\Temp\private.zip -Force }

	if ((Test-Path (Join-Path $psfolder.FullName '\Modules\PSToolKit')) -eq $true ) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder"
		Compress-Archive (Join-Path $psfolder.FullName '\Modules\PSToolKit') (Join-Path $psfolder.FullName "\Modules\$(Get-Date -Format yyyy-MM-dd)_PSToolKit.zip") -Force
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder"
		Remove-Item (Join-Path $psfolder.FullName '\Modules\PSToolKit') -Recurse -Force
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
	Invoke-WebRequest -Uri https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master -OutFile C:\Temp\private.zip
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
	Expand-Archive C:\Temp\private.zip C:\Temp
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] rename folder"
	$newfolder = New-Item -Path	(Join-Path $psfolder.FullName '\Modules') -Name PSToolKit -ItemType Directory -Force
	Copy-Item -Path C:\Temp\PSToolKit-master\Output\* -Destination $newfolder.FullName -Recurse
	Remove-Item C:\Temp\private.zip
	Remove-Item C:\Temp\PSToolKit-master -Recurse

	Import-Module PSToolKit -Force
	New-PSProfile
	Start-PSProfile
	if ($LabSetup) {
		Set-PSToolKitSystemSettings -RunAll
		Set-PSToolKitConfigFiles -Source Module
		Install-PSModules -BaseModules
		Install-ChocolateyClient
		Install-ChocolateyApps -BaseApps
	}
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Installing Other Modules' -ForegroundColor Yellow
		Install-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
	}
} #end Function
