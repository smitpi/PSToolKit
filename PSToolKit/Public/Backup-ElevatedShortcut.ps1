
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6b620bd0-1bf8-47f0-b226-982e7b654893

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
Created [28/11/2021_13:37] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Exports the RunAss shortcuts, to a zip file

#>


<#
.SYNOPSIS
Exports the RunAss shortcuts, to a zip file

.DESCRIPTION
Exports the RunAss shortcuts, to a zip file

.PARAMETER ExportPath
Path for the zip file

.EXAMPLE
Backup-ElevatedShortcut -ExportPath c:\temp

#>
Function Backup-ElevatedShortcut {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Backup-ElevatedShortcut')]
    PARAM(
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ExportPath = "$env:TEMP"
				)


    if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }
    if ((Test-Path -Path C:\Temp\Tasks) -eq $false) { New-Item -Path C:\Temp\Tasks -ItemType Directory -Force -ErrorAction SilentlyContinue }

    Get-ScheduledTask -TaskPath '\RunAs\' | ForEach-Object { Export-ScheduledTask -TaskName "\RunAs\$($_.TaskName)" | Out-File "C:\Temp\Tasks\$($_.TaskName).xml" }
    $Destination = [IO.Path]::Combine((Get-Item $ExportPath).FullName, "$($env:COMPUTERNAME)_RunAss_Shortcuts_$(Get-Date -Format ddMMMyyyy_HHmm).zip")
    Compress-Archive -Path C:\Temp\Tasks -DestinationPath $Destination -CompressionLevel Fastest
    Remove-Item -Path C:\Temp\Tasks -Recurse


} #end Function
