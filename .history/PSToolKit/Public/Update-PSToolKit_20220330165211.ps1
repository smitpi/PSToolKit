
<#PSScriptInfo

.VERSION 0.1.0

.GUID c743ae0b-5478-4cae-b315-8fd4bf9dc974

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
Created [23/11/2021_10:55] Initial Script Creating

#>

<#

.DESCRIPTION
 Update local repository from GitHub

#>

<#
.SYNOPSIS
Update PSToolKit from GitHub.

.DESCRIPTION
Update PSToolKit from GitHub.

.PARAMETER AllUsers
Will update to the AllUsers Scope

.PARAMETER ForceUpdate
ForceUpdate the download and install.

.EXAMPLE
Update-PSToolKit

#>
Function Update-PSToolKit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKit')]
	PARAM(
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$AllUsers,
		[switch]$ForceUpdate = $false
	)

	if ($AllUsers) {
		$ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules', 'PSToolKit')
	} else {
		$ModulePath = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell', 'Modules', 'PSToolKit')
	}


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder $($env:tmp) "
	if ((Test-Path $env:tmp\private.zip) -eq $true ) { Remove-Item $env:tmp\private.zip -Force }

	if ((Test-Path $ModulePath)) {
		$InstalledVer = $OnlineVer = $null
		
		[version]$InstalledVer = (Get-ChildItem -Directory $ModulePath -ErrorAction SilentlyContinue | Sort-Object -Property Name -Descending)[0].Name
		[version]$OnlineVer = (Invoke-RestMethod 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/Version.json').version
		if ($InstalledVer -lt $OnlineVer) {
			$ForceUpdate = $true
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder to $(Join-Path -Path $ModulePath -ChildPath 'PSToolKit-BCK.zip')"
			Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath 'PSToolKit-BCK.zip') -Update
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder $($ModulePath)"
			Get-ChildItem -Directory $ModulePath | Remove-Item -Recurse -Force
		} else {
			Write-Host '[Updating]: ' -NoNewline -ForegroundColor Yellow; Write-Host "PSToolKit ($($OnlineVer.ToString())): " -ForegroundColor Cyan -NoNewline; Write-Host 'Already Up To Date' -ForegroundColor DarkRed
		}
	} else {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Creating Module directory $($ModulePath)"
		New-Item $ModulePath -ItemType Directory -Force | Out-Null
		$ForceUpdate = $true
	}

	if ($ForceUpdate) {
		$PathFullName = Get-Item $ModulePath
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
		if (Get-Command Start-BitsTransfer) {
			Start-BitsTransfer -Source 'https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master' -Destination "$env:tmp\private.zip"
		} else {
			Invoke-WebRequest -Uri https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master -OutFile $env:tmp\private.zip
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
		Expand-Archive $env:tmp\private.zip $env:tmp -Force

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Copying to $($PathFullName.FullName)"
		$NewModule = Get-ChildItem -Directory $env:tmp\PSToolKit-master\Output
		Copy-Item -Path $NewModule.FullName -Destination $PathFullName.FullName -Recurse

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Removing temp files"
		Remove-Item $env:tmp\private.zip
		Remove-Item $env:tmp\PSToolKit-master -Recurse
	}
	$ForceUpdate = $false
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete]"
	Import-Module PSToolKit -Force -ErrorAction SilentlyContinue
	Show-PSToolKit -ShowMetaData
} #end Function
