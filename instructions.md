# PSToolKit
 
## Description
A Repository of my random scripts and functions writen over the years, there is a wyde range of tools in this module, used by a SysAdmin and EUC Administrator.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSToolKit)
```
Install-Module -Name PSToolKit -Verbose
```
- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/PSToolKit)
```
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSToolKit)
git clone --depth 1 https://github.com/smitpi/PSToolKit $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```
- Then import the module into your session
```
Import-Module PSToolKit -Verbose -Force
```
- or run these commands for more help and details.
```
Get-Command -Module PSToolKit
Get-Help about_PSToolKit
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/PSToolKit)
