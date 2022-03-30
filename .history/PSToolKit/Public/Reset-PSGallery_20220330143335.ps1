
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
 Reset gallery to degault settings 

#> 


<#
.SYNOPSIS
Reset gallery to degault settings

.DESCRIPTION
Reset gallery to degault settings

.EXAMPLE
Reset-PSGallery

#>
Function Reset-PSGallery {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Reset-PSGallery")]
	    [OutputType([System.Object[]])]
                PARAM(
					[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
            						else {Throw "Must be running an elevated prompt to use ClearARPCache"}})]
        			[switch]$Force
				)

       if (((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') -or ($Force)) {
            try {
                $wc = New-Object System.Net.WebClient
                $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

                Install-PackageProvider Nuget -Force | Out-Null
                Register-PSRepository -Default | Out-Null
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

                $BaseModules = @('PowerShellGet', 'PackageManagement')
                foreach ($base in $BaseModules) {
                    Install-Module -Name $base -Force -AllowClobber -Scope AllUsers
                    Import-Module $base -Force
                    Get-Module $base | Update-Module -Force -PassThru
                    Import-Module $base -Force
                }

                Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
            } catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
        } else {Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
    }


} #end Function
