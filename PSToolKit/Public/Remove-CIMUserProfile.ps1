
<#PSScriptInfo

.VERSION 0.1.0

.GUID 612f61fc-908d-404f-be24-76deccd4bfd2

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
Uses CimInstance to remove a user profile

#>

<#
.SYNOPSIS
Uses CimInstance to remove a user profile

.DESCRIPTION
Uses CimInstance to remove a user profile

.PARAMETER TargetServer
Affected Server

.PARAMETER UserName
Affected Username

.EXAMPLE
Remove-CIMUserProfiles -UserName ps

#>
Function Remove-CIMUserProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Remove-CIMUserProfiles')]
    PARAM(
        [string]$TargetServer = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName
    )

    $UserProfile = Get-CimInstance Win32_UserProfile -ComputerName $TargetServer | Where-Object { $_.LocalPath -like "*$UserName*" }
    Remove-CimInstance -InputObject $UserProfile
    Write-Output "Profile $($UserProfile.LocalPath) has been removed from $($TargetServer)"

} #end Function
