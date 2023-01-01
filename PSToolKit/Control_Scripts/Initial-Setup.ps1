
#region boxstarter setup

# Boxstarter options
$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot

# Development Mode
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

# Create Run_Win-Bootstrap Shortcuts
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$([Environment]::GetFolderPath('Desktop'))\Run_Win-Bootstrap.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$MSEdgePath = Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$Shortcut.TargetPath = $MSEdgePath.FullName
$Shortcut.Arguments = "--app=`"https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1`""
$IconLocation = 'C:\windows\System32\SHELL32.dll'
$IconArrayIndex = 27
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()
# Create GitHub_Win-Bootstrap Shortcuts
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$([Environment]::GetFolderPath('Desktop'))\Github_Win-Bootstrap.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$MSEdgePath = Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$Shortcut.TargetPath = $MSEdgePath.FullName
$Shortcut.Arguments = "--app=`"https://github.com/smitpi/win-bootstrap`""
$Shortcut.IconLocation = $MSEdgePath.fullname
$Shortcut.Save()

function check-reboot {
	refreshenv
	Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
	if (Test-PendingReboot) {Invoke-Reboot} 
	else {Write-Host 'Not Required' -ForegroundColor Green}
}
#endregion

#region Set Variables
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
		EnableHyperV        = $false
		EnableWSL           = $false
		WSLUser             = 'None'
		WSLPassword         = 'None'
	}
	$output | ConvertTo-Json | Out-File -FilePath $AnswerFile -Force
	Start-Process -FilePath notepad.exe -ArgumentList $AnswerFile -Wait
}
$AnswerFileImport = (Get-Content $AnswerFile | ConvertFrom-Json) 

foreach ($item in ($AnswerFileImport | Get-Member -MemberType noteProperty)) {
	New-Variable -Name $item.Name -Value $AnswerFileImport.$($item.Name) -Force -Scope Global
}
#endregion 

#region Add to domain
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
#endregion

#region pstoolkit setup
if (Test-Path "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1") {Remove-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1" -Force}
$web = New-Object System.Net.WebClient
$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
try {
	Import-Module $full.FullName -Force

	if ($GitHubUserID -like 'None') {Start-PSToolkitSystemInitialize -LabSetup -InstallMyModules}
	else {Start-PSToolkitSystemInitialize -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken -LabSetup -InstallMyModules}

	Remove-Item $full.FullName
} catch {Write-Warning "Error: Message:$($Error[0])"}
#endregion

#region baseapps
if (-not(Test-Path "$($PSDownload.fullname)\BaseApps.tmp") -and ($GitHubUserID -notlike 'None')) {
	try {
		check-reboot
		
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Base Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 

		New-Item "$($PSDownload.fullname)\BaseApps.tmp" -ItemType file -Force | Out-Null
	} catch {Write-Warning "Error: Message:$($Error[0])"}
}
#endregion

#region all modules
if ($InstallAllModules -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedModules.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Modules' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PWSHModule -ListName BaseModules, ExtendedModules, MyModules -Scope AllUsers -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 
		New-Item "$($PSDownload.fullname)\ExtendedModules.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region extended apps
if ($InstallAllApps -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedApps.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName BaseApps, ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})' -Wait -WorkingDirectory C:\Temp\PSTemp 
		
		Remove-Item -Path '$([Environment]::GetFolderPath('Desktop'))\*.lnk" -ErrorAction SilentlyContinue
		Remove-Item -Path "$($env:PUBLIC)\Desktop\*.lnk" -ErrorAction SilentlyContinue

		New-Item "$($PSDownload.fullname)\ExtendedApps.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region licensed apps
if ($InstallLicensedApps -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\LicensedApps.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Licensed Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-PSPackageManAppFromList -ListName LicensedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken})" -Wait -WorkingDirectory C:\Temp\PSTemp 
		New-Item "$($PSDownload.fullname)\LicensedApps.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region HyperV
if ($EnableHyperV) {
	if (-not(Test-Path "$($PSDownload.fullname)\EnableHyperV.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Hyper-V' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Windows Feature`n" -ForegroundColor Cyan
		Start-Process PowerShell -ArgumentList '-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {choco install -y Microsoft-Hyper-V-All --source=windowsFeatures})' -Wait -WorkingDirectory C:\Temp\PSTemp 
		check-reboot

		[scriptblock]$block = {
			if (-not(Test-Path C:\Hyper-V)) { New-Item C:\Hyper-V -ItemType Directory -Force | Out-Null }
			if (-not(Test-Path C:\Hyper-V\VHD)) { New-Item C:\Hyper-V\VHD -ItemType Directory -Force | Out-Null}
			if (-not(Test-Path C:\Hyper-V\Config)) { New-Item C:\Hyper-V\Config -ItemType Directory -Force | Out-Null}
			Hyper-V\Set-VMHost -VirtualHardDiskPath 'C:\Hyper-V\VHD' -VirtualMachinePath 'C:\Hyper-V\Config'
		
			$NetAdap = (Get-NetAdapter -Physical | Where-Object {$_.status -like 'up'})[0]
			Hyper-V\New-VMSwitch -Name 'External2' -NetAdapterName $NetAdap.Name
		}
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Setup]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Hyper-V Settings`n" -ForegroundColor Cyan
		Start-Process PowerShell -ArgumentList "-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {$($block)} )" -Wait -WorkingDirectory C:\Temp\PSTemp 

		New-Item "$($PSDownload.fullname)\EnableHyperV.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region WSL
if ($EnableWSL -and ($WSLUser -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\WSL.tmp")) {
		0
	}
}
#endregion

#region wallpaper
Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host "User Wallpaper`n" -ForegroundColor Cyan
# https://u.pcloud.link/publink/show?code=kZ4mFeVZGleWW7tIpASwap1qbic4Yy4mhL6y
$web = New-Object System.Net.WebClient
$web.DownloadFile('https://github.com/smitpi/PSToolKit/raw/master/PSToolKit/Private/Wallpapers/Chicago-Architecture-Wallpaper.jpg', "$env:USERPROFILE\New-Wallpaper.jpg")
Set-UserDesktopWallpaper -PicturePath "$env:USERPROFILE\New-Wallpaper.jpg" -Style Fill
#endregion

#region win updates
Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Microsoft Update' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
Start-Process PowerShell -ArgumentList '-NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -Command (& {Install-MSUpdate})' -Wait -WorkingDirectory C:\Temp\PSTemp 
check-reboot

#endregion


