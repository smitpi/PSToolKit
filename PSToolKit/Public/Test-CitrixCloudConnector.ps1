
<#PSScriptInfo

.VERSION 0.1.0

.GUID ae901c67-3a7d-492a-accc-796ed427b2fd

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
Perform basic connection tests to CItrix cloud.

#>

<#
.SYNOPSIS
Perform basic connection tests to CItrix cloud.

.DESCRIPTION
Perform basic connection tests to CItrix cloud.

.PARAMETER CustomerID
get from CItrix cloud.

.PARAMETER Export
Export the results

.PARAMETER ReportPath
Where report will be saved.

.EXAMPLE
An example

.NOTES
General notes
#>
Function Test-CitrixCloudConnector {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Test-CitrixCloudConnector')]
	PARAM(
		[string]$CustomerID,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
	)

	Write-Color 'Checking if needed CA certificates are installed.' -Color DarkCyan
	$online_root = '0563B8630D62D75ABBC8AB1E4BDFB5A899B24D43'
	$online_inter = '92C1588E85AF2201CE7915E8538B492F605B80C6'
	$root = Get-ChildItem -Path Cert:\LocalMachine\Root
	$Inter = Get-ChildItem -Path Cert:\LocalMachine\CA

	if ($online_root -notin $root.Thumbprint) {
		Write-Color 'Installing: ', 'DigiCertAssuredIDRootCA' -Color Cyan, Yellow -NoNewLine
		$rootca = 'c:\temp\DigiCert-rootca.crt'
		Invoke-WebRequest -Uri https://dl.cacerts.digicert.com/DigiCertAssuredIDRootCA.crt -OutFile $rootca | Out-Null
		Import-Certificate -FilePath $rootca -CertStoreLocation Cert:\LocalMachine\root\ | Out-Null
		Write-Color ' - Complete' -Color Green
	}
	if ($online_inter -notin $Inter.Thumbprint) {
		Write-Color 'Installing: ', 'DigiCertSHA2AssuredIDCodeSigningCA' -Color Cyan, Yellow -NoNewLine
		$ca_l1 = 'c:\temp\DigiCert-L1.crt'
		Invoke-WebRequest -Uri https://dl.cacerts.digicert.com/DigiCertSHA2AssuredIDCodeSigningCA.crt -OutFile $ca_l1
		Import-Certificate -FilePath $ca_l1 -CertStoreLocation Cert:\LocalMachine\CA | Out-Null
		Write-Color 'Complete' -Color Green
	}
	Write-Color 'Fetching url list from Citrix'

	$uri = 'https://fqdnallowlistsa.blob.core.windows.net/fqdnallowlist-commercial/allowlist.json'
	$siteList = Invoke-RestMethod -Uri $uri

	$members = $siteList | Get-Member -MemberType NoteProperty
	foreach ($item in $members) {
		Write-Color 'Checking Service:', $($item.Name) -Color Cyan, Yellow -LinesBefore 2
		Write-Color 'Last Change: ' -Color Yellow
		$siteList.$($item.Name).LatestChangeLog
		Write-Color 'Checking AllowList:'

		$list = $($siteList.$($item.Name).AllowList)
		foreach ($single in $list ) {
			Write-Color 'Checking - ', $($single) -Color Cyan, Yellow
			try {
				if ($single -like '<CUSTOMER_ID>*') { $single = $single.replace('<CUSTOMER_ID>', $($CustomerID)) }
				$Response = Invoke-WebRequest -Uri "https://$($single)"
				$StatusCode = $Response.StatusCode
				$StatusMessage = $Response.StatusDescription
			}
			catch {
				$StatusMessage = $_.Exception.Message
				$StatusCode = $_.Exception.Response.StatusCode.value__
			}
			$Fdata += @(
				[PSCustomObject]@{
					Service       = $($item.Name)
					Site          = $single
					statusCode    = $StatusCode
					StatusMessage = $StatusMessage
				}
			)
		}
	}

	if ($Export -eq 'Excel') { $fdata | Export-Excel -Path ($ReportPath + '\ConnectorUrl-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $fdata | Out-HtmlView -DisablePaging -Title 'ConnectorUrl-' -HideFooter -SearchHighlight -FixedHeader }
	if ($Export -eq 'Host') { $fdata }

} #end Function
