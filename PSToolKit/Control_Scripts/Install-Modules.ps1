$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) { Throw 'Must be running an elevated prompt to use function' }

$RequiredModules = @(
	'PWSHModule'
)


$PSTemp = 'C:\Temp\PSTemp'
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

Write-Host "`n`n[Utilizing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Temp Directory:' -ForegroundColor Cyan -NoNewline; Write-Host " $($PSDownload.FullName)" -ForegroundColor Green
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region ExecutionPolicy
if ((Get-ExecutionPolicy) -notlike 'Unrestricted') {
	try {
		Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process -ErrorAction Stop
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser -ErrorAction Stop
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope LocalMachine -ErrorAction Stop
		Write-Host ' Complete' -ForegroundColor Green
	} catch {Write-Warning "Error Setting ExecutionPolicy: Message:$($Error[0])"}
} else {Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution:' -ForegroundColor Cyan -NoNewline; Write-Host ' Already Set' -ForegroundColor Red}
#endregion

#region PSRepo
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted' ) {
	try {
		Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell Gallery:' -ForegroundColor Cyan -NoNewline
		$null = Install-PackageProvider Nuget -Force
		$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
		$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
		Write-Host ' Complete' -ForegroundColor Green
	} catch {Write-Warning "Error Setting PSRepository: Message:$($Error[0])"}
} else {Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell Gallery:' -ForegroundColor Cyan -NoNewline; Write-Host ' Already Set' -ForegroundColor Red}
#endregion

#region PackageManager
Start-Job -ScriptBlock {
	$PowerShellGet = Get-Module 'PowerShellGet' -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

	if ($PowerShellGet.Version -lt [version]'2.2.5') {
		Write-Host "`t[Updating]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan
		$installOptions = @{
			Repository = 'PSGallery'
			Force      = $true
			Scope      = 'AllUsers'
		}							
		try {
			Install-Module -Name PackageManagement @installOptions
			Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Complete' -ForegroundColor Green
		} catch {Write-Warning "Error installing PackageManagement: Message:$($Error[0])"}
		try {
			Install-Module -Name PowerShellGet @installOptions
			Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShellGet' -ForegroundColor Cyan -NoNewline; Write-Host ' Complete' -ForegroundColor Green
		} catch {Write-Warning "Error installing PowerShellGet: Message:$($Error[0])"}
	} else {
		Write-Host "`t[Update]: " -NoNewline -ForegroundColor Yellow; Write-Host 'PowerShell PackageManagement' -ForegroundColor Cyan -NoNewline; Write-Host ' Not Needed' -ForegroundColor Red
	}
} | Wait-Job | Receive-Job		
#endregion

#region Needed Modules
Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Needed PowerShell Modules`n" -ForegroundColor Cyan
$RequiredModules | ForEach-Object {		
	$module = $_
	if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
		try {
			Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module):" -ForegroundColor Cyan -NoNewline
			Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
			Write-Host ' Complete' -ForegroundColor Green
		} catch {Write-Warning "Error installing module $($module): Message:$($Error[0])"}
	} else {
		Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module):" -ForegroundColor Cyan -NoNewline; Write-Host ' Already Installed' -ForegroundColor Red
	}
}
#endregion

##################################
#region Create list menu
##################################
Write-Host ' '
do {
	[string]$selection2 = Read-Host 'Are you installing from a Public Gist? (Y/N)'
	$selection2 = $selection2[0]
} while ($selection2.ToUpper() -ne 'Y' -and $selection2.ToUpper() -ne 'N')
switch ($selection2.ToUpper()) {
	'Y' {
		$GitHubUser = Read-Host 'GitHub Username'
		$PublicGist = $true
	}
	'N' { 
		$GitHubUser = Read-Host 'GitHub Username'
		$GitHubToken = Read-Host 'GitHub Token'	
 }
}
Write-Host ' '
Write-Host 'What should the Scope be?' -ForegroundColor Gray
Write-Host 'C )' -ForegroundColor Yellow -NoNewline; Write-Host ' Current User' -ForegroundColor Cyan 
Write-Host 'A )' -ForegroundColor Yellow -NoNewline; Write-Host ' All Users' -ForegroundColor Cyan 
$selection = Read-Host 'Please make a selection'
switch ($selection) {
	'C' { $scope = 'CurrentUser' }
	'A' { $scope = 'AllUsers' }
}
Write-Host ' '
do {
	[string]$selection2 = Read-Host 'Do You want to install Prerelease Modules? (Y/N)'
	$selection2 = $selection2[0]
} while ($selection2.ToUpper() -ne 'Y' -and $selection2.ToUpper() -ne 'N')
switch ($selection2.ToUpper()) {
	'Y' { $PreRelease = $true }
	'N' { $PreRelease = $false }
}


[System.Collections.generic.List[PSObject]]$ModuleLists = @()
Get-PWSHModuleList -GitHubUserID $GitHubUser -GitHubToken $GitHubToken | ForEach-Object {$ModuleLists.Add($_)}

$InstallList = @()
Write-Host ' '
Write-Host 'Please select the list of Modules to install'
Write-Host ' '

do {
	Clear-Host
	$select = $null
	$index = 0
	foreach ($Mod in $ModuleLists) {
		Write-Host "$($index) ) " -ForegroundColor Yellow -NoNewline
		Write-Host "$($Mod.Name)" -ForegroundColor Cyan -NoNewline
		Write-Host ' - ' -ForegroundColor Yellow -NoNewline
		Write-Host "$($Mod.Description)" -ForegroundColor Gray
		$index++
	}
	Write-Host 'Q ) ' -ForegroundColor Yellow -NoNewline
	Write-Host 'Quit'
	Write-Host ' '
	Write-Host 'Current selected lists:' -NoNewline -ForegroundColor Green
	Write-Host ($($InstallList.Name) | Join-String -Separator ' ; ')
	[string]$select = Read-Host 'Select list'
	if ($select.ToUpper() -ne 'Q') {
		[int32]$sel = $select
		$InstallList += $ModuleLists[$sel]
		$ModuleLists.RemoveAt($sel)
	}
} while ($Select.ToUpper() -ne 'Q')
#endregion

$CommandParam = @{
	ListName        = $InstallList.Name
	Scope           = $scope
	AllowPrerelease = $PreRelease
	GitHubUserID    = $GitHubUser
}
if ($PublicGist) {$CommandParam.Add('PublicGist', $true)}
else {$CommandParam.Add('GitHubToken', $GitHubToken)}

Clear-Host
Install-PWSHModule @CommandParam

Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
Write-Host '[Complete]: ' -NoNewline -ForegroundColor Yellow
Write-Host 'App Install Complete' -ForegroundColor Green

