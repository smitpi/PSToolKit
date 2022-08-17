
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
Creates reports based on PSGallery.

#>
<#
.SYNOPSIS
Creates reports based on PSGallery.

.DESCRIPTION
Creates reports based on PSGallery. You can search for a keyword, and also exclude azure and aws modules.

.PARAMETER Keyword
Limit the search to a keyword.

.PARAMETER NoAzureAWS
This will exclude modules with AWS and Azure in the name.

.PARAMETER MaxCount
Limit the amount of modules to report, default is 250.

.PARAMETER Offline
Uses a previously downloaded cache for the search. If the cache doesn't exists, it will be created.

.PARAMETER UpdateCache
Update the local cache.

.PARAMETER SortOrder
Determines if the report will be sorted on the amount of downloads or the newest modules.

.PARAMETER Export
Export the result to a file. (Excel or markdown)

.PARAMETER ReportPath
Where to save the report.

.PARAMETER DownloadJeffReport
Downloads Jeff Hicks reports from GitHub.

.EXAMPLE
Find-OnlineModule -Keyword Citrix -Offline -SortOrder Downloads -Export Excel -ReportPath C:\temp

#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	[OutputType([System.Object[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	PARAM(
		[Parameter(Position = 0)]
		[string]$Keyword,
		[switch]$NoAzureAWS,
		[int]$MaxCount = 250,
		[switch]$Offline,
		[switch]$UpdateCache,
		[validateset('Newest', 'Downloads')]
		[string]$SortOrder = 'Downloads',
		[ValidateSet('Excel', 'Markdown', 'Host')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
		[switch]$DownloadJeffReport

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
			$AllImport = Import-Clixml -Path "$env:TEMP\psgallery.xml"
  }
	} else {
		Write-Host "[$(Get-Date)] Going Online" -ForegroundColor yellow
		$AllImport = Find-Module -Repository PSGallery
	}

	if ($NoAzureAWS) {
		$FilteredImport = $AllImport | Where-Object {
			$_.name -notmatch '(AWS)|(Azure)' -and 
			$_.Author -notmatch '(microsoft)|(amazon)'
		}
	} else {
		$FilteredImport = $AllImport
	}
	if ($null -like $Keyword) {$ReportModules = $FilteredImport }
	else {
		$ReportModules = $FilteredImport | Where-Object {
			$_.name -like "*$Keyword*" -or 
			$_.Description -like "*$Keyword*" -or 
			$_.ReleaseNotes -like "*$Keyword*" -or 
			$_.Tags -like "*$Keyword*" -or 
			$_.Author -like "*$Keyword*" 
		}
	}

	[System.Collections.ArrayList]$NewObject = @()
	foreach ($RepMod in $ReportModules) {
		[void]$NewObject.Add([PSCustomObject]@{
				Name                 = $RepMod.Name
				Version              = $RepMod.Version
				Projecturi           = $RepMod.ProjectUri.OriginalString
				PublishedDate        = [datetime]$RepMod.PublishedDate
				DownloadCount        = [int32]$RepMod.AdditionalMetadata.downloadCount
				VersionDownloadCount = [int32]$RepMod.AdditionalMetadata.versionDownloadCount
				Authors              = $RepMod.Author
				Description          = $RepMod.Description
				ReleaseNotes         = $RepMod.ReleaseNotes
				tags                 = @($RepMod.Tags | Out-String).Trim()
			} )
	}

	if ($SortOrder -like 'Downloads') {$FinalReport = $NewObject | Sort-Object -Property downloadCount -Descending | Select-Object -First $MaxCount}
	else { $FinalReport = $NewObject | Sort-Object -Property PublishedDate -Descending | Select-Object -First $MaxCount }

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		if ($FinalReport) {
			$FinalReport | Export-Excel -Title 'PSGallery Modules' -WorksheetName Modules @ExcelOptions
		}
	}
	if ($Export -like 'Markdown') {
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add("# PowerShell Filtered: $($Keyword)`n")
		$fragments.Add("![PS](https://www.powershellgallery.com/Content/Images/Branding/psgallerylogo.svg)`n")
		foreach ($item in $FinalReport) {
			$galleryLink = "https://www.powershellgallery.com/Packages/$($item.name)/$($item.version)"
			#$fragments.Add("## <img src=`"https://e1.pngegg.com/pngimages/64/313/png-clipart-simply-styled-icon-set-731-icons-free-powershell-white-and-blue-logo-illustration-thumbnail.png`" align=`"left`" style=`"height: 10px`"/>")
			$fragments.Add(" [$($item.name)]($gallerylink) | $($item.version)`n")
			$fragments.Add("Published: $($item.PublishedDate) by $($item.Authors)`n")
			$fragments.Add("<span style='font-weight:Lighter;'>$($item.Description)</span>`n")
			$dl = '__TotalDownloads__: {0:n0}' -f [int64]($item.downloadCount)
			$vdl = '__VersionDownloads__: {0:n0}' -f [int64]($item.versionDownloadCount)
			$repo = "__Repository__: $($item.projecturi)"
			$Fragments.Add("$dl | $vdl | $repo`n")
			$Fragments.Add('---')
		}
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -Encoding utf8 -Force
		Show-Markdown "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -UseBrowser
	}
	if ($export -like 'Host') {$FinalReport}

	if ($DownloadJeffReport) {
	
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-filtered.md'
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-downloads.md'
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-downloads-community.md'

	}
}
