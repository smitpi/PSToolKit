
<#PSScriptInfo

.VERSION 0.1.0

.GUID 65f8cec1-5b47-41b2-a2b8-c1b419fda97a

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
Created [28/12/2022_06:33] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Change the wallpaper for the user 

#> 


<#
.SYNOPSIS
Change the wallpaper for the user.

.DESCRIPTION
Change the wallpaper for the user.

.PARAMETER PicturePath
Defines the path to the picture to use for background
    
.PARAMETER Style
Defines the style of the wallpaper. Valid values are, Tiled, Centered, Stretched, Fill, Fit, Span

.EXAMPLE
Set-DesktopWallpaper -PicturePath "C:\pictures\picture1.jpg" -Style Fill

#>
Function Set-UserDesktopWallpaper {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Set-UserDesktopWallpaper")]
                #region Parameter
                PARAM(
					[Parameter(Mandatory)]
                    [string]$PicturePath,
                    [ValidateSet('Tiled', 'Centered', 'Stretched', 'Fill', 'Fit', 'Span')]
                    [string]$Style = 'Fill'
				)
                #endregion
       BEGIN {
        $Definition = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@

        Add-Type -MemberDefinition $Definition -Name Win32SystemParametersInfo -Namespace Win32Functions
        $Action_SetDeskWallpaper = [int]20
        $Action_UpdateIniFile = [int]0x01
        $Action_SendWinIniChangeEvent = [int]0x02

        $HT_WallPaperStyle = @{
            'Tiles'     = 0
            'Centered'  = 0
            'Stretched' = 2
            'Fill'      = 10
            'Fit'       = 6
            'Span'      = 22
        }

        $HT_TileWallPaper = @{
            'Tiles'     = 1
            'Centered'  = 0
            'Stretched' = 0
            'Fill'      = 0
            'Fit'       = 0
            'Span'      = 0
        }

    }


    PROCESS {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name wallpaperstyle -Value $HT_WallPaperStyle[$Style]
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name tilewallpaper -Value $HT_TileWallPaper[$Style]
        $null = [Win32Functions.Win32SystemParametersInfo]::SystemParametersInfo($Action_SetDeskWallpaper, 0, $PicturePath, ($Action_UpdateIniFile -bor $Action_SendWinIniChangeEvent))
    }
} #end Function
