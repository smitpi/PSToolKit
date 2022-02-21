
<#PSScriptInfo

.VERSION 0.1.0

.GUID a2e8effb-92e2-4c66-9abd-a4b4c2a29e67

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
 Show the help file of a command in  a new window

#>

<#
.SYNOPSIS
Show the help file of a command in  a new window

.DESCRIPTION
Show the help file of a command in  a new window

.PARAMETER CommandFilter
What to search for

.EXAMPLE
Get-CommandHelp -CommandFilter blah

.NOTES
General notes
#>
function Get-CommandHelp {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-CommandHelp')]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$CommandFilter)


    $Command = "*" + $CommandFilter + "*"
    $gethelpcommand = get-command $Command | Out-GridView -Title "Select the command" -OutputMode Multiple
    foreach ($gethelp in $gethelpcommand)
    {
        get-help $gethelp.name -ShowWindow
    }#for
}
