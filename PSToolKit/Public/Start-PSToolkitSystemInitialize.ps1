
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

.PARAMETER GitHubUserID
UserID used to install modules and apps.

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[Parameter(Position = 0)]
		[string]$GitHubUserID,
		[Parameter(Position = 1)]
		[string]$GitHubToken,
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false,
		[switch]$PendingReboot = $false
	)

	#Find-Module -Repository PSGallery | Where-Object {$_.author -like 'Pierre Smit'} 
    $MyModules = @( "CTXCloudApi",
                    "PSLauncher",
                    "PSConfigFile",
                    "XDHealthCheck",
                    "PSSysTray",
                    "PWSHModule",
                    "PSPackageMan")

    $RequiredModules = @('ImportExcel', 
                         'PSWriteHTML', 
                         'PSWriteColor', 
                         'PSScriptTools', 
                         'PoshRegistry', 
                         'Microsoft.PowerShell.Archive', 
                         'PWSHModule', 
                         'PSPackageMan')


	$PSTemp = 'C:\Temp\PSTemp'
	if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
	else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

	Write-Host "`n`n[Utilizing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Temp Directory:' -ForegroundColor Cyan -NoNewline; Write-Host " $($PSDownload.FullName)" -ForegroundColor Green
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	#region ExecutionPolicy
	if (-not(Test-Path "$($PSDownload.fullname)\ExecutionPolicy.tmp")) {
		if ((Get-ExecutionPolicy) -notlike 'Unrestricted') {
			try {
				Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline
				Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process -ErrorAction Stop
				Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser -ErrorAction Stop
				Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope LocalMachine -ErrorAction Stop
				Write-Host ' Complete' -ForegroundColor Green
			} catch {Write-Warning "Error Setting ExecutionPolicy: Message:$($Error[0])"}
		} else {Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline; Write-Host ' Already Set' -ForegroundColor Red}
		New-Item "$($PSDownload.fullname)\ExecutionPolicy.tmp" -ItemType file -Force | Out-Null
	}
	#endregion

	#region PSRepo
	if (-not(Test-Path "$($PSDownload.fullname)\PSRepo.tmp")) {
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
					Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Complete' -ForegroundColor Green
				} catch {Write-Warning "Error installing PackageManagement: Message:$($Error[0])"}
				try {
					Install-Module -Name PowerShellGet @installOptions
					Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShellGet' -ForegroundColor Cyan -NoNewline; Write-Host ' Complete' -ForegroundColor Green
				} catch {Write-Warning "Error installing PowerShellGet: Message:$($Error[0])"}
			} else {
				Write-Host "`t[Update]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Not Needed' -ForegroundColor Red
			}
		} | Wait-Job | Receive-Job		
		New-Item "$($PSDownload.fullname)\PSRepo.tmp" -ItemType file -Force | Out-Null
	}
	#endregion

	#region Boxstarter Install
	if (-not(Test-Path "$($PSDownload.fullname)\BoxstarterShell.tmp")) {
		if (-not(Get-Command BoxstarterShell.ps1 -ErrorAction SilentlyContinue)) {
			Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Boxstarter:' -ForegroundColor Cyan
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')) 
			Get-Boxstarter -Force
		}
		New-Item "$($PSDownload.fullname)\BoxstarterShell.tmp" -ItemType file -Force | Out-Null
	}
	#endregion

	#region Needed Modules
	if (-not(Test-Path "$($PSDownload.fullname)\NeededModules.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Needed PowerShell Modules`n" -ForegroundColor Cyan
		$RequiredModules | ForEach-Object {		
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
		New-Item "$($PSDownload.fullname)\NeededModules.tmp" -ItemType file -Force | Out-Null
	}
	#endregion

	#region PStoolkit
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "PSToolKit Module`n" -ForegroundColor Cyan
	if (Test-Path "$($PSDownload.fullname)\Update-MyModulesFromGitHub.ps1") {Remove-Item "$($PSDownload.fullname)\Update-MyModulesFromGitHub.ps1" -Force | Out-Null}
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-MyModulesFromGitHub.ps1', "$($PSDownload.fullname)\Update-MyModulesFromGitHub.ps1")
	$full = Get-Item "$($PSDownload.fullname)\Update-MyModulesFromGitHub.ps1"
	Import-Module $full.FullName -Force
	Update-MyModulesFromGitHub -Modules PSToolkit -AllUsers
	Import-Module PSToolKit -Force
	#endregion

	#region MyModules
	if ($InstallMyModules) {
		if (-not(Test-Path "$($PSDownload.fullname)\InstallMyModules.tmp")) {
			Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "My Modules`n" -ForegroundColor Cyan
			Write-Host "`t[Collecting] " -NoNewline -ForegroundColor Cyan; Write-Host "Module Details from PS Gallery`n" -ForegroundColor Cyan 
			 $MyModules | ForEach-Object {
				$module = Find-Module -Repository PSGallery -Name $_
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
		New-Item "$($PSDownload.fullname)\InstallMyModules.tmp" -ItemType file -Force | Out-Null
	}
	#endregion

	#region Lab Setup
	if ($LabSetup) {
		if (-not(Test-Path "$($PSDownload.fullname)\LabSetup.tmp")) {
			Write-Host "`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "System Settings`n" -ForegroundColor Cyan 
			Set-PSToolKitSystemSetting -RunAll
			#Set-PSToolKitSystemSetting -IntranetZone -IntranetZoneIPRange -SetPhotoViewer -DisableIPV6 -DisableInternetExplorerESC -DisableServerManager -EnableRDP -FileExplorerSettings -RemoveDefaultApps -SystemDefaults

			Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "New PS Profile`n" -ForegroundColor Cyan
			New-PSProfile

			if (-not([string]::IsNullOrEmpty($GitHubUserID))) {
				Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Base Modules`n" -ForegroundColor Cyan
				Install-PWSHModule -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken -ListName BaseModules -Scope AllUsers
			}
			Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
			Install-ChocolateyClient

			Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
			Install-VMWareTool
		
			Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "RSAT`n" -ForegroundColor Cyan
			Install-RSAT
			New-Item "$($PSDownload.fullname)\LabSetup.tmp" -ItemType file -Force | Out-Null
		}
	}
	#endregion

	#region Pending Reboot
	if ($PendingReboot) {
		Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Pending Reboot for $($env:COMPUTERNAME)" -ForegroundColor Cyan
		if ((Test-PSPendingReboot -ComputerName $env:COMPUTERNAME).IsPendingReboot -like 'True') {
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
