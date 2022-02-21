
<#PSScriptInfo

.VERSION 0.1.0

.GUID 68ea7fd0-8305-4ef4-a56a-874605a23e52

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
Created [26/10/2021_22:33] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PoshRegistry

<#

.DESCRIPTION
Update list of ListOfDDCs in the registry

#>

<#
.SYNOPSIS
Update list of ListOfDDCs in the registry

.DESCRIPTION
Update list of ListOfDDCs in the registry

.PARAMETER ComputerName
Server to update

.PARAMETER CurrentOnly
Only display current setting.

.PARAMETER CloudConnectors
List of DDC or Cloud Connector FQDN

.EXAMPLE
Update-ListOfDDCs -ComputerName AD01 -CloudConnectors $DDC

#>
Function Update-ListOfDDCs {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-ListOfDDCs')]
	PARAM(
		[string]$ComputerName = 'localhost',
		[switch]$CurrentOnly = $false,
		[string[]]$CloudConnectors
	)

	Import-Module PoshRegistry -Force
	if ($CurrentOnly) {
		$current = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "Current DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $current -ForegroundColor Red
	}
	else {
		$current = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "Current DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $current -ForegroundColor Red
		Write-Host '----------------------------------' -ForegroundColor Yellow

		foreach ($connector in $CloudConnectors) { if (-not(Test-Connection $connector -Count 1 -Quiet)) { Write-Warning "Unable to connect to $($connector)" } }
		$ListOfDDC = Join-String $CloudConnectors -Separator ' '

		Set-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs -Data $ListOfDDC -Force

		Get-Service -DisplayName 'Citrix Desktop Service' | Restart-Service -Force
		$currentnew = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "New DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $currentnew -ForegroundColor Green
	}
} #end Function
