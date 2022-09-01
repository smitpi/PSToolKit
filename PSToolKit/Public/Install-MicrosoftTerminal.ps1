
<#PSScriptInfo

.VERSION 1.0.0

.GUID ef1101bf-edf0-461e-96f6-89eb17a1bfb7

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Install MicrosoftTerminal on your device. 

#> 



<#
.SYNOPSIS
Install MicrosoftTerminal on your device.

.DESCRIPTION
Install MicrosoftTerminal on your device.

.PARAMETER DefaultSettings
Replace the settings.json file with one from this module.

.EXAMPLE
Install-MicrosoftTerminal -DefaultSettings

#>
Function Install-MicrosoftTerminal {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MicrosoftTerminal')]
	PARAM(
		[switch]$DefaultSettings = $false
	)

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

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
				$settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', 'Microsoft.WindowsTerminal*', 'LocalState', 'Settings.json')
				$SetFile = Get-Item $settingsFile
				if (Test-Path $SetFile.FullName) {Rename-Item -Path $SetFile.FullName -NewName "Settings-$(Get-Date -Format yyyy.MM.dd_HHMM).json" -Force | Out-Null}

				$module = Get-Module PSToolKit
				if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
				Get-Content (Join-Path $module.ModuleBase -ChildPath '\private\Config\MicrosoftTerminalSettings.json') | Set-Content $SetFile.FullName -Force
			}
		}
	} catch { Write-Warning "[Installing] Microsoft Terminal: Failed:`n $($_.Exception.Message)" }

}
