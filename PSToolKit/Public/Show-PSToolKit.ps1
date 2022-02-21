
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

.PARAMETER ShowCommand
Use the show-command command

.PARAMETER html
Create a website with the details

.EXAMPLE
Show-PSToolKit

#>
Function Show-PSToolKit {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-PSToolKit')]
    PARAM(
        [switch]$ShowCommand = $false,
        [switch]$html = $false
    )

    Write-Color 'Collecting Command Details' -Color DarkCyan
    Remove-Module -Name PSToolKit -Force -ErrorAction SilentlyContinue
    $module = Get-Module -Name PSToolKit
    if (-not($module)) { $module = Get-Module -Name PSToolKit -ListAvailable }
    $latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
    [string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version

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
   
    if ($ShowCommand) {
        $select = $commands | Select-Object Name, Description | Out-GridView -OutputMode Single
        Show-Command -Name $select.name
    }

    if (!$ShowCommand) {
        $out = ConvertTo-ASCIIArt -Text 'PSToolKit' -Font big
        $out += "`n"
        $out += ConvertTo-ASCIIArt -Text $version -Font big
        
        Write-Host $out -ForegroundColor Yellow
        
        foreach ($item in ($commands.verb | Sort-Object -Unique)) {
            Write-Color 'Verb:', $item -Color Cyan, Red -StartTab 2
            $filtered = $commands | Where-Object { $_.Verb -like $item }
            foreach ($fil in $filtered) {
                Write-Color "$($fil.name) - ", $($fil.Description) -Color Gray, Yellow

            }
        }
    }

    if ($html) {
        #region html settings
        $SectionSettings = @{
            HeaderTextSize        = '16'
            HeaderTextAlignment   = 'center'
            HeaderBackGroundColor = '#00203F'
            HeaderTextColor       = '#ADEFD1'
            backgroundColor       = 'lightgrey'
            CanCollapse           = $true
        }
        $TableSettings = @{
            SearchHighlight = $True
            AutoSize        = $true
            Style           = 'cell-border'
            ScrollX         = $true
            HideButtons     = $true
            HideFooter      = $true
            FixedHeader     = $true
            TextWhenNoData  = 'No Data to display here'
            DisableSearch   = $true
            ScrollCollapse  = $true
            #Buttons        =  @('searchBuilder','pdfHtml5','excelHtml5')
            ScrollY         = $true
            DisablePaging   = $true
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
                        $filtered | ForEach-Object { New-HTMLContent -Invisible -Content {
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.name)" -Color BlackRussian -FontSize 18 -Alignment right }
                                #New-HTMLPanel -BackgroundColor GhostWhite -AlignContentText center -Content {New-HTMLText -Text "[More]($($_.HelpUri))" -Color BlackRussian -FontSize 14 -Alignment center }
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.description) [More]($($_.HelpUri))" -Color FreeSpeechRed -FontSize 16 -Alignment left }      
                            }
                        }
                    }
                }
            }
        }
    }
} #end Function
