
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

.PARAMETER ConsoleOutput
How to display the results.

.PARAMETER MarkdownOutput
Export results to markdown file.

.EXAMPLE
Find-OnlineModule -Keyword Citrix -Offline -Output AsObject

#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	[OutputType([System.Object[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$Keyword,
		[switch]$Offline,
		[switch]$UpdateCache,
		[validateset('SortDownloads', 'SortDate', 'AsObject')]
		[String]$ConsoleOutput = 'AsObject',
		[validateset('SortDownloads', 'SortDate')]
		[String]$MarkdownOutput
	)

	if ($UpdateCache) {
        Write-Host "[$(Get-Date)] Updating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
		$cache = Find-Module -Repository PSGallery
		$cache | Export-Clixml -Path "$env:TEMP\psgallery.xml"
	}

	if ($Offline -or $UpdateCache) {
		if (-not(Test-Path "$env:TEMP\psgallery.xml")) {
        Write-Host "[$(Get-Date)] Creating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
			$AllImport = Find-Module -Repository PSGallery
			$AllImport | Export-Clixml -Path "$env:TEMP\psgallery.xml"
		} else {
            Write-Host "[$(Get-Date)] Using cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
            $AllImport = Import-Clixml -Path "$env:TEMP\psgallery.xml"}
	} else {
            Write-Host "[$(Get-Date)] Going Online" -ForegroundColor yellow
            $AllImport = Find-Module -Repository PSGallery
   }


if ($null -like $Keyword) {$ReportModules = $AllImport }
else {$ReportModules  = $AllImport | Where-Object {$_.name -like "*$Keyword*" -or $_.Description -like "*$Keyword*" -or $_.ReleaseNotes -like "*$Keyword*" -or $_.Tags -like "*$Keyword*" -or $_.Author -like "*$Keyword*" }}

	[System.Collections.ArrayList]$NewObject = @()
	foreach ($RepMod in $ReportModules) {
		[void]$NewObject.Add(		[PSCustomObject]@{
				Name                 = $RepMod_.Name
				Version              = $RepMod_.Version
                Description          = $RepMod_.Description
                projecturi           = $RepMod_.ProjectUri.OriginalString
				PublishedDate        = [datetime]$RepMod_.PublishedDate
				downloadCount        = [int32]$RepMod_.AdditionalMetadata.downloadCount
				versionDownloadCount = [int32]$RepMod_.AdditionalMetadata.versionDownloadCount
				#UpdatedDate          = [datetime]$_.AdditionalMetadata.updated
				Authors              = $RepMod_.Author
				releaseNotes         = $RepMod_.ReleaseNotes
				tags                 = $RepMod_.Tags
			} )
	}
	if ($ConsoleOutput -like 'SortDownloads') {$NewObject | Sort-Object -Property downloadCount -Descending | Format-Table -AutoSize}
	if ($ConsoleOutput -like 'SortDate') {$NewObject | Sort-Object -Property PublishedDate -Descending | Format-Table -AutoSize}
	if ($ConsoleOutput -like 'AsObject') {$NewObject}
	if ($MarkdownOutput -like 'SortDownloads') {$MarkObject = $NewObject | Sort-Object -Property downloadCount -Descending}
	if ($MarkdownOutput -like 'SortDate') {$MarkObject = $NewObject | Sort-Object -Property PublishedDate -Descending }
    if ($MarkdownOutput -like 'SortDate' -or $MarkdownOutput -like 'SortDownloads') {

                $fragments = [system.collections.generic.list[string]]::new()
                $fragments.Add("# PowerShell Filtered:$($Keyword)`n")
                $fragments.Add("![PS](https://www.powershellgallery.com/Content/Images/Branding/psgallerylogo.svg)`n")
                foreach ($item in $MarkObject) {
                    $galleryLink = "https://www.powershellgallery.com/Packages/$($item.name)/$($item.version)"
                    $fragments.Add("## <img src=`"https://e1.pngegg.com/pngimages/64/313/png-clipart-simply-styled-icon-set-731-icons-free-powershell-white-and-blue-logo-illustration-thumbnail.png`" align=`"left`" style=`"height: 32px`"/>")
                    $fragments.Add(" [$($item.name)]($gallerylink) | $($item.version)`n")
                    $fragments.Add("Published: $($item.PublishedDate) by $($item.Authors)`n")
                    $fragments.Add("<span style='font-weight:Lighter;'>$($item.Description)</span>`n")
                    $dl = "__Downloads__: {0:n0}" -f [int64]($item.versionDownloadCount)
                    $repo = "__Repository__: $($item.projecturi)"
                    $Fragments.Add("$dl | $repo`n")
                    $Fragments.Add("---")
                }

                $fragments.add("*Updated: $(Get-Date -Format U) UTC*")
                Write-Host "[$(Get-Date)] Saving report to $($env:TEMP)\PSGallery-$($Keyword).md" -ForegroundColor yellow
                #need to make sure files are encoded to UTF8 for future PDF conversion
                $fragments | Out-File "$($env:TEMP)\PSGallery-$($Keyword).md" -Encoding utf8 -Force
                . "$($env:TEMP)\PSGallery-$($Keyword).md"
                
}
}
