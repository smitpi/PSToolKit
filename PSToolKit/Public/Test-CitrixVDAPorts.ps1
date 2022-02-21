
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7ae3435e-25d9-44da-8fb6-e725a89d393d

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
.SYNOPSIS
 Test connection between ddc and vda

.DESCRIPTION
 Test connection between ddc and vda

.PARAMETER ServerList
List servers to test

.PARAMETER PortsList
List of ports to test

.PARAMETER Export
Export the results.

.PARAMETER ReportPath
Where report will be saves.

.EXAMPLE
Test-CitrixVDAPorts -ServerList $list

#>
Function Test-CitrixVDAPorts {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-CitrixVDAPorts')]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Collections.ArrayList]$ServerList,
        [Parameter(Mandatory = $false, Position = 1)]
        [System.Collections.ArrayList]$PortsList = @('80', '443', '1494', '2598'),
        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [Parameter(Mandatory = $false, Position = 4)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$ReportPath = $env:temp
    )

    $index = 0
    $object = @()
    $PortsList | ForEach-Object {
        $port = $_
        $ServerList | ForEach-Object {
            $test = Test-NetConnection -ComputerName $_ -Port $port -InformationLevel Detailed
            $ob = [PSCustomObject]@{
                index            = $index
                From_Host        = $env:COMPUTERNAME
                To_Host          = $_
                RemoteAddress    = $test.RemoteAddress
                Port             = $port
                TcpTestSucceeded = $test.TcpTestSucceeded
                Detail           = @(($test) | Out-String).Trim()
            }
            $object += $ob
            $index ++

        }
    }

    if ($Export -eq 'Excel') {
        foreach ($svr in $ServerList) {
            $object | Where-Object { $_.To_Host -like $svr } | Export-Excel -Path ($ReportPath + '\VDA_Ports-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Append -FreezeTopRow -TableStyle Dark11 -BoldTopRow -ConditionalText $(
                New-ConditionalText FALSE white red
                New-ConditionalText TRUE white green
            )
        }

    }
    if ($Export -eq 'HTML') {
        $HeadingText = 'VDA Ports Tests' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
        New-HTML -TitleText 'VDA Ports Tests' -FilePath ($ReportPath + '\VDA_Ports-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html') -ShowHTML {
            New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
            foreach ($svr in $ServerList) {
                $object | Where-Object { $_.To_Host -like $svr }
                New-HTMLSection @SectionSettings -Content {
                    New-HTMLSection -HeaderText "Source: $($svr)" @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $object }
                }
            }
        }
    }

    if ($Export -eq 'Host') { $object }


} #end Function
