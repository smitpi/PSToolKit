
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
Setup intranet zones for mapped drives from ip addresses.

.PARAMETER PSTrustedHosts
Set trusted hosts to domain servers.

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

.PARAMETER InstallVMWareTools
Install VMware tools if device is a VM.

.PARAMETER InstallAnsibleRemote
Configure ps remoting for ansible.

.PARAMETER EnableNFSClient
Install NFS Client.

.EXAMPLE
Set-PSToolKitSystemSettings -RunAll

#>
Function Set-PSToolKitSystemSettings {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSToolKitSystemSettings')]
    PARAM(
        [switch]$RunAll,
        [switch]$ExecutionPolicy,
        [switch]$PSGallery,
        [switch]$ForcePSGallery,
        [switch]$IntranetZone,
        [switch]$IntranetZoneIPRange,
        [switch]$PSTrustedHosts,
        [switch]$FileExplorerSettings,
        [switch]$DisableIPV6,
        [switch]$DisableFirewall,
        [switch]$DisableInternetExplorerESC,
        [switch]$DisableServerManager,
        [switch]$EnableRDP,
        [switch]$InstallVMWareTools,
        [switch]$InstallAnsibleRemote,
        [switch]$EnableNFSClient
    )

    if ($RunAll) {
        $ExecutionPolicy = $PSGallery = $IntranetZone = $IntranetZoneIPRange = $PSTrustedHosts = $FileExplorerSettings = $DisableIPV6 = $DisableFirewall = $DisableInternetExplorerESC = $DisableServerManager = $EnableRDP = $InstallVMWareTools = $InstallAnsibleRemote = $EnableNFSClient = $true
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
                if ((Test-Path -Path $key) -eq $false ) { New-Item -Path $parent -ItemType File -Name 'Domains' }
                New-Item -Path $key -ItemType File -Name "$LocalIntranetSite"
                Set-ItemProperty -Path $CompRegPath -Name 'file' -Value $DWord
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
                if (-not(Test-Path -Path $Key)) { New-Item -Path $parent -ItemType File -Name 'Ranges'}
                if (-not(Test-Path -Path $keychild)) {
                    New-Item -Path $key -ItemType File -Name "Range$($index)"
                    Set-ItemProperty -Path $keychild -Name 'file' -Value $DWord
                    Set-ItemProperty -Path $keychild -Name ':Range' -Value "$($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*"
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
        } catch { Write-Warning "[Set]File Explorer Settings: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($InstallVMWareTools) {
        try {
            if ((Get-CimInstance -ClassName win32_bios).Manufacturer -like '*VMware*') {
                Install-ChocolateyClient
                Write-Color 'Installing App: ', 'vmware-tools', ' from source ', 'chocolatey' -Color Cyan, Yellow, Cyan, Yellow
                choco upgrade vmware-tools --accept-license --limit-output -y --source chocolatey | Out-Null
                if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing vmware-tools Code: $($LASTEXITCODE)"}
            } else {Write-Color '[Installing]', 'VMWare Tools:', ' Not a VMWare VM' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Installing] VMWare Tools: Failed:`n $($_.Exception.Message)" }

    }

    if ($InstallAnsibleRemote) {
        try {
            $web = New-Object System.Net.WebClient
            $web.DownloadFile('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1', "$($env:TEMP)\ConfigureRemotingForAnsible.ps1")
            & "$($env:TEMP)\ConfigureRemotingForAnsible.ps1"

            Write-Color '[Installing] ', 'Ansible Remote: ', 'Complete' -Color Yellow, Cyan, Green
        } catch { Write-Warning "[Installing]Ansible Remote: Failed:`n $($_.Exception.Message)" }

    } #end

    if ($EnableNFSClient) {
        try {
            if ((Get-WindowsOptionalFeature -Online -FeatureName *nfs*).state -contains 'Disabled') {
                $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
                if ($checkver -like '*server*') {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ServerAndClient' -All
                } else {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ClientOnly' -All
                }
                Enable-WindowsOptionalFeature -Online -FeatureName 'ClientForNFS-Infrastructure' -All
                Enable-WindowsOptionalFeature -Online -FeatureName 'NFS-Administration' -All
                nfsadmin client stop
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousUID' -Type DWord -Value 0
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousGID' -Type DWord -Value 0
                nfsadmin client start
                nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
                Write-Color 'Useage:', 'mount -o anon <server>:/<path> <drive letter>' -Color Cyan, DarkCyan
                Write-Color '[Installing] ', 'NFS Client: ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Installing] ', 'NFS Client: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
            }
        } catch { Write-Warning "[Installing] NFS Client: Failed:`n $($_.Exception.Message)" }
    } #end

} #end Function
