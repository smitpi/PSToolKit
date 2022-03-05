
<#PSScriptInfo

.VERSION 0.1.0

.GUID cd062c17-ca13-4209-8a6e-20c292220964

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS PS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [05/03/2022_20:33] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
Generates a list of usernames and server names, that can be used as test / demo data.

#>

<#
.SYNOPSIS
Generates a list of usernames and server names, that can be used as test / demo data.

.DESCRIPTION
Generates a list of usernames and server names, that can be used as test / demo data.

.PARAMETER OS
The Type of server names to generate.

.PARAMETER Export
Export the results.

.PARAMETER ReportPath
Where to save the data.

.EXAMPLE
New-SuggestedInfraNames -OS VDI -Export Excel -ReportPath C:\temp

#>
Function New-SuggestedInfraNames {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-SuggestedInfraNames')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateSet('LNX', 'SVR', 'VDI', 'WST', 'DSK')]
        [string]$OS = 'SVR',
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Excel', 'Json')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )

    [System.Collections.ArrayList]$ServerObject = @()
    [void]$ServerObject.Add([PSCustomObject]@{build = 'verb'; servers = @(((Invoke-Generate "$OS-[verb]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'adjective'; servers = @(((invoke-Generate "$OS-[adjective]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'noun'; servers = @(((invoke-Generate "$OS-[noun]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'random'; servers = @(((Invoke-Generate "$OS-???##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'color'; servers = @(((Invoke-Generate "$OS-[color]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'consonant'; servers = @(((Invoke-Generate "$OS-[consonant][consonant][consonant]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'country'; servers = @(((Invoke-Generate "$OS-[country]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'phoneticvowel'; servers = @(((Invoke-Generate "$OS-[phoneticvowel]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'syllable'; servers = @(((Invoke-Generate "$OS-[syllable]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })

    [System.Collections.ArrayList]$UserObject = @()
    $rawUsers = Invoke-Generate -Template '[person both first]|[person both last]|[job]|(08#) ### ####|[country]' -Count 20
    foreach ($user in $rawUsers) {
        $breakdown = $user.Split('|')
        [void]$UserObject.Add([PSCustomObject]@{
                FirstName   = $breakdown[0]
                Lastname    = $breakdown[1]
                Fullname    = "$($breakdown[1]) $($breakdown[0])"
                Userid      = "$($breakdown[1])$($breakdown[0][0])"
                Department  = $breakdown[2]
                email       = "$($breakdown[0]).$($breakdown[1])@$($env:USERDNSDOMAIN)"
                PhoneNumber = $($breakdown[3])
                Country     = $breakdown[4]
            })
    }
    $data = @()
    $data = [PSCustomObject]@{
        ServerDetails = $ServerObject
        UserDetails   = $UserObject
    }

    if ($Export -eq 'Excel') {
        $data.ServerDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ServerDetails -AutoSize -AutoFilter
        $data.UserDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName UserDetails -AutoSize -AutoFilter -Show
    }
    if ($Export -eq 'Json') { $data | ConvertTo-Json -Depth 3 | Set-Content -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).json") }
    if ($Export -eq 'Host') { $data }


} #end Function
