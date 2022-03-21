function mybuild {
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[ValidateSet('Combine', 'Build')]
		[string]$Update
	)

	Get-Module PSToolKit | Remove-Module -Force
	Import-Module (Join-Path $PSScriptRoot "\PSToolKit\Public\Set-PSProjectFiles.ps1") -Force
	try {
		Copy-Item 'C:\Program Files\PSToolKit\Config\*' -Destination (Join-Path $PSScriptRoot "\PSToolKit\Private\Config") -Force -ErrorAction Stop
		Copy-Item 'C:\Program Files\PSToolKit\BGInfo\*' -Destination (Join-Path $PSScriptRoot "\PSToolKit\Private\BGInfo") -Force -ErrorAction Stop	
	} catch {throw "Cant copy config files`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}


	if ($Update -like 'Build') {
		try {
             if (test-path (Join-Path $PSScriptRoot "\Output")) {Remove-Item (Join-Path $PSScriptRoot "\Output") -Force -Recurse -ErrorAction Stop}
			 if (test-path (Join-Path $PSScriptRoot "\docs")) {Remove-Item (Join-Path $PSScriptRoot "\docs") -Force -Recurse -ErrorAction Stop}
		} catch {Write-Warning "Cant delete files`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

		Set-PSProjectFiles -ModulePSM1 (Join-Path $PSScriptRoot "\PSToolKit\PSToolKit.psm1") -VersionBump Build -mkdocs gh-deploy -GitPush
	} else {
		Set-PSProjectFiles -ModulePSM1 (Join-Path $PSScriptRoot "\PSToolKit\PSToolKit.psm1") -VersionBum CombineOnly -mkdocs serve -GitPush
	}

	try {
		$newmod = ((Get-ChildItem -Directory (Join-Path $PSScriptRoot "\Output")) | Sort-Object -Property Name -Descending)[0]
		Get-ChildItem -Directory 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit' | Compress-Archive -DestinationPath 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit\oldmodule.zip' -Update
		Get-ChildItem -Directory 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit' | Remove-Item -Recurse -Force
		Copy-Item -Path $newmod.FullName -Destination 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit\' -Force -Recurse
	} catch {Write-Warning "Unable to copy the new module `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
}