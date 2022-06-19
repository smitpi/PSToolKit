
<#PSScriptInfo

.VERSION 0.1.0

.GUID d6d10177-ac71-4796-81fb-600b93099b9b

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
 Show details of the commands in this module

#>

<#
.SYNOPSIS
Show details of the commands in this module

.DESCRIPTION
Show details of the commands in this module

.PARAMETER ShowMetaData
Show only version, date and path.

.PARAMETER ShowModified
Show new and modified functions.

.PARAMETER ShowCommand
Use the show-command command

.PARAMETER ExportToHTML
Create a HTML page with the details

.EXAMPLE
Show-PSToolKit

#>
Function Show-PSToolKit {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-PSToolKit')]
    PARAM(
        [switch]$ShowMetaData = $false,
        [switch]$ShowModified = $false,
        [switch]$ShowCommand = $false,
        [switch]$ExportToHTML = $false
    )

    Write-Color 'Collecting Command Details:' -Color DarkCyan -LinesBefore 1 -LinesAfter 1 -StartTab 1
    Remove-Module -Name PSToolKit -Force -ErrorAction SilentlyContinue
    $module = Get-Module -Name PSToolKit
    if (-not($module)) { $module = Get-Module -Name PSToolKit -ListAvailable }
    $latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
    [string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version
    [datetime]$CreateDate = (Get-Content -Path $($latestModule.Path.Replace('psm1', 'psd1')) | Where-Object { $_ -like '# Generated on: *' }).replace('# Generated on: ', '')
    $CreateDate = $CreateDate.ToUniversalTime()




    if ($ShowCommand) {
        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }
        $select = $commands | Select-Object Name, Description | Out-GridView -OutputMode Single
        Show-Command -Name $select.name
    }

    if ($ShowMetaData) {
        $Details = @()
        $Details = [PSCustomObject]@{
            Name    = 'PSToolKit'
            Object  = 'PowerShell Module'
            Version = $version
            Date    = (Get-Date($CreateDate) -Format F)
            Path    = $module.Path
        }
        $Details
    }

    if ($ShowModified) {
        $ModulePSM = Get-Item (Join-Path $latestModule.ModuleBase -ChildPath $latestModule.RootModule)
        $PSMContent = $PSMContent
        [System.Collections.ArrayList]$FunctionObject = @()    
        Select-String -Path $ModulePSM.FullName -Pattern '^# Function:*' | ForEach-Object {
            [void]$FunctionObject.Add([PSCustomObject]@{
                    Function   = ($PSMContent)[$_.LineNumber - 1].Replace('# Function:', '').Trim()
                    # ModuleVersion = ($PSMContent)[$_.LineNumber + 1].Replace('# ModuleVersion:', '').Trim()
                    # CreatedOn     = [datetime]($PSMContent)[$_.LineNumber + 4].Replace('# CreatedOn:', '').Trim()
                    ModifiedOn = [datetime]($PSMContent)[$_.LineNumber + 5].Replace('# ModifiedOn:', '').Trim()
                    Synopsis   = ($PSMContent)[$_.LineNumber + 6].Replace('# Synopsis:', '').Trim()
                })
        }
        $modweek = $FunctionObject | Where-Object { $_.ModifiedOn -gt (Get-Date).AddDays(-7) } | Sort-Object -Property ModifiedOn -Descending 
        $modMonth = $FunctionObject | Where-Object { $_.ModifiedOn -gt (Get-Date).AddMonths(-1) } | Sort-Object -Property ModifiedOn -Descending

        $Details = @()
        $Details = [PSCustomObject]@{
            Name    = 'PSToolKit'
            Object  = 'PowerShell Module'
            Version = $version
            Date    = (Get-Date($CreateDate) -Format F)
            Path    = $module.Path
        }
        $Details
        Write-Color 'Modified in the last week' -Color Cyan -LinesAfter 1
        $modweek | Format-Table
        Write-Color 'Modified in the last Month' -Color Cyan -LinesAfter 1 -LinesBefore 2
        $modMonth | Format-Table
        

    }

    if (-not($ShowCommand) -and (-not($ShowMetaData)) -and (-not($ExportToHTML)) -and (-not($ShowModified))) {

        # $out = ConvertTo-ASCIIArt -Text 'PSToolKit' -Font basic
        # $out += "`n"
        # $out += ConvertTo-ASCIIArt -Text $version -Font basic
        # $out += "`n"
        # $out += ("Module Path: $($module.Path)" | Out-String)
        # $out += ("Created on: $(Get-Date($CreateDate) -Format F)" | Out-String)
        # Add-Border -TextBlock $out -Character % -ANSIBorder "$([char]0x1b)[38;5;47m" -ANSIText "$([char]0x1b)[93m"

        $out = (Write-Ascii 'PSToolKit' -ForegroundColor Yellow | Out-String)
        $out += "`n"
        $out += (Write-Ascii $($version) -ForegroundColor Yellow)
        $out += "`n"
        $out += ("Module Path: $($module.Path)" | Out-String)
        $out += ("Created on: $(Get-Date($CreateDate) -Format F)" | Out-String)
        $out
        #Add-Border -TextBlock $out -Character % -ANSIBorder "$([char]0x1b)[38;5;47m" -ANSIText "$([char]0x1b)[93m"

        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }

        foreach ($item in ($commands.verb | Sort-Object -Unique)) {
            Write-Color 'Verb:', $item -Color Cyan, Red -StartTab 1 -LinesBefore 1
            $filtered = $commands | Where-Object { $_.Verb -like $item }
            foreach ($filter in $filtered) {
                Write-Color "$($filter.name)", ' - ', $($filter.Description) -Color Gray, Red, Yellow

            }
        }
    }

    if ($ExportToHTML) {
        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }

        #region html settings
        $SectionSettings = @{
            HeaderTextSize        = '16'
            HeaderTextAlignment   = 'center'
            HeaderBackGroundColor = '#00203F'
            HeaderTextColor       = '#ADEFD1'
            backgroundColor       = 'lightgrey'
            CanCollapse           = $true
        }
        $ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
        #endregion

        New-HTML -Online -Temporary -ShowHTML {
            New-HTMLHeader {
                New-HTMLLogo -RightLogoString $ImageLink
                New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment right -Text "Date Collected: $(Get-Date)"
            }
            foreach ($item in ($commands.verb | Sort-Object -Unique)) {
                $filtered = $commands | Where-Object { $_.Verb -like $item }
                New-HTMLSection -HeaderText "$($item)" @SectionSettings -Width 50% -AlignContent center -AlignItems center -Collapsed {
                    New-HTMLPanel -Content {
                        $filtered | ForEach-Object { New-HTMLSection -Invisible -Content {
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.name)" -Color BlackRussian -FontSize 18 -Alignment right }
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.description) [More]($($_.HelpUri))" -Color FreeSpeechRed -FontSize 16 -Alignment left }
                            }
                        }
                    }
                }
            }
        }
    }
} #end Function
