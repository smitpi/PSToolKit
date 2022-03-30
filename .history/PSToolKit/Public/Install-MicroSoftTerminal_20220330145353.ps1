
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
Param()


.SYNOPSIS
Install Terminal

.DESCRIPTION
Install Terminal

.EXAMPLE
Install-MicrosoftTerminal

#>
Function Install-MicrosoftTerminal {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-MicrosoftTerminal")]
	    [OutputType([System.Object[]])]
                PARAM()
				  
				
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
		}

} #end Function
