
<#PSScriptInfo

.VERSION 0.1.0

.GUID 444413cd-d655-4d66-ac1f-83b53807351d

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS win

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [16/02/2022_22:38] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
My wrapper for default robocopy switches

#>


<#
.SYNOPSIS
My wrapper for default robocopy switches

.DESCRIPTION
My wrapper for default robocopy switches

.PARAMETER Source
Folder to copy.

.PARAMETER Destination
Where it will be copied.

.PARAMETER Action
3 choices. Copy files and folders, Move files and folders or mirror the folders (Destination files will be overwritten)

.PARAMETER IncludeFiles
Only copy these files

.PARAMETER eXcludeFiles
Exclude these files (can use wildcards)

.PARAMETER eXcludeDirs
Exclude these folders (can use wildcards)

.PARAMETER TestOnly
Don't do any changes, see which files has changed.

.PARAMETER LogPath
Where to save the log. If the log file exists, it will be appended.

.EXAMPLE
Start-PSRoboCopy -Source C:\Utils\LabTools -Destination P:\Utils\LabTools2 -Action copy -eXcludeFiles *.git

#>
Function Start-PSRoboCopy {
        [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSRoboCopy')]
        PARAM(
                [Parameter(Mandatory = $true)]
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { throw "Source: $($_) does not exist." }
                        })]
                [System.IO.DirectoryInfo]$Source,
                [Parameter(Mandatory = $true)]
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [System.IO.DirectoryInfo]$Destination,
                [Parameter(Mandatory = $true)]
                [ValidateSet('Copy', 'Move', 'Mirror')]
                [string]$Action,
                [string[]]$IncludeFiles,
                [string[]]$eXcludeFiles,
                [string[]]$eXcludeDirs,
                [switch]$TestOnly,
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [System.IO.DirectoryInfo]$LogPath = 'C:\Temp'
        )

        [System.Collections.ArrayList]$RoboArgs = @()
        $RoboArgs.Add($($Source))
        $RoboArgs.Add($($Destination))
        if ($null -notlike $IncludeFiles) {
                $IncludeFiles | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }
        if ($null -notlike $eXcludeFiles) {
                $RoboArgs.Add('/XF')
                $eXcludeFiles | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }

        if ($null -notlike $eXcludeDirs) {
                $RoboArgs.Add('/XD')
                $eXcludeDirs | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }

        [void]$RoboArgs.Add('/W:0')
        [void]$RoboArgs.Add('/R:0')
        #[void]$RoboArgs.Add('/COPYALL')
        #[void]$RoboArgs.Add('/NJS')
        #[void]$RoboArgs.Add('/NJH')
        [void]$RoboArgs.Add('/NP')
        [void]$RoboArgs.Add('/NDL')
        [void]$RoboArgs.Add('/TEE')
        [void]$RoboArgs.Add('/MT:64')

        switch ($Action) {
                'Copy' { [void]$RoboArgs.Add('/E') }

                'Move' {
                        [void]$RoboArgs.Add('/E')
                        [void]$RoboArgs.Add('/MOVE')
                }

                'Mirror' { [void]$RoboArgs.Add('/MIR') }
        }
        if ($TestOnly) { [void]$RoboArgs.Add('/L') }

        $Logfile = Join-Path $LogPath -ChildPath "RoboCopyLog_Week_$(Get-Date -UFormat %V).log"
        [void]$RoboArgs.Add("/LOG+:$($Logfile)")

        & robocopy $RoboArgs

} #end Function
