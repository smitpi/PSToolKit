
<#PSScriptInfo

.VERSION 0.1.0

.GUID a7794dcf-a8f6-4745-b0f3-3e841891a470

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
 install Citrix cloud connector

#>

<#
.SYNOPSIS
Install Citrix cloud connector

.DESCRIPTION
Install Citrix cloud connector

.PARAMETER Customer_Id
Parameter description

.PARAMETER Client_Id
Parameter description

.PARAMETER Client_Secret
Parameter description

.PARAMETER Customer_Name
Parameter description

.EXAMPLE
Install-CitrixCloudConnector

#>
Function Install-CitrixCloudConnector {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-CitrixCloudConnector')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[string]$Customer_Id,
		[Parameter(Mandatory = $true)]
		[string]$Client_Id,
		[Parameter(Mandatory = $true)]
		[string]$Client_Secret,
		[Parameter(Mandatory = $true)]
		[string]$Customer_Name
	)

	## TODO Move script to ctxcloudapi module
	try {
		Import-Module CtxCloudAPI -Force -ErrorAction Stop
	}
 catch {
		Write-Warning 'Installing missing module CTXCloudApi'
		Install-Module -Name CTXCloudApi -Scope CurrentUser -Force -AllowClobber
		Import-Module CTXCloudApi -Force
	}

	$splat = @{
		Customer_Id   = $Customer_Id
		Client_Id     = $Client_Id
		Client_Secret = $Client_Secret
		Customer_Name = $Customer_Name
	}
	$APIHeader = Connect-CTXAPI @splat

	$ResourceLocationId = (Get-CTXAPI_ResourceLocations $APIHeader | Out-GridView -Title 'Resource Locations' -OutputMode Single).id

	if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

	$uri = 'https://downloads.cloud.com/dcintab5def1/connector/cwcconnector.exe'
	$outputfile = 'C:\Temp\cwcconnector.exe'
	Write-Host 'Dowloading latest release' -ForegroundColor Cyan
	Invoke-WebRequest -Uri $uri -OutFile $outputfile

	Write-Host 'Installing Cloud connector' -ForegroundColor Yellow
	Start-Process -FilePath $outputfile -ArgumentList "/q /Customer:$Customer_ID  /ClientId:$Client_id  /ClientSecret:$Client_id  /ResourceLocationId:$ResourceLocationId  /AcceptTermsOfService:$true" -NoNewWindow -Wait

	Get-CTXAPI_CloudConnectors -APIHeader $apiheader | Select-Object fqdn, location, status, lastContactDate, inMaintenance | Format-Table -AutoSize

} #end Function
