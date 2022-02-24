
<#PSScriptInfo

.VERSION 0.1.0

.GUID ed39e15a-67d3-4ecb-b140-50909f71d915

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
Created [23/02/2022_23:01] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
Calculates the uptime of a system 
#>

Function Get-SystemUptime {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SystemUptime')]
	                PARAM(
		            [Parameter(Mandatory = $false)]
					[Parameter(ParameterSetName = 'Set1')]
        			[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                            		else {throw "Unable to connect to $($_)"} })]
        			[string[]]$ComputerName = $env:computername
					)

[System.Collections.ArrayList]$ReturnObj = @()
foreach ($computer in $ComputerName) {
try {
	$lastboottime = (Get-CimInstance -ComputerName $computer -ClassName Win32_OperatingSystem ).LastBootUpTime
	$timespan = New-TimeSpan -Start $lastboottime -End (get-date)
} catch {Throw "Unable to connect to $($computer)"}
[void]$ReturnObj.add([PSCustomObject]@{
	ComputerName 	 = $computer
	Date         	 = $lastboottime
    Summary =  [PSCustomObject]@{
	    ComputerName 	 = $computer
	    Date         	 = $lastboottime
	    TotalDays		 = [math]::Round($timespan.totaldays)
	    TotalHours		 = [math]::Round($timespan.totalhours)
    }
	All = [PSCustomObject]@{
	    ComputerName 	 = $computer
	    Date         	 = $lastboottime
        Timespan         = $timespan
    }
})
}
return $ReturnObj
} #end Function
