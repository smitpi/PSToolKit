
<#PSScriptInfo

.VERSION 0.1.0

.GUID 8185732b-f155-4d76-8ae7-52c747814203

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
Created [30/03/2022_14:30] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION 
 Reset gallery to degault settings 

#> 


<#
.SYNOPSIS
Reset gallery to degault settings

.DESCRIPTION
Reset gallery to degault settings

.EXAMPLE
Reset-PSGallery

#>
Function Reset-PSGallery {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Reset-PSGallery")]
	    [OutputType([System.Object[]])]
                PARAM(
					[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
            						else {Throw "Must be running an elevated prompt to use ClearARPCache"}})]
        			[switch]$Force
				)


				
} #end Function
