
<#PSScriptInfo

.VERSION 0.1.0

.GUID e1a21430-79f1-4777-ac09-d44086a10a25

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS web

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [26/03/2022_20:55] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Start a new browser tab with search string.

#>


<#
.SYNOPSIS
Start a new browser tab with search string.

.DESCRIPTION
Start a new browser tab with search string.

.PARAMETER Query
What to search

.PARAMETER Clipboard
Use clipboad to search

.EXAMPLE
New-GoogleSearch blah

#>
Function New-GoogleSearch {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/New-GoogleSearch")]
        [Alias("google")]
                PARAM(
					[Parameter(ValueFromPipeline=$true)]
                    [string]$Query,
                    [switch]$Clipboard = $false
				)
$google = "https://www.google.com/search?q="

if ($Clipboard) {
    $clip = Get-Clipboard
    Start-Process "$google $clip"
}
else {Start-Process "$google $Query"}

} #end Function
New-Alias -Name "google" -Value New-GoogleSearch -Description "PSToolKit: Does google search" -Option AllScope -Scope global -Force
