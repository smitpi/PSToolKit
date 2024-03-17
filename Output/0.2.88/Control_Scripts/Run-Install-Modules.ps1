# Boxstarter options
$Boxstarter.RebootOk = $false # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $false # Save my password securely and auto-login after a reboot

# Basic setup
Write-Host 'Setting execution policy'
Update-ExecutionPolicy Unrestricted

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
$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-ModulesFromPWSHModule.ps1'
(New-Object System.Net.WebClient).DownloadFile($($Url), "$($env:tmp)\Install-ModulesFromPWSHModule.ps1")
Import-Module (Get-Item "$($env:tmp)\Install-ModulesFromPWSHModule.ps1") -Force; Install-AppsFromPSPackageMan