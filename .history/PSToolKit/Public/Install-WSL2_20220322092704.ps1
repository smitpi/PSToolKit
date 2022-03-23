
<#PSScriptInfo

.VERSION 0.1.0

.GUID 62b9e7e7-90c0-4f13-902d-79818c2cdb3f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [22/03/2022_09:27] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Enable Windows-Subsystem-Linux 

#> 


<#
.SYNOPSIS
Enable Windows-Subsystem-Linux

.DESCRIPTION
Enable Windows-Subsystem-Linux

.EXAMPLE
Install-WSL2

#>
Function Install-WSL2 {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-WSL2")]
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



	if ($Export -eq 'Excel') { $data | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\WSL2-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $data | Out-GridHtml -DisablePaging -Title "WSL2" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\WSL2-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $data }


} #end Function
