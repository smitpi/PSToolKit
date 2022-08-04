
<#PSScriptInfo

.VERSION 0.1.0

.GUID 31df1f87-a5fb-40dc-87b5-6aea00de4b77

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
Created [04/08/2022_16:37] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Move modules from current user to all users

#>


<#
.SYNOPSIS
Move modules from current user to all users

.DESCRIPTION
Move modules from current user to all users

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Move-ModulesToAllUser -Export HTML -ReportPath C:\temp

#>
Function Move-ModulesToAllUser {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Move-ModulesToAllUser')]
	[OutputType([System.Object[]])]
	PARAM(
	)

	$ModulePaths = $env:PSModulePath.split(';')

	$ModulePaths | Where-Object {$_ -notlike '*program*' -and $_ -notlike '*system*'}

	$PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell', 'Modules')
	$PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell', 'Modules')

	foreach ($ModPath in @($PersonalPowerShell, $PersonalWindowsPowerShell)) {
		if (Test-Path $ModPath) {
			Get-ChildItem $ModPath -Directory | ForEach-Object {
				[]

			}


			$ModuleVer
			foreach ($mod in $modules) {
				Write-PSToolKitMessage -Action Copying -Severity Information -Object $mod.Name -Message "from $($ModPath)"
				Copy-Item -Path "$($mod.FullName)" -Destination C:\Temp\test -Force -Recurse
				Write-PSToolKitMessage -Action Deleting -Severity Information -Object $mod.Name -Message "from $($ModPath)"
				try {
					Get-ChildItem -Path "$($mod.FullName)\*" | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction Stop
					Remove-Item $mod.FullName
				} catch {
					Start-Sleep 2
					Get-ChildItem -Path "$($mod.FullName)\*" | Remove-Item -Recurse -Force -Confirm:$false
					Remove-Item $mod.FullName
				}
			}
		}
	}

} #end Function
