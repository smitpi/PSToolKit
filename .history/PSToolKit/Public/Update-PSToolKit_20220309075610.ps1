﻿
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
	PARAM()

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder"
	if ((Test-Path C:\Temp) -eq $false ) { New-Item -ItemType Directory -Path C:\Temp -Force | Out-Null }
	if ((Test-Path C:\Temp\private.zip) -eq $true ) { Remove-Item C:\Temp\private.zip -Force }

	$ModulePath = [IO.Path]::Combine($env:ProgramFiles,"WindowsPowerShell","Modules","PSToolKit")
	if ((Test-Path $ModulePath  )) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder"
		Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath "PSToolKit-BCK.zip")  -Update
		Get-ChildItem -Directory 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit' | Remove-Item -Recurse -Force

		Compress-Archive (Join-Path $psfolder.FullName '\Modules\PSToolKit') (Join-Path $psfolder.FullName "\Modules\$(Get-Date -Format yyyy-MM-dd)_PSToolKit.zip") -Force
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder"
		Remove-Item (Join-Path $psfolder.FullName '\Modules\PSToolKit') -Recurse -Force
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
	Invoke-WebRequest -Uri https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master -OutFile C:\Temp\private.zip
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
	Expand-Archive C:\Temp\private.zip C:\Temp
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] rename folder"
	$newfolder = New-Item -Path	(Join-Path $psfolder.FullName '\Modules') -Name PSToolKit -ItemType Directory -Force
	Copy-Item -Path C:\Temp\PSToolKit-master\Output\* -Destination $newfolder.FullName -Recurse
	Remove-Item C:\Temp\private.zip
	Remove-Item C:\Temp\PSToolKit-master -Recurse
} #end Function