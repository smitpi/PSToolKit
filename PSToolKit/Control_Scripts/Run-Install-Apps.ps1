
# Boxstarter options
$Boxstarter.RebootOk = $false # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $false # Save my password securely and auto-login after a reboot
$Boxstarter.SuppressLogging = $True.
# Install-BoxstarterPackage -Package "C:\ProgramData\Boxstarter\BuildPackages\InstallApps.1.0.0.nupkg"
#New-PackageFromScript MyScript.ps1 MyPackage
#http://boxstarter.org/package/nr/url?


#Boxstarter.WinConfig\Install-WindowsUpdate -getUpdatesFromMS -acceptEula


# Basic setup
Write-Host 'Setting execution policy'
Update-ExecutionPolicy Unrestricted

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
	refreshenv
} catch {Write-Warning "Error: Message:$($Error[0])"}

####Elevate Powershell####
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-not($myWindowsPrincipal.IsInRole($adminRole))) {
	$newProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
	$newProcess.Arguments = $myInvocation.MyCommand.Definition
	$newProcess.Verb = 'runas'
	[System.Diagnostics.Process]::Start($newProcess)
	exit
}

if ([string]::IsNullOrEmpty($GitHubUserID)) {
	$input = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the GitHub User:', 'User Input', '')
	if ([string]::IsNullOrWhiteSpace($input)) {
		$GitHubUserID = $input
	}
}
	
if ([string]::IsNullOrEmpty($GitHubToken)) {
	$input = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the GitHub Token:', 'User Input', '')
	if ([string]::IsNullOrWhiteSpace($input)) {$GitHubToken = $input}
}
$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-AppsFromPSPackageMan.ps1'
(New-Object System.Net.WebClient).DownloadFile($($URL), "$($env:tmp)\Install-AppsFromPSPackageMan.ps1")
Import-Module (Get-Item "$($env:tmp)\Install-AppsFromPSPackageMan.ps1") -Force; 
Install-AppsFromPSPackageMan -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken




#powershell 'irm asheroto.com/winget | iex'
#Invoke-RestMethod asheroto.com/winget | Invoke-Expression
#http://boxstarter.org/package/url?asheroto.com/winget

Enable-UAC
