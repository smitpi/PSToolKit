
<#PSScriptInfo

.VERSION 0.1.0

.GUID a382f6f9-c1be-456f-834e-01bf03defe6b

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
Created [30/06/2023_08:17] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Show installed module list grouped by install path. 

#> 


<#
.SYNOPSIS
Show installed module list grouped by install path.

.DESCRIPTION
Show installed module list grouped by install path.

.PARAMETER Export
Export result to Excel or HTML.

.PARAMETER ReportPath
Where to save the report.

.PARAMETER OpenReportsFolder
Open the folder after creation.

.EXAMPLE
Show-ModulePathList -Export HTML -ReportPath C:\temp

#>
Function Show-ModulePathList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-ModulePathList')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
		[string[]]$Export = 'Host',

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
		[switch]$OpenReportsFolder
	)
	#endregion
	[string[]]$Modpaths = ($env:PSModulePath).Split(';')
	$AvailableModules = Get-Module -ListAvailable
	[System.Collections.ArrayList]$ModuleDetails = @()
	$ModuleDetails = $Modpaths | ForEach-Object {
		$Mpath = $_
		[pscustomobject]@{
			Location = $Mpath
			Modules  = ($AvailableModules | Where-Object { $_.path -match $Mpath.replace('\', '\\') } ).count
		}
	}

	if ($Export -eq 'Host') {$ModuleDetails}
	else {Write-PSReports -InputObject $ModuleDetails -ReportTitle 'Installed Modules' -Export $Export -ReportPath $ReportPath }
} #end Function
