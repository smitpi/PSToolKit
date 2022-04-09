
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

.EXAMPLE
dir | Write-PSToolKitMessage -Action Exists -Severity Information -Message 'its already there'

#>
Function Write-PSToolKitMessage {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitMessage')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists')]
		[string]$Action,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateSet('Information', 'Warning', 'Error')]
		[string]$Severity,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $false, Position = 2)]
		[string[]]$Object,
		[Parameter(Mandatory = $true, Position = 3)]
		[string[]]$Message
	)

	process {
		if ($Severity -like 'Warning') {Write-Color "[$($Severity)]", "[$($Action)]", " $Object ", "$Message" -Color Yellow, Yellow, Cyan, DarkGray -ShowTime }
		elseif ($Severity -like 'Error') {Write-Color "[$($Severity)]", "[$($Action)]", " $Object ", "$Message" -Color Red, Yellow, Cyan, DarkGray -ShowTime }
		elseif ($Action -like 'Exists') {Write-Color "[$($Severity)]", "[$($Action)]", " $Object ", "$Message" -Color DarkCyan, Yellow, Cyan, DarkRed -ShowTime}
		elseif ($Action -like 'Failed') {Write-Color "[$($Severity)]", "[$($Action)]", " $Object ", "$Message" -Color Red, Yellow, Cyan, DarkRed -ShowTime}
		else {Write-Color "[$($Severity)]", "[$($Action)]", " $Object ", "$Message" -Color DarkCyan, Yellow, Cyan, Green -ShowTime }

	}
} #end Function
