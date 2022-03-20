
<#PSScriptInfo

.VERSION 0.1.0

.GUID 094d0fea-8c06-48bf-b3e6-829f6a83396e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS MS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/11/2021_00:09] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Install the package manager winget

#>


<#
.SYNOPSIS
Install the package manager winget

.DESCRIPTION
Install the package manager winget

.EXAMPLE
Install-MSWinget

#>
Function Install-MSWinget {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MSWinget')]

    PARAM()
    # 1 - Work Station
    # 2 - Domain Controller
    # 3 - Server
    $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object ProductType, Version, BuildNumber
    if (([version]$checkver.Version).Major -gt 9 -and ([version]$checkver.Version).Build -gt 14393) {

        try {
            $checkInstall = [bool](winget -ErrorAction Stop)
        }
        catch { $checkInstall = $false }
        if ($checkInstall) { Write-Color 'Winget: ', 'Already Installed' -Color Cyan, Yellow }
        else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $url = 'https://github.com/microsoft/winget-cli/releases/latest/'
            $request = [System.Net.WebRequest]::Create($url)
            $request.AllowAutoRedirect = $false
            $response = $request.GetResponse()
            $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + '/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
            $OutFile = [IO.Path]::Combine('c:\temp', 'winget-latest.msixbundle')

            if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

            Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile

            if (![bool](Get-AppxPackage -Name Microsoft.VCLibs*)) {
                Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
            }

            Add-AppxPackage -Path $OutFile -ErrorAction Stop

            #winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
            if (Test-Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json") {
                $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
                $settingsJson =
                @'
    {
        // For documentation on these settings, see: https://aka.ms/winget-settings
        "experimentalFeatures": {
          "experimentalMSStore": true,
        }
    }
'@;
                $settingsJson | Out-File $settingsPath -Encoding utf8
            }

            try {
                $checkInstall2 = [bool](winget -ErrorAction Stop)
            }
            catch { $checkInstall2 = $false }
            if ($checkInstall2) { Write-Color 'Winget: ', 'Installation Successful' -Color Cyan, green }
            else { Write-Color 'Winget: ', 'Installation Failed' -Color Cyan, red }
        }
    }
    else { Write-Warning 'Your Operating System is not compatible, Windows 10 build 14393 and higher is' }




} #end Function
