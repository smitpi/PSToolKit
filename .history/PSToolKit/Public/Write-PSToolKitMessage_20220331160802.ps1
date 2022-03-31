
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

.EXAMPLE
Write-PSToolKitMessage

#>
Function Write-PSToolKitMessage {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Write-PSToolKitMessage")]
	    [OutputType([System.Object[]])]
                PARAM(
					[ValidateSet('Starting', 'Getting', 'Copying', 'Moving','Complete','Deleting','Changing','Failed','Exists')]
					[string]$Action,
					[ValidateSet('Information', 'Warning', 'Error')]
					[string]$Severity,
					[string[]]$Object,
					[string[]]$Message
				)
				if ($Severity -like "Warning") {Write-Color "[$($Severity)]","[$($Action)]"," $Object ","$Message" -Color Yellow,Yellow,Cyan,DarkGray }
				elseif ($Severity -like "Error") {Write-Color "[$($Severity)]","[$($Action)]"," $Object ","$Message" -Color Red,Yellow,Cyan,DarkGray }
				elseif ($Action -like 'Exists') {Write-Color "[$($Severity)]","[$($Action)]"," $Object ","$Message" -Color DarkCyan,Yellow,Cyan,DarkRed}
				elseif ($Action -like 'Failed') {Write-Color "[$($Severity)]","[$($Action)]"," $Object ","$Message" -Color Red,Yellow,Cyan,DarkRed}
				else {Write-Color "[$($Severity)]","[$($Action)]"," $Object ","$Message" -Color DarkCyan,Yellow,Cyan }


} #end Function
