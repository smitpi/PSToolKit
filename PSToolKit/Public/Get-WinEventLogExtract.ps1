
<#PSScriptInfo

.VERSION 0.1.0

.GUID f5f67d9d-7a63-40c4-9e6c-de5b54e7f5b1

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
Created [05/03/2022_06:34] Initital Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Extract Event logs of a server list, and create html / excel report

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
Only show Citrix errors

.PARAMETER Export
Export results

.PARAMETER ReportPath
Path where report will be saved

.EXAMPLE
Get-WinEventLogExtract -ComputerName localhost

#>
Function Get-WinEventLogExtract {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-WinEventLogExtract')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateScript( {
                $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use this fuction.' } })]
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0)]
        [string[]]$ComputerName,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [int]$Days,
        [Parameter(Mandatory = $true,
            Position = 2)]
        [validateset('Critical', 'Error', 'Warning', 'Informational')]
        [string]$ErrorLevel,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )
    Begin {
    }
    Process {
        [System.Collections.ArrayList]$AllEvents = @()
        $ComputerName | ForEach-Object {
            $comp = $_
            Write-Color '[Collecting] ', 'Windows Events: ', $((Get-FQDN -ComputerName $comp).fqdn) -Color Yellow, green, Cyan
            if (-not(Test-Connection $comp -Count 2 -Quiet)) { Write-Warning "Unable to connect to $($comp)" }
            else {
                try {
                    [hashtable]$filter = @{
                        StartTime = $((Get-Date).AddDays(-$days))
                    }
                    if ($ErrorLevel -like 'Critical') { $filter.Add('Level', @(1)) }
                    if ($ErrorLevel -like 'Error') { $filter.Add('Level', @(1, 2)) }
                    if ($ErrorLevel -like 'Warning') { $filter.Add('Level', @(1, 2, 3)) }
                    if ($ErrorLevel -like 'Informational') { $filter.Add('Level', @(1, 2, 3, 4)) }

                    $filter.Add('LogName', @('Application', 'System', 'Security', 'Setup') )
                    $tmpEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object MachineName, TimeCreated, UserId, Id, LevelDisplayName, LogName, ProviderName, Message

                    [void]$AllEvents.Add([pscustomobject]@{
                            Host   = ((Get-FQDN -ComputerName $comp).fqdn)
                            Events = $tmpEvents
                        })
                } catch {Write-Warning "Error: `nMessage:$($_.Exception)"}
            }
        }

        if ($Export -eq 'Excel') {
            $path = Get-Item $ReportPath
            $ExcelPath = Join-Path $Path.FullName -ChildPath "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx"
            $AllEvents.Events | Export-Excel -Path $ExcelPath -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "All Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot -FreezeTopRow -TableStyle Dark8 -BoldTopRow -ConditionalText $(
                New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' -PatternType Gray125
                New-ConditionalText -Text 'Error' -ConditionalTextColor white -BackgroundColor red -Range 'E:E' -PatternType Gray125
            ) -Show
            }

        if ($Export -eq 'HTML') {
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
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"

            New-HTML -TitleText "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $HTMLPath {
                    New-HTMLHeader {
                        New-HTMLText -FontSize 20 -FontStyle oblique -Color '#00203F' -Alignment center -Text "Date Collected: $(Get-Date)"
                    }
                   $AllEvents | ForEach-Object {
                   New-HTMLTab -name "$($_.host)" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "$(($_.host).ToUpper())"
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "Events [$($_.events.count)]"
                    New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.events) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }

                }
                    }
                } -Online -Encoding UTF8 -ShowHTML


            }

        if ($Export -eq 'Host') { $AllEvents }
    }
} #end Function


