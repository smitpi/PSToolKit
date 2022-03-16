
<#PSScriptInfo

.VERSION 0.1.0

.GUID 15d59d48-9d26-49c5-aeca-1b629763f036

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS choco

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [19/01/2022_22:17] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Search the online repo for software

#>


<#
.SYNOPSIS
Search the online repo for software

.DESCRIPTION
Search the online repo for software

.PARAMETER SearchString
What to search for.

.PARAMETER SelectTop
Limit the results

.PARAMETER GridView
Open in grid view.

.PARAMETER TableView
Open in table view.

.EXAMPLE
Find-ChocolateyApps -SearchString Citrix

#>
Function Find-ChocolateyApps {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Find-ChocolateyApps')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$SearchString,
		[int]$SelectTop = 25,
		[switch]$GridView = $false,
		[switch]$TableView = $false
	)

	[System.Collections.ArrayList]$AllAppDetail = @()
	Write-Color '[Collecting] ', 'Top ', "$($SelectTop) ", 'apps', " (Search: $($SearchString))" -Color Yellow, Cyan, Yellow, Cyan, Yellow

	$allapps = choco search $SearchString --limit-output --order-by-popularity --source chocolatey | Select-Object -First $SelectTop
	foreach ($app in $allapps) {
		$appdetail = (choco info ($app -split '\|')[0])
		Write-Color '[Processing] ', "$(($app -split '\|')[0])" -Color Yellow, Cyan

		if (($app -split '\|')[0]) {$ID = ($app -split '\|')[0]}
		if ($appdetail[2].Split('|')[0].split(':')[1]) {$Title = ($appdetail[2].Split('|')[0].split(':')[1] | Out-String).Trim()}
		if ($appdetail[2].Split('|')[1].split(':')[1]) {$Published = [DateTime]($appdetail[2].Split('|')[1].split(':')[1] | Out-String).Trim() }
		if (($appdetail[5].Split('|').split(':')[1])) {$downloads = ($appdetail[5].Split('|').split(':')[1] | Out-String).Trim()}
		if (($appdetail | Where-Object { $_ -like '*Summary*' })) {$sum = ($appdetail | Where-Object { $_ -like '*Summary*' }).replace(' Summary: ', '')}
		if (($appdetail | Where-Object { $_ -like '*Description*' })) {$disc = ($appdetail | Where-Object { $_ -like '*Description*' }).replace(' Description: ', '')}

		[void]$AllAppDetail.Add([PSCustomObject]@{
				id          = $ID
				Title       = $Title
				Published   = $Published
				Downloads   = ($appdetail[5].Split('|').split(':')[1] | Out-String).Trim()
				Summary     = ($appdetail | Where-Object { $_ -like '*Summary*' }).replace(' Summary: ', '')
				Description = ($appdetail | Where-Object { $_ -like '*Description*' }).replace(' Description: ', '')
			})
	}

	if ($GridView) {
		$selected = $AllAppDetail | Out-GridView -OutputMode Multiple
		Write-Color 'Apps Selected' -Color Green
		$selected.id
		$selected.id | Out-Clipboard
	} elseif ($TableView) {$AllAppDetail | Format-Table -AutoSize}
	else {$AllAppDetail}
} #end Function
