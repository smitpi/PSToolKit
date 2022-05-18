
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7ee9d10b-1bb3-450a-9d4d-b59a19d0995e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ctx

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [18/05/2022_01:38] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Export Citrix Policies 

#> 


<#
.SYNOPSIS
Export Citrix Policies

.DESCRIPTION
Export Citrix Policies

.EXAMPLE
Get-CitrixPolicies

#>
Function Get-CitrixPolicies {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Get-CitrixPolicies")]
	    [OutputType([System.Object[]])]
                PARAM(
					[Parameter(Mandatory = $true)]
					[Parameter(ParameterSetName = 'Set1')]
					[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".csv") })]
					[System.IO.FileInfo]$InputObject = "c:\temp\tmp.csv",

					[ValidateSet('Excel', 'HTML')]
					[string]$Export = 'Host',

                	[ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                	[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
					)



	if ($Export -eq 'Excel') { $data | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixPolicies -AutoSize -AutoFilter -Title CitrixPolicies -TitleBold -TitleSize 28}
	if ($Export -eq 'HTML') { $data | Out-GridHtml -DisablePaging -Title "CitrixPolicies" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $data }


} #end Function
