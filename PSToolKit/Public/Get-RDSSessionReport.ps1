
<#PSScriptInfo

.VERSION 0.1.0

.GUID 50e62fc0-27f9-4030-979a-fd134a1b1114

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS rds

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [06/04/2023_14:18] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Reports on Connects and Disconnects on a RDS Farm.

#> 


<#
.SYNOPSIS
Reports on Connects and Disconnects on a RDS Farm.

.DESCRIPTION
Reports on Connects and Disconnects on a RDS Farm.

.EXAMPLE
Get-RDSSessionReport -Export HTML -ReportPath C:\temp

#>

<#
.SYNOPSIS
Reports on Connects and Disconnects on a RDS Farm.

.DESCRIPTION
Reports on Connects and Disconnects on a RDS Farm.

.PARAMETER Gateway
Gateway server name for RDS Farm.

.PARAMETER UserName
Filter to report only on this user.

.PARAMETER Credential
Account with RDS Admin Access.

.PARAMETER Export
Export the results to a report.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-RDSSessionReport -Gateway TXGATE01 -Credential $admin -Export Excel,HTML -ReportPath C:\Temp\rds

#>
Function Get-RDSSessionReport {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-RDSSessionReport')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[Parameter(Position = 0,Mandatory,HelpMessage = 'Specify the name of the RDS Gateway Server.')]
		[ValidateNotNullorEmpty()]
		[ValidateScript({ (Test-Connection $_ -Count 1 -Quiet) -and ({
						$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
						if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
						else { Throw 'Must be running an elevated prompt.' }
					}) })]
		[string]$Gateway,
		
		[Parameter(Position = 1)]
		[string]$UserName,

		[Parameter(Position = 2)]
		[pscredential]$Credential,

		[ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
		[string[]]$Export = 'Host',

		[ValidateScript( { if (Test-Path $_) { $true }
				else {
					Write-Warning 'Folder does not exist, creating folder now.'
					New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true 
				}
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
	#endregion

	Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
	$ConnectFilter = @{
		LogName = 'Microsoft-Windows-TerminalServices-Gateway/Operational'
		ID      = @('302','303')
	}

	if ($Credential) {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Process] Collecting Events from $($Gateway) with account: $($Credential.UserName)"
		$Events = Get-WinEvent -ComputerName $Gateway -FilterHashtable $ConnectFilter -Credential $Credential
	} else {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Process] Collecting Events from $($Gateway)"
		$Events = Get-WinEvent -ComputerName $Gateway -FilterHashtable $ConnectFilter
	}
	[System.Collections.generic.List[PSObject]]$SessionObject = @()
	foreach ($Session in $Events) {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Processing Events: $($Events.IndexOf($($Session)) + 1) of $($Events.Count)"
		$Received = $Duration = $Transferred = $Protocol = 'None'
		if ($Session.id -eq 302) {
			$State = 'Connected'
			$Protocol = $Session.Properties[4].Value
		} else {
			$State = 'Disconnected'
			$Received = $Session.Properties[4].Value
			$Duration = $Session.Properties[6].Value
			$Transferred = $Session.Properties[5].Value
			$Protocol = $Session.Properties[7].Value
		}
		$SessionObject.Add([PSCustomObject]@{
				Date                    = $Session.TimeCreated
				State                   = $State
				Username                = $Session.Properties[0].Value
				ClientComputer          = $Session.Properties[1].Value
				RDSServer               = $Session.Properties[3].Value 
				'Bytes Received'        = $Received
				'Bytes Transferred'     = $Transferred
				'Session Duration(sec)' = $Duration
				Protocol                = $Protocol
				#Message                   = $Session.Message
			}) #PSList
	}

	if ($UserName) {
		$SessionObject = $SessionObject | Where-Object { $_.Username -like "*$($UserName)*" }
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Generating Report"
	if ($Export -contains 'Host') {$SessionObject}
	else {
		Write-PSReports -InputObject $SessionObject -ReportTitle "RDS Session Report" -Export $Export -ReportPath $ReportPath
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] DONE"
} #end Function
