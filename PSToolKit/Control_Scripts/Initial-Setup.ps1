
if (-not(Get-Command BoxstarterShell.ps1 -ErrorAction SilentlyContinue)) {
	Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ;iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'));Get-Boxstarter -Force})" -Wait -WorkingDirectory C:\Temp\PSTemp 
}


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

$PSTemp = 'C:\Temp\PSTemp'
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Configuring]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Answer File`n" -ForegroundColor Cyan

$AnswerFile = "$($PSDownload.FullName)\AnswerFile.json"
if (-not(Test-Path $AnswerFile)) {

	$output = [PSCustomObject]@{
		AddToDomain         = $false
		DomainName          = 'None'
		DomainUser          = 'None'
		DomainPassword      = 'None'
		NewHostName         = 'None'
		GitHubToken         = 'None'
		GitHubUserID        = 'None'
		InstallAllModules   = $false
		InstallAllApps      = $false
		InstallLicensedApps = $false
	}
	$output | ConvertTo-Json | Out-File -FilePath $AnswerFile -Force
Start-Process -FilePath notepad.exe -ArgumentList $AnswerFile -Wait
}
$AnswerFileImport = (Get-Content $AnswerFile | ConvertFrom-Json) 

foreach ($item in ($AnswerFileImport | Get-Member -MemberType noteProperty)) {
	New-Variable -Name $item.Name -Value $AnswerFileImport.$($item.Name) -Force -Scope Global
}

if ($AddToDomain) {
	If (!(Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Adding]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($NewHostName) to Domain`n" -ForegroundColor Cyan
		Write-Host -ForegroundColor Red 'This machine is not part of a domain. Adding now.'
		$encSecret = $DomainPassword | ConvertTo-SecureString -Force -AsPlainText
		$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, $encSecret)
    
		# Boxstarter options
		$Boxstarter.RebootOk = $false # Allow reboots?
		$Boxstarter.NoPassword = $false # Is this a machine with no login password?
		$Boxstarter.AutoLogin = $false # Save my password securely and auto-login after a reboot

		Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $NewHostName
		Start-Sleep 5
		Add-Computer -DomainName $DomainName -Credential $labcred -Options JoinWithNewName, AccountCreate -Force -Restart
	}
}

if (Test-Path "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1") {Remove-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1" -Force}
$web = New-Object System.Net.WebClient
$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
try {
	Import-Module $full.FullName -Force

    if ($GitHubUserID -like "None") {Start-PSToolkitSystemInitialize -LabSetup -InstallMyModules}
    else {Start-PSToolkitSystemInitialize -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken -LabSetup -InstallMyModules}

	Remove-Item $full.FullName
} catch {Write-Warning "Error: Message:$($Error[0])"}


if (-not(Test-Path "$($PSDownload.fullname)\BaseApps.tmp") -and ($GitHubUserID -notlike "None")) {
	try {
		refreshenv
		Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
		if (Test-PendingReboot) {Invoke-Reboot} 
		else {Write-Host 'Not Required' -ForegroundColor Green}
		
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Base Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 

		New-Item "$($PSDownload.fullname)\BaseApps.tmp" -ItemType file -Force | Out-Null
	} catch {Write-Warning "Error: Message:$($Error[0])"}
}


if ($InstallAllModules  -and ($GitHubUserID -notlike "None")) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedModules.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Modules' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PWSHModule -ListName BaseModules, ExtendedModules, MyModules -Scope AllUsers -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 
		New-Item "$($PSDownload.fullname)\ExtendedModules.tmp" -ItemType file -Force | Out-Null
	}
}

if ($InstallAllApps  -and ($GitHubUserID -notlike "None")) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedApps.tmp")) {
		refreshenv
		Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
		if (Test-PendingReboot) {Invoke-Reboot} 
		else {Write-Host 'Not Required' -ForegroundColor Green}
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName BaseApps, ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 
		
        Remove-Item -Path "$([Environment]::GetFolderPath('Desktop'))\*.lnk" -ErrorAction SilentlyContinue
        Remove-Item -Path "$($env:PUBLIC)\Desktop\*.lnk" -ErrorAction SilentlyContinue

New-Item "$($PSDownload.fullname)\ExtendedApps.tmp" -ItemType file -Force | Out-Null
	}
}

if ($InstallLicensedApps -and ($GitHubUserID -notlike "None")) {
	if (-not(Test-Path "$($PSDownload.fullname)\LicensedApps.tmp")) {
		refreshenv
		Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
		if (Test-PendingReboot) {Invoke-Reboot} 
		else {Write-Host 'Not Required' -ForegroundColor Green}
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Licensed Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName LicensedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 
		New-Item "$($PSDownload.fullname)\LicensedApps.tmp" -ItemType file -Force | Out-Null
	}
}
Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host "User Wallpaper`n" -ForegroundColor Cyan
# https://u.pcloud.link/publink/show?code=kZ4mFeVZGleWW7tIpASwap1qbic4Yy4mhL6y
$web = New-Object System.Net.WebClient
$web.DownloadFile('https://p-lux2.pcloud.com/D4ZswOSe2ZWMr5XGZZZ4A4Ec7Z2ZZQCzZkZu070ZDzZx7ZCzZiQFeVZsOQXEcIC9ty1s8tQMLylFp0oATlk/WIP-6th-anniversary-wallpaper-dark.jpg', "$env:USERPROFILE\New-Wallpaper.jpg")
Set-UserDesktopWallpaper -PicturePath "$env:USERPROFILE\New-Wallpaper.jpg" -Style Fill


Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Microsoft Update' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
Start-Process PowerShell -ArgumentList '-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-MSUpdate})' -Wait -WorkingDirectory C:\Temp\PSTemp 

refreshenv
Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
if (Test-PendingReboot) {Invoke-Reboot} 
else {Write-Host 'Not Required' -ForegroundColor Green}



