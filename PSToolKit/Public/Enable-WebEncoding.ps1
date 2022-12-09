
<#PSScriptInfo

.VERSION 0.1.0

.GUID dbe85d8c-51ca-440c-986b-c2705b35169f

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
 encode a url 

#> 


<#
.SYNOPSIS
encode a URL

.DESCRIPTION
encode a URL

.PARAMETER URL
The URL to encode

.EXAMPLE
Enable-WebEncoding -Export HTML -ReportPath C:\temp

#>
Function Enable-WebEncoding {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Enable-WebEncoding')]
	[OutputType([System.Object[]])]
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
			[System.Web.HttpUtility]::UrlEncode($ur) 
		}
	}#Process
	End {
		Write-Verbose '[07:26:07 END] Complete'
	}#End
} #end Function
