
<#PSScriptInfo

.VERSION 0.1.0

.GUID 31ba0989-9109-4acc-8c7a-7840d5827160

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/01/2022_08:11] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
Get FQDN for a device, and checks if it is online

#>


<#
.SYNOPSIS
Get FQDN for a device, and checks if it is online

.DESCRIPTION
Get FQDN for a device, and checks if it is online

.PARAMETER ComputerName
Name or IP to use.

.EXAMPLE
get-FQDN -ComputerName Neptune

#>
Function Get-FQDN {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FQDN')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
		[string[]]$ComputerName
	)
	process {
		[System.Collections.ArrayList]$outobject = @()
		$ComputerName | ForEach-Object {
			[void]$outobject.add([pscustomobject]@{
					Host   = $($_)
					FQDN   = ([System.Net.Dns]::GetHostEntry(($($_)))).HostName
					Online = Test-Connection -ComputerName $(([System.Net.Dns]::GetHostEntry(($($_)))).HostName) -Quiet -Count 2
				})
		}
	}
	end {return $outobject}
} #end Function
