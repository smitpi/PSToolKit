
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

.PARAMETER AsObject
Format output as object.

.EXAMPLE
Show-MyPSGalleryModules

#>
Function Show-MyPSGalleryModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-MyPSGalleryModules')]
	[OutputType([System.Collections.generic.List[PSObject]])]
	PARAM(
		[switch]$AsObject
	)
	Write-PSMessage -Action Collecting -BeforeMessage "PSGallery Modules" -BeforeMessageColor Gray -InsertTabs 1 -LinesAfter 2
	$ModLists = Find-Module -Repository PSGallery | Where-Object {$_.author -like 'Pierre Smit'}
	[System.Collections.generic.List[PSObject]]$GalStats = @()
	foreach ($Mod in $ModLists) {
		$GithubDetails = $null
		Write-PSMessage -Action 'Collecting' -Object $mod.name -Message 'Online Data' -MessageColor Gray
		$TotalDownloads = $TotalDownloads + [int]$Mod.AdditionalMetadata.downloadCount
		$GithubDetails = Invoke-RestMethod -Method Get -Uri "https://raw.githubusercontent.com/smitpi/$($Mod.name)/master/Version.json"
		$GalStats.Add([PSCustomObject]@{
				DateCollected    = ([datetime](Get-Date -Format U)).ToUniversalTime()
				Name             = $Mod.Name
				GithubVersion    = [version]$GithubDetails.version
				PublishedVersion = $Mod.Version
				GithubDate       = [datetime]$GithubDetails.date
				PublishedDate    = ([datetime]$Mod.AdditionalMetadata.published).ToUniversalTime()
				TotalDownload    = [Int]$Mod.AdditionalMetadata.downloadCount
				VersionDownload  = [Int]$Mod.AdditionalMetadata.versionDownloadCount
			})
	}
	If ($AsObject) {$GalStats}
	else {
		Write-PSMessage -Action Complete -BeforeMessage "Total Downloads:" -BeforeMessageColor Gray -Object $TotalDownloads -InsertTabs 1 -LinesBefore 2 -LinesAfter 1
		$GalStats | Format-Table -AutoSize -Wrap
	}
} #end Function
