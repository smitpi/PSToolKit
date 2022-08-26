
<#PSScriptInfo

.VERSION 0.1.0

.GUID a875d660-2ca2-4d92-8fd3-31d1a7e57ade

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
Created [29/07/2022_07:27] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Updates my modules 

#> 


<#
.SYNOPSIS
Updates my modules

.DESCRIPTION
Updates my modules

.PARAMETER Modules
Which modules to update.

.PARAMETER AllUsers
Will update to the AllUsers Scope.

.PARAMETER ForceUpdate
ForceUpdate the download and install.


.EXAMPLE
Update-MyModulesFromGitHub -AllUsers

#>
Function Update-MyModulesFromGitHub {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/$($ModuleName)/Update-MyModulesFromGitHub')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateSet('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule', 'PSToolkit','PSWindowsApp')]
		[string[]]$Modules = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule', 'PSToolkit', 'PSWindowsApp'),
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$AllUsers,
		[switch]$ForceUpdate = $false
	)

	foreach ($ModuleName in $Modules) {
		Write-Host '[Checking]: ' -ForegroundColor Yellow -NoNewline; Write-Host "$($ModuleName): " -ForegroundColor Cyan

		if ($AllUsers) {
			$ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules', "$($ModuleName)")
		} else {
			$ModulePath = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell', 'Modules', "$($ModuleName)")
		}


		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder $($env:tmp) "
		if ((Test-Path "$env:tmp\$($ModuleName).zip") -eq $true ) { Remove-Item "$env:tmp\$($ModuleName).zip" -Force }

		if ((Test-Path $ModulePath)) {
			$ModChild = $InstalledVer = $OnlineVer = $null
			$ModChild = Get-ChildItem -Directory $ModulePath -ErrorAction SilentlyContinue
			if ($null -like $ModChild) {$ForceUpdate = $true}
			else {
				[version]$InstalledVer = ($ModChild | Sort-Object -Property Name -Descending)[0].Name
				[version]$OnlineVer = (Invoke-RestMethod "https://raw.githubusercontent.com/smitpi/$($ModuleName)/master/Version.json").version
				if ($InstalledVer -lt $OnlineVer) {
					$ForceUpdate = $true
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder to $(Join-Path -Path $ModulePath -ChildPath "$($ModuleName)-BCK.zip")"
					Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath "$($ModuleName)-BCK.zip") -Update
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder $($ModulePath)"
					Get-ChildItem -Directory $ModulePath | Remove-Item -Recurse -Force
				} else {
					Write-Host "`t[Done]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($ModuleName) ($($OnlineVer.ToString())): " -ForegroundColor Cyan -NoNewline; Write-Host 'Already Up To Date' -ForegroundColor DarkRed
				}
			}
		} else {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Creating Module directory $($ModulePath)"
			New-Item $ModulePath -ItemType Directory -Force | Out-Null
			$ForceUpdate = $true
		}

		if ($ForceUpdate) {
			$PathFullName = Get-Item $ModulePath
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
			Write-Host "`t[Downloading]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($ModuleName): " -ForegroundColor DarkRed
			if (Get-Command Start-BitsTransfer) {
				try {
					Start-BitsTransfer -DisplayName "$($ModuleName) Download" -Source "https://github.com/smitpi/$($ModuleName)/archive/refs/heads/master.zip" -Destination "$env:tmp\$($ModuleName).zip" -TransferType Download -ErrorAction Stop
					
				} catch {
					Write-Warning 'Bits Transer failed, defaulting to webrequest'
					Invoke-WebRequest -Uri "https://github.com/smitpi/$($ModuleName)/archive/refs/heads/master.zip" -OutFile "$env:tmp\$($ModuleName).zip"
				}
			} else {
				Invoke-WebRequest -Uri "https://github.com/smitpi/$($ModuleName)/archive/refs/heads/master.zip" -OutFile "$env:tmp\$($ModuleName).zip"
			}
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
			Expand-Archive "$env:tmp\$($ModuleName).zip" "$env:tmp" -Force

			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Copying to $($PathFullName.FullName)"
			$NewModule = Get-ChildItem -Directory "$env:tmp\$($ModuleName)-master\Output"
			Copy-Item -Path $NewModule.FullName -Destination $PathFullName.FullName -Recurse

			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Removing temp files"
			Remove-Item "$env:tmp\$($ModuleName).zip"
			Remove-Item "$env:tmp\$($ModuleName)-master" -Recurse

			$module = Get-Module -Name $($ModuleName)
			if (-not($module)) { $module = Get-Module -Name $($ModuleName) -ListAvailable }
			$latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
			[string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version
			$Description = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Description
			[datetime]$CreateDate = (Get-Content -Path $($latestModule.Path.Replace('psm1', 'psd1')) | Where-Object { $_ -like '# Generated on: *' }).replace('# Generated on: ', '')
			$CreateDate = $CreateDate.ToUniversalTime()

			Write-Host "`t[$($ModuleName)]" -NoNewline -ForegroundColor Cyan; Write-Host ' Details' -ForegroundColor Green
			[PSCustomObject]@{
				Name        = $($ModuleName)
				Description = $Description
				Version     = $version
				Date        = (Get-Date($CreateDate) -Format F)
				Path        = $module.Path
			}
		}
		$ForceUpdate = $false
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete]"
		Remove-Module -Name $($ModuleName) -Force -ErrorAction SilentlyContinue
		try {
			Import-Module $($ModuleName) -Force -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}
} #end Function
