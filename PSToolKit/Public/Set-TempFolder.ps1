
<#PSScriptInfo

.VERSION 0.1.0

.GUID 5e1e0ce1-7f14-481d-874d-92129946bd5d

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
Set all the temp environmental variables to c:\temp

#>

<#
.SYNOPSIS
Set all the temp environmental variables to c:\temp

.DESCRIPTION
Set all the temp environmental variables to c:\temp

.EXAMPLE
Set-TempFolder

#>
function Set-TempFolder {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-TempFolder')]
	PARAM()

	Write-Host 'Setting temp folder: ' -ForegroundColor Cyan -NoNewline

	$TempFolder = 'C:\TEMP'
	if (!(Test-Path $TempFolder)) {	New-Item -ItemType Directory -Force -Path $TempFolder }
	[Environment]::SetEnvironmentVariable('TEMP', $TempFolder, [EnvironmentVariableTarget]::Machine)
	[Environment]::SetEnvironmentVariable('TMP', $TempFolder, [EnvironmentVariableTarget]::Machine)
	[Environment]::SetEnvironmentVariable('TEMP', $TempFolder, [EnvironmentVariableTarget]::User)
	[Environment]::SetEnvironmentVariable('TMP', $TempFolder, [EnvironmentVariableTarget]::User)

	Write-Host 'Complete' -ForegroundColor Green
}
