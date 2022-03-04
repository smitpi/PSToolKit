PARAM(
	[Parameter(Mandatory = $true)]
	[ValidateSet('Combine', 'Build')]
	[string]$Update
)

Get-Module PSToolKit | Remove-Module -Force
Import-Module 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\PSToolKit\Public\Set-PSProjectFiles.ps1' -Force
try {
	Copy-Item 'C:\Program Files\PSToolKit\Config\*' -Destination 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\PSToolKit\Private' -Force -ErrorAction Stop -Verbose
} catch {Write-Warning 'cant copy files'}


if ($Update -like 'Build') {
	try {
		Remove-Item 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\docs' -Force -Recurse -ErrorAction Stop
		Remove-Item 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\Output' -Force -Recurse -ErrorAction Stop
		Remove-Item 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\Issues.xlsx' -Force -ErrorAction Stop
	} catch {Write-Warning 'cant delete files'}
	Set-PSProjectFiles -ModulePSM1 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\PSToolKit\PSToolKit.psm1' -VersionBump Build -mkdocs gh-deploy
} else {
	Set-PSProjectFiles -ModulePSM1 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\PSToolKit\PSToolKit.psm1' -VersionBum CombineOnly
}

$newmod = ((Get-ChildItem -Path 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\Output\') | Sort-Object -Property Name -Descending)[0]
Get-ChildItem -Directory 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit' | Compress-Archive -DestinationPath 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit\oldmodule.zip' -Update
Get-ChildItem -Directory 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit' | Remove-Item -Recurse -Force
Copy-Item -Path $newmod.FullName -Destination 'C:\Program Files\WindowsPowerShell\Modules\PSToolKit\' -Force -Verbose -Recurse