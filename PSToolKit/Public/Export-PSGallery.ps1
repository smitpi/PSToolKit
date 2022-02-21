
<#PSScriptInfo

.VERSION 0.1.0

.GUID 043f4041-4aae-47c1-96bb-ad0bb51bc53d

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
Export details of all modules and scripts on psgallery to excel

#>

<#
.SYNOPSIS
Export details of all modules and scripts on psgallery to excel

.DESCRIPTION
Export details of all modules and scripts on psgallery to excel

.PARAMETER ReportPath
Where the excel file will be saved.

.EXAMPLE
Export-PSGallery -ReportPath c:\temp

#>
function Export-PSGallery {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-PSGallery')]
    PARAM(
        [Parameter(Mandatory = $false)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$ReportPath = $env:temp
    )
    $ReportSavePath = Get-Item $ReportPath
    [string]$Reportname = 'PSGallery.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'
    $ReportSave = Join-Path $ReportSavePath.FullName -ChildPath $Reportname

    Write-Output 'Collecting Modules'
    $newObject = @()
    $ResultModule = Find-Module
    foreach ($mod in $ResultModule) {
        $newObject += [PSCustomObject]@{
            title                = $mod.AdditionalMetadata.title
            tags                 = @($mod.AdditionalMetadata.tags) | Out-String
            ItemType             = $mod.AdditionalMetadata.ItemType
            published            = $mod.AdditionalMetadata.published
            downloadCount        = $mod.AdditionalMetadata.downloadCount
            versionDownloadCount = $mod.AdditionalMetadata.versionDownloadCount
            Authors              = $mod.AdditionalMetadata.Authors
            CompanyName          = $mod.AdditionalMetadata.CompanyName
            ProjectUri           = $mod.ProjectUri
            summary              = $mod.AdditionalMetadata.summary
        }
    }
    $newObject | Export-Excel -Path $ReportSave -WorksheetName Modules -AutoSize -AutoFilter

    Write-Output 'Collecting Scripts'
    $newObject2 = @()
    $ResultScript = Find-Script
    foreach ($scr in $ResultScript) {
        $newObject2 += [PSCustomObject]@{
            title                = $scr.AdditionalMetadata.title
            tags                 = @($scr.AdditionalMetadata.tags) | Out-String
            ItemType             = $scr.AdditionalMetadata.ItemType
            published            = $scr.AdditionalMetadata.published
            downloadCount        = $scr.AdditionalMetadata.downloadCount
            versionDownloadCount = $scr.AdditionalMetadata.versionDownloadCount
            Authors              = $scr.AdditionalMetadata.Authors
            CompanyName          = $scr.AdditionalMetadata.CompanyName
            ProjectUri           = $scr.ProjectUri
            summary              = $scr.AdditionalMetadata.summary
        }
    }
    $newObject2 | Export-Excel -Path $ReportSave -WorksheetName Scripts -AutoSize -AutoFilter -Show
}
