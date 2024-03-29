﻿
<#PSScriptInfo

.VERSION 0.1.0

.GUID 6e1b17e4-7f85-4929-87af-4f959f2120ae

.AUTHOR Joakim Svendsen

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
Created [20/03/2022_12:24] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Create Ascii Art

#>

<#
.SYNOPSIS
Create Ascii Art

.DESCRIPTION
Create Ascii Art

.PARAMETER InputObject
The string

.PARAMETER PrependChar
char

.PARAMETER Compress
compress output

.PARAMETER ForegroundColor
ForegroundColor

.PARAMETER BackgroundColor
BackgroundColor

.EXAMPLE
Write-Ascii Blah
#>
function Write-Ascii {
    # Wrapping the script in a function to make it a module

    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline = $True,
            Mandatory = $True)]
        [Alias('InputText')]
        [String[]] $InputObject,
        [Switch] $PrependChar,
        [Alias('Compression')] [Switch] $Compress,
        [ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Default', 'Gray', 'Green',
            'Magenta', 'Red', 'Rainbow', 'White', 'Yellow')]
        [String] $ForegroundColor = 'Default',
        [ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Default', 'Gray', 'Green',
            'Magenta', 'Red', 'Rainbow', 'White', 'Yellow')]
        [String] $BackgroundColor = 'Default'
        #[int] $MaxChars = '25'
    )

    begin {

        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'

        # Algorithm from hell... This was painful. I hope there's a better way.
        function Get-Ascii {

            param([String] $Text)

            $LetterArray = [Char[]] $Text.ToLower()

            #Write-Host -fore green $LetterArray

            # Find the letter with the most lines.
            $MaxLines = 0
            $LetterArray | ForEach-Object {
                if ($Letters.([String] $_).Lines -gt $MaxLines ) {
                    $MaxLines = $Letters.([String] $_).Lines
                }
            }

            # Now this sure was a simple way of making sure all letter align tidily without changing a lot of code!
            if (-not $Compress) { $MaxLines = 6 }

            $LetterWidthArray = $LetterArray | ForEach-Object {
                $Letter = [String] $_
                $Letters.$Letter.Width
            }
            $LetterLinesArray = $LetterArray | ForEach-Object {
                $Letter = [String] $_
                $Letters.$Letter.Lines
            }

            #$LetterLinesArray

            $Lines = @{
                '1' = ''
                '2' = ''
                '3' = ''
                '4' = ''
                '5' = ''
                '6' = ''
            }

            #$LineLengths = @(0, 0, 0, 0, 0, 0)

            # Debug
            #Write-Host "MaxLines: $Maxlines"

            $LetterPos = 0
            foreach ($Letter in $LetterArray) {

                # We need to work with strings for indexing the hash by letter
                $Letter = [String] $Letter

                # Each ASCII letter can be from 4 to 6 lines.

                # If the letter has the maximum of 6 lines, populate hash with all lines.
                if ($LetterLinesArray[$LetterPos] -eq 6) {

                    #Write-Host "Six letter letter"

                    foreach ($Num in 1..6) {

                        $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 1]

                        if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                            $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                        }

                        $StringNum = [String] $Num
                        $Lines.$StringNum += $LineFragment

                    }

                }

                # Add padding for line 1 for letters with 5 lines and populate lines 2-6.
                ## Changed to top-adjust 5-line letters if there are 6 total.
                ## Added XML properties for letter alignment. Most are "default", which is top-aligned.
                ## Also added script logic to handle it (2012-12-29): <fixation>bottom</fixation>
                elseif ($LetterLinesArray[$LetterPos] -eq 5) {

                    if ($MaxLines -lt 6 -or $Letters.$Letter.fixation -eq 'bottom') {

                        $Padding = ' ' * $LetterWidthArray[$LetterPos]
                        $Lines.'1' += $Padding

                        foreach ($Num in 2..6) {

                            $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 2]

                            if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                                $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                            }

                            $StringNum = [String] $Num
                            $Lines.$StringNum += $LineFragment

                        }

                    }

                    else {

                        $Padding = ' ' * $LetterWidthArray[$LetterPos]
                        $Lines.'6' += $Padding

                        foreach ($Num in 1..5) {

                            $StringNum = [String] $Num

                            $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 1]

                            if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                                $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                            }

                            $Lines.$StringNum += $LineFragment

                        }

                    }

                }

                # Here we deal with letters with four lines.
                # Dynamic algorithm that places four-line letters on the bottom line if there are
                # 4 or 5 lines only in the letter with the most lines.
                else {

                    # Default to putting the 4-liners at line 3-6
                    $StartRange, $EndRange, $IndexSubtract = 3, 6, 3
                    $Padding = ' ' * $LetterWidthArray[$LetterPos]

                    # If there are 4 or 5 lines...
                    if ($MaxLines -lt 6) {

                        $Lines.'2' += $Padding

                    }

                    # There are 6 lines maximum, put 4-line letters in the middle.
                    else {

                        $Lines.'1' += $Padding
                        $Lines.'6' += $Padding
                        $StartRange, $EndRange, $IndexSubtract = 2, 5, 2

                    }

                    # There will always be at least four lines. Populate lines 2-5 or 3-6 in the hash.
                    foreach ($Num in $StartRange..$EndRange) {

                        $StringNum = [String] $Num

                        $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - $IndexSubtract]

                        if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                            $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                        }

                        $Lines.$StringNum += $LineFragment

                    }

                }

                $LetterPos++

            } # end of LetterArray foreach

            # Return stuff
            $Lines.GetEnumerator() |
                Sort-Object -Property Name |
                    Select-Object -ExpandProperty Value |
                        Where-Object {
                            $_ -match '\S'
                        } | ForEach-Object {
                            if ($PrependChar) {
                                "'" + $_
                            } else {
                                $_
                            }
                        }

        }

        # Populate the $Letters hashtable with character data from the XML.
        Function Get-LetterXML {


            $LetterFile = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config', 'letters.xml')
            $Xml = [xml] (Get-Content $LetterFile)

            $Xml.Chars.Char | ForEach-Object {

                $Letters.($_.Name) = New-Object PSObject -Property @{

                    'Fixation' = $_.fixation
                    'Lines'    = $_.lines
                    'ASCII'    = $_.data
                    'Width'    = $_.width

                }

            }

        }

        function Write-RainbowString {

            param([String] $Line,
                [String] $ForegroundColor = '',
                [String] $BackgroundColor = '')

            $Colors = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow',
                'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')


            # $Colors[(Get-Random -Min 0 -Max 16)]

            [Char[]] $Line | ForEach-Object {

                if ($ForegroundColor -and $ForegroundColor -ieq 'rainbow') {

                    if ($BackgroundColor -and $BackgroundColor -ieq 'rainbow') {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -BackgroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    } elseif ($BackgroundColor) {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -BackgroundColor $BackgroundColor `
                            -NoNewline $_
                    } else {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    }

                }
                # One of them has to be a rainbow, so we know the background is a rainbow here...
                else {

                    if ($ForegroundColor) {
                        Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    } else {
                        Write-Host -BackgroundColor $Colors[(Get-Random -Min 0 -Max 16)] -NoNewline $_
                    }
                }

            }

            Write-Host ''

        }

        # Get ASCII art letters/characters and data from XML. Make it persistent for the module.
        if (-not (Get-Variable -EA SilentlyContinue -Scope Script -Name Letters)) {
            $script:Letters = @{}
            Get-LetterXML
        }

        # Turn the [string[]] into a [String] the only way I could figure out how... wtf
        #$Text = ''
        #$InputObject | ForEach-Object { $Text += "$_ " }

        # Limit to 30 characters
        #$MaxChars = 30
        #if ($Text.Length -gt $MaxChars) { "Too long text. There's a maximum of $MaxChars characters."; return }

        # Replace spaces with underscores (that's what's used for spaces in the XML).
        #$Text = $Text -replace ' ', '_'

        # Define accepted characters (which are found in XML).
        #$AcceptedChars = '[^a-z0-9 _,!?./;:<>()�{}\[\]\|\^=\$\-''+`\\"�������������]' # Some chars only works when sent as UTF-8 on IRC
        $LetterArray = [string[]]($Letters.GetEnumerator() | Sort-Object Name | Select-Object -ExpandProperty Name)
        $AcceptedChars = [regex] ( '(?i)[^' + ([regex]::Escape(($LetterArray -join '')) -replace '-', '\-' -replace '\]', '\]') + ' ]' )
        # Debug
        #Write-Host -fore cyan $AcceptedChars.ToString()
    }

    process {
        if ($InputObject -match $AcceptedChars) {
            'Unsupported character, using these accepted characters: ' + ($LetterArray -replace '^template$' -join ', ') + '.'
            return
        }

        # Filthy workaround (now worked around in the foreach creating the string).
        #if ($Text.Length -eq 1) { $Text += '_' }

        $Lines = @()

        foreach ($Text in $InputObject) {

            $ASCII = Get-Ascii ($Text -replace ' ', '_')

            if ($ForegroundColor -ne 'Default' -and $BackgroundColor -ne 'Default') {
                if ($ForegroundColor -ieq 'rainbow' -or $BackGroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -Line $_
                    }
                } else {
                    Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor ($ASCII -join "`n")
                }
            } elseif ($ForegroundColor -ne 'Default') {
                if ($ForegroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -ForegroundColor $ForegroundColor -Line $_
                    }
                } else {
                    Write-Host -ForegroundColor $ForegroundColor ($ASCII -join "`n")
                }
            } elseif ($BackgroundColor -ne 'Default') {
                if ($BackgroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -BackgroundColor $BackgroundColor -Line $_
                    }
                } else {
                    Write-Host -BackgroundColor $BackgroundColor ($ASCII -join "`n")
                }
            } else { $ASCII -replace '\s+$' }

        } # end of foreach

    } # end of process block

} # end of function
