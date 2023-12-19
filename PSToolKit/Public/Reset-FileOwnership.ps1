
<#PSScriptInfo

.VERSION 0.1.0

.GUID b532d3ac-01a2-4986-881e-4dc076a7de4c

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [10/08/2023_09:14] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Reset the ownership of a directory and add full control to the folder. 

#> 



<#
.SYNOPSIS
Reset the ownership of a directory and add full control to the folder.

.DESCRIPTION
Reset the ownership of a directory and add full control to the folder.

.PARAMETER Path
Path to the folder to reset ownership.

.PARAMETER Credentials
The account to grant full control.

.EXAMPLE
Reset-FileOwnership -Path C:\temp -Credentials $Admin

#>
Function Reset-FileOwnership {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Reset-FileOwnership')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[Parameter(Position = 0,Mandatory,ValueFromPipeline)]
		[alias('Directory')]
		[ValidateScript( { (Test-Path $_)})]
		[System.IO.DirectoryInfo[]]$Path,
					
		[Parameter(Position = 1)]
		[pscredential]$Credentials = (Get-Credential -Message 'User to be given access')
	)
	#endregion
	foreach ($Folder in $Path) {
		$Fullpath = Get-Item $Folder
		$UserName = $Credentials.UserName
		cmd /c "takeown /A /F $($Fullpath.FullName) /R /D y" 2>&1 | Write-Host -ForegroundColor Cyan
		cmd /c "icacls $($Fullpath.FullName) /grant $($UserName):F /t" 2>&1 | Write-Host -ForegroundColor Yellow
	}
} #end Function
