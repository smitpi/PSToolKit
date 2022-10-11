
<#PSScriptInfo

.VERSION 0.1.0

.GUID 50595f56-95a0-4491-883a-e3022264c340

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
Created [24/02/2022_05:49] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Calculates the uptime of a system

#>


<#
.SYNOPSIS
Calculates the uptime of a system

.DESCRIPTION
Calculates the uptime of a system

.PARAMETER ComputerName
Computer to query.

.PARAMETER Credential
To connect using a different account.

.EXAMPLE
Get-SystemUptime -ComputerName Neptune

#>
Function Get-SystemUptime {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SystemUptime')]
	[outputtype('System.Object[]')]
	PARAM(
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[Alias('DNSHostName', 'Name')]
		[ValidateNotNullOrEmpty()]
		[string[]]$ComputerName = $env:COMPUTERNAME,
		[pscredential]$Credential
	)

	begin {
		[System.Collections.generic.List[PSObject]]$UpTimeObject = @()
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
	} #begin
	process {
		foreach ($computer in $ComputerName) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to $($computer)"
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($computer)) +1) of $($ComputerName.Count)"
			try {
				if ($PSBoundParameters.Values -contains 'Credential') {$CimSession = New-CimSession -ComputerName $computer -Credential $Credential -ErrorAction Stop}
				else {$CimSession = New-CimSession -ComputerName $computer -ErrorAction Stop}
				
				$OperatingSystem = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem
				$timespan = New-TimeSpan -Start $OperatingSystem.LastBootUpTime -End (Get-Date)
				if ($timespan.TotalDays -lt 1) { 
					$TotalDays = [math]::Round($timespan.totaldays, 2)
				} # If
				else {
					$TotalDays = [math]::Round($timespan.totaldays)
				} #else
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Building Object"
				$UpTimeObject.Add([PSCustomObject]@{
						ComputerName = $OperatingSystem.PSComputerName
						Connection   = 'Successful'
						Caption      = $OperatingSystem.Caption
						BootDate     = [datetime]$OperatingSystem.LastBootUpTime
						TotalDays    = $TotalDays
						TotalHours   = [math]::Round($timespan.totalhours)
					})
			} catch {
				Write-Warning "Error $($computer): Message:$($Error[0])"
				$UpTimeObject.Add([PSCustomObject]@{
						ComputerName = $computer
						Connection   = 'Failed'
						Caption      = 'Unknown'
						BootDate     = 'Unknown'
						TotalDays    = 'Unknown'
						TotalHours   = 'Unknown'
					})
			}

		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($computer) - Complete"
	} #Process
	end {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) End] Done"
		$UpTimeObject
	} #End
} #end Function
