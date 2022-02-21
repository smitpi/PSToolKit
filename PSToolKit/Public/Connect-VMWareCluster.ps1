
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7d78f9a4-2060-4d30-a229-235fbfcb835d

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
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Connect to a vSphere cluster to perform other commands or scripts

#>

<#
.SYNOPSIS
Connect to a vSphere cluster to perform other commands or scripts

.DESCRIPTION
Connect to a vSphere cluster to perform other commands or scripts

.PARAMETER vCenterIp
vCenter IP or name

.PARAMETER vCenterUser
Username to connect with

.PARAMETER vCentrePass
Secure string

.EXAMPLE
Connect-VMWareCluster -vCenterUser $vCenterUser -vCentrePass $vCentrePass

#>
Function Connect-VMWareCluster {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Connect-VMWareCluster')]
    Param(
        [string]$vCenterIp,
        [string]$vCenterUser,
        [securestring]$vCentrePass
    )

    #$vCenterCred = Get-Credential -Message VCSA -UserName $vCenterUser
    #$vCenterPass = 'qqq' # password

    # Ignore unsigned ssl certificates and increase the http timeout value
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -Confirm:$false | Out-Null

    # Connect to vCenter server
    Connect-VIServer -Server $vCenterIp -User $vCenterUser -Password $vCentrePass

} #end Function
