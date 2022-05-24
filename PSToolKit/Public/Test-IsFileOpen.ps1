
<#PSScriptInfo

.VERSION 0.1.0

.GUID 39b99519-f58b-4898-bb1c-c75d26db4593

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
Created [24/05/2022_01:17] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Checks if a file is open

#>


<#
.SYNOPSIS
Checks if a file is open

.DESCRIPTION
Checks if a file is open

.PARAMETER Path
Path to the file to check.

.EXAMPLE
dir | Test-IsFileOpen


#>
Function Test-IsFileOpen {
	[Cmdletbinding( HelpURI = 'https://smitpi.github.io/PSToolKit/Test-IsFileOpen')]
	[OutputType([System.Object[]])]
	PARAM(
		[parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Alias('FullName')]
		[string[]]$Path,
		[switch]$FilterOpen = $False
	)
	Process {
		ForEach ($Item in $Path) {
			#Ensure this is a full path
			$Item = Convert-Path $Item
			#Verify that this is a file and not a directory
			If ([System.IO.File]::Exists($Item)) {
				Try {
					$FileStream = [System.IO.File]::Open($Item, 'Open', 'Write')
					$FileStream.Close()
					$FileStream.Dispose()
					$IsLocked = $False
				} Catch [System.UnauthorizedAccessException] {$IsLocked = 'AccessDenied'}
				Catch { $IsLocked = $True}
				$result = [pscustomobject]@{
					File     = $Item
					IsLocked = $IsLocked
				}
				if ($FilterOpen) {
					if ($result.IsLocked -eq $True) {$result}
				}
				else {$result}
			}
		}
	}
} #end Function
