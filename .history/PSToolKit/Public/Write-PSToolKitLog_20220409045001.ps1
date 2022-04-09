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
Run at the begining to create the initial arrray.

.PARAMETER Severity
Level of the message to be logged.

.PARAMETER Message
Details to be logged.

.PARAMETER ShowVerbose
Also show output to screen.

.PARAMETER ExportFinal
Run at the end to finalize the report.

.PARAMETER Export
Export the log to excel of html.

.PARAMETER ReportPath
Where to save the log.

.EXAMPLE
Write-PSToolKitLog -Severity Information -Message 'Where details are?'

.NOTES
General notes
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
        [string]$Message,
        [Parameter(ParameterSetName = 'log')]
        [ValidateSet('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists')]
        [string]$Action,
        [Parameter(ParameterSetName = 'log')]
        [switch]$ShowVerbose,
        [Parameter(ParameterSetName = 'Export')]
        [switch]$ExportFinal = $false,
        [Parameter(ParameterSetName = 'Export')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { (Test-Path $_) })]
        [Parameter(ParameterSetName = 'Export')]
        [System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
				)

    if ($Initialize) { [System.Collections.ArrayList]$script:ExportLogs = @() }


    [PSCustomObject]@{
        Time     = '[' + (Get-Date -f g) + '] '
        Severity = "[$Severity] "
        Message  = $Message
    } | Select-Object Time, Severity, Action, Message
    $ExportLogs.Add($object)

    if ($ShowVerbose) {
        $VerbosePreference = 'Continue'
        switch ($($Severity)) {
            { $_ -in 'Debug', 'Information' } { Write-Verbose "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Message)" }
            { $_ -in 'Warning', 'Error' } { Write-Warning "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Message)" }

        }
        $VerbosePreference = 'SilentlyContinue'
    }


    if ($ExportFinal) {
        if ($Export -eq 'Excel') { $ExportLogs | Export-Excel -Path ($ReportPath + '\PrivRepoLog-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Show }
        if ($Export -eq 'HTML') { $ExportLogs | Out-HtmlView -DisablePaging -Title 'PrivRepoLog' -HideFooter -SearchHighlight -FixedHeader }
        if ($Export -eq 'Host') { $ExportLogs | Format-Table -AutoSize }
    }
} #end Function
