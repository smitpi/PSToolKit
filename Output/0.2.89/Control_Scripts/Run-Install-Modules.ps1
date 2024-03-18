####Elevate Powershell####
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-not($myWindowsPrincipal.IsInRole($adminRole))) {
	$AskCredencials = Get-Credential -Message 'Admin Account'
	$newProcess = New-Object System.Diagnostics.ProcessStartInfo 'C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe'
	$newProcess.Verb = 'runas'
	$newProcess.UseShellExecute = $false
	$newProcess.UserName = $AskCredencials.UserName
	$newProcess.Password = $AskCredencials.Password
	$newProcess.Arguments = $myInvocation.MyCommand.Definition
	[System.Diagnostics.Process]::Start($newProcess)
	exit
}
$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-ModulesFromPWSHModule.ps1'
(New-Object System.Net.WebClient).DownloadFile($($Url), "$($env:tmp)\Install-ModulesFromPWSHModule.ps1")
Import-Module (Get-Item "$($env:tmp)\Install-ModulesFromPWSHModule.ps1") -Force; Install-ModulesFromPWSHModule