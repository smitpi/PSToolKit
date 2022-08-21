
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
A config file with Citrix server details and URLs. To be used in scripts.

#>

<#
.SYNOPSIS
A config file with Citrix server details and URLs. To be used in scripts.

.DESCRIPTION
A config file with Citrix server details and URLs. To be used in scripts. Use the function Import-CitrixSiteConfigFile to create variables from the config.

.PARAMETER ConfigName
A Unique name for the site / farm.

.PARAMETER Path
Where the config file will be saved.

.EXAMPLE
New-CitrixSiteConfigFile -ConfigName TestFarm -Path C:\Tiles

#>
Function New-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile')]
	PARAM (
		[parameter(Mandatory)]
		[string]$ConfigName,
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$Path = 'C:\Temp'
	)

	$fullname = (Get-Item $path).FullName
	
	[System.Collections.ArrayList]$DataColectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Data Collector'
			if ($null -notlike $tmpobj) {
				[void]$DataColectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$CloudConnectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Cloud Connectors'
			if ($null -notlike $tmpobj) {
				[void]$CloudConnectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$storefont = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix StoreFont'
			if ($null -notlike $tmpobj) {
				[void]$storefont.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$Director = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Director'
			if ($null -notlike $tmpobj) {
				[void]$Director.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$VDA = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'VDA Test Boxes'
			if ($null -notlike $tmpobj) {
				[void]$VDA.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$Other = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Other Servers'
			if ($null -notlike $tmpobj) {
				[void]$Other.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	try {
		$rds = Read-Host 'RDS License Server'
		if ($rds) {$RDSLicenseServer = $((Get-FQDN -ComputerName ($rds) ).FQDN)}

		$StoreFrontURL = Read-Host 'StoreFront URL'
		$GateWayURL = Read-Host 'Citrix GateWay URL'
		$DirectorURL = Read-Host 'Citrix Director URL'
		$DomainFQDN = Read-Host 'Domain FQDN'
		$DomainNetBios = Read-Host 'Domain NetBios'
		$RPath = Read-Host 'Default Reports Folder Path'
		try {
			$ReportPath = Get-Item $RPath -ErrorAction Stop
		} catch {
			Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
			Write-Warning 'Trying to create the folder'
			$ReportPath = New-Item $RPath -ItemType Directory -Force
		}
	} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}


	try {
		$site = Get-BrokerSite -AdminAddress $DataColectors[0] -ErrorAction Stop
		$DDCDetails = Get-BrokerController -AdminAddress $DataColectors[0] | Select-Object -First 1 -ErrorAction Stop
		$CTXLicenseServer = $site.LicenseServerName
		$siteName = $site.Name
		$funcionlevel = $site.DefaultMinimumFunctionalLevel
		$version = $DDCDetails.ControllerVersion
	} catch {
		Write-Warning 'Unable to connect to the Farm. Manually getting details'
		$CtxLic = Read-Host 'Citrix License Server'
		if ($CtxLic) {$CTXLicenseServer = $((Get-FQDN -ComputerName ($CtxLic) ).FQDN)}
		$siteName = Read-Host 'Site Name'
	}



	#if ([string]::IsNullOrEmpty($siteName)) {$siteName}

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
			DomainFQDN       = $DomainFQDN
			DomainNetBios    = $DomainNetBios
			StoreFrontURL    = $StoreFrontURL
			GateWayURL       = $GateWayURL
			DirectorURL      = $DirectorURL
			ReportPath       = $ReportPath.FullName
		}
	}

	$CTXSiteDetails

	if (Test-Path (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json")) {
		Write-Warning 'Config File Exists, renaming the old config file.'
		Rename-Item -Path (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json") -NewName "$($ConfigName)-CTXSiteConfig_$(Get-Date -Format yyyyMMdd_HHmm).json"
	}
	$CTXSiteDetails | ConvertTo-Json | Out-File (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json") -Encoding utf8
} #end Function