
<#PSScriptInfo

.VERSION 0.1.0

.GUID 02f4d85e-94f6-4d1c-aa34-b4fbbc44f0f9

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
Citrix policy export

#>


<#
.SYNOPSIS
Citrix policy export.

.DESCRIPTION
Citrix policy export. Run it from the DDC.

.PARAMETER FormatTable
Display as a table

.PARAMETER ExportToExcel
Export output to excel

.PARAMETER ReportPath
Path to where it will be saved

.PARAMETER ReportName
Name of the report

.EXAMPLE
Export-CitrixPolicySettings -FormatTable
#>
Function Export-CitrixPolicySetting {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-CitrixPolicySettings')]
	[OutputType([System.Object[]])]
	PARAM(
		[switch]$FormatTable = $false,
		[switch]$ExportToExcel = $false,
		[string]$ReportPath = $env:TMP,
		[string]$ReportName)


	if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
		Import-Module Citrix.GroupPolicy.Commands
		if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
			Write-Error 'Unable to find module'
			break
		}
	}

	New-PSDrive -Name LocalFarmGpo -PSProvider CitrixGroupPolicy -controller $env:COMPUTERNAME \
	[ArrayList]$TMPPolobject = @()
	$settingdetail = Get-CtxGroupPolicyConfiguration -PolicyName *
	$settingdetail | ForEach-Object {
		$item = $_
		$item | Get-Member -MemberType NoteProperty | Where-Object { $_.definition -like '*PSCustomObject*' } | ForEach-Object {
			$PolObject += [PSCustomObject]@{
				PolicyName   = $item.PolicyName
				PolicyType   = $item.Type
				SettingPath  = $item.($_.name).Path
				SettingName  = $_.name
				SettingState = $item.($_.name).state
				SettingValue = $item.($_.name).Value
			}

		}
	}
	$Polobject | Where-Object {$_.SettingState -notlike 'NotConfigured'}
	if ($FormatTable -eq $true) { $Polobject | Format-Table -AutoSize }
	else { $Polobject }


	if ($ExportToExcel -eq $true) {
		if ((Test-Path $ReportPath) -eq $true) {
			$pol = [IO.Path]::Combine($ReportPath, "$ReportName.xlsx")
			$PolObject | Export-Excel -Path $pol -Title 'Citrix Policies' -TitleBold -TitleSize 20 -AutoSize -AutoFilter -TitleFillPattern DarkGray
		}
		else { Write-Warning 'Invalid Path'; break }
 }



} #end Function