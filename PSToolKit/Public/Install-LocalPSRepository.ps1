
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6d394bf5-f1ec-4902-a1f8-6fdf2160167b

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
Created [11/06/2022_23:50] Initial Script Creating

.PRIVATEDATA

#>
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates a repository for offline installations 

#> 



<#
.SYNOPSIS
Short desCreates a repository for offline installations.

.DESCRIPTION
Short desCreates a repository for offline installations.

.PARAMETER RepoName
Name of the local repository

.PARAMETER RepoPath
Path to the folder for the repository.

.PARAMETER ImportPowerShellGet
Downloads an offline copy of PowerShellGet

.EXAMPLE
Install-LocalPSRepository -RepoName repo -RepoPath c:\utils\repo

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
		[switch]$ImportPowerShellGet
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
		Write-Color '[Installing] ', 'Repo: ', $($RepoName), ' to folder: ', $($RepoPath) -Color Yellow, Cyan, Green, cyan, Green
		Register-PSRepository @options
	}
 catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }


	if ($ImportPowerShellGet) {
		try {
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGetDeploy")) { New-Item "$($env:TMP)\OfflinePowerShellGetDeploy" -ItemType Directory -Force | Out-Null }
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGet")) { New-Item "$($env:TMP)\OfflinePowerShellGet" -ItemType Directory -Force | Out-Null }

			Write-Color '[Installing] ', 'OfflinePowerShellGetDeploy', ' Module' -Color Yellow, Cyan, green
			Save-Module -Name OfflinePowerShellGetDeploy -Path "$($env:TMP)\OfflinePowerShellGetDeploy" -Repository PSGallery
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGetDeploy\*.psm1" -Recurse | Import-Module

			Write-Color '[Installing] ', 'PowerShellGet', ' Offline' -Color Yellow, Cyan, Green
			Save-PowerShellGetForOffline -LocalFolder "$($env:TMP)\OfflinePowerShellGet"
			
			Write-Color '[Uploading] ', 'PackageManagement', ' to ', $($RepoName) -Color Yellow, Cyan, Green, DarkRed
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PackageManagement.psd1" | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
            
			Write-Color '[Uploading] ', 'PowerShellGet', ' to ', $($RepoName) -Color Yellow, Cyan, Green, DarkRed
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PowerShellGet.psd1" | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
		}
		catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }
	}
} #end Function