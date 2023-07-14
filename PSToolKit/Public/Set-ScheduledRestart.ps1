
<#PSScriptInfo

.VERSION 0.1.0

.GUID ff237c2f-c2b6-4747-a8b4-82718a2bc97a

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [13/07/2023_12:24] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Create a scheduled task to reboot a server 

#> 

<#
.SYNOPSIS
Create a scheduled task to reboot a server.

.DESCRIPTION
Create a scheduled task to reboot a server.

.PARAMETER ComputerName
List of servers to reboot.

.PARAMETER Credential
Credentials to connect to the server, if needed.

.PARAMETER RebootDate
The date and time to run the reboot.

.EXAMPLE
Set-ScheduledRestart -ComputerName $Env:COMPUTERNAME -Credential $admin -RebootDate $date

#>
Function Set-ScheduledRestart {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-ScheduledRestart')]
	[OutputType([System.Object[]])]
	#region Parameter
	PARAM(
		[Parameter(Position = 0, Mandatory, ParameterSetName = 'Set1', HelpMessage = 'Specify the name of a remote computer. The default is the local host.')]
		[alias('CN', 'host')]
		[ValidateNotNullorEmpty()]
		[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
				else {throw "Unable to connect to $($_)"} })]
		[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
				else {Throw 'Must be running an elevated prompt to use this function'}})]
		[string[]]$ComputerName,
		[pscredential]$Credential,
		[datetime]$RebootDate
	)
	#endregion
	foreach ($server in $ComputerName) {
		try {
			if ($PSBoundParameters.ContainsKey('Credential')) {
				$session = New-PSSession -ComputerName $server -Credential $Credential
			} else {
				$session = New-PSSession -ComputerName $server
			}
		} catch {Write-Warning "Error: Message:$($Error[0])"}

		Invoke-Command -Session $session -ScriptBlock {
			Get-ScheduledTask -TaskName 'Forced Reboot*' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
				
			$trigger = New-ScheduledTaskTrigger -Once -At $using:RebootDate
			$principal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount

			$taskActionSettings = @{
				Execute  = 'shutdown.exe'
				Argument = '/r /f /t 0'
			}

			$TaskAction = New-ScheduledTaskAction @taskActionSettings
			$TaskSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -Priority 0 -DontStopIfGoingOnBatteries 
			$NewTask = New-ScheduledTask -Action $TaskAction -Principal $principal -Trigger $trigger -Settings $TaskSettings
			Register-ScheduledTask -TaskName "Forced Reboot by $(whoami -upn)" -InputObject $NewTask -Force
		}
	}
} #end Function
