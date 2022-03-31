
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6bb2bfa9-cb81-44f7-8af2-945115a57dc2

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
Search for a string in a directory of ps1 scripts.

#>


<#
.SYNOPSIS
Search for a string in a directory of ps1 scripts.

.DESCRIPTION
Search for a string in a directory of ps1 scripts.

.PARAMETER Path
Path to search.

.PARAMETER Include
File extension to search. Default is ps1.

.PARAMETER KeyWord
The string to search for.

.PARAMETER ListView
Show result as a list.

.EXAMPLE
Search-Scripts -Path . -KeyWord "contain" -ListView

#>
FUNCTION Search-Script {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Search-Scripts')]
    PARAM(
        [STRING[]]$Path = $pwd,
        [STRING[]]$Include = '*.ps1',
        [STRING[]]$KeyWord = (Read-Host 'Keyword?'),
        [SWITCH]$ListView
    )
    BEGIN {

    }
    PROCESS {
        $Result = Get-ChildItem -Path $Path -Include $Include -Recurse | Sort-Object Directory, CreationTime | Select-String -SimpleMatch $KeyWord -OutVariable Result | Out-Null
    }
    END {
        IF ($ListView) {
            $Result | Format-List -Property Path, LineNumber, Line
        }
        ELSE {
            $Result | Format-Table -GroupBy Path -Property LineNumber, Line -AutoSize
        }
    }
}
