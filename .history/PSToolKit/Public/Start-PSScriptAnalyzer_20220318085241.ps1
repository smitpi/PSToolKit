
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

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Run and report ScriptAnalyzer output

#>


<#
.SYNOPSIS
Run and report ScriptAnalyzer output

.DESCRIPTION
Run and report ScriptAnalyzer output

.PARAMETER Path
Path to ps1 files

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
		[System.IO.DirectoryInfo]$Path,
		[String[]]$ExcludeRules,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ScriptAnalyzerIssues = @()
	# $ExcludeRules = @(
	# 	'PSMissingModuleManifestField',
	# 	'PSAvoidUsingWriteHost',
	# 	'PSUseSingularNouns',
	# 	'PSReviewUnusedParameter'
	# )

	Write-Color '[Starting]', 'PSScriptAnalyzer' -Color Yellow, DarkCyan
	if ($ExcludeRules -like $null) {
		Invoke-ScriptAnalyzer -Path $Path -Recurse -OutVariable Listissues | Out-Null}
	else {
		Invoke-ScriptAnalyzer -Path $Path -Recurse -OutVariable Listissues -ExcludeRule $ExcludeRules | Out-Null
	}

	foreach ($item in $Listissues) {
		Write-Color "$($item.scriptname): ", $($item.Message) -Color Cyan, Yellow
		[void]$ScriptAnalyzerIssues.Add([PSCustomObject]@{
				Catagory = 'ScriptAnalyzer'
				File     = $item.scriptname
				RuleName = $item.RuleName
				line     = $item.line
				Message  = $item.Message
			})
	}
	#endregion

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
		$ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
		#endregion

		New-HTML -Online -Temporary -ShowHTML {
			New-HTMLHeader {
				New-HTMLLogo -RightLogoString $ImageLink
				New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment right -Text "Date Collected: $(Get-Date)"
			}
			foreach ($item in ($commands.verb | Sort-Object -Unique)) {
				$filtered = $commands | Where-Object { $_.Verb -like $item }
				New-HTMLSection -HeaderText "$($item)" @SectionSettings -Width 50% -AlignContent center -AlignItems center -Collapsed {
					New-HTMLPanel -Content {
						$filtered | ForEach-Object { New-HTMLContent -Invisible -Content {
								New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.name)" -Color BlackRussian -FontSize 18 -Alignment right }
								New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.description) [More]($($_.HelpUri))" -Color FreeSpeechRed -FontSize 16 -Alignment left }
							}
						}
					}
				}
			}
		}

		
		
		
		$ScriptAnalyzerIssues | Out-GridHtml -DisablePaging -Title 'PSScriptAnalyzer' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $ScriptAnalyzerIssues }

} #end Function
