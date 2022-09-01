
<#PSScriptInfo

.VERSION 0.1.0

.GUID d46505a3-18d6-4cd7-b664-5ca9e6891a26

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
Created [01/09/2022_06:59] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Show version numbers ext. about my modules 

#> 


<#
.SYNOPSIS
Show version numbers ext. about my modules.

.DESCRIPTION
Show version numbers ext. about my modules.

.PARAMETER AsTable
Format output as table.

.EXAMPLE
Show-MyPSGalleryModules

#>
Function Show-MyPSGalleryModules {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Show-MyPSGalleryModules')]
	[OutputType([System.Collections.generic.List[PSObject]])]
	PARAM(
		[switch]$AsTable
	)
	$ModLists = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule')
	[System.Collections.generic.List[PSObject]]$GalStats = @()
	foreach ($Mod in $ModLists) {
		Write-PSToolKitMessage -Action 'Collecting' -Object $mod -Message 'Online Data' -MessageColor Gray
		$ResultModule = Find-Module $mod -Repository PSGallery
		$TotalDownloads = $TotalDownloads + [int]$ResultModule.AdditionalMetadata.downloadCount
		$GithubDetails = Invoke-RestMethod "https://raw.githubusercontent.com/smitpi/$($Mod)/master/Version.json"
		[void]$GalStats.Add([PSCustomObject]@{
				DateCollected   = ([datetime](Get-Date -Format U)).ToUniversalTime()
				Name            = $ResultModule.Name
				Version         = $ResultModule.Version
				GithubVersion   = [version]$GithubDetails.version
				GithubDate      = [datetime]$GithubDetails.date
				PublishedDate   = ([datetime]$ResultModule.AdditionalMetadata.published).ToUniversalTime()
				TotalDownload   = [Int]$ResultModule.AdditionalMetadata.downloadCount
				VersionDownload = [Int]$ResultModule.AdditionalMetadata.versionDownloadCount
			})
	}
If ($AsTable) {$GalStats | Format-Table -AutoSize -Wrap}
else {$GalStats}
} #end Function
