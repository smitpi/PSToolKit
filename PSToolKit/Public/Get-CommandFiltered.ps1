
<#PSScriptInfo

.VERSION 0.1.0

.GUID 5b6d4a45-e643-4740-8b74-b2648d4f2db9

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
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Finds commands on the system and sort it according to module

#>


<#
.SYNOPSIS
Finds commands on the system and sort it according to module

.DESCRIPTION
Finds commands on the system and sort it according to module

.PARAMETER Filter
Limit search

.PARAMETER PSToolKit
Limit search to the PSToolKit Module

.PARAMETER PrettyAnswer
Display results with color, but runs slow.

.EXAMPLE
Get-CommandFiltered -Filter help

.NOTES
General notes
#>
Function Get-CommandFiltered {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-CommandFiltered')]
	[Alias('fcmd')]
	PARAM(
		[string]$Filter,
		[switch]$PSToolKit = $false,
		[switch]$PrettyAnswer = $false
	)
	$Filtered = '*' + $Filter + '*'
	if ($PSToolKit) {Get-Command $Filtered -Module PSToolKit}
	else {
		$cmd = Get-Command $Filtered | Sort-Object -Property Source
		if ($PrettyAnswer) {
			foreach ($item in ($cmd.Source | Sort-Object -Unique)) {
				$commands = @()
				Write-Color -Text 'Module: ', $($item) -Color Cyan, Red -StartTab 2
				$cmd | Where-Object { $_.Source -like $item } | ForEach-Object {
					$commands += [pscustomobject]@{
						Name        = $_.Name
						Module      = $_.Module
						CommandType = $_.CommandType
						Source      = $_.Source
						Description = ((Get-Help $_.Name).description | Out-String).Trim()
					}
				}
				$commands | Format-Table -AutoSize | Out-More
			}
		} else { $cmd }
	}
} #end Function
New-Alias -Name fcmd -Value Get-CommandFiltered -Description 'Filter Get-command with keyword' -Option AllScope -Scope global -Force
