
<#PSScriptInfo

.VERSION 0.1.0

.GUID afc9054d-554a-4c74-a3d5-c4cbf8690029

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
Created [25/11/2021_01:10] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Install Windows Terminal from GitHub on any OS

#>


<#
.SYNOPSIS
Install Windows Terminal from GitHub on any OS

.DESCRIPTION
Install Windows Terminal from GitHub on any OS

.EXAMPLE
Install-WindowsTerminal

#>
Function Install-WindowsTerminal {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-WindowsTerminal')]
    PARAM()

    $package = Get-AppxPackage -Name Microsoft.WindowsTerminal
    if ($package.Status -like 'OK') {
        Write-Color "[Installing]", ' Microsoft Terminal: ', 'Already Installed' -Color Yellow,Cyan,DarkRed
    }
    else {
        if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
            $ChocoApp = choco search "microsoft-windows-terminal" --exact --local-only --limit-output
            $ChocoAppOnline = choco search "microsoft-windows-terminal" --exact --limit-output
            if ($null -eq $ChocoApp) {
                Write-Color '[Installing] ', $("microsoft-windows-terminal"), ' from source ', "chocolatey" -Color Yellow, Cyan, Green, Cyan
                choco upgrade $("microsoft-windows-terminal") --accept-license --limit-output -y | Out-Null
                if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $("microsoft-windows-terminal") Code: $($LASTEXITCODE)"}
            } else {
                Write-Color '[Installing] ', $($ChocoApp.split('|')[0]), " (Version: $($ChocoApp.split('|')[1]))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
                if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
                    Write-Color '[Updating] ', $("microsoft-windows-terminal"), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', $app.Source -Color Yellow, Cyan, Yellow, Green, Cyan
                    choco upgrade $("microsoft-windows-terminal") --accept-license --limit-output -y | Out-Null
                    if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $("microsoft-windows-terminal") Code: $($LASTEXITCODE)"}
                }
            }
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = 'https://github.com/microsoft/terminal/releases/latest/'
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $ver = ($([String]$response.GetResponseHeader('Location')).split('/'))[-1].Replace('v', '')
        $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + "/Microsoft.WindowsTerminal_$($ver)_8wekyb3d8bbwe.msixbundle"
        $OutFile = [IO.Path]::Combine('c:\temp', 'MSTerminal-latest.msixbundle')

        if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

        Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile
        Add-AppxPackage -Path $OutFile -ForceUpdateFromAnyVersion -InstallAllResources

    }
    $package = Get-AppxPackage -Name Microsoft.WindowsTerminal
    if ($package.Status -like 'OK') {
        Write-Color 'Windows Terminal: ', 'Installation Successful' -Color Cyan, Green
        $settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', $((Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName), 'LocalState', 'Settings.json')

        Invoke-WebRequest -Uri 'https://git.io/JMTRv' -OutFile $settingsFile
        Write-Color 'Windows Terminal Settings: ', 'Installation Successful' -Color Cyan, Green

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = 'https://github.com/microsoft/cascadia-code/releases/latest/'
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $ver = ($([String]$response.GetResponseHeader('Location')).split('/'))[-1].Replace('v', '')
        $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + "/CascadiaCode-$($ver).zip"
        $OutFile = [IO.Path]::Combine('c:\temp', 'CascadiaCode.zip')
        $ExpandDir = New-Item ([IO.Path]::Combine('c:\temp', 'CascadiaCode')) -ItemType Directory -Force
        $ttf = [IO.Path]::Combine('c:\temp', 'CascadiaCode', 'ttf', 'CascadiaCodePL.ttf')

        Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile -Verbose
        Expand-Archive -Path $OutFile -OutputPath $ExpandDir -ShowProgress

        $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
        $tt = Get-Item $ttf
        $tt | ForEach-Object { $fonts.CopyHere($_.fullname) }

        Write-Color 'Windows Terminal Fonts: ', 'Installation Successful' -Color Cyan, Green

    }
    else { Write-Color 'Windows Terminal Settings: ', 'Installation Failed' -Color Cyan, red }

} #end Function
