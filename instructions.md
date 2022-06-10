# PSToolKit
 
## Description
A Repository of my random scripts and functions writen over the years, there is a wyde range of tools in this module, used by a SysAdmin and EUC Administrator.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSToolKit)
```
Install-Module -Name PSToolKit -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/PSToolKit)
```
git clone https://github.com/smitpi/PSToolKit (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSToolKit)
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
