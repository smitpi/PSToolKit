
<#PSScriptInfo

.VERSION 0.1.0

.GUID 55c1262b-e7d4-4257-b9ec-fb051e28012a

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS win

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [06/05/2022_05:47] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates and saves a .rdp file 

#> 


<#
.SYNOPSIS
Creates and saves a .rdp file

.DESCRIPTION
Creates and saves a .rdp file

.EXAMPLE
New-RemoteDesktopFile

#>
Function New-RemoteDesktopFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-RemoteDesktopFile')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                else {throw "Unable to connect to $($_)"} })]
        [string[]]$ComputerName,
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$Path = 'C:\Temp',
        [string]$UserName,
        [string]$DomainName,
        [Switch]$Force = $false
    )
    foreach ($Comp in $ComputerName) {
        $fqdn = (Get-FQDN -ComputerName $Comp).FQDN
        $IP = ([System.Net.Dns]::GetHostAddresses($fqdn)).IPAddressToString

        [System.Collections.ArrayList]$RDPFile = @()
        [void]$RDPFile.Add("full address:s:$($fqdn)")
        [void]$RDPFile.Add('singlemoninwindowedmode:i:1')
        [void]$RDPFile.Add("alternate full address:s:$($IP)")
        [void]$RDPFile.Add("username:s:$($UserName)")
        [void]$RDPFile.Add("domain:s:$($DomainName)")
        [void]$RDPFile.Add('redirectsmartcards:i:1')
        [void]$RDPFile.Add('use multimon:i:0')
        [void]$RDPFile.Add('audiocapturemode:i:1')
        [void]$RDPFile.Add('redirectclipboard:i:1')
        [void]$RDPFile.Add('drivestoredirect:s:*')
        [void]$RDPFile.Add('usbdevicestoredirect:s:*')

        if (Test-Path (Join-Path -Path $Path -ChildPath "$($fqdn).rdp")) {
            if ($Force) {
                Write-Warning 'Overriding existing file'
                $RDPFile | Set-Content -Path (Join-Path -Path $Path -ChildPath "$($fqdn).rdp") -Encoding UTF8 -Force
                Write-Color 'RDP File Created: ', "$(Join-Path -Path $Path -ChildPath "$($fqdn).rdp")" -Color Yellow, Green
            } else {
                Write-Error 'File exists, use -force to override'
            }
        } else { 
            $RDPFile | Set-Content -Path (Join-Path -Path $Path -ChildPath "$($fqdn).rdp") -Encoding UTF8 -Force
            Write-Color 'RDP File Created: ', "$(Join-Path -Path $Path -ChildPath "$($fqdn).rdp")" -Color Yellow, Green
        }

    }
} #end Function
