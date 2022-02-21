
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6a0af5c6-913a-43bd-af2a-c962cf291428

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
Created [28/11/2021_13:38] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Restore the RunAss shortcuts, from a zip file

#>


<#
.SYNOPSIS
Restore the RunAss shortcuts, from a zip file


.DESCRIPTION
Restore the RunAss shortcuts, from a zip file

.PARAMETER ZipFilePath
Path to the backup file

.PARAMETER ForceReinstall
Override existing shortcuts

.EXAMPLE
Restore-ElevatedShortcut -ZipFilePath c:\temp\bck.zip -ForceReinstall

#>
Function Restore-ElevatedShortcut {
    [Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Restore-ElevatedShortcut')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [Parameter(ParameterSetName = 'Set1')]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.zip') })]
        [System.IO.FileInfo]$ZipFilePath,
        [switch]$ForceReinstall = $false
				)

    if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

    Expand-Archive $ZipFilePath -DestinationPath C:\Temp -Force
    $files = Get-ChildItem C:\temp\Tasks\*.xml
    foreach ($file in $files) {
        $checktask = $null
        try {
            if ($ForceReinstall) { Get-ScheduledTask -TaskName "$($file.BaseName)" -TaskPath '\RunAs\' | Unregister-ScheduledTask -Confirm:$false }
            $checktask = Get-ScheduledTaskInfo "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
        }
        catch { $checktask = $null }
        if ( $null -eq $checktask) {
            try {
                Write-Host 'Task:' -ForegroundColor Cyan -NoNewline
                Write-Host "$($file.BaseName)" -ForegroundColor red
                [xml]$importfile = Get-Content $file.FullName
                $sid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).value
                $importfile.Task.Principals.Principal.UserId = $sid
                Register-ScheduledTask -Xml ($importfile.OuterXml | Out-String) -TaskName "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
            }
            Catch { Write-Warning "$($_.BaseName) - wrong domain" }
            finally { Write-Warning "$($_.BaseName)" }
        }
    }
    Remove-Item -Path C:\Temp\Tasks -Recurse

} #end Function
