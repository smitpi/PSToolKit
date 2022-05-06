
<#PSScriptInfo

.VERSION 0.1.0

.GUID b8942165-3459-4e6d-bffe-3d8e30a94ffa

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [18/03/2022_08:27] Initial Script Creating

#>

<#

.DESCRIPTION
 Run and report ScriptAnalyzer output

#>


<#
.SYNOPSIS
Run and report ScriptAnalyzer output

.DESCRIPTION
Run and report ScriptAnalyzer output

.PARAMETER Paths
Path to ps1 files

.PARAMETER ExcludeRules
Exclude rules from report.

.PARAMETER Export
Export results

.PARAMETER ReportPath
Where to export to.

.EXAMPLE
Start-PSScriptAnalyzer -Path C:\temp

#>
Function Start-PSScriptAnalyzer {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSScriptAnalyzer')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { if (Test-Path $_) { $true }
				else {throw 'Not a valid path'}
				$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
				else {Throw 'Must be running an elevated prompt to use ClearARPCache'}})]
		[System.IO.DirectoryInfo[]]$Paths,
		[String[]]$ExcludeRules,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ScriptAnalyzerIssues = @()
foreach ($path in $paths) {
    $Listissues = $null
	Write-Color '[Starting]', 'PSScriptAnalyzer', " on ", "$($path)"  -Color Yellow, Cyan, Green,Cyan -LinesBefore 2 -LinesAfter 1
	if ($ExcludeRules -like $null) {
        Get-ChildItem -Path "$($path)\*.ps1" -Recurse | ForEach-Object {
            Write-Color "[Processing]", " $($_.Name)" -Color Yellow,Cyan
            Invoke-ScriptAnalyzer -Path $_.FullName -IncludeDefaultRules -Severity Information,warning,error -Fix -OutVariable tmp | Out-Null
            $Listissues = $Listissues + $tmp
        }
 } else {
        Get-ChildItem -Path "$($path)\*.ps1" -Recurse | ForEach-Object {
            Write-Color "[Processing]", " $($_.Name)" -Color Yellow,Cyan
            Invoke-ScriptAnalyzer -Path $_.FullName -IncludeDefaultRules -Severity Information,warning,error -Fix -OutVariable tmp -ExcludeRule $ExcludeRules | Out-Null
            $Listissues = $Listissues + $tmp
        }
	}

	foreach ($item in $Listissues) {
		[void]$ScriptAnalyzerIssues.Add([PSCustomObject]@{
				File     = $item.scriptname
				RuleName = $item.RuleName
				line     = $item.line
				Message  = $item.Message
			})
	}
	#endregion
}

	if ($Export -eq 'Excel') { $ScriptAnalyzerIssues | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ScriptAnalyzer -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PivotTableName Summery -PivotRows RuleName -PivotData Message}
	if ($Export -eq 'HTML') {
		#region html settings
		$SectionSettings = @{
			HeaderTextSize        = '16'
			HeaderTextAlignment   = 'center'
			HeaderBackGroundColor = '#00203F'
			HeaderTextColor       = '#ADEFD1'
			backgroundColor       = 'lightgrey'
			CanCollapse           = $true
		}
		$TableSettings = @{
			SearchHighlight = $True
			AutoSize        = $true
			Style           = 'cell-border'
			ScrollX         = $true
			HideButtons     = $true
			HideFooter      = $true
			FixedHeader     = $true
			TextWhenNoData  = 'No Data to display here'
			DisableSearch   = $true
			ScrollCollapse  = $true
			#Buttons        =  @('searchBuilder','pdfHtml5','excelHtml5')
			ScrollY         = $true
			DisablePaging   = $true
			PagingLength    = '10'
		}
		$ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
		#endregion

		New-HTML -FilePath $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") -Title 'PSScriptAnalyzer' -ShowHTML {
			New-HTMLHeader {
				New-HTMLLogo -RightLogoString $ImageLink
				New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment right -Text "Date Collected: $(Get-Date)"
			}
			foreach ($item in ($ScriptAnalyzerIssues.RuleName | Sort-Object -Unique)) {
				$filtered = $ScriptAnalyzerIssues | Where-Object { $_.RuleName -like $item }
				New-HTMLSection -HeaderText "$($item) [ $($filtered.Count) ]" @SectionSettings -Collapsed { New-HTMLTable -DataTable $filtered @TableSettings	}
			}
		}
	}
	if ($Export -eq 'Host') { return $ScriptAnalyzerIssues }

} #end Function