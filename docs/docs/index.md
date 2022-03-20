# PSToolKit
 
## Description
Powershell Scripts and functions for a system administrator
 
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
 
## Functions
- [Add-ChocolateyPrivateRepo](https://smitpi.github.io/PSToolKit/#Add-ChocolateyPrivateRepo) -- Add a private repository to Chocolatey.
- [Backup-ElevatedShortcut](https://smitpi.github.io/PSToolKit/#Backup-ElevatedShortcut) -- Exports the RunAss shortcuts, to a zip file
- [Backup-PowerShellProfile](https://smitpi.github.io/PSToolKit/#Backup-PowerShellProfile) -- Creates a zip file from the ps profile directories
- [Connect-VMWareCluster](https://smitpi.github.io/PSToolKit/#Connect-VMWareCluster) -- Connect to a vSphere cluster to perform other commands or scripts
- [Edit-ChocolateyAppsList](https://smitpi.github.io/PSToolKit/#Edit-ChocolateyAppsList) -- Add or remove apps from the json file used in Install-ChocolateyApps
- [Edit-HostsFile](https://smitpi.github.io/PSToolKit/#Edit-HostsFile) -- Edit the hosts file
- [Edit-PSModulesLists](https://smitpi.github.io/PSToolKit/#Edit-PSModulesLists) -- Edit the Modules json files.
- [Enable-RemoteHostPSRemoting](https://smitpi.github.io/PSToolKit/#Enable-RemoteHostPSRemoting) -- enable ps remote remotely
- [Export-CitrixPolicySettings](https://smitpi.github.io/PSToolKit/#Export-CitrixPolicySettings) -- Citrix policy export.
- [Export-ESXTemplates](https://smitpi.github.io/PSToolKit/#Export-ESXTemplates) -- Export all VM Templates from vSphere to local disk.
- [Export-PSGallery](https://smitpi.github.io/PSToolKit/#Export-PSGallery) -- Export details of all modules and scripts on psgallery to excel
- [Find-ChocolateyApps](https://smitpi.github.io/PSToolKit/#Find-ChocolateyApps) -- Search the online repo for software
- [Find-OnlineModule](https://smitpi.github.io/PSToolKit/#Find-OnlineModule) -- Find a module on psgallery
- [Find-OnlineScript](https://smitpi.github.io/PSToolKit/#Find-OnlineScript) -- Find Script on PSGallery
- [Find-PSScripts](https://smitpi.github.io/PSToolKit/#Find-PSScripts) -- Find and update script info
- [Format-AllObjectsInAListView](https://smitpi.github.io/PSToolKit/#Format-AllObjectsInAListView) -- Cast an array or psobject and display it in list view
- [Get-AllUsersInGroup](https://smitpi.github.io/PSToolKit/#Get-AllUsersInGroup) -- Get details of all users in a group
- [Get-CitrixClientVersions](https://smitpi.github.io/PSToolKit/#Get-CitrixClientVersions) -- Report on the CItrix workspace versions the users are using.
- [Get-CommandFiltered](https://smitpi.github.io/PSToolKit/#Get-CommandFiltered) -- Finds commands on the system and sort it according to module
- [Get-DeviceUptime](https://smitpi.github.io/PSToolKit/#Get-DeviceUptime) -- Calculates the uptime of a system
- [Get-FolderSize](https://smitpi.github.io/PSToolKit/#Get-FolderSize) -- Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
- [Get-FQDN](https://smitpi.github.io/PSToolKit/#Get-FQDN) -- Get FQDN for a device, and checks if it is online
- [Get-FullADUserDetail](https://smitpi.github.io/PSToolKit/#Get-FullADUserDetail) -- Extract handy info of an AD user
- [Get-MyPSGalleryStats](https://smitpi.github.io/PSToolKit/#Get-MyPSGalleryStats) -- Show stats about my published modules.
- [Get-ProcessPerformance](https://smitpi.github.io/PSToolKit/#Get-ProcessPerformance) -- Gets the top 10 processes by CPU %
- [Get-PropertiesToCSV](https://smitpi.github.io/PSToolKit/#Get-PropertiesToCSV) -- Get member data of an object. Use it to create other PSObjects.
- [Get-SoftwareAudit](https://smitpi.github.io/PSToolKit/#Get-SoftwareAudit) -- Connects to a remote hosts and collect installed software details
- [Get-SystemInfo](https://smitpi.github.io/PSToolKit/#Get-SystemInfo) -- Get system details of a remote device
- [Get-WinEventLogExtract](https://smitpi.github.io/PSToolKit/#Get-WinEventLogExtract) -- Extract Event logs of a server list, and create html / excel report
- [Import-CitrixSiteConfigFile](https://smitpi.github.io/PSToolKit/#Import-CitrixSiteConfigFile) -- Import the Citrix config file, and created a variable with the details
- [Import-XamlConfigFile](https://smitpi.github.io/PSToolKit/#Import-XamlConfigFile) -- Import the wpf xaml file and create variables from objects
- [Install-BGInfo](https://smitpi.github.io/PSToolKit/#Install-BGInfo) -- Install and auto runs bginfo at startup.
- [Install-ChocolateyApps](https://smitpi.github.io/PSToolKit/#Install-ChocolateyApps) -- Install chocolatey apps from a json list.
- [Install-ChocolateyClient](https://smitpi.github.io/PSToolKit/#Install-ChocolateyClient) -- Downloads and installs the Chocolatey client.
- [Install-ChocolateyServer](https://smitpi.github.io/PSToolKit/#Install-ChocolateyServer) -- This will download, install and setup a new Chocolatey Repo Server
- [Install-MSWinget](https://smitpi.github.io/PSToolKit/#Install-MSWinget) -- Install the package manager winget
- [Install-PSModules](https://smitpi.github.io/PSToolKit/#Install-PSModules) -- Install modules from .json file.
- [New-CitrixSiteConfigFile](https://smitpi.github.io/PSToolKit/#New-CitrixSiteConfigFile) -- All a config file with Citrix server details. To be imported as variables.
- [New-ElevatedShortcut](https://smitpi.github.io/PSToolKit/#New-ElevatedShortcut) -- Creates a shortcut to a script or exe that runs as admin, without UNC
- [New-GodModeFolder](https://smitpi.github.io/PSToolKit/#New-GodModeFolder) -- Creates a God Mode Folder
- [New-PSModule](https://smitpi.github.io/PSToolKit/#New-PSModule) -- Creates a new PowerShell module.
- [New-PSProfile](https://smitpi.github.io/PSToolKit/#New-PSProfile) -- Creates new profile files in the documents folder
- [New-PSScript](https://smitpi.github.io/PSToolKit/#New-PSScript) -- Creates a new PowerShell script. With PowerShell Script Info
- [New-SuggestedInfraNames](https://smitpi.github.io/PSToolKit/#New-SuggestedInfraNames) -- Generates a list of usernames and server names, that can be used as test / demo data.
- [Remove-CIMUserProfiles](https://smitpi.github.io/PSToolKit/#Remove-CIMUserProfiles) -- Uses CimInstance to remove a user profile
- [Remove-FaultyProfileList](https://smitpi.github.io/PSToolKit/#Remove-FaultyProfileList) -- Fixes Profilelist in the registry. To fix user logon with temp profile.
- [Remove-HiddenDevices](https://smitpi.github.io/PSToolKit/#Remove-HiddenDevices) -- Removes ghost devices from your system
- [Remove-UserProfile](https://smitpi.github.io/PSToolKit/#Remove-UserProfile) -- Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry
- [Restore-ElevatedShortcut](https://smitpi.github.io/PSToolKit/#Restore-ElevatedShortcut) -- Restore the RunAss shortcuts, from a zip file
- [Search-Scripts](https://smitpi.github.io/PSToolKit/#Search-Scripts) -- Search for a string in a directory of ps1 scripts.
- [Set-PSToolKitSystemSettings](https://smitpi.github.io/PSToolKit/#Set-PSToolKitSystemSettings) -- Set multiple settings on desktop or server
- [Set-SharedPSProfile](https://smitpi.github.io/PSToolKit/#Set-SharedPSProfile) -- Redirects PowerShell profile to network share.
- [Set-StaticIP](https://smitpi.github.io/PSToolKit/#Set-StaticIP) -- Set static IP on device
- [Set-TempFolder](https://smitpi.github.io/PSToolKit/#Set-TempFolder) -- Set all the temp environmental variables to c:\temp
- [Set-WindowsAutoLogin](https://smitpi.github.io/PSToolKit/#Set-WindowsAutoLogin) -- Enable autologin on a device.
- [Show-ComputerManagement](https://smitpi.github.io/PSToolKit/#Show-ComputerManagement) -- Opens the Computer Management of the system or remote system
- [Show-PSToolKit](https://smitpi.github.io/PSToolKit/#Show-PSToolKit) -- Show details of the commands in this module
- [Start-PSModuleMaintenance](https://smitpi.github.io/PSToolKit/#Start-PSModuleMaintenance) -- Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.
- [Start-PSProfile](https://smitpi.github.io/PSToolKit/#Start-PSProfile) -- My PS Profile for all sessions.
- [Start-PSRoboCopy](https://smitpi.github.io/PSToolKit/#Start-PSRoboCopy) -- My wrapper for default robocopy switches
- [Start-PSScriptAnalyzer](https://smitpi.github.io/PSToolKit/#Start-PSScriptAnalyzer) -- Run and report ScriptAnalyzer output
- [Start-PSToolkitSystemInitialize](https://smitpi.github.io/PSToolKit/#Start-PSToolkitSystemInitialize) -- Initialize a blank machine.
- [Sync-PSFolders](https://smitpi.github.io/PSToolKit/#Sync-PSFolders) -- Compare two directories and copy the differences
- [Test-CitrixCloudConnector](https://smitpi.github.io/PSToolKit/#Test-CitrixCloudConnector) -- Perform basic connection tests to CItrix cloud.
- [Test-CitrixVDAPorts](https://smitpi.github.io/PSToolKit/#Test-CitrixVDAPorts) -- Test connection between ddc and vda
- [Test-PendingReboot](https://smitpi.github.io/PSToolKit/#Test-PendingReboot) -- This script tests various registry values to see if the local computer is pending a reboot.
- [Test-PSRemote](https://smitpi.github.io/PSToolKit/#Test-PSRemote) -- Test PSb Remote to a device.
- [Update-ListOfDDCs](https://smitpi.github.io/PSToolKit/#Update-ListOfDDCs) -- Update list of ListOfDDCs in the registry
- [Update-LocalHelp](https://smitpi.github.io/PSToolKit/#Update-LocalHelp) -- Downloads and saves help files locally
- [Update-PSModuleInfo](https://smitpi.github.io/PSToolKit/#Update-PSModuleInfo) -- Update PowerShell module manifest file
- [Update-PSScriptInfo](https://smitpi.github.io/PSToolKit/#Update-PSScriptInfo) -- Update PowerShell ScriptFileInfo
- [Update-PSToolKit](https://smitpi.github.io/PSToolKit/#Update-PSToolKit) -- Update PSToolKit from GitHub.
- [Update-PSToolKitConfigFiles](https://smitpi.github.io/PSToolKit/#Update-PSToolKitConfigFiles) -- Manages the config files for the PSToolKit Module.
- [Write-Ascii](https://smitpi.github.io/PSToolKit/#Write-Ascii) -- Create Ascii Art
- [Write-PSToolKitLog](https://smitpi.github.io/PSToolKit/#Write-PSToolKitLog) -- Create a log for scripts
