
<#PSScriptInfo

.VERSION 0.1.0

.GUID 89bea77b-3cd5-4414-b048-93c23bda8e48

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
Created [26/10/2021_22:33] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Downloads and saves help files locally

#>

<#
.SYNOPSIS
 Downloads and saves help files locally

.DESCRIPTION
 Downloads and saves help files locally

.EXAMPLE
Update-LocalHelp

#>
function Update-LocalHelp {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-LocalHelp')]
    PARAM()

   
    if ((Test-Path $profile) -eq $false ) {
        Write-Warning 'Profile does not exist, creating file.'
        New-Item -ItemType File -Path $Profile -Force
        $psfolder = (Get-Item $profile).DirectoryName
    } else { $psfolder = (Get-Item $profile).DirectoryName }

    if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory -Force -ErrorAction SilentlyContinue }

    $helpdir = Get-Item (Join-Path $psfolder -ChildPath 'Help')

    Start-ThreadJob -ScriptBlock {
        Update-Help -Force -Verbose
        Save-Help -DestinationPath $using:helpdir -Force -Verbose
    }

        
}
