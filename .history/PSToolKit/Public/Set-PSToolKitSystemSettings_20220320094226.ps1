
<#PSScriptInfo

.VERSION 0.1.0

.GUID 149dd87d-ffd6-4d43-9b6e-4f8694e4d717

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [20/01/2022_07:42] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Set multiple settings on desktop or server

#>

<#
.SYNOPSIS
Set multiple settings on desktop or server

.DESCRIPTION
Set multiple settings on desktop or server

.PARAMETER RunAll
Enable all the options in this function.

.PARAMETER ExecutionPolicy
Set ps execution policy to unrestricted.

.PARAMETER PSGallery
Enable and set PS gallery to defaults

.PARAMETER ForcePSGallery
Force the reinstall of ps gallery

.PARAMETER IntranetZone
Setup intranet zones for mapped drives.

.PARAMETER IntranetZoneIPRange
Setup intranet zones for mapped drives from IP addresses.

.PARAMETER PSTrustedHosts
Set trusted hosts to domain servers.

.PARAMETER SystemDefaults
Set some system settings.

.PARAMETER DisableIEFirstRun
Disable IE first run

.PARAMETER DisableFirstLogonAnimation
Disable Hi Message

.PARAMETER SetPhotoViewer
Set photo viewer

.PARAMETER DisableShutdownTracker
Disable shutdown tracker

.PARAMETER FileExplorerSettings
Change explorer settings to what I like.

.PARAMETER DisableIPV6
Disable ipv6 on all network cards.

.PARAMETER DisableFirewall
Disable windows firewall on all network profiles.

.PARAMETER DisableInternetExplorerESC
Disable IE Extra security.

.PARAMETER DisableServerManager
Closes and set server manager not to open on start.

.PARAMETER EnableRDP
Enable RDP to this device.

.PARAMETER InstallPS7
Install PowerShell 7 with defaults.

.PARAMETER InstallMSTerminal
Install MS Terminal.

.PARAMETER InstallVMWareTools
Install VMware tools if device is a VM.

.PARAMETER InstallRSAT
Install MS Remote Admin Tools.

.PARAMETER InstallMSUpdates
Perform a Windows Update

.PARAMETER InstallSSHServer
Install openssh server and client.

.PARAMETER EnableNFSClient
Install NFS Client.

.PARAMETER PerformReboot
Reboot after all the setting changes.

.EXAMPLE
Set-PSToolKitSystemSettings -RunAll

#>
Function Set-PSToolKitSystemSettings {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSToolKitSystemSettings')]
    PARAM(
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$RunAll = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$ExecutionPolicy = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$PSGallery = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$ForcePSGallery = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$IntranetZone = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$IntranetZoneIPRange = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$PSTrustedHosts = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$FileExplorerSettings = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$SystemDefaults = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableIEFirstRun = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableFirstLogonAnimation = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$SetPhotoViewer = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableShutdownTracker = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableIPV6 = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableFirewall = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableInternetExplorerESC = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableServerManager = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$EnableRDP = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$InstallPS7 = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$InstallMSTerminal = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$InstallVMWareTools = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$InstallRSAT = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$InstallMSUpdates = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$EnableNFSClient = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$PerformReboot = $false
    )

    if ($RunAll) {
        ExecutionPolicy = $True
        PSGallery = $True
        IntranetZone = $True
        IntranetZoneIPRange = $True
        PSTrustedHosts = $True
        FileExplorerSettings = $True
        SystemDefaults = $True
        DisableIEFirstRun = $True
        DisableFirstLogonAnimation = $True
        SetPhotoViewer = $True
        DisableShutdownTracker = $True
        DisableIPV6 = $True
        DisableFirewall = $True
        DisableInternetExplorerESC = $True
        DisableServerManager = $True
        EnableRDP = $True
        InstallPS7 = $True
        InstallMSTerminal = $True
        InstallVMWareTools = $True
        InstallRSAT = $True
        EnableNFSClient = $True
    }

    if ($ExecutionPolicy) {
        try {
            if ((Get-ExecutionPolicy) -notlike 'Unrestricted') {
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope LocalMachine
                Write-Color '[Set]', 'ExecutionPolicy: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Set]', 'ExecutionPolicy: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Set]ExecutionPolicy: Failed:`n $($_.Exception.Message)" }

    }

    if ($PSGallery) {
        if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
            try {
                $wc = New-Object System.Net.WebClient
                $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

                Install-PackageProvider Nuget -Force | Out-Null
                Register-PSRepository -Default | Out-Null
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

                $BaseModules = @('PowerShellGet', 'PackageManagement')
                foreach ($base in $BaseModules) {
                    Install-Module -Name $base -Force -AllowClobber -Scope AllUsers
                    Import-Module $base -Force
                    Get-Module $base | Update-Module -Force -PassThru
                    Import-Module $base -Force
                }

                Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
            } catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
        } else {Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
    }

    if ($ForcePSGallery) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            Install-PackageProvider Nuget -Force | Out-Null
            Register-PSRepository -Default | Out-Null
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

            $BaseModules = @('PowerShellGet', 'PackageManagement')
            foreach ($base in $BaseModules) {
                Install-Module -Name $base -Force -AllowClobber -Scope AllUsers
                Import-Module $base -Force
                Get-Module $base | Update-Module -Force -PassThru
                Import-Module $base -Force
            }

            Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
            else { Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, Magenta }
        } catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
    }

    if ($IntranetZone) {
        $domainCheck = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()

        $LocalIntranetSite = $domainCheck.Name

        $parent = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
        $key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains'
        $CompRegPath = Join-Path $key -ChildPath $LocalIntranetSite
        $DWord = 1

        try {
            Write-Verbose "Creating a new key '$LocalIntranetSite' under $UserRegPath."

            if ((Test-Path -Path $CompRegPath) -eq $false ) {
                if ((Test-Path -Path $key) -eq $false ) { New-Item -Path $parent -ItemType File -Name 'Domains' | Out-Null }
                New-Item -Path $key -ItemType File -Name "$LocalIntranetSite" | Out-Null
                Set-ItemProperty -Path $CompRegPath -Name 'file' -Value $DWord | Out-Null
                Write-Color '[Set]', "IntranetZone $($LocalIntranetSite): ", 'Complete' -Color Yellow, Cyan, Green
            } else { Write-Color '[Set]', "IntranetZone $($LocalIntranetSite): ", 'Already Set' -Color Yellow, Cyan, DarkRed }

        } Catch { Write-Warning "[Set]IntranetZone: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($IntranetZoneIPRange) {
        $IPAddresses = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127*'}
        $index = 1
        foreach ($ip in $IPAddresses) {
            $ipdata = $ip.IPAddress.Split('.')
            $parent = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
            $key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges'
            $keychild = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range$($index)"
            $DWord = 1

            try {
                if (-not(Test-Path -Path $Key)) {
                    New-Item -Path $parent -ItemType File -Name 'Ranges' | Out-Null
                }
                if (-not(Test-Path -Path $keychild)) {
                    New-Item -Path $key -ItemType File -Name "Range$($index)" | Out-Null
                    Set-ItemProperty -Path $keychild -Name 'file' -Value $DWord | Out-Null
                    Set-ItemProperty -Path $keychild -Name ':Range' -Value "$($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*" | Out-Null
                    Write-Color '[Set]', "IntranetZone IP Range: $($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*: ", 'Complete' -Color Yellow, Cyan, Green
                } else {
                    Write-Color '[Set]', "IntranetZone IP Range: $($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*: ", 'Already Set' -Color Yellow, Cyan, DarkRed
                    ++$index
                }
            } Catch { Write-Warning "[Set]IntranetZone Ip Range: Failed:`n $($_.Exception.Message)" }
        }

    } #end if

    if ($DisableIPV6) {
        try {
            if ((Get-NetAdapterBinding -ComponentID ms_tcpip6).enabled -contains 'True') {
                Get-NetAdapterBinding -ComponentID ms_tcpip6 | Where-Object { $_.enabled -eq 'True' } | ForEach-Object { Disable-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 }
                Write-Color '[Disable]', 'IPv6: ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Disable]', 'IPv6: ', 'Already Set' -Color Yellow, Cyan, DarkRed
            }

        } Catch { Write-Warning "[Disable]IPv6: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($DisableFirewall) {
        try {
            if ((Get-NetFirewallProfile -Profile Domain, Public, Private).enabled -contains 'True') {
                Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
                Write-Color '[Disable]', 'Firewall: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Disable]', 'Firewall: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } Catch { Write-Warning "[Disable]Firewall: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($EnableRDP) {
        try {
            if ((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections -notlike 0) {
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
                Write-Color '[Enable]', 'RDP: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Enable]', 'RDP: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } Catch { Write-Warning "[Enable]RDP: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($DisableInternetExplorerESC) {
        try {
            $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
            if ($checkver -like '*server*') {
                $AdminKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
                $UserKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
                if ((Get-ItemProperty -Path $AdminKey).isinstalled -notlike 0) {
                    Set-ItemProperty -Path $AdminKey -Name 'IsInstalled' -Value 0 -Force
                    Set-ItemProperty -Path $UserKey -Name 'IsInstalled' -Value 0 -Force
                    Rundll32 iesetup.dll, IEHardenLMSettings
                    Rundll32 iesetup.dll, IEHardenUser
                    Rundll32 iesetup.dll, IEHardenAdmin
                    Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'Complete' -Color Yellow, Cyan, Green
                } else {Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'Already Set' -Color Yellow, Cyan, DarkRed}
            } else { Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'No Server OS Detected' -Color Yellow, Cyan, DarkRed }
        } catch { Write-Warning '[Disable]', "IE Enhanced Security Configuration (ESC): failed:`n $($_.Exception.Message)" }

    }

    if ($DisableServerManager) {
        try {
            $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
            if ($checkver -like '*server*') {
                if (Get-Process 'servermanager' -ErrorAction SilentlyContinue) { Stop-Process -Name servermanager -Force }
                if ((Get-ItemProperty HKCU:\Software\Microsoft\ServerManager).DoNotOpenServerManagerAtLogon -notlike 1) {
                    New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value '0x1' -Force
                    Write-Color '[Disable]', 'ServerManager: ', 'Complete' -Color Yellow, Cyan, Green
                } else {
                    Write-Color '[Disable]', 'ServerManager: ', 'Already Set' -Color Yellow, Cyan, DarkRed
                }
            } else { Write-Color '[Disable]', 'ServerManager: ', 'No Server OS Detected' -Color Yellow, Cyan, DarkRed }
        } catch { Write-Warning "[Disable]ServerManager: Failed:`n $($_.Exception.Message)" }

    }

    if ($PSTrustedHosts) {
        try {
            Enable-PSRemoting -Force | Out-Null
            $domainCheck = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
            $currentlist = @()
            [array]$currentlist += (Get-Item WSMan:\localhost\Client\TrustedHosts).value.split(',')
            if (-not($currentlist -contains "*.$domainCheck")) {
                if ($false -eq [bool]$currentlist) {
                    $DomainList = "*.$domainCheck"
                    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$DomainList" -Force
                    Write-Color '[Set]', 'TrustedHosts: ', 'Complete' -Color Yellow, Cyan, Green

                } else {
                    $currentlist += "*.$domainCheck"
                    $newlist = Join-String -Strings $currentlist -Separator ','
                    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$newlist" -Force
                    Write-Color '[Set]', 'TrustedHosts: ', 'Complete' -Color Yellow, Cyan, Green

                }
            } else {Write-Color '[Set]', 'TrustedHosts: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Set]TrustedHosts: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($FileExplorerSettings) {
        try {
            Write-Color '[Set]', 'File Explorer Settings:' -Color Yellow, Cyan

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowStatusBar -Value 1
            Write-Color '[Set]', 'ShowStatusBar: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMenuAdminTools -Value 1
            Write-Color '[Set]', 'StartMenuAdminTools: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name FolderContentsInfoTip -Value 1
            Write-Color '[Set]', 'FolderContentsInfoTip: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 0
            Write-Color '[Set]', 'ShowSecondsInSystemClock: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SnapAssist -Value 1
            Write-Color '[Set]', 'SnapAssist: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Type DWord -Value 0
            Write-Color '[Set]', 'HideFileExt: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowHiddenFiles : ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideMergeConflicts' -Type DWord -Value 0
            Write-Color '[Set]', 'ShowFolderMergeConflicts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowEncryptCompressedColor' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowEncCompFilesColor: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'AutoCheckSelect' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowSelectCheckboxes: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowRecent' -Type DWord -Value 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowFrequent' -Type DWord -Value 0
            Write-Color '[Set]', 'HideRecentShortcuts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type DWord -Value 1
            Write-Color '[Set]', 'SetExplorerThisPC: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'IconsOnly' -Type DWord -Value 0
            Write-Color '[Set]', 'EnableThumbnails: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisableThumbnailCache' -ErrorAction SilentlyContinue
            Write-Color '[Set]', 'EnableThumbnailCache: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisableThumbsDBOnNetworkFolders' -ErrorAction SilentlyContinue
            Write-Color '[Set]', 'EnableThumbsDBOnNetwork: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
            <#
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ServerAdminUI -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCompColor -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DontPrettyPath -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowInfoTip -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideIcons -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MapNetDrvBtn -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name WebView -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Filter -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SeparateProcess -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name AutoCheckSelect -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name IconsOnly -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTypeOverlay -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowStatusBar -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StoreAppsOnTaskbar -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ListviewAlphaSelect -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ListviewShadow -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarAnimations -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMigratedBrowserPin -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ReindexedProfile -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMenuAdminTools -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name UseCompactMode -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartShownOnUpgrade -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarSizeMove -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DisablePreviewDesktop -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name FolderContentsInfoTip -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowEncryptCompressedColor -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SnapAssist -Value 1
            Write-Color '[Set]', 'File Explorer Settings: ', 'Complete' -Color Yellow, Cyan, Green
#>
        } catch { Write-Warning "[Set]File Explorer Settings: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($DisableIEFirstRun) {
        If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main')) {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Type DWord -Value 1
        Write-Color '[Set]', 'DisableIEFirstRun: ', 'Complete' -Color Yellow, Cyan, Green

    }

    if ($DisableFirstLogonAnimation) {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableFirstLogonAnimation' -Type DWord -Value 0
        Write-Color '[Set]', 'DisableFirstLogonAnimation: ', 'Complete' -Color Yellow, Cyan, Green

    }

    if ($SetPhotoViewer) {
        If (!(Test-Path 'HKCR:')) {
            New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' | Out-Null
        }
        ForEach ($type in @('Paint.Picture', 'giffile', 'jpegfile', 'pngfile')) {
            New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
            New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
            Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name 'MuiVerb' -Type ExpandString -Value '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'
            Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name '(Default)' -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
        }
        Write-Color '[Set]', 'SetPhotoViewerAssociation: ', 'Complete' -Color Yellow, Cyan, Green

        If (!(Test-Path 'HKCR:')) {
            New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' | Out-Null
        }
        New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command' -Force | Out-Null
        New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget' -Force | Out-Null
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open' -Name 'MuiVerb' -Type String -Value '@photoviewer.dll,-3043'
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command' -Name '(Default)' -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget' -Name 'Clsid' -Type String -Value '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'
        Write-Color '[Set]', 'AddPhotoViewerOpenWith: ', 'Complete' -Color Yellow, Cyan, Green

    }

    if ($DisableShutdownTracker) {
        If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability')) {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name 'ShutdownReasonOn' -Type DWord -Value 0
        Write-Color '[Set]', 'DisableShutdownTracker: ', 'Complete' -Color Yellow, Cyan, Green

    }

    if ($SystemDefaults) {
        Write-Color '[Set]', 'System Defaults: ', 'Complete' -Color Yellow, Cyan, Green

        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' -Name 'PreventDeviceMetadataFromNetwork' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching' -Name 'SearchOrderConfig' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'EnableUpdateDriver: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

	(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '') | Out-Null
        Write-Color '[Set]', 'EnableUpdateMSProducts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        If (!(Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy')) {
            New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '01' -Type DWord -Value 1
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name 'StoragePoliciesNotified' -Type DWord -Value 1
        Write-Color '[Set]', 'EnableStorageSense: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-Service 'WSearch' -StartupType Automatic
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch' -Name 'DelayedAutoStart' -Type DWord -Value 1
        Start-Service 'WSearch' -WarningAction SilentlyContinue
        Write-Color '[Set]', 'EnableIndexing: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Type DWord -Value 1
        Write-Color '[Set]', 'EnableNTFSLongPaths: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 1
        Write-Color '[Set]', 'ShowTaskbarSearchIcon: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoStartMenuMFUprogramsList' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'ShowMostUsedApps: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        If ([System.Environment]::OSVersion.Version.Build -le 14393) {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DontUsePowerShellOnWinX' -Type DWord -Value 0
        } Else {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DontUsePowerShellOnWinX' -ErrorAction SilentlyContinue
        }
        Write-Color '[Set]', 'SetWinXMenuPowerShell: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'StartupPage' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'AllItemsIconView' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'SetControlPanelCategories: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
        If (!(Test-Path 'HKU:')) {
            New-PSDrive -Name 'HKU' -PSProvider 'Registry' -Root 'HKEY_USERS' | Out-Null
        }
        Set-ItemProperty -Path 'HKU:\.DEFAULT\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -Type DWord -Value 2147483650
        Add-Type -AssemblyName System.Windows.Forms
        If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{NUMLOCK}')
        }
        Write-Color '[Set]', 'EnableNumlock: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
        if ($checkver -notlike '*server*') {
            Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE"
            vssadmin Resize ShadowStorage /On=$env:SYSTEMDRIVE /For=$env:SYSTEMDRIVE /MaxSize=10GB | Out-Null
            Write-Color '[Set]', 'EnableRestorePoints: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
        }
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Type String -Value '1'
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Type String -Value '6'
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Type String -Value '10'
        Write-Color '[Set]', 'EnableEnhPointerPrecision: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
    }

    if ($InstallVMWareTools) {
        try {
            if ((Get-CimInstance -ClassName win32_bios).Manufacturer -like '*VMware*') {
                if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
                Write-Color '[Installing] ', 'VMWare Tools', ' from source ', 'chocolatey' -Color Yellow, Cyan, green, Cyan
                choco upgrade vmware-tools --accept-license --limit-output -y --source chocolatey | Out-Null
                if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing vmware-tools Code: $($LASTEXITCODE)"}
            } else {Write-Color '[Installing]', 'VMWare Tools:', ' Not a VMWare VM' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Installing] VMWare Tools: Failed:`n $($_.Exception.Message)" }

    }

    if ($InstallRSAT) {
        try {
            $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
            if ($checkver -notlike '*server*') {
                Write-Color '[Installing] ', 'RSAT Tools', ' for a ', 'Workstation OS' -Color Yellow, Cyan, green, Cyan
                $Roles = @('Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0', 'Rsat.DHCP.Tools~~~~0.0.1.0', 'Rsat.Dns.Tools~~~~0.0.1.0', 'Rsat.FileServices.Tools~~~~0.0.1.0', 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0', 'Rsat.ServerManager.Tools~~~~0.0.1.0', 'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0')
                $Roles | ForEach-Object {
                    if (-not(Get-WindowsCapability -Name $_ -Online)) {
                        Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.split('~')[0].split('.')[1])-$($_.split('~')[0].split('.')[2])" -Color Yellow, Cyan, green, Cyan -StartTab 1
                        Add-WindowsCapability -Name $_ -Online | Out-Null
                    } else {
                        Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.split('~')[0].split('.')[1])-$($_.split('~')[0].split('.')[2])", ' Already Installed' -Color Yellow, Cyan, green, DarkRed -StartTab 1
                    }
                }
            } else {
                Write-Color '[Installing] ', 'RSAT Tools', ' for a ', 'Server OS' -Color Yellow, Cyan, green, Cyan
                $roles = @('RSAT-Role-Tools', 'RSAT-AD-Tools', 'RSAT-AD-PowerShell', 'RSAT-ADDS', 'RSAT-AD-AdminCenter', 'RSAT-ADDS-Tools', 'RSAT-ADLDS', 'RSAT-Hyper-V-Tools', 'RSAT-DHCP', 'RSAT-DNS-Server', 'RSAT-File-Services')
                $roles | ForEach-Object {
                    if ((Get-WindowsFeature -Name $_).InstallState -notlike 'Installed') {
                        Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.Split('-')[1])($($_.Split('-')[2]))" -Color Yellow, Cyan, green, Cyan -StartTab 1
                        Install-WindowsFeature -Name $_ -IncludeAllSubFeature | Out-Null
                    } else {
                        Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.Split('-')[1])($($_.Split('-')[2]))", ' Already Installed' -Color Yellow, Cyan, green, DarkRed -StartTab 1
                    }
                }
            }
        } catch { Write-Warning "[Installing] RSAT Tools: Failed:`n $($_.Exception.Message)" }

    }

    if ($EnableNFSClient) {
        try {
            if ((Get-WindowsOptionalFeature -Online -FeatureName *nfs*).state -contains 'Disabled') {
                $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
                if ($checkver -like '*server*') {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ServerAndClient' -All | Out-Null
                } else {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ClientOnly' -All | Out-Null
                }
                Enable-WindowsOptionalFeature -Online -FeatureName 'ClientForNFS-Infrastructure' -All | Out-Null
                Enable-WindowsOptionalFeature -Online -FeatureName 'NFS-Administration' -All | Out-Null
                nfsadmin client stop | Out-Null
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousUID' -Type DWord -Value 0 | Out-Null
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousGID' -Type DWord -Value 0 | Out-Null
                nfsadmin client start | Out-Null
                nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i | Out-Null
                Write-Color '[Installing] ', 'NFS Client: ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Installing] ', 'NFS Client: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
            }
        } catch { Write-Warning "[Installing] NFS Client: Failed:`n $($_.Exception.Message)" }
    } #end

    if ($InstallPS7) {
        try {
            if ((Test-Path 'C:\Program Files\PowerShell\7') -eq $false) {
                $ReleaseModule = Get-Module PSReleaseTools
                if ($null -like $ReleaseModule) {$ReleaseModule = Get-Module PSReleaseTools -ListAvailable}
                if ($null -like $ReleaseModule) {
                    Write-Color '[Installing] ', 'Required Modules: ', 'PSReleaseTools' -Color Yellow, green, Cyan
                    Install-Module -Name PSReleaseTools -Scope CurrentUser -AllowClobber -Force
                }
                Import-Module PSReleaseTools -Force
                Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
                Write-Color '[Installing] ', 'PowerShell 7.x ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Installing] ', 'PowerShell 7.x: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
            }
        } catch { Write-Warning "[Installing] PowerShell 7.x: Failed:`n $($_.Exception.Message)" }
    }

    if ($InstallMSTerminal) {
        try {
            if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
            'microsoft-windows-terminal', 'cascadia-code-nerd-font', 'cascadiacodepl' | ForEach-Object {
                $ChocoApp = choco search $_ --exact --local-only --limit-output
                $ChocoAppOnline = choco search $_ --exact --limit-output
                if ($null -eq $ChocoApp) {
                    Write-Color '[Installing] ', $($_), ' from source ', 'chocolatey' -Color Yellow, Cyan, Green, Cyan
                    choco upgrade $($_) --accept-license --limit-output -y | Out-Null
                    if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
                } else {
                    Write-Color '[Installing] ', $($ChocoApp.split('|')[0]), " (Version: $($ChocoApp.split('|')[1]))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
                    if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
                        Write-Color '[Updating] ', $($_), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', 'chocolatey' -Color Yellow, Cyan, Yellow, Green, Cyan
                        choco upgrade $($_) --accept-license --limit-output -y | Out-Null
                        if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
                    }
                }
            }
            $settingsFile = ([IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', '*Terminal*', 'LocalState', 'Settings.json'))

            if (Test-Path $settingsFile) {
                $SetFile = Get-Item $settingsFile
                Rename-Item -Path $SetFile.FullName -NewName "Settings-$(Get-Date -Format yyyy.MM.dd_HHMM).json" -Force | Out-Null
            } else {
                New-Item -Path ([IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', '*Terminal*', 'LocalState')) -Name 'Settings.json' -ItemType File | Out-Null
                $SetFile = Get-Item $settingsFile
            }
            Invoke-WebRequest -Uri 'https://git.io/JMTRv' -OutFile $SetFile.FullName
            Write-Color '[Installing]', ' Microsoft Terminal Settings: ', 'Complete' -Color Yellow, Cyan, Green
        } catch { Write-Warning "[Installing] Microsoft Terminal: Failed:`n $($_.Exception.Message)" }
    }

    if ($InstallMSUpdates) {
        try {
            $UpdateModule = Get-Module PSWindowsUpdate
            if ($null -like $UpdateModule) {$UpdateModule = Get-Module PSWindowsUpdate -ListAvailable}
            if ($null -like $UpdateModule) {
                Write-Color '[Installing] ', 'Required Modules: ', 'PSWindowsUpdate' -Color Yellow, green, Cyan
                Install-Module -Name PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
            }
            Import-Module PSWindowsUpdate -Force
            Write-Color '[Installing] ', 'Windows Updates:', ' Software' -Color Yellow, Cyan, Green
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Software
            Write-Color '[Installing] ', 'Windows Updates:', ' Drivers' -Color Yellow, Cyan, Green
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Driver
        } catch { Write-Warning "[Installing] Windows Updates: Failed:`n $($_.Exception.Message)" }
    }

    if ($PerformReboot) {
        try {
            Write-Color '[Checking] ', 'Pending Reboot' -Color Yellow, Cyan
            $checkreboot = Test-PendingReboot -ComputerName $env:computername
            if ($checkreboot.IsPendingReboot -like 'True') {
                Write-Color '[Checking] ', 'Reboot Required', ' (Reboot in 15 sec)' -Color Yellow, DarkRed, Cyan
                Start-Sleep -Seconds 15
                Restart-Computer -Force
            } else {
                Write-Color '[Checking] ', 'Reboot Not Required' -Color Yellow, Cyan
            }
        } catch { Write-Warning "[Checking] Required Reboot: Failed:`n $($_.Exception.Message)" }
    }

} #end Function
