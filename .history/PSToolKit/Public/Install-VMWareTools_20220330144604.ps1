
<#PSScriptInfo

.VERSION 0.1.0

.GUID 9ba7b261-958d-40b0-ae6a-e67f7083e506

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
Created [30/03/2022_14:41] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Install vmware tools from chocolatety 

#> 


<#
.SYNOPSIS
Install vmware tools from chocolatety

.DESCRIPTION
Install vmware tools from chocolatety

.EXAMPLE
Install-VMWareTools

#>
Function Install-VMWareTools {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-VMWareTools")]
	    [OutputType([System.Object[]])]
                PARAM()


$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}


	try {
		if ((Get-CimInstance -ClassName win32_bios).Manufacturer -like '*VMware*') {
			if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
			Write-Color '[Installing] ', 'VMWare Tools', ' from source ', 'chocolatey' -Color Yellow, Cyan, green, Cyan
			choco upgrade vmware-tools --accept-license --limit-output -y --source chocolatey | Out-Null
			if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing vmware-tools Code: $($LASTEXITCODE)"}
		} else {Write-Color '[Installing]', 'VMWare Tools:', ' Not a VMWare VM' -Color Yellow, Cyan, DarkRed}
	} catch { Write-Warning "[Installing] VMWare Tools: Failed:`n $($_.Exception.Message)" }

} #end Function
