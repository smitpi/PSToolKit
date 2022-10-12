
<#PSScriptInfo

.VERSION 0.1.0

.GUID 4df2d0cd-5ec5-489b-9dc4-3f255e40006e

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
Created [07/01/2022_13:35] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Connects to a remote hosts and collect installed software details

#>


<#
.SYNOPSIS
Connects to a remote hosts and collect installed software details

.DESCRIPTION
Connects to a remote hosts and collect installed software details

.PARAMETER ComputerName
Name of the computers that will be audited.

.PARAMETER Credential
Use another userid to collect date.

.PARAMETER Export
Export the results to excel or html

.PARAMETER ReportPath
Path to save the report.

.EXAMPLE
Get-SoftwareAudit -ComputerName Neptune -Export Excel

#>
Function Get-SoftwareAudit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SoftwareAudit')]
	PARAM(
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[Alias('Name', 'DNSHostName')]
		[string[]]$ComputerName,

		[pscredential]$Credential,

		[ValidateSet('All', 'Excel', 'HTML', 'HTML5', 'Host')]
		[string[]]$Export = 'Host',
		
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
	Begin {
		[System.Collections.generic.List[PSObject]]$AppsObject = @()
	}#begin
	Process {
		foreach ($Computer in $ComputerName) { 
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($Computer)) + 1) of $($ComputerName.Count)"
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Starting $($Computer)"
			try {
				if ($PSBoundParameters.ContainsKey('Credential')) {
					$rawdata = Invoke-Command -ComputerName $Computer -ScriptBlock {
						Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
						Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
					} -Credential $Credential -ErrorAction Stop
				} else {
					$rawdata = Invoke-Command -ComputerName $Computer -ScriptBlock {
						Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
						Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
					} -ErrorAction Stop
				}
				foreach ($item in $rawdata) {
					if (-not([string]::IsNullOrEmpty($item.DisplayName))) {
						$AppsObject.Add([pscustomobject]@{
								HostName        = ([System.Net.Dns]::GetHostEntry(($($Computer)))).HostName
								Connection      = 'Successful'
								DisplayName     = $item.DisplayName
								Publisher       = $item.Publisher
								DisplayVersion  = $item.DisplayVersion
								EstimatedSize   = [Decimal]::Round([int]$item.EstimatedSize / 1024, 2)
								UninstallString = $item.UninstallString
							})
					}
				}
			} catch {
				Write-Warning "Error $($Computer): Message:$($Error[0])"
				$AppsObject.Add([pscustomobject]@{
						HostName        = $Computer
						Connection      = 'Failed'
						DisplayName     = $Null
						Publisher       = $Null
						DisplayVersion  = $Null
						EstimatedSize   = $Null
						UninstallString = $Null
					})
			}
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Done $($Computer)"
		} #Foreach
	} #Process
	End {
		if ($Export -contains 'Host') {$AppsObject}
		else {
			$ToReport = [PSCustomObject]@{
				'Applications' = $AppsObject
			}# PSObject

			$DefParameter = $PSBoundParameters
			$DefParameter.Remove('ComputerName') | Out-Null
			$DefParameter.Remove('Credential') | Out-Null
			$DefParameter.InputObject = $ToReport
			$DefParameter.ReportTitle = 'Installed Software'
			$DefParameter.OpenReportsFolder = $true

			Write-PSReports @DefParameter
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] DONE"
	} #End
} #end Function