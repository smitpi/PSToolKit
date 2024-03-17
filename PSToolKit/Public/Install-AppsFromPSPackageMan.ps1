
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6bc2f978-1dc0-4d09-8388-509c7948ef90

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
Created [17/03/2024_13:51] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Uses the module PSPackageMan to install apps from a GitHub Gist File 

#> 


<#
.SYNOPSIS
Uses the module PSPackageMan to install apps from a GitHub Gist File.

.DESCRIPTION
Uses the module PSPackageMan to install apps from a GitHub Gist File.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Install-AppsFromPSPackageMan  -GitHubUserID $user -PublicGist

#>
Function Install-AppsFromPSPackageMan {
	[Cmdletbinding(DefaultParameterSetName = 'Public', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-AppsFromPSPackageMan')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[string]$GitHubUserID, 
		[Parameter(ParameterSetName = 'Public')]
		[switch]$PublicGist,
		[Parameter(ParameterSetName = 'Private')]
		[string]$GitHubToken				
	)
	#endregion

	# ##################################
	# #region Check Admin
	# ##################################
	# 	# Get the ID and security principal of the current user account
	# 	$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	# 	$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

	# 	# Get the security principal for the Administrator role
	# 	$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

	# 	# Check to see if we are currently running "as Administrator"
	# 	if (-not($myWindowsPrincipal.IsInRole($adminRole))) {
	# 		$newProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
	# 		$newProcess.Arguments = $myInvocation.MyCommand.Definition
	# 		$newProcess.Verb = 'runas'
	# 		[System.Diagnostics.Process]::Start($newProcess)
	# 		exit
	# 	}
	# #endregion

	$RequiredModules = @(
		'PSPackageMan'
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

	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Latest Winget`n" -ForegroundColor Cyan
	if (-not(Get-Command winget.exe -ErrorAction SilentlyContinue)) {
		Invoke-RestMethod https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | Invoke-Expression
	}

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
		Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan; Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Installing Latest Chocolatey Client`n" -ForegroundColor Cyan
		Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
		$web = New-Object System.Net.WebClient
		$web.DownloadFile('https://community.chocolatey.org/install.ps1', "$($env:TEMP)\choco-install.ps1")
		& "$($env:TEMP)\choco-install.ps1" | Out-Null

		if (Get-Command choco -ErrorAction SilentlyContinue) {
			Write-Color '[Installing] ', 'Chocolatey Client: ', 'Complete' -Color Yellow, Cyan, Green
			choco config set --name="'useEnhancedExitCodes'" --value="'true'" --limit-output
			choco config set --name="'allowGlobalConfirmation'" --value="'true'" --limit-output
			choco config set --name="'removePackageInformationOnUninstall'" --value="'true'" --limit-output
		}
	}
	if (-not($PSBoundParameters.ContainsKey('GitHubUser'))) {
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
	}

	[System.Collections.generic.List[PSObject]]$AppLists = @()
	Get-PSPackageManAppList -GitHubUserID $GitHubUser -GitHubToken $GitHubToken | ForEach-Object {$AppLists.Add($_)}

	$InstallList = @()
	Write-Host ' '
	Write-Host 'Please select the list of Apps to install'
	Write-Host ' '

	do {
		Clear-Host
		$select = $null
		$index = 0
		foreach ($App in $AppLists) {
			Write-Host "$($index) ) " -ForegroundColor Yellow -NoNewline
			Write-Host "$($App.Name)" -ForegroundColor Cyan -NoNewline
			Write-Host ' - ' -ForegroundColor Yellow -NoNewline
			Write-Host "$($App.Description)" -ForegroundColor Gray
			$index++
		}
		Write-Host 'Q ) ' -ForegroundColor Yellow -NoNewline
		Write-Host 'Quit'
		Write-Host ' '
		Write-Host 'Current selected lists:' -NoNewline -ForegroundColor Green
		if (-not([string]::IsNullOrEmpty(($($InstallList))))) {
			Write-Host ($($InstallList.Name) | Join-String -Separator ' ; ')
		}		[string]$select = Read-Host 'Select list'
		if ($select.ToUpper() -ne 'Q') {
			[int32]$sel = $select
			$InstallList += $AppLists[$sel]
			$AppLists.RemoveAt($sel)
		}
	} while ($Select.ToUpper() -ne 'Q')

	$Settings = @{
		ListName     = $InstallList.Name
		GitHubUserID = $GitHubUser
	}
	if ($PublicGist) {$Settings.Add('PublicGist', $true)}
	else {$Settings.Add('GitHubToken', $GitHubToken)}

	Clear-Host
	Install-PSPackageManAppFromList @Settings


	Write-Host "`n`n-----------------------------------" -ForegroundColor DarkCyan
	Write-Host '[Complete]: ' -NoNewline -ForegroundColor Yellow
	Write-Host 'App Install Complete' -ForegroundColor Green




} #end Function
