
<#PSScriptInfo

.VERSION 0.1.0

.GUID bca536cd-a306-4eb6-b014-a9f3a25369db

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powwershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [20/03/2022_19:30] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Setup BGInfo 

#> 
<#
.SYNOPSIS
Install and auto runs bginfo at startup.

.DESCRIPTION
Install and auto runs bginfo at startup.

.PARAMETER RunBGInfo
Execute bginfo at the end of the script

.EXAMPLE
Install-BGInfo -RunBGInfo

#>
Function Install-BGInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Install-BGInfo')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$RunBGInfo = $false
	)
				

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'BGInfo')
	if (-not(Test-Path $ConfigPath)) { 
		$ModuleConfigPath = New-Item $ConfigPath -ItemType Directory -Force 
		Write-Color '[Creating] ', 'Config Folder:', ' Completed' -Color Yellow, Cyan, Green
	} else { $ModuleConfigPath = Get-Item $ConfigPath }

	try {
		$module = Get-Module PSToolKit
		if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
		Get-ChildItem (Join-Path $module.ModuleBase -ChildPath '\private\BGInfo') | ForEach-Object {
			Copy-Item -Path $_.FullName -Destination $ModuleConfigPath.FullName -Force
			Write-Color '[Updating] ', "$($_.name): ", 'Completed' -Color Yellow, Cyan, Green
		}
	} catch {throw "Unable to update from module source:`n $($_.Exception.Message)"}

	try {
		$bgInfoRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
		$bgInfoRegKey = 'BgInfo'
		$bgInfoRegType = 'String'
		$bgInfoRegKeyValue = '"C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe" "C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi" /timer:0 /nolicprompt'
		$regKeyExists = (Get-Item $bgInfoRegPath -ErrorAction SilentlyContinue).Property -contains $bgInfoRegkey

		If ($regKeyExists -eq $True) {
			Set-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -Value $bgInfoRegkeyValue | Out-Null
			Write-Color '[Recreating] ', 'Registry AutoStart: ', 'Completed' -Color Yellow, Cyan, Green
		} Else {
			New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue | Out-Null
			Write-Color '[Creating] ', 'Registry AutoStart: ', 'Completed' -Color Yellow, Cyan, Green
		}
	} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

	if ($RunBGInfo) {
		try {
			Write-Color '[Starting] ', 'BGInfo' -Color Yellow, Cyan
			Start-Process -FilePath 'C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe' -ArgumentList '"C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi" /timer:0 /nolicprompt' -NoNewWindow
		} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}
} #end Function
