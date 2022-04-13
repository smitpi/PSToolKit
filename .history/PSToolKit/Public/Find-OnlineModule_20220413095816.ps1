
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
What to search for

.PARAMETER install
install selected searched module

.EXAMPLE
Find-OnlineModule -Keyword Citrix -install


#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	PARAM(
		[string]$Keyword,
		[switch]$Offline,
		[switch]$UpdateCache
	)

	if ($Offline){


	}
	if ($UpdateCache){

		
	}

	$selectedmod = Find-Module -Filter $Keyword -Repository PSGallery | Select-Object * | ForEach-Object {
		[PSCustomObject]@{
			Name                 = $_.Name
			Version              = $_.Version
			PublishedDate        = $_.PublishedDate
			UpdatedDate          = $_.AdditionalMetadata.updated
			downloadCount        = [int32]$_.AdditionalMetadata.downloadCount
			versionDownloadCount = [int32]$_.AdditionalMetadata.versionDownloadCount
			Authors              = $_.Author
			releaseNotes         = $_.ReleaseNotes
			tags                 = $_.Tags
			summary              = $_.AdditionalMetadata.summary
		} | Select-Object Name, version, PublishedDate, UpdatedDate , downloadCount, versionDownloadCount, Authors, releaseNotes, tags, summary
	} | Sort-Object -Property downloadCount -Descending | Out-GridView -OutputMode Multiple

	if ($install) {
		foreach ($item in $selectedmod) {
			Install-Module -Name $item.name -Scope CurrentUser -AllowClobber
			Get-Command -Module $item.name

		}
	}
}
