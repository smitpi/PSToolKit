
<#PSScriptInfo

.VERSION 0.1.0

.GUID eda0aa73-c409-4d3e-be9f-cb4bc4dfb8aa

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
Created [30/03/2022_15:30] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Install Remote Admin Tools 

#> 


<#
.SYNOPSIS
Install Remote Admin Tools

.DESCRIPTION
Install Remote Admin Tools

.EXAMPLE
Install-RSAT

#>
Function Install-RSAT {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-RSAT')]
	PARAM()

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

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

} #end Function
