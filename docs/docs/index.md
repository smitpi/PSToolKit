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
 
## Functions
- [`Add-ChocolateyPrivateRepo`](https://smitpi.github.io/PSToolKit/#Add-ChocolateyPrivateRepo) -- Add a private repository to Chocolatey.
- [`Backup-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/#Backup-ElevatedShortcut) -- Exports the RunAss shortcuts, to a zip file
- [`Backup-PowerShellProfile`](https://smitpi.github.io/PSToolKit/#Backup-PowerShellProfile) -- Creates a zip file from the ps profile directories
- [`Compare-ADMembership`](https://smitpi.github.io/PSToolKit/#Compare-ADMembership) -- Compare two users AD group memberships
- [`Connect-VMWareCluster`](https://smitpi.github.io/PSToolKit/#Connect-VMWareCluster) -- Connect to a vSphere cluster to perform other commands or scripts
- [`Edit-ChocolateyAppsList`](https://smitpi.github.io/PSToolKit/#Edit-ChocolateyAppsList) -- Add or remove apps from the json file used in Install-ChocolateyApps
- [`Edit-HostsFile`](https://smitpi.github.io/PSToolKit/#Edit-HostsFile) -- Edit the hosts file
- [`Edit-PSModulesList`](https://smitpi.github.io/PSToolKit/#Edit-PSModulesList) -- Edit the Modules json files.
- [`Edit-SSHConfigFile`](https://smitpi.github.io/PSToolKit/#Edit-SSHConfigFile) -- Creates and modifies the ssh config file in their profile.
- [`Enable-RemoteHostPSRemoting`](https://smitpi.github.io/PSToolKit/#Enable-RemoteHostPSRemoting) -- enable ps remote remotely
- [`Export-ESXTemplate`](https://smitpi.github.io/PSToolKit/#Export-ESXTemplate) -- Export all VM Templates from vSphere to local disk.
- [`Find-ChocolateyApp`](https://smitpi.github.io/PSToolKit/#Find-ChocolateyApp) -- Search the online repo for software
- [`Find-OnlineModule`](https://smitpi.github.io/PSToolKit/#Find-OnlineModule) -- Creates reports based on PSGallery.
- [`Find-OnlineScript`](https://smitpi.github.io/PSToolKit/#Find-OnlineScript) -- Creates reports based on PSGallery. Filtered by scripts
- [`Format-AllObjectsInAListView`](https://smitpi.github.io/PSToolKit/#Format-AllObjectsInAListView) -- Cast an array or psobject and display it in list view
- [`Get-AllUsersInGroup`](https://smitpi.github.io/PSToolKit/#Get-AllUsersInGroup) -- Get details of all users in a group
- [`Get-CitrixClientVersion`](https://smitpi.github.io/PSToolKit/#Get-CitrixClientVersion) -- Report on the CItrix workspace versions the users are using.
- [`Get-CitrixPolicies`](https://smitpi.github.io/PSToolKit/#Get-CitrixPolicies) -- Export Citrix Policies
- [`Get-CommandFiltered`](https://smitpi.github.io/PSToolKit/#Get-CommandFiltered) -- Finds commands on the system and sort it according to module
- [`Get-DeviceUptime`](https://smitpi.github.io/PSToolKit/#Get-DeviceUptime) -- Calculates the uptime of a system
- [`Get-FolderSize`](https://smitpi.github.io/PSToolKit/#Get-FolderSize) -- Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
- [`Get-FQDN`](https://smitpi.github.io/PSToolKit/#Get-FQDN) -- Get FQDN for a device, and checks if it is online
- [`Get-FullADUserDetail`](https://smitpi.github.io/PSToolKit/#Get-FullADUserDetail) -- Extract user details from the domain
- [`Get-MyPSGalleryStat`](https://smitpi.github.io/PSToolKit/#Get-MyPSGalleryStat) -- Show stats about my published modules.
- [`Get-ProcessPerformance`](https://smitpi.github.io/PSToolKit/#Get-ProcessPerformance) -- Gets the top 10 processes by CPU %
- [`Get-PropertiesToCSV`](https://smitpi.github.io/PSToolKit/#Get-PropertiesToCSV) -- Get member data of an object. Use it to create other PSObjects.
- [`Get-SoftwareAudit`](https://smitpi.github.io/PSToolKit/#Get-SoftwareAudit) -- Connects to a remote hosts and collect installed software details
- [`Get-SystemInfo`](https://smitpi.github.io/PSToolKit/#Get-SystemInfo) -- Get system details of a remote device
- [`Get-WinEventLogExtract`](https://smitpi.github.io/PSToolKit/#Get-WinEventLogExtract) -- Extract Event logs of a server list, and create html / excel report
- [`Import-CitrixSiteConfigFile`](https://smitpi.github.io/PSToolKit/#Import-CitrixSiteConfigFile) -- Import the Citrix config file, and created a variable with the details
- [`Import-XamlConfigFile`](https://smitpi.github.io/PSToolKit/#Import-XamlConfigFile) -- Import the wpf xaml file and create variables from objects
- [`Install-BGInfo`](https://smitpi.github.io/PSToolKit/#Install-BGInfo) -- Install and auto runs bginfo at startup.
- [`Install-ChocolateyApp`](https://smitpi.github.io/PSToolKit/#Install-ChocolateyApp) -- Install chocolatey apps from a json list.
- [`Install-ChocolateyClient`](https://smitpi.github.io/PSToolKit/#Install-ChocolateyClient) -- Downloads and installs the Chocolatey client.
- [`Install-ChocolateyServer`](https://smitpi.github.io/PSToolKit/#Install-ChocolateyServer) -- This will download, install and setup a new Chocolatey Repo Server
- [`Install-LocalPSRepository`](https://smitpi.github.io/PSToolKit/#Install-LocalPSRepository) -- Creates a repository for offline installations
- [`Install-MicrosoftTerminal`](https://smitpi.github.io/PSToolKit/#Install-MicrosoftTerminal) -- Install MicrosoftTerminal on your device.
- [`Install-MSUpdate`](https://smitpi.github.io/PSToolKit/#Install-MSUpdate) -- Perform windows update
- [`Install-MSWinget`](https://smitpi.github.io/PSToolKit/#Install-MSWinget) -- Install the package manager winget
- [`Install-NFSClient`](https://smitpi.github.io/PSToolKit/#Install-NFSClient) -- Install NFS Client for windows
- [`Install-PowerShell7x`](https://smitpi.github.io/PSToolKit/#Install-PowerShell7x) -- Install ps7
- [`Install-PSModule`](https://smitpi.github.io/PSToolKit/#Install-PSModule) -- Install modules from .json file.
- [`Install-RSAT`](https://smitpi.github.io/PSToolKit/#Install-RSAT) -- Install Remote Admin Tools
- [`Install-VMWareTool`](https://smitpi.github.io/PSToolKit/#Install-VMWareTool) -- Install vmware tools from chocolatety
- [`New-CitrixSiteConfigFile`](https://smitpi.github.io/PSToolKit/#New-CitrixSiteConfigFile) -- A config file with Citrix server details and URLs. To be used in scripts.
- [`New-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/#New-ElevatedShortcut) -- Creates a shortcut to a script or exe that runs as admin, without UNC
- [`New-GodModeFolder`](https://smitpi.github.io/PSToolKit/#New-GodModeFolder) -- Creates a God Mode Folder
- [`New-GoogleSearch`](https://smitpi.github.io/PSToolKit/#New-GoogleSearch) -- Start a new browser tab with search string.
- [`New-PSModule`](https://smitpi.github.io/PSToolKit/#New-PSModule) -- Creates a new PowerShell module.
- [`New-PSProfile`](https://smitpi.github.io/PSToolKit/#New-PSProfile) -- Creates new profile files in the documents folder
- [`New-PSScript`](https://smitpi.github.io/PSToolKit/#New-PSScript) -- Creates a new PowerShell script. With PowerShell Script Info
- [`New-RemoteDesktopFile`](https://smitpi.github.io/PSToolKit/#New-RemoteDesktopFile) -- Creates and saves a .rdp file
- [`New-SuggestedInfraName`](https://smitpi.github.io/PSToolKit/#New-SuggestedInfraName) -- Generates a list of usernames and server names, that can be used as test / demo data.
- [`Remove-CIMUserProfile`](https://smitpi.github.io/PSToolKit/#Remove-CIMUserProfile) -- Uses CimInstance to remove a user profile
- [`Remove-FaultyProfileList`](https://smitpi.github.io/PSToolKit/#Remove-FaultyProfileList) -- Fixes Profilelist in the registry. To fix user logon with temp profile.
- [`Remove-HiddenDevice`](https://smitpi.github.io/PSToolKit/#Remove-HiddenDevice) -- Removes ghost devices from your system
- [`Remove-UserProfile`](https://smitpi.github.io/PSToolKit/#Remove-UserProfile) -- Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry
- [`Reset-PSGallery`](https://smitpi.github.io/PSToolKit/#Reset-PSGallery) -- Reset gallery to degault settings
- [`Restore-ElevatedShortcut`](https://smitpi.github.io/PSToolKit/#Restore-ElevatedShortcut) -- Restore the RunAss shortcuts, from a zip file
- [`Search-Script`](https://smitpi.github.io/PSToolKit/#Search-Script) -- Search for a string in a directory of ps1 scripts.
- [`Set-FolderCustomIcon`](https://smitpi.github.io/PSToolKit/#Set-FolderCustomIcon) -- Will change the icon of a folder to a custom selected icon
- [`Set-PSProjectFile`](https://smitpi.github.io/PSToolKit/#Set-PSProjectFile) -- Creates and modify needed files for a PS project from existing module files.
- [`Set-PSToolKitSystemSetting`](https://smitpi.github.io/PSToolKit/#Set-PSToolKitSystemSetting) -- Set multiple settings on desktop or server
- [`Set-SharedPSProfile`](https://smitpi.github.io/PSToolKit/#Set-SharedPSProfile) -- Redirects PowerShell and WindowsPowerShell profile folder to another path.
- [`Set-StaticIP`](https://smitpi.github.io/PSToolKit/#Set-StaticIP) -- Set static IP on device
- [`Set-TempFolder`](https://smitpi.github.io/PSToolKit/#Set-TempFolder) -- Set all the temp environmental variables to c:\temp
- [`Set-WindowsAutoLogin`](https://smitpi.github.io/PSToolKit/#Set-WindowsAutoLogin) -- Enable autologin on a device.
- [`Show-ComputerManagement`](https://smitpi.github.io/PSToolKit/#Show-ComputerManagement) -- Opens the Computer Management of the system or remote system
- [`Show-PSToolKit`](https://smitpi.github.io/PSToolKit/#Show-PSToolKit) -- Show details of the commands in this module
- [`Start-PSModuleMaintenance`](https://smitpi.github.io/PSToolKit/#Start-PSModuleMaintenance) -- Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.
- [`Start-PSProfile`](https://smitpi.github.io/PSToolKit/#Start-PSProfile) -- My PS Profile for all sessions.
- [`Start-PSRoboCopy`](https://smitpi.github.io/PSToolKit/#Start-PSRoboCopy) -- My wrapper for default robocopy switches
- [`Start-PSScriptAnalyzer`](https://smitpi.github.io/PSToolKit/#Start-PSScriptAnalyzer) -- Run and report ScriptAnalyzer output
- [`Start-PSToolkitSystemInitialize`](https://smitpi.github.io/PSToolKit/#Start-PSToolkitSystemInitialize) -- Initialize a blank machine.
- [`Test-CitrixCloudConnector`](https://smitpi.github.io/PSToolKit/#Test-CitrixCloudConnector) -- Perform basic connection tests to CItrix cloud.
- [`Test-CitrixVDAPort`](https://smitpi.github.io/PSToolKit/#Test-CitrixVDAPort) -- Test connection between ddc and vda
- [`Test-IsFileOpen`](https://smitpi.github.io/PSToolKit/#Test-IsFileOpen) -- Checks if a file is open
- [`Test-PendingReboot`](https://smitpi.github.io/PSToolKit/#Test-PendingReboot) -- This script tests various registry values to see if the local computer is pending a reboot.
- [`Test-PSRemote`](https://smitpi.github.io/PSToolKit/#Test-PSRemote) -- Test PSb Remote to a device.
- [`Update-ListOfDDC`](https://smitpi.github.io/PSToolKit/#Update-ListOfDDC) -- Update list of ListOfDDCs in the registry
- [`Update-LocalHelp`](https://smitpi.github.io/PSToolKit/#Update-LocalHelp) -- Downloads and saves help files locally
- [`Update-PSModuleInfo`](https://smitpi.github.io/PSToolKit/#Update-PSModuleInfo) -- Update PowerShell module manifest file
- [`Update-PSToolKit`](https://smitpi.github.io/PSToolKit/#Update-PSToolKit) -- Update PSToolKit from GitHub.
- [`Update-PSToolKitConfigFile`](https://smitpi.github.io/PSToolKit/#Update-PSToolKitConfigFile) -- Manages the config files for the PSToolKit Module.
- [`Write-Ascii`](https://smitpi.github.io/PSToolKit/#Write-Ascii) -- Create Ascii Art
- [`Write-PSToolKitLog`](https://smitpi.github.io/PSToolKit/#Write-PSToolKitLog) -- Create a log for scripts
- [`Write-PSToolKitMessage`](https://smitpi.github.io/PSToolKit/#Write-PSToolKitMessage) -- Writes the given into to screen
