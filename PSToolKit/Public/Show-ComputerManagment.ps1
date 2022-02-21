
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
 Opens the Computer Managment of the system or remote system 

#> 


<#
.SYNOPSIS
Opens the Computer Managment of the system or remote system

.DESCRIPTION
Opens the Computer Managment of the system or remote system

.EXAMPLE
Show-ComputerManagment

#>
Function Show-ComputerManagment {
	[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Show-ComputerManagment")]
                PARAM(
        			[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                            		else {throw "Unable to connect to $($_)"} })]
        			[string[]]$ComputerName = $env:ComputerName
					)
    compmgmt.msc /computer:$ComputerName
} #end Function
