
<#PSScriptInfo

.VERSION 0.1.0

.GUID 5a169afc-02aa-4035-b8ca-e00c862c219e

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
Created [05/08/2022_23:44] Initial Script Creating

.PRIVATEDATA

#>



<#

.DESCRIPTION
 Starts a porwershell session as an administrator

#>


<#
.SYNOPSIS
Starts a porwershell session as an administrator

.DESCRIPTION
Starts a porwershell session as an administrator

.PARAMETER WindowsPowerShell
Start powershell 5.1 session. Default is a Powershell 7 session.

.PARAMETER ISE
Start a powershell ISE session.

.PARAMETER Credential
Run session as a different user.

.EXAMPLE
An example

.NOTES
General notes
#>
Function Start-PowerShellAsAdmin {
	[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PowerShellAsAdmin')]
	[OutputType([void])]
	PARAM(
		[switch]$WindowsPowerShell,
		[switch]$ISE,
		[pscredential]$Credential
	)

	$Currentdir = Get-Location
	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
		if ($WindowsPowerShell) {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath powershell.exe -ArgumentList "-noexit -command & {set-location $($currentdir)}" -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath powershell.exe -ArgumentList "-command & {Start-Process -FilePath powershell.exe -ArgumentList `"-noexit`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		} elseif ($ISE) {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe' -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath powershell.exe -ArgumentList "-command & {Start-Process -FilePath `"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		} else {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath pwsh.exe -ArgumentList "-noexit -command & {set-location $($currentdir)}" -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath pwsh.exe -ArgumentList "-command & {Start-Process -FilePath pwsh.exe -ArgumentList `"-noexit`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		}
	}
} #end Function
