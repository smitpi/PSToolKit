
<#PSScriptInfo

.VERSION 0.1.0

.GUID 9ba7b261-958d-40b0-ae6a-e67f7083e506

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
Created [30/03/2022_14:41] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Install vmware tools from chocolatety 

#> 


<#
.SYNOPSIS
Install vmware tools from chocolatety

.DESCRIPTION
Install vmware tools from chocolatety

.EXAMPLE
Install-VMWareTools

#>
Function Install-VMWareTools {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-VMWareTools")]
	    [OutputType([System.Object[]])]
                PARAM(
					[Parameter(Mandatory = $true)]
					[Parameter(ParameterSetName = 'Set1')]
					[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".csv") })]
					[System.IO.FileInfo]$InputObject = "c:\temp\tmp.csv",
					[ValidateNotNullOrEmpty()]
					[string]$Username,
					[ValidateSet('Excel', 'HTML')]
					[string]$Export = 'Host',
                	[ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                	[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
					[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
            						else {Throw "Must be running an elevated prompt to use ClearARPCache"}})]
        			[switch]$ClearARPCache,
        			[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                            		else {throw "Unable to connect to $($_)"} })]
        			[string[]]$ComputerName
					)



	if ($Export -eq 'Excel') { $data | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\VMWareTools-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $data | Out-GridHtml -DisablePaging -Title "VMWareTools" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\VMWareTools-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $data }


} #end Function
