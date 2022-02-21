
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7d3510e9-ec60-4b00-93b0-d72a3a8d8180

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
 Show help file of a command in a specified module

#>

<#
.SYNOPSIS
Show help file of a command in a specified module

.DESCRIPTION
Show help file of a command in a specified module

.EXAMPLE
Get-ModuleCommandHelp

#>
function Get-ModuleCommandHelp {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-ModuleCommandHelp')]
    PARAM()
    $mods = Get-InstalledModule |Select-Object Name, Version, Description, InstalledDate, PublishedDate, UpdatedDate, InstalledLocation | Out-GridView -OutputMode Single -Title Choose...
    $cmds = get-command -Module $mods.Name | Select-Object name, description, commandtype, Modulename | Out-GridView -OutputMode Multiple -Title Choose...
    foreach ($cmd in $cmds) {
        get-help $cmd.name -ShowWindow
    }
}
