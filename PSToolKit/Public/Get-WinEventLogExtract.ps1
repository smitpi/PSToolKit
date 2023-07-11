
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
Created [05/03/2022_06:34] Initial Script Creating

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

.PARAMETER OpenReportsFolder
Open the folder after report creation.

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

        [ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
        [string[]]$Export = 'Host',

        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
        [switch]$OpenReportsFolder
    )
    Begin {
        [System.Collections.generic.List[PSObject]]$EventObject = @()       
    }
    Process {
        foreach ($comp in $ComputerName) {
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
                    $EventObject.Add((Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object MachineName, TimeCreated, UserId, Id, LevelDisplayName, LogName, ProviderName, Message))
                } catch {Write-Warning "Error: `nMessage:$($_.Exception)"}
            }
        }

    }
    end {

        if ($Export -eq 'Host') {$EventObject}
        else {
            $report = [PSCustomObject]@{
                'Windows Event Logs' = $EventObject
            }# PSObject

            [System.Collections.generic.List[PSObject]]$Conditions = @()    
            $Conditions.Add((New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor Yellow -Range 'E:E' ))
            $Conditions.Add((New-ConditionalText -Text 'Error' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' ))
            $Conditions.Add((New-ConditionalText -Text 'Critical' -ConditionalTextColor white -BackgroundColor Red -Range 'E:E' ))

            Write-PSReports -InputObject $report -ReportTitle 'Windows Events' -Export $Export -ReportPath $ReportPath -ExcelConditionalText $conditions
        }
    }
} #end Function


