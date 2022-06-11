
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
<#
.SYNOPSIS
Short desCreates a repository for offline installations.

.DESCRIPTION
Creates a repository for offline installations

.PARAMETER RepoName
Name of the local repository

.PARAMETER RepoPath
Path to the folder for the repository.

.PARAMETER ImportPowerShellGet
Downloads an offline copy of PowerShellGet

.PARAMETER DownloadModules
Downloads an existing json list of modules to the new repository.

.PARAMETER List
The base or extended json module list.

.PARAMETER ModuleNamesList
A string list of module names to download.

.EXAMPLE
Install-LocalPSRepository -RepoName repo -RepoPath c:\utils\repo -DownloadModules -List BaseModules

#>
Function Install-LocalPSRepository {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-LocalPSRepository')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[ValidateScript( { if (-not(Get-PSRepository -Name $_)) { $true }
				else { throw 'RepoName already exists' }
			})]
		[string]$RepoName,
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
		[switch]$DownloadModules,

		[Parameter(ParameterSetName = 'import')]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[string]$List = 'ExtendedModules',

		[Parameter(ParameterSetName = 'import', ValueFromPipeline)]
		[string[]]$ModuleNamesList
	)

	try {
		$options = @{
			Name                  = $RepoName 
			SourceLocation        = $RepoPath.FullName
			PublishLocation       = $RepoPath.FullName
			ScriptSourceLocation  = $RepoPath.FullName
			ScriptPublishLocation = $RepoPath.FullName
			InstallationPolicy    = 'Trusted'
		}
        Write-Color '[Installing] ',"Repo: ",$($RepoName), ' to folder: ', $($RepoPath) -Color Yellow, Cyan, Green, cyan, Green
		Register-PSRepository @options
	}
 catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }


	if ($ImportPowerShellGet) {
		try {
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGetDeploy")) { New-Item "$($env:TMP)\OfflinePowerShellGetDeploy" -ItemType Directory -Force | Out-Null }
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGet")) { New-Item "$($env:TMP)\OfflinePowerShellGet" -ItemType Directory -Force | Out-Null }

            Write-Color '[Installing] ',"OfflinePowerShellGetDeploy", " Module" -Color Yellow, Cyan,green
			Save-Module -Name OfflinePowerShellGetDeploy -Path "$($env:TMP)\OfflinePowerShellGetDeploy" -Repository PSGallery
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGetDeploy\*.psm1" -Recurse | Import-Module

            Write-Color '[Installing] ',"PowerShellGet", " Offline" -Color Yellow, Cyan,Green
			Save-PowerShellGetForOffline -LocalFolder "$($env:TMP)\OfflinePowerShellGet"
			
            Write-Color '[Uploading] ',"PackageManagement", " to ", $($RepoName) -Color Yellow, Cyan,Green,DarkRed
            Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PackageManagement.psd1" | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
            
            Write-Color '[Uploading] ',"PowerShellGet", " to ", $($RepoName) -Color Yellow, Cyan,Green,DarkRed
            Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PowerShellGet.psd1"  | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
		}
		catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }
	}
	if ($DownloadModules) {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		try {
			$ConPath = Get-Item $ConfigPath
		}
		catch { Write-Error 'Config path foes not exist'; exit }
		if ($List -like 'BaseModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) | ConvertFrom-Json).name }
		elseif ($List -like 'ExtendedModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) | ConvertFrom-Json).name }
		elseif ($ModuleNamesList) { $mods = $ModuleNamesList }

		if (-not($mods)) { throw 'Couldnt get a valid modules list'; exit }
		else {
			$mods | ForEach-Object {
				Write-Color '[Installing] ', $($_), ' to folder: ', $($RepoPath) -Color Yellow, Cyan, Green, cyan, Green, DarkRed
				Save-Package -Name $_ -Provider NuGet -Source https://www.powershellgallery.com/api/v2 -Path $RepoPath | Out-Null
			}
		}
	}
} #end Function
