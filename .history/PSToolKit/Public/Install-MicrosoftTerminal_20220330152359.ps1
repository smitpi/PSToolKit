
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7a5ae56c-542d-4fcf-bdb8-371bb23e1e63

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
Created [30/03/2022_14:49] Initial Script Creating

.PRIVATEDATA

#>


#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Install Terminal

#>
<#
.SYNOPSIS
Install MicrosoftTerminal on your device.

.DESCRIPTION
Install MicrosoftTerminal on your device.

.PARAMETER DefaultSettings
Parameter description

.EXAMPLE
Install-MicrosoftTerminal

#>
Function Install-MicrosoftTerminal {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Install-MicrosoftTerminal")]
                PARAM(
					[switch]$DefaultSettings
				)
				
	try {
		if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
		'microsoft-windows-terminal', 'cascadia-code-nerd-font', 'cascadiacodepl' | ForEach-Object {
			$ChocoApp = choco search $_ --exact --local-only --limit-output
			$ChocoAppOnline = choco search $_ --exact --limit-output
			if ($null -eq $ChocoApp) {
				Write-Color '[Installing] ', $($_), ' from source ', 'chocolatey' -Color Yellow, Cyan, Green, Cyan
				choco upgrade $($_) --accept-license --limit-output -y | Out-Null
				if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
			} else {
				Write-Color '[Installing] ', $($ChocoApp.split('|')[0]), " (Version: $($ChocoApp.split('|')[1]))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
				if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
					Write-Color '[Updating] ', $($_), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', 'chocolatey' -Color Yellow, Cyan, Yellow, Green, Cyan -StartTab 1
					choco upgrade $($_) --accept-license --limit-output -y | Out-Null
					if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
				}
			}
			if ($DefaultSettings) {
				$settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', "Microsoft.WindowsTerminal*", 'LocalState', 'Settings.json')
            	$SetFile = Get-Item $settingsFile
				if (Test-Path $SetFile.FullName) {Rename-Item -Path $SetFile.FullName -NewName "Settings-$(Get-Date -Format yyyy.MM.dd_HHMM).json" -Force | Out-Null}

				$module = Get-Module PSToolKit
				if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
				Get-Content (Join-Path $module.ModuleBase -ChildPath "\private\Config\MicrosoftTerminalSettings.json") | Set-Content $SetFile.FullName -Force
			}
		}
	} catch { Write-Warning "[Installing] Microsoft Terminal: Failed:`n $($_.Exception.Message)" }

}