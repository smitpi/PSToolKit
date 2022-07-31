
<#PSScriptInfo

.VERSION 0.1.0

.GUID 8185732b-f155-4d76-8ae7-52c747814203

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
Created [30/03/2022_14:30] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Reset gallery to default settings

#>


<#
.SYNOPSIS
Reset gallery to default settings

.DESCRIPTION
Reset gallery to default settings

.PARAMETER Force
Force the reinstall

.EXAMPLE
Reset-PSGallery

#>
Function Reset-PSGallery {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Reset-PSGallery')]
	PARAM(
		[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
				else {Throw 'Must be running an elevated prompt'}})]
		[switch]$Force = $false
	)

	if (((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') -or ($Force)) {
		try {
			$wc = New-Object System.Net.WebClient
			$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
			Install-PackageProvider Nuget -Force -ErrorAction SilentlyContinue | Out-Null
			Register-PSRepository -Default -ErrorAction SilentlyContinue | Out-Null
			Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue | Out-Null
			Write-Color '[Installing]', 'PackageProvider: ', 'Complete' -Color Yellow, Cyan, Green

			#} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

			Write-Color '[Checking]', 'PowerShell PackageManagement' -Color Yellow, Cyan
			Start-Job -ScriptBlock {
				$PowerShellGet = Get-Module 'PowerShellGet' -ListAvailable | 
					Sort-Object Version -Descending | 
						Select-Object -First 1

						if ($PowerShellGet.Version -lt [version]'2.2.5') {
							Write-Color "`t[Updating]", 'PowerShell PackageManagement' -Color Yellow, Cyan

							$installOptions = @{
								Repository = 'PSGallery'
								Force      = $true
								Scope      = 'AllUsers'
							}							
							try {
								Install-Module -Name PackageManagement @installOptions
								Write-Color "`t[Installing]", 'PackageManagement: ', 'Complete' -Color Yellow, Cyan, Green
							} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
							try {
								Install-Module -Name PowerShellGet @installOptions
								Write-Color "`t[Installing]", 'PowerShellGet: ', 'Complete' -Color Yellow, Cyan, Green
							} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
						} else {
							Write-Color "`t[Update]", 'PowerShell PackageManagement ', 'Not Needed' -Color Green, Cyan, DarkRed
						}
					
					} | Wait-Job | Receive-Job

					Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
				} catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
			} else {Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, DarkRed}

		} #end Function
