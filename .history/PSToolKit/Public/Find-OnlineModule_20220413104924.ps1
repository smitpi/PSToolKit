
<#PSScriptInfo

.VERSION 0.1.0

.GUID 8896cc83-9074-4514-a524-f5b40847adae

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
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Find a module on psgallery

#>
<#
.SYNOPSIS
Find a module on psgallery

.DESCRIPTION
Find a module on psgallery

.PARAMETER Keyword
What to search for.

.PARAMETER Offline
Uses a previously downloaded cache for the earch. If the cache doesnt exists, it will be created.

.PARAMETER UpdateCache
Update the local cache.

.PARAMETER Output
How to display the results.

.EXAMPLE
Find-OnlineModule -Keyword Citrix -Offline -Output AsObject

#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$Keyword,
		[switch]$Offline,
		[switch]$UpdateCache,
		[validateset('SortDownloads', 'SortDate', 'AsObject')]
		[String]$Output = 'AsObject'
	)

	if ($Offline) {
		if (-not(Test-Path "$env:TEMP\psgallery.xml")) {
			$AllImport = Find-Module -Repository PSGallery
			$AllImport | Export-Clixml -Path "$env:TEMP\psgallery.xml"
		} else {$AllImport = Import-Clixml -Path "$env:TEMP\psgallery.xml"}
	} else {$AllImport = Find-Module -Repository PSGallery}

	if ($UpdateCache) {
		$cache = Find-Module -Repository PSGallery
		$cache | Export-Clixml -Path "$env:TEMP\psgallery.xml"
	}


	[System.Collections.ArrayList]$NewObject = @()
	$AllImport | Where-Object {$_.name -like "*$Keyword*" -or $_.Description -like "*$Keyword*" -or $_.ReleaseNotes -like "*$Keyword*" -or $_.Tags -like "*$Keyword*" -or $_.Author -like "*$Keyword*" } | ForEach-Object {
		[void]$NewObject.Add(		[PSCustomObject]@{
				Name                 = $_.Name
				Version              = $_.Version
				PublishedDate        = [datetime]$_.PublishedDate
				downloadCount        = [int32]$_.AdditionalMetadata.downloadCount
				versionDownloadCount = [int32]$_.AdditionalMetadata.versionDownloadCount
				#UpdatedDate          = [datetime]$_.AdditionalMetadata.updated
				Authors              = $_.Author
				releaseNotes         = $_.ReleaseNotes
				tags                 = $_.Tags
				summary              = $_.AdditionalMetadata.summary
			} )
	}
	if ($Output -like 'SortDownloads') {$NewObject | Sort-Object -Property downloadCount -Descending | Format-Table -AutoSize}
	if ($Output -like 'SortDate') {$NewObject | Sort-Object -Property PublishedDate -Descending | Format-Table -AutoSize}
	if ($Output -like 'AsObject') {$NewObject}
	
}
