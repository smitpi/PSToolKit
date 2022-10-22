
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
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSProfile')]
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

    $ModModules = Get-Module PSToolKit
    if (-not($ModModules)) { $ModModules = Get-Module PSToolKit -ListAvailable }
    if (-not($ModModules)) { throw 'Module not found' }

    foreach ($folder in $folders) {
        $configfolder = [IO.Path]::Combine($folder.FullName, 'Config')

        $Profilefiles = Get-ChildItem -File "$($folder.FullName)\*profile*.ps1"
        if ($Profilefiles) {
            if (-not(Test-Path $configfolder)) {New-Item $configfolder -ItemType directory -Force | Out-Null}

            $Profilefiles | Compress-Archive -DestinationPath (Join-Path -Path $configfolder -ChildPath "NewPSProfile-BCK-$(Get-Date -Format 'dd.MMM.yyyy_HH\hmm').zip")
            $Profilefiles | Remove-Item -Force
        }

        $NewFile = @"

################################
#region common settings       ##
################################
#Force TLS 1.2 for all connections
if (`$PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

#Enable concise error view for PS7 and up
if (`$psversiontable.psversion.major -ge 7) {
    `$ErrorView = 'ConciseView'
}
#endregion


################################
#region Start PSToolKit       ##
################################
`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $ModModules.ModuleBase).Parent).FullName "\*\$($ModModules.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
Import-Module `$PRModule.FullName -Force
Start-PSProfile
#endregion

################################
#region Add custom prompt     ##
################################
function prompt {
    `$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    `$principal = [Security.Principal.WindowsPrincipal] `$identity
    `$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    `$Seconds = (New-TimeSpan -Start (Get-History)[-1].StartExecutionTime -End (Get-History)[-1].EndExecutionTime).Seconds
    
    if (Test-Path variable:/PSDebugContext) {
        `$Part1 = '[DBG]'
    } elseif (`$principal.IsInRole(`$adminRole)) {
        `$Part1 = '[ADMIN]'
    } else {
        `$Part1 = ''
    }
    if (`$Part1) {
        Write-Host `$Part1 -NoNewline -ForegroundColor Red
    }
    Write-Host "(`$(`$Seconds)sec)[`$(`$env:USERNAME.ToLower())@`$(`$env:USERDNSDOMAIN.ToLower())] " -ForegroundColor Cyan -NoNewline
    if ((Get-Location).ProviderPath.Length -lt 50) {
        Write-Host "`$(Get-Location)" -NoNewline
    } else {
        Write-Host "`$((Get-Location).ProviderPath[0..2] | Join-String)....`$((Get-Location).ProviderPath[-50..-1] | Join-String)" -NoNewline
    }
    if (`$NestedPromptLevel -ge 1) { 
        Write-Host ' >>' -NoNewline 
    } else {
        Write-Host ' >' -NoNewline
    }
    return ' '
}
#endregion
"@


        $NewFile | Set-Content ([IO.Path]::Combine($folder.FullName, $ise)), ([IO.Path]::Combine($folder.FullName, $ps)), ([IO.Path]::Combine($folder.FullName, $vscode)) -Force
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ise)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ps)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $vscode)) -Color Cyan, Gray, Green
    }

} #end Function
