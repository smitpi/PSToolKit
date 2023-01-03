
#region boxstarter setup

# Boxstarter options
$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot

# Development Mode
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1
#endregion

#region set folders
$PSTemp = 'C:\Temp\PSTemp'
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

if (Test-Path 'C:\Temp\PSTemp\Logs') {$PSLogsPath = Get-Item 'C:\Temp\PSTemp\Logs'}
else {$PSLogsPath = New-Item 'C:\Temp\PSTemp\Logs' -ItemType Directory -Force}
#endregion

#region start transcript
Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Starting]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Transcript ($($PSLogsPath.FullName)\Initial-Setup-Transcript.log)`n" -ForegroundColor Cyan
Start-Transcript -Path "$($PSLogsPath.FullName)\Initial-Setup-Transcript.log" -Append -Force -NoClobber -IncludeInvocationHeader
#endregion

#region Create Icon Folder
if (Test-Path "$($env:PUBLIC)\Desktop\Win-Bootstrap") { Get-Item "$($env:PUBLIC)\Desktop\Win-Bootstrap" | Remove-Item -Recurse -Force}
$BootstrapFolder = New-Item "$($env:PUBLIC)\Desktop\Win-Bootstrap" -ItemType Directory -Force

if (-not(Test-Path "$($env:PUBLIC)\Pictures\Utilities.ico")) {
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Private/ICO/Utilities_Icon.ico', "$($env:PUBLIC)\Pictures\Utilities.ico")
}

if (-not(Test-Path "$($env:PUBLIC)\Pictures\Notes-icon.ico")) {
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Private/ICO/Notes-icon.ico', "$($env:PUBLIC)\Pictures\Notes-icon.ico")
}
if (-not(Test-Path "$($env:PUBLIC)\Pictures\archive-icon.ico")) {
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Private/ICO/archive-icon.ico', "$($env:PUBLIC)\Pictures\archive-icon.ico")
}

$DesktopIni = @"
[.ShellClassInfo]
IconResource=$($env:PUBLIC)\Pictures\Utilities.ico,0
"@

#Create/Add content to the desktop.ini file
$newini = New-Item -Path "$($env:PUBLIC)\Desktop\Win-Bootstrap\desktop.ini" -ItemType File -Value $DesktopIni
  
#Set the attributes for $Desktop.ini
$newini.Attributes = 'Hidden, System, Archive'
 
#Finally, set the folder's attributes
$BootstrapFolder.Attributes = 'ReadOnly, Directory'
#endregion

#region Create Icons
# Create Run_Win-Bootstrap Shortcuts
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$($env:PUBLIC)\Desktop\Win-Bootstrap\Run_Win-Bootstrap.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$MSEdgePath = Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$Shortcut.TargetPath = $MSEdgePath.FullName
$Shortcut.Arguments = "--app=`"https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1`""
$IconLocation = 'C:\windows\System32\SHELL32.dll'
$IconArrayIndex = 27
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

# Create GitHub_PSToolKit Shortcuts
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$($env:PUBLIC)\Desktop\Win-Bootstrap\GitHub_PSToolKit.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$MSEdgePath = Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$Shortcut.TargetPath = $MSEdgePath.FullName
$Shortcut.Arguments = "--app=`"https://github.com/smitpi/pstoolkit`""
$IconLocation = 'C:\windows\System32\mstsc.exe'
$IconArrayIndex = 19
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

# AnswerFile
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$($env:PUBLIC)\Desktop\Win-Bootstrap\AnswerFile.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$NotepadPath = Get-Item 'C:\Windows\system32\notepad.exe'
$Shortcut.TargetPath = $NotepadPath.FullName
$Shortcut.Arguments = "$($PSDownload.FullName)\AnswerFile.json"
$IconLocation = "$($env:PUBLIC)\Pictures\Notes-icon.ico"
$IconArrayIndex = 0
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

# Bootstrap Temp Folder
$WScriptShell = New-Object -ComObject WScript.Shell
$lnkfile = "$($env:PUBLIC)\Desktop\Win-Bootstrap\Bootstrap_Temp_Directory.lnk"
$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
$ExeFolder = Get-Item 'C:\Windows\explorer.exe'
$Shortcut.TargetPath = $ExeFolder.FullName
$Shortcut.Arguments = "$($PSDownload.FullName)"
$IconLocation = "$($env:PUBLIC)\Pictures\archive-icon.ico"
$IconArrayIndex = 0
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()
#endregion

#region Function:check reboot
function check-reboot {
	refreshenv | Out-Null
	Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
	if (Test-PendingReboot) {Invoke-Reboot} 
	else {Write-Host 'Not Required' -ForegroundColor Green}
}
#endregion

#region Function:Run-Block
function Run-Block {
	PARAM(
		[string]$Name,
		[string]$Block,
		[System.IO.DirectoryInfo]$LogsPath = $PSLogsPath	
	)
	try {
		$PSPath = Get-Item (Get-Command powershell).Source
		$PSLogsPath = Get-Item $LogsPath
	} catch {Write-Warning "Error: Message:$($Error[0])"}
	$InstallerArgs = @{
		FilePath              = $pspath.fullname
		Wait                  = $true
		NoNewWindow           = $true
		WorkingDirectory      = $PSDownload.fullname
		RedirectStandardError = Join-Path $PSLogsPath.fullname -ChildPath "$($Name)-Error.log"
		#RedirectStandardOutput = Join-Path $PSLogsPath.fullname -ChildPath "$($Name)Output.log"
	}
	try {
		Write-Host '[Executing] ' -NoNewline -ForegroundColor Yellow; Write-Host "CodeBlock: $($Name)" -ForegroundColor Cyan
		Start-Process @InstallerArgs -ArgumentList "-NoLogo -NoProfile -Mta -NonInteractive -ExecutionPolicy Bypass -Command (& {$($Block)})"
		Write-Host '[Completed]: ' -ForegroundColor Yellow -NoNewline; Write-Host "CodeBlock: $($Name)" -ForegroundColor DarkRed
		Write-Host "-----------------------------------`n" -ForegroundColor DarkCyan
	} catch {Write-Warning "Error: Message:$($Error[0])"}
}
#endregion

#region Answer File
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

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Configuring]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Answer File`n" -ForegroundColor Cyan

$AnswerFile = "$($PSDownload.FullName)\AnswerFile.json"
if (-not(Test-Path $AnswerFile)) {
	$domaincreds = Get-Credential -Message 'Account to add device to domain'
	$output = [PSCustomObject]@{
		AddToDomain         = $false
		DomainName          = 'None'
		DomainUser          = $domaincreds.UserName
		DomainPassword      = ($domaincreds.Password | ConvertFrom-SecureString)
		NewHostName         = 'None'
		GitHubToken         = 'None'
		GitHubUserID        = 'None'
		InstallAllModules   = $false
		InstallAllApps      = $false
		InstallLicensedApps = $false
		EnableHyperV        = $false
		EnableWSL           = $false
		WSLUser             = 'None'
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
		Write-Host -ForegroundColor Red 'Your AnswerFile will be deleted after this process is complete.'
		Rename-Item "$($PSDownload.FullName)\AnswerFile.json" -NewName "$(Get-Date -Format ddMMMyyyy_HHmm)-AnswerFile.json"
		$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, ($DomainPassword | ConvertTo-SecureString))

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
		Run-Block -Name baseapps -Block "Install-PSPackageManAppFromList -ListName BaseApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken"	
		New-Item "$($PSDownload.fullname)\BaseApps.tmp" -ItemType file -Force | Out-Null
	} catch {Write-Warning "Error: Message:$($Error[0])"}
}
#endregion

#region all modules
if ($InstallAllModules -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedModules.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Modules' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Run-Block -Name ExtendedModules -Block "Install-PWSHModule -ListName BaseModules, ExtendedModules, MyModules -Scope AllUsers -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken"
		New-Item "$($PSDownload.fullname)\ExtendedModules.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region extended apps
if ($InstallAllApps -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\ExtendedApps.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Extended Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Run-Block -Name ExtendedApps -Block "Install-PSPackageManAppFromList -ListName BaseApps,ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken"
		Run-Block -Name RemovePrivateIcons -Block "Remove-Item -Path `"$([Environment]::GetFolderPath('Desktop'))\*.lnk`""
		Run-Block -Name RemovePublicIcons -Block "Remove-Item -Path $($env:PUBLIC)\Desktop\*.lnk"
		New-Item "$($PSDownload.fullname)\ExtendedApps.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region licensed apps
if ($InstallLicensedApps -and ($GitHubUserID -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\LicensedApps.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Licensed Apps' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Run-Block -Name LicensedApps -Block "Install-PSPackageManAppFromList -ListName LicensedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken"	
		New-Item "$($PSDownload.fullname)\LicensedApps.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region HyperV
if ($EnableHyperV) {
	if (-not(Test-Path "$($PSDownload.fullname)\EnableHyperV.tmp")) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Hyper-V' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Invoke-Command -ScriptBlock {
			Write-Host "`t`tInstalling Feature" -ForegroundColor DarkYellow	
			choco install -y Microsoft-Hyper-V-All --source=windowsFeatures
		}
		check-reboot
		Invoke-Command -ScriptBlock {
			try {
				if (-not(Test-Path C:\Hyper-V)) { New-Item C:\Hyper-V -ItemType Directory -Force | Out-Null }
				if (-not(Test-Path C:\Hyper-V\VHD)) { New-Item C:\Hyper-V\VHD -ItemType Directory -Force | Out-Null}
				if (-not(Test-Path C:\Hyper-V\Config)) { New-Item C:\Hyper-V\Config -ItemType Directory -Force | Out-Null}
				Write-Host "`t`tSetting Hyper-V Paths" -ForegroundColor DarkYellow	
				Hyper-V\Set-VMHost -VirtualHardDiskPath 'C:\Hyper-V\VHD' -VirtualMachinePath 'C:\Hyper-V\Config'
		
				$NetAdap = (Get-NetAdapter -Physical | Where-Object {$_.status -like 'up'})[0]
				Write-Host "`t`tCreate External Switch" -ForegroundColor DarkYellow	
				Hyper-V\New-VMSwitch -Name 'External' -NetAdapterName $NetAdap.Name
			} catch {Write-Warning "Error: Message:$($Error[0])"}
		}
		New-Item "$($PSDownload.fullname)\EnableHyperV.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region WSL
if ($EnableWSL -and ($WSLUser -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\WSL.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'WSL' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		Invoke-Command -ScriptBlock { 
			Write-Host "`t`tInstalling Ubuntu" -ForegroundColor DarkYellow	
			'wsl --install -d Ubuntu' | cmd
		}
		check-reboot
        
		Invoke-Command -ScriptBlock {
			PARAM($GitHubUserID, $GitHubToken, $WSLUser)
			Write-Host "`t`tSetting wsl.conf" -ForegroundColor DarkYellow	
			'Ubuntu run --user root echo [network] | ubuntu run -u root tee -a /etc/wsl.conf' | cmd
			'Ubuntu run --user root echo generateResolvConf = false | ubuntu run -u root tee -a /etc/wsl.conf' | cmd
			'wsl --shutdown Ubuntu' | cmd
			Write-Host "`t`tSetting resolv.conf" -ForegroundColor DarkYellow	
			'Ubuntu run --user root touch /etc/resolv.conf' | cmd
			'Ubuntu run --user root echo nameserver 1.1.1.1 | ubuntu run -u root tee -a /etc/resolv.conf' | cmd
			'Ubuntu run --user root sudo curl -o /etc/wsl.conf -L https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Private/Config/wsl.conf' | cmd
			'wsl --shutdown Ubuntu' | cmd
			Write-Host "`t`tGit Clone Ansible Repo" -ForegroundColor DarkYellow	
			'ubuntu run --user root rm /opt/ansible -R' | cmd
			"Ubuntu run --user root git clone https://$($GitHubToken):x-oauth-basic@github.com/smitpi/ansible-bootstrap /opt/ansible/ansible-bootstrap" | cmd
			'ubuntu run --user root cp /opt/ansible/ansible-bootstrap/inventory-src /opt/ansible/inventory' | cmd
			'Ubuntu run --user root mkdir /opt/ansible/host_vars' | cmd
			Write-Host "`t`tRunning Updates" -ForegroundColor DarkYellow	
			'Ubuntu run --user root apt update' | cmd
			'Ubuntu run --user root apt install make git python3-pip python3-dev -y' | cmd
			'Ubuntu run --user root pip3 install ansible' | cmd
			Write-Host "`t`tAdding Default User" -ForegroundColor DarkYellow	
			"ubuntu --config --default-user $WSLUser" | cmd
		} -ArgumentList $GitHubUserID, $GitHubToken, $WSLUser
		
		check-reboot
		New-Item "$($PSDownload.fullname)\WSL.tmp" -ItemType file -Force | Out-Null
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
Run-Block -Name MSUpdates -Block 'Install-MSUpdate'
check-reboot
#endregion
Stop-Transcript