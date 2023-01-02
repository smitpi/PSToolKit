# PSToolKit

## Description

A Repository of my random scripts and functions writen over the years, there is a wyde range of tools in this module, used by a SysAdmin and EUC Administrator.

---

## Win-Bootstrap

Boxstarter scripts to setup a new windows machine.

- Run the following commands to install Boxstarter:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 
iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force
```

- Then click on one of the below links to start.

|Click link to run  |Description  |
|---------|---------|
| [System Setup](http://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1')     | Use [PSToolKit](https://github.com/smitpi/PSToolKit) to Install a new System.|

> **Warning**
>> You will need a valid **github userid** and **token** to continue

---

## Getting Started

- Run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/PSToolKit)

```powershell
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSToolKit)
git clone --depth 1 https://github.com/smitpi/PSToolKit $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```

- Then import the module into your session

```powershell
Import-Module PSToolKit -Verbose -Force
```

- or run these commands for more help and details.

```powershell
Get-Command -Module PSToolKit
Get-Help about_PSToolKit
```

Documentation can be found at: [Github_Pages](https://smitpi.github.io/PSToolKit)
