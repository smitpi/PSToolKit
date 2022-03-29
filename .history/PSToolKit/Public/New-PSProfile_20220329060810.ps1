
<#PSScriptInfo

.VERSION 0.1.1

.GUID 61cbb8e0-0468-4f53-9060-5d601fecb913

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [05/02/2022_11:41] Initial Script Creating
Updated [05/03/2022_06:35] added fun

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION 
Creates new profile files in the documents folder

#>


<#
.SYNOPSIS
Creates new profile files in the documents folder

.DESCRIPTION
Creates new profile files in the documents folder

.EXAMPLE
New-PSProfile

#>
Function New-PSProfile {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSProfile')]
    PARAM(
    )

    [System.Collections.ArrayList]$folders = @()
    $ps7Folder = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'PowerShell')
    $ps5Folder = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell')

    if (-not(Test-Path $ps7Folder)) { [void]$folders.Add($(New-Item $ps7Folder -ItemType Directory)) }
    else { [void]$folders.Add($(Get-Item $ps7Folder)) }

    if (-not(Test-Path $ps5Folder)) { [void]$folders.Add($(New-Item $ps5Folder -ItemType Directory)) }
    else { [void]$folders.Add($(Get-Item $ps5Folder)) }

    $ise = 'Microsoft.PowerShellISE_profile.ps1'
    $ps = 'Microsoft.PowerShell_profile.ps1'
    $vscode = 'Microsoft.VSCode_profile.ps1'

    foreach ($folder in $folders) {
        if (-not(Test-Path ([IO.Path]::Combine($folder.FullName, 'Config')))) { $ConfigPath =  New-Item ([IO.Path]::Combine($folder.FullName, 'Config')) -ItemType Directory }
        else {
            $ConfigPath = Get-Item ([IO.Path]::Combine($folder.FullName, 'Config')) 
            $BCKDestination = Join-Path -Path $ConfigPath.FullName -ChildPath ""
            ([IO.Path]::Combine($ConfigPath.FullName,"$(Get-Date -Format yyyy.MM.dd_HH.mm)"))
    }

        if (Test-Path ([IO.Path]::Combine($folder.FullName, $ise))) {
            if (-not(Test-Path $BCKDestination )) {
                $BCKDest = New-Item $BCKDestination -ItemType directory
            }
            else {
                $BCKDest = get-Item $BCKDestination
            }
            Move-Item ([IO.Path]::Combine($folder.FullName, $ise)) -Destination $BCKDest.FullName -Force
        }
        if (Test-Path ([IO.Path]::Combine($folder.FullName, $ps))) {
            if (-not(Test-Path $BCKDestination )) {
                $BCKDest = New-Item $BCKDestination -ItemType directory
            } else {
                $BCKDest = Get-Item $BCKDestination
            }
            Move-Item ([IO.Path]::Combine($folder.FullName, $ps)) -Destination $BCKDest.FullName -Force
        }
        if (Test-Path ([IO.Path]::Combine($folder.FullName, $vscode))) {
            if (-not(Test-Path $BCKDestination )) {
                $BCKDest = New-Item $BCKDestination -ItemType directory
            } else {
                $BCKDest = Get-Item $BCKDestination
            }
            Move-Item ([IO.Path]::Combine($folder.FullName, $vscode)) -Destination $BCKDest.FullName -Force
        }
        $BCKDest.FullName | Compress-Archive -DestinationPath (Join-Path -Path $ConfigPath.fullname -ChildPath 'NewPSProfile-BCK.zip') -Update
        $BCKDest.FullName | Remove-Item -Recurse -Force

        $ModModules = Get-Module PSToolKit
        if (-not($ModModules)) { $ModModules = Get-Module PSToolKit -ListAvailable }
        if (-not($ModModules)) { throw 'Module not found' }

        $NewFile = @"
#Force TLS 1.2 for all connections
if (`$PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

#Enable concise errorview for PS7 and up
if (`$psversiontable.psversion.major -ge 7) {
    `$ErrorView = 'ConciseView'
}

`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $ModModules.ModuleBase).Parent).FullName "\*\$($ModModules.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
Import-Module `$PRModule.FullName -Force
Start-PSProfile

"@


        $NewFile | Set-Content ([IO.Path]::Combine($folder.FullName, $ise)), ([IO.Path]::Combine($folder.FullName, $ps)), ([IO.Path]::Combine($folder.FullName, $vscode)) -Force
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ise)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ps)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $vscode)) -Color Cyan, Gray, Green


    }

} #end Function
