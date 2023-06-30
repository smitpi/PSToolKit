
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


.EXAMPLE
Start-PSProfile -ClearHost

#>
Function Start-PSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSProfile')]
	PARAM(
		[switch]$ClearHost = $false
	)
	
	$ErrorActionPreference = 'Stop'
	if ($ClearHost) { Clear-Host }
	#region Create Folder
	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$Global:psfolder = Get-Item (Get-Item $profile).DirectoryName
	} else { $Global:psfolder = Get-Item (Get-Item $profile).DirectoryName }
	#endregion

	#region Add Extra Folders
	try {
		## Create folders for PowerShell profile
		if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory | Out-Null }
	} catch { Write-Warning 'Unable to create default folders' }

	try {
		Set-Location $psfolder -ErrorAction Stop
	} catch { Write-Warning 'Unable to set location' }
	#endregion
	
	#region Loading Functions
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,23} ' -f 'Loading Functions') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	#region PSReadLine
	try {
		$PSReadLineSplat = @{
			PredictionSource              = 'HistoryAndPlugin'
			PredictionViewStyle           = 'InlineView'
			HistorySearchCursorMovesToEnd = $true
			HistorySaveStyle              = 'SaveIncrementally'
			ShowToolTips                  = $true
			BellStyle                     = 'Visual'
			HistorySavePath               = "$([environment]::GetFolderPath('ApplicationData'))\Microsoft\Windows\PowerShell\PSReadLine\history.txt"
		}
		Set-PSReadLineOption @PSReadLineSplat -ErrorAction Stop
		Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine
		Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch {
		try {
			Set-PSReadLineOption @PSReadLineSplat -PredictionSource history -PredictionViewStyle InlineView
			Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine
			Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
			Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
			Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
			Write-Host ('[Alternative]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'PSReadLineOptions: Could not be loaded' }
	}
	#endregion
	#region Chocolatey
	try {
		$chocofunctions = Get-Item "$env:ChocolateyInstall\helpers\functions" -ErrorAction Stop
		$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
		Import-Module "$ChocolateyProfile" -ErrorAction Stop
		Get-ChildItem $chocofunctions | ForEach-Object { . $_.FullName }
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Chocolatey Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-21}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'Chocolatey: Could not be loaded' }
	#endregion
	#region PStyle
	if ($PSVersionTable.PSEdition -like 'Desktop') {
		if (!(Get-Module 'PSStyle') -and !(Get-Module 'PSStyle' -ListAvailable)) {
			try {
				Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
				Write-Host (' {0,-36}: ' -f 'PSStyle Module') -ForegroundColor Cyan -NoNewline
				Import-Module PSStyle -Force
				Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
			} catch {Write-Warning 'PSStyle Module: Could not be loaded'}
		} else {
			Write-Warning 'PSStyle Module: Not Installed'
		}
	}

	#endregion
	#region Proxy Connect
	function Connect-Proxy {
		try {
			$wc = New-Object System.Net.WebClient
			$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		} catch { Write-Warning 'Proxy Connection: Could not be loaded' }
	}
	Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
	Write-Host (' {0,-36}: ' -f 'Proxy Connection') -ForegroundColor Cyan -NoNewline
	Connect-Proxy
	Write-Host ('{0,-21}' -f 'Complete') -ForegroundColor Green
	#endregion
	#endregion


#region Session Info
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
#endregion

#region Update help
	if ($(Get-Date).DayOfWeek -like 'Monday') {
		$Localhelpjob = Update-LocalHelp
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'Updating Local Help, For details Run:') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "`$Localhelpjob | Wait-Job | Receive-Job" -ForegroundColor Green
	}
#endregion

} #end Function
