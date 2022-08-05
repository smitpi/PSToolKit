
<#PSScriptInfo

.VERSION 0.1.0

.GUID e39cae70-8c24-4740-9971-494b0c4cbcb0

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
Created [31/03/2022_15:53] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Writes the given into to screen

#>

<#
.SYNOPSIS
Writes the given into to screen

.DESCRIPTION
Writes the given into to screen

.PARAMETER Action
Action for the object.

.PARAMETER Severity
Severity of the entry.

.PARAMETER Object
The object to be reported on.

.PARAMETER Message
The Details.

.PARAMETER Object2
The second object to be reported on.

.PARAMETER Message2
The second message Details.

.EXAMPLE
dir | Write-PSToolKitMessage -Action Exists -Severity Information -Message 'its already there'

#>
Function Write-PSToolKitMessage {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitMessage')]
	[OutputType([System.Object[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$Action,
		[Parameter(Position = 1)]
		[ValidateSet('Information', 'Warning', 'Error')]
		[string]$Severity = 'Information',
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $false, Position = 2)]
		[string[]]$Object,
		[Parameter(Mandatory = $true, Position = 3)]
		[string[]]$Message,
		[Parameter(Position = 4)]
		[string[]]$Object2,
		[Parameter(Position = 5)]
		[string[]]$Message2
	)

	process {
		if ($Severity -like 'Warning') {
			Write-Host 'WARNING - ' -ForegroundColor Yellow -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message) " -ForegroundColor DarkGray -NoNewline
			Write-Host "$($Object2) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message2) " -ForegroundColor DarkGray
		} elseif ($Severity -like 'Error') {
			Write-Host 'ERROR - ' -ForegroundColor Red -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message) " -ForegroundColor DarkGray -NoNewline
			Write-Host "$($Object2) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message2) " -ForegroundColor DarkGray
		} else {
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message) " -ForegroundColor DarkGray -NoNewline
			Write-Host "$($Object2) " -ForegroundColor Cyan -NoNewline
			Write-Host "$($Message2) " -ForegroundColor DarkGray

		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
	}
} #end Function


$scriptblock = {
	@('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists')
}
Register-ArgumentCompleter -CommandName Write-PSToolKitMessage -ParameterName Action -ScriptBlock $scriptBlock

