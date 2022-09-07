
<#PSScriptInfo

.VERSION 0.1.0

.GUID e5620f86-2289-4a06-91c7-2926dc68ecf2

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
Created [03/09/2022_19:42] Initial Script

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Script template for scripts to create reports 

#> 


<#
.SYNOPSIS
Script template for scripts to create reports

.DESCRIPTION
Script template for scripts to create reports

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
New-PSReportingScript -Export HTML -ReportPath C:\temp

#>
Function New-PSReportingScript {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSReportingScript')]
	[OutputType([System.Object[]])]
	param (
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$Path = $pwd,
		[Parameter(Mandatory = $True)]
		[ValidateScript( { Get-Verb -Verb $_ })]
		[ValidateNotNullOrEmpty()]
		[string]$Verb,
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[string]$Noun,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $true)]
		[string]$Description,
		[Parameter(Mandatory = $true)]
		[string[]]$tags)

	$checkpath = Get-Item $Path
	$ValidVerb = Get-Verb -Verb $Verb
	if ([bool]$ValidVerb -ne $true) { Write-Warning 'Script name is not valid, Needs to be in verb-noun format'; break }

	$properverb = (Get-Culture).TextInfo.ToTitleCase($Verb)
	$propernoun = $Noun.substring(0, 1).toupper() + $Noun.substring(1)

	try {
		$module = Get-Item (Join-Path $checkpath.Parent -ChildPath "$((Get-Item $checkpath.Parent).BaseName).psm1") -ErrorAction Stop
		$modulename = $module.BaseName
	} catch { Write-Warning 'Could not detect module'; $modulename = Read-Host 'Module Name: ' }


	$functionText = @"
<#
.SYNOPSIS
$Description

.DESCRIPTION
$Description

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$properverb-$propernoun -Export HTML -ReportPath C:\temp

#>
Function $properverb-$propernoun {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/$modulename/$properverb-$propernoun")]
	    [OutputType([System.Object[]])]
                PARAM(
					[Parameter(Position = 0,Mandatory = `$true,HelpMessage = "Specify the name of a remote computer. The default is the local host.")]
        			[alias("CN", "host")]
        			[ValidateNotNullorEmpty()]
					[Parameter(ParameterSetName = 'Set1')]
					[ValidateScript( { (Test-Path `$_) -and ((Get-Item `$_).Extension -eq ".csv") })]
					[System.IO.FileInfo]`$InputObject,

					[Parameter(HelpMessage = "Specify the name of a user.")]
					[ValidateNotNullOrEmpty()]
					[string]`$Username,

					
					[ValidateScript({`$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if (`$IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {`$True}
            						else {Throw "Must be running an elevated prompt to use this function"}})]
        			[switch]`$ClearARPCache,
					
        			[ValidateScript({if (Test-Connection -ComputerName `$_ -Count 2 -Quiet) {`$true}
                            		else {throw "Unable to connect to `$(`$_)"} })]
        			[string[]]`$ComputerName,

					[ValidateSet('Excel', 'HTML', 'Host')]
					[string]`$Export = 'Host',

                	[ValidateScript( { if (Test-Path `$_) { `$true }
                                else { New-Item -Path `$_ -ItemType Directory -Force | Out-Null; `$true }
                    })]
                	[System.IO.DirectoryInfo]`$ReportPath = 'C:\Temp'
				)



	if (`$Export -eq 'Excel') { 
		`$ExcelOptions = @{
            Path             = `$(Join-Path -Path `$ReportPath -ChildPath "\$propernoun-`$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = `$True
            AutoFilter       = `$True
            TitleBold        = `$True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = `$True
            FreezePane       = '3'
        }
         `$data | Export-Excel -Title $propernoun -WorksheetName $propernoun @ExcelOptions}

	if (`$Export -eq 'HTML') { 
			`$script:TableSettings = @{
			Style           = 'cell-border'
			TextWhenNoData  = 'No Data to display here'
			Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
			FixedHeader     = `$true
			HideFooter      = `$true
			SearchHighlight = `$true
			PagingStyle     = 'full'
			PagingLength    = 10
		}
		`$script:SectionSettings = @{
			BackgroundColor       = 'grey'
			CanCollapse           = `$true
			HeaderBackGroundColor = '#2b1200'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#f37000'
			HeaderTextSize        = '15'
			BorderRadius          = '20px'
		}
		`$script:TableSectionSettings = @{
			BackgroundColor       = 'white'
			CanCollapse           = `$true
			HeaderBackGroundColor = '#f37000'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#2b1200'
			HeaderTextSize        = '15'
		}
		`$script:TabSettings = @{
			TextTransform = 'uppercase'
			IconBrands    = 'mix'
			TextSize      = '16' 
			TextColor     = '#00203F'
			IconSize      = '16'
			IconColor     = '#00203F'
		}

		`$ReportTitle = "$propernoun"
		`$HeadingText = "`$(`$ReportTitle) [`$(Get-Date -Format dd) `$(Get-Date -Format MMMM) `$(Get-Date -Format yyyy) `$(Get-Date -Format HH:mm)]"
		New-HTML -TitleText `$(`$ReportTitle) -FilePath `$(Join-Path -Path `$ReportPath -ChildPath "\$propernoun-`$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text `$HeadingText
			}
			if (`$data) { New-HTMLTab -Name 'Winget Installed App list' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($data) @TableSettings}}}
		}
	}
	if (`$Export -eq 'Host') { `$data }
} #end Function
"@
	$ScriptFullPath = $checkpath.fullname + "\$properverb-$propernoun.ps1"

	$manifestProperties = @{
		Path            = $ScriptFullPath
		Version         = '0.1.0'
		Author          = $Author
		Description     = $Description
		CompanyName     = 'HTPCZA Tech'
		Tags            = @($Tags)
		ReleaseNotes    = 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initial Script'
		GUID            = (New-Guid)
		RequiredModules = 'ImportExcel', 'PSWriteHTML', 'PSWriteColor'
	}

	New-ScriptFileInfo @manifestProperties -Force
	$content = Get-Content $ScriptFullPath | Where-Object { $_ -notlike 'Param*' }
	Set-Content -Value ($content + $functionText) -Path $ScriptFullPath -Force

}
