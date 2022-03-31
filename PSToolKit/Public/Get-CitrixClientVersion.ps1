
<#PSScriptInfo

.VERSION 0.1.0

.GUID 570c4be8-12c9-4e0b-938d-97128e8bf2be

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
 Report on the CItrix workspace versions the users are using.

#>

<#
.SYNOPSIS
 Report on the CItrix workspace versions the users are using.

.DESCRIPTION
 Report on the CItrix workspace versions the users are using.

.PARAMETER AdminAddress
DDC FQDN

.PARAMETER hours
Limit the amount of data to collect from OData

.PARAMETER ReportsPath
Where report will be saved.

.EXAMPLE
Get-CitrixClientVersions -AdminAddress localhost -hours 12

#>
Function Get-CitrixClientVersion {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-CitrixClientVersions')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminAddress,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int]$hours,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (-Not (Test-Path $_) ) { stop }
				$true
			})]
		[string[]]$ReportsPath)


	$now = Get-Date -Format yyyy-MM-ddTHH:mm:ss
	$past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss')

	$urisettings = @{
		#AllowUnencryptedAuthentication = $true
		UseDefaultCredentials = $true
	}

	$SessionURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Sessions?$filter = StartDate ge datetime''' + $past + ''' and StartDate le datetime''' + $now + ''''
	$ConnectionURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Connections?$filter = LogOnStartDate ge datetime''' + $past + ''' and LogOnStartDate le datetime''' + $now + ''''
	$UsersURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Users'
	#$MachinesURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Machines'

	$Sessions = (Invoke-RestMethod -Uri $SessionURI @urisettings ).content.properties
	$Connections = (Invoke-RestMethod -Uri $ConnectionURI @urisettings ).content.properties
	$users = (Invoke-RestMethod -Uri $UsersURI @urisettings ).content.properties


	$index = 1
	[string]$AllCount = $Connections.Count
	$export = @()
	$Connections | ForEach-Object {
		$connect = $_
		$id = ($Sessions | Where-Object { $_.SessionKey.'#text' -like $connect.SessionKey.'#text' }).UserId.'#text'
		$userdetails = $users | Where-Object { $_.id.'#text' -like $id }
		Write-Output "Collecting data $index of $AllCount"
		$index++
		$export += [pscustomobject]@{
			Domain         = $userdetails.Domain
			UserName       = $userdetails.UserName
			Upn            = $userdetails.Upn
			FullName       = $userdetails.FullName
			ClientName     = $connect.ClientName
			ClientAddress  = $connect.ClientAddress
			ClientVersion  = $connect.ClientVersion
			ClientPlatform = $connect.ClientPlatform
			Protocol       = $connect.Protocol
		} | Select-Object Domain, UserName, Upn, FullName, ClientName, ClientAddress, ClientVersion, ClientPlatform, Protocol
	}
	$Reportpath = ($ReportsPath).Trim() + '\Citrix_Client_Ver_' + (Get-Date -Format yyyy_MM_dd).ToString() + '.csv'
	$export | Sort-Object -Property Username -Descending -Unique | Export-Csv -Path $Reportpath -NoClobber -Force -NoTypeInformation

} #end Function
