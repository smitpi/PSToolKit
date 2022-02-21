
<#PSScriptInfo

.VERSION 0.1.0

.GUID 01311f11-b787-49d3-812d-e6cb465bd201

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

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
 install OpenSSH on server

#>

<#
.SYNOPSIS
Install and setup OpenSSH on device.

.DESCRIPTION
Install and setup OpenSSH on device.

.PARAMETER AddPowershellSubsystem
Add the ps subsystem to the ssh config file.

.EXAMPLE
 Install-SSHServer

.NOTES
General notes
#>
Function Install-SSHServer {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-SSHServer')]
	PARAM(
		[switch]$AddPowershellSubsystem = $false
	)
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
		$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
		$request = [System.Net.WebRequest]::Create($url)
		$request.AllowAutoRedirect = $false
		$response = $request.GetResponse()
		$DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + '/OpenSSH-Win64.zip'
		$OutFile = $env:TEMP + '\OpenSSH-Win64.zip'
		Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile -Verbose
		if (Test-Path 'C:\Program Files\OpenSSH-Win64') { Rename-Item -Path 'C:\Program Files\OpenSSH-Win64' -NewName OpenSSH-Win64-old -Force }
		New-Item 'C:\Program Files\OpenSSH-Win64' -ItemType Directory -Force
		Expand-Archive -Path $OutFile -OutputPath 'C:\Program Files\OpenSSH-Win64' -ShowProgress -FlattenPaths
	}
 else {
		Get-ChocoPackage -Name openssh -Exact | Install-ChocoPackage -Force
	}
	Import-Module 'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'
	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
	'sshd', 'ssh-agent' | Set-Service -StartupType Automatic -Status Running -Verbose

	$SSHConf = Get-Content "$env:ProgramData\ssh\sshd_config"
	$NewSSHConf = $SSHConf -replace ('#PasswordAuthentication yes', 'PasswordAuthentication yes')
	$NewSSHConf = $NewSSHConf -replace ('#PubkeyAuthentication yes', 'PubkeyAuthentication yes')
	$NewSSHConf | Set-Content "$env:ProgramData\ssh\sshd_config" -Force
	'sshd', 'ssh-agent' | Get-Service | Stop-Service
	'sshd', 'ssh-agent' | Get-Service | Start-Service -Verbose

	if ($AddPowershellSubsystem) {
		$PowerShellPath = (Get-Command -Name pwsh.exe).Path
		$fso = New-Object -ComObject Scripting.FileSystemObject
		$NewSSHConf += ' '
		$NewSSHConf += '# Required (Windows): Define the PowerShell subsystem'
		$NewSSHConf += 'Subsystem powershell ' + $fso.GetFile($PowerShellPath).ShortPath + ' -sshs -NoLogo'
		$NewSSHConf | Set-Content "$env:ProgramData\ssh\sshd_config" -Force

		'sshd', 'ssh-agent' | Get-Service | Stop-Service
		'sshd', 'ssh-agent' | Get-Service | Start-Service -Verbose

	}

} #end Function

