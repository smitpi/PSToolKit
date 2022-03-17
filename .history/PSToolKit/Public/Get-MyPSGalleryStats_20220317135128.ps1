
<#PSScriptInfo

.VERSION 0.1.0

.GUID c4d35ac7-1b1f-48cf-81ee-f9a4ad9f5594

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
 Display detail about the modules I've uploaded

#>

<#
.SYNOPSIS
Show stats about my published modules.

.DESCRIPTION
Show stats about my published modules.

.PARAMETER Display
How to display the output.

.EXAMPLE
Get-MyPSGalleryStats -Display TableView

#>
Function Get-MyPSGalleryStats {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateSet('GridView', 'TableView')]
        [string]$Display = 'Host'
    )

    [System.Collections.ArrayList]$newObject = @()
    $ResultModule = Find-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Repository PSGallery
    foreach ($mod in $ResultModule) {
        [void]$newObject.Add([PSCustomObject]@{
                Sum = [PSCustomObject]@{
                    Name            = $mod.Name
                    Version         = $mod.Version
                    Date            = [datetime]$mod.AdditionalMetadata.published
                    TotalDownload   = $mod.AdditionalMetadata.downloadCount
                    VersionDownload = $mod.AdditionalMetadata.versionDownloadCount
                }
                All = $mod
                Total = $ResultModule.AdditionalMetadata.downloadCount | ForEach-Object {$x = $x + $_}
            })
    }
    
    if ($Display -like 'GridView') {$newObject.Sum | ConvertTo-WPFGrid}
    if ($Display -like 'TableView') {$newObject.Sum | Format-Table -AutoSize}
    if ($Display -like 'Host') {$newObject}


} #end Function


