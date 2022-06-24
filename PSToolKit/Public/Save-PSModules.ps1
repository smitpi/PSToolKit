
<#PSScriptInfo

.VERSION 0.1.0

.GUID 664da3ea-33f7-449d-81e2-9d6f36b69465

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
Created [24/06/2022_07:29] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Saves the modules to a local repo 

#> 


<#
.SYNOPSIS
Saves the modules to a local repo

.DESCRIPTION
Saves the modules to a local repo

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Save-PSModules -Export HTML -ReportPath C:\temp

#>

<#
.SYNOPSIS
Saves the modules to a local repo.

.DESCRIPTION
Saves the modules to a local repo.

.PARAMETER List
Select the base or extended, to select one of the json config files.

.PARAMETER ModuleNamesList
Or specify a string list with module names.

.PARAMETER Repository
To which repository it will download.

.EXAMPLE
Install-PSModule -List BaseModules -Repository LocalRepo

#>
Function Save-PSModules {
	[Cmdletbinding(DefaultParameterSetName = 'List', HelpURI = 'https://smitpi.github.io/PSToolKit/Save-PSModules')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'List')]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[string]$List = 'ExtendedModules',

		[Parameter(ParameterSetName = 'Other', ValueFromPipeline)]
		[string[]]$ModuleNamesList,	

		[Parameter(ParameterSetName = 'List')]
		[Parameter(ParameterSetName = 'Other')]
		[ValidateScript({if (Get-PSRepository -Name $_) {$true}
				else {Throw 'You need to create a local repo'}})]
		[string]$Repository
	)

	try {
		$RepoPath = Get-Item (Get-PSRepository -Name $Repository).SourceLocation
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path foes not exist'; exit }
	if ($List -like 'BaseModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) | ConvertFrom-Json).name }
	elseif ($List -like 'ExtendedModules') { $mods = (Get-Content (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) | ConvertFrom-Json).name }
	elseif ($ModuleNamesList) { $mods = $ModuleNamesList }

	if (-not($mods)) { throw 'Couldnt get a valid modules list'; exit }
	else {
		$mods | ForEach-Object {
			Write-Color '[Downloading] ', $($_), ' to folder: ', $($RepoPath.FullName) -Color Yellow, Cyan, Green, cyan, Green, DarkRed
			Save-Package -Name $_ -Provider NuGet -Source https://www.powershellgallery.com/api/v2 -Path $RepoPath.FullName | Out-Null
		}
	}
} #end Function

$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	(Get-PSRepository | Where-Object {$_.Name -notlike 'PSGallery'}).Name
}
Register-ArgumentCompleter -CommandName Save-PSModules -ParameterName Repository -ScriptBlock $scriptBlock
