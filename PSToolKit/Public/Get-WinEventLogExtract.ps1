
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0a2c6466-01f5-4743-baf2-1cb8652860dd

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

#>

<#
.SYNOPSIS
 Extract Event logs of a server list, and create html / excel report

.DESCRIPTION
 Extract Event logs of a server list, and create html / excel report

.PARAMETER ComputerName
Name of the host

.PARAMETER Days
Limit the search results

.PARAMETER ErrorLevel
Set the default filter to this level and above.

.PARAMETER FilterCitrix
Only show CItrix errors

.PARAMETER Export
Export results

.PARAMETER ReportPath
Path where report will be saved

.EXAMPLE
Get-WinEventLogExtract -ComputerName localhost

#>
Function Get-WinEventLogExtract {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-WinEventLogExtract')]
    [OutputType([System.Object[]])]
    PARAM(
        [string[]]$ComputerName = @($($env:COMPUTERNAME)),
        [int]$Days = 7,
        [validateset('Critical', 'Error', 'Warning', 'Informational')]
        [string]$ErrorLevel = 'Warning',
        [switch]$FilterCitrix = $false,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )
    [System.Collections.ArrayList]$AllEvents = @()
    $filter = @{
        StartTime = (Get-Date).AddDays(-$days)
    }

    if ($FilterCitrix) { $filter.Add('ProviderName', '*Citrix*') }
    if ($ErrorLevel -like 'Critical') { $filter.Add('Level', @(1)) }
    if ($ErrorLevel -like 'Error') { $filter.Add('Level', @(1, 2)) }
    if ($ErrorLevel -like 'Warning') { $filter.Add('Level', @(1, 2, 3)) }
    if ($ErrorLevel -like 'Informational') { $filter.Add('Level', @(1, 2, 3, 4)) }

    ForEach ($comp in $ComputerName) {
        Write-Host 'Processing Events for server: ' -ForegroundColor Cyan -NoNewline
        Write-Host "$($comp)" -ForegroundColor Yellow
        $filter.Remove('LogName')
        if (-not(Test-Connection $comp -Count 2 -Quiet)) { Write-Warning "Unable to connect to $($comp)" }
        else {
            try {
                $tmpNames = Get-WinEvent -ListLog * -ComputerName $comp | Where-Object { $_.IsEnabled -like 'True' -and $_.RecordCount -gt 0 -and $_.LogType -like 'Administrative' } | ForEach-Object {
                    [pscustomobject]@{
                        MachineName   = $comp
                        LogName       = $_.LogName
                        RecordCount   = $_.RecordCount
                        IsClassicLog  = $_.IsClassicLog
                        IsEnabled     = $_.IsEnabled
                        LogMode       = $_.LogMode
                        LogType       = $_.LogType
                        LastWriteTime = $_.LastWriteTime
                    }

                }
                $filter.Add('LogName', $($tmpNames.logname))
                $tmpEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object MachineName, TimeCreated, UserId, Id, LevelDisplayName, LogName, ProviderName, Message

                [void]$AllEvents.Add([pscustomobject]@{
                        Host     = $comp
                        Lognames = $tmpNames
                        Events   = $tmpEvents
                    })

            }
            catch { Write-Warning "Unable to get logs from $($comp):`n $($_.Exception.Message)" }
        }
    }

    if ($Export -eq 'Excel') {
        $AllEvents | ForEach-Object {
            $_.lognames | Export-Excel -Path ($ReportPath + "\$($_.host)-Events-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -WorksheetName LogNames -AutoSize -AutoFilter -Title "$($_.host)`'s Log Names" -TitleBold -TitleSize 20 -FreezePane 3
            $_.Events | Export-Excel -Path ($ReportPath + "\$($_.host)-Events-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "$($_.host)`'s Log Names" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot -FreezeTopRow -TableStyle Dark8 -BoldTopRow -ConditionalText $(
                New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' -PatternType Gray125
                New-ConditionalText -Text 'Error' -ConditionalTextColor white -BackgroundColor red -Range 'E:E' -PatternType Gray125
            ) -Show
        }
    }

    if ($Export -eq 'HTML') {
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
            #AutoSize        = $true
            Style           = 'cell-border'
            ScrollX         = $true
            HideButtons     = $true
            HideFooter      = $true
            FixedHeader     = $true
            TextWhenNoData  = 'No Data to display here'
            #DisableSearch   = $true
            ScrollCollapse  = $true
            ScrollY         = $true
            DisablePaging   = $true
        }

        $AllEvents | ForEach-Object {
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "$($_.host)-WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"

            New-HTML -TitleText "$($_.host)-WinEvents" -FilePath $HTMLPath {
                New-HTMLHeader {
                    New-HTMLText -FontSize 28 -FontStyle oblique -Color '#00203F' -Alignment center -Text "$($_.host)"
                    New-HTMLText -FontSize 20 -FontStyle oblique -Color '#00203F' -Alignment center -Text "Date Collected: $(Get-Date)"
                }
                New-HTMLSection -HeaderText "Log Names [$($_.lognames.count)]" @SectionSettings -Collapsed {
                    New-HTMLSection -Invisible { New-HTMLTable -DataTable $($_.lognames) @TableSettings }
                }
                New-HTMLSection -HeaderText "Events [$($_.events.count)]" @SectionSettings -Collapsed {
                    New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.events) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }
                }
            } -Online -Encoding UTF8 -ShowHTML
        }
    }
    if ($Export -eq 'Host') { $AllEvents }

} #end Function


