
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

#endregion

#region Set Variables

#region set folders
$PSTemp = 'C:\Temp\PSTemp'
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

if (Test-Path 'C:\Temp\PSTemp\Logs') {$PSLogsPath = Get-Item 'C:\Temp\PSTemp\Logs'}
else {$PSLogsPath = New-Item 'C:\Temp\PSTemp\Logs' -ItemType Directory -Force}
#endregion

#region check reboot
function check-reboot {
	refreshenv | Out-Null
	Write-Host '[Checking] ' -NoNewline -ForegroundColor Yellow; Write-Host 'Pending Reboot: ' -ForegroundColor Cyan -NoNewline
	if (Test-PendingReboot) {Invoke-Reboot} 
	else {Write-Host 'Not Required' -ForegroundColor Green}
}
#endregion

#region Run Block Code
function Run-Block {
	PARAM(
		[string]$Name,
		[string]$Block
	)

	$PSPath = Get-Item (Get-Command powershell).Source
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
		Start-Process @InstallerArgs -ArgumentList "-NoLogo -NoProfile -ExecutionPolicy Bypass -Command (& {$($Block)})"
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
		$ExtendedApps = {
			Install-PSPackageManAppFromList -ListName BaseApps, ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
			Remove-Item -Path "$([Environment]::GetFolderPath('Desktop'))\*.lnk" -ErrorAction SilentlyContinue
			Remove-Item -Path "$($env:PUBLIC)\Desktop\*.lnk" -ErrorAction SilentlyContinue
		}
		Run-Block -Name ExtendedApps -Block $ExtendedApps	
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
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Windows Feature`n" -ForegroundColor Cyan
		Run-Block -Name EnableHyperV -Block 'choco install -y Microsoft-Hyper-V-All --source=windowsFeatures'	
		check-reboot

		$HyperVSettings = {
			if (-not(Test-Path C:\Hyper-V)) { New-Item C:\Hyper-V -ItemType Directory -Force | Out-Null }
			if (-not(Test-Path C:\Hyper-V\VHD)) { New-Item C:\Hyper-V\VHD -ItemType Directory -Force | Out-Null}
			if (-not(Test-Path C:\Hyper-V\Config)) { New-Item C:\Hyper-V\Config -ItemType Directory -Force | Out-Null}
			Hyper-V\Set-VMHost -VirtualHardDiskPath 'C:\Hyper-V\VHD' -VirtualMachinePath 'C:\Hyper-V\Config'
		
			$NetAdap = (Get-NetAdapter -Physical | Where-Object {$_.status -like 'up'})[0]
			Hyper-V\New-VMSwitch -Name 'External' -NetAdapterName $NetAdap.Name
		}
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Setup]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Hyper-V Settings`n" -ForegroundColor Cyan
		Run-Block -Name HyperVSettings -Block $HyperVSettings
		New-Item "$($PSDownload.fullname)\EnableHyperV.tmp" -ItemType file -Force | Out-Null
	}
}
#endregion

#region WSL
if ($EnableWSL -and ($WSLUser -notlike 'None')) {
	if (-not(Test-Path "$($PSDownload.fullname)\WSL.tmp")) {
		check-reboot
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'WSL' -ForegroundColor Cyan -NoNewline; Write-Host " (New Window)`n" -ForegroundColor darkYellow   
		$WSLInstall = {
			#New-NetFirewallRule -DisplayName 'WSL allow in' -Direction Inbound -InterfaceAlias 'vEthernet (WSL)' -Action Allow

			cmd.exe /c 'wsl --install --web-download --no-launch --distribution Ubuntu'
			cmd.exe /c 'wsl --distribution Ubuntu --shell-type standard --user root touch /etc/wsl.conf'
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo '[network]' |  ubuntu run -u root tee -a /etc/wsl.conf"
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo 'generateResolvConf = false' |  ubuntu run -u root tee -a /etc/wsl.conf"
			cmd.exe /c 'wsl --distribution Ubuntu --shell-type standard --user root rm -rf /etc/resolv.conf'
			cmd.exe /c 'wsl --distribution Ubuntu --shell-type standard --user root touch /etc/resolv.conf'
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo 'nameserver 1.1.1.1' |  ubuntu run -u root tee -a /etc/resolv.conf"
			cmd.exe /c 'wsl --distribution Ubuntu --shell-type standard --user root sudo curl -o /etc/wsl.conf -L https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Private/Config/wsl.conf'
			cmd.exe /c 'wsl --shutdown Ubuntu'
		}

		$LinuxUserSetup = {
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root useradd -m -G sudo -s /bin/bash $($WSLUser)"
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root (echo -e 'Blah'; echo -e 'Blah') |wsl --distribution Ubuntu --shell-type standard --user root passwd $($WSLUser)"
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo '[user]' |  ubuntu run -u root tee -a /etc/wsl.conf"
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo 'default = $($WSLUser)' |  ubuntu run -u root tee -a /etc/wsl.conf"
			cmd.exe /c "wsl --distribution Ubuntu --shell-type standard --user root echo '$($WSLUser) ALL=(ALL) NOPASSWD:ALL' |  ubuntu run -u root tee /etc/sudoers.d/$($WSLUser)"
			cmd.exe /c 'wsl --shutdown Ubuntu'
		}

		$DeployAnsible = {
			cmd.exe /c 'wsl --exec sudo apt update'
			cmd.exe /c 'wsl --exec sudo apt install make git -y'
			cmd.exe /c "wsl --exec sudo git clone https://$($GitHubToken):x-oauth-basic@github.com/smitpi/ansible-bootstrap ~/ansible/ansible-bootstrap"
			cmd.exe /c "wsl --exec sudo cp /home/$($WSLUser)/ansible/ansible-bootstrap/inventory-src /home/$($WSLUser)/ansible/inventory"
			cmd.exe /c "wsl --exec sudo mkdir /home/$($WSLUser)/ansible/host_vars"

			cmd.exe /c 'wsl --exec sudo apt install git python3-pip python3-dev -y'
			cmd.exe /c 'wsl --exec sudo pip3 install ansible'
			cmd.exe /c "wsl --exec sudo ansible-galaxy install -r /home/$($WSLUser)/ansible/ansible-bootstrap/requirements.yml --force"

			cmd.exe /c "wsl --exec sudo ansible-playbook -i /home/$($WSLUser)/ansible/inventory /home/$($WSLUser)/ansible/ansible-bootstrap/local.yml --limit localhost --tags initial"
			cmd.exe /c "wsl --exec sudo ansible-playbook -i /home/$($WSLUser)/ansible/inventory /home/$($WSLUser)/ansible/ansible-bootstrap/local.yml"
		}
		
		Write-Host "`t`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'WSL2' -ForegroundColor Cyan
		Run-Block -Name WSLInstall -Block $WSLInstall
		check-reboot
		Write-Host "`t`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Linux Sudo Account' -ForegroundColor Cyan
		Run-Block -Name LinuxUserSetup -Block $LinuxUserSetup
		check-reboot
		Write-Host "`t`t[Executing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Ansible Config' -ForegroundColor Cyan
		Run-Block -Name DeployAnsible -Block $DeployAnsible
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
Run-Block -Name WinUpdate -Block 'Install-MSUpdate'
check-reboot
#endregion


