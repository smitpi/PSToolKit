####Elevate Powershell####
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-not($myWindowsPrincipal.IsInRole($adminRole))) {

	$AskCredencials = Get-Credential -Message 'Admin Account'

	if (-not(Test-Path 'C:\Temp')) {$TempPath = New-Item -Path 'C:\Temp' -ItemType Directory -Force -Credential $AskCredencials | Out-Null}
	else {$TempPath = Get-Item C:\Temp}

	$run = New-Item -Path "$($TempPath)\Run.ps1" -Value @"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
`$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-AppsFromPSPackageMan.ps1'
(New-Object System.Net.WebClient).DownloadFile(`$(`$Url), "$($TempPath)\Install-AppsFromPSPackageMan.ps1")
Import-Module (Get-Item "$($TempPath)\Install-AppsFromPSPackageMan.ps1").fullname -Force; Install-AppsFromPSPackageMan
"@ -Verbose -Force

	$RunUser = New-Item -Path "$($TempPath)\RunUser.ps1" -Value @"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Start-Process -FilePath powershell -ArgumentList "-noprofile -ExecutionPolicy Bypass -file ``"$($TempPath)\Run.ps1``"" -Verb runas
"@ -Verbose -Force

	Start-Process -FilePath powershell -ArgumentList "-noprofile -ExecutionPolicy Bypass -file `"$($TempPath)\RunUser.ps1`"" -Credential $AskCredencials

	Start-Sleep 10
	$run, $RunUser, (Get-Item "$($TempPath)\Install-AppsFromPSPackageMan.ps1") | Remove-Item -Force
} else {
	$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-AppsFromPSPackageMan.ps1'
(New-Object System.Net.WebClient).DownloadFile($($URL), "$($env:tmp)\Install-AppsFromPSPackageMan.ps1")
	Import-Module (Get-Item "$($env:tmp)\Install-AppsFromPSPackageMan.ps1") -Force; Install-AppsFromPSPackageMan
}
