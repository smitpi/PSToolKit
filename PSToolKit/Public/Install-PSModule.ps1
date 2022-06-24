
<#PSScriptInfo

.VERSION 0.1.0

.GUID 2709e068-607f-4c46-a69d-e141f55a0505

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
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#
.SYNOPSIS
Uses a preconfigured json file or a newly created list of needed modules, and installs them.

.DESCRIPTION
Uses a preconfigured json file or a newly created list of needed modules, and installs them.

.PARAMETER List
Select the base or extended, to select one of the json config files.

.PARAMETER ModuleNamesList
Or specify a string list with module names.

.PARAMETER Repository
From which repository it will install.

.PARAMETER Scope
To which scope, allusers or currentuser.

.EXAMPLE
 Install-PSModule -List BaseModules -Repository PSGallery -Scope AllUsers  

#>
Function Install-PSModule {
	[Cmdletbinding(DefaultParameterSetName = 'List', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSModules')]
	PARAM(
		[Parameter(ParameterSetName = 'List')]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[string]$List = 'ExtendedModules',

		[Parameter(ParameterSetName = 'Other', ValueFromPipeline)]
		[string[]]$ModuleNamesList,	

		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[string]$Repository = 'PSGallery',

		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[validateset('CurrentUser', 'AllUsers')]
		[string]$Scope = 'AllUsers'
	)

	if ($Scope -like 'AllUsers') {
		$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
		
		if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
		else { Throw 'Must be running an elevated prompt to install in AllUsers'; exit }
	}

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	}
 catch { Write-Error 'Config path foes not exist'; exit }
 
	if ($List -like 'BaseModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) | ConvertFrom-Json).name }
	elseif ($List -like 'ExtendedModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) | ConvertFrom-Json).name }
	elseif ($ModuleNamesList) { $mods = $ModuleNamesList }

	if (-not($mods)) { throw 'Couldnt get a valid modules list'; exit }

	foreach ($mod in $mods) {
		Remove-Variable -Name PSModule -ErrorAction SilentlyContinue
		$PSModule = Get-Module -Name $mod | Sort-Object -Property Version -Descending | Select-Object -First 1
		if ([string]::IsNullOrEmpty($PSModule)) { $PSModule = Get-Module -Name $mod -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 }
		if ([string]::IsNullOrEmpty($PSModule)) {
			Write-Color '[Installing] ', $($mod), ' to Scope: ', $($Scope), ' from ', $($Repository) -Color Yellow, Cyan, Green, Cyan, Green, Cyan
			Install-Module -Name $mod -Scope $Scope -AllowClobber -Force -Repository $Repository
		}
		else {
			Write-Color '[Installing] ', "$($PSModule.Name): ", ' Already Installed ', "(Path: $($PSModule.Path))" -Color Yellow, Cyan, DarkRed, DarkGreen
			$OnlineMod = Find-Module -Name $mod -Repository $Repository
			if ($PSModule.Version -lt $OnlineMod.Version) {
				Write-Color "`t[Upgrading] ", "$($PSModule.Name): ", 'to version ', "$($OnlineMod.Version)" -Color Yellow, Cyan, Green, DarkRed
				try {
					Update-Module -Name $PSModule.Name -Scope $Scope -Force -ErrorAction Stop
				}
				catch {
					try {
						Install-Module -Name $PSModule.Name -Scope $Scope -Force -AllowClobber 
					}
					catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }
    }
			}
		}
	}
	
}# Function


$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	(Get-PSRepository).Name
}
Register-ArgumentCompleter -CommandName Install-PSModule -ParameterName Repository -ScriptBlock $scriptBlock
