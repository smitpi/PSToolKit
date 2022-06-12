#
# Module manifest for module 'PSToolKit'
#
# Generated by: Pierre Smit
#
# Generated on: 2022-06-12 10:26:15Z
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSToolKit.psm1'

# Version number of this module.
ModuleVersion = '0.1.13'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '7b851f82-8c0e-40be-8faa-fc062c1bdb0d'

# Author of this module
Author = 'Pierre Smit'

# Company or vendor of this module
CompanyName = 'HTPCZA Tech'

# Copyright statement for this module
Copyright = '(c) 2022 Pierre Smit. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A Repository of my random scripts and functions writen over the years, there is a wyde range of tools in this module, used by a SysAdmin and EUC Administrator.'

# Minimum version of the PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('ImportExcel', 
               'PSWriteHTML', 
               'PSWriteColor', 
               'PSScriptTools', 
               'PoshRegistry')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-ChocolateyPrivateRepo', 'Backup-ElevatedShortcut', 
               'Backup-PowerShellProfile', 'Compare-ADMembership', 
               'Connect-VMWareCluster', 'Edit-ChocolateyAppsList', 'Edit-HostsFile', 
               'Edit-PSModulesList', 'Edit-SSHConfigFile', 
               'Enable-RemoteHostPSRemoting', 'Export-ESXTemplate', 
               'Find-ChocolateyApp', 'Find-OnlineModule', 'Find-OnlineScript', 
               'Format-AllObjectsInAListView', 'Get-AllUsersInGroup', 
               'Get-CitrixClientVersion', 'Get-CitrixPolicies', 
               'Get-CommandFiltered', 'Get-DeviceUptime', 'Get-FolderSize', 'Get-FQDN', 
               'Get-FullADUserDetail', 'Get-MyPSGalleryStat', 
               'Get-ProcessPerformance', 'Get-PropertiesToCSV', 'Get-SoftwareAudit', 
               'Get-SystemInfo', 'Get-WinEventLogExtract', 
               'Import-CitrixSiteConfigFile', 'Import-XamlConfigFile', 
               'Install-BGInfo', 'Install-ChocolateyApp', 'Install-ChocolateyClient', 
               'Install-ChocolateyServer', 'Install-LocalPSRepository', 
               'Install-MicrosoftTerminal', 'Install-MSUpdate', 'Install-MSWinget', 
               'Install-NFSClient', 'Install-PowerShell7x', 'Install-PSModule', 
               'Install-RSAT', 'Install-VMWareTool', 'New-CitrixSiteConfigFile', 
               'New-ElevatedShortcut', 'New-GodModeFolder', 'New-GoogleSearch', 
               'New-PSModule', 'New-PSProfile', 'New-PSScript', 
               'New-RemoteDesktopFile', 'New-SuggestedInfraName', 
               'Publish-ModuleToLocalRepo', 'Remove-CIMUserProfile', 
               'Remove-FaultyProfileList', 'Remove-HiddenDevice', 
               'Remove-UserProfile', 'Reset-PSGallery', 'Restore-ElevatedShortcut', 
               'Search-Script', 'Set-FolderCustomIcon', 'Set-PSProjectFile', 
               'Set-PSToolKitSystemSetting', 'Set-SharedPSProfile', 'Set-StaticIP', 
               'Set-TempFolder', 'Set-WindowsAutoLogin', 'Show-ComputerManagement', 
               'Show-PSToolKit', 'Start-PSModuleMaintenance', 'Start-PSProfile', 
               'Start-PSRoboCopy', 'Start-PSScriptAnalyzer', 
               'Start-PSToolkitSystemInitialize', 'Test-CitrixCloudConnector', 
               'Test-CitrixVDAPort', 'Test-IsFileOpen', 'Test-PendingReboot', 
               'Test-PSRemote', 'Update-ListOfDDC', 'Update-LocalHelp', 
               'Update-PSModuleInfo', 'Update-PSToolKit', 
               'Update-PSToolKitConfigFile', 'Write-Ascii', 'Write-PSToolKitLog', 
               'Write-PSToolKitMessage'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'ps'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/smitpi/PSToolKit'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Updated [21/05/2022_14:58] More personal scripts added'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://smitpi.github.io/PSToolKit'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

