
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

.PARAMETER BeforeMessage
Message to display before object. This can be an array of strings as well, to have different colors in the text.

.PARAMETER BeforeMessageColor
The Colour of the corresponding message in the array.

.PARAMETER AfterMessage
Message to display after object. This can be an array of strings as well, to have different colors in the text.

.PARAMETER AfterMessageColor
The Colour of the corresponding message in the array.

.PARAMETER InsertTabs
Insert tabs before writing the text.

.PARAMETER LinesBefore
Insert Blank Lines before Output.

.PARAMETER LinesAfter
Insert Blank Lines After Output.

.PARAMETER NoNewLine
Wont add a new line after writing to screen.

.EXAMPLE
Write-Message -Action Getting -Severity Information -Object (get-item .) -Message "This is","the directory","you are in." -MessageColor Cyan,DarkGreen,DarkRed

#>
Function Write-Message {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Write-Message')]
	[Alias('Write-Message')]
	[OutputType([string[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
	PARAM(
		[string]$Action,
		[ValidateSet('Information', 'Warning', 'Error')]
		[string]$Severity = 'Information',
		[string[]]$BeforeMessage,
		[ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGrey', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]
		[string[]]$BeforeMessageColor,
		[Parameter(ValueFromPipeline)]
		[string[]]$Object,
		[Alias ('Message')]
		[string[]]$AfterMessage,
		[ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGrey', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]
		[Alias ('MessageColor')]
		[string[]]$AfterMessageColor,
		[int]$InsertTabs = 0,
		[int]$LinesBefore = 0,
		[int]$LinesAfter = 0,
		[switch]$NoNewLine = $false
	)
	begin {
		if ($LinesBefore -ne 0) {
			0..$LinesBefore | ForEach-Object {Write-Host ' '}
		}

		if ($InsertTabs -ne 0) {
			0..$InsertTabs | ForEach-Object {Write-Host "`t" -NoNewline}
		}
	}
	process {
		if ($Severity -like 'Warning') {
			Write-Host 'WARNING - ' -ForegroundColor Yellow -NoNewline
			Write-Host "[$(Get-Date -Format yyyy-MM-dd) $(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			if ($action) {Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline}
			if ($BeforeMessage) {
				0..($BeforeMessage.Count - 1) | ForEach-Object {
					try {
						$number = $_
						Write-Host "$($BeforeMessage[$_]) " -ForegroundColor $BeforeMessageColor[$_] -NoNewline -ErrorAction Stop
					} catch {Write-Host "$($BeforeMessage[$number]) " -ForegroundColor Gray -NoNewline}
				}
			}
			if ($object) {Write-Host '[' -ForegroundColor Yellow -NoNewline; Write-Host "$($Object)" -ForegroundColor Cyan -NoNewline; Write-Host '] ' -ForegroundColor Yellow -NoNewline}
		} elseif ($Severity -like 'Error') {
			Write-Host 'ERROR - ' -ForegroundColor Red -NoNewline
			Write-Host "[$(Get-Date -Format yyyy-MM-dd) $(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			if ($action) {Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline}
			if ($BeforeMessage) {
				0..($BeforeMessage.Count - 1) | ForEach-Object {
					try {
						$number = $_
						Write-Host "$($BeforeMessage[$_]) " -ForegroundColor $BeforeMessageColor[$_] -NoNewline -ErrorAction Stop
					} catch {Write-Host "$($BeforeMessage[$number]) " -ForegroundColor Gray -NoNewline}
				}
			}
			if ($object) {Write-Host '[' -ForegroundColor Yellow -NoNewline; Write-Host "$($Object)" -ForegroundColor Cyan -NoNewline; Write-Host '] ' -ForegroundColor Yellow -NoNewline}
		} else {
			Write-Host "[$(Get-Date -Format yyyy-MM-dd) $(Get-Date -Format HH:mm:ss)] " -ForegroundColor Gray -NoNewline
			if ($action) {Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline}
			if ($BeforeMessage) {
				0..($BeforeMessage.Count - 1) | ForEach-Object {
					try {
						$number = $_
						Write-Host "$($BeforeMessage[$_]) " -ForegroundColor $BeforeMessageColor[$_] -NoNewline -ErrorAction Stop
					} catch {Write-Host "$($BeforeMessage[$number]) " -ForegroundColor Gray -NoNewline}
				}
			}
			if ($object) {Write-Host '[' -ForegroundColor Yellow -NoNewline; Write-Host "$($Object)" -ForegroundColor Cyan -NoNewline; Write-Host '] ' -ForegroundColor Yellow -NoNewline}
		}
		if ($AfterMessage) {
			0..($AfterMessage.Count - 1) | ForEach-Object {
				try {
					$number = $_
					Write-Host "$($AfterMessage[$_]) " -ForegroundColor $AfterMessageColor[$_] -NoNewline -ErrorAction Stop
				} catch {Write-Host "$($AfterMessage[$number]) " -ForegroundColor Gray -NoNewline}
			}
		}
		if (-not($NoNewLine)) {
			Write-Host ''
		}
	}
	end {
		if ($LinesAfter -ne 0) {
			0..$LinesAfter | ForEach-Object {Write-Host ' '}
		}
	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$Action = @('Starting', 'Getting', 'Installing', 'Copying', 'Moving', 'Complete', 'Deleting', 'Removing', 'Uninstalling', 'Changing', 'Failed', 'Exists', 'Disabling') 
	$action | Where-Object {$_ -like "$wordToComplete*"} 
}
Register-ArgumentCompleter -CommandName Write-Message -ParameterName Action -ScriptBlock $scriptBlock
