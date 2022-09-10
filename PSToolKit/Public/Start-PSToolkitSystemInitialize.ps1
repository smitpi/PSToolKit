
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

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false,
		[switch]$PendingReboot = $false
	)

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
	Start-Job -ScriptBlock {
		$PowerShellGet = Get-Module 'PowerShellGet' -ListAvailable | 
			Sort-Object Version -Descending | 
				Select-Object -First 1

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
					} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
					try {
						Install-Module -Name PowerShellGet @installOptions
						Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShellGet' -ForegroundColor Cyan -NoNewline; Write-Host 'Complete' -ForegroundColor Green
					} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
				} else {
					Write-Host "`t[Update]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Not Needed' -ForegroundColor Red
				}
			} | Wait-Job | Receive-Job

	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Needed Powershell modules' -ForegroundColor Cyan

	'ImportExcel', 'PSWriteHTML', 'PSWriteColor', 'PSScriptTools', 'PoshRegistry', 'Microsoft.PowerShell.Archive','PWSHModule','PSPackageMan' | ForEach-Object {		
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
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-MyModulesFromGitHub.ps1', "$($env:TEMP)\Update-MyModulesFromGitHub.ps1")
	$full = Get-Item "$($env:TEMP)\Update-MyModulesFromGitHub.ps1"
	Import-Module $full.FullName -Force
	Update-MyModulesFromGitHub -Modules PSToolkit -AllUsers
	Remove-Item $full.FullName

	Import-Module PSToolKit -Force
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Installing My Modules' -ForegroundColor Cyan
		Find-Module -Repository PSGallery | Where-Object {$_.author -like 'Pierre Smit'} | ForEach-Object {
			$module = $_
			Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name)" -ForegroundColor Cyan
			if (-not(Get-Module $module.name) -and -not(Get-Module $module.name -ListAvailable)) {
				try {
					Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name)" -ForegroundColor Cyan
					Install-Module -Name $module.name -Scope AllUsers -AllowClobber -ErrorAction stop
				} catch {Write-Warning "Error installing module $($module.name): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
			} else {
				$LocalMod = Get-Module $module.name
				if (-not($LocalMod)) {$LocalMod = Get-Module $module.name -ListAvailable}
				if (($LocalMod[0].Version) -lt $module.Version) {
					try {
						Write-Host "`t`t[Upgrading]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module.name)" -ForegroundColor Cyan
						Update-Module -Name $module.name -Scope AllUsers -Force
					} catch {Write-Warning "Error installing module $($module.name): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
				}
			}
		}
	}

	if ($LabSetup) {
		New-PSProfile
		Set-PSToolKitSystemSetting -RunAll
		Install-PWSHModule -GitHubUserID smitpi -PublicGist -ListName base -Scope AllUsers
		Install-ChocolateyClient
		Install-VMWareTool
		Install-PowerShell7x
		Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID smitpi -PublicGist
		Install-RSAT
		Install-MSUpdate
	}

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

	Write-Host '[Complete] ' -NoNewline -ForegroundColor Yellow; Write-Host 'System Initialization' -ForegroundColor DarkRed
} #end Function
