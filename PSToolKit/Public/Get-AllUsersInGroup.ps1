
<#PSScriptInfo

.VERSION 0.1.0

.GUID 1ab86400-6c17-4900-9002-6403a575c654

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

.DESCRIPTION
 Recursively gets all nested users from a ad group

#>


<#
.SYNOPSIS
Get details of all users in a group

.DESCRIPTION
Get details of all users in a group

.PARAMETER GroupName
The AD Group to query

.PARAMETER DomainFQDN
Name of the domain

.PARAMETER Credential
Credentials to connect to that domain

.PARAMETER Export
Export the results

.PARAMETER ReportPath
Where to save the report

.EXAMPLE
Get-AllUsersInGroup -GroupName CTX -DomainFQDN internal.lab -Credential $cred

#>
function Get-AllUsersInGroup {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-AllUsersInGroup')]
	Param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupName,
		[Parameter(Mandatory = $true)]
		[string]$DomainFQDN,
		[Parameter(Mandatory = $true)]
		[PSCredential]$Credential,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[string]$ReportPath = $env:temp
	)
	$samgroup = Get-ADGroup $GroupName -Server $DomainFQDN -Credential $Credential
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] $($samgroup.SamAccountName.ToString())"

	$AllUsers = @()
	$AllUsers += Get-ADGroupMember $samgroup.SamAccountName -Server $DomainFQDN -Credential $Credential -Recursive -Verbose | ForEach-Object { Get-ADUser $_ -Properties * -Server $DomainFQDN -Credential $Credential -Verbose | Select-Object -Property SamAccountName, GivenName, Surname, EmailAddress, UserPrincipalName }

	if ($Export -eq 'Excel') {
		$AllUsers | Export-Excel -Path ($ReportPath + '\ADGroup-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -WorksheetName EventsRawData -AutoSize -AutoFilter -Title 'Events' -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot -FreezeTopRow -TableStyle Dark8 -BoldTopRow -ConditionalText $(
			New-ConditionalText Warning black orange
			New-ConditionalText Error white red
		)
 }

	if ($Export -eq 'HTML') {
		$AllUsers | Out-HtmlView -Title "$($env:COMPUTERNAME)" -FilePath ($ReportPath + '\ADGroup' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html') -DisablePaging -HideFooter -Style cell-border -FixedHeader -SearchHighlight

 }
	if ($Export -eq 'Host') { $AllUsers }
}