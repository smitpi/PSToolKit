
<#PSScriptInfo

.VERSION 0.1.0

.GUID e8c06a12-88f4-4244-9c49-e99c0d4ebb04

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
enable ps remote remotely

#>


<#
.SYNOPSIS
enable ps remote remotely

.DESCRIPTION
enable ps remote remotely

.PARAMETER ComputerName
The remote computer

.PARAMETER AdminCredentials
Credentials with admin access

.EXAMPLE
Enable-RemoteHostPSRemoting -ComputerName $host -AdminCredentials $cred

.NOTES
General notes
#>
Function Enable-RemoteHostPSRemoting {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Enable-RemoteHostPSRemoting')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript( { (Test-Connection -ComputerName $_ -Count 1 -Quiet) })]
		[string]$ComputerName,
		[pscredential]$AdminCredentials = (Get-Credential)
	)

	#.\psexec.exe \ServerB -h -s powershell.exe Enable-PSRemoting -Force
	$SessionArgs = @{
		ComputerName  = $ComputerName
		Credential    = $AdminCredentials
		SessionOption = New-CimSessionOption -Protocol Dcom
	}
	$MethodArgs = @{
		ClassName  = 'Win32_Process'
		MethodName = 'Create'
		CimSession = New-CimSession @SessionArgs
		Arguments  = @{
			CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force'"
		}
	}
	Invoke-CimMethod @MethodArgs
	Test-PSRemote -ComputerName $ComputerName -Credential $AdminCredentials
} #end Function
