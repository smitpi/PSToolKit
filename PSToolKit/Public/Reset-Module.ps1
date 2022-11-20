
<#PSScriptInfo

.VERSION 0.1.0

.GUID a3b21ac7-1f72-4da3-90ee-676272792a3f

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
Created [18/09/2022_17:37] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Removes and force import a module. 

#> 


<#
.SYNOPSIS
Removes and force import a module.

.DESCRIPTION
Removes and force import a module.

.PARAMETER Name
Name of the module to reset.

.EXAMPLE
Reset-Module PSToolkit

#>
Function Reset-Module {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Reset-Module')]
	[OutputType([System.Object[]])]
	[Alias('resmod')]
	PARAM(
		[Parameter(Position = 0, Mandatory, HelpMessage = 'Specify the name of the module.')]
		[alias('ModuleName')]
		[ValidateNotNullorEmpty()]
		[ValidateScript( { (Get-Module $_) -or (Get-Module $_ -ListAvailable) })]
		[string]$Name
	)

	try {
		$ModuleFullName = (Get-Module $name -ListAvailable -ErrorAction Stop)[0]
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			
	Write-PSMessage -Action Removing -Severity Information -BeforeMessage 'Module' -BeforeMessageColor Green -Object $ModuleFullName.Name -AfterMessage 'from', 'Memory' -AfterMessageColor green, Red
	Remove-Module -Name $ModuleFullName.Name -Force -ErrorAction SilentlyContinue
	Write-PSMessage -Action Importing -Severity Information -BeforeMessage 'Module' -BeforeMessageColor Green -Object $ModuleFullName.Name
	$NewImport = Import-Module -Name $ModuleFullName.Name -Force -PassThru
	$LatestImport = $NewImport | Sort-Object -Property Version -Descending | Select-Object -First 1
	Write-PSMessage -Action Complete -BeforeMessage "Module Count:`t" -BeforeMessageColor Green -Object $NewImport.Count -LinesBefore 2
	Write-PSMessage -Action Complete -BeforeMessage "Module Name:`t" -BeforeMessageColor Green -Object $LatestImport.Name
	Write-PSMessage -Action Complete -BeforeMessage 'Module Version:' -BeforeMessageColor Green -Object $LatestImport.Version
	Write-PSMessage -Action Complete -BeforeMessage "Module Path:`t" -BeforeMessageColor Green -Object $LatestImport.Path
} #end Function

$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
(Get-Module -ListAvailable).name | Where-Object {$_ -like "*$wordToComplete*"}}

Register-ArgumentCompleter -CommandName Reset-Module -ParameterName Name -ScriptBlock $scriptBlock
