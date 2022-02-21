
<#PSScriptInfo

.VERSION 0.1.0

.GUID f5d16500-7386-43c0-a680-d005f1f6341c

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
 The PS Profile I use on client sites

#>


<#
.SYNOPSIS
The PS Profile I use on client sites

.DESCRIPTION
The PS Profile I use on client sites

.PARAMETER ClearHost
Clear the screen before it loads

.PARAMETER ShowModuleList
Show the module list and count of modules.

.EXAMPLE
Start-PSProfile -ClearHost

#>
Function Start-PSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSProfile')]
	PARAM(
		[switch]$ClearHost = $false,
		[switch]$ShowModuleList = $false
	)

	$ErrorActionPreference = 'Stop'

	if ($ClearHost) { Clear-Host }

	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$psfolder = (Get-Item $profile).DirectoryName
	}
	else { $psfolder = (Get-Item $profile).DirectoryName }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	## Some Session Information
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,20} ' -f 'Session Info') -ForegroundColor DarkCyan
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
    
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'Computer Name') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($env:COMPUTERNAME) ($(([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName))") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline    
	Write-Host (' {0,-35}: ' -f 'PowerShell Execution Policy') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$(Get-ExecutionPolicy -Scope LocalMachine)") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Profile Folder') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($psfolder)") -ForegroundColor Green


	try {
		## Create folders for PowerShell profile
		if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory | Out-Null }
	}
 catch { Write-Warning 'Unable to create default folders' }

	try {
		$ProdModules = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\PowerShell\ProdModules)
		if (Test-Path $ProdModules) {
			Set-Location $ProdModules
		}
		else {
			$ScriptFolder = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\WindowsPowerShell\Scripts) | Get-Item
			Set-Location $ScriptFolder
		}
	}
 catch { Write-Warning 'Unable to set location' }

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,25} ' -f 'Loading Functions') -ForegroundColor DarkCyan
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	try {
		Set-PSReadLineOption -PredictionSource History -HistorySearchCursorMovesToEnd -ShowToolTips -BellStyle Visual -HistorySavePath "$([environment]::GetFolderPath('ApplicationData'))\Microsoft\Windows\PowerShell\PSReadLine\history.txt"
		Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	}
 catch { Write-Warning 'PSReadLineOptions: Could not be loaded' }

	try {
		$chocofunctions = Get-Item "$env:ChocolateyInstall\helpers\functions" -ErrorAction Stop
		$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
		Import-Module "$ChocolateyProfile" -ErrorAction Stop
		Get-ChildItem $chocofunctions | ForEach-Object { . $_.FullName }
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Chocolatey Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-21}' -f 'Complete') -ForegroundColor Green
	}
 catch { Write-Warning 'Chocolatey: Could not be loaded' }
 
 	try {
		Add-PSSnapin citrix*
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Citrix SnapIns') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	}
 catch { Write-Warning 'Citrix SnapIns: Could not be loaded' }

	$ErrorActionPreference = 'Continue'
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'Starting Session for') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($env:USERDOMAIN)\$($env:USERNAME) ($($env:USERNAME)@$($env:USERDNSDOMAIN))") -ForegroundColor Green
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ' '


	if ($ShowModuleList) {
		[string[]]$Modpaths = ($env:PSModulePath).Split(';')
		$AvailableModules = Get-Module -ListAvailable
		[System.Collections.ArrayList]$ModuleDetails = @()
		$ModuleDetails = $Modpaths | ForEach-Object {
			$Mpath = $_
			[pscustomobject]@{
				Location = $Mpath
				Modules  = ($AvailableModules | Where-Object { $_.path -match $Mpath.replace('\', '\\') } ).count
			}
		} 
		Write-Host '----------------------------' -ForegroundColor DarkGray
		Write-Host "`tList of Module Paths:" -ForegroundColor yellow
		Write-Host '----------------------------' -ForegroundColor DarkGray
		$ModuleDetails | Sort-Object -Property modules -Descending
	} 
} #end Function