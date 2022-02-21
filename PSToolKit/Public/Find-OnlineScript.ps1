
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0b568f7e-3d5f-427c-854f-440e22c1e530

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
Find Script on PSGallery

#>

<#
.SYNOPSIS
Find Script on PSGallery

.DESCRIPTION
Find Script on PSGallery

.PARAMETER Keyword
What to search for

.PARAMETER install
Install selected script

.EXAMPLE
Find-OnlineScript -Keyword blah -install

.NOTES
General notes
#>
function Find-OnlineScript {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineScript')]
	PARAM(
		[string]$Keyword,
		[switch]$install = $false
	)

	$selectedscript = Find-Script -Filter $Keyword -Repository PSGallery | Select-Object * | ForEach-Object {
		[PSCustomObject]@{
			Name                 = $_.Name
			Version              = $_.Version
			PublishedDate        = $_.PublishedDate
			UpdatedDate          = $_.AdditionalMetadata.lastUpdated
			downloadCount        = [int32]$_.AdditionalMetadata.downloadCount
			versionDownloadCount = [int32]$_.AdditionalMetadata.versionDownloadCount
			Authors              = $_.Author
			tags                 = $_.Tags
			summary              = $_.AdditionalMetadata.summary
		} | Select-Object Name, Version, PublishedDate, UpdatedDate , downloadCount, versionDownloadCount, Authors, tags, summary
	} | Sort-Object -Property downloadCount -Descending | Out-GridView -OutputMode Multiple

	if ($install) {
		foreach ($item in $selectedscript) {
			Install-Script -Name $item.name -Scope CurrentUser -AcceptLicense
		}
	}
}

