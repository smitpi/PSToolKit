
<#PSScriptInfo

.VERSION 0.1.0

.GUID 723363ca-f4cc-42b5-9e51-2321a1d48af7

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
Created [30/11/2023_08:14] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 List all the installed versions of .net 

#> 


<#
.SYNOPSIS
List all the installed versions of .net

.DESCRIPTION
List all the installed versions of .net

.EXAMPLE
Get-DotNetVersions -Export HTML -ReportPath C:\temp

#>
Function Get-DotNetVersions {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Get-DotNetVersions")]
	    [OutputType([System.Object[]])]
                #region Parameter
                PARAM(
                    [Parameter(Mandatory,ValueFromPipeline)]
					[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
									else {throw "Unable to connect to $($_)"} })]
					[string[]]$ComputerName,

					[pscredential]$Credentials,
					[ValidateSet('All', 'Excel', 'HTML', 'HTML5')]
					[string[]]$Export = 'Host',

					[ValidateScript( { if (Test-Path $_) { $true }
                                else { Write-Warning "Folder does not exist, creating folder now."
                                New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                    })]
					[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
					[switch]$OpenReportsFolder
				)
                #endregion
    Begin {
		Write-Verbose "[08:14:58 BEGIN] Starting New-PSScript"

    } #End Begin Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Select PSChildName, version
    Process {
    
    }#Process
    End {
		Write-Verbose "[08:14:58 END] Complete"
    }#End End
} #end Function
