
<#PSScriptInfo

.VERSION 0.1.0

.GUID 336baad7-2b77-4968-b277-edc24d0f0f9b

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
Export all VM Templates from vSphere to local disk.

#>


<#
.SYNOPSIS
Export all VM Templates from vSphere to local disk.

.DESCRIPTION
Export all VM Templates from vSphere to local disk.

.PARAMETER ExportPath
Directory to export to

.EXAMPLE
Export-ESXTemplates -ExportPath c:\temp
#>
Function Export-ESXTemplates {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-ESXTemplates')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript( { (Test-Path $_) })]
		[System.IO.DirectoryInfo]$ExportPath)


	Get-Template | Sort-Object -Unique | ForEach-Object {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Exporting Template: $($_.name)"

		$template = Get-Template -Name $_.Name | Sort-Object -Unique
		$templatevm = Set-Template -Template $template -ToVM
		Get-Snapshot $templatevm | Remove-Snapshot -Confirm:$false
		$templatevm | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
		$templatevm | Export-VApp -Destination $ExportPath -Format Ova -Name $templatevm.Name -Force
		Get-VM $templatevm | Set-VM -ToTemplate -Name $template.Name -Confirm:$false
	}




} #end Function
