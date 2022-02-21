
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
 All a config file with CItrix server details. To be imported as variables.

#>

<#
.SYNOPSIS
 All a config file with CItrix server details. To be imported as variables.

.DESCRIPTION
 All a config file with CItrix server details. To be imported as variables.

.EXAMPLE
An example

.NOTES
General notes
#>
Function New-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile')]
	$path = Read-Host 'Where to save the config file'
	if (Test-Path $path) { $fullname = (Get-Item $path).FullName }
	else { Write-Error 'Path does not exist'; halt }

	$DataColectors = @()
	$UserInput = ''
	While ($UserInput -ne 'n') {
		$DataColectors += Read-Host 'Citrix Data Collector FQDN:'
		$UserInput = Read-Host 'Add more? (y/n)'
	}
	$CloudConnectors = @()
	$UserInput = ''
	While ($UserInput -ne 'n') {
		$CloudConnectors += Read-Host 'Citrix Cloud Connectors FQDN:'
		$UserInput = Read-Host 'Add more? (y/n)'
	}
	$storefont = @()
	$UserInput = ''
	While ($UserInput -ne 'n') {
		$storefont += Read-Host 'Citrix StoreFront FQDN:'
		$UserInput = Read-Host 'Add more? (y/n)'
	}
	$Director = @()
	$UserInput = ''
	While ($UserInput -ne 'n') {
		$storefont += Read-Host 'Citrix Director FQDN:'
		$UserInput = Read-Host 'Add more? (y/n)'
	}
	$RDSLicenseServer = Read-Host 'RDS Lisense Server FQDN:'
	try {
		$site = Get-BrokerSite -AdminAddress $DataColectors[0]
		$DDCDetails = Get-BrokerController -AdminAddress $DataColectors[0] | Select-Object -First 1
	}
	catch {
		$site = 'Unknown'
		$DDCDetails = 'Unknown'
	}
	$CTXLicenseServer = $site.LicenseServerName
	$siteName = $site.Name
	$funcionlevel = $site.DefaultMinimumFunctionalLevel
	$version = $DDCDetails.ControllerVersion

	$CTXSiteDetails = [PSCustomObject]@{
		DateCollected = Get-Date -Format yyyy-MM-ddTHH.mm
		SiteName      = $siteName
		Funcionlevel  = $funcionlevel
		Version       = $version
		CTXServers    = [PSCustomObject]@{
			DataColectors    = $DataColectors
			CloudConnectors  = $CloudConnectors
			Storefont        = $storefont
			Director         = $Director
			RDSLicenseServer = $RDSLicenseServer
			CTXLicenseServer = $CTXLicenseServer
		}
	}
	$CTXSiteDetails
	$CTXSiteDetails | ConvertTo-Json | Out-File "$fullname\CTXSiteConfig.json" -Force -Verbose



} #end Function