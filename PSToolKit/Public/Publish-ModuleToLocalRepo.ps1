
<#PSScriptInfo

.VERSION 0.1.0

.GUID 15ec255e-6e97-4009-8697-8d15806dce4e

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
Created [11/06/2022_18:22] Initial Script Creating

.PRIVATEDATA

#>


<#
.SYNOPSIS
Checks for required modules and upload all to your local repo.

.DESCRIPTION
Checks for required modules and upload all to your local repo.

.PARAMETER ManifestPaths
Path to the .psd1 file.

.PARAMETER Repository
Name of the local repository.

.EXAMPLE
Publish-ModuleToLocalRepo -ManifestPaths .\PSConfigFile\PSConfigFile\PSConfigFile.psd1 -Repository blah

#>
Function Publish-ModuleToLocalRepo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Publish-ModuleToLocalRepo')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ValueFromPipeline)]
		[string[]]$ManifestPaths,
		[Parameter(Mandatory)]
		[string]$Repository	
	)

	foreach ($Man in $ManifestPaths) {
		$ManifestPath = Get-Item $Man
		$ManifestData = Import-PowerShellDataFile -Path $ManifestPath.fullname
		if ($ManifestData.RequiredModules) {
			$ManifestData.RequiredModules | ForEach-Object {
				$Importmod = Import-Module $_ -Force -PassThru
				if (-not(Find-Module $Importmod.Name -Repository $Repository -ErrorAction SilentlyContinue)) { 
					Write-Color '[Uploading] ', 'Required Module ', $($Importmod.Name) -Color Yellow, Cyan, DarkRed
					Publish-Module -Name $Importmod.Name -Repository $Repository -Force 
				}
				else { Write-Color '[Uploading] ', 'Module ', $($Importmod.Name), '  Already Uploaded' -Color Yellow, Cyan, green, DarkRed }
			}
		}
		try {
			$NewImport = Import-Module (Get-Item $ManifestPath.fullname.Replace('.psd1', '.psm1')) -Force -PassThru
		}
		catch { $NewImport = Import-Module $ManifestPath.Directory.Name -Force -PassThru }
		if (-not(Find-Module $NewImport.Name -Repository $Repository -ErrorAction SilentlyContinue)) {
			Write-Color '[Uploading] ', 'Module ', $($NewImport.Name) -Color Yellow, Cyan, DarkRed
			Publish-Module -Name $NewImport.Name -Repository $Repository -Force
		}
		else { Write-Color '[Uploading] ', 'Module ', $($NewImport.Name), '  Already Uploaded' -Color Yellow, Cyan, green, DarkRed }
	}
} #end Function

$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
    
	(Get-PSRepository).Name
}
Register-ArgumentCompleter -CommandName Publish-ModuleToLocalRepo -ParameterName Repository -ScriptBlock $scriptBlock

