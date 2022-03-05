
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3fe6d34a-fcd0-4569-862b-1873f0cb4775

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
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 All a config file with Citrix server details. To be imported as variables.

#>

<#
.SYNOPSIS
 All a config file with Citrix server details. To be imported as variables.

.DESCRIPTION
 All a config file with Citrix server details. To be imported as variables.

.EXAMPLE
New-CitrixSiteConfigFile

#>
Function New-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile')]

	$path = Read-Host 'Where to save the config file'
	if (Test-Path $path) { $fullname = (Get-Item $path).FullName }
	else { Throw 'Path does not exist' }


	[System.Collections.ArrayList]$DataColectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Data Collector'
		if ($null -notlike $tmpobj) {
			[void]$DataColectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$CloudConnectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Cloud Connectors'
		if ($null -notlike $tmpobj) {
			[void]$CloudConnectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$storefont = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix StoreFont'
		if ($null -notlike $tmpobj) {
			[void]$storefont.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$Director = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Director'
		if ($null -notlike $tmpobj) {
			[void]$Director.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$VDA = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'VDA Test Boxes'
		if ($null -notlike $tmpobj) {
			[void]$VDA.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$Other = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Other Servers'
		if ($null -notlike $tmpobj) {
			[void]$Other.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	$RDSLicenseServer = $((Get-FQDN -ComputerName (Read-Host 'RDS License Server') ).FQDN)
	try {
		$site = Get-BrokerSite -AdminAddress $DataColectors[0] -ErrorAction Stop
		$DDCDetails = Get-BrokerController -AdminAddress $DataColectors[0] | Select-Object -First 1 -ErrorAction Stop
		$CTXLicenseServer = $site.LicenseServerName
		$siteName = $site.Name
		$funcionlevel = $site.DefaultMinimumFunctionalLevel
		$version = $DDCDetails.ControllerVersion
	} catch {
		Write-Warning 'Unable to connect to the Farm.'
		$CTXLicenseServer = $((Get-FQDN -ComputerName (Read-Host 'Citrix License Server') ).FQDN)
		$siteName = Read-Host 'Site Name'
		$funcionlevel = 'Unknown'
		$version = 'Unknown'
		$site = 'Unknown'
		$DDCDetails = 'Unknown'
	}


	$CTXSiteDetails = [PSCustomObject]@{
		DateCollected = (Get-Date -Format yyyy-MM-ddTHH.mm)
		SiteName      = $siteName
		Funcionlevel  = $funcionlevel
		Version       = $version
		CTXServers    = [PSCustomObject]@{
			DataColector     = $DataColectors
			CloudConnector   = $CloudConnectors
			Storefont        = $storefont
			Director         = $Director
			RDSLicenseServer = $RDSLicenseServer
			CTXLicenseServer = $CTXLicenseServer
			VDA              = $VDA
			Other            = $Other
		}
	}

	$CTXSiteDetails

	if (Test-Path (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json')) {
		Write-Warning 'Config File Exists, renaming the old config file.'
		Rename-Item -Path (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json') -NewName "CTXSiteConfig_$(Get-Date -Format yyyyMMdd_HHmm).json"
	}
	$CTXSiteDetails | ConvertTo-Json | Out-File (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json') -Encoding utf8
} #end Function