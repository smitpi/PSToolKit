
<#PSScriptInfo

.VERSION 0.1.0

.GUID 71d4b9ce-6981-4adb-9ca5-917cb7565079

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ad

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [21/06/2022_05:27] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
Extract users from an AD group recursive, 4 levels deep.

#> 

<#
.SYNOPSIS
Extract users from an AD group recursive, 4 levels deep.

.DESCRIPTION
Extract users from an AD group recursive, 4 levels deep.

.PARAMETER GroupName
Name of the group to query. 
 
.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.
 
.PARAMETER ReportPath
Where to save the report.
 
.EXAMPLE
Get-NestedADGroupMembers -GroupName "Domain Admins"
 
#>
Function Get-NestedADGroupMember {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-NestedADGroupMembers')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript({Get-ADGroup $_})]
		[string]$GroupName,
 
		[ValidateSet('Excel', 'HTML', 'Host')]
		[string]$Export = 'Host',
 
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
 
	try {
		$GroupMemeber = (Get-ADGroup -Identity $GroupName -Properties *).members | ForEach-Object {
			Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) Level1 $($_)"
				if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
				else {
					Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
						Write-Verbose "`t[$(Get-Date -Format HH:mm:ss) Level2 $($_)"
						if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
						else {
							Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
								Write-Verbose "`t`t[$(Get-Date -Format HH:mm:ss) Level3 $($_)"
								if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
								else {
									Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
										Write-Verbose "`t`t`t[$(Get-Date -Format HH:mm:ss) Level4 $($_)"
										if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
										else {Get-ADGroup -Identity $_ -Properties * | Select-Object member -ExpandProperty member}
									}
								}
							}
						}
					}
				}
			}
		}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Nested_AD_Group_Members-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$GroupMemeber | Export-Excel -Title NestedADGroupMembers -WorksheetName NestedADGroupMembers @ExcelOptions
	}
 
	if ($Export -eq 'HTML') {
		if ($Export -eq 'HTML') { 
			$ReportTitle = 'Nested AD Group Members-'
 
			$TableSettings = @{
				SearchHighlight = $True
				Style           = 'cell-border'
				ScrollX         = $true
				HideButtons     = $true
				HideFooter      = $true
				FixedHeader     = $true
				TextWhenNoData  = 'No Data to display here'
				ScrollCollapse  = $true
				ScrollY         = $true
				DisablePaging   = $true
			}
			$SectionSettings = @{
				BackgroundColor       = 'LightGrey'
				CanCollapse           = $true
				HeaderBackGroundColor = '#00203F'
				HeaderTextAlignment   = 'center'
				HeaderTextColor       = '#ADEFD1'
				HeaderTextSize        = '15'
				BorderRadius          = '20px'
			}
			$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
			New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
				New-HTMLHeader {
					New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				}
				if ($GroupMemeber) {
					New-HTMLTab -Name 'Members' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
						New-HTMLSection @SectionSettings { New-HTMLTable -DataTable $($DefenderObj) @TableSettings}}
				}
			}
		}
	}
	if ($Export -eq 'Host') { $GroupMemeber }
} #end Function
