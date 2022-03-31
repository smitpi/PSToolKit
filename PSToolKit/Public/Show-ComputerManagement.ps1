
<#PSScriptInfo

.VERSION 0.1.0

.GUID d54363b7-1ec8-444f-8667-b56d9f90ec1f

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
Created [20/02/2022_22:02] Initial Script Creating

.PRIVATEDATA

#>



<#

.DESCRIPTION
 Opens the Computer Management of the system or remote system

#>


<#
.SYNOPSIS
Opens the Computer Management of the system or remote system

.DESCRIPTION
Opens the Computer Management of the system or remote system

.PARAMETER ComputerName
Computer to Manage

.EXAMPLE
Show-ComputerManagement -ComputerName neptune

#>
Function Show-ComputerManagement {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-ComputerManagement')]
                PARAM(
        			[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                            		else {throw "Unable to connect to $($_)"} })]
        			[string[]]$ComputerName = $env:ComputerName
					)
    compmgmt.msc /computer:$ComputerName
} #end Function
