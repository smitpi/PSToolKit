
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3b0bff71-01b7-4383-b539-798ea6b03096

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ad

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [27/05/2022_08:34] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Compare two users AD group memberships 

#> 

<#
.SYNOPSIS
Compare two users AD group memberships

.DESCRIPTION
Compare two users AD group memberships

.PARAMETER ReferenceUser
First user name.

.PARAMETER DifferenceUser
Second user name

.PARAMETER DomainFQDN
Domain to search

.PARAMETER DomainCredential
Userid to connect to that domain.

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$compare = Compare-ADMembership -ReferenceUser ps -DifferenceUser ctxuser1

#>
Function Compare-ADMembership {
	[Cmdletbinding(DefaultParameterSetName = 'CurrentDomain', HelpURI = 'https://smitpi.github.io/PSToolKit/Compare-ADMembership')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$ReferenceUser,

		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$DifferenceUser,

		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[string]$DomainFQDN,

		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[pscredential]$DomainCredential,

		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[ValidateSet('Excel', 'Host', 'HTML')]
		[string]$Export = 'Host',

		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	if ($null -notlike $DomainFQDN) {
		if (-not($DomainCredential)) {$DomainCredential = Get-Credential -Message "Account to connnect to $($DomainFQDN)"}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		try {
			$FullReferenceUser = Get-ADUser -Identity $ReferenceUser -Properties * -Server $DomainFQDN -Credential $DomainCredential
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		try {
			$FullDifferenceUser = Get-ADUser -Identity $DifferenceUser -Properties * -Server $DomainFQDN -Credential $DomainCredential
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}

		$Compare = Compare-Object -ReferenceObject $FullReferenceUser.memberof -DifferenceObject $FullDifferenceUser.memberof -IncludeEqual

		$DiffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '<='}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			$ADgroup = Get-ADGroup -Identity $_ -Server $NewDomain -Credential $DomainCredential
			[PSCustomObject]@{
				UserName               = $FullDifferenceUser.DisplayName
				UserSamAccountName     = $FullDifferenceUser.SamAccountName
				UserUPN                = $FullDifferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$ReffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '=>'}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			$ADgroup = Get-ADGroup -Identity $_ -Server $NewDomain -Credential $DomainCredential
			[PSCustomObject]@{
				UserName               = $FullReferenceUser.DisplayName
				UserSamAccountName     = $FullReferenceUser.SamAccountName
				UserUPN                = $FullReferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$EqualMembers = ($Compare | Where-Object {$_.SideIndicator -like '=='}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			Get-ADGroup -Identity $_ -Server $NewDomain -Credential $DomainCredential | Select-Object Name, DistinguishedName
		}
		
		$data = [PSCustomObject]@{
			DiffUserMissing = $DiffUserMissing
			ReffUserMissing = $ReffUserMissing
			EqualMembers    = $EqualMembers
		}
	} else {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		try {
			$FullReferenceUser = Get-ADUser -Identity $ReferenceUser -Properties *
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		try {
			$FullDifferenceUser = Get-ADUser -Identity $DifferenceUser -Properties *
		} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}

		$Compare = Compare-Object -ReferenceObject $FullReferenceUser.memberof -DifferenceObject $FullDifferenceUser.memberof -IncludeEqual

		$DiffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '<='}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			$ADgroup = Get-ADGroup -Identity $_ -Server $NewDomain
			[PSCustomObject]@{
				UserName               = $FullDifferenceUser.DisplayName
				UserSamAccountName     = $FullDifferenceUser.SamAccountName
				UserUPN                = $FullDifferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$ReffUserMissing = ($Compare | Where-Object {$_.SideIndicator -like '=>'}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			$ADgroup = Get-ADGroup -Identity $_ -Server $NewDomain
			[PSCustomObject]@{
				UserName               = $FullReferenceUser.DisplayName
				UserSamAccountName     = $FullReferenceUser.SamAccountName
				UserUPN                = $FullReferenceUser.UserPrincipalName
				GroupName              = $ADgroup.Name
				GroupDistinguishedName = $ADgroup.DistinguishedName
			}
		}
		$EqualMembers = ($Compare | Where-Object {$_.SideIndicator -like '=='}).InputObject | ForEach-Object {
			$Cname = $_
			$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
			$NewDomain = Join-String -Strings $Split -Separator .
			Get-ADGroup -Identity $_ -Server $NewDomain | Select-Object Name, DistinguishedName
		}
		

		$Data = [PSCustomObject]@{
			DiffUserMissing = $DiffUserMissing
			ReffUserMissing = $ReffUserMissing
			EqualMembers    = $EqualMembers
		}
	}
	if ($Export -like 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\AD_MemberShip-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$Data.ReffUserMissing | Export-Excel -Title 'Reference User Missing' -WorksheetName ADMemberShip @ExcelOptions
		$Data.DiffUserMissing | Export-Excel -Title 'Difference User Missing' -WorksheetName ADMemberShip @ExcelOptions -StartRow ($data.ReffUserMissing.count + 4)
		$Data.EqualMembers.name | Export-Excel -Title 'Equal Members' -WorksheetName ADMemberShip @ExcelOptions -StartRow (($data.ReffUserMissing.count + 4) + ($data.DiffUserMissing.count + 4))
	}

	if ($Export -eq 'HTML') {
		$ReportTitle = 'AD MemberShip'

		$TableSettings = @{
			SearchHighlight = $True
			Style           = 'cell-border'
			ScrollX         = $true
			HideButtons     = $true
			HideFooter      = $true
			FixedHeader     = $true
			TextWhenNoData  = 'No Data to display here'
			ScrollCollapse  = $true
			ScrollY         = $true
			DisablePaging   = $true
		}
		$SectionSettings = @{
			BackgroundColor       = 'LightGrey'
			CanCollapse           = $true
			HeaderBackGroundColor = '#00203F'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#ADEFD1'
			HeaderTextSize        = '15'
			BorderRadius          = '20px'
		}
		$TableSectionSettings = @{
			BackgroundColor       = 'LightGrey'
			CanCollapse           = $true
			HeaderBackGroundColor = '#ADEFD1'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#00203F'
			HeaderTextSize        = '15'
			BorderRadius          = '20px'
		}

		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
			}
			New-HTMLSection @SectionSettings -HeaderText 'Refferencing User' {
				New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($data.ReffUserMissing) @TableSettings}
			}
			New-HTMLSection @SectionSettings -HeaderText 'Differencing User' {
				New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($data.DiffUserMissing) @TableSettings}
			}
			New-HTMLSection @SectionSettings -HeaderText 'Eqeal Groups' {
				New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($data.EqualMembers) @TableSettings}
			}
		}
 }

 if ($Export -eq 'Host') {$data}

} #end Function
