
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
Update local repository from GitHub

.DESCRIPTION
Update local repository from GitHub

.EXAMPLE
Update-PSToolKit

#>
Function Update-PSToolKit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKit')]
	PARAM(
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$AllUsers = $True
	)

	if ($AllUsers) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder"
		if ((Test-Path C:\Temp) -eq $false ) { New-Item -ItemType Directory -Path C:\Temp -Force | Out-Null }
		if ((Test-Path C:\Temp\private.zip) -eq $true ) { Remove-Item C:\Temp\private.zip -Force }

		$ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules', 'PSToolKit')
		if ((Test-Path $ModulePath  )) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder"
			Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath 'PSToolKit-BCK.zip') -Update
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder"
			Get-ChildItem -Directory $ModulePath | Remove-Item -Recurse -Force
		} else {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Creating Module directory"
			New-Item $ModulePath -ItemType Directory -Force | Out-Null
		}

		$PathFullName = Get-Item $ModulePath
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
		Invoke-WebRequest -Uri https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master -OutFile C:\Temp\private.zip
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
		Expand-Archive C:\Temp\private.zip C:\Temp
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] rename folder"

		Copy-Item -Path C:\Temp\PSToolKit-master\Output\* -Destination $PathFullName.FullName -Recurse
		Remove-Item C:\Temp\private.zip
		Remove-Item C:\Temp\PSToolKit-master -Recurse
	}
} #end Function
