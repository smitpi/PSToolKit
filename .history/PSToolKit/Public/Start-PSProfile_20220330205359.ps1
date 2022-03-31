
<#PSScriptInfo

.VERSION 0.1.0

.GUID f5d16500-7386-43c0-a680-d005f1f6341c

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS PS

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
My PS Profile for all sessions.

.DESCRIPTION
My PS Profile for all sessions.

.PARAMETER ClearHost
Clear the screen before loading.

.PARAMETER AddFun
Add fun details in the output.

.PARAMETER GalleryStats
Stats about my published modules..

.PARAMETER ShowModuleList
Summary of installed modules.

.PARAMETER ShortenPrompt
Shorten the command prompt for more coding space.

.EXAMPLE
Start-PSProfile -ClearHost

#>
Function Start-PSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSProfile')]
	PARAM(
		[switch]$ClearHost = $false,
		[switch]$AddFun = $false,
		[switch]$GalleryStats = $false,
		[switch]$ShowModuleList = $false,
		[switch]$ShortenPrompt = $false
	)
	<##>
	$ErrorActionPreference = 'Stop'

	if ($ClearHost) { Clear-Host }

	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$psfolder = (Get-Item $profile).DirectoryName
	} else { $psfolder = (Get-Item $profile).DirectoryName }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	try {
		## Create folders for PowerShell profile
		if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory | Out-Null }
	} catch { Write-Warning 'Unable to create default folders' }

	try {
		$ProdModules = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\PowerShell\ProdModules)
		if (Test-Path $ProdModules) {
			Set-Location $ProdModules
		} else {
			$ScriptFolder = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\WindowsPowerShell\Scripts) | Get-Item
			Set-Location $ScriptFolder
		}
	} catch { Write-Warning 'Unable to set location' }

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,23} ' -f 'Loading Functions') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	try {
    $PSReadLineSplat=@{
        PredictionSource               = 'HistoryAndPlugin'
        PredictionViewStyle            = 'ListView'
        HistorySearchCursorMovesToEnd  = $true
        HistorySaveStyle               = 'SaveIncrementally'
        ShowToolTips                   = $true
        BellStyle                      = "Visual"
        HistorySavePath                = "$([environment]::GetFolderPath('ApplicationData'))\Microsoft\Windows\PowerShell\PSReadLine\history.txt"
    }

		Set-PSReadLineOption @PSReadLineSplat
		Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'PSReadLineOptions: Could not be loaded' }

	try {
		$chocofunctions = Get-Item "$env:ChocolateyInstall\helpers\functions" -ErrorAction Stop
		$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
		Import-Module "$ChocolateyProfile" -ErrorAction Stop
		Get-ChildItem $chocofunctions | ForEach-Object { . $_.FullName }
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Chocolatey Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-21}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'Chocolatey: Could not be loaded' }

 try {
		Add-PSSnapin citrix*
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Citrix SnapIns') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'Citrix SnapIns: Could not be loaded' }
 if ($AddFun) {
	 try {
			$chuck = (Invoke-RestMethod -Uri https://api.chucknorris.io/jokes/random?category=dev).value
			Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'Chuck Detail') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'Chuck gave up...' }

		try {
			$weather = Invoke-RestMethod 'https://weatherdbi.herokuapp.com/data/weather/Johannesburg'
			Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'Weather') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'Error on weather' }
	}

	$ErrorActionPreference = 'Continue'
	## Some Session Information
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,20} ' -f 'PowerShell Info') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'Computer Name') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($env:COMPUTERNAME) ($(([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName))") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Execution Policy') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$(Get-ExecutionPolicy -Scope LocalMachine)") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Edition') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($PSVersionTable.PSEdition) (Ver: $($PSVersionTable.PSVersion.ToString()))") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Profile Folder') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($psfolder)") -ForegroundColor Green

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,20} ' -f 'Session Detail') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'For User:') -ForegroundColor Cyan -NoNewline
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
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,25} ' -f 'Module Paths Details') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "$(($ModuleDetails | Sort-Object -Property modules -Descending | Out-String))" -ForegroundColor Green
	}

	if ($AddFun) {
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'Fun Stuff') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,-35}: ' -f 'Current weather') -ForegroundColor Cyan -NoNewline
		Write-Host (' {0,-20} ' -f "$($weather.currentConditions.comment) | Temperature:$($weather.currentConditions.temp.c)°C | Wind:$($weather.currentConditions.wind.km)km/h |") -ForegroundColor Green
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,-35}: ' -f 'Chuck Noris in Dev:') -ForegroundColor Cyan -NoNewline
		Write-Host (' {0,-20} ' -f "$($chuck)") -ForegroundColor Green
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
 }

 if ($GalleryStats) {
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'My PSGallery Stats') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "$((Get-MyPSGalleryStats -Display TableView) | Out-String)" -ForegroundColor Green
 }

	if ($ShortenPrompt) {
		Function prompt {
			$location = $executionContext.SessionState.Path.CurrentLocation.path
			#what is the maximum length of the path before you begin truncating?
			$len = 10

			if ($location.length -gt $len) {

				#split on the path delimiter which might be different on non-Windows platforms
				$dsc = [system.io.path]::DirectorySeparatorChar
				#escape the separator character to treat it as a literal
				#filter out any blank entries which might happen if the path ends with the delimiter
				$split = $location -split "\$($dsc)" | Where-Object { $_ -match '\S+' }
				#reconstruct a shorted path
				$here = "{0}$dsc{1}...$dsc{2}" -f $split[0], $split[1], $split[-1]

			} else {
				#length is ok so use the current location
				$here = $location
			}

			"PS $here$('>' * ($nestedPromptLevel + 1)) "
			# .Link
			# https://go.microsoft.com/fwlink/?LinkID=225750
			# .ExternalHelp System.Management.Automation.dll-help.xml

		}
	}

} #end Function
