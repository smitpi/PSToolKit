
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7f39cc38-d7fc-45fa-a6ea-2d2057e35f4d

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
Created [29/11/2022_07:26] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 decode a URL 

#> 


<#
.SYNOPSIS
decode a URL

.DESCRIPTION
decode a URL

.PARAMETER URL
The URL to decode.

.EXAMPLE
Disable-WebEncoding -Export HTML -ReportPath C:\temp

#>
Function Disable-WebEncoding {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Disable-WebEncoding')]
	[OutputType([System.String])]
 #region Parameter
	PARAM(
		[Parameter(Mandatory, ValueFromPipeline, Position = 0)]
		[string[]]$URL
	)
	#endregion
	Begin {
		Write-Verbose '[07:26:07 BEGIN] Starting New-PSScript'
	}#Begin
	Process {
		foreach ($ur in $URL) {
			[System.Web.HttpUtility]::UrlDecode($ur) 
		}
	}#Process
	End {

		Write-Verbose '[07:26:07 END] Complete'
	}#End
} #end Function