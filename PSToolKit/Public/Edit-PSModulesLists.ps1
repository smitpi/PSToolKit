
<#PSScriptInfo

.VERSION 0.1.0

.GUID fdd27872-ece5-47bd-97e9-4ece001ce929

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
Created [28/01/2022_11:44] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Edit the json config files

#>


<#
.SYNOPSIS
Edit the Modules json files.

.DESCRIPTION
Edit the Modules json files.

.PARAMETER List
Which list to edit.

.PARAMETER ShowCurrent
Currently in the list

.PARAMETER RemoveModule
Remove form the list

.PARAMETER AddModule
Add to the list

.PARAMETER ModuleName
What module to add.

.EXAMPLE
Edit-PSModulesLists -ShowCurrent

#>
Function Edit-PSModulesLists {
	[Cmdletbinding(DefaultParameterSetName = 'List'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Edit-PSModulesLists')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$List,
		[Parameter(ParameterSetName = 'List')]
		[switch]$ShowCurrent,
		[Parameter(ParameterSetName = 'Remove')]
		[switch]$RemoveModule,
		[Parameter(ParameterSetName = 'Add')]
		[switch]$AddModule,
		[Parameter(ParameterSetName = 'Add')]
		[string]$ModuleName
	)

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	}
 catch { Write-Error 'Config path foes not exist'; exit }
	if ($List -like 'BaseModules') { $ModuleList = (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) }
	if ($List -like 'ExtendedModules') { $ModuleList = (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) }

	[System.Collections.ArrayList]$mods = Get-Content $ModuleList | ConvertFrom-Json
	function ListStuff {
		PARAM($arg)
		$index = 0
		foreach ($inst in $arg) {
			Write-Color "$($index)) ", $($inst) -Color Cyan, Yellow
			++$index
		}
	}

	if ($ShowCurrent) { ListStuff -arg $mods.name }
	if ($RemoveModule) {
		do {
			Clear-Host
			ListStuff $mods.name
			Write-Color 'Q) ', 'To Exit'
			$select = Read-Host 'Make a selection'
			if ($select.ToUpper() -ne 'Q') { $mods.RemoveAt($select) }
		}
		until ($select.toupper() -eq 'Q')

		$SortMods =  $mods | Sort-Object -Property Name -Unique 
        $SortMods | ConvertTo-Json -Depth 3 | Set-Content -Path $ModuleList -Force
		[System.Collections.ArrayList]$mods = Get-Content $ModuleList | ConvertFrom-Json
		ListStuff $mods.name

	}
	if ($AddModule) {
		$findmods = Find-Module -Filter $ModuleName 
		if ($findmods.Name.count -gt 1) {
			ListStuff -arg $findmods.name
			$select = Read-Host 'Make a selection: '
            $selectMod = $findmods[$select]
			$mods.Add(@{Name = "$($selectMod.name)" }) | Out-Null
		}
		elseif ($findmods.Name.count -eq 1) {
			$mods.Add(@{Name = "$ModuleName" }) | Out-Null
		}
		else { Write-Error "Could not find $($ModuleName);quit" }

		$SortMods =  $mods | Sort-Object -Property Name -Unique 
        $SortMods | ConvertTo-Json -Depth 3 | Set-Content -Path $ModuleList -Force
		[System.Collections.ArrayList]$mods = Get-Content $ModuleList | ConvertFrom-Json
		ListStuff $mods.name
	}
} #end Function
