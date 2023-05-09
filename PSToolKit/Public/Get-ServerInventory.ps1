
<#PSScriptInfo

.VERSION 0.1.0

.GUID 91760a19-1c16-4d5b-99e2-7a889aa0784e

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
Created [09/05/2023_08:08] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Connect to remote host and collect server details. 

#> 


<#
.SYNOPSIS
Connect to remote host and collect server details.

.DESCRIPTION
Connect to remote host and collect server details.

.EXAMPLE
Get-ServerInventory -Export HTML -ReportPath C:\temp

#>
Function Get-ServerInventory {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Get-ServerInventory')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Set1', HelpMessage = 'Specify the name of a remote computer. The default is the local host.')]
		[alias('CN', 'host')]
		[ValidateScript({if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {$true}
				else {throw "Unable to connect to $($_)"} })]
		[string[]]$ComputerName,

		[Parameter(Position = 1)]
		[pscredential]$Credentials,

		[ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
		[string[]]$Export = 'None',

		[ValidateScript( { if (Test-Path $_) { $true }
				else {
					Write-Warning 'Folder does not exist, creating folder now.'
					New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true 
				}
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
	#endregion
	Begin {
		[System.Collections.generic.List[PSObject]]$ServerObject = @()
	} #End Begin
	Process {	
		foreach ($IP in $ComputerName) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($IP)) + 1) of $($ComputerName.Count)"
			if ($PSBoundParameters.Keys -contains 'Credentials') {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting with credentials"
					$Comp = (Get-FQDN -ComputerName $IP).fqdn
					$CimSession = New-CimSession -ComputerName $Comp -Credential $Credentials
				} catch {Write-Error "Error: Message:$($Error[0])"}
			} else {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting without credentials"
					$Comp = (Get-FQDN -ComputerName $IP).fqdn
					$CimSession = New-CimSession -ComputerName $Comp
				} catch {Write-Error "Error: Message:$($Error[0])"}
			}
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Getting server details"
			$Network = Get-CimInstance -CimSession $CimSession -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true
			$CPU = Get-CimInstance -CimSession $CimSession -ClassName Win32_Processor
			$OS = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem
			$Ram = Get-CimInstance -CimSession $CimSession -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
			$HDD = Get-CimInstance -CimSession $CimSession -ClassName win32_logicaldisk | Where-Object {$_.DriveType -eq 3}
			[string[]]$HDDSize = $HDD.Size | ForEach-Object {[Math]::Round(($_ / 1gb), 2)}
			[string[]]$HDDFreeSize = $HDD.FreeSpace | ForEach-Object {[Math]::Round(($_ / 1gb), 2)}
			$BIOS = Get-CimInstance -CimSession $CimSession -ClassName win32_bios

			if ($BIOS.SerialNumber -like 'VMware*') {
				$Type = 'Virtual'
			} else { $Type = 'Physical'}

			#region Build Object
			$Serv = [PSCustomObject]@{
				'ComputerName'   = $Comp
				'IP'             = $Network[0].IPAddress[0]
				'MAC'            = $Network[0].MACAddress
				'Server_Type'    = $Type
				'Cpu_Type'       = $CPU[0].Name
				CPU_Count        = $CPU.Count
				'CPU_Cores'      = $CPU[0].NumberOfCores
				VCPU_Totall      = ([int]$CPU.Count * [int]$CPU[0].NumberOfCores)
				'Memory'         = ([Math]::Round(($ram.sum / 1gb), 2))
				'OS'             = $OS.Caption
				'DriveName'      = @(($HDD.DeviceID) | Out-String).Trim()
				'DriveSize'      = @(($HDDSize) | Out-String).Trim()
				'DriveFreeSpace' = @(($HDDFreeSize) | Out-String).Trim()
				# 'DriveName'      = ($HDD.DeviceID) | ForEach-Object { @(($_) | Out-String).Trim()}
				# 'DriveSize'      = ($HDD.size) | ForEach-Object {@(([Math]::Round(($_ / 1gb), 2)) | Out-String).Trim()}
				# 'DriveFreeSpace' = ($HDD.FreeSpace) | ForEach-Object {@(([Math]::Round(($_ / 1gb), 2)) | Out-String).Trim()}
			}
			#endregion
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Complete with $($IP)"
			$ServerObject.Add($Serv)
		}
	}#End Process
	End {
		if ($Export -like 'None') {$ServerObject}
		else {
			Write-PSReports -InputObject $ServerObject -ReportTitle 'Server Details' -Export $Export -ReportPath $ReportPath
		}
		Write-Verbose '[08:08:29 END] Complete'
	}#End End
} #end Function
