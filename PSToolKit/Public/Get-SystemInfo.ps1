
<#PSScriptInfo

.VERSION 0.1.0

.GUID 88616549-cc11-4a72-97c9-fffa3a0176fd

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
Created [26/01/2022_11:03] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Get system details of a remote device

#>


<#
.SYNOPSIS
Get system details of a remote device

.DESCRIPTION
Get system details of a remote device

.PARAMETER ComputerName
Device to be queried.

.PARAMETER Export
Export to excel or html

.PARAMETER ReportPath
Where to save report.

.EXAMPLE
Get-SystemInfo -ComputerName Apollo

#>
Function Get-SystemInfo {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SystemInfo')]

    PARAM(
        [ValidateScript( { if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
                else { throw "Unable to connect to $($_)" } })]
        [string[]]$ComputerName,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
				)

    [System.Collections.ArrayList]$allcomp = @()
    foreach ($comp in $ComputerName) {
        #region CompInfo
        try {
            $CompinfoOS = [System.Collections.Generic.List[PSObject]]::New()
            $CompinfoBios = [System.Collections.Generic.List[PSObject]]::New()
            $CompinfoWin = [System.Collections.Generic.List[PSObject]]::New()
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Computer Info"
            $Compinfo = Invoke-Command -ComputerName $comp -ScriptBlock { Get-ComputerInfo }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'OS*' } | ForEach-Object {
                $CompinfoOS.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'Bios*' } | ForEach-Object {
                $CompinfoBios.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'Windows*' } | ForEach-Object {
                $CompinfoWin.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
        }
        catch { Write-Warning "[Collect]Computer info: Failed:`n $($_.Exception.Message)" }

        #endregion
        #region network
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Network Info"
            [System.Collections.ArrayList]$Network = @()
            Get-CimInstance -ComputerName $comp -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | ForEach-Object {
                $Network.Add([pscustomobject]@{
                        Description          = $_.Description
                        DHCPEnabled          = $_.DHCPEnabled
                        DHCPServer           = $_.DHCPServer
                        DNSDomain            = $_.DNSDomain
                        DNSHostName          = $_.DNSHostName
                        DNSServerSearchOrder = @(($_.DNSServerSearchOrder) | Out-String).Trim()
                        IPAddress            = @(($_.IPAddress) | Out-String).Trim()
                        DefaultIPGateway     = @(($_.DefaultIPGateway) | Out-String).Trim()
                        IPSubnet             = @(($_.IPSubnet) | Out-String).Trim()
                        MACAddress           = $_.MACAddress
                    }) | Out-Null
            }
        }
        catch { Write-Warning "[Collect]Network info: Failed:`n $($_.Exception.Message)" }

        #endregion
        #region events
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Events Info"
            [System.Collections.ArrayList]$AllEvents = @()
            $filter = @{
                LogName   = 'Application', 'System'
                StartTime = (Get-Date).AddHours(-24)
                Level     = '1', '2', '3'
            }
            $AllEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object TimeCreated, LogName, ID, MachineName, ProviderName, LevelDisplayName, Level, Message
        }
        catch { Write-Warning "[Collect]Computer events: Failed:`n $($_.Exception.Message)" }
        #endregion
        #region Antivirus
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Antivirus Info"
        [System.Collections.ArrayList]$Antivirus = @()
        if (Get-CimInstance -ComputerName $comp -Namespace root\securitycenter2 -ClassName antivirusproduct -ErrorAction SilentlyContinue) {
            Get-CimInstance -ComputerName $comp -Namespace root\securitycenter2 -ClassName antivirusproduct | ForEach-Object {
                $Antitmp = New-Object -TypeName psobject -Property @{
                    displayName              = $_.displayName
                    pathToSignedProductExe   = $_.pathToSignedProductExe
                    pathToSignedReportingExe = $_.pathToSignedReportingExe
                    productState             = $_.productState
                    timestamp                = $_.timestamp
                }
                $Antivirus.Add($Antitmp) | Out-Null
            }
        }
        elseif (Get-CimInstance -ComputerName $comp -Namespace root\securitycenter -ClassName antivirusproduct -ErrorAction SilentlyContinue) {
            Get-CimInstance -ComputerName $comp -Namespace root\securitycenter -ClassName antivirusproduct | ForEach-Object {
                $Antitmp = New-Object -TypeName psobject -Property @{
                    displayName              = $_.displayName
                    pathToSignedProductExe   = $_.pathToSignedProductExe
                    pathToSignedReportingExe = $_.pathToSignedReportingExe
                    productState             = $_.productState
                    timestamp                = $_.timestamp
                }
                $Antivirus.Add($Antitmp) | Out-Null
            }
        }
        else {
            $Antitmp = New-Object -TypeName psobject -Property @{
                displayName              = 'No Antivirus Found'
                pathToSignedProductExe   = 'No Antivirus Found'
                pathToSignedReportingExe = 'No Antivirus Found'
                productState             = 'No Antivirus Found'
                timestamp                = 'No Antivirus Found'

            }
            $Antivirus.Add($Antitmp) | Out-Null
        }
        #endregion
        #region Build array
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Other Info"
            $biosfiltered = @('BiosBIOSVersion', 'BiosFirmwareType', 'BiosInstallDate', 'BiosManufacturer', 'BiosName', 'BiosOtherTargetOS', 'BiosPrimaryBIOS', 'BiosReleaseDate', 'BiosSeralNumber', 'BiosSoftwareElementState', 'BiosStatus', 'BiosTargetOperatingSystem', 'BiosVersion')
            $OSFiltered = @('OsArchitecture', 'OsBuildNumber', 'OSDisplayVersion', 'OsInstallDate', 'OsLastBootUpTime', 'OsName', 'OsNumberOfLicensedUsers', 'OsNumberOfUsers', 'OsProductType', 'OsSystemDirectory', 'OsSystemDrive', 'OsType', 'OsUptime', 'OsVersion', 'OsWindowsDirectory')
            $WinFiltered = @('WindowsBuildLabEx', 'WindowsCurrentVersion', 'WindowsEditionId', 'WindowsInstallationType', 'WindowsInstallDateFromRegistry', 'WindowsProductId', 'WindowsProductName', 'WindowsRegisteredOrganization', 'WindowsRegisteredOwner', 'WindowsSystemRoot', 'WindowsVersion')
            $SysInfo = @()
            $SysInfo = [pscustomobject]@{
                DateCollected = (Get-Date -Format yyyy.MM.dd-HH.mm)
                Hostname      = (Get-FQDN -ComputerName $comp).fqdn
                OS            = $CompinfoOS | Where-Object { $_.name -in $OSFiltered }
                Bios          = $CompinfoBios | Where-Object { $_.name -in $biosfiltered }
                Windows       = $CompinfoWin | Where-Object { $_.name -in $WinFiltered }
                Software      = Get-SoftwareAudit -ComputerName $comp | Select-Object Displayname, DisplayVersion, Publisher, EstimatedSize
                Enviroment    = Get-CimInstance -Namespace root/cimv2 -ClassName win32_environment -ComputerName $comp | Select-Object Name, UserName, VariableValue, SystemVariable, Description
                hotfix        = Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName win32_quickfixengineering | Select-Object Caption, Description, HotFixID
                EventViewer   = $AllEvents
                Network       = $Network
                AntiVirus     = $Antivirus
                Services      = Invoke-Command -ComputerName $comp -ScriptBlock { Get-Service } | Sort-Object -Property StartType | Select-Object DisplayName, status, StartType
            }
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] $($comp)"
        }
        catch { Write-Warning "[Collect]Other info: Failed:`n $($_.Exception.Message)" }
        #endregion
        [void]$allcomp.Add($SysInfo)
    }

    #region excel
    if ($Export -eq 'Excel') {
        try {
            foreach ($SysInfo in $allcomp) {
                $path = Get-Item $ReportPath
                $ExcelPath = Join-Path $Path.FullName -ChildPath "$($SysInfo.Hostname)-SysInfo-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx"

                $SysInfo.OS | Export-Excel -Path $ExcelPath -WorksheetName OS -AutoSize -AutoFilter
                $SysInfo.Bios | Export-Excel -Path $ExcelPath -WorksheetName Bios -AutoSize -AutoFilter
                $SysInfo.Windows | Export-Excel -Path $ExcelPath -WorksheetName Windows -AutoSize -AutoFilter
                $SysInfo.Software | Export-Excel -Path $ExcelPath -WorksheetName Software -AutoSize -AutoFilter
                $SysInfo.Enviroment | Export-Excel -Path $ExcelPath -WorksheetName ENV -AutoSize -AutoFilter
                $SysInfo.hotfix | Export-Excel -Path $ExcelPath -WorksheetName Hotfix -AutoSize -AutoFilter
                $SysInfo.EventViewer | Export-Excel -Path $ExcelPath -WorksheetName Events -AutoSize -AutoFilter
                $SysInfo.Network | Export-Excel -Path $ExcelPath -WorksheetName Network -AutoSize -AutoFilter
                $SysInfo.AntiVirus | Export-Excel -Path $ExcelPath -WorksheetName Antivirus -AutoSize -AutoFilter
                $SysInfo.Services | Export-Excel -Path $ExcelPath -WorksheetName Services -AutoSize -AutoFilter
            }
        }
        catch { Write-Warning "[Report]Excel Report Failed:`n $($_.Exception.Message)" }

    }
    #endregion
    if ($Export -eq 'HTML') {
        try {
            #region html settings
            $SectionSettings = @{
                HeaderTextSize        = '16'
                HeaderTextAlignment   = 'center'
                HeaderBackGroundColor = '#00203F'
                HeaderTextColor       = '#ADEFD1'
                backgroundColor       = 'lightgrey'
                CanCollapse           = $true
            }
            $TableSettings = @{
                SearchHighlight = $True
                AutoSize        = $true
                Style           = 'cell-border'
                ScrollX         = $true
                HideButtons     = $true
                HideFooter      = $true
                FixedHeader     = $true
                TextWhenNoData  = 'No Data to display here'
                DisableSearch   = $true
                ScrollCollapse  = $true
                #Buttons        =  @('searchBuilder','pdfHtml5','excelHtml5')
                ScrollY         = $true
                DisablePaging   = $true
                PagingLength    = '10'
            }
            $ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
            #endregion

            #region Build HTML
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "SystemInfo-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"
              
            New-HTML -TitleText 'SystemInfo' -FilePath $HTMLPath {
                New-HTMLLogo -RightLogoString $ImageLink
                New-HTMLNavFloat -Title 'Server Info' -TitleColor AirForceBlue -TaglineColor Amethyst {
                    New-NavFloatWidget -Type List {
                        New-NavFloatWidgetItem -IconColor AirForceBlue -IconSolid home -Name 'Home' -LinkHome
                        foreach ($SysInfo in $allcomp) { New-NavFloatWidgetItem -IconColor Blue -IconBrands bluetooth -Name "$($SysInfo.Hostname)" -InternalPageID "$($SysInfo.Hostname)" }
                    }
                } -ButtonColor White -ButtonColorBackground red -ButtonLocationRight 30px -ButtonLocationTop 70px -ButtonColorBackgroundOnHover pink -ButtonColorOnHover White
        
                New-HTMLPanel -Invisible {
                    New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 40 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text 'Welcome to your Server Info' }
                    New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Date Collected: $($SysInfo.DateCollected)" }
                    New-HTMLPanel -Invisible -Content { $allcomp.hostname | ForEach-Object { New-HTMLText -FontSize 20 -FontStyle oblique -TextTransform lowercase -Color '#00203F' -Alignment center -Text "$($_)" } }

                }

                foreach ($SysInfo in $allcomp) {

                    New-HTMLPage -Name "$($SysInfo.Hostname)" -PageContent {
                        New-HTMLLogo -RightLogoString $ImageLink
                        New-HTMLPanel -Invisible {
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 40 -FontStyle oblique -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Server: $($SysInfo.Hostname)" }
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Date Collected: $($SysInfo.DateCollected)" }
                        }


                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 20% -Title 'Windows' { New-HTMLTable -DataTable $SysInfo.Windows @TableSettings } -X 10px -Y 10px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'OS' { New-HTMLTable -DataTable $SysInfo.OS @TableSettings } -X 40px -Y 40px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 30% -Width 30% -Title 'AntiVirus' { New-HTMLTable -DataTable $SysInfo.AntiVirus @TableSettings } -X 70px -Y 70px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Bios' { New-HTMLTable -DataTable $SysInfo.Bios @TableSettings } -X 100px -Y 100px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Enviroment' { New-HTMLTable -DataTable $SysInfo.Enviroment @TableSettings } -X 130px -Y 130px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 50% -Title 'EventViewer' { New-HTMLTable -DataTable $SysInfo.EventViewer @TableSettings {
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } } -X 160px -Y 160px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 30% -Title 'Software' { New-HTMLTable -DataTable $SysInfo.Software @TableSettings } -X 190px -Y 190px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 20% -Width 50% -Title 'Network' { New-HTMLTable -DataTable $SysInfo.Network @TableSettings } -X 220px -Y 220px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Services' { New-HTMLTable -DataTable $SysInfo.Services @TableSettings {
                                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Operator eq -Value 'Stopped' -Color GhostWhite -Row -BackgroundColor FaluRed } } -X 250px -Y 250px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 20% -Title 'hotfix' { New-HTMLTable -DataTable $SysInfo.hotfix @TableSettings } -X 270px -Y 170px


                    }
                }

            } -Online -ShowHTML
        }
        catch { Write-Warning "[Report]HTML Report Failed:`n $($_.Exception.Message)" }
        #endregion
    }
    if ($Export -eq 'Host') { return $allcomp }

    


    
} #end Function
