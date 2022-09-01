
<#PSScriptInfo

.VERSION 0.1.0

.GUID bd5645e4-e07a-4668-aad8-7d3341bdaca2

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


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
Message to display. This can be an array of strings as well, to have different colors in the text.

.PARAMETER MessageColor
The Colour of the corresponding message in the array.

.PARAMETER InsertTabs
Insert tabs before writing the text.

.PARAMETER NoNewLine
Wont add a new line after writing to screen.

.EXAMPLE
Write-Message -Action Getting -Severity Information -Object (get-item .) -Message "This is","the directory","you are in." -MessageColor Cyan,DarkGreen,DarkRed

#>
Function Write-Message {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitMessage')]
	[Alias('Write-PSToolKitMessage')]
	[OutputType([string[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[string]$Action,
		[ValidateSet('Information', 'Warning', 'Error')]
		[string]$Severity = 'Information',
		[Parameter(ValueFromPipeline = $true, ValueFromRemainingArguments = $false)]
		[string[]]$Object,
		[string[]]$Message,
		[ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGrey', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]
		[string[]]$MessageColor,
		[int]$InsertTabs = 0,
		[switch]$NoNewLine = $false
	)
	process {
		if ($InsertTabs -ne 0) {
			0..$InsertTabs | ForEach-Object {Write-Host "`t" -NoNewline}
		}
	
		if ($Severity -like 'Warning') {
			Write-Host 'WARNING - ' -ForegroundColor Yellow -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} elseif ($Severity -like 'Error') {
			Write-Host 'ERROR - ' -ForegroundColor Red -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} else {
			Write-Host "[$(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		}
		0..($Message.Count - 1) | ForEach-Object {
			if ([string]::IsNullOrEmpty($MessageColor[$_])) {$cl = 'Grey'}
			else {$cl = $MessageColor[$_]}

			Write-Host "$($Message[$_]) " -ForegroundColor $cl -NoNewline
		}
		if (-not($NoNewLine)) {
			Write-Host ''
		}

	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$Action = @('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists') 
	$action | Where-Object {$_ -like "$wordToComplete*"} 
}
Register-ArgumentCompleter -CommandName Write-Message -ParameterName Action -ScriptBlock $scriptBlock
