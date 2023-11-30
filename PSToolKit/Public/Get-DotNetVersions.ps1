
<#PSScriptInfo

.VERSION 0.1.0

.GUID 723363ca-f4cc-42b5-9e51-2321a1d48af7

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
Created [30/11/2023_08:14] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 List all the installed versions of .net 

#> 


<#
.SYNOPSIS
List all the installed versions of .net

.DESCRIPTION
List all the installed versions of .net

.EXAMPLE
Get-DotNetVersions -Export HTML -ReportPath C:\temp

#>
Function Get-DotNetVersions {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-DotNetVersions')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[Parameter(Mandatory, ValueFromPipeline)]
		[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
				else {throw "Unable to connect to $($_)"} })]
		[string[]]$ComputerName,

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
	Begin {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		[System.Collections.generic.List[PSObject]]$NetObject = @()
	} #End Begin 
	Process {
		foreach ($Computer in $ComputerName) {
			$RawData = $null
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] $($ComputerName.IndexOf($($Computer)) + 1) of $($ComputerName.Count)"
			if ($PSBoundParameters.ContainsKey('Credential')) {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to $($Computer) with Credential $($Credential.UserName)"
					$Session = New-PSSession -ComputerName $Computer -Credential $Credential
					$RawData = Invoke-Command -Session $Session -ScriptBlock {Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, version}
				} catch {Write-Warning "Error: Cant collect data from $($Computer) with Username:$($Credential.UserName) -  Message:$($Error[0])"}
			} else {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to $($Computer) with logged in account"
					$Session = New-PSSession -ComputerName $Computer
					$RawData = Invoke-Command -Session $Session -ScriptBlock {Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, version}
				} catch {Write-Warning "Error: Cant collect data from $($Computer) with logged in account -  Message:$($Error[0])"}
			}
			if (-not([string]::IsNullOrEmpty($RawData))) {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Adding to the object"
				$RawData | ForEach-Object {
					$NetObject.Add([PSCustomObject]@{
							ComputerName = $_.PSComputerName
							DotNet       = $_.PSChildName
							Version      = $_.Version
						}) #PSList
				}
			}
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Done with computer $($Computer)"
		}
	}#Process
	End {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Creating reports"
		if ($Export -eq 'Host') {
			$NetObject
		} else {
			Write-PSReports -InputObject $NetObject -ReportTitle 'DotNet Versions' -Export $Export -ReportPath $ReportPath
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Done"
	}#End End
} #end Function
