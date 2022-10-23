
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

.PARAMETER PendingReboot
Will reboot the device if it is needed.

.PARAMETER InstallMyModules
Install my other published modules.

.PARAMETER GitHubToken
Token used to install modules and apps.

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[Parameter(Mandatory, Position = 0)]
		[string]$GitHubToken,
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false,
		[switch]$PendingReboot = $false
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	#region ExecutionPolicy
	if ((Get-ExecutionPolicy) -notlike 'Unrestricted') {
		try {
			Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline
			Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process -ErrorAction Stop
			Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser -ErrorAction Stop
			Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope LocalMachine -ErrorAction Stop
			Write-Host ' Complete' -ForegroundColor Green
		} catch {Write-Warning "Error Setting ExecutionPolicy: Message:$($Error[0])"}
	} else {Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline; Write-Host ' Already Set' -ForegroundColor Red}
	#endregion

	#region PSRepo
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted' ) {
		try {
			Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell Gallery:' -ForegroundColor Cyan -NoNewline
			$null = Install-PackageProvider Nuget -Force
			$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
			$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
			Write-Host ' Complete' -ForegroundColor Green
		} catch {Write-Warning "Error Setting PSRepository: Message:$($Error[0])"}
	} else {Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell Gallery:' -ForegroundColor Cyan -NoNewline; Write-Host ' Already Set' -ForegroundColor Red}
	#endregion

	#region PackageManager
	Start-Job -ScriptBlock {
		$PowerShellGet = Get-Module 'PowerShellGet' -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

		if ($PowerShellGet.Version -lt [version]'2.2.5') {
			Write-Host "`t[Updating]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan
			$installOptions = @{
				Repository = 'PSGallery'
				Force      = $true
				Scope      = 'AllUsers'
			}							
			try {
				Install-Module -Name PackageManagement @installOptions
				Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host 'Complete' -ForegroundColor Green
			} catch {Write-Warning "Error installing PackageManagement: Message:$($Error[0])"}
			try {
				Install-Module -Name PowerShellGet @installOptions
				Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShellGet' -ForegroundColor Cyan -NoNewline; Write-Host 'Complete' -ForegroundColor Green
			} catch {Write-Warning "Error installing PowerShellGet: Message:$($Error[0])"}
		} else {
			Write-Host "`t[Update]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Not Needed' -ForegroundColor Red
		}
	} | Wait-Job | Receive-Job		
	#endregion

	#region Needed Modules
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Needed PowerShell Modules`n" -ForegroundColor Cyan
	'ImportExcel', 'PSWriteHTML', 'PSWriteColor', 'PSScriptTools', 'PoshRegistry', 'Microsoft.PowerShell.Archive', 'PWSHModule', 'PSPackageMan' | ForEach-Object {		
		$module = $_
		if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
			try {
				Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module):" -ForegroundColor Cyan -NoNewline
				Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
				Write-Host ' Complete' -ForegroundColor Green
			} catch {Write-Warning "Error installing module $($module): Message:$($Error[0])"}
		} else {
			Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module):" -ForegroundColor Cyan -NoNewline; Write-Host ' Already Installed' -ForegroundColor Red
		}
	}
	#endregion

	#region PStoolkit
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "PSToolKit Module`n" -ForegroundColor Cyan
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-MyModulesFromGitHub.ps1', "$($env:TEMP)\Update-MyModulesFromGitHub.ps1")
	$full = Get-Item "$($env:TEMP)\Update-MyModulesFromGitHub.ps1"
	Import-Module $full.FullName -Force
	Update-MyModulesFromGitHub -Modules PSToolkit -AllUsers
	Remove-Item $full.FullName
	Import-Module PSToolKit -Force
	#endregion

	#region MyModules
	if ($InstallMyModules) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "My Modules`n" -ForegroundColor Cyan
		Write-Host "`t[Collecting] " -NoNewline -ForegroundColor Cyan; Write-Host "Module Details from PS Gallery`n" -ForegroundColor Cyan 
		Find-Module -Repository PSGallery | Where-Object {$_.author -like 'Pierre Smit'} | ForEach-Object {
			$module = $_
			Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name)" -ForegroundColor Cyan
			if (-not(Get-Module $module.name) -and -not(Get-Module $module.name -ListAvailable)) {
				try {
					Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name):" -ForegroundColor Cyan -NoNewline
					Install-Module -Name $module.name -Scope AllUsers -AllowClobber -ErrorAction stop
					Write-Host ' Complete' -ForegroundColor Green
				} catch {Write-Warning "Error installing module $($module.name):  Message:$($Error[0])"}
			} else {
				$LocalMod = Get-Module $module.name -ListAvailable | Sort-Object -Property Version | Select-Object -First 1
				if (($LocalMod[0].Version) -lt $module.Version) {
					try {
						Write-Host "`t[Upgrading]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name):" -ForegroundColor Cyan -NoNewline
						Update-Module -Name $module.name -Scope AllUsers -Force
						Write-Host ' Complete' -ForegroundColor Green
					} catch {Write-Warning "Error installing module $($module.name):  Message:$($Error[0])"}
				} else {Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name):" -ForegroundColor Cyan -NoNewline; Write-Host ' Already Installed' -ForegroundColor Red}
			}
		}
	}
	#endregion

	#region Lab Setup
	if ($LabSetup) {
		Write-Host "`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "System Settings`n" -ForegroundColor Cyan
		Set-PSToolKitSystemSetting -RunAll

		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "New PS Profile`n" -ForegroundColor Cyan
		New-PSProfile

		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Base Modules`n" -ForegroundColor Cyan
		Install-PWSHModule -GitHubUserID smitpi -GitHubToken $GitHubToken -ListName BaseModules -Scope AllUsers

		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
		Install-ChocolateyClient

		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
		Install-VMWareTool

		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Base Apps`n" -ForegroundColor Cyan
		Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID smitpi -GitHubToken $GitHubToken
		
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "RSAT`n" -ForegroundColor Cyan
		Install-RSAT
	}
	#endregion

	#region Pending Reboot
	if ($PendingReboot) {
		Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Pending Reboot for $($env:COMPUTERNAME)" -ForegroundColor Cyan
		if ((Test-PendingReboot -ComputerName $env:COMPUTERNAME).IsPendingReboot -like 'True') {
			Write-Host "`t[Reboot Needed]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Rebooting in 60 sec' -ForegroundColor DarkRed
			Start-Sleep 60
			Restart-Computer -Force
		} else {
			Write-Host '[Reboot]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Not Necessary, continuing' -ForegroundColor Cyan
		}
	}
	#endregion

	Write-Host '[Complete] ' -NoNewline -ForegroundColor Yellow; Write-Host 'System Initialization' -ForegroundColor DarkRed
} #end Function
