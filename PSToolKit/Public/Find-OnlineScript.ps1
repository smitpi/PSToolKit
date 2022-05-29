
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
			[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'

		)

		if ($UpdateCache) {
			Write-Host "[$(Get-Date)] Updating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
			$cache = Find-Script -Repository PSGallery
			$cache | Export-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
		}

		if ($Offline -or $UpdateCache) {
			if (-not(Test-Path "$env:TEMP\psgallery-scripts.xml")) {
				Write-Host "[$(Get-Date)] Creating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
				$AllImport = Find-Script -Repository PSGallery
				$AllImport | Export-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
			} else {
				Write-Host "[$(Get-Date)] Using cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
				$AllImport = Import-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
			}
		} else {
			Write-Host "[$(Get-Date)] Going Online" -ForegroundColor yellow
			$AllImport = Find-Script -Repository PSGallery
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
				Path             = $(Join-Path -Path $ReportPath -ChildPath "\PSGallery-scripts-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
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
				$fragments.Add("## <img src=`"https://e1.pngegg.com/pngimages/64/313/png-clipart-simply-styled-icon-set-731-icons-free-powershell-white-and-blue-logo-illustration-thumbnail.png`" align=`"left`" style=`"height: 32px`"/>")
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
			$fragments | Out-File "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-scripts-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -Encoding utf8 -Force
		}
		if ($export -like 'Host') {$FinalReport}
}

