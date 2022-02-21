
<#PSScriptInfo

.VERSION 0.1.0

.GUID 46e93c03-a779-4da3-8803-e3f6594ced4c

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [26/01/2022_11:02] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Gets the top 10 processes by CPU %

#>


<#
.SYNOPSIS
Gets the top 10 processes by CPU %

.DESCRIPTION
Gets the top 10 processes by CPU %

.PARAMETER ComputerName
Device to be queried.

.PARAMETER LimitProcCount
List the top x of processes.

.PARAMETER Sortby
Sort by CPU or Memory descending.

.EXAMPLE
Get-ProcessPerformance -ComputerName Apollo -LimitProcCount 10 -Sortby '% CPU'

#>
Function Get-ProcessPerformance {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-ProcessPerformance')]

    PARAM(
        [ValidateScript( { if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
                else { throw "Unable to connect to $($_)" } })]
        [string[]]$ComputerName,
        [int]$LimitProcCount,
        [validateset('% Mem', '% CPU')]
        [string]$Sortby = '% CPU'
    )

    foreach ($comp in $ComputerName) {
        $cores = ((Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName Win32_Processor).NumberOfLogicalProcessors)[0]
        $ProcessArray = [System.Collections.Generic.List[PSObject]]::New()
        $process = Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName Win32_PerfFormattedData_PerfProc_Process
        foreach ($proc in $process | Where-Object { $_.Name -notlike 'Idle' -and $_.Name -notlike '_Total' }) {
            $ProcessArray.Add([PSCustomObject]@{
                    Computername = $comp
                    Name         = $proc.Name
                    ID           = $proc.IDProcess
                    '% CPU'      = [Math]::Round(($proc.PercentProcessorTime / $cores), 2)
                    '% Mem'      = [Math]::Round(($proc.workingSetPrivate / 1mb), 2)
                })
        }
        if ($LimitProcCount -gt 0) { $ProcessArray | Sort-Object -Property $Sortby -Descending | Select-Object -First $LimitProcCount }
        else { $ProcessArray | Sort-Object -Property $Sortby -Descending }
    }
} #end Function
