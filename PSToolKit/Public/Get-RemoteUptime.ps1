
<#PSScriptInfo

.VERSION 0.1.0

.GUID d12d161d-0028-4e78-88a1-d8ebbd386e0b

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
 Check the uptime of a list of servers

#>

<#
.SYNOPSIS
Check the uptime of a list of servers

.DESCRIPTION
Check the uptime of a list of servers

.PARAMETER ComputerName
Server Names to check

.PARAMETER ShowOfflineComputers
Show which servers are offline

.EXAMPLE
Get-RemoteUptime -ComputerName $list

#>
Function Get-RemoteUptime {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-RemoteUptime')]


    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]

        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [Switch]
        $ShowOfflineComputers

    )

    BEGIN {
        $ErroredComputers = @()
    }

    PROCESS {
        Foreach ($Computer in $ComputerName) {
            Try {
                $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
                $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
                $Properties = @{ComputerName = $Computer
                    LastBoot                 = $OS.ConvertToDateTime($OS.LastBootUpTime)
                    Uptime                   = ([String]$Uptime.Days + ' Days ' + $Uptime.Hours + ' Hours ' + $Uptime.Minutes + ' Minutes')
                }

                $Object = New-Object -TypeName PSObject -Property $Properties | Select-Object ComputerName, LastBoot, UpTime

            }
            catch {
                if ($ShowOfflineComputers) {
                    $ErrorMessage = $Computer + ' Error: ' + $_.Exception.Message
                    $ErroredComputers += $ErrorMessage

                    $Properties = @{ComputerName = $Computer
                        LastBoot                 = 'Unable to Connect'
                        Uptime                   = 'Error Shown Below'
                    }

                    $Object = New-Object -TypeName PSObject -Property $Properties | Select-Object ComputerName, LastBoot, UpTime
                }

            }
            finally {
                Write-Output $Object

                $Object = $null
                $OS = $null
                $Uptime = $null
                $ErrorMessage = $null
                $Properties = $null
            }
        }

        if ($ShowOfflineComputers) {
            Write-Output ''
            Write-Output 'Errors for Computers not able to connect.'
            Write-Output $ErroredComputers
        }
    }

    END {}

}
