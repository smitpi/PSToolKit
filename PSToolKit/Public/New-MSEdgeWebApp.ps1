
<#PSScriptInfo

.VERSION 0.1.0

.GUID bce5d07e-605f-40e4-975d-cd5de23daf5f

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
Created [19/12/2022_16:08] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Creates a new webapp to a URL, and save the shortcut on your system. 

#> 


<#
.SYNOPSIS
Creates a new webapp to a URL, and save the shortcut on your system.

.DESCRIPTION
Creates a new webapp to a URL, and save the shortcut on your system.

.parameter AppName
The name of the webapp

.parameter URL
The URL of the webapp.

.parameter IconPath
Path to the icon to be used.

.parameter Path
The path to save the shortcut to.

.EXAMPLE
New-MSEdgeWebApp -AppName vcsa -URL https://linktovmware.com -Path c:\temp

#>
Function New-MSEdgeWebApp {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-MSEdgeWebApp')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[parameter(Mandatory, Position = 0)]
		[string]$AppName,

		[Parameter(Mandatory, Position = 1)]
		[string]$URL,

		[ValidateScript( { if ((Get-Item $_).Extension -eq '.ico' -or (Get-Item $_).Extension -eq '.exe') { $true }
				else { throw 'Invalid: Need a .ico or .exe file' } })]
		[System.IO.FileInfo]$IconPath,
					
		[ValidateScript( { if (Test-Path $_) { $true }
				else {
					Write-Warning 'Folder does not exist, creating folder now.'
					New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true 
				}
			})]
		[System.IO.DirectoryInfo]$Path = 'C:\Temp'
	)
	#endregion
	Begin {
		Write-Verbose '[16:08:48 BEGIN] Starting New-PSScript'

	} #End Begin
	Process {
		$WScriptShell = New-Object -ComObject WScript.Shell
		$lnkfile = Join-Path -Path $Path -ChildPath "$($AppName).lnk"
		$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
		$MSEdgePath = Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		$Shortcut.TargetPath = $MSEdgePath.FullName
		$Shortcut.Arguments = "--app=`"$($URL)`""

		$FullIconPath = Get-Item $IconPath
		if ($fullIconPath.extension -eq '.ico' -or $fullIconPath.extension -eq '.exe') {
			$Shortcut.IconLocation = $FullIconPath.FullName
		} else {
			$IconLocation = 'C:\windows\System32\SHELL32.dll'
			$IconArrayIndex = 27
			$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
		}
		#Save the Shortcut to the TargetPath
		$Shortcut.Save()
	}#Process

	End {
		Write-Verbose '[16:08:48 END] Complete'
	}#End End
} #end Function
