PARAM(
	[string]$DomainName,
	[string]$DomainUser,
	[securestring]$DomainPassword,
	[Parameter(Mandatory = $true)]
	[string]$GitHubToken
)

If (!(Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain) {
	Write-Host -ForegroundColor Red 'This machine is not part of a domain. Adding now.'
	$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, $DomainPassword)
    
	Rename-Computer -ComputerName $env:COMPUTERNAME -NewName "Dev-$(Get-Random -Maximum 5000)"
	Start-Sleep 5
	Add-Computer -DomainName $DomainName -Credential $labcred -Options JoinWithNewName, AccountCreate -Force -Restart
}

$PSTemp = "$env:TEMP\PSTemp"
if (Test-Path $PSTemp) {Remove-Item $PSTemp -Force -Recurse}
$PSDownload = New-Item $PSTemp -ItemType Directory -Force

$web = New-Object System.Net.WebClient
$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
Import-Module $full.FullName -Force
Start-PSToolkitSystemInitialize -GitHubToken $GitHubToken -LabSetup -InstallMyModules
Remove-Item $full.FullName


# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force
# iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/JMTr4'gist.githubusercontent.com/smitpi/87099e6b6c60b76e8fd09c70b73bdd8a/raw/b889b1a92b3cf3ed19db76d8e1a9c6ac1ca4faba/Lab-Initialize-Setup.ps1'))
