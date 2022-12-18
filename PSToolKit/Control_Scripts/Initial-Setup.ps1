# Boxstarter options
$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot

#. { Invoke-WebRequest https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force

try {
	$message = @"
  _    _ _______ _____   _____ ______           ____              _       _                   
 | |  | |__   __|  __ \ / ____|___  /   /\     |  _ \            | |     | |                  
 | |__| |  | |  | |__) | |       / /   /  \    | |_) | ___   ___ | |_ ___| |_ _ __ __ _ _ __  
 |  __  |  | |  |  ___/| |      / /   / /\ \   |  _ < / _ \ / _ \| __/ __| __| '__/ _` | '_ \ 
 | |  | |  | |  | |    | |____ / /__ / ____ \  | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) |
 |_|  |_|  |_|  |_|     \_____/_____/_/    \_\ |____/ \___/ \___/ \__|___/\__|_|  \__,_| .__/ 
                                                                                       | |    
                                                                                       |_|    
"@
	Write-Host $message -ForegroundColor Yellow
	Disable-UAC
	$VerbosePreference = 'SilentlyContinue'
} catch {Write-Warning "Error: Message:$($Error[0])"}

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Starting]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Bootstrap Script`n" -ForegroundColor Cyan

$PSTemp = "$env:TEMP\PSTemp"
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Configuring]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Answer File`n" -ForegroundColor Cyan

$AnswerFile = "$($PSDownload.FullName)\AnswerFile.json"
if (-not(Test-Path $AnswerFile)) {

	$output = [PSCustomObject]@{
		DomainName        = 'None'
		DomainUser        = 'None'
		DomainPassword    = 'None'
		NewHostName       = 'None'
		GitHubToken       = 'None'
		GitHubUserID      = 'None'
		InstallAllModules = $false
		InstallAllApps    = $false
	}
	$output | ConvertTo-Json | Out-File -FilePath $AnswerFile -Force
}
Start-Process -FilePath notepad.exe -ArgumentList $AnswerFile -Wait
$AnswerFileImport = (Get-Content $AnswerFile | ConvertFrom-Json) 

foreach ($item in ($AnswerFileImport | Get-Member -MemberType noteProperty)) {
	New-Variable -Name $item.Name -Value $AnswerFileImport.$($item.Name) -Force -Scope Global
}


If (!(Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain) {
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Adding]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($NewHostName) to Domain`n" -ForegroundColor Cyan
	Write-Host -ForegroundColor Red 'This machine is not part of a domain. Adding now.'
	$encSecret = $DomainPassword | ConvertTo-SecureString -Force -AsPlainText
	$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, $encSecret)
    
	Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $NewHostName
	Start-Sleep 5
	Add-Computer -DomainName $DomainName -Credential $labcred -Options JoinWithNewName, AccountCreate -Force -Restart
}

if (Test-Path "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1") {Remove-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1" -Force}
$web = New-Object System.Net.WebClient
$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
Import-Module $full.FullName -Force
Start-PSToolkitSystemInitialize -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken -LabSetup -InstallMyModules
Remove-Item $full.FullName

if (-not(Test-Path "$($PSDownload.fullname)\BaseApps.tmp")) {
	try {
		Get-Service WinRM | Start-Service -Verbose
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Base Apps`n" -ForegroundColor Cyan
		Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
		if (Test-PendingReboot -ComputerName $env:COMPUTERNAME) {
			if (-not(Test-Path "$($PSDownload.fullname)\1stReboot.tmp")) {
				New-Item "$($PSDownload.fullname)\1stReboot.tmp" -ItemType file -Force | Out-Null
				Invoke-Reboot
			}		
		} else {Write-Host 'Not Required' -ForegroundColor Green}
		Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
		New-Item "$($PSDownload.fullname)\LabSetup.tmp" -ItemType file -Force | Out-Null
	} catch {Write-Warning "Error: Message:$($Error[0])"}
}


if ($InstallAllModules) {
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Extended Modules`n" -ForegroundColor Cyan
	Install-PWSHModule -ListName BaseModules, ExtendedModules, MyModules -Scope AllUsers -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
}

if ($InstallAllApps) {
	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Extended Apps`n" -ForegroundColor Cyan
	Install-PSPackageManAppFromList -ListName BaseApps, ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
}

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Windows Updates`n" -ForegroundColor Cyan

Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
if (Test-PendingReboot -ComputerName $env:COMPUTERNAME) {Invoke-Reboot}
else {Write-Host 'Not Required' -ForegroundColor Green}
Install-MSUpdate



