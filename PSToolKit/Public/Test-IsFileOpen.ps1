
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

.PARAMETER FilterOpen
Only show open files.

.EXAMPLE
dir | Test-IsFileOpen


#>
Function Test-IsFileOpen {
	[Cmdletbinding( HelpURI = 'https://smitpi.github.io/PSToolKit/Test-IsFileOpen')]
	[OutputType([System.Object[]])]
	PARAM(
		[parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Alias('FullName')]
		[string[]]$Path
	)
	Begin {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"

		# $checkhandle = "$($env:TEMP)\handle.exe"
		# if (-not(test-path $checkhandle)) {
		# 	Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/Handle.zip' -OutFile "$($env:TEMP)\handle.zip"
		# 	Expand-Archive  -Path "$($env:TEMP)\handle.zip" -DestinationPath "$($env:TEMP)"
		# 	Set-ItemProperty -Path 'HKCU:\Software\Sysinternals' -Name 'EulaAccepted' -Value 1 -Force
		# }

		# $splitter = '------------------------------------------------------------------------------'
		# $handleProcess = ((& "$($env:TEMP)\handle.exe") -join "`n") -split $splitter | Where-Object {$_ -match [regex]::Escape($File) }

		

		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Collecting Processes"
		$AllProcess = foreach ($proc in (Get-Process)) {
			foreach ($module in $proc.modules) {
				[pscustomobject]@{
					ProcessName = $proc.ProcessName
					MainModule  = $proc.MainModule
					Parent      = $proc.Parent
					ID          = $proc.id
					FileName    = $module.filename
				}
			}
		}
	}
	Process {
		ForEach ($Item in $Path) {
			#Ensure this is a full path
			$Item = Convert-Path $Item
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Checking File: $($Item)"
			#Verify that this is a file and not a directory
			If ([System.IO.File]::Exists($Item)) {
				Try {
					$FileStream = [System.IO.File]::Open($Item, 'Open', 'Write')
					$FileStream.Close()
					$FileStream.Dispose()
				} Catch [System.UnauthorizedAccessException] {
					[pscustomobject]@{
						File        = $Item
						Status      = 'AccessDenied'
						ProcessName = ($AllProcess | Where-Object {$_.FileName -like $item }).ProcessName
						ID          = ($AllProcess | Where-Object {$_.FileName -eq $item }).id		
					}		
				} Catch { 
					[pscustomobject]@{
						File        = $Item
						Status      = 'Locked'
						ProcessName = ($AllProcess | Where-Object {$_.FileName -like $Item }).ProcessName
						ID          = ($AllProcess | Where-Object {$_.FileName -eq $item }).id				
					}
				}
			}
		}
	}
} #end Function

