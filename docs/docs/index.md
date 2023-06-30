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
- Or from the created Powershell Script:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
(New-Object System.Net.WebClient).DownloadFile('https://bit.ly/35sEu2b', "$($env:tmp)\Start-PSToolkitSystemInitialize.ps1")
Import-Module (Get-Item "$($env:tmp)\Start-PSToolkitSystemInitialize.ps1") -Force; Start-PSToolkitSystemInitialize
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
 
## PS Controller Scripts
- boxstarter-install.ps1
- call-initial.ps1
- Initial-Setup.ps1
 
## Functions
- [`Add-ChocolateyPrivateRepo`](https://smitpi.github.io/PSToolKit/Add-ChocolateyPrivateRepo) -- Add a private repository to Chocolatey.
- [`Backup-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/Backup-ElevatedShortcut) -- Exports the RunAss shortcuts, to a zip file
- [`Backup-PowerShellProfile`](https://smitpi.github.io/PSToolKit/Backup-PowerShellProfile) -- Creates a zip file from the ps profile directories
- [`Compare-ADMembership`](https://smitpi.github.io/PSToolKit/Compare-ADMembership) -- Compare two users AD group memberships
- [`Connect-VMWareCluster`](https://smitpi.github.io/PSToolKit/Connect-VMWareCluster) -- Connect to a vSphere cluster to perform other commands or scripts
- [`Disable-WebEncoding`](https://smitpi.github.io/PSToolKit/Disable-WebEncoding) -- decode a URL
- [`Edit-SSHConfigFile`](https://smitpi.github.io/PSToolKit/Edit-SSHConfigFile) -- Creates and modifies the ssh config file in their profile.
- [`Enable-RemoteHostPSRemoting`](https://smitpi.github.io/PSToolKit/Enable-RemoteHostPSRemoting) -- enable ps remote remotely
- [`Enable-WebEncoding`](https://smitpi.github.io/PSToolKit/Enable-WebEncoding) -- encode a URL
- [`Export-ESXTemplate`](https://smitpi.github.io/PSToolKit/Export-ESXTemplate) -- Export all VM Templates from vSphere to local disk.
- [`Find-ChocolateyApp`](https://smitpi.github.io/PSToolKit/Find-ChocolateyApp) -- Search the online repo for software
- [`Find-OnlineModule`](https://smitpi.github.io/PSToolKit/Find-OnlineModule) -- Creates reports based on PSGallery.
- [`Find-OnlineScript`](https://smitpi.github.io/PSToolKit/Find-OnlineScript) -- Creates reports based on PSGallery. Filtered by scripts
- [`Get-CitrixClientVersion`](https://smitpi.github.io/PSToolKit/Get-CitrixClientVersion) -- Report on the CItrix workspace versions the users are using.
- [`Get-CitrixPolicy`](https://smitpi.github.io/PSToolKit/Get-CitrixPolicy) -- Export Citrix Policies
- [`Get-CommandFiltered`](https://smitpi.github.io/PSToolKit/Get-CommandFiltered) -- Finds commands on the system and sort it according to module
- [`Get-FolderSize`](https://smitpi.github.io/PSToolKit/Get-FolderSize) -- Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
- [`Get-FQDN`](https://smitpi.github.io/PSToolKit/Get-FQDN) -- Get FQDN for a device, and checks if it is online
- [`Get-FullADUserDetail`](https://smitpi.github.io/PSToolKit/Get-FullADUserDetail) -- Extract user details from the domain
- [`Get-MyPSGalleryReport`](https://smitpi.github.io/PSToolKit/Get-MyPSGalleryReport) -- Gallery report
- [`Get-MyPSGalleryStat`](https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStat) -- Show stats about my published modules.
- [`Get-NestedADGroupMember`](https://smitpi.github.io/PSToolKit/Get-NestedADGroupMember) -- Extract users from an AD group recursive, 4 levels deep.
- [`Get-ProcessPerformance`](https://smitpi.github.io/PSToolKit/Get-ProcessPerformance) -- Gets the top 10 processes by CPU %
- [`Get-PropertiesToCSV`](https://smitpi.github.io/PSToolKit/Get-PropertiesToCSV) -- Get member data of an object. Use it to create other PSObjects.
- [`Get-PSObject`](https://smitpi.github.io/PSToolKit/Get-PSObject) -- Show all Object Methods and Properties.
- [`Get-RDSSessionReport`](https://smitpi.github.io/PSToolKit/Get-RDSSessionReport) -- Reports on Connects and Disconnects on a RDS Farm.
- [`Get-ServerInventory`](https://smitpi.github.io/PSToolKit/Get-ServerInventory) -- Connect to remote host and collect server details.
- [`Get-SoftwareAudit`](https://smitpi.github.io/PSToolKit/Get-SoftwareAudit) -- Connects to a remote hosts and collect installed software details
- [`Get-SystemInfo`](https://smitpi.github.io/PSToolKit/Get-SystemInfo) -- Get system details of a remote device
- [`Get-SystemUptime`](https://smitpi.github.io/PSToolKit/Get-SystemUptime) -- Calculates the uptime of a system
- [`Get-WinEventLogExtract`](https://smitpi.github.io/PSToolKit/Get-WinEventLogExtract) -- Extract Event logs of a server list, and create html / excel report
- [`Import-CitrixSiteConfigFile`](https://smitpi.github.io/PSToolKit/Import-CitrixSiteConfigFile) -- Import the Citrix config file, and created a variable with the details
- [`Import-XamlConfigFile`](https://smitpi.github.io/PSToolKit/Import-XamlConfigFile) -- Import the wpf xaml file and create variables from objects
- [`Install-BGInfo`](https://smitpi.github.io/PSToolKit/Install-BGInfo) -- Install and auto runs bginfo at start up.
- [`Install-ChocolateyClient`](https://smitpi.github.io/PSToolKit/Install-ChocolateyClient) -- Downloads and installs the Chocolatey client.
- [`Install-ChocolateyServer`](https://smitpi.github.io/PSToolKit/Install-ChocolateyServer) -- This will download, install and setup a new Chocolatey Repo Server
- [`Install-LocalPSRepository`](https://smitpi.github.io/PSToolKit/Install-LocalPSRepository) -- Short desCreates a repository for offline installations.
- [`Install-MSUpdate`](https://smitpi.github.io/PSToolKit/Install-MSUpdate) -- Perform windows update
- [`Install-NFSClient`](https://smitpi.github.io/PSToolKit/Install-NFSClient) -- Install NFS Client for windows
- [`Install-PowerShell7x`](https://smitpi.github.io/PSToolKit/Install-PowerShell7x) -- Install ps7
- [`Install-RSAT`](https://smitpi.github.io/PSToolKit/Install-RSAT) -- Install Remote Admin Tools
- [`Install-VMWareTool`](https://smitpi.github.io/PSToolKit/Install-VMWareTool) -- Install vmware tools from chocolatety
- [`New-CitrixSiteConfigFile`](https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile) -- A config file with Citrix server details and URLs. To be used in scripts.
- [`New-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/New-ElevatedShortcut) -- Creates a shortcut to a script or exe that runs as admin, without UNC
- [`New-GodModeFolder`](https://smitpi.github.io/PSToolKit/New-GodModeFolder) -- Creates a God Mode Folder
- [`New-GoogleSearch`](https://smitpi.github.io/PSToolKit/New-GoogleSearch) -- Start a new browser tab with search string.
- [`New-MSEdgeWebApp`](https://smitpi.github.io/PSToolKit/New-MSEdgeWebApp) -- Creates a new webapp to a URL, and save the shortcut on your system.
- [`New-PSGenericList`](https://smitpi.github.io/PSToolKit/New-PSGenericList) -- Creates a .net list object
- [`New-PSModule`](https://smitpi.github.io/PSToolKit/New-PSModule) -- Creates a new PowerShell module.
- [`New-PSProfile`](https://smitpi.github.io/PSToolKit/New-PSProfile) -- Creates new profile files in the documents folder
- [`New-PSReportingScript`](https://smitpi.github.io/PSToolKit/New-PSReportingScript) -- Script template for scripts to create reports
- [`New-PSScript`](https://smitpi.github.io/PSToolKit/New-PSScript) -- Creates a new PowerShell script. With PowerShell Script Info
- [`New-SuggestedInfraName`](https://smitpi.github.io/PSToolKit/New-SuggestedInfraName) -- Generates a list of usernames and server names, that can be used as test / demo data.
- [`Publish-ModuleToLocalRepo`](https://smitpi.github.io/PSToolKit/Publish-ModuleToLocalRepo) -- Checks for required modules and upload all to your local repo.
- [`Remove-CIMUserProfile`](https://smitpi.github.io/PSToolKit/Remove-CIMUserProfile) -- Uses CimInstance to remove a user profile
- [`Remove-FaultyProfileList`](https://smitpi.github.io/PSToolKit/Remove-FaultyProfileList) -- Fixes Profilelist in the registry. To fix user logon with temp profile.
- [`Remove-HiddenDevice`](https://smitpi.github.io/PSToolKit/Remove-HiddenDevice) -- Removes ghost devices from your system
- [`Remove-UserProfile`](https://smitpi.github.io/PSToolKit/Remove-UserProfile) -- Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry
- [`Reset-Module`](https://smitpi.github.io/PSToolKit/Reset-Module) -- Removes and force import a module.
- [`Reset-PSGallery`](https://smitpi.github.io/PSToolKit/Reset-PSGallery) -- Reset gallery to default settings
- [`Resolve-SID`](https://smitpi.github.io/PSToolKit/Resolve-SID) -- Resolves the Sid
- [`Restore-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/Restore-ElevatedShortcut) -- Restore the RunAss shortcuts, from a zip file
- [`Search-Script`](https://smitpi.github.io/PSToolKit/Search-Script) -- Search for a string in a directory of ps1 scripts.
- [`Set-FolderCustomIcon`](https://smitpi.github.io/PSToolKit/Set-FolderCustomIcon) -- Will change the icon of a folder to a custom selected icon
- [`Set-PSProjectFile`](https://smitpi.github.io/PSToolKit/Set-PSProjectFile) -- Creates and modify needed files for a PS project from existing module files.
- [`Set-PSToolKitSystemSetting`](https://smitpi.github.io/PSToolKit/Set-PSToolKitSystemSetting) -- Set multiple settings on desktop or server
- [`Set-SharedPSProfile`](https://smitpi.github.io/PSToolKit/Set-SharedPSProfile) -- Redirects PowerShell and WindowsPowerShell profile folder to another path.
- [`Set-StaticIP`](https://smitpi.github.io/PSToolKit/Set-StaticIP) -- Set static IP on device
- [`Set-TempFolder`](https://smitpi.github.io/PSToolKit/Set-TempFolder) -- Set all the temp environmental variables to c:\temp
- [`Set-UserDesktopWallpaper`](https://smitpi.github.io/PSToolKit/Set-UserDesktopWallpaper) -- Change the wallpaper for the user.
- [`Set-VSCodeExplorerSortOrder`](https://smitpi.github.io/PSToolKit/Set-VSCodeExplorerSortOrder) -- Change the sort order in VSCode explorer
- [`Set-WindowsAutoLogin`](https://smitpi.github.io/PSToolKit/Set-WindowsAutoLogin) -- Enable autologin on a device.
- [`Show-ComputerManagement`](https://smitpi.github.io/PSToolKit/Show-ComputerManagement) -- Opens the Computer Management of the system or remote system
- [`Show-ModulePathList`](https://smitpi.github.io/PSToolKit/Show-ModulePathList) -- Show installed module list grouped by install path.
- [`Show-MyPSGalleryModule`](https://smitpi.github.io/PSToolKit/Show-MyPSGalleryModule) -- Show version numbers ext. about my modules.
- [`Show-PSToolKit`](https://smitpi.github.io/PSToolKit/Show-PSToolKit) -- Show details of the commands in this module.
- [`Start-DomainControllerReplication`](https://smitpi.github.io/PSToolKit/Start-DomainControllerReplication) -- Start replication between Domain Controllers.
- [`Start-PowerShellAsAdmin`](https://smitpi.github.io/PSToolKit/Start-PowerShellAsAdmin) -- Starts a porwershell session as an administrator
- [`Start-PSProfile`](https://smitpi.github.io/PSToolKit/Start-PSProfile) -- My PS Profile for all sessions.
- [`Start-PSRoboCopy`](https://smitpi.github.io/PSToolKit/Start-PSRoboCopy) -- My wrapper for default robocopy switches
- [`Start-PSScriptAnalyzer`](https://smitpi.github.io/PSToolKit/Start-PSScriptAnalyzer) -- Run and report ScriptAnalyzer output
- [`Start-PSToolkitSystemInitialize`](https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize) -- Initialize a blank machine.
- [`Test-CitrixCloudConnector`](https://smitpi.github.io/PSToolKit/Test-CitrixCloudConnector) -- Perform basic connection tests to Citrix cloud.
- [`Test-CitrixVDAPort`](https://smitpi.github.io/PSToolKit/Test-CitrixVDAPort) -- Test connection between DDC and VDI
- [`Test-IsFileOpen`](https://smitpi.github.io/PSToolKit/Test-IsFileOpen) -- Checks if a file is open
- [`Test-PSPendingReboot`](https://smitpi.github.io/PSToolKit/Test-PSPendingReboot) -- This script tests various registry values to see if the local computer is pending a reboot.
- [`Test-PSRemote`](https://smitpi.github.io/PSToolKit/Test-PSRemote) -- Test PSb Remote to a device.
- [`Test-SystemOnline`](https://smitpi.github.io/PSToolKit/Test-SystemOnline) -- Does basic checks for connecting to a remote device
- [`Update-ListOfDDC`](https://smitpi.github.io/PSToolKit/Update-ListOfDDC) -- Update list of ListOfDDCs in the registry
- [`Update-LocalHelp`](https://smitpi.github.io/PSToolKit/Update-LocalHelp) -- Downloads and saves help files locally
- [`Update-MyModulesFromGitHub`](https://smitpi.github.io/PSToolKit/Update-MyModulesFromGitHub) -- Updates my modules
- [`Update-PSDefaultParameter`](https://smitpi.github.io/PSToolKit/Update-PSDefaultParameter) -- Updates the $PSDefaultParameterValues variable
- [`Update-PSModuleInfo`](https://smitpi.github.io/PSToolKit/Update-PSModuleInfo) -- Update PowerShell module manifest file
- [`Write-Ascii`](https://smitpi.github.io/PSToolKit/Write-Ascii) -- Create Ascii Art
- [`Write-PSMessage`](https://smitpi.github.io/PSToolKit/Write-PSMessage) -- Writes the given into to screen
- [`Write-PSReports`](https://smitpi.github.io/PSToolKit/Write-PSReports) -- Creates a excel or html report
- [`Write-PSToolKitLog`](https://smitpi.github.io/PSToolKit/Write-PSToolKitLog) -- Create a log for scripts
