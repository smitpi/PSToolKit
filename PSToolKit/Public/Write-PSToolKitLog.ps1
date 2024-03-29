﻿
<#PSScriptInfo

.VERSION 0.1.0

.GUID 48795cf9-d54a-4612-9444-a6e342a2e87a

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
Created [20/01/2022_13:17] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Create a log for scripts

#>


<#
.SYNOPSIS
Create a log for scripts

.DESCRIPTION
Create a log for scripts

.PARAMETER Initialize
Create the initial array.

.PARAMETER Severity
Severity of the entry.

.PARAMETER Action
Action for the object.

.PARAMETER Object
The object to be reported on.

.PARAMETER Message
Details.

.PARAMETER ShowVerbose
Show every entry as it is logged.

.PARAMETER ExportFinal
Export the final log file.

.PARAMETER Export
Export the log,

.PARAMETER LogName
Name for the log file.

.PARAMETER ReportPath
Path where it will be saved.

.EXAMPLE
dir | Write-PSToolKitLog -Severity Error -Action Starting -Message 'file list' -ShowVerbose

#>
Function Write-PSToolKitLog {
    [Cmdletbinding(DefaultParameterSetName = 'log'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitLog')]
    PARAM(
        [Parameter(ParameterSetName = 'Create')]
        [switch]$Initialize,
        [Parameter(ParameterSetName = 'log')]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',
        [Parameter(ParameterSetName = 'log')]
        [ValidateSet('Starting', 'Processing', 'Copying', 'Moving', 'Complete', 'Deleting', 'Modifying')]
        [string]$Action,
        [Parameter(ValueFromPipeline = $true, ValueFromRemainingArguments = $false)]
        [Parameter(ParameterSetName = 'log')]
        [string[]]$Object,
        [Parameter(ParameterSetName = 'log')]
        [string]$Message,
        [Parameter(ParameterSetName = 'log')]
        [switch]$ShowVerbose,
        [Parameter(ParameterSetName = 'Export')]
        [switch]$ExportFinal = $false,
        [Parameter(ParameterSetName = 'Export')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [Parameter(ParameterSetName = 'Export')]
        [string]$LogName = 'PSToolKitLog',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(ParameterSetName = 'Export')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
				)
    begin {
        if ($Initialize) { [System.Collections.ArrayList]$script:ExportLogs = @() }
    }
    process {
        if (-not($Initialize) -and -not($ExportFinal)) {
            [void]$ExportLogs.Add([PSCustomObject]@{
                    Time     = "[$(Get-Date -f g)] "
                    Severity = "[$($Severity)] "
                    Action   = "[$($Action)]: "
                    Object   = "($($Object)) "
                    Message  = $Message
                })
        }

        if ($ShowVerbose) {
            $VerbosePreference = 'Continue'
            switch ($($Severity)) {
                { $_ -in 'Debug', 'Information' } { Write-Verbose "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Action)$($ExportLogs[-1].object)$($ExportLogs[-1].Message)" }
                { $_ -in 'Warning', 'Error' } { Write-Warning "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Action)$($ExportLogs[-1].Object)$($ExportLogs[-1].Message)" }
            }
            $VerbosePreference = 'SilentlyContinue'
        }

        if ($ExportFinal) {
            if ($Export -eq 'Excel') { $ExportLogs | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\$($LogName)-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title "$($LogName)" -TitleBold -TitleSize 20 -FreezePane 3 -TitleFillPattern DarkGrid -FreezeTopRow -TableStyle Dark6 -BoldTopRow -Show }
            if ($Export -eq 'HTML') { $ExportLogs | Out-HtmlView -DisablePaging -Title "$($LogName)" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($LogName)-$(Get-Date -Format yyyy.MM.dd-HH.mm).html")}
            if ($Export -eq 'Host') { $ExportLogs | Format-Table -AutoSize -Wrap }
        }
    }
} #end Function
