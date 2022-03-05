
<#PSScriptInfo

.VERSION 0.1.0

.GUID a41b2154-729b-4415-a02a-204fdec4dd86

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
Created [12/01/2022_08:40] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Downloads and installs the Chocolatey client.

#>


<#
.SYNOPSIS
Downloads and installs the Chocolatey client.

.DESCRIPTION
Downloads and installs the Chocolatey client.

.EXAMPLE
Install-ChocolateyClient

#>
Function Install-ChocolateyClient {
  [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyClient')]
  PARAM()

  if ((Test-Path $profile) -eq $false ) {
    Write-Warning 'Profile does not exist, creating file.'
    New-Item -ItemType File -Path $Profile -Force
  }

		$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) { Throw 'Must be running an elevated prompt to use function' }

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $web = New-Object System.Net.WebClient
    $web.DownloadFile('https://community.chocolatey.org/install.ps1', "$($env:TEMP)\choco-install.ps1")
    & "$($env:TEMP)\choco-install.ps1"
    Write-Color '[Installing] ', 'Chocolatey Client: ', 'Complete' -Color Cyan, Yellow, Green
  }
  else {
    Write-Color '[Installing] ', 'Chocolatey Client: ', 'Aleady Installed' -Color Cyan, Yellow, Green
  }

  choco config set --name="'useEnhancedExitCodes'" --value="'true'"
  choco config set --name="'allowGlobalConfirmation'" --value="'true'"
  choco config set --name="'removePackageInformationOnUninstall'" --value="'true'"
  Write-Color '[Installing] ', 'ChocolateyClient: ', 'Config set' -Color Cyan, Yellow, Green

} #end Function
