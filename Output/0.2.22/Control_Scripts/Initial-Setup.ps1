$PSTemp = "$env:TEMP\PSTemp"
if (Test-Path $PSTemp) {Remove-Item $PSTemp -Force -Recurse}
$PSDownload = New-Item $PSTemp -ItemType Directory -Force


$AnswerFile = "$($PSDownload.FullName)\AnswerFile.json"

if (-not(Test-Path $AnswerFile)) {

	$output = [PSCustomObject]@{
		DomainName        = 'None'
		DomainUser        = 'None'
		DomainPassword    = 'None'
		NewHostName       = 'None'
		GitHubToken       = 'None'
		GitHubUserID      = 'None'
		InstallAllModules = $false
		InstallAllApps    = $false
	}

	$output | ConvertTo-Json | Out-File -FilePath $AnswerFile -Force

	Start-Process -FilePath notepad.exe -ArgumentList $AnswerFile -Wait
}

$AnswerFileImport = (Get-Content $AnswerFile | ConvertFrom-Json) 

foreach ($item in ($AnswerFileImport | Get-Member -MemberType noteProperty)) {
	New-Variable -Name $item.Name -Value $AnswerFileImport.$($item.Name) -Force -Scope Global
}


If (!(Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain) {
	Write-Host -ForegroundColor Red 'This machine is not part of a domain. Adding now.'
	$encSecret = $DomainPassword | ConvertTo-SecureString -Force -AsPlainText
	$labcred = New-Object System.Management.Automation.PSCredential ($DomainUser, $encSecret)
    
	Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $NewHostName
	Start-Sleep 5
	Add-Computer -DomainName $DomainName -Credential $labcred -Options JoinWithNewName, AccountCreate -Force -Restart
}

$web = New-Object System.Net.WebClient
$web.DownloadFile('https://bit.ly/35sEu2b', "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1")
$full = Get-Item "$($PSDownload.FullName)\Start-PSToolkitSystemInitialize.ps1"
Import-Module $full.FullName -Force
Start-PSToolkitSystemInitialize -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken -LabSetup -InstallMyModules
Remove-Item $full.FullName

if ($InstallAllModules) {
	Install-PWSHModule -ListName BaseModules, ExtendedModules, MyModules -Scope AllUsers -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
}

if ($InstallAllApps) {
	Install-PSPackageManAppFromList -ListName BaseApps, ExtendedApps -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
}


# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force
# iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/JMTr4'gist.githubusercontent.com/smitpi/87099e6b6c60b76e8fd09c70b73bdd8a/raw/b889b1a92b3cf3ed19db76d8e1a9c6ac1ca4faba/Lab-Initialize-Setup.ps1'))
# iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1')); Initial-Setup.ps1 -GitHubToken 
# start http://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1


