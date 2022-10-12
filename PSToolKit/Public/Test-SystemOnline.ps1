
<#PSScriptInfo

.VERSION 0.1.0

.GUID d31f5d99-2bf5-4061-b862-f1b3d78cedb8

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
Created [12/10/2022_00:43] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Does basic checks for connecting to a remote device 

#> 


<#
.SYNOPSIS
Does basic checks for connecting to a remote device

.DESCRIPTION
Does basic checks for connecting to a remote device

.PARAMETER ComputerName
The Device to query.

.PARAMETER Credential
Use another account to do the checks.

.EXAMPLE
Test-SystemOnline -ComputerName $ListOfBoxes -Credential $User


#>
Function Test-SystemOnline {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-SystemOnline')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[Alias ('Name', 'DNSHostName')]
		[string[]]$ComputerName = $env:COMPUTERNAME,
		[pscredential]$Credential
	)
	Begin {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		[System.Collections.generic.List[PSObject]]$SysObject = @()
	} #Begin
	Process {
		foreach ($Computer in $ComputerName) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($Computer)) + 1) of $($ComputerName.Count)"
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to $($Computer)"
			try {
				$HostName = ([System.Net.Dns]::GetHostEntry(($($Computer)))).HostName
				$Connection = Test-Connection -ComputerName $Computer -Count 1 -IPv4 -ErrorAction Stop
				if ($PSBoundParameters.ContainsKey('Credential')) {
					$CimSession = New-CimSession -ComputerName $Computer -Credential $Credential -ErrorAction Stop
					$UserName = $Credential.UserName
				} else {
					$CimSession = New-CimSession -ComputerName $Computer -ErrorAction Stop 
					$UserName = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
				}
				$SysObject.Add([PSCustomObject]@{
						HostName    = $HostName
						Connection  = 'Successful'
						IPV4Address = $Connection.Address
						Protocol    = $CimSession.Protocol
						UserName    = $UserName
					}) #PSList
			} catch {
				Write-Warning "Error $($Computer): Message:$($Error[0])"
				$SysObject.Add([PSCustomObject]@{
						HostName    = $computer
						Connection  = 'Failed'
						IPV4Address = $null
						Protocol    = $null
						UserName    = $null
					}) #PSList
			}
		}
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Done: $($Computer)"
	} #Process
	End {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Done"
		$SysObject
	}#End
} #Function
