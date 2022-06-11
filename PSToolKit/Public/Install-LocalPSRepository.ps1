
<#PSScriptInfo

.VERSION 0.1.0

.GUID 40b7b319-2039-44cc-805a-2c02a1112940

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
Created [11/06/2022_05:40] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates a repository for offline installations 

#> 


<#
.SYNOPSIS
Creates a repository for offline installations

.DESCRIPTION
Creates a repository for offline installations

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Install-LocalPSRepository -Export HTML -ReportPath C:\temp

#>
Function Install-LocalPSRepository {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-LocalPSRepository')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[ValidateScript( { if (-not(Get-PSRepository -Name $_)) { $true }
				else { throw 'RepoName already exists' }
			})]
		[string[]]$RepoName,
		[Parameter(Mandatory)]
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$RepoPath,

		[Parameter(ParameterSetName = 'import')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$ImportPowerShellGet,

		[Parameter(ParameterSetName = 'import')]
		[switch]$ImportDirectory,
		[ValidateScript( { if (Test-Path $_) { $true }
				else { throw 'Invalid path' }
			})]
		[Parameter(ParameterSetName = 'import')]
		[System.IO.DirectoryInfo]$ImportPath
	)

	try {
		$options = @{
			Name                 = $RepoName 
			SourceLocation       = $RepoPath
			ScriptSourceLocation = $RepoPath
			InstallationPolicy   = 'Trusted'
		}
		Register-PSRepository @options -ErrorAction Stop
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}


	if ($ImportPowerShellGet) {
		if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGetDeploy")) {New-Item "$($env:TMP)\OfflinePowerShellGetDeploy" -ItemType Directory -Force | Out-Null}
		if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGet")) {New-Item "$($env:TMP)\OfflinePowerShellGet" -ItemType Directory -Force | Out-Null}


		Save-Module -Name OfflinePowerShellGetDeploy -Path "$($env:TMP)\OfflinePowerShellGetDeploy" -Repository PSGallery
		Get-ChildItem "$($env:TMP)\OfflinePowerShellGetDeploy\*.psm1" -Recurse | Import-Module

		Save-PowerShellGetForOffline -LocalFolder "$($env:TMP)\OfflinePowerShellGet"
		Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\*.psm1" | ForEach-Object {Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo'}

	}
	if ($ImportDirectory) {
			
	}


} #end Function
