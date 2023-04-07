
<#PSScriptInfo

.VERSION 0.1.0

.GUID 85ba9d07-3dca-4f28-a866-4b00352d8858

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS AD

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [07/04/2023_10:24] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Start replication between Domain Controllers.

#> 


<#
.SYNOPSIS
Start replication between Domain Controllers.

.DESCRIPTION
Start replication between Domain Controllers.

.EXAMPLE
Start-DomainControllerReplication -Export HTML -ReportPath C:\temp

#>

<#
.SYNOPSIS
Start replication between Domain Controllers.

.DESCRIPTION
Start replication between Domain Controllers.

.PARAMETER Credential
AD Domain Admin Credentials.

.EXAMPLE
Start-DomainControllerReplication -Credential $Admin

#>
Function Start-DomainControllerReplication {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Start-DomainControllerReplication")]
	    [OutputType([System.Object[]])]
                #region Parameter
                PARAM(
					[Parameter(Position = 0,Mandatory,HelpMessage = 'AD Domain Admin Credentials.')]
					[pscredential]$Credential
					)
                #endregion
				$DomainControllers =  Get-ADDomainController -Filter * -Credential $Credential
				$ADDomain = Get-ADDomain -Credential $Credential
				foreach ($DC in $DomainControllers) {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] ($($DC.Name)) DC $($DomainControllers.IndexOf($($DC)) + 1) of $($DomainControllers.Count)"
					Start-Job -Name "ADSync" -ScriptBlock {
						PARAM ($DC,$ADDomain)
						cmd /c "repadmin /syncall $($DC.Name) $($ADDomain.DistinguishedName)  /e /A" | Write-Verbose
					} -Credential $Credential -ArgumentList $DC,$ADDomain | Wait-Job | Receive-Job
				}
					Start-Sleep 10
					Get-ADReplicationPartnerMetadata -Target "$($env:USERDNSDOMAIN)" -Scope Domain -Credential $Credential | Select-Object Server, LastReplicationSuccess
} #end Function
