
<#PSScriptInfo

.VERSION 0.1.0

.GUID f918a423-5aea-4f91-9c7c-b0addfc27b54

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/02/2022_23:05] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Manages this modules config files

#>

<#
.SYNOPSIS
Manages the config files for the PSToolKit Module.

.DESCRIPTION
Manages the config files for the PSToolKit Module, By updating either the locally installed files, or the ones hosted on GitHub Gist.

.PARAMETER UpdateLocal
Overwrites the local files in C:\Program Files\PSToolKit\Config\

.PARAMETER UpdateLocalFromModule
Will be updated from the PSToolKit Modules files.

.PARAMETER UpdateLocalFromGist
Will be updated from the hosted gist files..

.PARAMETER UpdateGist
Update the Gist from the local files.

.PARAMETER GitHubUserID
GitHub User with access to the gist.

.PARAMETER GitHubToken
GitHub User's Token.

.EXAMPLE
Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule

#>
Function Update-PSToolKitConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'local', HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKitConfigFiles')]
	PARAM(
		[Parameter(ParameterSetName = 'local')]
		[Parameter(ParameterSetName = 'Localgist')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$UpdateLocal,
		[Parameter(ParameterSetName = 'gistupdate')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$UpdateGist,
		[Parameter(ParameterSetName = 'local')]
		[switch]$UpdateLocalFromModule,
		[Parameter(ParameterSetName = 'Localgist')]
		[switch]$UpdateLocalFromGist,
		[Parameter(ParameterSetName = 'gistupdate')]
		[Parameter(ParameterSetName = 'Localgist')]
		[string]$GitHubUserID,
		[Parameter(ParameterSetName = 'gistupdate')]
		[Parameter(ParameterSetName = 'Localgist')]
		[string]$GitHubToken
	)

 $ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	if (-not(Test-Path $ConfigPath)) { $ModuleConfigPath = New-Item $ConfigPath -ItemType Directory -Force }
	else { $ModuleConfigPath = Get-Item $ConfigPath }

	if ($UpdateLocal) {
		if ($UpdateLocalFromModule) {
			try {
				$module = Get-Module PSToolKit
				if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
				Get-ChildItem (Join-Path $module.ModuleBase -ChildPath "\private\Config") | ForEach-Object {
					Copy-Item -Path $_.FullName -Destination $ModuleConfigPath.FullName -Force
					Write-Color '[Update]', "$($_.name): ", 'Completed' -Color Yellow, Cyan, Green
				}
			} catch {throw "Unable to update from module source:`n $($_.Exception.Message)"}
		}
		if ($UpdateLocalFromGist) {
			$headers = @{}
			$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
			$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
			$base64 = [System.Convert]::ToBase64String($bytes)
			$headers.Authorization = 'Basic {0}' -f $base64

			$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID

			$gistfiles = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
			$gistfiles = $gistfiles | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }
			$gistfileNames = $gistfiles.files | Get-Member | Where-Object { $_.memberType -eq 'NoteProperty' } | Select-Object Name
			foreach ($gistfileName in $gistfileNames) {
				$url = ($gistfiles.files."$($gistfileName.name)").raw_url
            (Invoke-WebRequest -Uri $url -Headers $headers).content | Set-Content (Join-Path $ModuleConfigPath.FullName -ChildPath $($gistfileName.name))
				Write-Color '[Update]', $($gistfileName.name), ': Complete' -Color Yellow, Cyan, Green
			}
		}

	}
	if ($UpdateGist) {
		try {
			$headers = @{}
			$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
			$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
			$base64 = [System.Convert]::ToBase64String($bytes)
			$headers.Authorization = 'Basic {0}' -f $base64

			$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
			$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
			$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }
		} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}

		if ($null -like $PRGist) {
			try {
				$Body = @{}
				$files = @{}
				Get-ChildItem $ModuleConfigPath.FullName | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } } -ErrorAction Stop
				$Body.files = $Files
				$Body.description = 'PSToolKit-Config'
				$json = ConvertTo-Json -InputObject $Body
				$json = [System.Text.Encoding]::UTF8.GetBytes($json)
				$null = Invoke-WebRequest -Headers $headers -Uri https://api.github.com/gists -Method Post -Body $json -ErrorAction Stop
				Write-Color '[Initial]-[Upload]', 'PSToolKit Config to Gist:', ' Completed' -Color Yellow, Cyan, Green
			} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}
		} else {
			try {
				$Body = @{}
				$files = @{}
				Get-ChildItem $ModuleConfigPath.FullName | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } } -ErrorAction Stop
				$Body.files = $Files
				$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
				$json = ConvertTo-Json -InputObject $Body
				$json = [System.Text.Encoding]::UTF8.GetBytes($json)
				$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
				Write-Color '[Upload]', 'PSToolKit Config to Gist:', ' Completed' -Color Yellow, Cyan, Green
			} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}
		}

	}


} #end
