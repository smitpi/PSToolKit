
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
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER InputObject
Data  for the report.

.PARAMETER ReportTitle
Title of the report.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Write-PSToolKitReport -InputObject $data -ReportTitle "Temp Data" -Export HTML -ReportPath C:\temp

#>
Function Write-PSToolKitReport {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitReport')]
	[OutputType([System.Object[]])]
	PARAM(
		[PSCustomObject]$InputObject,
		[string]$ReportTitle,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export,

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	$members = ($InputObject | Get-Member -MemberType Property, NoteProperty).Name

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))_$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}

		foreach ($member in $members) {
			if ($InputObject.$member) {$InputObject.$member | Export-Excel -Title $member -WorksheetName $member @ExcelOptions}
		}
	}
		if ($Export -eq 'HTML') { 
			$script:TableSettings = @{
				Style           = 'cell-border'
				TextWhenNoData  = 'No Data to display here'
				Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
				FixedHeader     = $true
				HideFooter      = $true
				SearchHighlight = $true
				PagingStyle     = 'full'
				PagingLength    = 10
			}
			$script:SectionSettings = @{
				BackgroundColor       = 'grey'
				CanCollapse           = $true
				HeaderBackGroundColor = '#2b1200'
				HeaderTextAlignment   = 'center'
				HeaderTextColor       = '#f37000'
				HeaderTextSize        = '15'
				BorderRadius          = '20px'
			}
			$script:TableSectionSettings = @{
				BackgroundColor       = 'white'
				CanCollapse           = $true
				HeaderBackGroundColor = '#f37000'
				HeaderTextAlignment   = 'center'
				HeaderTextColor       = '#2b1200'
				HeaderTextSize        = '15'
			}
			$script:TabSettings = @{
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
	} #end Function
