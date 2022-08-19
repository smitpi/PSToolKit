
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
Message to display. This can be an array of strings as well, to have different colours in the text.+

.PARAMETER MessageColor
The Colour of the corresponding message in the array.

.PARAMETER InsertTabs
Insert tabs before writing the text.

.PARAMETER NoNewLine
Wont add a new line after writing to screen.

.EXAMPLE
Write-PSToolKitMessage -Action Getting -Severity Information -Object (get-item .) -Message "This is","the directory","you are in." -MessageColor Cyan,DarkGreen,DarkRed

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
		[Parameter(Position = 3)]
		[string[]]$Message,
		[ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGrey', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]
		[Parameter(Position = 4)]
		[string[]]$MessageColor,
		[Parameter(Position = 6)]
		[int]$InsertTabs = 0,
		[Parameter(Position = 6)]
		[switch]$NoNewLine = $false
	)

	process {
		if ($InsertTabs -ne 0) {
			0..$InsertTabs | ForEach-Object {Write-Host "`t" -NoNewline}
		}
	
		if ($Severity -like 'Warning') {
			Write-Host 'WARNING - ' -ForegroundColor Yellow -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} elseif ($Severity -like 'Error') {
			Write-Host 'ERROR - ' -ForegroundColor Red -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} else {
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		}
		0..($Message.Count - 1) | ForEach-Object {
			Write-Host "$($Message[$_]) " -ForegroundColor $MessageColor[$_] -NoNewline
		}
		if (-not($NoNewLine)) {
			Write-Host ''
		}

	}
} #end Function
$scriptblock = {
	@('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists')
}
Register-ArgumentCompleter -CommandName Write-PSToolKitMessage -ParameterName Action -ScriptBlock $scriptBlock

