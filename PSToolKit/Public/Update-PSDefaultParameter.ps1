
<#PSScriptInfo

.VERSION 0.1.0

.GUID 745c5792-4b26-4def-97eb-9440eb82597e

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
Created [17/08/2022_13:39] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Updates the $PSDefaultParameterValues variable 

#> 


<#
.SYNOPSIS
Updates the $PSDefaultParameterValues variable

.DESCRIPTION
Updates the $PSDefaultParameterValues variable, and saves it to your profile.

.PARAMETER Function
The function name to add, you can also add wildcards.

.PARAMETER Parameter
The Parameter in that function to add.

.PARAMETER value
Value of the parameter

.PARAMETER WriteToProfile
Also write the result to your profile.

.EXAMPLE
Update-PSDefaultParameter -Function Connect-VMWareCluster -Parameter vCenterIp -value '192.168.x.x' -WriteToProfile

#>
Function Update-PSDefaultParameter {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSDefaultParameter')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Function,
		[string]$Parameter,
		[string]$value,
		[switch]$WriteToProfile
	)
	$PSDefaultParameterValues.Add("$($Function):$($Parameter)", $($value))
	$PSDefaultParameterValues

	if ($WriteToProfile) {

		$ProfileAdd = [System.Collections.Generic.List[string]]::new()
		$ProfileAdd.Add('#region PSDefaultParameter')
		$PSDefaultParameterValues.GetEnumerator() | ForEach-Object {$ProfileAdd.Add("`$PSDefaultParameterValues[""$($_.Name)""] = ""$($_.Value)""")}
		$ProfileAdd.Add('#endregion PSDefaultParameter')

		$PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
		$PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
		$Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
		$files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
		foreach ($file in $files) {	
			$tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSDefaultParameter*'}
			$tmp | Set-Content -Path $file.FullName -Force
			Add-Content -Value $ProfileAdd -Path $file.FullName -Force -Encoding utf8
			Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
		}



	}
		
} #end Function
