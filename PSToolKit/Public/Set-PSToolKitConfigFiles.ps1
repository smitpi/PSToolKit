
<#PSScriptInfo

.VERSION 0.1.0

.GUID b2cf012a-9d2e-45fd-af69-6816bd96332d

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [28/01/2022_11:04] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Creates the config files for the modules and chocolatey scripts

#>


<#
.SYNOPSIS
Creates the config files for the modules and chocolatey scripts.

.DESCRIPTION
Creates the config files for the modules and chocolatey scripts.

.PARAMETER Source
Where to copy the config from.

.PARAMETER UserID
GitHub userid hosting the gist.

.PARAMETER GitHubToken
GitHub Token

.EXAMPLE
Set-PSToolKitConfigFiles -Source Module

#>
Function Set-PSToolKitConfigFiles {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSToolKitConfigFiles')]

    PARAM(
        [ValidateSet('Gist', 'Module')]
        [string]$Source = 'Module',
        [Parameter(ParameterSetName = 'gist')]
        [string]$UserID,
        [Parameter(ParameterSetName = 'gist')]
        [string]$GitHubToken
    )
    $ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
    if (-not(Test-Path $ModulePath)) { $NewModulePath = New-Item $ModulePath -ItemType Directory -Force }
    else { $NewModulePath = Get-Item $ModulePath }

    if ($Source -like 'Module') {
        $module = Get-Module PSToolKit
        if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
        Get-ChildItem (Join-Path $module.ModuleBase -ChildPath \private) | Copy-Item -Destination $NewModulePath.FullName
    }
    else {
        $headers = @{}
        $auth = '{0}:{1}' -f $UserID, $GitHubToken
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $headers.Authorization = 'Basic {0}' -f $base64

        $url = 'https://api.github.com/users/{0}/gists' -f $Userid

        $gistfiles = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
        $gistfiles = $gistfiles | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }
        $gistfileNames = $gistfiles.files | Get-Member | Where-Object { $_.memberType -eq 'NoteProperty' } | Select-Object Name
        foreach ($gistfileName in $gistfileNames) {
            $url = ($gistfiles.files."$($gistfileName.name)").raw_url
            (Invoke-WebRequest -Uri $url -Headers $headers).content | Set-Content (Join-Path $NewModulePath.FullName -ChildPath $($gistfileName.name))
            Write-Color '[Set]', $($gistfileName.name), ': Complete' -Color Yellow, Cyan, Green
        }
    }

} #end Function
