
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7f8b18aa-e16e-4f33-9ea4-4693ea56ea2a

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
Created [27/10/2021_04:26] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Install All Remote Support Tools

#>


<#
.SYNOPSIS
Install All Remote Support Tools

.DESCRIPTION
Install All Remote Support Tools

.EXAMPLE
Install-RSAT

.NOTES
General notes
#>
Function Install-RSAT {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-RSAT')]
	PARAM()
	$checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
	if ($checkver -notlike '*server*') {
		Write-Host 'Installing RSAT on device type:' -ForegroundColor Cyan -NoNewline
		Write-Host 'Workstation' -ForegroundColor red

		$currentInstalled = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.state -like 'Installed' } | Select-Object -Property DisplayName, State, name
		Write-Host 'Currenly Installed RSAT modules:' -ForegroundColor Cyan
		$currentInstalled | ForEach-Object { Write-Host $_.DisplayName -ForegroundColor Green }

		Write-Host ' '
		Write-Host '------------------------------------------------------'
		Write-Host ' '
		Write-Host 'Installing remaining RSAT modules:' -ForegroundColor Cyan
		$currentmissing = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.state -notlike 'Installed' } | Select-Object -Property DisplayName, State, name
		$currentmissing | ForEach-Object {
			Write-Host $_.DisplayName -ForegroundColor Green
			Add-WindowsCapability -Name $_.name -Online
		}
	}
 else {
		Write-Host 'Installing RSAT on device type:' -ForegroundColor Cyan -NoNewline
		Write-Host 'Server' -ForegroundColor red

		$currentInstalled = Get-WindowsFeature | Where-Object { $_.name -like 'RSAT*' -and $_.InstallState -like 'Installed' } | Select-Object DisplayName, InstallState, name
		Write-Host 'Currenly Installed RSAT modules:' -ForegroundColor Cyan
		$currentInstalled | ForEach-Object { Write-Host $_.DisplayName -ForegroundColor Green }

		Write-Host ' '
		Write-Host '------------------------------------------------------'
		Write-Host ' '
		Write-Host 'Installing remaining RSAT modules:' -ForegroundColor Cyan
		$currentmissing = Get-WindowsFeature | Where-Object { $_.name -like 'RSAT*' -and $_.InstallState -notlike 'Installed' } | Select-Object DisplayName, InstallState, name
		$currentmissing | ForEach-Object {
			Write-Host $_.DisplayName -ForegroundColor Green
			Install-WindowsFeature -Name $_.name -IncludeAllSubFeature
		}

	}

} #end Function
