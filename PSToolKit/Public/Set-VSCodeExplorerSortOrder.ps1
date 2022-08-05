
<#PSScriptInfo

.VERSION 0.1.0

.GUID 84df74b9-a7a9-4c9d-91a4-ef448603eaf2

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
Created [05/08/2022_21:34] Initial Script Creating

.PRIVATEDATA

#>



<#

.DESCRIPTION
 Change the sort order in VSCode explorer

#>




<#
.SYNOPSIS
Change the sort order in VSCode explorer

.DESCRIPTION
Change the sort order in VSCode explorer

.PARAMETER SetToDefault
Set it to default

.PARAMETER SetToModified
Set it to modified.

.EXAMPLE
Set-VSCodeExplorerSortOrder -SetToModified

#>
Function Set-VSCodeExplorerSortOrder {
	[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSToolKit/Set-VSCodeExplorerSortOrder')]
	[Alias('setcode')]
	PARAM(
		[switch]$SetToDefault,
		[switch]$SetToModified
	)

	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
		try {
			$CodePath = (Get-Process *code*)[0].CommandLine.split('--')[0].Replace('"', $null) | Get-Item -ErrorAction Stop
			$settingsfile = Get-Item (Join-Path -Path $CodePath.DirectoryName -ChildPath '\data\user-data\User\settings.json') -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$CurrentSetting = Select-String -Path $settingsfile -Pattern '"explorer.sortOrder"'
		Write-PSToolKitMessage -Action 'Current' -Object 'Settings Set To:' -Message $CurrentSetting.Line.Trim()

		try {
			if ($SetToDefault) {(Get-Content -Path $settingsfile -Force -ErrorAction Stop) -replace '"explorer.sortOrder": "modified"', '"explorer.sortOrder": "default"' | Set-Content $settingsfile -Force -ErrorAction Stop}
			if ($SetToModified) {(Get-Content -Path $settingsfile -Force -ErrorAction Stop) -replace '"explorer.sortOrder": "default"', '"explorer.sortOrder": "modified"' | Set-Content $settingsfile -Force -ErrorAction Stop}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$NewSetting = Select-String -Path $settingsfile -Pattern '"explorer.sortOrder"'
		Write-PSToolKitMessage -Action 'New' -Object 'Settings Set To:' -Message $NewSetting.Line.Trim()

	}
} #end Function
