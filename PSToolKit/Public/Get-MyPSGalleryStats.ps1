
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
Show stats about my published modules

.DESCRIPTION
Show stats about my published modules

.EXAMPLE
Get-MyPSGalleryStats

#>
Function Get-MyPSGalleryStats {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]

    PARAM()

    $newObject = @()
    $ResultModule = Find-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Repository PSGallery
    foreach ($mod in $ResultModule) {
        $newObject += [PSCustomObject]@{
            Name                 = $mod.Name
            Version              = $mod.Version
            tags                 = @($mod.tags) | Out-String
            ItemType             = $mod.AdditionalMetadata.ItemType
            published            = $mod.AdditionalMetadata.published
            downloadCount        = $mod.AdditionalMetadata.downloadCount
            versionDownloadCount = $mod.AdditionalMetadata.versionDownloadCount
            Authors              = $mod.AdditionalMetadata.Authors
            CompanyName          = $mod.AdditionalMetadata.CompanyName
            ProjectUri           = $mod.ProjectUri.AbsoluteUri
            summary              = $mod.AdditionalMetadata.summary
        }
    }
    $newObject | ConvertTo-WPFGrid
} #end Function


