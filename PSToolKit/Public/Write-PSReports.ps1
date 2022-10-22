
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3c9dc69d-98ff-46a7-ae8e-3aea6b7fafca

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
Created [06/09/2022_14:10] Initial Script

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module POSHTML5

<# 

.DESCRIPTION 
 Creates a excel or html report 

#> 


<#
.SYNOPSIS
Creates a excel or html report

.DESCRIPTION
Creates a excel or html report

.PARAMETER Export
Export the result to a report file. (Excel or html5 or normal html).

.PARAMETER InputObject
Data for the report.

.PARAMETER ExcelConditionalText
Add Conditional text color to the cells.

.PARAMETER ReportTitle
Title of the report.

.PARAMETER ReportPath
Where to save the report.

.PARAMETER OpenReportsFolder
Open the directory of creating the reports.

.EXAMPLE
$condition = New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' -PatternType Gray125
$condition += New-ConditionalText -Text 'Error' -ConditionalTextColor white -BackgroundColor red -Range 'E:E' -PatternType Gray125 

Write-PSReports -InputObject $data -ReportTitle "Temp Data" -Export HTML -ReportPath C:\temp

#>
Function Write-PSReports {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSReports')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Position = 0, Mandatory)]
		[PSCustomObject]$InputObject,
		
		[Parameter(Position = 1, Mandatory)]
		[string]$ReportTitle,

		[PSCustomObject]$ExcelConditionalText,

		[ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
		[string[]]$Export,

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
		[switch]$OpenReportsFolder
	)

	if ($Export -contains 'Excel') { $Excel = $True }
	if ($Export -contains 'HTML') {$HTML = $True }
	if ($Export -contains 'HTML5') {$HTML5 = $True }
	if ($Export -contains 'All') {$Excel = $HTML = $HTML5 = $True  }


	$members = ($InputObject.psobject.members | Where-Object {$_.MemberType -like '*Property*'}).Name

	if ($Excel) {  
		$ExcelOptions = @{
			Path              = $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))_$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize          = $True
			AutoFilter        = $True
			TitleBold         = $True
			TitleSize         = '28'
			TitleFillPattern  = 'LightTrellis'
			TableStyle        = 'Light20'
			FreezeTopRow      = $True
			FreezePane        = '3'
			FreezeFirstColumn = $True
			MaxAutoSizeRows   = 50
		}

		if ($ExcelConditionalText) {
			$ExcelOptions.Add('ConditionalText', $ExcelConditionalText)
		}

		foreach ($member in $members) {
			if ($InputObject.$member) {$InputObject.$member | Export-Excel -Title $member -WorksheetName $member @ExcelOptions -MaxAutoSizeRows 50 }
		}
	}
	if ($HTML) { 
		$TableSettings = @{
			Style           = 'cell-border'
			TextWhenNoData  = 'No Data to display here'
			Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
			FixedHeader     = $true
			HideFooter      = $true
			SearchHighlight = $true
			PagingStyle     = 'full'
			PagingLength    = 50
			AutoSize        = $true
			ScrollX         = $true
			ScrollCollapse  = $true
			ScrollY         = $true
			DisablePaging   = $true
		}
		$SectionSettings = @{
			BackgroundColor       = 'grey'
			CanCollapse           = $true
			HeaderBackGroundColor = '#2b1200'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#f37000'
			HeaderTextSize        = '15'
			BorderRadius          = '20px'
		}
		$TableSectionSettings = @{
			BackgroundColor       = 'white'
			CanCollapse           = $true
			HeaderBackGroundColor = '#f37000'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#2b1200'
			HeaderTextSize        = '15'
		}
		$TabSettings = @{
			TextTransform = 'uppercase'
			IconBrands    = 'mix'
			TextSize      = '16' 
			TextColor     = '#00203F'
			IconSize      = '16'
			IconColor     = '#00203F'
		}
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))_$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
			}
			foreach ($member in $members) {
				if ($InputObject.$member) {New-HTMLTab -Name $member @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $InputObject.$member @TableSettings}}}
			}
		}
	}
	if ($HTML5) {
		New-PWFPage -Title $($ReportTitle) -Content {
			New-PWFCardHeader -BackgroundColor '#fff' -Center -Content {New-PWFTitles -TitleText "$($ReportTitle)" -Size 1}
			New-PWFTabContainer -Tabs {
				foreach ($member in $members) {
					New-PWFTab -Name $member -Content {
						New-PWFRow -Content {
							New-PWFColumn -Content {
								New-PWFCard -BackgroundColor '#fff' -Content {
									New-PWFTitles -Size 3 -TitleText $member -Center
									New-PWFTable -ToTable ($InputObject.$member) -Pagination -DetailsOnClick -SortByColumn -ShowTooltip -EnableSearch -Exportbuttons -ContextualColor dark -Striped
								}
							}
						}
					}
				}
			}
		} | Out-File -Encoding utf8 -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))_HTML5_$(Get-Date -Format yyyy.MM.dd-HH.mm).html")
	}
	if ($OpenReportsFolder) {Start-Process -FilePath explorer.exe -ArgumentList $($ReportPath)}
} #end Function
