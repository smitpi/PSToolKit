
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

.PARAMETER Controller
Name of the DDC

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
					[string]$Controller,

					[ValidateSet('Excel', 'HTML')]
					[string]$Export = 'Host',

                	[ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                	[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
					)

	if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
		Import-Module Citrix.GroupPolicy.Commands
		if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
			Write-Error 'Unable to find module'
			break
		}
	}

	New-PSDrive -Name LocalFarmGpo -PSProvider CitrixGroupPolicy -controller $Controller \
	[ArrayList]$TMPPolobject = @()
	$settingdetail = Get-CtxGroupPolicyConfiguration -PolicyName *
	$settingdetail | ForEach-Object {
		$item = $_
		$item | Get-Member -MemberType NoteProperty | Where-Object { $_.definition -like '*PSCustomObject*' } | ForEach-Object {
			$TMPPolobject.add([PSCustomObject]@{
					PolicyName   = $item.PolicyName
					PolicyType   = $item.Type
					SettingPath  = $item.($_.name).Path
					SettingName  = $_.name
					SettingState = $item.($_.name).state
					SettingValue = $item.($_.name).Value
				})
		}
	}
	$Polobject = $TMPPolobject | Where-Object {$_.SettingState -notlike 'NotConfigured'}

	if ($Export -eq 'Excel') { $Polobject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixPolicies -AutoSize -AutoFilter -Title CitrixPolicies -TitleBold -TitleSize 28}
	if ($Export -eq 'HTML') { $Polobject | Out-GridHtml -DisablePaging -Title "CitrixPolicies" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $Polobject }


} #end Function
