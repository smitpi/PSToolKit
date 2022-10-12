
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
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[Alias ('Name', 'DNSHostName')]
		[string[]]$ComputerName	
	)
	begin {
		[System.Collections.generic.List[PSObject]]$FQDNObject = @()
	}#Begin

	process {
		foreach ($Computer in $ComputerName) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($Computer)) + 1) of $($ComputerName.Count)"
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to $($Computer)"
			try {
				$FQDNObject.Add([PSCustomObject]@{
						ComputerName = $Computer
						FQDN         = ([System.Net.Dns]::GetHostEntry(($($Computer)))).HostName
					}) #PSList
			} catch {Write-Warning "Error $($Computer): Message:$($Error[0])"}
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Done: $($Computer)"
	} #Process
	end {$FQDNObject}
} #end Function
