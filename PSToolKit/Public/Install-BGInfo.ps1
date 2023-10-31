
<#PSScriptInfo

.VERSION 1.0.0

.GUID e1fdeb76-78e2-419f-acac-4b9ae8c67ed1

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

<# 

.DESCRIPTION 
 Install and auto runs bginfo at start up. 

#> 



<#
.SYNOPSIS
Install and auto runs bginfo at start up.

.DESCRIPTION
Install and auto runs bginfo at start up.

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
		$WScriptShell = New-Object -ComObject WScript.Shell
		$lnkfile = "$($env:PUBLIC)\Desktop\Refresh Bginfo.lnk"
		$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
		$Shortcut.TargetPath = 'C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe'
		$Shortcut.Arguments = "`"C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi`" /timer:0 /nolicprompt"
		$icon = Get-Item 'C:\Program Files\PSToolKit\BGInfo\BgInfo.ico'
		$Shortcut.IconLocation = $icon.FullName
		#Save the Shortcut to the TargetPath
		$Shortcut.Save()

	} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

	if ($RunBGInfo) {
		try {
			Write-Color '[Starting] ', 'BGInfo' -Color Yellow, Cyan
			Start-Process -FilePath 'C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe' -ArgumentList '"C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi" /timer:0 /nolicprompt' -NoNewWindow
		} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}
} #end Function
