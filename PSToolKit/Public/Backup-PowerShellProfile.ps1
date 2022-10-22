
<#PSScriptInfo

.VERSION 0.1.0

.GUID b75273f3-6ff1-4bcd-bbe6-81783f8fbd65

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
Created [23/11/2021_19:12] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Creates a zip file from the ps profile directories

#>

<#
.SYNOPSIS
Creates a zip file from the ps profile directories

.DESCRIPTION
Creates a zip file from the ps profile directories

.PARAMETER ExtraDir
Another Directory to add to the zip file

.PARAMETER DestinationPath
Where the zip file will be saved.

.EXAMPLE
Backup-PowerShellProfile -DestinationPath c:\temp

#>
Function Backup-PowerShellProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Backup-PowerShellProfile')]

    PARAM(
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ExtraDir,
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$DestinationPath = $([Environment]::GetFolderPath('MyDocuments'))
    )
    try {
        $SourceDir = @()
        $SourceDir = (Get-Item (Get-Item $PROFILE).Directory).FullName
        if ([bool]$ExtraDir) { 
            $SourceDir += (Get-Item $ExtraDir).fullname 
        }
        $Destination = [IO.Path]::Combine((Get-Item $DestinationPath).FullName, "Powershell_$($PSVersionTable.PSEdition)_$($env:COMPUTERNAME.ToLower())_Profile_Backup_$(Get-Date -Format ddMMMyyyy_HHmm).zip")
    }
    catch { Write-Error 'Unable to get directories' }

    try {
        Compress-Archive -Path $SourceDir -DestinationPath $Destination -CompressionLevel Fastest -Update
    }
    catch { Write-Error 'Unable to create zip file' }
} #end Function
