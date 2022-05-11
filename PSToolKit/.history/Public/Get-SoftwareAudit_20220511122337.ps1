
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

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

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
Name of the computers that will be audited

.PARAMETER Export
Export the results to excel or html

.PARAMETER ReportPath
Path to save the report.

.EXAMPLE
Get-SoftwareAudit -ComputerName Neptune -Export Excel

#>
Function Get-SoftwareAudit {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SoftwareAudit')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = 'Set1')]
		[string[]]$ComputerName,
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $false)]
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[string]$ReportPath = "$env:TEMP"
	)
	[System.Collections.ArrayList]$Software = @()
	foreach ($CompName in $ComputerName) {
		try {
			
		}
		try {
			$rawdata = Invoke-Command -ComputerName $CompName -ScriptBlock {
				Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
				Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
			}
			foreach ($item in $rawdata) {
				if (-not($null -eq $item.DisplayName)) {
					[void]$Software.Add([pscustomobject]@{
						CompName        = $($item.PSComputerName)
						DisplayName     = $item.DisplayName
						DisplayVersion  = $item.DisplayVersion
						Publisher       = $item.Publisher
						EstimatedSize   = [Decimal]::Round([int]$item.EstimatedSize / 1024, 2)
						UninstallString = $item.UninstallString
					})
				}
			}
		}
		catch { Write-Warning "Error: $($_.Exception.Message)" }
	}
	if ($Export -eq 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\SoftwareAudit-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$Software | Export-Excel -Title SoftwareAudit -WorksheetName SoftwareAudit @ExcelOptions
	}
	if ($Export -eq 'HTML') { $Software | Out-HtmlView -DisablePaging -Title 'SoftwareAudit' -HideFooter -SearchHighlight -FixedHeader }
	if ($Export -eq 'Host') { $Software }
} #end Function