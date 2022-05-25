
<#PSScriptInfo

.VERSION 0.1.0

.GUID 41b9f92e-f797-4153-ad6f-9def2606abdc

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
Created [25/05/2022_03:04] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Will change the icon of a folder to a custom selected icon 

#> 

<#
.SYNOPSIS
Will change the icon of a folder to a custom selected icon

.DESCRIPTION
Will change the icon of a folder to a custom selected icon

.PARAMETER FolderPath
Path to the folder to be changed.

.PARAMETER CustomIconPath
Path to the .ico, .exe, .icl or .dll file, containing the icon.

.PARAMETER Index
The index of the icon in the file.

.EXAMPLE
Set-FolderCustomIcon -FolderPath C:\temp -CustomIconPath C:\WINDOWS\System32\SHELL32.dll -Index 27

.NOTES
General notes
#>
Function Set-FolderCustomIcon {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-FolderCustomIcon')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { if (Test-Path $_) { $true } })]
		[System.IO.DirectoryInfo]$FolderPath,
		[ValidateScript( { if ((Test-Path $_) -and ((Get-Item $_).Extension -in @('.exe', '.ico', '.icl', '.dll'))) {$true} })]
		[string]$CustomIconPath,
		[int32]$Index
	)

	try {
		[System.IO.FileInfo]$CustomIconPath = Get-Item $CustomIconPath
		if ($index) {
			$fullicon = "$($CustomIconPath.FullName),$($Index)"
		} else {
			$fullicon = "$($CustomIconPath.FullName),0"
		}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

	$DesktopIni = @"
[.ShellClassInfo]
IconResource= $($fullicon)
"@
	try {
		#Create/Add content to the desktop.ini file
		if (Test-Path (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini')) {Remove-Item (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini') -Force -ErrorAction SilentlyContinue}
		$newini = New-Item -Path (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini') -ItemType File -Value $DesktopIni
  
		#Set the attributes for $DesktopIni
		$newini.Attributes = 'Hidden, System, Archive'
 
		#Finally, set the folder's attributes
		$(Get-Item $FolderPath).Attributes = 'ReadOnly, Directory'
		#endregion
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
} #end Function