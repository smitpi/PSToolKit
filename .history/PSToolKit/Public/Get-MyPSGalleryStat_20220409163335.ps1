
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
Function Get-MyPSGalleryStat {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateSet('GridView', 'TableView')]
        [string]$Display = 'Host',
        [Switch]$OpenProfilePage
    )

    if ($OpenProfilePage) {{Start-Process 'https://www.powershellgallery.com/profiles/smitpi'}}
    $ModLists = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray')

    [System.Collections.ArrayList]$newObject = @()
    $TotalDownloads = 0

    foreach ($Mod in $ModLists) {
        Write-Color '[Collecting]', ' data for ', $($mod) -Color yellow, Green, Cyan
        $ResultModule = Find-Module $mod -Repository PSGallery
        $TotalDownloads = $TotalDownloads + [int]$ResultModule.AdditionalMetadata.downloadCount
        [void]$newObject.Add([PSCustomObject]@{
                Sum            = [PSCustomObject]@{
                    Name            = $ResultModule.Name
                    Version         = $ResultModule.Version
                    Date            = [datetime]$ResultModule.AdditionalMetadata.published
                    TotalDownload   = $ResultModule.AdditionalMetadata.downloadCount
                    VersionDownload = $ResultModule.AdditionalMetadata.versionDownloadCount
                }
                All            = $ResultModule
                TotalDownloads = $TotalDownloads
            })
    }

    if ($Display -like 'GridView') {$newObject.Sum | ConvertTo-WPFGrid}
    if ($Display -like 'TableView') {
        Write-Color 'Total Downloads: ', "$(($newObject.TotalDownloads | Sort-Object -Descending)[0])" -Color Cyan, yellow -LinesBefore 1
        $newObject.Sum | Sort-Object -Property VersionDownload -Descending | Format-Table -AutoSize
    }
    if ($Display -like 'Host') {$newObject}
} #end Function


