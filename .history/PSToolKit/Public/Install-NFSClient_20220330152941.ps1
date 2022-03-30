
<#PSScriptInfo

.VERSION 0.1.0

.GUID f66cfeab-9d59-4e34-9b21-b49211191224

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
Created [30/03/2022_15:27] Initial Script Creating

.PRIVATEDATA

#>


#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Install NFS Client for windows 

#> 


<#
.SYNOPSIS
Install NFS Client for windows

.DESCRIPTION
Install NFS Client for windows

.EXAMPLE
Install-NFSClient

#>
Function Install-NFSClient {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-NFSClient')]
	[OutputType([System.Object[]])]
	PARAM(	)

	
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

} #end Function
