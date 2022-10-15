
<#PSScriptInfo

.VERSION 0.1.0

.GUID 191511d2-98e3-45ce-bf91-acc44a0e2edc

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
Cast an array or PSObject and display it in list view

#>


<#
.SYNOPSIS
Cast an array or PSObject and display it in list view

.DESCRIPTION
Cast an array or PSObject and display it in list view

.PARAMETER Data
The PSObject to transform

.EXAMPLE
Get-ObjectProperties -data $data

#>
Function Get-ObjectProperties {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-ObjectProperties')]
    Param (
        [parameter( ValueFromPipeline = $True )]
        [object[]]$Data)

    Process {
        ForEach ( $Object in $Data ) {
            $Object.psobject.Properties | Select-Object -Property Name, Value
        }
    }
}
