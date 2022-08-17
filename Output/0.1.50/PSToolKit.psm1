#region Public Functions
#region Add-ChocolateyPrivateRepo.ps1
######## Function 1 of 95 ##################
# Function:         Add-ChocolateyPrivateRepo
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Add a private repository to Chocolatey.
#############################################
 
<#
.SYNOPSIS
Add a private repository to Chocolatey.

.DESCRIPTION
Add a private repository to Chocolatey.

.PARAMETER RepoName
Name of the repo

.PARAMETER RepoURL
URL of the repo

.PARAMETER Priority
Priority of server, 1 being the highest.

.PARAMETER RepoApiKey
API key to allow uploads to the server.

.PARAMETER DisableCommunityRepo
Disable the community repo, and will only use the private one.

.EXAMPLE
Add-ChocolateyPrivateRepo -RepoName XXX -RepoURL https://choco.xxx.lab/chocolatey -Priority 3

#>
Function Add-ChocolateyPrivateRepo {
  [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Add-ChocolateyPrivateRepo')]
  PARAM(
    [Parameter(Mandatory = $true)]
    [ValidateScript( {
        $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
        else { Throw 'Must be running an elevated prompt to use this fuction.' } })]
    [string]$RepoName,
    [Parameter(Mandatory = $true)]
    [string]$RepoURL,
    [Parameter(Mandatory = $true)]
    [int]$Priority,
    [string]$RepoApiKey,
    [switch]$DisableCommunityRepo
  )

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {Install-ChocolateyClient}

  [System.Collections.ArrayList]$sources = @()
  choco source list --limit-output | ForEach-Object {
    [void]$sources.Add([pscustomobject]@{
        Name     = $_.split('|')[0]
        URL      = $_.split('|')[1]
        Priority = $_.split('|')[5]
      })
  }
  $RepoExists = $RepoURL -in $sources.Url
  if (!$RepoExists) {
    try {
      choco source add --name="$($RepoName)" --source=$($RepoURL) --priority=$($Priority) --limit-output
      [void]$sources.add([pscustomobject]@{
          Name     = $($RepoName)
          URL      = $($RepoURL)
          Priority = $($Priority)
        })
      Write-Color '[Installing]', 'Chocolatey Private Repo: ', 'Complete' -Color Yellow, Cyan, Green
      Write-Output $sources
      Write-Output '_______________________________________'
    } catch { Write-Warning "[Installing] Chocolatey Private Repo Failed:`n $($_.Exception.Message)" }

  } else {
    Write-Color '[Installing]', "Chocolatey Private Repo $($RepoName): ", 'Already Exists' -Color Yellow, Cyan, DarkRed
  }

  if ($null -notlike $RepoApiKey) {
    choco apikey --source="$($RepoURL)" --api-key="$($RepoApiKey)" --limit-output | Out-Null
    if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing APIKey Code: $($LASTEXITCODE)"}
    else {Write-Color '[Installing] ', 'RepoAPIKey: ', 'Complete' -Color Yellow, Cyan, Green}
  }
  if ($DisableCommunityRepo) {
    choco source disable --name=chocolatey --limit-output | Out-Null
    if ($LASTEXITCODE -ne 0) {Write-Warning "Error disabling repo Code: $($LASTEXITCODE)"}
    else {Write-Color '[Disabling] ', 'Chocolatey Repo: ', 'Complete' -Color Yellow, Cyan, Green}
  }


} #end Function
 
Export-ModuleMember -Function Add-ChocolateyPrivateRepo
#endregion
 
#region Backup-ElevatedShortcut.ps1
######## Function 2 of 95 ##################
# Function:         Backup-ElevatedShortcut
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Exports the RunAss shortcuts, to a zip file
#############################################
 
<#
.SYNOPSIS
Exports the RunAss shortcuts, to a zip file

.DESCRIPTION
Exports the RunAss shortcuts, to a zip file

.PARAMETER ExportPath
Path for the zip file

.EXAMPLE
Backup-ElevatedShortcut -ExportPath c:\temp

#>
Function Backup-ElevatedShortcut {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Backup-ElevatedShortcut')]
    PARAM(
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ExportPath = "$env:TEMP"
				)


    if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }
    if ((Test-Path -Path C:\Temp\Tasks) -eq $false) { New-Item -Path C:\Temp\Tasks -ItemType Directory -Force -ErrorAction SilentlyContinue }

    Get-ScheduledTask -TaskPath '\RunAs\' | ForEach-Object { Export-ScheduledTask -TaskName "\RunAs\$($_.TaskName)" | Out-File "C:\Temp\Tasks\$($_.TaskName).xml" }
    $Destination = [IO.Path]::Combine((Get-Item $ExportPath).FullName, "$($env:COMPUTERNAME)_RunAss_Shortcuts_$(Get-Date -Format ddMMMyyyy_HHmm).zip")
    Compress-Archive -Path C:\Temp\Tasks -DestinationPath $Destination -CompressionLevel Fastest
    Remove-Item -Path C:\Temp\Tasks -Recurse


} #end Function
 
Export-ModuleMember -Function Backup-ElevatedShortcut
#endregion
 
#region Backup-PowerShellProfile.ps1
######## Function 3 of 95 ##################
# Function:         Backup-PowerShellProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Creates a zip file from the ps profile directories
#############################################
 
<#
.SYNOPSIS
Creates a zip file from the ps profile directories

.DESCRIPTION
Creates a zip file from the ps profile directories

.PARAMETER ExtraDir
Another Directory to add to the zip file

.PARAMETER DestinationPath
Where the zip file will be saved.

.EXAMPLE
Backup-PowerShellProfile -DestinationPath c:\temp

#>
Function Backup-PowerShellProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Backup-PowerShellProfile')]

    PARAM(
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ExtraDir,
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$DestinationPath = $([Environment]::GetFolderPath('MyDocuments'))
    )
    try {
        $ps = [IO.Path]::Combine($([Environment]::GetFolderPath('MyDocuments')), 'PowerShell')
        $wps = [IO.Path]::Combine($([Environment]::GetFolderPath('MyDocuments')), 'WindowsPowerShell')
        $SourceDir = @()
        if (Test-Path $ps) { $SourceDir += (Get-Item $ps).FullName }
        if (Test-Path $wps) { $SourceDir += (Get-Item $wps).FullName }
        if ([bool]$ExtraDir) { $SourceDir += (Get-Item $ExtraDir).fullname }
        $Destination = [IO.Path]::Combine((Get-Item $DestinationPath).FullName, "$($env:COMPUTERNAME)_Powershell_Profile_Backup_$(Get-Date -Format ddMMMyyyy_HHmm).zip")
    }
    catch { Write-Error 'Unable to get directories' }

    try {
        Compress-Archive -Path $SourceDir -DestinationPath $Destination -CompressionLevel Fastest
    }
    catch { Write-Error 'Unable to create zip file' }
} #end Function
 
Export-ModuleMember -Function Backup-PowerShellProfile
#endregion
 
#region Compare-ADMembership.ps1
######## Function 4 of 95 ##################
# Function:         Compare-ADMembership
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/29 11:35:51
# Synopsis:         Compare two users AD group memberships
#############################################
 
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
 
Export-ModuleMember -Function Compare-ADMembership
#endregion
 
#region Connect-VMWareCluster.ps1
######## Function 5 of 95 ##################
# Function:         Connect-VMWareCluster
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Connect to a vSphere cluster to perform other commands or scripts
#############################################
 
<#
.SYNOPSIS
Connect to a vSphere cluster to perform other commands or scripts

.DESCRIPTION
Connect to a vSphere cluster to perform other commands or scripts

.PARAMETER vCenterIp
vCenter IP or name

.PARAMETER vCenterUser
Username to connect with

.PARAMETER vCentrePass
Secure string

.EXAMPLE
Connect-VMWareCluster -vCenterUser $vCenterUser -vCentrePass $vCentrePass

#>
Function Connect-VMWareCluster {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Connect-VMWareCluster')]
    Param(
        [string]$vCenterIp,
        [string]$vCenterUser,
        [securestring]$vCentrePass
    )

    #$vCenterCred = Get-Credential -Message VCSA -UserName $vCenterUser
    #$vCenterPass = 'qqq' # password

    # Ignore unsigned ssl certificates and increase the http timeout value
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -Confirm:$false | Out-Null

    # Connect to vCenter server
    Connect-VIServer -Server $vCenterIp -User $vCenterUser -Password $vCentrePass

} #end Function
 
Export-ModuleMember -Function Connect-VMWareCluster
#endregion
 
#region Edit-ChocolateyAppsList.ps1
######## Function 6 of 95 ##################
# Function:         Edit-ChocolateyAppsList
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/11 02:59:04
# Synopsis:         Add or remove apps from the json file used in Install-ChocolateyApps
#############################################
 
<#
.SYNOPSIS
Add or remove apps from the json file used in Install-ChocolateyApps


.DESCRIPTION
Add or remove apps from the json file used in Install-ChocolateyApps


.PARAMETER ShowCurrent
List current apps in the json file

.PARAMETER AddApp
add an app to the list.

.PARAMETER ChocoID
Name or ID of the app.

.PARAMETER ChocoSource
The source where the app is hosted

.PARAMETER RemoveApp
Remove app from the list

.PARAMETER List
Which list to use.

.EXAMPLE
Edit-ChocolateyAppsList -AddApp -ChocoID 7zip -ChocoSource chocolatey

#>
Function Edit-ChocolateyAppsList {
	[Cmdletbinding(DefaultParameterSetName = 'Current', HelpURI = 'https://smitpi.github.io/PSToolKit/Edit-ChocolateyAppsList')]
	PARAM(
		[ValidateSet('BaseApps', 'ExtendedApps')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$List = 'ExtendedApps',
		[Parameter(ParameterSetName = 'Current')]
		[switch]$ShowCurrent,
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Remove')]
		[switch]$RemoveApp,
		[Parameter(ParameterSetName = 'Add')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$AddApp,
		[Parameter(ParameterSetName = 'Add')]
		[string]$ChocoSource = 'chocolatey'
	)

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path foes not exist'; exit }

	if ($List -like 'BaseApps') { $AppList = (Join-Path $ConPath.FullName -ChildPath BaseAppList.json) }
	if ($List -like 'ExtendedApps') { $AppList = (Join-Path $ConPath.FullName -ChildPath ExtendedAppsList.json) }


	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
	function ListApps {
		PARAM($arg)
		$index = 0
		foreach ($inst in $arg) {
			Write-Color "$($index)) ", $($inst) -Color Cyan, Yellow
			++$index
		}
	}

	if ($ShowCurrent) { listapps $installs.name }

	if ($RemoveApp) {
		do {
			Clear-Host
			ListApps $installs.name
			Write-Color 'Q) ', 'To Exit'
			$select = Read-Host 'Make a selection'
			if ($select.ToUpper() -ne 'Q') { $installs.RemoveAt($select) }
		}
		until ($select.toupper() -eq 'Q')
		$installs | Sort-Object -Property Name -Unique | ConvertTo-Json | Set-Content -Path $AppList
		[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
		ListApps $installs.name
	}

	if (-not($RemoveApp) -and -not($ShowCurrent	)) {
		$AppSearch = choco search $($AddApp) --source=$($ChocoSource) --limit-output | ForEach-Object { ($_ -split '\|')[0] }
		if ($null -like $AppSearch) { Write-Error "Could not find the app in source: $($ChocoSource)" }
		if ($AppSearch.count -eq 1) {
			$tmp = New-Object -TypeName psobject -Property @{
				'Name'   = $AddApp
				'Source' = $ChocoSource
			}
			$installs.Add($tmp)
		}
		if ($AppSearch.count -gt 1) {
			ListApps $AppSearch
			$select = Read-Host 'Make a selection: '
			$tmp = New-Object -TypeName psobject -Property @{
				'Name'   = $AppSearch[$select]
				'Source' = $ChocoSource
			}
			$installs.Add($tmp)
		}
		$installs | Sort-Object -Property Name -Unique | ConvertTo-Json | Set-Content -Path $AppList
		[System.Collections.ArrayList]$installs = Get-Content $AppList | ConvertFrom-Json
		ListApps $installs.name
	}

} #end Function

Register-ArgumentCompleter -CommandName Edit-ChocolateyAppsList -ParameterName ChocoSource -ScriptBlock {
	choco source --limit-output | ForEach-Object { ($_ -split '\|')[0] }
}
 
Export-ModuleMember -Function Edit-ChocolateyAppsList
#endregion
 
#region Edit-HostsFile.ps1
######## Function 7 of 95 ##################
# Function:         Edit-HostsFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Edit the hosts file
#############################################
 
<#
.SYNOPSIS
Edit the hosts file

.DESCRIPTION
Edit the hosts file

.PARAMETER ShowCurrent
Show existing entries

.PARAMETER Remove
Remove an entry

.PARAMETER RemoveText
What to remove, either ip fqdn or host

.PARAMETER Add
Add an entry

.PARAMETER AddIP
Ip to add.

.PARAMETER AddFQDN
FQDN to add

.PARAMETER AddHost
Host to add.

.PARAMETER OpenInNotepad
Open the file in notepad.

.EXAMPLE
Edit-HostsFile -Remove -RemoveText blah

#>
Function Edit-HostsFile {
	[Cmdletbinding(DefaultParameterSetName = 'Show', HelpURI = 'https://smitpi.github.io/PSToolKit/Edit-HostsFile')]
	PARAM(
		[Parameter(ParameterSetName = 'Show')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$ShowCurrent,
		[Parameter(ParameterSetName = 'Remove')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$Remove,
		[Parameter(ParameterSetName = 'Remove')]
		[string]$RemoveText,
		[Parameter(ParameterSetName = 'Add')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$Add,
		[Parameter(ParameterSetName = 'Add')]
		[string]$AddIP,
		[Parameter(ParameterSetName = 'Add')]
		[string]$AddFQDN,
		[Parameter(ParameterSetName = 'Add')]
		[string]$AddHost,
		[Parameter(ParameterSetName = 'Notepad')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$OpenInNotepad
	)

	$HostFile = Get-Item ([IO.Path]::Combine($env:windir, 'System32', 'Drivers', 'etc', 'hosts'))
	function ListDetails {
		PARAM($arg)
		$index = 0
		foreach ($inst in $arg) {
			Write-Color "$($index)) ", "$($inst.IP) ", "$($inst.FQDN) ", "$($inst.Host)" -Color Cyan, Yellow, Yellow, Yellow
			++$index
		}
	}

	function getcurrent {
		$script:CurrentHostsFile = Get-Content $HostFile.FullName
		[System.Collections.ArrayList]$script:CurrentHostsFileFiltered = @()
		$script:CurrentHostsFile | Where-Object { $_ -notlike '#*' -and $_ -notlike $null } | ForEach-Object {
			[void]$script:CurrentHostsFileFiltered.Add([pscustomobject]@{
					IP   = $_.split(' ')[0]
					FQDN = $_.split(' ')[1]
					Host = $_.split(' ')[2]
				})
		}
	}

	if ($OpenInNotepad) { notepad.exe $HostFile.FullName }
	if ($ShowCurrent) {
		getcurrent
		ListDetails $CurrentHostsFileFiltered
	}
	if ($Remove) {
		getcurrent
		Copy-Item -Path $HostFile.FullName -Destination (Join-Path -Path $HostFile.Directory.FullName -ChildPath "hosts_$(Get-Date -Format yyyyMMdd_HHmm)")
		$CurrentHostsFile | Where-Object { $_ -notlike "*$RemoveText*" } | Set-Content $HostFile.FullName
		getcurrent
		ListDetails $CurrentHostsFileFiltered

	}
	if ($Add) {
		Copy-Item -Path $HostFile.FullName -Destination (Join-Path -Path $HostFile.Directory.FullName -ChildPath "hosts_$(Get-Date -Format yyyyMMdd_HHmm)")
		getcurrent
		[void]$CurrentHostsFileFiltered.Add([pscustomobject]@{
				IP   = $AddIP
				FQDN = $AddFQDN
				Host = $AddHost
			})
		$NewHostsFile = [System.Collections.Generic.List[string]]::new()
		$CurrentHostsFile | Where-Object { $_ -like '#*' } | ForEach-Object { $NewHostsFile.Add($_) }
		$CurrentHostsFileFiltered | ForEach-Object { $NewHostsFile.Add("$($_.IP)`t$($_.FQDN)`t$($_.Host)") }
		$NewHostsFile | Set-Content $HostFile.FullName
		getcurrent
		ListDetails $CurrentHostsFileFiltered
	}
} #end Function
 
Export-ModuleMember -Function Edit-HostsFile
#endregion
 
#region Edit-SSHConfigFile.ps1
######## Function 8 of 95 ##################
# Function:         Edit-SSHConfigFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Creates and modifies the ssh config file in their profile.
#############################################
 
<#
.SYNOPSIS
Creates and modifies the ssh config file in their profile.

.DESCRIPTION
Creates and modifies the ssh config file in their profile.

.PARAMETER Show
Show current records.

.PARAMETER Remove
Remove a record

.PARAMETER RemoveString
Looks for a record in host and hostname, and removes it.

.PARAMETER Add
Add a record.

.PARAMETER AddObject
Adds an entry from a already created object.

.PARAMETER OpenInNotepad
Open the config file in notepad

.EXAMPLE
$rr = [PSCustomObject]@{
	Host         = 'esx00'
	HostName     = '192.168.10.19'
	User         = 'root'
	Port         = '22'
	IdentityFile = 'C:\Users\xx\.ssh\yyy.id'
}
Edit-SSHConfigFile -AddObject $rr

#>
Function Edit-SSHConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'List', HelpURI = 'https://smitpi.github.io/PSToolKit/Edit-SSHConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'List')]
		[switch]$Show,
		[Parameter(ParameterSetName = 'remove')]
		[switch]$Remove,
		[Parameter(ParameterSetName = 'removestring')]
		[string]$RemoveString,
		[Parameter(ParameterSetName = 'add')]
		[switch]$Add,
		[Parameter(ParameterSetName = 'addobject')]
		[PSCustomObject]$AddObject,
		[Parameter(ParameterSetName = 'notepad')]
		[switch]$OpenInNotepad
	)

	$SSHconfig = [IO.Path]::Combine($env:USERPROFILE, '.ssh', 'Config')
	try {
		$SSHconfigFile = Get-Item $SSHconfig
	} catch {
		Write-Warning 'Config file not found, Creating new file'
		$out = "##########################`n"
		$out += "# Managed by PSToolKit`n"
		$out += "##########################`n"
		$out | Set-Content $SSHconfig -Force
		$SSHconfigFile = Get-Item $SSHconfig
	}

	$content = Get-Content $SSHconfigFile.FullName

	if ($content[1] -notcontains '# Managed by PSToolKit') {
		Write-Warning 'Not managed by PStoolKit, Creating new file'
		Rename-Item -Path $SSHconfigFile.FullName -NewName "config_$(Get-Date -Format yyyyMMdd_HHmm)"
		$out = "##########################`n"
		$out += "# Managed by PSToolKit`n"
		$out += "##########################`n"
		$out | Set-Content $SSHconfigFile.FullName -Force
	}
	$index = 3
	[System.Collections.ArrayList]$SSHObject = @()
	$content | Where-Object {$_ -like 'Host*'} | ForEach-Object {
		[void]$SSHObject.Add([PSCustomObject]@{
				Host         = $($content[$index + 0].replace('Host ', '').Trim())
				HostName     = $($content[$index + 1].replace('HostName ', '').Trim())
				User         = $($content[$index + 2].replace('User ', '').Trim())
				Port         = $($content[$index + 3].replace('Port ', '').Trim())
				IdentityFile = $($content[$index + 4].replace('IdentityFile ', '').Trim())
			})
		$index = $index + 5
	}

	function displayout {
		PARAM($object)
		$id = 0
		Write-Host ('    {0,-15} {1,-15} {2,-15} {3,-15} {4,-15}' -f 'host', 'hostname', 'user', 'Port', 'IdentityFile') -ForegroundColor DarkRed
		$Object | ForEach-Object {
			Write-Host ('{5}) {0,-15} {1,-15} {2,-15} {3,-15} {4,-15}' -f $($_.host), $($_.hostname), $($_.user), $($_.Port), $($_.IdentityFile), $($id)) -ForegroundColor Cyan
			++$id
		}
	}
	function writeout {
		PARAM($object)

		$sshfile = [System.Collections.Generic.List[string]]::new()
		$sshfile.Add('##########################')
		$sshfile.Add('# Managed by PSToolKit')
		$sshfile.Add('##########################')
		$object | ForEach-Object {
			$sshfile.Add("Host $($_.host)")
			$sshfile.Add("  HostName $($_.HostName)")
			$sshfile.Add("  User $($_.User)")
			$sshfile.Add("  Port $($_.Port)")
			$sshfile.Add("  IdentityFile $($_.IdentityFile)")
		}
		Set-Content -Path $SSHconfigFile.FullName -Value $sshfile -Force
		Write-Color '[Creating] ', 'New SSH Config File ', 'Complete' -Color Yellow, Cyan, Green
	}

	if ($null -notlike $AddObject) {
		[void]$SSHObject.add($AddObject)
		Clear-Host
		displayout $SSHObject
		writeout $SSHObject
	}
	if ($null -notlike $RemoveString) {
		$SSHObject.Remove(($SSHObject | Where-Object {$_.host -like "*$RemoveString*" -or $_.hostname -like "*$RemoveString*"}))
		Clear-Host
		displayout $SSHObject
		writeout $SSHObject
	}


	if ($OpenInNotepad) {& notepad.exe $SSHconfigFile.FullName}
	if ($Show) {
		Clear-Host
		displayout $SSHObject
	}
	if ($Remove) {
		do {
			$removerec = $null
			Clear-Host
			displayout $SSHObject
			$removerec = Read-Host 'id to remove'
			if ($null -notlike $removerec) {$SSHObject.RemoveAt($removerec)}
			$more = Read-Host 'Remove more (y/n)'
		} until ($more.ToUpper() -like 'N')
		writeout $SSHObject
	}
	if ($add) {
		do {
			Clear-Host
			Write-Color 'Supply the following Details:' -Color DarkRed -LinesAfter 2 -StartTab 1
			[void]$SSHObject.Add([PSCustomObject]@{
					Host         = Read-Host 'Host'
					HostName     = Read-Host 'HostName or IP'
					User         = Read-Host 'Username'
					Port         = Read-Host 'Port'
					IdentityFile = Read-Host 'IdentityFile'
				})
			$more = Read-Host 'Add more (y/n)'
		} until ($more.ToUpper() -like 'N')
		displayout $SSHObject
		writeout $SSHObject
	}

} #end Function
 
Export-ModuleMember -Function Edit-SSHConfigFile
#endregion
 
#region Enable-RemoteHostPSRemoting.ps1
######## Function 9 of 95 ##################
# Function:         Enable-RemoteHostPSRemoting
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         enable ps remote remotely
#############################################
 
<#
.SYNOPSIS
enable ps remote remotely

.DESCRIPTION
enable ps remote remotely

.PARAMETER ComputerName
The remote computer

.PARAMETER AdminCredentials
Credentials with admin access

.EXAMPLE
Enable-RemoteHostPSRemoting -ComputerName $host -AdminCredentials $cred

.NOTES
General notes
#>
Function Enable-RemoteHostPSRemoting {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Enable-RemoteHostPSRemoting')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript( { (Test-Connection -ComputerName $_ -Count 1 -Quiet) })]
		[string]$ComputerName,
		[pscredential]$AdminCredentials = (Get-Credential)
	)

	#.\psexec.exe \ServerB -h -s powershell.exe Enable-PSRemoting -Force
	$SessionArgs = @{
		ComputerName  = $ComputerName
		Credential    = $AdminCredentials
		SessionOption = New-CimSessionOption -Protocol Dcom
	}
	$MethodArgs = @{
		ClassName  = 'Win32_Process'
		MethodName = 'Create'
		CimSession = New-CimSession @SessionArgs
		Arguments  = @{
			CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force'"
		}
	}
	Invoke-CimMethod @MethodArgs
	Invoke-Command -ComputerName $ComputerName -ScriptBlock { Write-Output -InputObject $using:env:COMPUTERNAME : working } -HideComputerName

} #end Function
 
Export-ModuleMember -Function Enable-RemoteHostPSRemoting
#endregion
 
#region Export-ESXTemplate.ps1
######## Function 10 of 95 ##################
# Function:         Export-ESXTemplate
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Export all VM Templates from vSphere to local disk.
#############################################
 
<#
.SYNOPSIS
Export all VM Templates from vSphere to local disk.

.DESCRIPTION
Export all VM Templates from vSphere to local disk.

.PARAMETER ExportPath
Directory to export to

.EXAMPLE
Export-ESXTemplates -ExportPath c:\temp
#>
Function Export-ESXTemplate {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-ESXTemplates')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript( { (Test-Path $_) })]
		[System.IO.DirectoryInfo]$ExportPath)


	Get-Template | Sort-Object -Unique | ForEach-Object {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Exporting Template: $($_.name)"

		$template = Get-Template -Name $_.Name | Sort-Object -Unique
		$templatevm = Set-Template -Template $template -ToVM
		Get-Snapshot $templatevm | Remove-Snapshot -Confirm:$false
		$templatevm | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
		$templatevm | Export-VApp -Destination $ExportPath -Format Ova -Name $templatevm.Name -Force
		Get-VM $templatevm | Set-VM -ToTemplate -Name $template.Name -Confirm:$false
	}




} #end Function
 
Export-ModuleMember -Function Export-ESXTemplate
#endregion
 
#region Find-ChocolateyApp.ps1
######## Function 11 of 95 ##################
# Function:         Find-ChocolateyApp
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Search the online repo for software
#############################################
 
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
Function Find-ChocolateyApp {
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

		$id = $Title = $Published = $downloads = $sum = $disc = "None"
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
				Downloads   = $downloads
				Summary     = $sum
				Description = $disc
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
 
Export-ModuleMember -Function Find-ChocolateyApp
#endregion
 
#region Find-OnlineModule.ps1
######## Function 12 of 95 ##################
# Function:         Find-OnlineModule
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/16 18:01:56
# Synopsis:         Creates reports based on PSGallery.
#############################################
 
<#
.SYNOPSIS
Creates reports based on PSGallery.

.DESCRIPTION
Creates reports based on PSGallery. You can search for a keyword, and also exclude azure and aws modules.

.PARAMETER Keyword
Limit the search to a keyword.

.PARAMETER NoAzureAWS
This will exclude modules with AWS and Azure in the name.

.PARAMETER MaxCount
Limit the amount of modules to report, default is 250.

.PARAMETER Offline
Uses a previously downloaded cache for the search. If the cache doesn't exists, it will be created.

.PARAMETER UpdateCache
Update the local cache.

.PARAMETER SortOrder
Determines if the report will be sorted on the amount of downloads or the newest modules.

.PARAMETER Export
Export the result to a file. (Excel or markdown)

.PARAMETER ReportPath
Where to save the report.

.PARAMETER DownloadJeffReport
Downloads Jeff Hicks reports from GitHub.

.EXAMPLE
Find-OnlineModule -Keyword Citrix -Offline -SortOrder Downloads -Export Excel -ReportPath C:\temp

#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	[OutputType([System.Object[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	PARAM(
		[Parameter(Position = 0)]
		[string]$Keyword,
		[switch]$NoAzureAWS,
		[int]$MaxCount = 250,
		[switch]$Offline,
		[switch]$UpdateCache,
		[validateset('Newest', 'Downloads')]
		[string]$SortOrder = 'Downloads',
		[ValidateSet('Excel', 'Markdown', 'Host')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp',
		[switch]$DownloadJeffReport

	)


	if ($UpdateCache) {
		Write-Host "[$(Get-Date)] Updating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
		$cache = Find-Module -Repository PSGallery
		$cache | Export-Clixml -Path "$env:TEMP\psgallery.xml"
	}

	if ($Offline -or $UpdateCache) {
		if (-not(Test-Path "$env:TEMP\psgallery.xml")) {
			Write-Host "[$(Get-Date)] Creating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
			$AllImport = Find-Module -Repository PSGallery
			$AllImport | Export-Clixml -Path "$env:TEMP\psgallery.xml"
		} else {
			Write-Host "[$(Get-Date)] Using cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
			$AllImport = Import-Clixml -Path "$env:TEMP\psgallery.xml"
  }
	} else {
		Write-Host "[$(Get-Date)] Going Online" -ForegroundColor yellow
		$AllImport = Find-Module -Repository PSGallery
	}

	if ($NoAzureAWS) {
		$FilteredImport = $AllImport | Where-Object {
			$_.name -notmatch '(AWS)|(Azure)' -and 
			$_.Author -notmatch '(microsoft)|(amazon)'
		}
	} else {
		$FilteredImport = $AllImport
	}
	if ($null -like $Keyword) {$ReportModules = $FilteredImport }
	else {
		$ReportModules = $FilteredImport | Where-Object {
			$_.name -like "*$Keyword*" -or 
			$_.Description -like "*$Keyword*" -or 
			$_.ReleaseNotes -like "*$Keyword*" -or 
			$_.Tags -like "*$Keyword*" -or 
			$_.Author -like "*$Keyword*" 
		}
	}

	[System.Collections.ArrayList]$NewObject = @()
	foreach ($RepMod in $ReportModules) {
		[void]$NewObject.Add([PSCustomObject]@{
				Name                 = $RepMod.Name
				Version              = $RepMod.Version
				Projecturi           = $RepMod.ProjectUri.OriginalString
				PublishedDate        = [datetime]$RepMod.PublishedDate
				DownloadCount        = [int32]$RepMod.AdditionalMetadata.downloadCount
				VersionDownloadCount = [int32]$RepMod.AdditionalMetadata.versionDownloadCount
				Authors              = $RepMod.Author
				Description          = $RepMod.Description
				ReleaseNotes         = $RepMod.ReleaseNotes
				tags                 = @($RepMod.Tags | Out-String).Trim()
			} )
	}

	if ($SortOrder -like 'Downloads') {$FinalReport = $NewObject | Sort-Object -Property downloadCount -Descending | Select-Object -First $MaxCount}
	else { $FinalReport = $NewObject | Sort-Object -Property PublishedDate -Descending | Select-Object -First $MaxCount }

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		if ($FinalReport) {
			$FinalReport | Export-Excel -Title 'PSGallery Modules' -WorksheetName Modules @ExcelOptions
		}
	}
	if ($Export -like 'Markdown') {
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add("# PowerShell Filtered: $($Keyword)`n")
		$fragments.Add("![PS](https://www.powershellgallery.com/Content/Images/Branding/psgallerylogo.svg)`n")
		foreach ($item in $FinalReport) {
			$galleryLink = "https://www.powershellgallery.com/Packages/$($item.name)/$($item.version)"
			#$fragments.Add("## <img src=`"https://e1.pngegg.com/pngimages/64/313/png-clipart-simply-styled-icon-set-731-icons-free-powershell-white-and-blue-logo-illustration-thumbnail.png`" align=`"left`" style=`"height: 10px`"/>")
			$fragments.Add(" [$($item.name)]($gallerylink) | $($item.version)`n")
			$fragments.Add("Published: $($item.PublishedDate) by $($item.Authors)`n")
			$fragments.Add("<span style='font-weight:Lighter;'>$($item.Description)</span>`n")
			$dl = '__TotalDownloads__: {0:n0}' -f [int64]($item.downloadCount)
			$vdl = '__VersionDownloads__: {0:n0}' -f [int64]($item.versionDownloadCount)
			$repo = "__Repository__: $($item.projecturi)"
			$Fragments.Add("$dl | $vdl | $repo`n")
			$Fragments.Add('---')
		}
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -Encoding utf8 -Force
		Show-Markdown "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -UseBrowser
	}
	if ($export -like 'Host') {$FinalReport}

	if ($DownloadJeffReport) {
	
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-filtered.md'
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-downloads.md'
		Start-Process 'https://github.com/jdhitsolutions/PSGalleryReport/blob/main/psgallery-downloads-community.md'

	}
}
 
Export-ModuleMember -Function Find-OnlineModule
#endregion
 
#region Find-OnlineScript.ps1
######## Function 13 of 95 ##################
# Function:         Find-OnlineScript
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/29 08:48:45
# Synopsis:         Creates reports based on PSGallery. Filtered by scripts
#############################################
 
<#
.SYNOPSIS
Find Script on PSGallery

.DESCRIPTION
Find Script on PSGallery

.PARAMETER Keyword
What to search for

.PARAMETER install
Install selected script

.EXAMPLE
Find-OnlineScript -Keyword blah -install

.NOTES
General notes
#>

<#
.SYNOPSIS
Creates reports based on PSGallery. Filtered by scripts

.DESCRIPTION
Creates reports based on PSGallery. You can search for a keyword, and also exclude azure and aws scripts.

.PARAMETER Keyword
Limit the search to a keyword.

.PARAMETER NoAzureAWS
This will exclude scripts with AWS and Azure in the name.

.PARAMETER MaxCount
Limit the amount of scripts to report, default is 250.

.PARAMETER Offline
Uses a previously downloaded cache for the search. If the cache doesn't exists, it will be created.

.PARAMETER UpdateCache
Update the local cache.

.PARAMETER SortOrder
Determines if the report will be sorted on the amount of downloads or the newest scripts.

.PARAMETER Export
Export the result to a file. (Excel or markdown)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Find-OnlineScript -Keyword Citrix -Offline -SortOrder Downloads -Export Excel -ReportPath C:\temp

#>
function Find-OnlineScript {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineScript')]
		PARAM(
			[Parameter(Position = 0)]
			[string]$Keyword,
			[switch]$NoAzureAWS,
			[int]$MaxCount = 250,
			[switch]$Offline,
			[switch]$UpdateCache,
			[validateset('Newest', 'Downloads')]
			[string]$SortOrder = 'Downloads',
			[ValidateSet('Excel', 'Markdown', 'Host')]
			[string]$Export = 'Host',
			[ValidateScript( { if (Test-Path $_) { $true }
					else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
				})]
			[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'

		)

		if ($UpdateCache) {
			Write-Host "[$(Get-Date)] Updating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
			$cache = Find-Script -Repository PSGallery
			$cache | Export-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
		}

		if ($Offline -or $UpdateCache) {
			if (-not(Test-Path "$env:TEMP\psgallery-scripts.xml")) {
				Write-Host "[$(Get-Date)] Creating cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
				$AllImport = Find-Script -Repository PSGallery
				$AllImport | Export-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
			} else {
				Write-Host "[$(Get-Date)] Using cache $($env:TEMP)\psgallery.xml" -ForegroundColor yellow
				$AllImport = Import-Clixml -Path "$env:TEMP\psgallery-scripts.xml"
			}
		} else {
			Write-Host "[$(Get-Date)] Going Online" -ForegroundColor yellow
			$AllImport = Find-Script -Repository PSGallery
		}

		if ($NoAzureAWS) {
			$FilteredImport = $AllImport | Where-Object {
				$_.name -notmatch '(AWS)|(Azure)' -and 
				$_.Author -notmatch '(microsoft)|(amazon)'
			}
		} else {
			$FilteredImport = $AllImport
		}
		if ($null -like $Keyword) {$ReportModules = $FilteredImport }
		else {
			$ReportModules = $FilteredImport | Where-Object {
				$_.name -like "*$Keyword*" -or 
				$_.Description -like "*$Keyword*" -or 
				$_.ReleaseNotes -like "*$Keyword*" -or 
				$_.Tags -like "*$Keyword*" -or 
				$_.Author -like "*$Keyword*" 
			}
		}

		[System.Collections.ArrayList]$NewObject = @()
		foreach ($RepMod in $ReportModules) {
			[void]$NewObject.Add([PSCustomObject]@{
					Name                 = $RepMod.Name
					Version              = $RepMod.Version
					Projecturi           = $RepMod.ProjectUri.OriginalString
					PublishedDate        = [datetime]$RepMod.PublishedDate
					DownloadCount        = [int32]$RepMod.AdditionalMetadata.downloadCount
					VersionDownloadCount = [int32]$RepMod.AdditionalMetadata.versionDownloadCount
					Authors              = $RepMod.Author
					Description          = $RepMod.Description
					ReleaseNotes         = $RepMod.ReleaseNotes
					tags                 = @($RepMod.Tags | Out-String).Trim()
				} )
		}

		if ($SortOrder -like 'Downloads') {$FinalReport = $NewObject | Sort-Object -Property downloadCount -Descending | Select-Object -First $MaxCount}
		else { $FinalReport = $NewObject | Sort-Object -Property PublishedDate -Descending | Select-Object -First $MaxCount }

		if ($Export -eq 'Excel') { 
			$ExcelOptions = @{
				Path             = $(Join-Path -Path $ReportPath -ChildPath "\PSGallery-scripts-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
				AutoSize         = $True
				AutoFilter       = $True
				TitleBold        = $True
				TitleSize        = '28'
				TitleFillPattern = 'LightTrellis'
				TableStyle       = 'Light20'
				FreezeTopRow     = $True
				FreezePane       = '3'
			}
			if ($FinalReport) {
				$FinalReport | Export-Excel -Title 'PSGallery Modules' -WorksheetName Modules @ExcelOptions
			}
		}
		if ($Export -like 'Markdown') {
			$fragments = [system.collections.generic.list[string]]::new()
			$fragments.Add("# PowerShell Filtered: $($Keyword)`n")
			$fragments.Add("![PS](https://www.powershellgallery.com/Content/Images/Branding/psgallerylogo.svg)`n")
			foreach ($item in $FinalReport) {
				$galleryLink = "https://www.powershellgallery.com/Packages/$($item.name)/$($item.version)"
				$fragments.Add("## <img src=`"https://e1.pngegg.com/pngimages/64/313/png-clipart-simply-styled-icon-set-731-icons-free-powershell-white-and-blue-logo-illustration-thumbnail.png`" align=`"left`" style=`"height: 32px`"/>")
				$fragments.Add(" [$($item.name)]($gallerylink) | $($item.version)`n")
				$fragments.Add("Published: $($item.PublishedDate) by $($item.Authors)`n")
				$fragments.Add("<span style='font-weight:Lighter;'>$($item.Description)</span>`n")
				$dl = '__TotalDownloads__: {0:n0}' -f [int64]($item.downloadCount)
				$vdl = '__VersionDownloads__: {0:n0}' -f [int64]($item.versionDownloadCount)
				$repo = "__Repository__: $($item.projecturi)"
				$Fragments.Add("$dl | $vdl | $repo`n")
				$Fragments.Add('---')
			}
			$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
			$fragments | Out-File "$(Join-Path -Path $ReportPath -ChildPath "\PSGallery-scripts-$(Get-Date -Format yyyy.MM.dd-HH.mm).md")" -Encoding utf8 -Force
		}
		if ($export -like 'Host') {$FinalReport}
}

 
Export-ModuleMember -Function Find-OnlineScript
#endregion
 
#region Format-AllObjectsInAListView.ps1
######## Function 14 of 95 ##################
# Function:         Format-AllObjectsInAListView
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/27 21:28:55
# Synopsis:         Cast an array or PSObject and display it in list view
#############################################
 
<#
.SYNOPSIS
Cast an array or PSObject and display it in list view

.DESCRIPTION
Cast an array or PSObject and display it in list view

.PARAMETER Data
The PSObject to transform

.EXAMPLE
Format-AllObjectsInAListView -data $data

#>
Function Format-AllObjectsInAListView {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Format-AllObjectsInAListView')]
    Param (
        [parameter( ValueFromPipeline = $True )]
        [object[]]$Data)

    Process {
        ForEach ( $Object in $Data ) {
            $Object.psobject.Properties | Select-Object -Property Name, Value
        }
    }
}
 
Export-ModuleMember -Function Format-AllObjectsInAListView
#endregion
 
#region Get-CitrixClientVersion.ps1
######## Function 15 of 95 ##################
# Function:         Get-CitrixClientVersion
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Report on the CItrix workspace versions the users are using.
#############################################
 
<#
.SYNOPSIS
 Report on the CItrix workspace versions the users are using.

.DESCRIPTION
 Report on the CItrix workspace versions the users are using.

.PARAMETER AdminAddress
DDC FQDN

.PARAMETER hours
Limit the amount of data to collect from OData

.PARAMETER ReportsPath
Where report will be saved.

.EXAMPLE
Get-CitrixClientVersions -AdminAddress localhost -hours 12

#>
Function Get-CitrixClientVersion {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-CitrixClientVersions')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminAddress,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int]$hours,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (-Not (Test-Path $_) ) { stop }
				$true
			})]
		[string[]]$ReportsPath)


	$now = Get-Date -Format yyyy-MM-ddTHH:mm:ss
	$past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss')

	$urisettings = @{
		#AllowUnencryptedAuthentication = $true
		UseDefaultCredentials = $true
	}

	$SessionURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Sessions?$filter = StartDate ge datetime''' + $past + ''' and StartDate le datetime''' + $now + ''''
	$ConnectionURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Connections?$filter = LogOnStartDate ge datetime''' + $past + ''' and LogOnStartDate le datetime''' + $now + ''''
	$UsersURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Users'
	#$MachinesURI = 'http://' + $AdminAddress + '/Citrix/Monitor/OData/v3/Data/Machines'

	$Sessions = (Invoke-RestMethod -Uri $SessionURI @urisettings ).content.properties
	$Connections = (Invoke-RestMethod -Uri $ConnectionURI @urisettings ).content.properties
	$users = (Invoke-RestMethod -Uri $UsersURI @urisettings ).content.properties


	$index = 1
	[string]$AllCount = $Connections.Count
	$export = @()
	$Connections | ForEach-Object {
		$connect = $_
		$id = ($Sessions | Where-Object { $_.SessionKey.'#text' -like $connect.SessionKey.'#text' }).UserId.'#text'
		$userdetails = $users | Where-Object { $_.id.'#text' -like $id }
		Write-Output "Collecting data $index of $AllCount"
		$index++
		$export += [pscustomobject]@{
			Domain         = $userdetails.Domain
			UserName       = $userdetails.UserName
			Upn            = $userdetails.Upn
			FullName       = $userdetails.FullName
			ClientName     = $connect.ClientName
			ClientAddress  = $connect.ClientAddress
			ClientVersion  = $connect.ClientVersion
			ClientPlatform = $connect.ClientPlatform
			Protocol       = $connect.Protocol
		} | Select-Object Domain, UserName, Upn, FullName, ClientName, ClientAddress, ClientVersion, ClientPlatform, Protocol
	}
	$Reportpath = ($ReportsPath).Trim() + '\Citrix_Client_Ver_' + (Get-Date -Format yyyy_MM_dd).ToString() + '.csv'
	$export | Sort-Object -Property Username -Descending -Unique | Export-Csv -Path $Reportpath -NoClobber -Force -NoTypeInformation

} #end Function
 
Export-ModuleMember -Function Get-CitrixClientVersion
#endregion
 
#region Get-CitrixPolicies.ps1
######## Function 16 of 95 ##################
# Function:         Get-CitrixPolicies
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/25 04:20:25
# Synopsis:         Export Citrix Policies
#############################################
 
<#
.SYNOPSIS
Export Citrix Policies

.DESCRIPTION
Export Citrix Policies

.PARAMETER Controller
Name of the DDC

.PARAMETER Export
Export result to excel, html

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixPolicies -Controller $ctxddc

#>
Function Get-CitrixPolicies {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Get-CitrixPolicies")]
	    [OutputType([System.Object[]])]
                PARAM(
					[Parameter(Mandatory = $true)]
					[string]$Controller,

					[ValidateSet('Excel', 'HTML')]
					[string]$Export = 'Host',

                	[ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                	[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
					)

	if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
		Import-Module Citrix.GroupPolicy.Commands -Force
		if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {Write-Error 'Unable to find module'}
	}

	New-PSDrive -Name LocalFarmGpo -PSProvider CitrixGroupPolicy -controller $Controller -Root "\" -Scope global | Out-Null

	[System.Collections.ArrayList]$TMPPolobject = @()
    [System.Collections.ArrayList]$Polobject = @()
	$settingdetail = Get-CtxGroupPolicyConfiguration -PolicyName *
	$settingdetail | ForEach-Object {
		$item = $_
		$item | Get-Member -MemberType NoteProperty | Where-Object { $_.definition -like '*PSCustomObject*' } | ForEach-Object {
			[void]$TMPPolobject.add([PSCustomObject]@{
					PolicyName   = $item.PolicyName
					PolicyType   = $item.Type
					SettingPath  = $item.($_.name).Path
					SettingName  = $_.name
					SettingState = $item.($_.name).state
					SettingValue = $item.($_.name).Value
				})
		}
	}
	$Polobject = $TMPPolobject | Where-Object {$_.SettingState -notlike 'NotConfigured'}
    Remove-PSDrive LocalFarmGpo -Scope global

	if ($Export -eq 'Excel') { $Polobject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixPolicies -AutoSize -AutoFilter -Title CitrixPolicies -TitleBold -TitleSize 28}
	if ($Export -eq 'HTML') { $Polobject | Out-HtmlView -DisablePaging -Title "CitrixPolicies" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixPolicies-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $Polobject }


} #end Function
 
Export-ModuleMember -Function Get-CitrixPolicies
#endregion
 
#region Get-CommandFiltered.ps1
######## Function 17 of 95 ##################
# Function:         Get-CommandFiltered
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Finds commands on the system and sort it according to module
#############################################
 
<#
.SYNOPSIS
Finds commands on the system and sort it according to module

.DESCRIPTION
Finds commands on the system and sort it according to module

.PARAMETER Filter
Limit search

.PARAMETER PrettyAnswer
Display results with colour, but runs slow.

.EXAMPLE
Get-CommandFiltered -Filter blah

.NOTES
General notes
#>
Function Get-CommandFiltered {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-CommandFiltered')]
	[Alias("fcmd")]
	PARAM(
		[string]$Filter,
		[switch]$PrettyAnswer = $false
	)
	$Filtered = '*' + $Filter + '*'
	$cmd = Get-Command $Filtered | Sort-Object -Property Source
	if ($PrettyAnswer) {
		foreach ($item in ($cmd.Source | Sort-Object -Unique)) {
			$commands = @()
			Write-Color -Text 'Module: ', $($item) -Color Cyan, Red -StartTab 2
			$cmd | Where-Object { $_.Source -like $item } | ForEach-Object {
				$commands += [pscustomobject]@{
					Name        = $_.Name
					Module      = $_.Module
					CommandType = $_.CommandType
					Source      = $_.Source
					Description = ((Get-Help $_.Name).description | Out-String).Trim()
				}
			}
			$commands | Format-Table -AutoSize | Out-More
		}
	}
	else { $cmd }
} #end Function
New-Alias -Name fcmd -Value Get-CommandFiltered -Description 'Filter Get-command with keyword' -Option AllScope -Scope global -Force
 
Export-ModuleMember -Function Get-CommandFiltered
#endregion
 
#region Get-DeviceUptime.ps1
######## Function 18 of 95 ##################
# Function:         Get-DeviceUptime
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Calculates the uptime of a system
#############################################
 
<#
.SYNOPSIS
Calculates the uptime of a system

.DESCRIPTION
Calculates the uptime of a system

.PARAMETER ComputerName
Computer to query.

.EXAMPLE
Get-DeviceUptime -ComputerName Neptune

#>
Function Get-DeviceUptime {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Get-DeviceUptime')]
	[outputtype('System.Object[]')]
	PARAM(
		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = 'Set1')]
		[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
				else {throw "Unable to connect to $($_)"} })]
		[string[]]$ComputerName = $env:computername
	)

	[System.Collections.ArrayList]$ReturnObj = @()
	foreach ($computer in $ComputerName) {
		try {
			$lastboottime = (Get-CimInstance -ComputerName $computer -ClassName Win32_OperatingSystem ).LastBootUpTime
			$timespan = New-TimeSpan -Start $lastboottime -End (Get-Date)
		} catch {Throw "Unable to connect to $($computer)"}
		[void]$ReturnObj.add([PSCustomObject]@{
				ComputerName = $computer
				Date         = $lastboottime
    Summary      = [PSCustomObject]@{
	    ComputerName = $computer
	    Date         = $lastboottime
	    TotalDays    = [math]::Round($timespan.totaldays)
	    TotalHours   = [math]::Round($timespan.totalhours)
    }
				All          = [PSCustomObject]@{
	    ComputerName = $computer
	    Date         = $lastboottime
					Timespan     = $timespan
    }
			})
	}
	return $ReturnObj


} #end Function
 
Export-ModuleMember -Function Get-DeviceUptime
#endregion
 
#region Get-FolderSize.ps1
######## Function 19 of 95 ##################
# Function:         Get-FolderSize
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Joakim Svendsen
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
#############################################
 
<#
.SYNOPSIS
    Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option

.DESCRIPTION
Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
,
    which makes it not actually copy or move files, but just list them, and the end
    summary result is parsed to extract the relevant data.

    This apparently is much faster than .NET and Get-ChildItem in PowerShell.

    The properties of the objects will be different based on which method is used, but
    the "TotalBytes" property is always populated if the directory size was successfully
    retrieved. Otherwise you should get a warning.

    BSD 3-clause license.

    Copyright (C) 2015, Joakim Svendsen
    All rights reserved.
    Svendsen Tech.


.PARAMETER Path
    Path or paths to measure size of.

.PARAMETER Precision
    Number of digits after decimal point in rounded numbers.

.PARAMETER RoboOnly
    Do not use COM, only robocopy, for always getting full details.

.EXAMPLE
    . .\Get-FolderSize.ps1
    PS C:\> 'C:\Windows', 'E:\temp' | Get-FolderSize

.EXAMPLE
    Get-FolderSize -Path Z:\Database -Precision 2

.EXAMPLE
    Get-FolderSize -Path Z:\Database -RoboOnly

#>
function Get-FolderSize {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FolderSize')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [string[]] $Path,
        [int] $Precision = 4,
        [switch] $RoboOnly)
    begin {
        $FSO = New-Object -ComObject Scripting.FileSystemObject -ErrorAction Stop
        function Get-RoboFolderSizeInternal {
            param(
                # Paths to report size, file count, dir count, etc. for.
                [string[]] $Path,
                [int] $Precision = 4)
            begin {
                if (-not (Get-Command -Name robocopy -ErrorAction SilentlyContinue)) {
                    Write-Warning -Message "Fallback to robocopy failed because robocopy.exe could not be found. Path '$p'. $([datetime]::Now)."
                    return
                }
            }
            process {
                foreach ($p in $Path) {
                    Write-Verbose -Message "Processing path '$p' with Get-RoboFolderSizeInternal. $([datetime]::Now)."
                    $RoboCopyArgs = @('/L', '/S', '/NJH', '/BYTES', '/FP', '/NC', '/NDL', '/TS', '/XJ', '/R:0', '/W:0')
                    [datetime] $StartedTime = [datetime]::Now
                    [string] $Summary = robocopy $p NULL $RoboCopyArgs | Select-Object -Last 8
                    [datetime] $EndedTime = [datetime]::Now
                    [regex] $HeaderRegex = '\s+Total\s*Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras'
                    [regex] $DirLineRegex = 'Dirs\s*:\s*(?<DirCount>\d+)(?:\s*\d+){3}\s*(?<DirFailed>\d+)\s*\d+'
                    [regex] $FileLineRegex = 'Files\s*:\s*(?<FileCount>\d+)(?:\s*\d+){3}\s*(?<FileFailed>\d+)\s*\d+'
                    [regex] $BytesLineRegex = 'Bytes\s*:\s*(?<ByteCount>\d+)(?:\s*\d+){3}\s*(?<BytesFailed>\d+)\s*\d+'
                    [regex] $TimeLineRegex = 'Times\s*:\s*(?<TimeElapsed>\d+).*'
                    [regex] $EndedLineRegex = 'Ended\s*:\s*(?<EndedTime>.+)'
                    if ($Summary -match "$HeaderRegex\s+$DirLineRegex\s+$FileLineRegex\s+$BytesLineRegex\s+$TimeLineRegex\s+$EndedLineRegex") {
                        $TimeElapsed = [math]::Round([decimal] ($EndedTime - $StartedTime).TotalSeconds, $Precision)
                        New-Object PSObject -Property @{
                            Path        = $p
                            TotalBytes  = [decimal] $Matches['ByteCount']
                            TotalMBytes = [math]::Round(([decimal] $Matches['ByteCount'] / 1MB), $Precision)
                            TotalGBytes = [math]::Round(([decimal] $Matches['ByteCount'] / 1GB), $Precision)
                            BytesFailed = [decimal] $Matches['BytesFailed']
                            DirCount    = [decimal] $Matches['DirCount']
                            FileCount   = [decimal] $Matches['FileCount']
                            DirFailed   = [decimal] $Matches['DirFailed']
                            FileFailed  = [decimal] $Matches['FileFailed']
                            TimeElapsed = $TimeElapsed
                            StartedTime = $StartedTime
                            EndedTime   = $EndedTime

                        } | Select-Object Path, TotalBytes, TotalMBytes, TotalGBytes, DirCount, FileCount, DirFailed, FileFailed, TimeElapsed, StartedTime, EndedTime
                    }
                    else {
                        Write-Warning -Message "Path '$p' output from robocopy was not in an expected format."
                    }
                }
            }
        }
    }
    process {
        foreach ($p in $Path) {
            Write-Verbose -Message "Processing path '$p'. $([datetime]::Now)."
            if (-not (Test-Path -Path $p -PathType Container)) {
                Write-Warning -Message "$p does not exist or is a file and not a directory. Skipping."
                continue
            }
            if ($RoboOnly) {
                Get-RoboFolderSizeInternal -Path $p -Precision $Precision
                continue
            }
            $ErrorActionPreference = 'Stop'
            try {
                $StartFSOTime = [datetime]::Now
                $TotalBytes = $FSO.GetFolder($p).Size
                $EndFSOTime = [datetime]::Now
                if ($null -eq $TotalBytes) {
                    Get-RoboFolderSizeInternal -Path $p -Precision $Precision
                    continue
                }
            }
            catch {
                if ($_.Exception.Message -like '*PERMISSION*DENIED*') {
                    Write-Verbose 'Caught a permission denied. Trying robocopy.'
                    Get-RoboFolderSizeInternal -Path $p -Precision $Precision
                    continue
                }
                Write-Warning -Message "Encountered an error while processing path '$p': $_"
                continue
            }
            $ErrorActionPreference = 'Continue'
            New-Object PSObject -Property @{
                Path        = $p
                TotalBytes  = [decimal] $TotalBytes
                TotalMBytes = [math]::Round(([decimal] $TotalBytes / 1MB), $Precision)
                TotalGBytes = [math]::Round(([decimal] $TotalBytes / 1GB), $Precision)
                BytesFailed = $null
                DirCount    = $null
                FileCount   = $null
                DirFailed   = $null
                FileFailed  = $null
                TimeElapsed = [math]::Round(([decimal] ($EndFSOTime - $StartFSOTime).TotalSeconds), $Precision)
                StartedTime = $StartFSOTime
                EndedTime   = $EndFSOTime
            } | Select-Object Path, TotalBytes, TotalMBytes, TotalGBytes, DirCount, FileCount, DirFailed, FileFailed, TimeElapsed, StartedTime, EndedTime
        }
    }
    end {
        [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($FSO)
        [gc]::Collect()
    }
}
 
Export-ModuleMember -Function Get-FolderSize
#endregion
 
#region Get-FQDN.ps1
######## Function 20 of 95 ##################
# Function:         Get-FQDN
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/11 12:40:46
# Synopsis:         Get FQDN for a device, and checks if it is online
#############################################
 
<#
.SYNOPSIS
Get FQDN for a device, and checks if it is online

.DESCRIPTION
Get FQDN for a device, and checks if it is online

.PARAMETER ComputerName
Name or IP to use.

.EXAMPLE
get-FQDN -ComputerName Neptune

#>
Function Get-FQDN {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FQDN')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
		[string[]]$ComputerName
	)
	process {
		[System.Collections.ArrayList]$outobject = @()
		$ComputerName | ForEach-Object {
			try {
				[void]$outobject.add([pscustomobject]@{
						Host   = $($_)
						FQDN   = ([System.Net.Dns]::GetHostEntry(($($_)))).HostName
						Online = Test-Connection -ComputerName $(([System.Net.Dns]::GetHostEntry(($($_)))).HostName) -Quiet -Count 2
					})
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		}
	}
	end {return $outobject}
} #end Function
 
Export-ModuleMember -Function Get-FQDN
#endregion
 
#region Get-FullADUserDetail.ps1
######## Function 21 of 95 ##################
# Function:         Get-FullADUserDetail
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/29 11:37:41
# Synopsis:         Extract user details from the domain
#############################################
 
<#
.SYNOPSIS
Extract user details from the domain

.DESCRIPTION
Extract user details from the domain

.PARAMETER UserToQuery
User id to search for.

.PARAMETER DomainFQDN
Domain to search

.PARAMETER DomainCredential
Userid to connect to that domain.

.EXAMPLE
Get-FullADUserDetail -UserToQuery ps

#>
Function Get-FullADUserDetail {
	[Cmdletbinding(DefaultParameterSetName = 'CurrentDomain' , HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FullADUserDetail')]
	PARAM(
		[Parameter(ParameterSetName = 'CurrentDomain')]
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $true)]
		[string]$UserToQuery,
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[string]$DomainFQDN,
		[Parameter(ParameterSetName = 'OtherDomain')]
		[Parameter(Mandatory = $false)]
		[pscredential]$DomainCredential
	)

	if ($null -notlike $DomainFQDN) {
		if (-not($DomainCredential)) {$DomainCredential = Get-Credential -Message "Account to connnect to $($DomainFQDN)"}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
		try {
			$AllUserDetails = Get-ADUser -Identity $UserToQuery -Server $DomainFQDN -Credential $DomainCredential -Properties *
			[pscustomobject]@{
				UserSummary    = $AllUserDetails | Select-Object Name, GivenName, Surname, UserPrincipalName, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				AllUserDetails = $AllUserDetails
				MemberOf       = $AllUserDetails.memberof | ForEach-Object { 
					$Cname = $_
					$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
					$NewDomain = Join-String -Strings $Split -Separator .
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Connecting] to doamin: $($Domain)"
					Get-ADGroup -Identity $_ -Server $NewDomain -Credential $DomainCredential
				}
			}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	} else {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
		try {
			$AllUserDetails = Get-ADUser -Identity $UserToQuery -Properties *
			[pscustomobject]@{
				UserSummary    = $AllUserDetails | Select-Object Name, GivenName, Surname, UserPrincipalName, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				AllUserDetails = $AllUserDetails
				MemberOf       = $AllUserDetails.memberof | ForEach-Object { 
					$Cname = $_
					$Split = ($Cname.Split(',') | Where-Object {$_ -like 'DC=*'}).replace('DC=', '')
					$NewDomain = Join-String -Strings $Split -Separator .
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Connecting] to doamin: $($Domain)"
					Get-ADGroup -Identity $_ -Server $NewDomain
				}
			}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}
} #end Function
 
Export-ModuleMember -Function Get-FullADUserDetail
#endregion
 
#region Get-MyPSGalleryStat.ps1
######## Function 22 of 95 ##################
# Function:         Get-MyPSGalleryStat
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/16 09:40:12
# Synopsis:         Show stats about my published modules.
#############################################
 
<#
.SYNOPSIS
Show stats about my published modules.

.DESCRIPTION
Show stats about my published modules.

.PARAMETER OpenProfilePage
Open my profile page on psgallery

.PARAMETER ASObject
Return output as an object.

.PARAMETER GitHubUserID
The GitHub User ID.

.PARAMETER GitHubToken
GitHub Token with access to the Users' Gist.

.PARAMETER History
Downloads and calculates the history.

.PARAMETER daysToReport
Report on this amount of days.

.PARAMETER AddtoProfile
Add defaults to profile.

.EXAMPLE
Get-MyPSGalleryStats

#>
Function Get-MyPSGalleryStat {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [string]$GitHubUserID,
        [string]$GitHubToken,
        [switch]$History,
        [int]$daysToReport = 7,
        [switch]$AddtoProfile,
        [Switch]$OpenProfilePage,
        [switch]$ASObject
    )

    if ($OpenProfilePage) {Start-Process 'https://www.powershellgallery.com/profiles/smitpi'}
    else {
        $ModLists = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule')
        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
            $headers = @{}
            $auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
            $base64 = [System.Convert]::ToBase64String($bytes)
            $headers.Authorization = 'Basic {0}' -f $base64

            $url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
            $AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
            $PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'smitpi-gallery-stats' }

            Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
            $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStats.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop

            [System.Collections.generic.List[PSObject]]$GalStats = @()
            $TotalDownloads = 0
            try {
                $Content | ForEach-Object {$GalStats.Add($_)}
            } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

        foreach ($Mod in $ModLists) {
            Write-PSToolKitMessage -Action 'Collecting' -Object $mod -Message 'Online Data'
            $ResultModule = Find-Module $mod -Repository PSGallery
            $TotalDownloads = $TotalDownloads + [int]$ResultModule.AdditionalMetadata.downloadCount
            [void]$GalStats.Add([PSCustomObject]@{
                    Sum            = [PSCustomObject]@{
                        DateCollected   = [datetime](Get-Date -Format U)
                        Name            = $ResultModule.Name
                        Version         = $ResultModule.Version
                        PublishedDate   = [datetime]$ResultModule.AdditionalMetadata.published
                        TotalDownload   = [Int]$ResultModule.AdditionalMetadata.downloadCount
                        VersionDownload = [Int]$ResultModule.AdditionalMetadata.versionDownloadCount
                    }
                    All            = $ResultModule
                    TotalDownloads = $TotalDownloads
                    DateCollected  = [datetime](Get-Date -Format U)
                })
        }
        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to gist"
            $Body = @{}
            $files = @{}
            $Files['PSGalleryStats.json'] = @{content = ( $GalStats | ConvertTo-Json -Depth 10 | Out-String ) }
            $Body.files = $Files
            $Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
            $json = ConvertTo-Json -InputObject $Body
            $json = [System.Text.Encoding]::UTF8.GetBytes($json)
            $null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
            Write-PSToolKitMessage -Action 'Upload' -Object 'PSGallery Stats' -Message 'To Github Gist' -Object2 'Complete'
        } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

        if ($ASObject) {$GalStats}
        else {
            Write-Color 'Total Downloads: ', "$(($GalStats.TotalDownloads | Sort-Object -Descending)[0])" -Color Cyan, yellow -LinesBefore 1
            $GalStats[-1..-6].Sum | Sort-Object -Property PublishedDate -Descending | Format-Table -AutoSize -Wrap
        }
    }

    if ($History) {
        $end = ((Get-Date).AddDays(-$daysToReport)).ToUniversalTime()
        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
            $headers = @{}
            $auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
            $base64 = [System.Convert]::ToBase64String($bytes)
            $headers.Authorization = 'Basic {0}' -f $base64

            $url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
            $AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
            $PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'smitpi-gallery-stats' }
        } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
            $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStats.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

        [System.Collections.generic.List[PSObject]]$GalHistory = @()
        try {
            $Content | ForEach-Object {$GalHistory.Add($_)}
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

        [System.Collections.generic.List[PSObject]]$GalTotals = @()
        $allNames = $GalHistory.Sum | Select-Object Name | Sort-Object -Property Name -Unique

        foreach ($All in $allNames) {
            $sum = $GalHistory.Sum | Where-Object {$_.Name -like $all.Name -and $_.DateCollected -gt $end}
            $span = New-TimeSpan -Start $sum[0].DateCollected -End $sum[-1].DateCollected
            $GalTotals.Add(
                [PSCustomObject]@{
                    Days           = [math]::ceiling($span.TotalDays)
                    Hours          = [math]::ceiling($span.TotalHours)
                    ModuleName     = $Sum[0].Name
                    Version        = $Sum[-1].version
                    TotalDownloads = [int]($Sum[-1].TotalDownload - $Sum[0].TotalDownload)
                })
        }
        $GalTotals | Format-Table -AutoSize -Wrap
    }
    if ($AddtoProfile) {
        $ToAppend = @"
		
#region MyPSGalleryStat Defaults
`$PSDefaultParameterValues['*MyPSGalleryStat*:GitHubUserID'] =  "$($GitHubUserID)"
`$PSDefaultParameterValues['*MyPSGalleryStat*:GitHubToken'] =  "$($GitHubToken)"
#endregion MyPSGalleryStat
"@

        $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
        $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
        $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
        $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
        foreach ($file in $files) {	
            $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*MyPSGalleryStat*'}
            $tmp | Set-Content -Path $file.FullName -Force
            Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8
            Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
        }

    
    }
} #end Function


 
Export-ModuleMember -Function Get-MyPSGalleryStat
#endregion
 
#region Get-NestedADGroupMembers.ps1
######## Function 23 of 95 ##################
# Function:         Get-NestedADGroupMembers
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/21 05:29:15
# Synopsis:         Extract users from an AD group recursive, 4 levels deep.
#############################################
 
<#
.SYNOPSIS
Extract users from an AD group recursive, 4 levels deep.

.DESCRIPTION
Extract users from an AD group recursive, 4 levels deep.

.PARAMETER GroupName
Name of the group to query. 
 
.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.
 
.PARAMETER ReportPath
Where to save the report.
 
.EXAMPLE
Get-NestedADGroupMembers -GroupName "Domain Admins"
 
#>
Function Get-NestedADGroupMembers {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-NestedADGroupMembers')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript({Get-ADGroup $_})]
		[string]$GroupName,
 
		[ValidateSet('Excel', 'HTML', 'Host')]
		[string]$Export = 'Host',
 
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
 
	try {
		$GroupMemeber = (Get-ADGroup -Identity $GroupName -Properties *).members | ForEach-Object {
			Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) Level1 $($_)"
				if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
				else {
					Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
						Write-Verbose "`t[$(Get-Date -Format HH:mm:ss) Level2 $($_)"
						if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
						else {
							Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
								Write-Verbose "`t`t[$(Get-Date -Format HH:mm:ss) Level3 $($_)"
								if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
								else {
									Get-ADObject -Filter {DistinguishedName -like $_} -Properties * | ForEach-Object {
										Write-Verbose "`t`t`t[$(Get-Date -Format HH:mm:ss) Level4 $($_)"
										if ($_.ObjectClass -like 'user') {$_.DistinguishedName}
										else {Get-ADGroup -Identity $_ -Properties * | Select-Object member -ExpandProperty member}
									}
								}
							}
						}
					}
				}
			}
		}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Nested_AD_Group_Members-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$GroupMemeber | Export-Excel -Title NestedADGroupMembers -WorksheetName NestedADGroupMembers @ExcelOptions
	}
 
	if ($Export -eq 'HTML') {
		if ($Export -eq 'HTML') { 
			$ReportTitle = 'Nested AD Group Members-'
 
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
			$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
			New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
				New-HTMLHeader {
					New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				}
				if ($GroupMemeber) {
					New-HTMLTab -Name 'Members' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
						New-HTMLSection @SectionSettings { New-HTMLTable -DataTable $($DefenderObj) @TableSettings}}
				}
			}
		}
	}
	if ($Export -eq 'Host') { $GroupMemeber }
} #end Function
 
Export-ModuleMember -Function Get-NestedADGroupMembers
#endregion
 
#region Get-ProcessPerformance.ps1
######## Function 24 of 95 ##################
# Function:         Get-ProcessPerformance
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Gets the top 10 processes by CPU %
#############################################
 
<#
.SYNOPSIS
Gets the top 10 processes by CPU %

.DESCRIPTION
Gets the top 10 processes by CPU %

.PARAMETER ComputerName
Device to be queried.

.PARAMETER LimitProcCount
List the top x of processes.

.PARAMETER Sortby
Sort by CPU or Memory descending.

.EXAMPLE
Get-ProcessPerformance -ComputerName Apollo -LimitProcCount 10 -Sortby '% CPU'

#>
Function Get-ProcessPerformance {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-ProcessPerformance')]

    PARAM(
        [ValidateScript( { if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
                else { throw "Unable to connect to $($_)" } })]
        [string[]]$ComputerName,
        [int]$LimitProcCount,
        [validateset('% Mem', '% CPU')]
        [string]$Sortby = '% CPU'
    )

    foreach ($comp in $ComputerName) {
        $cores = ((Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName Win32_Processor).NumberOfLogicalProcessors)[0]
        $ProcessArray = [System.Collections.Generic.List[PSObject]]::New()
        $process = Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName Win32_PerfFormattedData_PerfProc_Process
        foreach ($proc in $process | Where-Object { $_.Name -notlike 'Idle' -and $_.Name -notlike '_Total' }) {
            $ProcessArray.Add([PSCustomObject]@{
                    Computername = $comp
                    Name         = $proc.Name
                    ID           = $proc.IDProcess
                    '% CPU'      = [Math]::Round(($proc.PercentProcessorTime / $cores), 2)
                    '% Mem'      = [Math]::Round(($proc.workingSetPrivate / 1mb), 2)
                })
        }
        if ($LimitProcCount -gt 0) { $ProcessArray | Sort-Object -Property $Sortby -Descending | Select-Object -First $LimitProcCount }
        else { $ProcessArray | Sort-Object -Property $Sortby -Descending }
    }
} #end Function
 
Export-ModuleMember -Function Get-ProcessPerformance
#endregion
 
#region Get-PropertiesToCSV.ps1
######## Function 25 of 95 ##################
# Function:         Get-PropertiesToCSV
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Get member data of an object. Use it to create other PSObjects.
#############################################
 
<#
.SYNOPSIS
Get member data of an object. Use it to create other PSObjects.

.DESCRIPTION
Get member data of an object. Use it to create other PSObjects.

.PARAMETER Data
Parameter description

.EXAMPLE
Get-PropertiesToCSV -data $data

#>
Function Get-PropertiesToCSV {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-PropertiesToCSV')]

    Param (
        [parameter( ValueFromPipeline = $True )]
        [object[]]$Data)

    process {
    $data | Get-Member -MemberType NoteProperty | Sort-Object | ForEach-Object { $_.name } | Join-String -Separator ','
    }
} #end Function

 
Export-ModuleMember -Function Get-PropertiesToCSV
#endregion
 
#region Get-SoftwareAudit.ps1
######## Function 26 of 95 ##################
# Function:         Get-SoftwareAudit
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/11 12:37:04
# Synopsis:         Connects to a remote hosts and collect installed software details
#############################################
 
<#
.SYNOPSIS
Connects to a remote hosts and collect installed software details

.DESCRIPTION
Connects to a remote hosts and collect installed software details

.PARAMETER ComputerName
Name of the computers that will be audited

.PARAMETER Export
Export the results to excel or html

.PARAMETER ReportPath
Path to save the report.

.EXAMPLE
Get-SoftwareAudit -ComputerName Neptune -Export Excel

#>
Function Get-SoftwareAudit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SoftwareAudit')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[string[]]$ComputerName,
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $false)]
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[string]$ReportPath = "$env:TEMP"
	)
	[System.Collections.ArrayList]$Software = @()
	foreach ($CompName in $ComputerName) {
		try {
			$check = $null
			$check = Get-FQDN -ComputerName $CompName -ErrorAction Stop
		} catch { Write-Warning "Error: $($_.Exception.Message)" }
		if ($check.online -like 'True') {
			Write-PSToolKitMessage -Action Starting -Severity Information -Object $($check.FQDN) -Message 'Collecting Software'
			try {
				$rawdata = Invoke-Command -ComputerName $CompName -ScriptBlock {
					Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
					Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
				}
				foreach ($item in $rawdata) {
					if (-not($null -eq $item.DisplayName)) {
						[void]$Software.Add([pscustomobject]@{
								CompName        = $($check.FQDN)
								DisplayName     = $item.DisplayName
								DisplayVersion  = $item.DisplayVersion
								Publisher       = $item.Publisher
								EstimatedSize   = [Decimal]::Round([int]$item.EstimatedSize / 1024, 2)
								UninstallString = $item.UninstallString
							})
					}
				}
			} catch { Write-Warning "Error: $($_.Exception.Message)" }
		} else {Write-Warning "$($CompName) is offline"}
	}
	if ($Export -eq 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\SoftwareAudit-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$Software | Export-Excel -Title SoftwareAudit -WorksheetName SoftwareAudit @ExcelOptions
	}
	if ($Export -eq 'HTML') { $Software | Out-HtmlView -DisablePaging -Title 'SoftwareAudit' -HideFooter -SearchHighlight -FixedHeader }
	if ($Export -eq 'Host') { $Software }
} #end Function
 
Export-ModuleMember -Function Get-SoftwareAudit
#endregion
 
#region Get-SystemInfo.ps1
######## Function 27 of 95 ##################
# Function:         Get-SystemInfo
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Get system details of a remote device
#############################################
 
<#
.SYNOPSIS
Get system details of a remote device

.DESCRIPTION
Get system details of a remote device

.PARAMETER ComputerName
Device to be queried.

.PARAMETER Export
Export to excel or html

.PARAMETER ReportPath
Where to save report.

.EXAMPLE
Get-SystemInfo -ComputerName Apollo

#>
Function Get-SystemInfo {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SystemInfo')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateScript( { if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
                else { throw "Unable to connect to $($_)" } })]
        [string[]]$ComputerName,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { (Test-Path $_) })]
        [System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
				)

    [System.Collections.ArrayList]$allcomp = @()
    foreach ($comp in $ComputerName) {
        #region CompInfo
        try {
            $CompinfoOS = [System.Collections.Generic.List[PSObject]]::New()
            $CompinfoBios = [System.Collections.Generic.List[PSObject]]::New()
            $CompinfoWin = [System.Collections.Generic.List[PSObject]]::New()
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Computer Info"
            $Compinfo = Invoke-Command -ComputerName $comp -ScriptBlock { Get-ComputerInfo }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'OS*' } | ForEach-Object {
                $CompinfoOS.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'Bios*' } | ForEach-Object {
                $CompinfoBios.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
            $Compinfo | Get-Member | Where-Object { $_.Name -like 'Windows*' } | ForEach-Object {
                $CompinfoWin.add([pscustomobject]@{
                        name  = $_.name
                        Value = $Compinfo.$($_.name)
                    }) | Out-Null
            }
        }
        catch { Write-Warning "[Collect]Computer info: Failed:`n $($_.Exception.Message)" }

        #endregion
        #region network
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Network Info"
            [System.Collections.ArrayList]$Network = @()
            Get-CimInstance -ComputerName $comp -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | ForEach-Object {
                $Network.Add([pscustomobject]@{
                        Description          = $_.Description
                        DHCPEnabled          = $_.DHCPEnabled
                        DHCPServer           = $_.DHCPServer
                        DNSDomain            = $_.DNSDomain
                        DNSHostName          = $_.DNSHostName
                        DNSServerSearchOrder = @(($_.DNSServerSearchOrder) | Out-String).Trim()
                        IPAddress            = @(($_.IPAddress) | Out-String).Trim()
                        DefaultIPGateway     = @(($_.DefaultIPGateway) | Out-String).Trim()
                        IPSubnet             = @(($_.IPSubnet) | Out-String).Trim()
                        MACAddress           = $_.MACAddress
                    }) | Out-Null
            }
        }
        catch { Write-Warning "[Collect]Network info: Failed:`n $($_.Exception.Message)" }

        #endregion
        #region events
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Events Info"
            [System.Collections.ArrayList]$AllEvents = @()
            $filter = @{
                LogName   = 'Application', 'System'
                StartTime = (Get-Date).AddHours(-24)
                Level     = '1', '2', '3'
            }
            $AllEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object TimeCreated, LogName, ID, MachineName, ProviderName, LevelDisplayName, Level, Message
        }
        catch { Write-Warning "[Collect]Computer events: Failed:`n $($_.Exception.Message)" }
        #endregion
        #region Antivirus
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Antivirus Info"
        [System.Collections.ArrayList]$Antivirus = @()
        if (Get-CimInstance -ComputerName $comp -Namespace root\securitycenter2 -ClassName antivirusproduct -ErrorAction SilentlyContinue) {
            Get-CimInstance -ComputerName $comp -Namespace root\securitycenter2 -ClassName antivirusproduct | ForEach-Object {
                $Antitmp = New-Object -TypeName psobject -Property @{
                    displayName              = $_.displayName
                    pathToSignedProductExe   = $_.pathToSignedProductExe
                    pathToSignedReportingExe = $_.pathToSignedReportingExe
                    productState             = $_.productState
                    timestamp                = $_.timestamp
                }
                $Antivirus.Add($Antitmp) | Out-Null
            }
        }
        elseif (Get-CimInstance -ComputerName $comp -Namespace root\securitycenter -ClassName antivirusproduct -ErrorAction SilentlyContinue) {
            Get-CimInstance -ComputerName $comp -Namespace root\securitycenter -ClassName antivirusproduct | ForEach-Object {
                $Antitmp = New-Object -TypeName psobject -Property @{
                    displayName              = $_.displayName
                    pathToSignedProductExe   = $_.pathToSignedProductExe
                    pathToSignedReportingExe = $_.pathToSignedReportingExe
                    productState             = $_.productState
                    timestamp                = $_.timestamp
                }
                $Antivirus.Add($Antitmp) | Out-Null
            }
        }
        else {
            $Antitmp = New-Object -TypeName psobject -Property @{
                displayName              = 'No Antivirus Found'
                pathToSignedProductExe   = 'No Antivirus Found'
                pathToSignedReportingExe = 'No Antivirus Found'
                productState             = 'No Antivirus Found'
                timestamp                = 'No Antivirus Found'

            }
            $Antivirus.Add($Antitmp) | Out-Null
        }
        #endregion
        #region Build array
        try {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Collect] $($comp) - Other Info"
            $biosfiltered = @('BiosBIOSVersion', 'BiosFirmwareType', 'BiosInstallDate', 'BiosManufacturer', 'BiosName', 'BiosOtherTargetOS', 'BiosPrimaryBIOS', 'BiosReleaseDate', 'BiosSeralNumber', 'BiosSoftwareElementState', 'BiosStatus', 'BiosTargetOperatingSystem', 'BiosVersion')
            $OSFiltered = @('OsArchitecture', 'OsBuildNumber', 'OSDisplayVersion', 'OsInstallDate', 'OsLastBootUpTime', 'OsName', 'OsNumberOfLicensedUsers', 'OsNumberOfUsers', 'OsProductType', 'OsSystemDirectory', 'OsSystemDrive', 'OsType', 'OsUptime', 'OsVersion', 'OsWindowsDirectory')
            $WinFiltered = @('WindowsBuildLabEx', 'WindowsCurrentVersion', 'WindowsEditionId', 'WindowsInstallationType', 'WindowsInstallDateFromRegistry', 'WindowsProductId', 'WindowsProductName', 'WindowsRegisteredOrganization', 'WindowsRegisteredOwner', 'WindowsSystemRoot', 'WindowsVersion')
            $SysInfo = @()
            $SysInfo = [pscustomobject]@{
                DateCollected = (Get-Date -Format yyyy.MM.dd-HH.mm)
                Hostname      = (Get-FQDN -ComputerName $comp).fqdn
                OS            = $CompinfoOS | Where-Object { $_.name -in $OSFiltered }
                Bios          = $CompinfoBios | Where-Object { $_.name -in $biosfiltered }
                Windows       = $CompinfoWin | Where-Object { $_.name -in $WinFiltered }
                Software      = Get-SoftwareAudit -ComputerName $comp | Select-Object Displayname, DisplayVersion, Publisher, EstimatedSize
                Environment    = Get-CimInstance -Namespace root/cimv2 -ClassName win32_environment -ComputerName $comp | Select-Object Name, UserName, VariableValue, SystemVariable, Description
                hotfix        = Get-CimInstance -ComputerName $comp -Namespace root/cimv2 -ClassName win32_quickfixengineering | Select-Object Caption, Description, HotFixID
                EventViewer   = $AllEvents
                Network       = $Network
                AntiVirus     = $Antivirus
                Services      = Invoke-Command -ComputerName $comp -ScriptBlock { Get-Service } | Sort-Object -Property StartType | Select-Object DisplayName, status, StartType
            }
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] $($comp)"
        }
        catch { Write-Warning "[Collect]Other info: Failed:`n $($_.Exception.Message)" }
        #endregion
        [void]$allcomp.Add($SysInfo)
    }

    #region excel
    if ($Export -eq 'Excel') {
        try {
            foreach ($SysInfo in $allcomp) {
                $path = Get-Item $ReportPath
                $ExcelPath = Join-Path $Path.FullName -ChildPath "$($SysInfo.Hostname)-SysInfo-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx"

                $SysInfo.OS | Export-Excel -Path $ExcelPath -WorksheetName OS -AutoSize -AutoFilter
                $SysInfo.Bios | Export-Excel -Path $ExcelPath -WorksheetName Bios -AutoSize -AutoFilter
                $SysInfo.Windows | Export-Excel -Path $ExcelPath -WorksheetName Windows -AutoSize -AutoFilter
                $SysInfo.Software | Export-Excel -Path $ExcelPath -WorksheetName Software -AutoSize -AutoFilter
                $SysInfo.Environment | Export-Excel -Path $ExcelPath -WorksheetName ENV -AutoSize -AutoFilter
                $SysInfo.hotfix | Export-Excel -Path $ExcelPath -WorksheetName Hotfix -AutoSize -AutoFilter
                $SysInfo.EventViewer | Export-Excel -Path $ExcelPath -WorksheetName Events -AutoSize -AutoFilter
                $SysInfo.Network | Export-Excel -Path $ExcelPath -WorksheetName Network -AutoSize -AutoFilter
                $SysInfo.AntiVirus | Export-Excel -Path $ExcelPath -WorksheetName Antivirus -AutoSize -AutoFilter
                $SysInfo.Services | Export-Excel -Path $ExcelPath -WorksheetName Services -AutoSize -AutoFilter
            }
        }
        catch { Write-Warning "[Report]Excel Report Failed:`n $($_.Exception.Message)" }

    }
    #endregion
    if ($Export -eq 'HTML') {
        try {
            #region html settings
            $SectionSettings = @{
                HeaderTextSize        = '16'
                HeaderTextAlignment   = 'center'
                HeaderBackGroundColor = '#00203F'
                HeaderTextColor       = '#ADEFD1'
                backgroundColor       = 'lightgrey'
                CanCollapse           = $true
            }
            $TableSettings = @{
                SearchHighlight = $True
                AutoSize        = $true
                Style           = 'cell-border'
                ScrollX         = $true
                HideButtons     = $true
                HideFooter      = $true
                FixedHeader     = $true
                TextWhenNoData  = 'No Data to display here'
                DisableSearch   = $true
                ScrollCollapse  = $true
                #Buttons        =  @('searchBuilder','pdfHtml5','excelHtml5')
                ScrollY         = $true
                DisablePaging   = $true
                PagingLength    = '10'
            }
            $ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
            #endregion

            #region Build HTML
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "SystemInfo-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"

            New-HTML -TitleText 'SystemInfo' -FilePath $HTMLPath {
                New-HTMLLogo -RightLogoString $ImageLink
                New-HTMLNavFloat -Title 'Server Info' -TitleColor AirForceBlue -TaglineColor Amethyst {
                    New-NavFloatWidget -Type List {
                        New-NavFloatWidgetItem -IconColor AirForceBlue -IconSolid home -Name 'Home' -LinkHome
                        foreach ($SysInfo in $allcomp) { New-NavFloatWidgetItem -IconColor Blue -IconBrands bluetooth -Name "$($SysInfo.Hostname)" -InternalPageID "$($SysInfo.Hostname)" }
                        foreach ($SysInfo in $allcomp) { New-NavFloatWidgetItem -IconColor red -IconBrands cuttlefish -Name "$($SysInfo.Hostname)(Alt View)" -InternalPageID "$($SysInfo.Hostname)(Alt View)" }
                    }
                } -ButtonColor White -ButtonColorBackground red -ButtonLocationRight 30px -ButtonLocationTop 70px -ButtonColorBackgroundOnHover pink -ButtonColorOnHover White

                New-HTMLPanel -Invisible {
                    New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 40 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text 'Welcome to your Server Info' }
                    New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Date Collected: $($SysInfo.DateCollected)" }
                    New-HTMLPanel -Invisible -Content { $allcomp.hostname | ForEach-Object { New-HTMLText -FontSize 20 -FontStyle oblique -TextTransform lowercase -Color '#00203F' -Alignment center -Text "$($_)" } }

                }

                foreach ($SysInfo in $allcomp) {

                    New-HTMLPage -Name "$($SysInfo.Hostname)" -PageContent {
                        New-HTMLLogo -RightLogoString $ImageLink
                        New-HTMLPanel -Invisible {
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 40 -FontStyle oblique -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Server: $($SysInfo.Hostname)" }
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Date Collected: $($SysInfo.DateCollected)" }
                        }


                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 20% -Title 'Windows' { New-HTMLTable -DataTable $SysInfo.Windows @TableSettings } -X 10px -Y 10px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'OS' { New-HTMLTable -DataTable $SysInfo.OS @TableSettings } -X 40px -Y 40px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 30% -Width 30% -Title 'AntiVirus' { New-HTMLTable -DataTable $SysInfo.AntiVirus @TableSettings } -X 70px -Y 70px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Bios' { New-HTMLTable -DataTable $SysInfo.Bios @TableSettings } -X 100px -Y 100px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Environment' { New-HTMLTable -DataTable $SysInfo.Environment @TableSettings } -X 130px -Y 130px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 50% -Title 'EventViewer' { New-HTMLTable -DataTable $SysInfo.EventViewer @TableSettings {
                                New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                                New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } } -X 160px -Y 160px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 30% -Title 'Software' { New-HTMLTable -DataTable $SysInfo.Software @TableSettings } -X 190px -Y 190px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 20% -Width 50% -Title 'Network' { New-HTMLTable -DataTable $SysInfo.Network @TableSettings } -X 220px -Y 220px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Services' { New-HTMLTable -DataTable $SysInfo.Services @TableSettings {
                                New-TableCondition -Name 'Status' -ComparisonType string -Operator eq -Value 'Stopped' -Color GhostWhite -Row -BackgroundColor FaluRed } } -X 250px -Y 250px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 20% -Title 'hotfix' { New-HTMLTable -DataTable $SysInfo.hotfix @TableSettings } -X 270px -Y 170px


                    }
                    New-HTMLPage -Name "$($SysInfo.Hostname)(Alt View)" -PageConten {
                    New-HTMLLogo -RightLogoString $ImageLink
                        New-HTMLPanel -Invisible {
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 40 -FontStyle oblique -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Server: $($SysInfo.Hostname)" }
                            New-HTMLPanel -Invisible -Content { New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment center -Text "Date Collected: $($SysInfo.DateCollected)" }
                        }
                    $SysInfo | Get-Member -MemberType NoteProperty |ForEach-Object {
                    New-HTMLSection -HeaderText $($_.name) @SectionSettings -Collapsed -Content {
                        New-HTMLTable -DataTable $SysInfo.$($_.name) @TableSettings {
                                New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                                New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange
                                New-TableCondition -Name 'Status' -ComparisonType string -Operator eq -Value 'Stopped' -Color GhostWhite -Row -BackgroundColor FaluRed
                        }
                        }
                    }
                    }
                }

            } -Online -ShowHTML
        }
        catch { Write-Warning "[Report]HTML Report Failed:`n $($_.Exception.Message)" }
        #endregion
    }
    if ($Export -eq 'Host') { return $allcomp }



} #end Function
 
Export-ModuleMember -Function Get-SystemInfo
#endregion
 
#region Get-WinEventLogExtract.ps1
######## Function 28 of 95 ##################
# Function:         Get-WinEventLogExtract
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/25 01:49:48
# Synopsis:         Extract Event logs of a server list, and create html / excel report
#############################################
 
<#
.SYNOPSIS
 Extract Event logs of a server list, and create html / excel report

.DESCRIPTION
 Extract Event logs of a server list, and create html / excel report

.PARAMETER ComputerName
Name of the host

.PARAMETER Days
Limit the search results

.PARAMETER ErrorLevel
Set the default filter to this level and above.

.PARAMETER FilterCitrix
Only show Citrix errors

.PARAMETER Export
Export results

.PARAMETER ReportPath
Path where report will be saved

.EXAMPLE
Get-WinEventLogExtract -ComputerName localhost

#>
Function Get-WinEventLogExtract {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-WinEventLogExtract')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateScript( {
                $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use this fuction.' } })]
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0)]
        [string[]]$ComputerName,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [int]$Days,
        [Parameter(Mandatory = $true,
            Position = 2)]
        [validateset('Critical', 'Error', 'Warning', 'Informational')]
        [string]$ErrorLevel,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )
    Begin {
    }
    Process {
        [System.Collections.ArrayList]$AllEvents = @()
        $ComputerName | ForEach-Object {
            $comp = $_
            Write-Color '[Collecting] ', 'Windows Events: ', $((Get-FQDN -ComputerName $comp).fqdn) -Color Yellow, green, Cyan
            if (-not(Test-Connection $comp -Count 2 -Quiet)) { Write-Warning "Unable to connect to $($comp)" }
            else {
                try {
                    [hashtable]$filter = @{
                        StartTime = $((Get-Date).AddDays(-$days))
                    }
                    if ($ErrorLevel -like 'Critical') { $filter.Add('Level', @(1)) }
                    if ($ErrorLevel -like 'Error') { $filter.Add('Level', @(1, 2)) }
                    if ($ErrorLevel -like 'Warning') { $filter.Add('Level', @(1, 2, 3)) }
                    if ($ErrorLevel -like 'Informational') { $filter.Add('Level', @(1, 2, 3, 4)) }

                    $filter.Add('LogName', @('Application', 'System', 'Security', 'Setup') )
                    $tmpEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object MachineName, TimeCreated, UserId, Id, LevelDisplayName, LogName, ProviderName, Message

                    [void]$AllEvents.Add([pscustomobject]@{
                            Host   = ((Get-FQDN -ComputerName $comp).fqdn)
                            Events = $tmpEvents
                        })
                } catch {Write-Warning "Error: `nMessage:$($_.Exception)"}
            }
        }

        if ($Export -eq 'Excel') {
            $path = Get-Item $ReportPath
            $ExcelPath = Join-Path $Path.FullName -ChildPath "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx"
            $AllEvents.Events | Export-Excel -Path $ExcelPath -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "All Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot -FreezeTopRow -TableStyle Dark8 -BoldTopRow -ConditionalText $(
                New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' -PatternType Gray125
                New-ConditionalText -Text 'Error' -ConditionalTextColor white -BackgroundColor red -Range 'E:E' -PatternType Gray125
            ) -Show
            }

        if ($Export -eq 'HTML') {
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
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"

            New-HTML -TitleText "WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $HTMLPath {
                    New-HTMLHeader {
                        New-HTMLText -FontSize 20 -FontStyle oblique -Color '#00203F' -Alignment center -Text "Date Collected: $(Get-Date)"
                    }
                   $AllEvents | ForEach-Object {
                   New-HTMLTab -name "$($_.host)" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "$(($_.host).ToUpper())"
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "Events [$($_.events.count)]"
                    New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.events) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }

                }
                    }
                } -Online -Encoding UTF8 -ShowHTML


            }

        if ($Export -eq 'Host') { $AllEvents }
    }
} #end Function


 
Export-ModuleMember -Function Get-WinEventLogExtract
#endregion
 
#region Import-CitrixSiteConfigFile.ps1
######## Function 29 of 95 ##################
# Function:         Import-CitrixSiteConfigFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/25 02:26:42
# Synopsis:         Import the Citrix config file, and created a variable with the details
#############################################
 
<#
.SYNOPSIS
 Import the Citrix config file, and created a variable with the details

.DESCRIPTION
 Import the Citrix config file, and created a variable with the details

.PARAMETER CitrixSiteConfigFilePath
Path to config file

.EXAMPLE
Import-CitrixSiteConfigFile -CitrixSiteConfigFilePath c:\temp\CTXSiteConfig.json

#>
Function Import-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Import-CitrixSiteConfigFile')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$CitrixSiteConfigFilePath 
		)

	$JSONParameter = Get-Content ($CitrixSiteConfigFilePath) | ConvertFrom-Json
	$JSONParameter.PSObject.Properties | Where-Object { $_.name -notlike 'CTXServers' } | ForEach-Object { Write-Color $_.name, ':', $_.value -Color DarkYellow, DarkCyan, Green -ShowTime }
	Write-Color 'Created array CTXServers:' -Color Red -StartTab 2 -LinesAfter 1 -LinesBefore 1

	$JSONParameter.PSObject.Properties | Where-Object { $_.name -like 'CTXServers' } | ForEach-Object { New-Variable -Name $_.name -Value $_.value -Force -Scope global }

	$CTXServers.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

} #end Function
 
Export-ModuleMember -Function Import-CitrixSiteConfigFile
#endregion
 
#region Import-XamlConfigFile.ps1
######## Function 30 of 95 ##################
# Function:         Import-XamlConfigFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:57
# Synopsis:         Import the wpf xaml file and create variables from objects
#############################################
 
<#
.SYNOPSIS
Import the wpf xaml file and create variables from objects

.DESCRIPTION
Import the wpf xaml file and create variables from objects

.PARAMETER XamlFile
Path to the xaml file to import

.PARAMETER FormName
The form name variable to be created.

.PARAMETER ShowExample
Show example to open the form.


.EXAMPLE
Import-XamlConfigFile -XamlFile D:\MainWindow.xaml -FormName SMainForm

#>
Function Import-XamlConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Import-XamlConfigFile')]

    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.xaml') })]
        [System.IO.FileInfo]$XamlFile,
        [string]$FormName,
        [switch]$ShowExample
    )

    $inputXAML = Get-Content -Path $xamlFile -Raw

    $inputXAML = $inputXAML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXAML

    #Check for a text changed value (which we cannot parse)
    If ($xaml.SelectNodes('//*[@Name]') | Where-Object TextChanged) {
        Write-Error "This Snippet can't convert any lines which contain a 'textChanged' property. `n please manually remove these entries"
        $xaml.SelectNodes('//*[@Name]') | Where-Object TextChanged | ForEach-Object { Write-Warning "Please remove the TextChanged property from this entry $($_.Name)" }
        return
    }

    #Read XAML

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
        New-Variable -Name $FormName -Value $Form -Force -Scope global
    }
    catch [System.Management.Automation.MethodInvocationException] {
        Write-Warning 'We ran into a problem with the XAML code.  Check the syntax for this control...'
        Write-Host $error[0].Exception.Message -ForegroundColor Red
        if ($error[0].Exception.Message -like '*button*') {
            Write-Warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"
        }
    }
    catch {
        #if it broke some other way :D
        Write-Host 'Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed.'
    }

    #===========================================================================
    # Store Form Objects In PowerShell
    #===========================================================================

    $xaml.SelectNodes('//*[@Name]') | ForEach-Object { New-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope global -Force }

    Function Get-FormVariable {
        if ($global:ReadmeDisplay -ne $true) { Write-Host 'If you need to reference this display again, run Get-FormVariables' -ForegroundColor Yellow; $global:ReadmeDisplay = $true }
        Write-Host 'Found the following interactable elements from our form' -ForegroundColor Cyan
        Get-Variable WPF*
    }


    Get-FormVariables

    if ($ShowExample) {

        Write-Output @"
#Adding code to a button, so that when clicked, it pings a system
`$WPF_button.Add_Click({ Test-connection -count 1 -ComputerName `$WPFtextBox.Text
})
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
`$$FormName.ShowDialog() | out-null
"@
    }

    #===========================================================================
    # Use this space to add code to the various form elements in your GUI
    #===========================================================================

    #Reference

    #Adding items to a dropdown/combo box
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})

    #Setting the text of a text box to the current PC name
    #$WPFtextBox.Text = $env:COMPUTERNAME

    #Adding code to a button, so that when clicked, it pings a system
    # $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPTextBox.Text
    # })
    #===========================================================================
    # Shows the form
    #===========================================================================
    # write-host "To show the form, run the following" -ForegroundColor Cyan
    # '$Form.ShowDialog() | out-null'




} #end Function
 
Export-ModuleMember -Function Import-XamlConfigFile
#endregion
 
#region Install-BGInfo.ps1
######## Function 31 of 95 ##################
# Function:         Install-BGInfo
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install and auto runs bginfo at startup.
#############################################
 
<#
.SYNOPSIS
Install and auto runs bginfo at startup.

.DESCRIPTION
Install and auto runs bginfo at startup.

.PARAMETER RunBGInfo
Execute bginfo at the end of the script

.EXAMPLE
Install-BGInfo -RunBGInfo

#>
Function Install-BGInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Install-BGInfo')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$RunBGInfo = $false
	)


	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'BGInfo')
	if (-not(Test-Path $ConfigPath)) {
		$ModuleConfigPath = New-Item $ConfigPath -ItemType Directory -Force
		Write-Color '[Creating] ', 'Config Folder:', ' Completed' -Color Yellow, Cyan, Green
	} else { $ModuleConfigPath = Get-Item $ConfigPath }

	try {
		$module = Get-Module PSToolKit
		if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
		Get-ChildItem (Join-Path $module.ModuleBase -ChildPath '\private\BGInfo') | ForEach-Object {
			Copy-Item -Path $_.FullName -Destination $ModuleConfigPath.FullName -Force
			Write-Color '[Updating] ', "$($_.name): ", 'Completed' -Color Yellow, Cyan, Green
		}
	} catch {throw "Unable to update from module source:`n $($_.Exception.Message)"}

	try {
		$bgInfoRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
		$bgInfoRegKey = 'BgInfo'
		$bgInfoRegType = 'String'
		$bgInfoRegKeyValue = '"C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe" "C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi" /timer:0 /nolicprompt'
		$regKeyExists = (Get-Item $bgInfoRegPath -ErrorAction SilentlyContinue).Property -contains $bgInfoRegkey

		If ($regKeyExists -eq $True) {
			Set-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -Value $bgInfoRegkeyValue | Out-Null
			Write-Color '[Recreating] ', 'Registry AutoStart: ', 'Completed' -Color Yellow, Cyan, Green
		} Else {
			New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue | Out-Null
			Write-Color '[Creating] ', 'Registry AutoStart: ', 'Completed' -Color Yellow, Cyan, Green
		}
	} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

	if ($RunBGInfo) {
		try {
			Write-Color '[Starting] ', 'BGInfo' -Color Yellow, Cyan
			Start-Process -FilePath 'C:\Program Files\PSToolKit\BGInfo\Bginfo64.exe' -ArgumentList '"C:\Program Files\PSToolKit\BGInfo\PSToolKit.bgi" /timer:0 /nolicprompt' -NoNewWindow
		} catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
	}
} #end Function
 
Export-ModuleMember -Function Install-BGInfo
#endregion
 
#region Install-ChocolateyApp.ps1
######## Function 32 of 95 ##################
# Function:         Install-ChocolateyApp
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install chocolatey apps from a json list.
#############################################
 
<#
.SYNOPSIS
 Install chocolatey apps from a json list.

.DESCRIPTION
 Install chocolatey apps from a json list.

.PARAMETER BaseApps
Use build in base app list

.PARAMETER ExtendedApps
Use build in extended app list

.PARAMETER OtherApps
Specify your own json list file

.PARAMETER JsonPath
Path to the json file

.EXAMPLE
Install-ChocolateyApps -BaseApps

#>
Function Install-ChocolateyApp {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyApps')]
	PARAM(
		[Parameter(ParameterSetName = 'Set1')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$BaseApps = $false,
		[Parameter(ParameterSetName = 'Set1')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$ExtendedApps = $false,
		[Parameter(ParameterSetName = 'Set2')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$OtherApps = $false,
		[Parameter(ParameterSetName = 'Set2')]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$JsonPath
	)
	try {
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		$ConPath = Get-Item $ConfigPath
	} catch { Throw "Config path does not exist`nRun Update-PSToolKitConfigFiles to install the config files" }
	if ($BaseApps) { $AppList = (Join-Path $ConPath.FullName -ChildPath BaseAppList.json) }
	if ($ExtendedApps) { $AppList = (Join-Path $ConPath.FullName -ChildPath ExtendedAppsList.json) }
	if ($OtherApps) { $AppList = Get-Item $JsonPath }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	[System.Collections.ArrayList]$installs = @()
	[System.Collections.ArrayList]$installs = Get-Content $AppList -Raw | ConvertFrom-Json

	foreach ($app in $installs) {
		$ChocoApp = choco search $app.name --exact --local-only --limit-output
		$ChocoAppOnline = choco search $app.name --exact --limit-output
		if ($null -eq $ChocoApp) {
			Write-Color '[Installing] ', $($app.name), ' from source ', $app.Source -Color Yellow, Cyan, Green, Cyan
			choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
			if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
		} else {
			Write-Color '[Installing] ', $($ChocoApp.split('|')[0]), " (Version: $($ChocoApp.split('|')[1]))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
			if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
				Write-Color '[Updating] ', $($app.name), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', $app.Source -Color Yellow, Cyan, Yellow, Green, Cyan
				choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
				if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
			}
		}
	}


} #end Function
 
Export-ModuleMember -Function Install-ChocolateyApp
#endregion
 
#region Install-ChocolateyClient.ps1
######## Function 33 of 95 ##################
# Function:         Install-ChocolateyClient
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Downloads and installs the Chocolatey client.
#############################################
 
<#
.SYNOPSIS
Downloads and installs the Chocolatey client.

.DESCRIPTION
Downloads and installs the Chocolatey client.

.EXAMPLE
Install-ChocolateyClient

#>
Function Install-ChocolateyClient {
  [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyClient')]
  PARAM()

  if ((Test-Path $profile) -eq $false ) {
    Write-Warning 'Profile does not exist, creating file.'
    New-Item -ItemType File -Path $Profile -Force
  }

		$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) { Throw 'Must be running an elevated prompt to use function' }

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $web = New-Object System.Net.WebClient
    $web.DownloadFile('https://community.chocolatey.org/install.ps1', "$($env:TEMP)\choco-install.ps1")
    & "$($env:TEMP)\choco-install.ps1" *> $null

    if (Get-Command choco -ErrorAction SilentlyContinue) {
      Write-Color '[Installing] ', 'Chocolatey Client: ', 'Complete' -Color Yellow, Cyan, Green
      choco config set --name="'useEnhancedExitCodes'" --value="'true'" --limit-output
      choco config set --name="'allowGlobalConfirmation'" --value="'true'" --limit-output
      choco config set --name="'removePackageInformationOnUninstall'" --value="'true'" --limit-output
      Write-Color '[Set] ', 'Chocolatey Client Config: ', 'Complete' -Color Yellow, Cyan, Green
    } else {Write-Color '[Installing] ', 'Chocolatey Client: ', 'Failed' -Color Yellow, Cyan, red}
  } else {
    Write-Color '[Installing] ', 'Chocolatey Client: ', 'Aleady Installed' -Color Yellow, Cyan, DarkRed
  }
} #end Function
 
Export-ModuleMember -Function Install-ChocolateyClient
#endregion
 
#region Install-ChocolateyServer.ps1
######## Function 34 of 95 ##################
# Function:         Install-ChocolateyServer
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         This will download, install and setup a new Chocolatey Repo Server
#############################################
 
<#
.SYNOPSIS
This will download, install and setup a new Chocolatey Repo Server

.DESCRIPTION
This will download, install and setup a new Chocolatey Repo Server

.PARAMETER SiteName
Name of the new repo

.PARAMETER AppPoolName
Pool name in IIS

.PARAMETER SitePath
Path where packages will be saved.

.PARAMETER APIKey
Change the default api to this key.

.EXAMPLE
Install-ChocolateyServer -SiteName blah -AppPoolName blah -SitePath c:\temp\blah -APIKey 123456789

#>
Function Install-ChocolateyServer {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyServer')]

    PARAM(
        [Parameter(Mandatory = $true)]
        [string]$SiteName,
        [Parameter(Mandatory = $true)]
        [String]$AppPoolName,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$SitePath,
        [string]$APIKey
    )


    function Add-Acl {
        Param (
            [string]$Path,
            [System.Security.AccessControl.FileSystemAccessRule]$AceObject
        )

        Write-Verbose "Retrieving existing ACL from $Path"
        $objACL = Get-Acl -Path $Path
        $objACL.AddAccessRule($AceObject)
        Write-Verbose "Setting ACL on $Path"
        Set-Acl -Path $Path -AclObject $objACL
    }

    function New-AclObject {
        Param (
            [string]$SamAccountName,
            [System.Security.AccessControl.FileSystemRights]$Permission,
            [System.Security.AccessControl.AccessControlType]$AccessControl = 'Allow',
            [System.Security.AccessControl.InheritanceFlags]$Inheritance = 'None',
            [System.Security.AccessControl.PropagationFlags]$Propagation = 'None'
        )

        New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule($SamAccountName, $Permission, $Inheritance, $Propagation, $AccessControl)
    }

    if ($null -eq (Get-Command -Name 'choco.exe' -ErrorAction SilentlyContinue)) {
        Write-Warning 'Chocolatey not installed. Cannot install standard packages.'
        Exit 1
    }
    # Install Chocolatey.Server prerequisites
    choco install IIS-WebServer --source windowsfeatures
    choco install IIS-ASPNET45 --source windowsfeatures

    # Install Chocolatey.Server
    choco upgrade chocolatey.server -y

    # Step by step instructions here https://docs.chocolatey.org/en-us/guides/organizations/set-up-chocolatey-server#setup-normally
    # Import the right modules
    Import-Module WebAdministration
    # Disable or remove the Default website
    Get-Website -Name 'Default Web Site' | Stop-Website
    Set-ItemProperty -Path 'IIS:\Sites\Default Web Site' -Name serverAutoStart -Value False    # disables website

    # Set up an app pool for Chocolatey.Server. Ensure 32-bit is enabled and the managed runtime version is v4.0 (or some version of 4). Ensure it is "Integrated" and not "Classic".
    New-WebAppPool -Name $appPoolName -Force
    Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name enable32BitAppOnWin64 -Value True       # Ensure 32-bit is enabled
    Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name managedRuntimeVersion -Value v4.0       # managed runtime version is v4.0
    Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name managedPipelineMode -Value Integrated   # Ensure it is "Integrated" and not "Classic"
    Restart-WebAppPool -Name $appPoolName   # likely not needed ... but just in case

    # Set up an IIS website pointed to the install location and set it to use the app pool.
    New-Website -Name $siteName -ApplicationPool $appPoolName -PhysicalPath $sitePath

    # Add permissions to c:\tools\chocolatey.server:
    'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$appPoolName" | ForEach-Object {
        $obj = New-AclObject -SamAccountName $_ -Permission 'ReadAndExecute' -Inheritance 'ContainerInherit', 'ObjectInherit'
        Add-Acl -Path $sitePath -AceObject $obj
    }

    # Add the permissions to the App_Data subfolder:
    $appdataPath = Join-Path -Path $sitePath -ChildPath 'App_Data'
    'IIS_IUSRS', "IIS APPPOOL\$appPoolName" | ForEach-Object {
        $obj = New-AclObject -SamAccountName $_ -Permission 'Modify' -Inheritance 'ContainerInherit', 'ObjectInherit'
        Add-Acl -Path $appdataPath -AceObject $obj
    }

    if (-not($null -like $APIKey)) { ((Get-Content (Join-Path $sitePath -ChildPath '\web.config') -Raw) -replace 'chocolateyrocks', 'white') | Set-Content -Path (Join-Path $sitePath -ChildPath '\web.config') -Force ; iisreset.exe }
    Write-Color '[Installing] ', 'Chocolaty Server: ', 'Complete' -Color Cyan, Yellow, Green


} #end Function
 
Export-ModuleMember -Function Install-ChocolateyServer
#endregion
 
#region Install-LocalPSRepository.ps1
######## Function 35 of 95 ##################
# Function:         Install-LocalPSRepository
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/11 23:52:06
# Synopsis:         Short desCreates a repository for offline installations.
#############################################
 
<#
.SYNOPSIS
Short desCreates a repository for offline installations.

.DESCRIPTION
Short desCreates a repository for offline installations.

.PARAMETER RepoName
Name of the local repository

.PARAMETER RepoPath
Path to the folder for the repository.

.PARAMETER ImportPowerShellGet
Downloads an offline copy of PowerShellGet

.PARAMETER DownloadModules
Downloads an existing json list of modules to the new repository.

.PARAMETER List
The base or extended json module list.

.PARAMETER ModuleNamesList
A string list of module names to download.

.EXAMPLE
Install-LocalPSRepository -RepoName repo -RepoPath c:\utils\repo -DownloadModules -List BaseModules

#>
Function Install-LocalPSRepository {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-LocalPSRepository')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[ValidateScript( { if (-not(Get-PSRepository -Name $_)) { $true }
				else { throw 'RepoName already exists' }
			})]
		[string]$RepoName,
		[Parameter(Mandatory)]
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$RepoPath,

		[Parameter(ParameterSetName = 'import')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$ImportPowerShellGet,

		[Parameter(ParameterSetName = 'import')]
		[switch]$DownloadModules,

		[Parameter(ParameterSetName = 'import')]
		[ValidateSet('BaseModules', 'ExtendedModules')]
		[string]$List = 'ExtendedModules',

		[Parameter(ParameterSetName = 'import', ValueFromPipeline)]
		[string[]]$ModuleNamesList
	)

	try {
		$options = @{
			Name                  = $RepoName 
			SourceLocation        = $RepoPath.FullName
			PublishLocation       = $RepoPath.FullName
			ScriptSourceLocation  = $RepoPath.FullName
			ScriptPublishLocation = $RepoPath.FullName
			InstallationPolicy    = 'Trusted'
		}
		Write-Color '[Installing] ', 'Repo: ', $($RepoName), ' to folder: ', $($RepoPath) -Color Yellow, Cyan, Green, cyan, Green
		Register-PSRepository @options
	}
 catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }


	if ($ImportPowerShellGet) {
		try {
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGetDeploy")) { New-Item "$($env:TMP)\OfflinePowerShellGetDeploy" -ItemType Directory -Force | Out-Null }
			if (-not(Test-Path "$($env:TMP)\OfflinePowerShellGet")) { New-Item "$($env:TMP)\OfflinePowerShellGet" -ItemType Directory -Force | Out-Null }

			Write-Color '[Installing] ', 'OfflinePowerShellGetDeploy', ' Module' -Color Yellow, Cyan, green
			Save-Module -Name OfflinePowerShellGetDeploy -Path "$($env:TMP)\OfflinePowerShellGetDeploy" -Repository PSGallery
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGetDeploy\*.psm1" -Recurse | Import-Module

			Write-Color '[Installing] ', 'PowerShellGet', ' Offline' -Color Yellow, Cyan, Green
			Save-PowerShellGetForOffline -LocalFolder "$($env:TMP)\OfflinePowerShellGet"
			
			Write-Color '[Uploading] ', 'PackageManagement', ' to ', $($RepoName) -Color Yellow, Cyan, Green, DarkRed
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PackageManagement.psd1" | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
            
			Write-Color '[Uploading] ', 'PowerShellGet', ' to ', $($RepoName) -Color Yellow, Cyan, Green, DarkRed
			Get-ChildItem "$($env:TMP)\OfflinePowerShellGet\*\*\PowerShellGet.psd1" | ForEach-Object { Publish-Module -Path $_.DirectoryName -Repository $RepoName -NuGetApiKey 'AnyStringWillDo' -Force }
		}
		catch { Write-Warning "Error: `n`tMessage:$($_.Exception.Message)" }
	}
	if ($DownloadModules) {
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
		else {
			$mods | ForEach-Object {
				Write-Color '[Installing] ', $($_), ' to folder: ', $($RepoPath) -Color Yellow, Cyan, Green, cyan, Green, DarkRed
				Save-Package -Name $_ -Provider NuGet -Source https://www.powershellgallery.com/api/v2 -Path $RepoPath | Out-Null
			}
		}
	}
} #end Function
 
Export-ModuleMember -Function Install-LocalPSRepository
#endregion
 
#region Install-MicrosoftTerminal.ps1
######## Function 36 of 95 ##################
# Function:         Install-MicrosoftTerminal
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install MicrosoftTerminal on your device.
#############################################
 
<#
.SYNOPSIS
Install MicrosoftTerminal on your device.

.DESCRIPTION
Install MicrosoftTerminal on your device.

.PARAMETER DefaultSettings
Replace the settings.json file with one from this module.

.EXAMPLE
Install-MicrosoftTerminal -DefaultSettings

#>
Function Install-MicrosoftTerminal {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MicrosoftTerminal')]
	PARAM(
		[switch]$DefaultSettings = $false
	)

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

	try {
		if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
		'microsoft-windows-terminal', 'cascadia-code-nerd-font', 'cascadiacodepl' | ForEach-Object {
			$ChocoApp = choco search $_ --exact --local-only --limit-output
			$ChocoAppOnline = choco search $_ --exact --limit-output
			if ($null -eq $ChocoApp) {
				Write-Color '[Installing] ', $($_), ' from source ', 'chocolatey' -Color Yellow, Cyan, Green, Cyan
				choco upgrade $($_) --accept-license --limit-output -y | Out-Null
				if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
			} else {
				Write-Color '[Installing] ', $($ChocoApp.split('|')[0]), " (Version: $($ChocoApp.split('|')[1]))", ' Already Installed' -Color Yellow, Cyan, Green, DarkRed
				if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
					Write-Color '[Updating] ', $($_), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', 'chocolatey' -Color Yellow, Cyan, Yellow, Green, Cyan -StartTab 1
					choco upgrade $($_) --accept-license --limit-output -y | Out-Null
					if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($_) Code: $($LASTEXITCODE)"}
				}
			}
			if ($DefaultSettings) {
				$settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', 'Microsoft.WindowsTerminal*', 'LocalState', 'Settings.json')
				$SetFile = Get-Item $settingsFile
				if (Test-Path $SetFile.FullName) {Rename-Item -Path $SetFile.FullName -NewName "Settings-$(Get-Date -Format yyyy.MM.dd_HHMM).json" -Force | Out-Null}

				$module = Get-Module PSToolKit
				if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
				Get-Content (Join-Path $module.ModuleBase -ChildPath '\private\Config\MicrosoftTerminalSettings.json') | Set-Content $SetFile.FullName -Force
			}
		}
	} catch { Write-Warning "[Installing] Microsoft Terminal: Failed:`n $($_.Exception.Message)" }

}
 
Export-ModuleMember -Function Install-MicrosoftTerminal
#endregion
 
#region Install-MSUpdate.ps1
######## Function 37 of 95 ##################
# Function:         Install-MSUpdate
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Perform windows update
#############################################
 
<#
.SYNOPSIS
Perform windows update

.DESCRIPTION
Perform windows update

.PARAMETER PerformReboot
Check and perform a reboot if required.

.EXAMPLE
Install-MSUpdates -PerformReboot

#>
Function Install-MSUpdate {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MSUpdates')]
	PARAM(
		[switch]$PerformReboot = $false
	)

	try {
		$UpdateModule = Get-Module PSWindowsUpdate
		if ($null -like $UpdateModule) {$UpdateModule = Get-Module PSWindowsUpdate -ListAvailable}
		if ($null -like $UpdateModule) {
			Write-Color '[Installing] ', 'Required Modules: ', 'PSWindowsUpdate' -Color Yellow, green, Cyan
			Install-Module -Name PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
		}
		Import-Module PSWindowsUpdate -Force
		Write-Color '[Installing] ', 'Windows Updates:', ' Software' -Color Yellow, Cyan, Green
		Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Software
		Write-Color '[Installing] ', 'Windows Updates:', ' Drivers' -Color Yellow, Cyan, Green
		Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -RecurseCycle 4 -UpdateType Driver
	} catch { Write-Warning "[Installing] Windows Updates: Failed:`n $($_.Exception.Message)" }

	if ($PerformReboot) {
		try {
			Write-Color '[Checking] ', 'Pending Reboot' -Color Yellow, Cyan
			$checkreboot = Test-PendingReboot -ComputerName $env:computername
			if ($checkreboot.IsPendingReboot -like 'True') {
				Write-Color '[Checking] ', 'Reboot Required', ' (Reboot in 15 sec)' -Color Yellow, DarkRed, Cyan
				Start-Sleep -Seconds 15
				Restart-Computer -Force
			} else {
				Write-Color '[Checking] ', 'Reboot Not Required' -Color Yellow, Cyan
			}
		} catch { Write-Warning "[Checking] Required Reboot: Failed:`n $($_.Exception.Message)" }
	}
} #end Function
 
Export-ModuleMember -Function Install-MSUpdate
#endregion
 
#region Install-MSWinget.ps1
######## Function 38 of 95 ##################
# Function:         Install-MSWinget
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install the package manager winget
#############################################
 
<#
.SYNOPSIS
Install the package manager winget

.DESCRIPTION
Install the package manager winget

.EXAMPLE
Install-MSWinget

#>
Function Install-MSWinget {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-MSWinget')]

    PARAM()
    # 1 - Work Station
    # 2 - Domain Controller
    # 3 - Server
    $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object ProductType, Version, BuildNumber
    if (([version]$checkver.Version).Major -gt 9 -and ([version]$checkver.Version).Build -gt 14393) {

        try {
            $checkInstall = [bool](winget -ErrorAction Stop)
        }
        catch { $checkInstall = $false }
        if ($checkInstall) { Write-Color 'Winget: ', 'Already Installed' -Color Cyan, Yellow }
        else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $url = 'https://github.com/microsoft/winget-cli/releases/latest/'
            $request = [System.Net.WebRequest]::Create($url)
            $request.AllowAutoRedirect = $false
            $response = $request.GetResponse()
            $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + '/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
            $OutFile = [IO.Path]::Combine('c:\temp', 'winget-latest.msixbundle')

            if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

            Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile

            if (![bool](Get-AppxPackage -Name Microsoft.VCLibs*)) {
                Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
            }

            Add-AppxPackage -Path $OutFile -ErrorAction Stop

            #winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
            if (Test-Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json") {
                $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
                $settingsJson =
                @'
    {
        // For documentation on these settings, see: https://aka.ms/winget-settings
        "experimentalFeatures": {
          "experimentalMSStore": true,
        }
    }
'@;
                $settingsJson | Out-File $settingsPath -Encoding utf8
            }

            try {
                $checkInstall2 = [bool](winget -ErrorAction Stop)
            }
            catch { $checkInstall2 = $false }
            if ($checkInstall2) { Write-Color 'Winget: ', 'Installation Successful' -Color Cyan, green }
            else { Write-Color 'Winget: ', 'Installation Failed' -Color Cyan, red }
        }
    }
    else { Write-Warning 'Your Operating System is not compatible, Windows 10 build 14393 and higher is' }




} #end Function
 
Export-ModuleMember -Function Install-MSWinget
#endregion
 
#region Install-NFSClient.ps1
######## Function 39 of 95 ##################
# Function:         Install-NFSClient
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install NFS Client for windows
#############################################
 
<#
.SYNOPSIS
Install NFS Client for windows

.DESCRIPTION
Install NFS Client for windows

.EXAMPLE
Install-NFSClient

#>
Function Install-NFSClient {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-NFSClient')]
	PARAM(	)

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

	try {
		if ((Get-WindowsOptionalFeature -Online -FeatureName *nfs*).state -contains 'Disabled') {
			$checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
			if ($checkver -like '*server*') {
				Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ServerAndClient' -All | Out-Null
			} else {
				Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ClientOnly' -All | Out-Null
			}
			Enable-WindowsOptionalFeature -Online -FeatureName 'ClientForNFS-Infrastructure' -All | Out-Null
			Enable-WindowsOptionalFeature -Online -FeatureName 'NFS-Administration' -All | Out-Null
			nfsadmin client stop | Out-Null
			Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousUID' -Type DWord -Value 0 | Out-Null
			Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousGID' -Type DWord -Value 0 | Out-Null
			nfsadmin client start | Out-Null
			nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i | Out-Null
			Write-Color '[Installing] ', 'NFS Client: ', 'Complete' -Color Yellow, Cyan, Green
		} else {
			Write-Color '[Installing] ', 'NFS Client: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
		}
	} catch { Write-Warning "[Installing] NFS Client: Failed:`n $($_.Exception.Message)" }

} #end Function
 
Export-ModuleMember -Function Install-NFSClient
#endregion
 
#region Install-PowerShell7x.ps1
######## Function 40 of 95 ##################
# Function:         Install-PowerShell7x
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install ps7
#############################################
 
<#
.SYNOPSIS
Install ps7

.DESCRIPTION
Install ps7

.EXAMPLE
Install-PowerShell7x

#>
Function Install-PowerShell7x {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/Install-PowerShell7x")]
                PARAM()

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}


	try {
		if ((Test-Path 'C:\Program Files\PowerShell\7') -eq $false) {
			$ReleaseModule = Get-Module PSReleaseTools
			if ($null -like $ReleaseModule) {$ReleaseModule = Get-Module PSReleaseTools -ListAvailable}
			if ($null -like $ReleaseModule) {
				Write-Color '[Installing] ', 'Required Modules: ', 'PSReleaseTools' -Color Yellow, green, Cyan
				Install-Module -Name PSReleaseTools -Scope CurrentUser -AllowClobber -Force
			}
			Import-Module PSReleaseTools -Force
			Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
			Write-Color '[Installing] ', 'PowerShell 7.x ', 'Complete' -Color Yellow, Cyan, Green
		} else {
			Write-Color '[Installing] ', 'PowerShell 7.x: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
		}
	} catch { Write-Warning "[Installing] PowerShell 7.x: Failed:`n $($_.Exception.Message)" }

} #end Function
 
Export-ModuleMember -Function Install-PowerShell7x
#endregion
 
#region Install-RSAT.ps1
######## Function 41 of 95 ##################
# Function:         Install-RSAT
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install Remote Admin Tools
#############################################
 
<#
.SYNOPSIS
Install Remote Admin Tools

.DESCRIPTION
Install Remote Admin Tools

.EXAMPLE
Install-RSAT

#>
Function Install-RSAT {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-RSAT')]
	PARAM()

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}

	try {
		$checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
		if ($checkver -notlike '*server*') {
			Write-Color '[Installing] ', 'RSAT Tools', ' for a ', 'Workstation OS' -Color Yellow, Cyan, green, Cyan
			$Roles = @('Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0', 'Rsat.DHCP.Tools~~~~0.0.1.0', 'Rsat.Dns.Tools~~~~0.0.1.0', 'Rsat.FileServices.Tools~~~~0.0.1.0', 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0', 'Rsat.ServerManager.Tools~~~~0.0.1.0', 'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0')
			$Roles | ForEach-Object {
				if (-not(Get-WindowsCapability -Name $_ -Online)) {
					Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.split('~')[0].split('.')[1])-$($_.split('~')[0].split('.')[2])" -Color Yellow, Cyan, green, Cyan -StartTab 1
					Add-WindowsCapability -Name $_ -Online | Out-Null
				} else {
					Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.split('~')[0].split('.')[1])-$($_.split('~')[0].split('.')[2])", ' Already Installed' -Color Yellow, Cyan, green, DarkRed -StartTab 1
				}
			}
		} else {
			Write-Color '[Installing] ', 'RSAT Tools', ' for a ', 'Server OS' -Color Yellow, Cyan, green, Cyan
			$roles = @('RSAT-Role-Tools', 'RSAT-AD-Tools', 'RSAT-AD-PowerShell', 'RSAT-ADDS', 'RSAT-AD-AdminCenter', 'RSAT-ADDS-Tools', 'RSAT-ADLDS', 'RSAT-Hyper-V-Tools', 'RSAT-DHCP', 'RSAT-DNS-Server', 'RSAT-File-Services')
			$roles | ForEach-Object {
				if ((Get-WindowsFeature -Name $_).InstallState -notlike 'Installed') {
					Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.Split('-')[1])($($_.Split('-')[2]))" -Color Yellow, Cyan, green, Cyan -StartTab 1
					Install-WindowsFeature -Name $_ -IncludeAllSubFeature | Out-Null
				} else {
					Write-Color '[Installing] ', 'RSAT Tool: ', "$($_.Split('-')[1])($($_.Split('-')[2]))", ' Already Installed' -Color Yellow, Cyan, green, DarkRed -StartTab 1
				}
			}
		}
	} catch { Write-Warning "[Installing] RSAT Tools: Failed:`n $($_.Exception.Message)" }

} #end Function
 
Export-ModuleMember -Function Install-RSAT
#endregion
 
#region Install-VMWareTool.ps1
######## Function 42 of 95 ##################
# Function:         Install-VMWareTool
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Install vmware tools from chocolatety
#############################################
 
<#
.SYNOPSIS
Install vmware tools from chocolatety

.DESCRIPTION
Install vmware tools from chocolatety

.EXAMPLE
Install-VMWareTools

#>
Function Install-VMWareTool {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-VMWareTools')]
	PARAM()


	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Throw 'Must be running an elevated prompt to use this function'}


	try {
		if ((Get-CimInstance -ClassName win32_bios).Manufacturer -like '*VMware*') {
			if (-not(Get-Command choco.exe -ErrorAction SilentlyContinue)) { Install-ChocolateyClient}
			Write-Color '[Installing] ', 'VMWare Tools', ' from source ', 'chocolatey' -Color Yellow, Cyan, green, Cyan
			choco upgrade vmware-tools --accept-license --limit-output -y --source chocolatey | Out-Null
			if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing vmware-tools Code: $($LASTEXITCODE)"}
		} else {Write-Color '[Installing] ', 'VMWare Tools:', ' Not a VMWare VM' -Color Yellow, Cyan, DarkRed}
	} catch { Write-Warning "[Installing] VMWare Tools: Failed:`n $($_.Exception.Message)" }

} #end Function
 
Export-ModuleMember -Function Install-VMWareTool
#endregion
 
#region Install-WingetApp.ps1
######## Function 43 of 95 ##################
# Function:         Install-WingetApp
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:03:39
# ModifiedOn:       2022/08/09 13:35:13
# Synopsis:         Install apps from a json file.
#############################################
 
<#
.SYNOPSIS
Install apps from a json file.

.DESCRIPTION
Install apps from a json file.

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Install-WingetApps -Export HTML -ReportPath C:\temp

#>

Function Install-WingetApp {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-WingetApps")]
	    [OutputType([System.Object[]])]
                PARAM()


	try {
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		$ConPath = Get-Item $ConfigPath
	} catch { Throw "Config path does not exist`nRun Update-PSToolKitConfigFiles to install the config files" }

	$AppList = Get-Content (Join-Path $ConPath.FullName -ChildPath WingetappList.json) | ConvertFrom-Json

	foreach ($app in $AppList){
		Write-Host "[Installing] " -NoNewline -ForegroundColor Yellow; Write-output "$($app.name)" -ForegroundColor Cyan
		& winget install --id $app.id --accept-package-agreements --accept-source-agreements --source msstore -h 2>&1 | Write-Host -ForegroundColor Yellow
	}

} #end Function
 
Export-ModuleMember -Function Install-WingetApp
#endregion
 
#region Install-WingetApps.ps1
######## Function 44 of 95 ##################
# Function:         Install-WingetApps
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/16 10:02:35
# Synopsis:         Install apps from a json file.
#############################################
 
<#
.SYNOPSIS
Install apps from a json file.

.DESCRIPTION
Install apps from a json file.

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Install-WingetApps -Export HTML -ReportPath C:\temp

#>

Function Install-WingetApp {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSToolKit/Install-WingetApps")]
	    [OutputType([System.Object[]])]
                PARAM()


	try {
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		$ConPath = Get-Item $ConfigPath
	} catch { Throw "Config path does not exist`nRun Update-PSToolKitConfigFiles to install the config files" }

	$AppList = Get-Content (Join-Path $ConPath.FullName -ChildPath WingetappList.json) | ConvertFrom-Json

	foreach ($app in $AppList){
		Write-Host "[Installing] " -NoNewline -ForegroundColor Yellow; Write-output "$($app.name)" -ForegroundColor Cyan
		& winget install --id $app.id --accept-package-agreements --accept-source-agreements --source msstore -h 2>&1 | Write-Host -ForegroundColor Yellow
	}

} #end Function
 
Export-ModuleMember -Function Install-WingetApps
#endregion
 
#region Move-ModulesToAllUser.ps1
######## Function 45 of 95 ##################
# Function:         Move-ModulesToAllUser
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/05 16:42:43
# Synopsis:         Move modules from current user to all users
#############################################
 
<#
.SYNOPSIS
Move modules from current user to all users

.DESCRIPTION
Move modules from current user to all users

.PARAMETER AllUsers
Check if the user is an admin.

.EXAMPLE
Move-ModulesToAllUser

.NOTES
General notes
#>
Function Move-ModulesToAllUser {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Move-ModulesToAllUser')]
	[OutputType([System.Object[]])]
	PARAM(
	)

	$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (-not($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Write-Error 'Must be running an elevated prompt run this function'; exit}

	$PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell', 'Modules')
	$PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell', 'Modules')

	if (Test-Path $PersonalWindowsPowerShell) {
		$modules = Get-ChildItem $PersonalWindowsPowerShell -Directory
		foreach ($mod in $modules) {
			Write-PSToolKitMessage -Action Moving -Object $mod.name -Message 'From WindowsPowerShell' -Object2 'To AllUsers'
			try {
				Move-Item -Path $mod.FullName -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ErrorAction Stop
			} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		}
	}
	if (Test-Path $PersonalPowerShell) {
		$modules = Get-ChildItem $PersonalPowerShell -Directory
		foreach ($mod in $modules) {
			Write-PSToolKitMessage -Action Moving -Object $mod.name -Message 'From PowerShell' -Object2 'To AllUsers'
			try {
				Move-Item -Path $mod.FullName -Destination 'C:\Program Files\PowerShell\Modules' -ErrorAction Stop
			} catch {Write-Error "Error: `n`tMessage:$($_.Exception.Message)"}
		}
	}
} #end Function
 
Export-ModuleMember -Function Move-ModulesToAllUser
#endregion
 
#region New-CitrixSiteConfigFile.ps1
######## Function 46 of 95 ##################
# Function:         New-CitrixSiteConfigFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/20 06:04:36
# Synopsis:         A config file with Citrix server details and URLs. To be used in scripts.
#############################################
 
<#
.SYNOPSIS
A config file with Citrix server details and URLs. To be used in scripts.

.DESCRIPTION
A config file with Citrix server details and URLs. To be used in scripts. Use the function Import-CitrixSiteConfigFile to create variables from the config.

.PARAMETER ConfigName
A Unique name for the site / farm.

.PARAMETER Path
Where the config file will be saved.

.EXAMPLE
New-CitrixSiteConfigFile -ConfigName TestFarm -Path C:\Tiles

#>
Function New-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile')]
	PARAM (
		[parameter(Mandatory)]
		[string]$ConfigName,
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$Path = 'C:\Temp'
	)

	$fullname = (Get-Item $path).FullName
	
	[System.Collections.ArrayList]$DataColectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Data Collector'
			if ($null -notlike $tmpobj) {
				[void]$DataColectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$CloudConnectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Cloud Connectors'
			if ($null -notlike $tmpobj) {
				[void]$CloudConnectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$storefont = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix StoreFont'
			if ($null -notlike $tmpobj) {
				[void]$storefont.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$Director = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Citrix Director'
			if ($null -notlike $tmpobj) {
				[void]$Director.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$VDA = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'VDA Test Boxes'
			if ($null -notlike $tmpobj) {
				[void]$VDA.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	[System.Collections.ArrayList]$Other = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		try {
			$tmpobj = $null
			$tmpobj = Read-Host 'Other Servers'
			if ($null -notlike $tmpobj) {
				[void]$Other.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
				$UserInput = Read-Host 'Add more? (y/n)'
			} else {$UserInput = 'n'}
		} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}
	}

	try {
		$rds = Read-Host 'RDS License Server'
		if ($rds) {$RDSLicenseServer = $((Get-FQDN -ComputerName ($rds) ).FQDN)}

		$StoreFrontURL = Read-Host 'StoreFront URL'
		$GateWayURL = Read-Host 'Citrix GateWay URL'
		$DirectorURL = Read-Host 'Citrix Director URL'
	} catch {Write-Warning "Error: `n`tMessage:$(_.Exception.Message)"}

	try {
		$site = Get-BrokerSite -AdminAddress $DataColectors[0] -ErrorAction Stop
		$DDCDetails = Get-BrokerController -AdminAddress $DataColectors[0] | Select-Object -First 1 -ErrorAction Stop
		$CTXLicenseServer = $site.LicenseServerName
		$siteName = $site.Name
		$funcionlevel = $site.DefaultMinimumFunctionalLevel
		$version = $DDCDetails.ControllerVersion
	} catch {
		Write-Warning 'Unable to connect to the Farm. Manually getting details'
		$CtxLic = Read-Host 'Citrix License Server'
		if ($CtxLic) {$CTXLicenseServer = $((Get-FQDN -ComputerName ($CtxLic) ).FQDN)}
		$siteName = Read-Host 'Site Name'
	}

	$RPath = Read-Host 'Default Reports Folder Path'
	try {
		$ReportPath = Get-Item $RPath -ErrorAction Stop
	} catch {
		Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
		Write-Warning 'Trying to create the folder'
		$ReportPath = New-Item $RPath -ItemType Directory -Force
	}

	#if ([string]::IsNullOrEmpty($siteName)) {$siteName}

	$CTXSiteDetails = [PSCustomObject]@{
		DateCollected = (Get-Date -Format yyyy-MM-ddTHH.mm)
		SiteName      = $siteName
		Funcionlevel  = $funcionlevel
		Version       = $version
		CTXServers    = [PSCustomObject]@{
			DataColector     = $DataColectors
			CloudConnector   = $CloudConnectors
			Storefont        = $storefont
			Director         = $Director
			RDSLicenseServer = $RDSLicenseServer
			CTXLicenseServer = $CTXLicenseServer
			VDA              = $VDA
			Other            = $Other
			StoreFrontURL    = $StoreFrontURL
			GateWayURL       = $GateWayURL
			DirectorURL      = $DirectorURL
			ReportPath       = $ReportPath.FullName
		}
	}

	$CTXSiteDetails

	if (Test-Path (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json")) {
		Write-Warning 'Config File Exists, renaming the old config file.'
		Rename-Item -Path (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json") -NewName "$($ConfigName)-CTXSiteConfig_$(Get-Date -Format yyyyMMdd_HHmm).json"
	}
	$CTXSiteDetails | ConvertTo-Json | Out-File (Join-Path -Path $fullname -ChildPath "$($ConfigName)-CTXSiteConfig.json") -Encoding utf8
} #end Function
 
Export-ModuleMember -Function New-CitrixSiteConfigFile
#endregion
 
#region New-ElevatedShortcut.ps1
######## Function 47 of 95 ##################
# Function:         New-ElevatedShortcut
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Creates a shortcut to a script or exe that runs as admin, without UNC
#############################################
 
<#
.SYNOPSIS
Creates a shortcut to a script or exe that runs as admin, without UNC

.DESCRIPTION
Creates a shortcut to a script or exe that runs as admin, without UNC

.PARAMETER ShortcutName
Name of the shortcut

.PARAMETER FilePath
Path to the executable or ps1 file

.PARAMETER OpenPath
Open explorer to the .lnk file.

.EXAMPLE
New-ElevatedShortcut -ShortcutName blah -FilePath cmd.exe

#>
Function New-ElevatedShortcut {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/New-ElevatedShortcut')]

	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[string]$ShortcutName,
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.ps1') -or ((Get-Item $_).Extension -eq '.exe') })]
		[string]$FilePath,
		[switch]$OpenPath = $false
	)

	$ScriptInfo = Get-Item $FilePath

	if ($ScriptInfo.Extension -eq '.ps1') {
		$taskActionSettings = @{
			Execute  = 'powershell.exe'
			Argument = "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$($ScriptInfo.FullName)"" -Verb RunAs"
		}
	}
	if ($ScriptInfo.Extension -eq '.exe') {
		$taskActionSettings = @{
			Execute  = 'powershell.exe'
			Argument = "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -command `"& {Start-Process -FilePath `'$($ScriptInfo.FullName)`'}`" -Verb RunAs"
		}
	}

	$taskaction = New-ScheduledTaskAction @taskActionSettings
	Register-ScheduledTask -TaskName "RunAs\$ShortcutName" -Action $taskAction
	$taskPrincipal = New-ScheduledTaskPrincipal -UserId $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -RunLevel Highest
	Set-ScheduledTask -TaskName "RunAs\$ShortcutName" -Principal $taskPrincipal

	## Create icon
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ScriptInfo.DirectoryName + '\' + $ShortcutName + '.lnk')
	$Shortcut.TargetPath = 'C:\Windows\System32\schtasks.exe'
	$Shortcut.Arguments = "/run /tn RunAs\$ShortcutName"
	if ($ScriptInfo.Extension -eq '.exe') {	$Shortcut.IconLocation = $ScriptInfo.FullName }
	else {
		$IconLocation = 'C:\windows\System32\SHELL32.dll'
		$IconArrayIndex = 27
		$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
	}
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()

	if ($OpenPath) {
		Start-Process -FilePath explorer.exe -ArgumentList $($ScriptInfo.DirectoryName)
	}
} #end Function
 
Export-ModuleMember -Function New-ElevatedShortcut
#endregion
 
#region New-GodModeFolder.ps1
######## Function 48 of 95 ##################
# Function:         New-GodModeFolder
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Creates a God Mode Folder
#############################################
 
<#
.SYNOPSIS
Creates a God Mode Folder

.DESCRIPTION
Creates a God Mode Folder

.EXAMPLE
New-GodModeFolder

#>
Function New-GodModeFolder {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-GodModeFolder')]
	PARAM()


	New-Item -Path ([Environment]::GetFolderPath('Desktop')) -Name 'God Mode .{ED7BA470-8E54-465E-825C-99712043E01C}' -ItemType directory -Force

} #end Function
 
Export-ModuleMember -Function New-GodModeFolder
#endregion
 
#region New-GoogleSearch.ps1
######## Function 49 of 95 ##################
# Function:         New-GoogleSearch
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/03 23:20:57
# Synopsis:         Start a new browser tab with search string.
#############################################
 
<#
.SYNOPSIS
Start a new browser tab with search string.

.DESCRIPTION
Start a new browser tab with search string.

.PARAMETER Query
What to search

.PARAMETER Clipboard
Use clipboard to search

.EXAMPLE
New-GoogleSearch blah

#>
Function New-GoogleSearch {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/New-GoogleSearch")]
        [Alias("google")]
                PARAM(
					[Parameter(ValueFromPipeline=$true)]
                    [string]$Query,
                    [switch]$Clipboard = $false
				)
$google = "https://www.google.com/search?q="

if ($Clipboard) {
    $clip = Get-Clipboard
    Start-Process "$google $clip"
}
else {Start-Process "$google $Query"}

} #end Function
New-Alias -Name "google" -Value New-GoogleSearch -Description "PSToolKit: Does google search" -Option AllScope -Scope global -Force
 
Export-ModuleMember -Function New-GoogleSearch
#endregion
 
#region New-PSGenericList.ps1
######## Function 50 of 95 ##################
# Function:         New-PSGenericList
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Jeff Hicks
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/30 22:56:13
# Synopsis:         Creates a .net list object
#############################################
 
<#
.SYNOPSIS
Creates a .net list object

.DESCRIPTION
Creates a .net list object


.PARAMETER Type
The type of objects in the list

.PARAMETER Values
Data to add.

.EXAMPLE
$list = New-GenericList -Type string -Values 'blah','two','one'

#>
Function New-PSGenericList {
	[cmdletbinding()]
	[alias('ngl')]
	[outputType('System.Collections.Generic.List[<type>]')]
	Param(
		[Parameter(
			Position = 0,
			ValueFromPipelineByPropertyname,
			HelpMessage = 'Enter the object type to be used for defining the list such as Int32 or String.'
		)]
		[ValidateNotNullOrEmpty()]
		[Type]$Type = 'String',
		[Parameter(
			ValueFromPipeline,
			HelpMessage = 'Specify the values or objects to add to the list.'
		)]
		[object[]]$Values
	)
	Begin {
		Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
		if ($PSBoundParameters.ContainsKey('Type')) {
			#create the list object if the type name is passed as a parameter value.
			Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Creating a generic list for $type objects"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}
	} #begin

	Process {
		#If the list is not defined in the Begin block define it here based on pipeline input.
		#The If statement should only run once, for the first pipelined object.
		if ((-Not $list.psbase) -AND ($psitem)) {
			$type = $psitem.gettype()
			if ($type.name -eq 'PSCustomObject') {
				Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Detected $type. Using PSObject as the type"
				$type = 'PSObject' -as [Type]
			}
			Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating a generic list for $type objects"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}

		#add each value to the list
		foreach ($value in $values) {
			if ($VerbosePreference -eq 'continue') {
				#display verbose output for each item added to the list using Write-Progress
				$paramHash = @{
					Activity         = $myinvocation.mycommand
					Status           = 'Adding items'
					CurrentOperation = "[$((Get-Date).TimeofDay) PROCESS] Adding $value to the list"
				}

				Write-Progress @paramHash

			}
			$list.Add($value)
		} #foreach value
	} #process

	End {
		if ($VerbosePreference -eq 'continue') {
			#reset the cursor position
			Write-Host "`r"
		}
		#create an empty generic string list if no type or values are specifed
		if (-Not $list) {
			Write-Verbose "[$((Get-Date).TimeofDay) END    ] Creating an empty $type generic list"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Added $($list.count) objects to the list"
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Writing object type $($list.psobject.typenames[0])"
		#need to return the list object not the values, and this syntax
		#appears to achieve this goal.
		, $list

		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
	} #end

} #close New-GenericList
 
Export-ModuleMember -Function New-PSGenericList
#endregion
 
#region New-PSModule.ps1
######## Function 51 of 95 ##################
# Function:         New-PSModule
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Creates a new PowerShell module.
#############################################
 
<#
.SYNOPSIS
Creates a new PowerShell module.

.DESCRIPTION
Creates a new PowerShell module.

.PARAMETER ModulePath
Path to where it will be saved.

.PARAMETER ModuleName
Name of module

.PARAMETER Author
Who wrote it

.PARAMETER Description
What it does

.PARAMETER Tag
Tags for reaches.

.EXAMPLE
New-PSModule -ModulePath C:\Temp\ -ModuleName blah -Description 'blah' -Tag ps

#>
function New-PSModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSModule')]
	PARAM(
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$ModulePath = $pwd,
		[Parameter(Mandatory = $true)]
		[string]$ModuleName,
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $true)]
		[string]$Description = (Read-Host Description),
		[Parameter(Mandatory = $true)]
		[string[]]$Tag = (Read-Host Tag)
	)

	$ModuleFullPath = Join-Path (Get-Item $ModulePath).FullName -ChildPath $ModuleName
	if ((Test-Path $ModuleFullPath) -eq $true) { Write-Warning 'Already exits'; break }

	if ((Test-Path -Path $ModuleFullPath) -eq $false) {
		New-Item -Path $ModuleFullPath -ItemType Directory
		New-Item -Path $ModuleFullPath\Private -ItemType Directory
		New-Item -Path $ModuleFullPath\Public -ItemType Directory
		New-Item -Path $ModuleFullPath\en-US -ItemType Directory
		New-Item -Path $ModuleFullPath\docs -ItemType Directory
		#Create the module and related files
		$ModuleStartup = @('
Set-StrictMode -Version Latest
# Get public and private function definition files.

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files.
foreach ($import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
		. $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

## Export all of the public functions making them available to the user
foreach ($file in $Public) {
    Export-ModuleMember -Function $file.BaseName
}
')

		$ModuleStartup | Out-File "$ModuleFullPath\$ModuleName.psm1" -Force
		New-Item "$ModuleFullPath\$ModuleName.Format.ps1xml" -ItemType File
		New-ModuleManifest -Path "$ModuleFullPath\$ModuleName.psd1" -RootModule "$ModuleName.psm1" -Guid (New-Guid) -Description $Description -Author $Author -ModuleVersion '0.1.0' -CompanyName 'HTPCZA Tech'-Tags $tag

	}
}

 
Export-ModuleMember -Function New-PSModule
#endregion
 
#region New-PSProfile.ps1
######## Function 52 of 95 ##################
# Function:         New-PSProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/17 12:50:45
# Synopsis:         Creates new profile files in the documents folder
#############################################
 
<#
.SYNOPSIS
Creates new profile files in the documents folder

.DESCRIPTION
Creates new profile files in the documents folder

.EXAMPLE
New-PSProfile

#>
Function New-PSProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSProfile')]
    PARAM(
    )

    [System.Collections.ArrayList]$folders = @()
    $ps7Folder = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'PowerShell')
    $ps5Folder = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell')

    if (-not(Test-Path $ps7Folder)) { [void]$folders.Add($(New-Item $ps7Folder -ItemType Directory)) }
    else { [void]$folders.Add($(Get-Item $ps7Folder)) }

    if (-not(Test-Path $ps5Folder)) { [void]$folders.Add($(New-Item $ps5Folder -ItemType Directory)) }
    else { [void]$folders.Add($(Get-Item $ps5Folder)) }

    $ise = 'Microsoft.PowerShellISE_profile.ps1'
    $ps = 'Microsoft.PowerShell_profile.ps1'
    $vscode = 'Microsoft.VSCode_profile.ps1'

    $ModModules = Get-Module PSToolKit
    if (-not($ModModules)) { $ModModules = Get-Module PSToolKit -ListAvailable }
    if (-not($ModModules)) { throw 'Module not found' }

    foreach ($folder in $folders) {
        $configfolder = [IO.Path]::Combine($folder.FullName, 'Config')
        $BCKFolder = [IO.Path]::Combine($folder.FullName, 'Config', "$(Get-Date -Format yyyy.MM.dd_HH.mm)")

        $Profilefiles = Get-ChildItem -File "$($folder.FullName)\*profile*.ps1"
        if ($Profilefiles) {
            if (-not(Test-Path $configfolder)) {New-Item $configfolder -ItemType directory -Force}
            $BCKDest = New-Item $BCKFolder -ItemType directory -Force
            $Profilefiles | Move-Item -Destination $BCKDest.FullName

            $BCKDest.FullName | Compress-Archive -DestinationPath (Join-Path -Path $configfolder -ChildPath 'NewPSProfile-BCK.zip') -Update
            $BCKDest.FullName | Remove-Item -Recurse -Force
        }

        $NewFile = @"

################################
#region common settings       ##
################################
#Force TLS 1.2 for all connections
if (`$PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

#Enable concise errorview for PS7 and up
if (`$psversiontable.psversion.major -ge 7) {
    `$ErrorView = 'ConciseView'
}
#endregion


################################
#region Start PSToolKit       ##
################################
`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $ModModules.ModuleBase).Parent).FullName "\*\$($ModModules.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
Import-Module `$PRModule.FullName -Force
Start-PSProfile

#endregion

################################
#region Add custom prompt     ##
################################
function prompt {
    `$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    `$principal = [Security.Principal.WindowsPrincipal] `$identity
    `$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    `$Seconds = (New-TimeSpan -Start (Get-History)[-1].StartExecutionTime -End (Get-History)[-1].EndExecutionTime).Seconds
    
    if (Test-Path variable:/PSDebugContext) {
        `$Part1 = '[DBG]'
    } elseif (`$principal.IsInRole(`$adminRole)) {
        `$Part1 = '[ADMIN]'
    } else {
        `$Part1 = ''
    }
    if (`$Part1) {
        Write-Host `$Part1 -NoNewline -ForegroundColor Red
    }
    Write-Host "(`$(`$Seconds)sec)[`$(`$env:USERNAME.ToLower())@`$(`$env:USERDNSDOMAIN.ToLower())] " -ForegroundColor Cyan -NoNewline
    if ((Get-Location).ProviderPath.Length -lt 50) {
        Write-Host "`$(Get-Location)" -NoNewline
    } else {
        Write-Host "`$((Get-Location).ProviderPath[0..2] | Join-String)....`$((Get-Location).ProviderPath[-50..-1] | Join-String)" -NoNewline
    }
    if (`$NestedPromptLevel -ge 1) { 
        Write-Host ' >>' -NoNewline 
    } else {
        Write-Host ' >' -NoNewline
    }
    return ' '
}
#endregion

#Region vscode addon
Import-CommandSuite
#endregion


"@


        $NewFile | Set-Content ([IO.Path]::Combine($folder.FullName, $ise)), ([IO.Path]::Combine($folder.FullName, $ps)), ([IO.Path]::Combine($folder.FullName, $vscode)) -Force
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ise)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $ps)) -Color Cyan, Gray, Green
        Write-Color '[Created]', 'Profile :', ([IO.Path]::Combine($folder.FullName, $vscode)) -Color Cyan, Gray, Green


    }

} #end Function
 
Export-ModuleMember -Function New-PSProfile
#endregion
 
#region New-PSScript.ps1
######## Function 53 of 95 ##################
# Function:         New-PSScript
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/31 01:01:21
# Synopsis:         Creates a new PowerShell script. With PowerShell Script Info
#############################################
 
<#
.SYNOPSIS
 Creates a new PowerShell script. With PowerShell Script Info

.DESCRIPTION
 Creates a new PowerShell script. With PowerShell Script Info

.PARAMETER Path
Where the script will be created.

.PARAMETER Verb
Approved PowerShell verb

.PARAMETER Noun
Second part of script name.

.PARAMETER Author
Who wrote it.

.PARAMETER Description
What it does.

.PARAMETER tags
Tags for searches.

.EXAMPLE
New-PSScript -Path .\PSToolKit\Private\ -Verb get -Noun blah -Description 'blah' -tags PS

#>
function New-PSScript {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSScript')]
	param (
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$Path = $pwd,
		[Parameter(Mandatory = $True)]
		[ValidateScript( { Get-Verb -Verb $_ })]
		[ValidateNotNullOrEmpty()]
		[string]$Verb,
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[string]$Noun,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $true)]
		[string]$Description,
		[Parameter(Mandatory = $true)]
		[string[]]$tags)

	$checkpath = Get-Item $Path
	$ValidVerb = Get-Verb -Verb $Verb
	if ([bool]$ValidVerb -ne $true) { Write-Warning 'Script name is not valid, Needs to be in verb-noun format'; break }

	$properverb = (Get-Culture).TextInfo.ToTitleCase($Verb)
	$propernoun = $Noun.substring(0, 1).toupper() + $Noun.substring(1)

	try {
		$module = Get-Item (Join-Path $checkpath.Parent -ChildPath "$((Get-Item $checkpath.Parent).BaseName).psm1") -ErrorAction Stop
		$modulename = $module.BaseName
	} catch { Write-Warning 'Could not detect module'; $modulename = Read-Host 'Module Name: ' }


	$functionText = @"
<#
.SYNOPSIS
$Description

.DESCRIPTION
$Description

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$properverb-$propernoun -Export HTML -ReportPath C:\temp

#>
Function $properverb-$propernoun {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/$modulename/$properverb-$propernoun")]
	    [OutputType([System.Object[]])]
                PARAM(

					[Parameter(Position = 0,Mandatory = `$true,HelpMessage = "Specify the name of a remote computer. The default is the local host.")]
        			[alias("CN", "host")]
        			[ValidateNotNullorEmpty()]
					[Parameter(ParameterSetName = 'Set1')]
					[ValidateScript( { (Test-Path `$_) -and ((Get-Item `$_).Extension -eq ".csv") })]
					[System.IO.FileInfo]`$InputObject,

					[Parameter(HelpMessage = "Specify the name of a user.")]
					[ValidateNotNullOrEmpty()]
					[string]`$Username,

					[ValidateSet('Excel', 'HTML', 'Host')]
					[string]`$Export = 'Host',

                	[ValidateScript( { if (Test-Path `$_) { `$true }
                                else { New-Item -Path `$_ -ItemType Directory -Force | Out-Null; `$true }
                    })]
                	[System.IO.DirectoryInfo]`$ReportPath = 'C:\Temp',

					[ValidateScript({`$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if (`$IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {`$True}
            						else {Throw "Must be running an elevated prompt to use this function"}})]
        			[switch]`$ClearARPCache,
					
        			[ValidateScript({if (Test-Connection -ComputerName `$_ -Count 2 -Quiet) {`$true}
                            		else {throw "Unable to connect to `$(`$_)"} })]
        			[string[]]`$ComputerName
					)



	if (`$Export -eq 'Excel') { 
		`$ExcelOptions = @{
            Path             = `$(Join-Path -Path `$ReportPath -ChildPath "\$propernoun-`$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = `$True
            AutoFilter       = `$True
            TitleBold        = `$True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = `$True
            FreezePane       = '3'
        }
         `$data | Export-Excel -Title $propernoun -WorksheetName $propernoun @ExcelOptions}

	if (`$Export -eq 'HTML') { `$data | Out-GridHtml -DisablePaging -Title "$propernoun" -HideFooter -SearchHighlight -FixedHeader -FilePath `$(Join-Path -Path `$ReportPath -ChildPath "\$propernoun-`$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if (`$Export -eq 'Host') { `$data }
} #end Function
"@
	$ScriptFullPath = $checkpath.fullname + "\$properverb-$propernoun.ps1"

	$manifestProperties = @{
		Path            = $ScriptFullPath
		Version         = '0.1.0'
		Author          = $Author
		Description     = $Description
		CompanyName     = 'HTPCZA Tech'
		Tags            = @($Tags)
		ReleaseNotes    = 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initial Script Creating'
		GUID            = (New-Guid)
		RequiredModules = 'ImportExcel', 'PSWriteHTML', 'PSWriteColor'
	}

	New-ScriptFileInfo @manifestProperties -Force
	$content = Get-Content $ScriptFullPath | Where-Object { $_ -notlike 'Param*' }
	Set-Content -Value ($content + $functionText) -Path $ScriptFullPath -Force

}
 
Export-ModuleMember -Function New-PSScript
#endregion
 
#region New-SuggestedInfraName.ps1
######## Function 54 of 95 ##################
# Function:         New-SuggestedInfraName
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Generates a list of usernames and server names, that can be used as test / demo data.
#############################################
 
<#
.SYNOPSIS
Generates a list of usernames and server names, that can be used as test / demo data.

.DESCRIPTION
Generates a list of usernames and server names, that can be used as test / demo data.

.PARAMETER OS
The Type of server names to generate.

.PARAMETER Export
Export the results.

.PARAMETER ReportPath
Where to save the data.

.EXAMPLE
New-SuggestedInfraNames -OS VDI -Export Excel -ReportPath C:\temp

#>
Function New-SuggestedInfraName {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-SuggestedInfraNames')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateSet('LNX', 'SVR', 'VDI', 'WST', 'DSK')]
        [string]$OS = 'SVR',
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Excel', 'Json')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )

    [System.Collections.ArrayList]$ServerObject = @()
    [void]$ServerObject.Add([PSCustomObject]@{build = 'verb'; servers = @(((Invoke-Generate "$OS-[verb]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'adjective'; servers = @(((invoke-Generate "$OS-[adjective]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'noun'; servers = @(((invoke-Generate "$OS-[noun]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'random'; servers = @(((Invoke-Generate "$OS-???##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'color'; servers = @(((Invoke-Generate "$OS-[color]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'consonant'; servers = @(((Invoke-Generate "$OS-[consonant][consonant][consonant]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'country'; servers = @(((Invoke-Generate "$OS-[country]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'phoneticvowel'; servers = @(((Invoke-Generate "$OS-[phoneticvowel]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })
    [void]$ServerObject.Add([PSCustomObject]@{build = 'syllable'; servers = @(((Invoke-Generate "$OS-[syllable]##" -Numbers 0123 -Count 3).toupper()) | Out-String).Trim()  })

    [System.Collections.ArrayList]$UserObject = @()
    $rawUsers = Invoke-Generate -Template '[person both first]|[person both last]|[job]|(08#) ### ####|[country]' -Count 20
    foreach ($user in $rawUsers) {
        $breakdown = $user.Split('|')
        [void]$UserObject.Add([PSCustomObject]@{
                FirstName   = $breakdown[0]
                Lastname    = $breakdown[1]
                Fullname    = "$($breakdown[1]) $($breakdown[0])"
                Userid      = "$($breakdown[1])$($breakdown[0][0])"
                Department  = $breakdown[2]
                email       = "$($breakdown[0]).$($breakdown[1])@$($env:USERDNSDOMAIN)"
                PhoneNumber = $($breakdown[3])
                Country     = $breakdown[4]
            })
    }
    $data = @()
    $data = [PSCustomObject]@{
        ServerDetails = $ServerObject
        UserDetails   = $UserObject
    }

    if ($Export -eq 'Excel') {
        $data.ServerDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ServerDetails -AutoSize -AutoFilter
        $data.UserDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName UserDetails -AutoSize -AutoFilter -Show
    }
    if ($Export -eq 'Json') { $data | ConvertTo-Json -Depth 3 | Set-Content -Path $(Join-Path -Path $ReportPath -ChildPath "\SuggestedInfraNames-$(Get-Date -Format yyyy.MM.dd-HH.mm).json") }
    if ($Export -eq 'Host') { $data }


} #end Function
 
Export-ModuleMember -Function New-SuggestedInfraName
#endregion
 
#region Publish-ModuleToLocalRepo.ps1
######## Function 55 of 95 ##################
# Function:         Publish-ModuleToLocalRepo
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/11 22:04:18
# Synopsis:         Checks for required modules and upload all to your local repo.
#############################################
 
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

 
Export-ModuleMember -Function Publish-ModuleToLocalRepo
#endregion
 
#region Remove-CIMUserProfile.ps1
######## Function 56 of 95 ##################
# Function:         Remove-CIMUserProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Uses CimInstance to remove a user profile
#############################################
 
<#
.SYNOPSIS
Uses CimInstance to remove a user profile

.DESCRIPTION
Uses CimInstance to remove a user profile

.PARAMETER TargetServer
Affected Server

.PARAMETER UserName
Affected Username

.EXAMPLE
Remove-CIMUserProfiles -UserName ps

#>
Function Remove-CIMUserProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Remove-CIMUserProfiles')]
    PARAM(
        [string]$TargetServer = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName
    )

    $UserProfile = Get-CimInstance Win32_UserProfile -ComputerName $TargetServer | Where-Object { $_.LocalPath -like "*$UserName*" }
    Remove-CimInstance -InputObject $UserProfile
    Write-Output "Profile $($UserProfile.LocalPath) has been removed from $($TargetServer)"

} #end Function
 
Export-ModuleMember -Function Remove-CIMUserProfile
#endregion
 
#region Remove-FaultyProfileList.ps1
######## Function 57 of 95 ##################
# Function:         Remove-FaultyProfileList
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Fixes Profilelist in the registry. To fix user logon with temp profile.
#############################################
 
<#
.SYNOPSIS
Fixes Profilelist in the registry. To fix user logon with temp profile.


.DESCRIPTION
Connects to a server, Compare Profilelist in registry to what is on disk, and deletes registry if needed. The next time a user logs on, new profile will be created, and not a temp profile.

.PARAMETER TargetServer
ServerName to connect to.

.EXAMPLE
Remove-FaultyProfileList -TargetServer AD01

#>
function Remove-FaultyProfileList {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Remove-FaultyProfileList')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetServer)

    if ((Test-Connection -ComputerName $TargetServer -Count 2 -Quiet) -eq $true) {
        try {
            Invoke-Command -ComputerName $TargetServer -ScriptBlock {
                ## TODO  ### <-- This needs to be tested to return the correct list
                $UserProfileReg = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | Where-Object { $_.GetValue('Guid') -notlike $null }

                foreach ($UserProfile in $UserProfileReg) {
                    if ((Test-Path -Path ($UserProfile.GetValue('ProfileImagePath'))) -eq $false) {
                        Write-Host "$($UserProfile.GetValue('ProfileImagePath').split('\')[2]) -- Does not Exist" -ForegroundColor Red
                        $AdminAnswer = Read-Host 'Delete from Registry (Y/N)'
                        if ($AdminAnswer.ToUpper() -eq 'Y') {
                            $UserProfileGuid = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid' | Where-Object { $_.pschildname -like $UserProfile.GetValue('Guid') }
                            Set-Location 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList'
                            Remove-Item $UserProfile.PSChildName
                            Set-Location 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid'
                            Remove-Item $UserProfileGuid.PSChildName
                            Set-Location C:
                            Write-Host "$($UserProfile.GetValue('ProfileImagePath').split('\')[2]) -- Deleted" -ForegroundColor DarkRed
                        }
                    }
                    else {
                        Write-Host "$($UserProfile.GetValue('ProfileImagePath').split('\')[2]) -- Exists" -ForegroundColor Green
                    }
                }
            }
            Write-Host "User Profile: $($UserName) removed from server $($TargetServer)" -ForegroundColor DarkCyan

        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            # $FailedItem = $_.Exception.ItemName
            Write-Host $ErrorMessage -ForegroundColor Red
            Break
        }
    }
    else {
        Write-Host 'Server is not reachable' -ForegroundColor Red
    }
}

 
Export-ModuleMember -Function Remove-FaultyProfileList
#endregion
 
#region Remove-HiddenDevice.ps1
######## Function 58 of 95 ##################
# Function:         Remove-HiddenDevice
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Removes ghost devices from your system
#############################################
 
<#
.SYNOPSIS
   Removes ghost devices from your system

.DESCRIPTION
   Removes ghost devices from your system


.PARAMETER filterByFriendlyName
This parameter will exclude devices that match the partial name provided. This parameter needs to be specified in an array format for all the friendly names you want to be excluded from removal.
"Intel" will match "Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz". "Loop" will match "Microsoft Loopback Adapter".

.PARAMETER filterByClass
This parameter will exclude devices that match the class name provided. This parameter needs to be specified in an array format for all the class names you want to be excluded from removal.
This is an exact string match so "Disk" will not match "DiskDrive".

.PARAMETER listDevicesOnly
listDevicesOnly will output a table of all devices found in this system.

.PARAMETER listGhostDevicesOnly
listGhostDevicesOnly will output a table of all 'ghost' devices found in this system.

.EXAMPLE
Lists all devices
. Remove-HiddenDevices -listDevicesOnly

.EXAMPLE
Save the list of devices as an object
$Devices = . Remove-HiddenDevices -listDevicesOnly

.EXAMPLE
Lists all 'ghost' devices
. Remove-HiddenDevices -listGhostDevicesOnly

.EXAMPLE
Save the list of 'ghost' devices as an object
$ghostDevices = . Remove-HiddenDevices -listGhostDevicesOnly

.EXAMPLE
Remove all ghost devices EXCEPT any devices that have "Intel" or "Citrix" in their friendly name
. Remove-HiddenDevices -filterByFriendlyName @("Intel","Citrix")

.EXAMPLE
Remove all ghost devices EXCEPT any devices that are apart of the classes "LegacyDriver" or "Processor"
. Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor")

.EXAMPLE
Remove all ghost devices EXCEPT for devices with a friendly name of "Intel" or "Citrix" or with a class of "LegacyDriver" or "Processor"
. Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor") -filterByFriendlyName @("Intel","Citrix")

.NOTES
Permission level has not been tested.  It is assumed you will need to have sufficient rights to uninstall devices from device manager for this script to run properly.
#>
function Remove-HiddenDevice {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Remove-HiddenDevices')]
	Param(
  [array]$FilterByClass,
  [array]$FilterByFriendlyName,
  [switch]$listDevicesOnly,
  [switch]$listGhostDevicesOnly
	)

	#parameter futzing
	$removeDevices = $true
	if ($FilterByClass -ne $null) {
		Write-Host "FilterByClass: $FilterByClass"
	}

	if ($FilterByFriendlyName -ne $null) {
		Write-Host "FilterByFriendlyName: $FilterByFriendlyName"
	}

	if ($listDevicesOnly -eq $true) {
		Write-Host "List devices without removal: $listDevicesOnly"
		$removeDevices = $false
	}

	if ($listGhostDevicesOnly -eq $true) {
		Write-Host "List ghost devices without removal: $listGhostDevicesOnly"
		$removeDevices = $false
	}



	$setupapi = @'
using System;
using System.Diagnostics;
using System.Text;
using System.Runtime.InteropServices;
namespace Win32
{
    public static class SetupApi
    {
         // 1st form using a ClassGUID only, with Enumerator = IntPtr.Zero
        [DllImport("setupapi.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr SetupDiGetClassDevs(
           ref Guid ClassGuid,
           IntPtr Enumerator,
           IntPtr hwndParent,
           int Flags
        );

        // 2nd form uses an Enumerator only, with ClassGUID = IntPtr.Zero
        [DllImport("setupapi.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr SetupDiGetClassDevs(
           IntPtr ClassGuid,
           string Enumerator,
           IntPtr hwndParent,
           int Flags
        );

        [DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetupDiEnumDeviceInfo(
            IntPtr DeviceInfoSet,
            uint MemberIndex,
            ref SP_DEVINFO_DATA DeviceInfoData
        );

        [DllImport("setupapi.dll", SetLastError = true)]
        public static extern bool SetupDiDestroyDeviceInfoList(
            IntPtr DeviceInfoSet
        );
        [DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetupDiGetDeviceRegistryProperty(
            IntPtr deviceInfoSet,
            ref SP_DEVINFO_DATA deviceInfoData,
            uint property,
            out UInt32 propertyRegDataType,
            byte[] propertyBuffer,
            uint propertyBufferSize,
            out UInt32 requiredSize
        );
        [DllImport("setupapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern bool SetupDiGetDeviceInstanceId(
            IntPtr DeviceInfoSet,
            ref SP_DEVINFO_DATA DeviceInfoData,
            StringBuilder DeviceInstanceId,
            int DeviceInstanceIdSize,
            out int RequiredSize
        );


        [DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetupDiRemoveDevice(IntPtr DeviceInfoSet,ref SP_DEVINFO_DATA DeviceInfoData);
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct SP_DEVINFO_DATA
    {
       public uint cbSize;
       public Guid classGuid;
       public uint devInst;
       public IntPtr reserved;
    }
    [Flags]
    public enum DiGetClassFlags : uint
    {
        DIGCF_DEFAULT       = 0x00000001,  // only valid with DIGCF_DEVICEINTERFACE
        DIGCF_PRESENT       = 0x00000002,
        DIGCF_ALLCLASSES    = 0x00000004,
        DIGCF_PROFILE       = 0x00000008,
        DIGCF_DEVICEINTERFACE   = 0x00000010,
    }
    public enum SetupDiGetDeviceRegistryPropertyEnum : uint
    {
         SPDRP_DEVICEDESC          = 0x00000000, // DeviceDesc (R/W)
         SPDRP_HARDWAREID          = 0x00000001, // HardwareID (R/W)
         SPDRP_COMPATIBLEIDS           = 0x00000002, // CompatibleIDs (R/W)
         SPDRP_UNUSED0             = 0x00000003, // unused
         SPDRP_SERVICE             = 0x00000004, // Service (R/W)
         SPDRP_UNUSED1             = 0x00000005, // unused
         SPDRP_UNUSED2             = 0x00000006, // unused
         SPDRP_CLASS               = 0x00000007, // Class (R--tied to ClassGUID)
         SPDRP_CLASSGUID           = 0x00000008, // ClassGUID (R/W)
         SPDRP_DRIVER              = 0x00000009, // Driver (R/W)
         SPDRP_CONFIGFLAGS         = 0x0000000A, // ConfigFlags (R/W)
         SPDRP_MFG             = 0x0000000B, // Mfg (R/W)
         SPDRP_FRIENDLYNAME        = 0x0000000C, // FriendlyName (R/W)
         SPDRP_LOCATION_INFORMATION    = 0x0000000D, // LocationInformation (R/W)
         SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = 0x0000000E, // PhysicalDeviceObjectName (R)
         SPDRP_CAPABILITIES        = 0x0000000F, // Capabilities (R)
         SPDRP_UI_NUMBER           = 0x00000010, // UiNumber (R)
         SPDRP_UPPERFILTERS        = 0x00000011, // UpperFilters (R/W)
         SPDRP_LOWERFILTERS        = 0x00000012, // LowerFilters (R/W)
         SPDRP_BUSTYPEGUID         = 0x00000013, // BusTypeGUID (R)
         SPDRP_LEGACYBUSTYPE           = 0x00000014, // LegacyBusType (R)
         SPDRP_BUSNUMBER           = 0x00000015, // BusNumber (R)
         SPDRP_ENUMERATOR_NAME         = 0x00000016, // Enumerator Name (R)
         SPDRP_SECURITY            = 0x00000017, // Security (R/W, binary form)
         SPDRP_SECURITY_SDS        = 0x00000018, // Security (W, SDS form)
         SPDRP_DEVTYPE             = 0x00000019, // Device Type (R/W)
         SPDRP_EXCLUSIVE           = 0x0000001A, // Device is exclusive-access (R/W)
         SPDRP_CHARACTERISTICS         = 0x0000001B, // Device Characteristics (R/W)
         SPDRP_ADDRESS             = 0x0000001C, // Device Address (R)
         SPDRP_UI_NUMBER_DESC_FORMAT       = 0X0000001D, // UiNumberDescFormat (R/W)
         SPDRP_DEVICE_POWER_DATA       = 0x0000001E, // Device Power Data (R)
         SPDRP_REMOVAL_POLICY          = 0x0000001F, // Removal Policy (R)
         SPDRP_REMOVAL_POLICY_HW_DEFAULT   = 0x00000020, // Hardware Removal Policy (R)
         SPDRP_REMOVAL_POLICY_OVERRIDE     = 0x00000021, // Removal Policy Override (RW)
         SPDRP_INSTALL_STATE           = 0x00000022, // Device Install State (R)
         SPDRP_LOCATION_PATHS          = 0x00000023, // Device Location Paths (R)
         SPDRP_BASE_CONTAINERID        = 0x00000024  // Base ContainerID (R)
    }
}
'@
	Add-Type -TypeDefinition $setupapi

	#Array for all removed devices report
	$removeArray = @()
	#Array for all devices report
	$array = @()

	$setupClass = [Guid]::Empty
	#Get all devices
	$devs = [Win32.SetupApi]::SetupDiGetClassDevs([ref]$setupClass, [IntPtr]::Zero, [IntPtr]::Zero, [Win32.DiGetClassFlags]::DIGCF_ALLCLASSES)

	#Initialise Struct to hold device info Data
	$devInfo = New-Object Win32.SP_DEVINFO_DATA
	$devInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devInfo)

	#Device Counter
	$devCount = 0
	#Enumerate Devices
	while ([Win32.SetupApi]::SetupDiEnumDeviceInfo($devs, $devCount, [ref]$devInfo)) {

		#Will contain an enum depending on the type of the registry Property, not used but required for call
		$propType = 0
		#Buffer is initially null and buffer size 0 so that we can get the required Buffer size first
		[byte[]]$propBuffer = $null
		$propBufferSize = 0
		#Get Buffer size
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_FRIENDLYNAME, [ref]$propType, $propBuffer, 0, [ref]$propBufferSize) | Out-Null
		#Initialize Buffer with right size
		[byte[]]$propBuffer = New-Object byte[] $propBufferSize

		#Get HardwareID
		$propTypeHWID = 0
		[byte[]]$propBufferHWID = $null
		$propBufferSizeHWID = 0
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_HARDWAREID, [ref]$propTypeHWID, $propBufferHWID, 0, [ref]$propBufferSizeHWID) | Out-Null
		[byte[]]$propBufferHWID = New-Object byte[] $propBufferSizeHWID

		#Get DeviceDesc (this name will be used if no friendly name is found)
		$propTypeDD = 0
		[byte[]]$propBufferDD = $null
		$propBufferSizeDD = 0
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_DEVICEDESC, [ref]$propTypeDD, $propBufferDD, 0, [ref]$propBufferSizeDD) | Out-Null
		[byte[]]$propBufferDD = New-Object byte[] $propBufferSizeDD

		#Get Install State
		$propTypeIS = 0
		[byte[]]$propBufferIS = $null
		$propBufferSizeIS = 0
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_INSTALL_STATE, [ref]$propTypeIS, $propBufferIS, 0, [ref]$propBufferSizeIS) | Out-Null
		[byte[]]$propBufferIS = New-Object byte[] $propBufferSizeIS

		#Get Class
		$propTypeCLSS = 0
		[byte[]]$propBufferCLSS = $null
		$propBufferSizeCLSS = 0
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_CLASS, [ref]$propTypeCLSS, $propBufferCLSS, 0, [ref]$propBufferSizeCLSS) | Out-Null
		[byte[]]$propBufferCLSS = New-Object byte[] $propBufferSizeCLSS
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_CLASS, [ref]$propTypeCLSS, $propBufferCLSS, $propBufferSizeCLSS, [ref]$propBufferSizeCLSS) | Out-Null
		$Class = [System.Text.Encoding]::Unicode.GetString($propBufferCLSS)

		#Read FriendlyName property into Buffer
		if (![Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_FRIENDLYNAME, [ref]$propType, $propBuffer, $propBufferSize, [ref]$propBufferSize)) {
			[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_DEVICEDESC, [ref]$propTypeDD, $propBufferDD, $propBufferSizeDD, [ref]$propBufferSizeDD) | Out-Null
			$FriendlyName = [System.Text.Encoding]::Unicode.GetString($propBufferDD)
			#The friendly Name ends with a weird character
			if ($FriendlyName.Length -ge 1) {
				$FriendlyName = $FriendlyName.Substring(0, $FriendlyName.Length - 1)
			}
		}
		else {
			#Get Unicode String from Buffer
			$FriendlyName = [System.Text.Encoding]::Unicode.GetString($propBuffer)
			#The friendly Name ends with a weird character
			if ($FriendlyName.Length -ge 1) {
				$FriendlyName = $FriendlyName.Substring(0, $FriendlyName.Length - 1)
			}
		}

		#InstallState returns true or false as an output, not text
		$InstallState = [Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_INSTALL_STATE, [ref]$propTypeIS, $propBufferIS, $propBufferSizeIS, [ref]$propBufferSizeIS)

		# Read HWID property into Buffer
		if (![Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_HARDWAREID, [ref]$propTypeHWID, $propBufferHWID, $propBufferSizeHWID, [ref]$propBufferSizeHWID)) {
			#Ignore if Error
			$HWID = ''
		}
		else {
			#Get Unicode String from Buffer
			$HWID = [System.Text.Encoding]::Unicode.GetString($propBufferHWID)
			#trim out excess names and take first object
			$HWID = $HWID.split([char]0x0000)[0].ToUpper()
		}

		#all detected devices list
		$obj = New-Object System.Object
		$obj | Add-Member -type NoteProperty -Name FriendlyName -Value $FriendlyName
		$obj | Add-Member -type NoteProperty -Name HWID -Value $HWID
		$obj | Add-Member -type NoteProperty -Name InstallState -Value $InstallState
		$obj | Add-Member -type NoteProperty -Name Class -Value $Class
		if ($array.count -le 0) {
			#for some reason the script will blow by the first few entries without displaying the output
			#this brief pause seems to let the objects get created/displayed so that they are in order.
			Start-Sleep 1
		}
		$array += @($obj)

		<#
        We need to execute the filtering at this point because we are in the current device context
        where we can execute an action (eg, removal).
        InstallState : False == ghosted device
        #>
		$matchFilter = $false
		if ($removeDevices -eq $true) {
			#we want to remove devices so lets check the filters...
			if ($FilterByClass -ne $null) {
				foreach ($ClassFilter in $FilterByClass) {
					if ($ClassFilter -eq $Class) {
						Write-Verbose "Class filter match $ClassFilter, skipping"
						$matchFilter = $true
					}
				}
			}
			if ($FilterByFriendlyName -ne $null) {
				foreach ($FriendlyNameFilter in $FilterByFriendlyName) {
					if ($FriendlyName -like '*' + $FriendlyNameFilter + '*') {
						Write-Verbose "FriendlyName filter match $FriendlyName, skipping"
						$matchFilter = $true
					}
				}
			}
			if ($InstallState -eq $False) {
				if ($matchFilter -eq $false) {
					Write-Host "Attempting to removing device $FriendlyName" -ForegroundColor Yellow
					$removeObj = New-Object System.Object
					$removeObj | Add-Member -type NoteProperty -Name FriendlyName -Value $FriendlyName
					$removeObj | Add-Member -type NoteProperty -Name HWID -Value $HWID
					$removeObj | Add-Member -type NoteProperty -Name InstallState -Value $InstallState
					$removeObj | Add-Member -type NoteProperty -Name Class -Value $Class
					$removeArray += @($removeObj)
					if ([Win32.SetupApi]::SetupDiRemoveDevice($devs, [ref]$devInfo)) {
						Write-Host "Removed device $FriendlyName" -ForegroundColor Green
					}
					else {
						Write-Host "Failed to remove device $FriendlyName" -ForegroundColor Red
					}
				}
				else {
					Write-Host "Filter matched. Skipping $FriendlyName" -ForegroundColor Yellow
				}
			}
		}
		$devcount++
	}

	#output objects so you can take the output from the script
	if ($listDevicesOnly) {
		$allDevices = $array | Sort-Object -Property FriendlyName | Format-Table
		$allDevices
		Write-Host "Total devices found       : $($array.count)"
		$ghostDevices = ($array | Where-Object { $_.InstallState -eq $false } | Sort-Object -Property FriendlyName)
		Write-Host "Total ghost devices found : $($ghostDevices.count)"
		return $allDevices | Out-Null
	}

	if ($listGhostDevicesOnly) {
		$ghostDevices = ($array | Where-Object { $_.InstallState -eq $false } | Sort-Object -Property FriendlyName)
		$ghostDevices | Format-Table
		Write-Host "Total ghost devices found : $($ghostDevices.count)"
		return $ghostDevices | Out-Null
	}

	if ($removeDevices -eq $true) {
		Write-Host 'Removed devices:'
		$removeArray | Sort-Object -Property FriendlyName | Format-Table
		Write-Host "Total removed devices     : $($removeArray.count)"
		return $removeArray | Out-Null
	}
}
 
Export-ModuleMember -Function Remove-HiddenDevice
#endregion
 
#region Remove-UserProfile.ps1
######## Function 59 of 95 ##################
# Function:         Remove-UserProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry
#############################################
 
<#
.SYNOPSIS
Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry

.DESCRIPTION
Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry

.PARAMETER TargetServer
Server to connect to.

.PARAMETER UserName
Affected Username

.EXAMPLE
Remove-UserProfile -TargetServer AD01 -UserName ps

#>
Function Remove-UserProfile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Remove-UserProfile')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetServer,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName
    )
    ## TODO Needs to be tested and confirm working.
    if ((Test-Connection -ComputerName $TargetServer -Count 2 -Quiet) -eq $true) {
        try {
            Invoke-Command -ComputerName $TargetServer -ScriptBlock {
                $UserProfile = Get-ChildItem C:\Users | Where-Object { $_.name -like $using:UserName }
                $UserProfileReg = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | Where-Object { $_.GetValue('ProfileImagePath') -like $UserProfile.FullName }
                $UserProfileGuid = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid' | Where-Object { $_.pschildname -like $UserProfileReg.GetValue('Guid') }
                $newuser = ('_OLD_' + $using:UserName)
                $newfolder = 'C:\users\' + $newuser
                if ((Test-Path -Path $newfolder) -eq $true) { $newuser = ('_OLD_' + (Get-Random -Maximum 20) + '_' + $($using:UserName)) }
                Rename-Item -Path $UserProfile.FullName -NewName $newuser
                if ($UserProfileReg -eq $true) {
                    Set-Location 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList'
                    Remove-Item $UserProfileReg.PSChildName
                }
                if ($UserProfileReg -eq $true) {
                    Set-Location 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid'
                    Remove-Item $UserProfileGuid.PSChildName
                }
                Set-Location C:
            } -ArgumentList $UserName
            write-out User Profile: $UserName removed from server $TargetServer

        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
            Break
        }
    }
    else {
        Write-Host 'Server is not reachable' -ForegroundColor Red
    }

} #end Function

 
Export-ModuleMember -Function Remove-UserProfile
#endregion
 
#region Reset-PSGallery.ps1
######## Function 60 of 95 ##################
# Function:         Reset-PSGallery
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/09 18:24:11
# Synopsis:         Reset gallery to default settings
#############################################
 
<#
.SYNOPSIS
Reset gallery to default settings

.DESCRIPTION
Reset gallery to default settings

.PARAMETER Force
Force the reinstall

.PARAMETER Repository
Will Install PowerShellGet from another repository.

.EXAMPLE
Reset-PSGallery

#>
Function Reset-PSGallery {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Reset-PSGallery')]
	PARAM(
		[ValidateScript({$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
				else {Throw 'Must be running an elevated prompt'}})]
        [string]$Repository = "PSGallery",
		[switch]$Force = $false
	)

    $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$scope = "AllUsers"}
    else {$scope = "CurrentUser"}

    $wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        

	if (((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') -or ($Force)) {
		try {
	
			Install-PackageProvider Nuget -Force -ErrorAction SilentlyContinue | Out-Null
			Register-PSRepository -Default -ErrorAction SilentlyContinue | Out-Null
			Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue | Out-Null
			Write-Color '[Installing]', 'PackageProvider: ', 'Complete' -Color Yellow, Cyan, Green

			Write-Color '[Checking]', 'PowerShell PackageManagement' -Color Yellow, Cyan
			Start-Job -ScriptBlock {
				$PowerShellGet = Get-Module 'PowerShellGet' -ListAvailable | 
					Sort-Object Version -Descending | 
						Select-Object -First 1

						if ($PowerShellGet.Version -lt [version]'2.2.5') {
							Write-Color "`t[Updating]", 'PowerShell PackageManagement' -Color Yellow, Cyan

							$installOptions = @{
								Repository = $Using:Repository
								Force      = $true
								Scope      = $using:scope
							}							
							try {
								Install-Module -Name PackageManagement @installOptions
								Write-Color "`t[Installing]", 'PackageManagement: ', 'Complete' -Color Yellow, Cyan, Green
							} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
							try {
								Install-Module -Name PowerShellGet @installOptions
								Write-Color "`t[Installing]", 'PowerShellGet: ', 'Complete' -Color Yellow, Cyan, Green
							} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
						} else {
							Write-Color "`t[Update]", 'PowerShell PackageManagement ', 'Not Needed' -Color Green, Cyan, DarkRed
						}
					} | Wait-Job | Receive-Job
					Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
				} catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
			} else {Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, DarkRed}

		} #end Function
 
Export-ModuleMember -Function Reset-PSGallery
#endregion
 
#region Resolve-SID.ps1
######## Function 61 of 95 ##################
# Function:         Resolve-SID
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Jeff Hicks
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/30 21:50:40
# Synopsis:         Resolves the Sid
#############################################
 
<#
.SYNOPSIS
Resolves the Sid

.DESCRIPTION
Resolves the Sid

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Resolve-SID -Export HTML -ReportPath C:\temp

#>
Function Resolve-SID {
	[cmdletbinding()]
	[OutputType('ResolvedSID', 'String')]
	Param(
		[Parameter(
			Position = 0,
			Mandatory,
			ValueFromPipeline,
			ValueFromPipelineByPropertyName,
			HelpMessage = 'Enter a SID string.'
		)]
		[ValidateScript({
				If ($_ -match 'S-1-[1235]-\d{1,2}(-\d+)*') {
					$True
				} else {
					Throw 'The parameter value does not match the pattern for a valid SID.'
					$False
				}
			})]
		[string]$SID,
		[Parameter(HelpMessage = 'Display the resolved account name as a string.')]
		[switch]$ToString
	)
	Begin {
		Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
	} #begin

	Process {
		Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Converting $SID "
		Try {
			if ($SID -eq 'S-1-5-32') {
				#apparently you can't resolve the builtin account
				$resolved = "$env:COMPUTERNAME\BUILTIN"
			} else {
				$resolved = [System.Security.Principal.SecurityIdentifier]::new($sid).Translate([system.security.principal.NTAccount]).value
			}

			if ($ToString) {
				$resolved
			} else {
				if ($resolved -match '\\') {
					$domain = $resolved.Split('\')[0]
					$username = $resolved.Split('\')[1]
				} else {
					$domain = $Null
					$username = $resolved
				}
				[pscustomObject]@{
					PSTypename = 'ResolvedSID'
					NTAccount  = $resolved
					Domain     = $domain
					Username   = $username
					SID        = $SID
				}
			}
		} Catch {
			Write-Warning "Failed to resolve $SID. $($_.Exception.InnerException.Message)"
		}
	} #process

	End {
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
	} #end

} #close Resolve-SID
 
Export-ModuleMember -Function Resolve-SID
#endregion
 
#region Restore-ElevatedShortcut.ps1
######## Function 62 of 95 ##################
# Function:         Restore-ElevatedShortcut
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Restore the RunAss shortcuts, from a zip file
#############################################
 
<#
.SYNOPSIS
Restore the RunAss shortcuts, from a zip file


.DESCRIPTION
Restore the RunAss shortcuts, from a zip file

.PARAMETER ZipFilePath
Path to the backup file

.PARAMETER ForceReinstall
Override existing shortcuts

.EXAMPLE
Restore-ElevatedShortcut -ZipFilePath c:\temp\bck.zip -ForceReinstall

#>
Function Restore-ElevatedShortcut {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Restore-ElevatedShortcut')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt.' } })]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.zip') })]
        [System.IO.FileInfo]$ZipFilePath,
        [switch]$ForceReinstall = $false
				)
    try {
        $ZipFile = Get-Item $ZipFilePath
        Pscx\Expand-Archive -Path $ZipFile.FullName -OutputPath $env:TMP -Force
    } catch {Write-Warning "Error: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

    $files = Get-ChildItem $env:TMP\Tasks\*.xml
    foreach ($file in $files) {
        $checktask = $null
        try {
            if ($ForceReinstall) { Get-ScheduledTask -TaskName "$($file.BaseName)" -TaskPath '\RunAs\' | Unregister-ScheduledTask -Confirm:$false }
            $checktask = Get-ScheduledTaskInfo "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
        } catch { $checktask = $null }
        if ( $null -eq $checktask) {
            try {
                Write-Host 'Task:' -ForegroundColor Cyan -NoNewline
                Write-Host "$($file.BaseName)" -ForegroundColor red
                [xml]$importfile = Get-Content $file.FullName
                $sid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).value
                $importfile.Task.Principals.Principal.UserId = $sid
                Register-ScheduledTask -Xml ($importfile.OuterXml | Out-String) -TaskName "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
            } Catch { Write-Warning "$($_.BaseName) - wrong domain" }
            finally { Write-Warning "$($_.BaseName)" }
        }
    }
    Remove-Item -Path $env:TMP\Tasks\*.xml -Recurse
    Remove-Item -Path $env:TMP\Tasks
} #end Function
 
Export-ModuleMember -Function Restore-ElevatedShortcut
#endregion
 
#region Save-PSModules.ps1
######## Function 63 of 95 ##################
# Function:         Save-PSModules
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/24 07:54:19
# Synopsis:         Saves the modules to a local repo.
#############################################
 
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
 
Export-ModuleMember -Function Save-PSModules
#endregion
 
#region Search-Script.ps1
######## Function 64 of 95 ##################
# Function:         Search-Script
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Search for a string in a directory of ps1 scripts.
#############################################
 
<#
.SYNOPSIS
Search for a string in a directory of ps1 scripts.

.DESCRIPTION
Search for a string in a directory of ps1 scripts.

.PARAMETER Path
Path to search.

.PARAMETER Include
File extension to search. Default is ps1.

.PARAMETER KeyWord
The string to search for.

.PARAMETER ListView
Show result as a list.

.EXAMPLE
Search-Scripts -Path . -KeyWord "contain" -ListView

#>
FUNCTION Search-Script {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Search-Scripts')]
    PARAM(
        [STRING[]]$Path = $pwd,
        [STRING[]]$Include = '*.ps1',
        [STRING[]]$KeyWord = (Read-Host 'Keyword?'),
        [SWITCH]$ListView
    )
    BEGIN {

    }
    PROCESS {
        $Result = Get-ChildItem -Path $Path -Include $Include -Recurse | Sort-Object Directory, CreationTime | Select-String -SimpleMatch $KeyWord -OutVariable Result | Out-Null
    }
    END {
        IF ($ListView) {
            $Result | Format-List -Property Path, LineNumber, Line
        }
        ELSE {
            $Result | Format-Table -GroupBy Path -Property LineNumber, Line -AutoSize
        }
    }
}
 
Export-ModuleMember -Function Search-Script
#endregion
 
#region Set-FolderCustomIcon.ps1
######## Function 65 of 95 ##################
# Function:         Set-FolderCustomIcon
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/25 03:55:57
# Synopsis:         Will change the icon of a folder to a custom selected icon
#############################################
 
<#
.SYNOPSIS
Will change the icon of a folder to a custom selected icon

.DESCRIPTION
Will change the icon of a folder to a custom selected icon

.PARAMETER FolderPath
Path to the folder to be changed.

.PARAMETER CustomIconPath
Path to the .ico, .exe, .icl or .dll file, containing the icon.

.PARAMETER Index
The index of the icon in the file.

.EXAMPLE
Set-FolderCustomIcon -FolderPath C:\temp -CustomIconPath C:\WINDOWS\System32\SHELL32.dll -Index 27

.NOTES
General notes
#>
Function Set-FolderCustomIcon {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-FolderCustomIcon')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { if (Test-Path $_) { $true } })]
		[System.IO.DirectoryInfo]$FolderPath,
		[ValidateScript( { if ((Test-Path $_) -and ((Get-Item $_).Extension -in @('.exe', '.ico', '.icl', '.dll'))) {$true} })]
		[string]$CustomIconPath,
		[int32]$Index
	)

	try {
		[System.IO.FileInfo]$CustomIconPath = Get-Item $CustomIconPath
		if ($index) {
			$fullicon = "$($CustomIconPath.FullName),$($Index)"
		} else {
			$fullicon = "$($CustomIconPath.FullName),0"
		}
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

	$DesktopIni = @"
[.ShellClassInfo]
IconResource= $($fullicon)
"@
	try {
		#Create/Add content to the desktop.ini file
		if (Test-Path (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini')) {Remove-Item (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini') -Force -ErrorAction SilentlyContinue}
		$newini = New-Item -Path (Join-Path -Path $($FolderPath) -ChildPath '\desktop.ini') -ItemType File -Value $DesktopIni
  
		#Set the attributes for $DesktopIni
		$newini.Attributes = 'Hidden, System, Archive'
 
		#Finally, set the folder's attributes
		$(Get-Item $FolderPath).Attributes = 'ReadOnly, Directory'
		#endregion
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
} #end Function
 
Export-ModuleMember -Function Set-FolderCustomIcon
#endregion
 
#region Set-ObjectOwnerShip.ps1
######## Function 66 of 95 ##################
# Function:         Set-ObjectOwnerShip
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/05 15:30:28
# Synopsis:         Reset the ownership of a folder, and add the specified user with full control.
#############################################
 
<#
.SYNOPSIS
Reset the ownership of a folder, and add the specified user with full control.

.DESCRIPTION
Reset the ownership of a folder, and add the specified user with full control.


#>
<#
.SYNOPSIS
Reset the ownership of a folder, and add the specified user with full control.


.DESCRIPTION
Reset the ownership of a folder, and add the specified user with full control.

.PARAMETER FolderPath
The folder to replace the permissions

.PARAMETER UserName
This user will be granted full control.

.EXAMPLE
Set-ObjectOwnerShip -FolderPath c:\temp -UserName lab\james

#>
Function Set-ObjectOwnerShip {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Set-ObjectOwnerShip')]
	[OutputType([System.Object[]])]
	param (
		[Parameter(Mandatory = $true)]
		[validatescript({if (Test-Path $_) {$true}
				else {throw 'Unknown Path...'}})]
		[Alias('Name')]
		[System.IO.DirectoryInfo[]]$FolderPath,

		[Parameter(Mandatory = $true)]
		[string[]]$UserName
	)

	[System.Collections.generic.List[PSObject]]$Object2 = @()
	[System.Collections.generic.List[PSObject]]$object = @()


	foreach ($Path in $FolderPath) {
		$FullPath = Get-Item $Path
		Start-Process -FilePath takeown -ArgumentList "/f $($FullPath.FullName) /r /d y" -NoNewWindow -RedirectStandardError "$($env:TMP)\error.log" -RedirectStandardOutput "$($env:TMP)\std.log" -Wait
		$Errors += Get-Content "$($env:TMP)\error.log"
		$StandardOut = Get-Content "$($env:TMP)\std.log" | Where-Object {$_ -notlike $null}
		$StandardOut | ForEach-Object {
			$object.Add([PSCustomObject]@{
					Status = $_.split('"')[0].split(':')[0]
					File   = $_.split('"')[1]
					Owner  = $_.split('"')[3]
				})
		}


		foreach ($User in $UserName) {

			Start-Process -FilePath icacls -ArgumentList "$($FullPath.FullName) /grant $($User):F /t /C" -NoNewWindow -RedirectStandardError "$($env:TMP)\icacls_error.log" -RedirectStandardOutput "$($env:TMP)\icalcs_std.log" -Wait
			$Errors += Get-Content "$($env:TMP)\icacls_error.log"
			$icacls_StandardOut = Get-Content "$($env:TMP)\icalcs_std.log"
			$icacls_StandardOut | ForEach-Object {
				$Object2.Add([PSCustomObject]@{
						User   = $User
						Status = $_.split(' ')[0]
						Object = $_.split(' ')[1]
						File   = $_.split(' ')[2]
					})
			}
		}
		return [PSCustomObject]@{
			OwnweShip = $object
			ICalcs    = $Object2
			Error     = $Errors
		}

	}
} #end Function
 
Export-ModuleMember -Function Set-ObjectOwnerShip
#endregion
 
#region Set-PSProjectFile.ps1
######## Function 67 of 95 ##################
# Function:         Set-PSProjectFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/02 02:40:33
# Synopsis:         Creates and modify needed files for a PS project from existing module files.
#############################################
 
<#
.SYNOPSIS
Creates and modify needed files for a PS project from existing module files.

.DESCRIPTION
Creates and modify needed files for a PS project from existing module files.

.PARAMETER ModuleScriptFile
Path to module .psm1 file.

.PARAMETER CopyNestedModules
Will copy the required modules to the folder.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER mkdocs
Create and test the mkdocs site

.PARAMETER GitPush
Run Git Push when done.

.PARAMETER CopyToModulesFolder
Copies the module to program files.

.EXAMPLE
Set-PSProjectFiles -ModuleScriptFile blah -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[System.IO.FileInfo]$ModuleScriptFile,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'CombineOnly',
		[ValidateSet('serve', 'deploy')]
		[string]$mkdocs = 'None',
		[switch]$CopyNestedModules = $false,
		[Switch]$GitPush = $false,
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[switch]$CopyToModulesFolder = $false
	)
	
	#region module
	Write-Color '[Starting]', ' Module Import' -Color Yellow, DarkCyan
	try {
		$modulefile = $ModuleScriptFile | Get-Item -ErrorAction Stop
		$module = Import-Module $modulefile.FullName -Force -PassThru -ErrorAction Stop
	} catch { Write-Error "Error: Importing Module `nMessage:$($_.Exception.message)"; exit }
	#endregion

	#region deleting Folders
	Write-Color '[Starting]', ' Removing Old Folders' -Color Yellow, DarkCyan
	$ModuleBase = ((Get-Item $module.ModuleBase).Parent).fullname
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$ModulePublicFunctions = [IO.Path]::Combine($module.ModuleBase, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($module.ModuleBase, 'Private') | Get-Item
	$Modulemkdocs = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocs.yml')
	$ModuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	[System.Collections.ArrayList]$Issues = @()

	try {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop; Start-Sleep 5 }
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
		if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force -ErrorAction Stop }
		if (Test-Path $ModuleIssuesExcel) { Remove-Item $ModuleIssuesExcel -Force -ErrorAction Stop }	
	} catch {
		try {
			Write-Warning "Error: Deleting Old Folders `nMessage:$($_.Exception.message)`nRetrying"
			Start-Sleep 10
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force -ErrorAction Stop; Start-Sleep 5 }
			if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force -ErrorAction Stop }
		} catch { throw 'Error removing Folder Structure' ; exit }
 }
	#endregion
    
	#region version bump
	if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
		try {
			Write-Color '[Starting]', ' Version increase' -Color Yellow, DarkCyan
			$ModuleManifestFileTMP = Get-Item ($module.Path).Replace('.psm1', '.psd1')
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName -ErrorAction Stop).version 

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				FunctionsToExport = (Get-Command -Module $module.Name -CommandType Function | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties -ErrorAction Stop
		} catch { Write-Error "Error: Updateing Version bump `nMessage:$($_.Exception.message)"; exit }
	} 
	#endregion
	#region Folders
	try {
		Write-Color '[Starting]', ' Creating New Folder Structure' -Color Yellow, DarkCyan
		$ModuleManifestFile = Get-Item ($module.Path).Replace('.psm1', '.psd1')
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object * -ErrorAction Stop
		$FileContent = Get-Content $ModuleManifestFile -ErrorAction Stop
		$DateLine = Select-String -InputObject $ModuleManifestFile -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $ModuleManifestFile -Force -ErrorAction Stop
	} catch { Write-Error "Error: Updating Date in Module Manifest File  `nMessage:$($_.Exception.message)"; exit }
	try {
		$ModuleOutputFolder = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
		$ModuleOutput = New-Item $ModuleOutputFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop

		$ModuledocsFolder = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
		$Moduledocs = New-Item $ModuledocsFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop

		$ModuleExternalHelpFolder = [IO.Path]::Combine($ModuleOutput, 'en-US')
		$ModuleExternalHelp = New-Item $ModuleExternalHelpFolder -ItemType Directory -Force | Get-Item -ErrorAction Stop
	} catch { Write-Error "Error: Creating folders `nMessage:$($_.Exception.message)"; exit }
	#endregion

	#region platyps
	try {
		Write-Color '[Starting]', ' Creating Markdown help files' -Color Yellow, DarkCyan
		$markdownParams = @{
			Module         = $module.Name
			OutputFolder   = $Moduledocs.FullName
			WithModulePage = $false
			Locale         = 'en-US'
			HelpVersion    = $ModuleManifest.Version.ToString()
		}
		New-MarkdownHelp @markdownParams -Force
	} catch { Write-Error "Error: MarkdownHelp `nMessage:$($_.Exception.message)"; exit }

	try {
		Compare-Object -ReferenceObject (Get-ChildItem $ModulePublicFunctions).BaseName -DifferenceObject (Get-ChildItem $Moduledocs).BaseName | Where-Object { $_.SideIndicator -like '<=' } | ForEach-Object {
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'External Help'
					File     = $_.InputObject
					details  = 'Did not create the .md file'
				})
		}

		$MissingDocumentation = Select-String -Path (Join-Path $Moduledocs.FullName -ChildPath '\*.md') -Pattern '({{.*}})'
		$group = $MissingDocumentation | Group-Object -Property Line
		foreach ($gr in $group) {
			foreach ($item in $gr.Group) {
				$object = Get-Item $item.Path
				$mod = Get-Content -Path $object.FullName
				Write-Color "$($object.name):", "$($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])" -Color Cyan, Yellow
				[void]$Issues.Add([PSCustomObject]@{
						Catagory = 'External Help'
						File     = $object.name
						details  = "$($object.name) - $($mod[$($item.LineNumber -2)]) - $($mod[$($item.LineNumber -1)])"
					})
			}
		}
	} catch { Write-Error "Error: Docs check `nMessage:$($_.Exception.message)"; exit }

	try {
		Write-Color '[Starting]', ' Creating External help files' -Color Yellow, DarkCyan
		New-ExternalHelp -Path $Moduledocs.FullName -OutputPath $ModuleExternalHelp.FullName -Force -ShowProgress

		Write-Color '[Starting]', ' Creating About help files' -Color Yellow, DarkCyan
		$aboutfile = [System.Collections.Generic.List[string]]::new()
		$aboutfile.Add('')
		$aboutfile.Add("$($module.Name)")
		$aboutfile.Add("`t about_$($module.Name)")
		$aboutfile.Add(' ')
		$aboutfile.Add('SHORT DESCRIPTION')
		$aboutfile.Add("`t $(($ModuleManifest.Description | Out-String))")
		$aboutfile.Add(' ')
		$aboutfile.Add('NOTES')
		$aboutfile.Add('Functions in this module:')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { ($aboutfile.Add("`t $_ -- $((Get-Help $_).synopsis)")) }
		$aboutfile.Add(' ')
		$aboutfile.Add('SEE ALSO')
		$aboutfile.Add("`t $(($ModuleManifest.ProjectUri.AbsoluteUri | Out-String))")
		$aboutfile.Add("`t $(($ModuleManifest.HelpInfoUri | Out-String))")
		$aboutfile | Set-Content -Path (Join-Path $ModuleExternalHelp.FullName -ChildPath "\about_$($module.Name).help.txt") -Force

		if (!(Test-Path $ModulesInstuctions)) {
			$instructions = [System.Collections.Generic.List[string]]::new()
			$instructions.add("# $($module.Name)")
			$instructions.Add(' ')
			$instructions.add('## Description')
			$instructions.add("$(($ModuleManifest.Description | Out-String).Trim())")
			$instructions.Add(' ')
			$instructions.Add('## Getting Started')
			$instructions.Add("- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/$($module.Name))")
			$instructions.Add('```')
			$instructions.Add("Install-Module -Name $($module.Name) -Verbose")
			$instructions.Add('```')
			$instructions.Add("- or from GitHub [GitHub Repo](https://github.com/smitpi/$($module.Name))")
			$instructions.Add('```')
			$instructions.Add("git clone https://github.com/smitpi/$($module.Name) (Join-Path (get-item (Join-Path (Get-Item `$profile).Directory 'Modules')).FullName -ChildPath $($Module.Name))")
			$instructions.Add('```')
			$instructions.Add('- Then import the module into your session')
			$instructions.Add('```')
			$instructions.Add("Import-Module $($module.Name) -Verbose -Force")
			$instructions.Add('```')
			$instructions.Add('- or run these commands for more help and details.')
			$instructions.Add('```')
			$instructions.Add("Get-Command -Module $($module.Name)")
			$instructions.Add("Get-Help about_$($module.Name)")
			$instructions.Add('```')
			$instructions.Add("Documentation can be found at: [Github_Pages](https://smitpi.github.io/$($module.Name))")
			$instructions | Set-Content -Path $ModulesInstuctions
		}

		$readme = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $readme.add($_) }
		$readme.add(' ')
		$readme.add('## Functions')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $readme.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
		$readme | Set-Content -Path $ModuleReadme

		$mkdocsFunc = [System.Collections.Generic.List[string]]::new()
		$mkdocsFunc.add("site_name: `'$($module.Name)`'")
		$mkdocsFunc.add("site_description: `'Documentation for PowerShell Module: $($module.Name)`'")
		$mkdocsFunc.add("site_author: `'$(($ModuleManifest.Author | Out-String).Trim())`'")
		$mkdocsFunc.add("site_url: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add("repo_url: `'https://github.com/smitpi/$($module.Name)`'")
		$mkdocsFunc.add("repo_name:  `'smitpi/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add("copyright: `'$(($ModuleManifest.Copyright | Out-String).Trim())`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('extra:')
		$mkdocsFunc.add('  manifest: manifest.webmanifest')
		$mkdocsFunc.add('  social:')
		$mkdocsFunc.add('    - icon: fontawesome/brands/github-square')
		$mkdocsFunc.add("      link: `'https://smitpi.github.io/$($module.Name)`'")
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('markdown_extensions:')
		$mkdocsFunc.add('  - pymdownx.keys')
		$mkdocsFunc.add('  - pymdownx.snippets')
		$mkdocsFunc.add('  - pymdownx.superfences')
		$mkdocsFunc.add(' ')
		$mkdocsFunc.add('theme:')
		$mkdocsFunc.add('  name: material')
		$mkdocsFunc.add('  features:')
		$mkdocsFunc.add('    - navigation.instant')
		$mkdocsFunc.add('  language: en')
		$mkdocsFunc.add("  favicon: `'`'")
		$mkdocsFunc.add("  logo: `'`'")
		$mkdocsFunc.add('  palette:')
		$mkdocsFunc.add('    - media: "(prefers-color-scheme: light)"')
		$mkdocsFunc.add('      primary: blue grey')
		$mkdocsFunc.add('      accent: indigo')
		$mkdocsFunc.add('      scheme: default')
		$mkdocsFunc.add('      toggle:')
		$mkdocsFunc.add('        icon: material/toggle-switch-off-outline')
		$mkdocsFunc.add('        name: Switch to dark mode')
		$mkdocsFunc.add('    - media: "(prefers-color-scheme: dark)"')
		$mkdocsFunc.add('      primary: blue grey')
		$mkdocsFunc.add('      accent: indigo')
		$mkdocsFunc.add('      scheme: slate')
		$mkdocsFunc.add('      toggle:')
		$mkdocsFunc.add('        icon: material/toggle-switch')
		$mkdocsFunc.add('        name: Switch to light mode')
		$mkdocsFunc | Set-Content -Path $Modulemkdocs -Force

		$indexFile = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
		$indexFile.add(' ')
		$indexFile.add('## Functions')
	 (Get-Command -Module $module.Name -CommandType Function).name | Sort-Object | ForEach-Object { $indexFile.add("- [``$_``](https://smitpi.github.io/$($module.Name)/$_) -- " + (Get-Help $_).SYNOPSIS) }
		$indexFile | Set-Content -Path $ModuleIndex -Force

		$versionfile = [System.Collections.Generic.List[PSObject]]::New()
		$versionfile.add([pscustomobject]@{
				version = $($moduleManifest.version).ToString()
				Author  = $($moduleManifest.author)
				Date    = (Get-Date -Format u)
			})
		$versionfile | ConvertTo-Json | Set-Content (Join-Path $ModuleBase -ChildPath 'Version.json') -Force
	} catch { Write-Error "Error: Creating Other Files `nMessage:$($_.Exception.message)"; exit }
	#endregion
	
	#region Combine files
	Write-Color '[Starting]', ' Creating new module files' -Color Yellow, DarkCyan

	$ModuleOutput = Get-Item $ModuleOutput
	$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))

	Copy-Item -Path $ModuleManifestFile.FullName -Destination $ModuleOutput.fullname -Force
	$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
	if ($null -notlike $PrivateFiles) {
		Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
	}

	$private = @(Get-ChildItem -Path "$($ModulePrivateFunctions.FullName)\*.ps1" -ErrorAction Stop | Sort-Object -Property Name)
	$public = @(Get-ChildItem -Path "$($ModulePublicFunctions.FullName)\*.ps1" -Recurse -ErrorAction Stop | Sort-Object -Property Name)

	$file = [System.Collections.Generic.List[string]]::new()
	if ($private) {
		$file.add('#region Private Functions')
		foreach ($PrivateItem in $private) {
			$file.add("#region $($PrivateItem.name)")
			$file.Add('########### Private Function ###############')
			$file.Add(('{0,-20}{1}' -f '# Source:', $($PrivateItem.name)))
			$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
			$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
			$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
			$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($PrivateItem.CreationTime)))
			$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($PrivateItem.LastWriteTime)))
			$file.Add('############################################')
			Write-Color '[Processing]: ', $($PrivateItem.name) -Color Cyan, Yellow
			Get-Content $PrivateItem.fullname | ForEach-Object { $file.add($_) }
			$file.add('#endregion')
		}
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#region Public Functions')
	foreach ($PublicItem in $public) {
		$author = $ModuleManifest.Author
		try {
			$scriptinfo = Test-ScriptFileInfo -Path $PublicItem.fullName -ErrorAction Stop
			$author = $scriptinfo.author
		} catch {Write-Warning "`tCould not read script info [$($PublicItem.BaseName)], default values used."}

		$file.add("#region $($PublicItem.name)")
		$file.Add("######## Function $($public.IndexOf($PublicItem) + 1) of $($public.Count) ##################")
		$file.Add(('{0,-20}{1}' -f '# Function:', $($PublicItem.BaseName)))
		$file.Add(('{0,-20}{1}' -f '# Module:', $($module.Name)))
		$file.Add(('{0,-20}{1}' -f '# ModuleVersion:', $($moduleManifest.version)))
		$file.Add(('{0,-20}{1}' -f '# Author:', $($author)))
		$file.Add(('{0,-20}{1}' -f '# Company:', $($moduleManifest.CompanyName)))
		$file.Add(('{0,-20}{1}' -f '# CreatedOn:', $($PublicItem.CreationTime)))
		$file.Add(('{0,-20}{1}' -f '# ModifiedOn:', $($PublicItem.LastWriteTime)))
		$file.Add(('{0,-20}{1}' -f '# Synopsis:', $((Get-Help $($PublicItem.BaseName)).synopsis)))
		$file.Add('#############################################')
		$file.Add(' ')
		Write-Color '[Processing]: ', $($PublicItem.name) -Color Cyan, Yellow

		[int]$StartIndex = (Select-String -InputObject $PublicItem -Pattern '.SYNOPSIS*').LineNumber[0] - 2
		[int]$EndIndex = (Get-Content $PublicItem.FullName).length
		Get-Content -Path $PublicItem.FullName | Select-Object -Index ($StartIndex..$EndIndex) | ForEach-Object { $file.Add($_) }
		$file.Add(' ')
		$file.Add("Export-ModuleMember -Function $($PublicItem.BaseName)")
		$file.add('#endregion')
		$file.Add(' ')
	}
	$file.add('#endregion')
	$file.Add(' ')
	$file | Set-Content -Path $rootModule -Encoding utf8 -Force

	$newfunction = ((Select-String -Path $rootModule -Pattern '^# Function:').Line).Replace('# Function:', '').Trim()
	$ModCommands = Get-Command -Module $module | ForEach-Object { $_.name }

	Compare-Object -ReferenceObject $ModCommands -DifferenceObject $newfunction | ForEach-Object {
		[void]$Issues.Add([PSCustomObject]@{
				Catagory = 'Not Copied'
				File     = $_.InputObject
				details  = $_.SideIndicator
			})
	}
	#endregion
	
	#region NestedModules
	if ($CopyNestedModules) {
		Write-Color '[Starting]', ' Copying nested modules' -Color Yellow, DarkCyan

		if (-not(Test-Path $(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules'))) {
			New-Item -Path "$(Join-Path -Path $ModuleOutput -ChildPath '\NestedModules')" -ItemType Directory -Force | Out-Null
		}
		foreach ($required in $ModuleManifest.RequiredModules) {
			$latestmod = $null
			Import-Module $required -Force -Verbose
			$latestmod = Get-Module $required | Sort-Object -Property Version | Select-Object -First 1
			if (-not($latestmod)) { $latestmod = Get-Module $required -ListAvailable | Sort-Object -Property Version | Select-Object -First 1 }
			
			Write-Color "`t[Copying]", "$($required.Name)" -Color Yellow, DarkCyan
			Copy-Item -Path (Get-Item $latestmod.Path).Directory -Destination ([IO.Path]::Combine($ModuleOutput, 'NestedModules', $($required.Name), $($latestmod.Version))) -Recurse
		}
		$nestedmodules = @()
		$nestedmodules = (Get-ChildItem -Path "$ModuleOutput\NestedModules\*.psm1" -Recurse).FullName | ForEach-Object { $_.Replace("$($ModuleOutput)\", '') }
		$rootManifest = Get-Item ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psd1"))

		$manifest = Import-PowerShellDataFile $ModuleManifest.Path
		$manifest.Remove('CmdletsToExport')
		$manifest.Remove('AliasesToExport')
		$manifest.Remove('PrivateData')
		if ($ModuleManifest.Tags) { $manifest.Add('Tags', $ModuleManifest.Tags) }
		if ($ModuleManifest.LicenseUri) { $manifest.Add('LicenseUri', $ModuleManifest.LicenseUri) }
		if ($ModuleManifest.ProjectUri) { $manifest.Add('ProjectUri', $ModuleManifest.ProjectUri) }
		if ($ModuleManifest.IconUri) { $manifest.Add('IconUri', $ModuleManifest.IconUri) }
		if ($ModuleManifest.ReleaseNotes) { $manifest.Add('ReleaseNotes', $ModuleManifest.ReleaseNotes) }

		if (Test-Path $rootManifest) { Remove-Item $rootManifest -Force }
		New-ModuleManifest -Path $rootManifest.FullName -NestedModules $nestedmodules @manifest

		$FileContent = Get-Content $rootManifest
		$DateLine = Select-String -InputObject $rootManifest -Pattern '# Generated on:'
		$FileContent[($DateLine.LineNumber - 1)] = "# Generated on: $(Get-Date -Format u)"
		$FileContent | Set-Content $rootManifest -Force
	}
	#endregion

	#region report issues
	if ($null -notlike $Issues) { 
		Write-Color '[Starting]', ' Creating Issues Reports' -Color Yellow, DarkCyan
		$issues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName Other -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow 
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add((New-MDHeader "$($module.Name): Issues"))
		$Fragments.Add("---`n")
		$fragments.Add((New-MDTable -Object $Issues))
		$Fragments.Add("---`n")
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File -FilePath $ModuleIssues -Encoding utf8 -Force
	}
	#endregion
	
	#region mkdocs
	if ($mkdocs -like 'serve') {
		Write-Color '[Starting]', ' Creating MKDocs help files' -Color Yellow, DarkCyan
		Start-Process -FilePath mkdocs.exe -ArgumentList 'serve -a localhost:7070 --livereload --dirtyreload' -WorkingDirectory (Split-Path -Path $Moduledocs -Parent) -WindowStyle Normal
		Start-Sleep 5
		Start-Process "http://127.0.0.1:7070/$($module.Name)/"
	}
	if ($mkdocs -like 'deploy') {
		Start-Process -FilePath mkdocs.exe -ArgumentList gh-deploy -WorkingDirectory (Split-Path -Path $Moduledocs -Parent) -NoNewWindow 2>&1 | Write-Host -ForegroundColor Yellow 
	}
	#endregion

	#region Git push
	if ($GitPush) {
		if (Get-Command git.exe -ErrorAction SilentlyContinue) {
			Write-Color '[Starting]', ' Git Push' -Color Yellow, DarkCyan
			Set-Location $ModuleBase 
			Start-Sleep 5
			git add --all 2>&1 | Write-Host -ForegroundColor DarkCyan
			git commit --all -m "To Version: $($moduleManifest.version.tostring())" 2>&1 | Write-Host -ForegroundColor DarkGreen
			git push 2>&1 | Write-Host -ForegroundColor DarkRed
		} else { Write-Warning 'Git is not installed' }
	}
	#endregion

	#region Copy to Dir
	if ($CopyToModulesFolder) {
		Write-Color '[Copying]', ' New Module ', "$($modulefile.basename) ver:($($ModuleManifest.Version.ToString())) ", 'to Windows PowerShell' -Color Yellow, DarkCyan, Green, DarkCyan
		if (-not(Test-Path "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)")) { New-Item "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" -ItemType Directory -Force | Out-Null }
		Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" | Compress-Archive -DestinationPath "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)\$($modulefile.basename)-bck.zip" -Update
		Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)" | Remove-Item -Recurse -Force
		Copy-Item -Path $ModuleOutput.FullName -Destination "C:\Program Files\WindowsPowerShell\Modules\$($modulefile.basename)\" -Force -Recurse

		Write-Color '[Copying]', ' New Module ', "$($modulefile.basename) ver:($($ModuleManifest.Version.ToString())) ", 'to PowerShell' -Color Yellow, DarkCyan, Green, DarkCyan
		if (-not(Test-Path "C:\Program Files\PowerShell\Modules\$($modulefile.basename)")) { New-Item "C:\Program Files\PowerShell\Modules\$($modulefile.basename)" -ItemType Directory -Force | Out-Null }
		Get-ChildItem -Directory "C:\Program Files\PowerShell\Modules\$($modulefile.basename)" | Compress-Archive -DestinationPath "C:\Program Files\PowerShell\Modules\$($modulefile.basename)\$($modulefile.basename)-bck.zip" -Update
		Get-ChildItem -Directory "C:\Program Files\PowerShell\Modules\$($modulefile.basename)" | Remove-Item -Recurse -Force
		Copy-Item -Path $ModuleOutput.FullName -Destination "C:\Program Files\PowerShell\Modules\$($modulefile.basename)\" -Force -Recurse
	}
	#endregion

}#end Function
 
$scriptblock = {
	param($commandName, $parameterName, $stringMatch)
	$here = (Get-Item .)
	(Get-ChildItem -Path .\*.psm1 -Recurse).FullName | ForEach-Object { $_.Replace("$($here.FullName)", '.') }
}
Register-ArgumentCompleter -CommandName Set-PSProjectFile -ParameterName ModuleScriptFile -ScriptBlock $scriptBlock
 
Export-ModuleMember -Function Set-PSProjectFile
#endregion
 
#region Set-PSToolKitSystemSetting.ps1
######## Function 68 of 95 ##################
# Function:         Set-PSToolKitSystemSetting
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Set multiple settings on desktop or server
#############################################
 
<#
.SYNOPSIS
Set multiple settings on desktop or server

.DESCRIPTION
Set multiple settings on desktop or server

.PARAMETER RunAll
Enable all the options in this function. Except windows update and reboot.

.PARAMETER ExecutionPolicy
Set ps execution policy to unrestricted.

.PARAMETER IntranetZone
Setup intranet zones for mapped drives.

.PARAMETER IntranetZoneIPRange
Setup intranet zones for mapped drives from IP addresses.

.PARAMETER PSTrustedHosts
Set trusted hosts to domain servers.

.PARAMETER SystemDefaults
Set some system settings.

.PARAMETER SetPhotoViewer
Set photo viewer

.PARAMETER FileExplorerSettings
Change explorer settings to what I like.

.PARAMETER DisableIPV6
Disable ipv6 on all network cards.

.PARAMETER DisableFirewall
Disable windows firewall on all network profiles.

.PARAMETER DisableInternetExplorerESC
Disable IE Extra security.

.PARAMETER DisableServerManager
Closes and set server manager not to open on start.

.PARAMETER EnableRDP
Enable RDP to this device.

.PARAMETER PerformReboot
Reboot after all the setting changes.

.EXAMPLE
Set-PSToolKitSystemSettings -RunAll

#>
Function Set-PSToolKitSystemSetting {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSToolKitSystemSettings')]
    PARAM(
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$RunAll = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$ExecutionPolicy = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$IntranetZone = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$IntranetZoneIPRange = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$PSTrustedHosts = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$FileExplorerSettings = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$SystemDefaults = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$SetPhotoViewer = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableIPV6 = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableFirewall = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableInternetExplorerESC = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$DisableServerManager = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$EnableRDP = $false,
        [ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
                else { Throw 'Must be running an elevated prompt to use function' } })]
        [switch]$PerformReboot = $false
    )

    if ($RunAll) {
        $ExecutionPolicy = $True
        $IntranetZone = $True
        $IntranetZoneIPRange = $True
        $PSTrustedHosts = $True
        $FileExplorerSettings = $True
        $SystemDefaults = $True
        $SetPhotoViewer = $True
        $DisableIPV6 = $True
        $DisableFirewall = $True
        $DisableInternetExplorerESC = $True
        $DisableServerManager = $True
        $EnableRDP = $True

    }

    if ($ExecutionPolicy) {
        try {
            if ((Get-ExecutionPolicy) -notlike 'Unrestricted') {
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser
                Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope LocalMachine
                Write-Color '[Set]', 'ExecutionPolicy: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Set]', 'ExecutionPolicy: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Set]ExecutionPolicy: Failed:`n $($_.Exception.Message)" }

    }

    if ($IntranetZone) {
        $domainCheck = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()

        $LocalIntranetSite = $domainCheck.Name

        $parent = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
        $key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains'
        $CompRegPath = Join-Path $key -ChildPath $LocalIntranetSite
        $DWord = 1

        try {
            Write-Verbose "Creating a new key '$LocalIntranetSite' under $UserRegPath."

            if ((Test-Path -Path $CompRegPath) -eq $false ) {
                if ((Test-Path -Path $key) -eq $false ) { New-Item -Path $parent -ItemType File -Name 'Domains' | Out-Null }
                New-Item -Path $key -ItemType File -Name "$LocalIntranetSite" | Out-Null
                Set-ItemProperty -Path $CompRegPath -Name 'file' -Value $DWord | Out-Null
                Write-Color '[Set]', "IntranetZone $($LocalIntranetSite): ", 'Complete' -Color Yellow, Cyan, Green
            } else { Write-Color '[Set]', "IntranetZone $($LocalIntranetSite): ", 'Already Set' -Color Yellow, Cyan, DarkRed }

        } Catch { Write-Warning "[Set]IntranetZone: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($IntranetZoneIPRange) {
        $IPAddresses = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127*'}
        $index = 1
        foreach ($ip in $IPAddresses) {
            $ipdata = $ip.IPAddress.Split('.')
            $parent = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
            $key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges'
            $keychild = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range$($index)"
            $DWord = 1

            try {
                if (-not(Test-Path -Path $Key)) {
                    New-Item -Path $parent -ItemType File -Name 'Ranges' | Out-Null
                }
                if (-not(Test-Path -Path $keychild)) {
                    New-Item -Path $key -ItemType File -Name "Range$($index)" | Out-Null
                    Set-ItemProperty -Path $keychild -Name 'file' -Value $DWord | Out-Null
                    Set-ItemProperty -Path $keychild -Name ':Range' -Value "$($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*" | Out-Null
                    Write-Color '[Set]', "IntranetZone IP Range: $($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*: ", 'Complete' -Color Yellow, Cyan, Green
                } else {
                    Write-Color '[Set]', "IntranetZone IP Range: $($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*: ", 'Already Set' -Color Yellow, Cyan, DarkRed
                    ++$index
                }
            } Catch { Write-Warning "[Set]IntranetZone Ip Range: Failed:`n $($_.Exception.Message)" }
        }

    } #end if

    if ($DisableIPV6) {
        try {
            if ((Get-NetAdapterBinding -ComponentID ms_tcpip6).enabled -contains 'True') {
                Get-NetAdapterBinding -ComponentID ms_tcpip6 | Where-Object { $_.enabled -eq 'True' } | ForEach-Object { Disable-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 }
                Write-Color '[Disable]', 'IPv6: ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Disable]', 'IPv6: ', 'Already Set' -Color Yellow, Cyan, DarkRed
            }

        } Catch { Write-Warning "[Disable]IPv6: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($DisableFirewall) {
        try {
            if ((Get-NetFirewallProfile -Profile Domain, Public, Private).enabled -contains 'True') {
                Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
                Write-Color '[Disable]', 'Firewall: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Disable]', 'Firewall: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } Catch { Write-Warning "[Disable]Firewall: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($EnableRDP) {
        try {
            if ((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections -notlike 0) {
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
                Write-Color '[Enable]', 'RDP: ', 'Complete' -Color Yellow, Cyan, Green
            } else {Write-Color '[Enable]', 'RDP: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } Catch { Write-Warning "[Enable]RDP: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($DisableInternetExplorerESC) {
        try {
            $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
            if ($checkver -like '*server*') {
                $AdminKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
                $UserKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
                if ((Get-ItemProperty -Path $AdminKey).isinstalled -notlike 0) {
                    Set-ItemProperty -Path $AdminKey -Name 'IsInstalled' -Value 0 -Force
                    Set-ItemProperty -Path $UserKey -Name 'IsInstalled' -Value 0 -Force
                    Rundll32 iesetup.dll, IEHardenLMSettings
                    Rundll32 iesetup.dll, IEHardenUser
                    Rundll32 iesetup.dll, IEHardenAdmin
                    Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'Complete' -Color Yellow, Cyan, Green
                } else {Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'Already Set' -Color Yellow, Cyan, DarkRed}
            } else { Write-Color '[Disable]', 'IE Enhanced Security Configuration (ESC): ', 'No Server OS Detected' -Color Yellow, Cyan, DarkRed }
        } catch { Write-Warning '[Disable]', "IE Enhanced Security Configuration (ESC): failed:`n $($_.Exception.Message)" }

    }

    if ($DisableServerManager) {
        try {
            $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
            if ($checkver -like '*server*') {
                if (Get-Process 'servermanager' -ErrorAction SilentlyContinue) { Stop-Process -Name servermanager -Force }
                if ((Get-ItemProperty HKCU:\Software\Microsoft\ServerManager).DoNotOpenServerManagerAtLogon -notlike 1) {
                    New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value '0x1' -Force
                    Write-Color '[Disable]', 'ServerManager: ', 'Complete' -Color Yellow, Cyan, Green
                } else {
                    Write-Color '[Disable]', 'ServerManager: ', 'Already Set' -Color Yellow, Cyan, DarkRed
                }
            } else { Write-Color '[Disable]', 'ServerManager: ', 'No Server OS Detected' -Color Yellow, Cyan, DarkRed }
        } catch { Write-Warning "[Disable]ServerManager: Failed:`n $($_.Exception.Message)" }

    }

    if ($PSTrustedHosts) {
        try {
            Enable-PSRemoting -Force | Out-Null
            $domainCheck = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
            $currentlist = @()
            [array]$currentlist += (Get-Item WSMan:\localhost\Client\TrustedHosts).value.split(',')
            if (-not($currentlist -contains "*.$domainCheck")) {
                if ($false -eq [bool]$currentlist) {
                    $DomainList = "*.$domainCheck"
                    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$DomainList" -Force
                    Write-Color '[Set]', 'TrustedHosts: ', 'Complete' -Color Yellow, Cyan, Green

                } else {
                    $currentlist += "*.$domainCheck"
                    $newlist = Join-String -Strings $currentlist -Separator ','
                    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$newlist" -Force
                    Write-Color '[Set]', 'TrustedHosts: ', 'Complete' -Color Yellow, Cyan, Green

                }
            } else {Write-Color '[Set]', 'TrustedHosts: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Set]TrustedHosts: Failed:`n $($_.Exception.Message)" }
    } #end if

    if ($FileExplorerSettings) {
        try {
            Write-Color '[Setting]', 'File Explorer Settings:' -Color Yellow, Cyan

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowStatusBar -Value 1
            Write-Color '[Set]', 'ShowStatusBar: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMenuAdminTools -Value 1
            Write-Color '[Set]', 'StartMenuAdminTools: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name FolderContentsInfoTip -Value 1
            Write-Color '[Set]', 'FolderContentsInfoTip: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 0
            Write-Color '[Set]', 'ShowSecondsInSystemClock: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SnapAssist -Value 1
            Write-Color '[Set]', 'SnapAssist: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Type DWord -Value 0
            Write-Color '[Set]', 'HideFileExt: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowHiddenFiles : ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideMergeConflicts' -Type DWord -Value 0
            Write-Color '[Set]', 'ShowFolderMergeConflicts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowEncryptCompressedColor' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowEncCompFilesColor: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'AutoCheckSelect' -Type DWord -Value 1
            Write-Color '[Set]', 'ShowSelectCheckboxes: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowRecent' -Type DWord -Value 0
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowFrequent' -Type DWord -Value 0
            Write-Color '[Set]', 'HideRecentShortcuts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type DWord -Value 1
            Write-Color '[Set]', 'SetExplorerThisPC: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'IconsOnly' -Type DWord -Value 0
            Write-Color '[Set]', 'EnableThumbnails: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisableThumbnailCache' -ErrorAction SilentlyContinue
            Write-Color '[Set]', 'EnableThumbnailCache: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisableThumbsDBOnNetworkFolders' -ErrorAction SilentlyContinue
            Write-Color '[Set]', 'EnableThumbsDBOnNetwork: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
            <#
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ServerAdminUI -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCompColor -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DontPrettyPath -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowInfoTip -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideIcons -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MapNetDrvBtn -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name WebView -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Filter -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SeparateProcess -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name AutoCheckSelect -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name IconsOnly -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTypeOverlay -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowStatusBar -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StoreAppsOnTaskbar -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ListviewAlphaSelect -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ListviewShadow -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarAnimations -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMigratedBrowserPin -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ReindexedProfile -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartMenuAdminTools -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name UseCompactMode -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name StartShownOnUpgrade -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarSizeMove -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DisablePreviewDesktop -Value 0
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name FolderContentsInfoTip -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowEncryptCompressedColor -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 1
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SnapAssist -Value 1
            Write-Color '[Set]', 'File Explorer Settings: ', 'Complete' -Color Yellow, Cyan, Green
#>
        } catch { Write-Warning "[Set]File Explorer Settings: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($SetPhotoViewer) {
        If (!(Test-Path 'HKCR:')) {
            New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' | Out-Null
        }
        ForEach ($type in @('Paint.Picture', 'giffile', 'jpegfile', 'pngfile')) {
            New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
            New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
            Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name 'MuiVerb' -Type ExpandString -Value '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'
            Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name '(Default)' -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
        }
        Write-Color '[Set]', 'SetPhotoViewerAssociation: ', 'Complete' -Color Yellow, Cyan, Green

        If (!(Test-Path 'HKCR:')) {
            New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' | Out-Null
        }
        New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command' -Force | Out-Null
        New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget' -Force | Out-Null
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open' -Name 'MuiVerb' -Type String -Value '@photoviewer.dll,-3043'
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command' -Name '(Default)' -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
        Set-ItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget' -Name 'Clsid' -Type String -Value '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'
        Write-Color '[Set]', 'AddPhotoViewerOpenWith: ', 'Complete' -Color Yellow, Cyan, Green

    }

    if ($SystemDefaults) {
        Write-Color '[Setting]', 'System Defaults: ' -Color Yellow, Cyan
        If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main')) {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Type DWord -Value 1
        Write-Color '[Set]', 'DisableIEFirstRun: ', 'Complete' -Color Yellow, Cyan, Green

        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableFirstLogonAnimation' -Type DWord -Value 0
        Write-Color '[Set]', 'DisableFirstLogonAnimation: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability')) {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name 'ShutdownReasonOn' -Type DWord -Value 0
        Write-Color '[Set]', 'DisableShutdownTracker: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' -Name 'PreventDeviceMetadataFromNetwork' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching' -Name 'SearchOrderConfig' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'EnableUpdateDriver: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

	    (New-Object -ComObject Microsoft.Update.ServiceManager).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '') | Out-Null
        Write-Color '[Set]', 'EnableUpdateMSProducts: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        If (!(Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy')) {
            New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Force | Out-Null
        }
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '01' -Type DWord -Value 1
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name 'StoragePoliciesNotified' -Type DWord -Value 1
        Write-Color '[Set]', 'EnableStorageSense: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-Service 'WSearch' -StartupType Automatic
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch' -Name 'DelayedAutoStart' -Type DWord -Value 1
        Start-Service 'WSearch' -WarningAction SilentlyContinue
        Write-Color '[Set]', 'EnableIndexing: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Type DWord -Value 1
        Write-Color '[Set]', 'EnableNTFSLongPaths: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 1
        Write-Color '[Set]', 'ShowTaskbarSearchIcon: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoStartMenuMFUprogramsList' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'ShowMostUsedApps: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        If ([System.Environment]::OSVersion.Version.Build -le 14393) {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DontUsePowerShellOnWinX' -Type DWord -Value 0
        } Else {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DontUsePowerShellOnWinX' -ErrorAction SilentlyContinue
        }
        Write-Color '[Set]', 'SetWinXMenuPowerShell: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'StartupPage' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'AllItemsIconView' -ErrorAction SilentlyContinue
        Write-Color '[Set]', 'SetControlPanelCategories: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
        If (!(Test-Path 'HKU:')) {
            New-PSDrive -Name 'HKU' -PSProvider 'Registry' -Root 'HKEY_USERS' | Out-Null
        }
        Set-ItemProperty -Path 'HKU:\.DEFAULT\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -Type DWord -Value 2147483650
        Add-Type -AssemblyName System.Windows.Forms
        If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{NUMLOCK}')
        }
        Write-Color '[Set]', 'EnableNumlock: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1

        $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
        if ($checkver -notlike '*server*') {
            Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE"
            vssadmin Resize ShadowStorage /On=$env:SYSTEMDRIVE /For=$env:SYSTEMDRIVE /MaxSize=10GB | Out-Null
            Write-Color '[Set]', 'EnableRestorePoints: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
        }
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Type String -Value '1'
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Type String -Value '6'
        Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Type String -Value '10'
        Write-Color '[Set]', 'EnableEnhPointerPrecision: ', 'Complete' -Color Yellow, Cyan, Green -StartTab 1
    }

    if ($PerformReboot) {
        try {
            Write-Color '[Checking] ', 'Pending Reboot' -Color Yellow, Cyan
            $checkreboot = Test-PendingReboot -ComputerName $env:computername
            if ($checkreboot.IsPendingReboot -like 'True') {
                Write-Color '[Checking] ', 'Reboot Required', ' (Reboot in 15 sec)' -Color Yellow, DarkRed, Cyan
                Start-Sleep -Seconds 15
                Restart-Computer -Force
            } else {
                Write-Color '[Checking] ', 'Reboot Not Required' -Color Yellow, Cyan
            }
        } catch { Write-Warning "[Checking] Required Reboot: Failed:`n $($_.Exception.Message)" }
    }

} #end Function
 
Export-ModuleMember -Function Set-PSToolKitSystemSetting
#endregion
 
#region Set-SharedPSProfile.ps1
######## Function 69 of 95 ##################
# Function:         Set-SharedPSProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/06 00:29:36
# Synopsis:         Redirects PowerShell and WindowsPowerShell profile folder to another path.
#############################################
 
<#
.SYNOPSIS
Redirects PowerShell and WindowsPowerShell profile folder to another path.

.DESCRIPTION
Redirects PowerShell and WindowsPowerShell profile folder to another path.

.PARAMETER CurrentUser
Will change the currently logged on user's folders.

.PARAMETER OtherUser
Will change another user's folders.

.PARAMETER ProfilePath
The Other Users' Profile Path.

.PARAMETER SharedProfilePath
Path to new folder. Folders PowerShell and WindowsPowerShell will be created if it doesn't exists.

.EXAMPLE
Set-SharedPSProfile -CurrentUser -SharedProfilePath "\\nas01\profile"

.NOTES
General notes
#>
function Set-SharedPSProfile {
	[Cmdletbinding(DefaultParameterSetName = 'Current', HelpURI = 'https://smitpi.github.io/PSToolKit/Set-SharedPSProfile')]
	param (
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Current')]
		[switch]$CurrentUser,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Other')]
		[switch]$OtherUser,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Parameter(ParameterSetName = 'Other')]
		[string]$ProfilePath,

		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (Test-Path $_) { $true }
				else { throw 'Not a valid Location' }
			})]
		[Parameter(ParameterSetName = 'Other')]
		[Parameter(ParameterSetName = 'Current')]
		[System.IO.DirectoryInfo]$SharedProfilePath
	)

	try {
		if ($CurrentUser) {	$PersonalDocuments = [Environment]::GetFolderPath('MyDocuments') }
		if ($OtherUser) { $PersonalDocuments = [IO.Path]::Combine("$($ProfilePath)", 'Documents') }
		if ($null -like $PersonalDocuments) { throw 'No User selected.' }

		$WindowsPowerShell = [IO.Path]::Combine($PersonalDocuments, 'WindowsPowerShell')
		$PowerShell = [IO.Path]::Combine($PersonalDocuments, 'PowerShell')

		if ((Test-Path $WindowsPowerShell) -eq $true ) {
			Write-Warning 'Folder exists, renamig now...'
			Rename-Item -Path $WindowsPowerShell -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose

		}

		if ((Test-Path $PowerShell) -eq $true ) {
			Write-Warning 'Folder exists, renamig now...'
			Rename-Item -Path $PowerShell -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose
		}
	} catch { Write-Warning "Error: `nMessage:$($_.Exception.Message)" }

	if (-not(Test-Path $WindowsPowerShell) -and -not(Test-Path $PowerShell)) {
		$NewWindowsPowerShell = [IO.Path]::Combine($SharedProfilePath, 'WindowsPowerShell')
		$NewPowerShell = [IO.Path]::Combine($SharedProfilePath, 'PowerShell')

		if (-not(Test-Path $NewWindowsPowerShell)) { New-Item $NewWindowsPowerShell -ItemType Directory -Force }
		if (-not(Test-Path $NewPowerShell)) { New-Item $NewPowerShell -ItemType Directory -Force }

		New-Item -ItemType SymbolicLink -Name WindowsPowerShell -Path $PersonalDocuments -Value $NewWindowsPowerShell
		New-Item -ItemType SymbolicLink -Name PowerShell -Path $PersonalDocuments -Value $NewPowerShell

		Write-Host 'Move PS Profile to the shared location: ' -ForegroundColor Cyan -NoNewline
		Write-Host Completed -ForegroundColor green
	} else {
		Write-Warning "$($PersonalPSFolder) Already Exists, remove old profile fist"
	}
}


$scriptblock = {
	#param($commandName, $parameterName, $stringMatch)

	(Get-CimInstance Win32_UserProfile | Select-Object localpath).LocalPath
}
Register-ArgumentCompleter -CommandName Set-SharedPSProfile -ParameterName OtherUserName -ScriptBlock $scriptBlock




 
Export-ModuleMember -Function Set-SharedPSProfile
#endregion
 
#region Set-StaticIP.ps1
######## Function 70 of 95 ##################
# Function:         Set-StaticIP
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Set static IP on device
#############################################
 
<#
.SYNOPSIS
Set static IP on device

.DESCRIPTION
Set static IP on device

.PARAMETER IP
New IP

.PARAMETER GateWay
new gateway

.PARAMETER DNS
new DNS

.EXAMPLE
Set-StaticIP -IP 192.168.10.10 -GateWay 192.168.10.1 -DNS 192.168.10.60

#>
function Set-StaticIP {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-StaticIP')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$IP,
		[string]$GateWay,
		[string]$DNS
	)

	Disable-IPV6
	New-NetIPAddress -IPAddress $IP -DefaultGateway $GateWay -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex
	Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses $DNS
	Write-Host 'Static IP Set:' -ForegroundColor Cyan -NoNewline
	Write-Host $IP -ForegroundColor Yellow
	Get-NetIPAddress -IPAddress $IP
}
 
Export-ModuleMember -Function Set-StaticIP
#endregion
 
#region Set-TempFolder.ps1
######## Function 71 of 95 ##################
# Function:         Set-TempFolder
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Set all the temp environmental variables to c:\temp
#############################################
 
<#
.SYNOPSIS
Set all the temp environmental variables to c:\temp

.DESCRIPTION
Set all the temp environmental variables to c:\temp

.EXAMPLE
Set-TempFolder

#>
function Set-TempFolder {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-TempFolder')]
	PARAM()

	Write-Host 'Setting temp folder: ' -ForegroundColor Cyan -NoNewline

	$TempFolder = 'C:\TEMP'
	if (!(Test-Path $TempFolder)) {	New-Item -ItemType Directory -Force -Path $TempFolder }
	[Environment]::SetEnvironmentVariable('TEMP', $TempFolder, [EnvironmentVariableTarget]::Machine)
	[Environment]::SetEnvironmentVariable('TMP', $TempFolder, [EnvironmentVariableTarget]::Machine)
	[Environment]::SetEnvironmentVariable('TEMP', $TempFolder, [EnvironmentVariableTarget]::User)
	[Environment]::SetEnvironmentVariable('TMP', $TempFolder, [EnvironmentVariableTarget]::User)

	Write-Host 'Complete' -ForegroundColor Green
}
 
Export-ModuleMember -Function Set-TempFolder
#endregion
 
#region Set-VSCodeExplorerSortOrder.ps1
######## Function 72 of 95 ##################
# Function:         Set-VSCodeExplorerSortOrder
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/09 06:19:55
# Synopsis:         Change the sort order in VSCode explorer
#############################################
 
<#
.SYNOPSIS
Change the sort order in VSCode explorer

.DESCRIPTION
Change the sort order in VSCode explorer

.PARAMETER SetToDefault
Set it to default

.PARAMETER SetToModified
Set it to modified.

.EXAMPLE
Set-VSCodeExplorerSortOrder -SetToModified

#>
Function Set-VSCodeExplorerSortOrder {
	[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSToolKit/Set-VSCodeExplorerSortOrder')]
	[Alias('setcode')]
	PARAM(
		[switch]$SetToDefault,
		[switch]$SetToModified
	)

	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
		try {
			$CodePath = (Get-Process *code*)[0].CommandLine.split('--')[0].Replace('"', $null) | Get-Item -ErrorAction Stop
			if ($CodePath.Directory -notin $($env:Path.split(';'))) {$env:path += $CodePath.Directory}
			$settingsfile = Get-Item (Join-Path -Path $CodePath.DirectoryName -ChildPath '\data\user-data\User\settings.json') -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$CurrentSetting = Select-String -Path $settingsfile -Pattern '"explorer.sortOrder"'
		Write-PSToolKitMessage -Action 'Current' -Object 'Settings Set To:' -Message $CurrentSetting.Line.Trim()

		try {
			if ($SetToDefault) {(Get-Content -Path $settingsfile -Force -ErrorAction Stop) -replace '"explorer.sortOrder": "modified"', '"explorer.sortOrder": "default"' | Set-Content $settingsfile -Force -ErrorAction Stop}
			if ($SetToModified) {(Get-Content -Path $settingsfile -Force -ErrorAction Stop) -replace '"explorer.sortOrder": "default"', '"explorer.sortOrder": "modified"' | Set-Content $settingsfile -Force -ErrorAction Stop}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$NewSetting = Select-String -Path $settingsfile -Pattern '"explorer.sortOrder"'
		Write-PSToolKitMessage -Action 'New' -Object 'Settings Set To:' -Message $NewSetting.Line.Trim()

	}
} #end Function
 
Export-ModuleMember -Function Set-VSCodeExplorerSortOrder
#endregion
 
#region Set-WindowsAutoLogin.ps1
######## Function 73 of 95 ##################
# Function:         Set-WindowsAutoLogin
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Enable autologin on a device.
#############################################
 
<#
.SYNOPSIS
Enable autologin on a device.

.DESCRIPTION
Enable autologin on a device.

.PARAMETER ComputerName
The target computer name.

.PARAMETER Action
Disable or enable settings.

.PARAMETER LogonCredentials
Credentials to use.

.PARAMETER RestartHost
Restart device after change.

.EXAMPLE
Set-WindowsAutoLogin -ComputerName apollo.internal.lab -Action Enable -LogonCredentials $newcred -RestartHost

.NOTES
General notes
#>
Function Set-WindowsAutoLogin {
	[Cmdletbinding(DefaultParameterSetName = 'Disable', HelpURI = 'https://smitpi.github.io/PSToolKit/Set-WindowsAutoLogin')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript({ if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
				else { throw "Unable to connect to $($_)" } })]
		[string[]]$ComputerName,
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[ValidateSet('Enable', 'Disable')]
		[string]$Action,
		[Parameter(ParameterSetName = 'Enable')]
		[pscredential]$LogonCredentials,
		[Parameter(ParameterSetName = 'Enable')]
		[switch]$RestartHost = $false
	)


	foreach ($comp in $ComputerName) {
		try {
			if ($action -like 'Enable') {
				Write-Verbose "[$((Get-Date -Format HH:mm:ss).ToString())] [Testing] User and domain details"
				if ($LogonCredentials.UserName.Contains('\')) {
					$userdomain = $LogonCredentials.UserName.Split('\')[0]
					$username = $LogonCredentials.UserName.Split('\')[1]
				}
				elseif ($LogonCredentials.UserName.Contains('@')) {
					$userdomain = $LogonCredentials.UserName.Split('@')[1]
					$username = $LogonCredentials.UserName.Split('@')[0]
				}
				else {
					$userdomain = $ComputerName
					$username = $LogonCredentials.UserName
				}
				$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LogonCredentials.Password)
				$UserPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


				Write-Verbose "[$((Get-Date -Format HH:mm:ss).ToString())] [Testing] Adding credencials to local administrators "
				try {
					$checkmember = Invoke-Command -ComputerName $Comp -ScriptBlock { Get-LocalGroupMember -Group 'Administrators' -Member "$($using:userdomain)\$($using:username)" }
					if ($null -like $checkmember) {
						Invoke-Command -ComputerName $Comp -ScriptBlock { Add-LocalGroupMember -Group 'Administrators' -Member "$($using:userdomain)\$($using:username)" -ErrorAction Stop }
					}
				}
				catch { Throw 'Cant add account to the local admin groups' }

				$CheckCurrentSetting = Invoke-Command -ComputerName $Comp -ScriptBlock { Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon }
				if ($CheckCurrentSetting -eq '1') { Throw 'AutoLogin Already configured. Disable first and rerun.' }
				else {
					Invoke-Command -ComputerName $Comp -ScriptBlock {
						Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value $using:userdomain
						Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $using:username
						Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $using:UserPassword
						Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value '1'
					}
					Write-Color '[Set]', "AutoLogin on $($comp): ", 'Enabled' -Color Yellow, Cyan, Green
				}
			}
			if ($Action -like 'Diable') {
				Invoke-Command -ComputerName $Comp -ScriptBlock {
					Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value " "
					Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value ' '
					Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value ' '
					Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value '0'
				}

				Write-Color '[Set]', "AutoLogin on $($comp): ", 'Disabled' -Color Yellow, Cyan, Green
			}

			if ($RestartHost) {
				Write-Color '[Restarting] ', "Host:", " $($comp)" -Color Yellow, Cyan, Green
				Restart-Computer -ComputerName $Comp -Force
			}
		}
		catch { Write-Warning "[Set]Autologin: Failed on $($comp):`n $($_.Exception.Message)" }
	}
} #end Function
 
Export-ModuleMember -Function Set-WindowsAutoLogin
#endregion
 
#region Show-ComputerManagement.ps1
######## Function 74 of 95 ##################
# Function:         Show-ComputerManagement
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Opens the Computer Management of the system or remote system
#############################################
 
<#
.SYNOPSIS
Opens the Computer Management of the system or remote system

.DESCRIPTION
Opens the Computer Management of the system or remote system

.PARAMETER ComputerName
Computer to Manage

.EXAMPLE
Show-ComputerManagement -ComputerName neptune

#>
Function Show-ComputerManagement {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-ComputerManagement')]
                PARAM(
        			[ValidateScript({if (Test-Connection -ComputerName $_ -Count 2 -Quiet) {$true}
                            		else {throw "Unable to connect to $($_)"} })]
        			[string[]]$ComputerName = $env:ComputerName
					)
    compmgmt.msc /computer:$ComputerName
} #end Function
 
Export-ModuleMember -Function Show-ComputerManagement
#endregion
 
#region Show-PSToolKit.ps1
######## Function 75 of 95 ##################
# Function:         Show-PSToolKit
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/27 21:55:02
# Synopsis:         Show details of the commands in this module
#############################################
 
<#
.SYNOPSIS
Show details of the commands in this module

.DESCRIPTION
Show details of the commands in this module

.PARAMETER ShowMetaData
Show only version, date and path.

.PARAMETER ShowModified
Show new and modified functions.

.PARAMETER ShowCommand
Use the show-command command

.PARAMETER ExportToHTML
Create a HTML page with the details

.EXAMPLE
Show-PSToolKit

#>
Function Show-PSToolKit {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Show-PSToolKit')]
    PARAM(
        [switch]$ShowMetaData = $false,
        [switch]$ShowModified = $false,
        [switch]$ShowCommand = $false,
        [switch]$ExportToHTML = $false
    )

    Write-Color 'Collecting Command Details:' -Color DarkCyan -LinesBefore 1 -LinesAfter 1 -StartTab 1
    Remove-Module -Name PSToolKit -Force -ErrorAction SilentlyContinue
    $module = Get-Module -Name PSToolKit
    if (-not($module)) { $module = Get-Module -Name PSToolKit -ListAvailable }
    $latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
    [string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version
    [datetime]$CreateDate = (Get-Content -Path $($latestModule.Path.Replace('psm1', 'psd1')) | Where-Object { $_ -like '# Generated on: *' }).replace('# Generated on: ', '')
    $CreateDate = $CreateDate.ToUniversalTime()




    if ($ShowCommand) {
        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }
        $select = $commands | Select-Object Name, Description | Out-GridView -OutputMode Single
        Show-Command -Name $select.name
    }

    if ($ShowMetaData) {
        $Details = @()
        $Details = [PSCustomObject]@{
            Name    = 'PSToolKit'
            Object  = 'PowerShell Module'
            Version = $version
            Date    = (Get-Date($CreateDate) -Format F)
            Path    = $module.Path
        }
        $Details
    }

    if ($ShowModified) {
        $ModulePSM = Get-Item (Join-Path $latestModule.ModuleBase -ChildPath $latestModule.RootModule)
        $PSMContent = Get-Content $ModulePSM.FullName
        [System.Collections.ArrayList]$FunctionObject = @()    
        Select-String -Path $ModulePSM.FullName -Pattern '^# Function:*' | ForEach-Object {
            [void]$FunctionObject.Add([PSCustomObject]@{
                    Function   = ($PSMContent)[$_.LineNumber - 1].Replace('# Function:', '').Trim()
                    # ModuleVersion = ($PSMContent)[$_.LineNumber + 1].Replace('# ModuleVersion:', '').Trim()
                    # CreatedOn     = [datetime]($PSMContent)[$_.LineNumber + 4].Replace('# CreatedOn:', '').Trim()
                    ModifiedOn = [datetime]($PSMContent)[$_.LineNumber + 5].Replace('# ModifiedOn:', '').Trim()
                    Synopsis   = ($PSMContent)[$_.LineNumber + 6].Replace('# Synopsis:', '').Trim()
                })
        }
        $modweek = $FunctionObject | Where-Object { $_.ModifiedOn -gt (Get-Date).AddDays(-7) } | Sort-Object -Property ModifiedOn -Descending 
        $modMonth = $FunctionObject | Where-Object { $_.ModifiedOn -gt (Get-Date).AddMonths(-1) } | Sort-Object -Property ModifiedOn -Descending

        $Details = @()
        $Details = [PSCustomObject]@{
            Name    = 'PSToolKit'
            Object  = 'PowerShell Module'
            Version = $version
            Date    = (Get-Date($CreateDate) -Format F)
            Path    = $module.Path
        }
        $Details
        Write-Color 'Modified in the last week' -Color Cyan -StartTab 2
        $modweek | Format-Table
        Write-Color 'Modified in the last Month' -Color Cyan -StartTab 2
        $modMonth | Format-Table
    }

    if (-not($ShowCommand) -and (-not($ShowMetaData)) -and (-not($ExportToHTML)) -and (-not($ShowModified))) {

        # $out = ConvertTo-ASCIIArt -Text 'PSToolKit' -Font basic
        # $out += "`n"
        # $out += ConvertTo-ASCIIArt -Text $version -Font basic
        # $out += "`n"
        # $out += ("Module Path: $($module.Path)" | Out-String)
        # $out += ("Created on: $(Get-Date($CreateDate) -Format F)" | Out-String)
        # Add-Border -TextBlock $out -Character % -ANSIBorder "$([char]0x1b)[38;5;47m" -ANSIText "$([char]0x1b)[93m"

        $out = (Write-Ascii 'PSToolKit' -ForegroundColor Yellow | Out-String)
        $out += "`n"
        $out += (Write-Ascii $($version) -ForegroundColor Yellow)
        $out += "`n"
        $out += ("Module Path: $($module.Path)" | Out-String)
        $out += ("Created on: $(Get-Date($CreateDate) -Format F)" | Out-String)
        $out
        #Add-Border -TextBlock $out -Character % -ANSIBorder "$([char]0x1b)[38;5;47m" -ANSIText "$([char]0x1b)[93m"

        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }

        foreach ($item in ($commands.verb | Sort-Object -Unique)) {
            Write-Color 'Verb:', $item -Color Cyan, Red -StartTab 1 -LinesBefore 1
            $filtered = $commands | Where-Object { $_.Verb -like $item }
            foreach ($filter in $filtered) {
                Write-Color "$($filter.name)", ' - ', $($filter.Description) -Color Gray, Red, Yellow

            }
        }
    }

    if ($ExportToHTML) {
        $commands = @()
        $commands = Get-Command -Module PSToolKit | ForEach-Object {
            [pscustomobject]@{
                CmdletBinding       = $_.CmdletBinding
                CommandType         = $_.CommandType
                DefaultParameterSet = $_.DefaultParameterSet
                #Definition          = $_.Definition
                Description         = ((Get-Help $_.Name).SYNOPSIS | Out-String).Trim()
                HelpFile            = $_.HelpFile
                Module              = $_.Module
                ModuleName          = $_.ModuleName
                Name                = $_.Name
                Noun                = $_.Noun
                Options             = $_.Options
                OutputType          = $_.OutputType
                Parameters          = $_.Parameters
                ParameterSets       = $_.ParameterSets
                RemotingCapability  = $_.RemotingCapability
                #ScriptBlock         = $_.ScriptBlock
                Source              = $_.Source
                Verb                = $_.Verb
                Version             = $_.Version
                Visibility          = $_.Visibility
                HelpUri             = $_.HelpUri
            }
        }

        #region html settings
        $SectionSettings = @{
            HeaderTextSize        = '16'
            HeaderTextAlignment   = 'center'
            HeaderBackGroundColor = '#00203F'
            HeaderTextColor       = '#ADEFD1'
            backgroundColor       = 'lightgrey'
            CanCollapse           = $true
        }
        $ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'
        #endregion

        New-HTML -Online -Temporary -ShowHTML {
            New-HTMLHeader {
                New-HTMLLogo -RightLogoString $ImageLink
                New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment right -Text "Date Collected: $(Get-Date)"
            }
            foreach ($item in ($commands.verb | Sort-Object -Unique)) {
                $filtered = $commands | Where-Object { $_.Verb -like $item }
                New-HTMLSection -HeaderText "$($item)" @SectionSettings -Width 50% -AlignContent center -AlignItems center -Collapsed {
                    New-HTMLPanel -Content {
                        $filtered | ForEach-Object { New-HTMLSection -Invisible -Content {
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.name)" -Color BlackRussian -FontSize 18 -Alignment right }
                                New-HTMLPanel -BackgroundColor GhostWhite -Content { New-HTMLText -Text "$($_.description) [More]($($_.HelpUri))" -Color FreeSpeechRed -FontSize 16 -Alignment left }
                            }
                        }
                    }
                }
            }
        }
    }
} #end Function
 
Export-ModuleMember -Function Show-PSToolKit
#endregion
 
#region Start-PowerShellAsAdmin.ps1
######## Function 76 of 95 ##################
# Function:         Start-PowerShellAsAdmin
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/06 00:24:59
# Synopsis:         Starts a porwershell session as an administrator
#############################################
 
<#
.SYNOPSIS
Starts a porwershell session as an administrator

.DESCRIPTION
Starts a porwershell session as an administrator

.PARAMETER WindowsPowerShell
Start powershell 5.1 session. Default is a Powershell 7 session.

.PARAMETER ISE
Start a powershell ISE session.

.PARAMETER Credential
Run session as a different user.

.EXAMPLE
An example

.NOTES
General notes
#>
Function Start-PowerShellAsAdmin {
	[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PowerShellAsAdmin')]
	[OutputType([void])]
	PARAM(
		[switch]$WindowsPowerShell,
		[switch]$ISE,
		[pscredential]$Credential
	)

	$Currentdir = Get-Location
	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
		if ($WindowsPowerShell) {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath powershell.exe -ArgumentList "-noexit -command & {set-location $($currentdir)}" -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath powershell.exe -ArgumentList "-command & {Start-Process -FilePath powershell.exe -ArgumentList `"-noexit`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		} elseif ($ISE) {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe' -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath powershell.exe -ArgumentList "-command & {Start-Process -FilePath `"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		} else {
			if ([string]::IsNullOrEmpty($Credential)) {
				Start-Process -FilePath pwsh.exe -ArgumentList "-noexit -command & {set-location $($currentdir)}" -WorkingDirectory $Currentdir -Verb RunAs
			} else {
				Start-Process -FilePath pwsh.exe -ArgumentList "-command & {Start-Process -FilePath pwsh.exe -ArgumentList `"-noexit`" -Verb RunAs }" -Credential $Credential -WorkingDirectory $currentdir -WindowStyle Hidden
			}
		}
	}
} #end Function
 
Export-ModuleMember -Function Start-PowerShellAsAdmin
#endregion
 
#region Start-PSModuleMaintenance.ps1
######## Function 77 of 95 ##################
# Function:         Start-PSModuleMaintenance
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.
#############################################
 
<#
.SYNOPSIS
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

.DESCRIPTION
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

.PARAMETER ListUpdateAvailable
Filter to show only the modules with update available.

.PARAMETER PerformUpdate
Performs the update-module function on modules with updates available.

.PARAMETER RemoveDuplicates
Checks if a module is installed in more than one location, and reinstall it the all users profile.

.PARAMETER RemoveOldVersions
Delete the old versions of existing modules.

.PARAMETER ForceRemove
If unable to remove, then the directory will be deleted.

.EXAMPLE
Start-PSModuleMaintenance -ListUpdateAvailable -PerformUpdate

#>
Function Start-PSModuleMaintenance {
	[Cmdletbinding(DefaultParameterSetName = 'Update', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSModuleMaintenance')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'Update')]
		[switch]$ListUpdateAvailable = $false,
		[Parameter(ParameterSetName = 'Update')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$PerformUpdate = $false,
		[Parameter(ParameterSetName = 'Duplicate')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$RemoveDuplicates = $false,
		[Parameter(ParameterSetName = 'Remove')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$RemoveOldVersions = $false,
		[Parameter(ParameterSetName = 'Remove')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt to use function' } })]
		[switch]$ForceRemove = $false
	)

	if (-not ($RemoveOldVersions) -and (-not $RemoveDuplicates)) {
		$index = 0
		[System.Collections.ArrayList]$moduleReport = @()
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }
		Write-Host 'Collecting Online Modules, this might take some time' -ForegroundColor Cyan
		$AllOnlineModules = Find-Module *
		foreach ($SingleModule in $InstalledModules) {
			$index++
			Write-Host "Checking Module $index of"$InstalledModules.count -NoNewline -ForegroundColor Green; Write-Host ' '$SingleModule.Name -ForegroundColor Yellow
			try {
				$OnlineModule = $AllOnlineModules | Where-Object { $_.name -like $SingleModule.Name }
				if ($SingleModule.Version -lt $OnlineModule.Version) { $ModuleUpdate = 'UpdateAvailable' }
				else { $ModuleUpdate = 'NoUpdate' }
			} catch { $OnlineModule = $null }
			[void]$moduleReport.Add([pscustomobject]@{
					Name                 = $SingleModule.Name
					Description          = $SingleModule.Description
					InstalledVersion     = $SingleModule.Version
					Functions            = $OnlineModule.AdditionalMetadata.Functions
					lastUpdated          = $OnlineModule.AdditionalMetadata.lastUpdated
					downloadCount        = $OnlineModule.AdditionalMetadata.downloadCount
					versionDownloadCount = $OnlineModule.AdditionalMetadata.versionDownloadCount
					OnlineVersion        = $OnlineModule.Version
					OnlineLastUpdated    = $OnlineModule.AdditionalMetadata.lastUpdated
					Update               = $ModuleUpdate
					InstalledPath        = $SingleModule.InstalledLocation
				})
		}

		if ($ListUpdateAvailable) {return $moduleReport | Where-Object { $_.Update -like 'UpdateAvailable' } }
		if ($PerformUpdate) {
			$moduleReport | Where-Object { $_.Update -like 'UpdateAvailable' } | ForEach-Object {
				Write-Color 'Performing update on: ', $_.name -Color Green, Yellow
				Update-Module -Name $_.name -Force }
		}
		if (-not($ListUpdateAvailable) -and (-not($PerformUpdate))) { return $moduleReport }
	}
	if ($RemoveOldVersions) {
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }
		foreach ($SingleModule in $InstalledModules) {
			$CheckOldMod = $null
			$CheckOldMod = Get-Module $SingleModule.Name
			if ($null -eq $CheckOldMod) { $CheckOldMod = Get-Module $SingleModule.Name -ListAvailable }
			if ($CheckOldMod.count -gt 1) {
				$TopVersion = $CheckOldMod | Sort-Object -Property version -Descending | Select-Object -First 1
				foreach ($removemod in ($CheckOldMod | Where-Object { $_.Version -lt $TopVersion.Version } )) {
					try {
						Remove-Module -Name $removemod.Name -Force -ErrorAction SilentlyContinue
						Write-Color "[$($removemod.name)]", "[$(((Get-Item $removemod.Path).Directory).Parent.FullName)]", ' Removing ', $removemod.Version -Color Yellow, DarkCyan, Red, DarkYellow
						Get-InstalledModule -Name $removemod.Name -RequiredVersion $removemod.Version | Uninstall-Module -Force -ErrorAction Stop
					} catch {
						Write-Warning "Unable to uninstall $($removemod.name):`n $($_.Exception.Message)"
						if ($ForceRemove) {
							try {
								Write-Color "[$($removemod.name)]", "[$(((Get-Item $removemod.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
								Remove-Item -Path (Get-Item $removemod.Path).Directory -Recurse -Force
							} catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
						}
					}
				}
			}
		}
	}
	if ($RemoveDuplicates) {
		[System.Collections.ArrayList]$duplicates = @()
		$InstalledModules = Get-InstalledModule | Where-Object { $_.Repository -like 'PSGallery' }

		foreach ($SingleModule in $InstalledModules) {
			$DupMod = $null
			$DupMod = Get-Module $SingleModule.Name
			if ($null -eq $DupMod) { $DupMod = Get-Module $SingleModule.Name -ListAvailable }
			if ($DupMod.path.count -gt 1) {
				$DupMod | ForEach-Object {
					[void]$duplicates.Add($_)
				}
			}
		}

		foreach ($dup in $duplicates) {
			try {
				Write-Color "[$($dup.name)]", " - $($dup.path)", 'Remove Duplicate' -Color Yellow, DarkCyan, Red
				Remove-Module $dup.name -Force -ErrorAction SilentlyContinue
				Get-InstalledModule -Name $dup.name -RequiredVersion $dup.Version -ErrorAction SilentlyContinue | Uninstall-Module -Force -ErrorAction Stop
			} catch { Write-Warning "Unable to remove:`n $($_.Exception.Message)" }
			try {
				if (Test-Path (Get-Item $dup.Path).Directory) {
					Write-Color "[$($dup.name)]", "[$(((Get-Item $dup.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
					Remove-Item -Path ((Get-Item $dup.Path).Directory).FullName -Recurse -Force -ErrorAction Stop
				}
			} catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
		}

		Write-Color 'Reinstall Module:' -Color Cyan
		$duplicates.name | Sort-Object -Unique | ForEach-Object {
			try {
				Write-Color "[$($_)]" -Color Yellow
				Install-Module -Name $_ -Scope AllUsers -AllowClobber -Force -ErrorAction Stop
			} catch { Write-Warning "Unable to install from:`n $($_.Exception.Message)" }
		}
	}
} #end Function
 
Export-ModuleMember -Function Start-PSModuleMaintenance
#endregion
 
#region Start-PSProfile.ps1
######## Function 78 of 95 ##################
# Function:         Start-PSProfile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/09 06:40:00
# Synopsis:         My PS Profile for all sessions.
#############################################
 
<#
.SYNOPSIS
My PS Profile for all sessions.

.DESCRIPTION
My PS Profile for all sessions.

.PARAMETER ClearHost
Clear the screen before loading.

.PARAMETER ShowModuleList
Summary of installed modules.

.EXAMPLE
Start-PSProfile -ClearHost

#>
Function Start-PSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSProfile')]
	PARAM(
		[switch]$ClearHost = $false,
		[switch]$ShowModuleList = $false
	)
	$ErrorActionPreference = 'Stop'

	if ($ClearHost) { Clear-Host }

	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$Global:psfolder = Get-Item (Get-Item $profile).DirectoryName
	} else { $Global:psfolder = Get-Item (Get-Item $profile).DirectoryName }

	function proxyconnect {
		$wc = New-Object System.Net.WebClient
		$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	}
	proxyconnect

	try {
		## Create folders for PowerShell profile
		if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory | Out-Null }
	} catch { Write-Warning 'Unable to create default folders' }

	try {
		Set-Location $psfolder -ErrorAction Stop
	} catch { Write-Warning 'Unable to set location' }

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,23} ' -f 'Loading Functions') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	try {
		$PSReadLineSplat = @{
			PredictionSource              = 'HistoryAndPlugin'
			PredictionViewStyle           = 'InlineView'
			HistorySearchCursorMovesToEnd = $true
			HistorySaveStyle              = 'SaveIncrementally'
			ShowToolTips                  = $true
			BellStyle                     = 'Visual'
			HistorySavePath               = "$([environment]::GetFolderPath('ApplicationData'))\Microsoft\Windows\PowerShell\PSReadLine\history.txt"
		}
		Set-PSReadLineOption @PSReadLineSplat -ErrorAction Stop
		Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch {
		try {
			Set-PSReadLineOption @PSReadLineSplat -PredictionSource history -PredictionViewStyle InlineView
			Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
			Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
			Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
			Write-Host ('[Alternative]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'PSReadLineOptions: Could not be loaded' }
	}

	try {
		$chocofunctions = Get-Item "$env:ChocolateyInstall\helpers\functions" -ErrorAction Stop
		$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
		Import-Module "$ChocolateyProfile" -ErrorAction Stop
		Get-ChildItem $chocofunctions | ForEach-Object { . $_.FullName }
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Chocolatey Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-21}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'Chocolatey: Could not be loaded' }

 try {
		Add-PSSnapin citrix*
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'Citrix SnapIns') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'Citrix SnapIns: Could not be loaded' }

	$ErrorActionPreference = 'Continue'
	## Some Session Information
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,20} ' -f 'PowerShell Info') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'Computer Name') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($env:COMPUTERNAME) ($(([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName))") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Execution Policy') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$(Get-ExecutionPolicy -Scope LocalMachine)") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Edition') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($PSVersionTable.PSEdition) (Ver: $($PSVersionTable.PSVersion.ToString()))") -ForegroundColor Green

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'PowerShell Profile Folder') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($psfolder)") -ForegroundColor Green

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,20} ' -f 'Session Detail') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,-35}: ' -f 'For User:') -ForegroundColor Cyan -NoNewline
	Write-Host ('{0,-20}' -f "$($env:USERDOMAIN)\$($env:USERNAME) ($($env:USERNAME)@$($env:USERDNSDOMAIN))") -ForegroundColor Green
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ' '


 if ($ShowModuleList) {
		[string[]]$Modpaths = ($env:PSModulePath).Split(';')
		$AvailableModules = Get-Module -ListAvailable
		[System.Collections.ArrayList]$ModuleDetails = @()
		$ModuleDetails = $Modpaths | ForEach-Object {
			$Mpath = $_
			[pscustomobject]@{
				Location = $Mpath
				Modules  = ($AvailableModules | Where-Object { $_.path -match $Mpath.replace('\', '\\') } ).count
			}
		}
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,25} ' -f 'Module Paths Details') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "$(($ModuleDetails | Sort-Object -Property modules -Descending | Out-String))" -ForegroundColor Green
	}


	if ($(Get-Date).DayOfWeek -like 'Monday') {
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'Updating Local Help, For details Run:') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "`$Localhelpjob | Wait-Job | Receive-Job" -ForegroundColor Green
		$Localhelpjob = Update-LocalHelp
	}

} #end Function
 
Export-ModuleMember -Function Start-PSProfile
#endregion
 
#region Start-PSRoboCopy.ps1
######## Function 79 of 95 ##################
# Function:         Start-PSRoboCopy
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/27 11:28:43
# Synopsis:         My wrapper for default robocopy switches
#############################################
 
<#
.SYNOPSIS
My wrapper for default robocopy switches

.DESCRIPTION
My wrapper for default robocopy switches

.PARAMETER Source
Folder to copy.

.PARAMETER Destination
Where it will be copied.

.PARAMETER Action
3 choices. Copy files and folders, Move files and folders or mirror the folders (Destination files will be overwritten)

.PARAMETER IncludeFiles
Only copy these files

.PARAMETER eXcludeFiles
Exclude these files (can use wildcards)

.PARAMETER eXcludeDirs
Exclude these folders (can use wildcards)

.PARAMETER TestOnly
Don't do any changes, see which files has changed.

.PARAMETER LogPath
Where to save the log. If the log file exists, it will be appended.

.EXAMPLE
Start-PSRoboCopy -Source C:\Utils\LabTools -Destination P:\Utils\LabTools2 -Action copy -eXcludeFiles *.git

#>
Function Start-PSRoboCopy {
        [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSRoboCopy')]
        PARAM(
                [Parameter(Mandatory = $true)]
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { trow "Source: $($_) does not exist." }
                        })]
                [System.IO.DirectoryInfo]$Source,
                [Parameter(Mandatory = $true)]
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [System.IO.DirectoryInfo]$Destination,
                [Parameter(Mandatory = $true)]
                [ValidateSet('Copy', 'Move', 'Mirror')]
                [string]$Action,
                [string[]]$IncludeFiles,
                [string[]]$eXcludeFiles,
                [string[]]$eXcludeDirs,
                [switch]$TestOnly,
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [System.IO.DirectoryInfo]$LogPath = 'C:\Temp'
        )

        [System.Collections.ArrayList]$RoboArgs = @()
        $RoboArgs.Add($($Source))
        $RoboArgs.Add($($Destination))
        if ($null -notlike $IncludeFiles) {
                $IncludeFiles | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }
        if ($null -notlike $eXcludeFiles) {
                $RoboArgs.Add('/XF')
                $eXcludeFiles | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }

        if ($null -notlike $eXcludeDirs) {
                $RoboArgs.Add('/XD')
                $eXcludeDirs | ForEach-Object { $RoboArgs.Add("`"$_`"") }
        }

        [void]$RoboArgs.Add('/W:0')
        [void]$RoboArgs.Add('/R:0')
        #[void]$RoboArgs.Add('/COPYALL')
        #[void]$RoboArgs.Add('/NJS')
        #[void]$RoboArgs.Add('/NJH')
        [void]$RoboArgs.Add('/NP')
        [void]$RoboArgs.Add('/NDL')
        [void]$RoboArgs.Add('/TEE')
        [void]$RoboArgs.Add('/MT:64')

        switch ($Action) {
                'Copy' { [void]$RoboArgs.Add('/E') }

                'Move' {
                        [void]$RoboArgs.Add('/E')
                        [void]$RoboArgs.Add('/MOVE')
                }

                'Mirror' { [void]$RoboArgs.Add('/MIR') }
        }
        if ($TestOnly) { [void]$RoboArgs.Add('/L') }

        $Logfile = Join-Path $LogPath -ChildPath "RoboCopyLog_Week_$(Get-Date -UFormat %V).log"
        [void]$RoboArgs.Add("/LOG+:$($Logfile)")

        & robocopy $RoboArgs

} #end Function
 
Export-ModuleMember -Function Start-PSRoboCopy
#endregion
 
#region Start-PSScriptAnalyzer.ps1
######## Function 80 of 95 ##################
# Function:         Start-PSScriptAnalyzer
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/29 23:50:20
# Synopsis:         Run and report ScriptAnalyzer output
#############################################
 
<#
.SYNOPSIS
Run and report ScriptAnalyzer output

.DESCRIPTION
Run and report ScriptAnalyzer output

.PARAMETER Paths
Path to ps1 files

.PARAMETER ExcludeDefault
Will exclude these rules: PSAvoidTrailingWhitespace,PSUseShouldProcessForStateChangingFunctions,PSAvoidUsingWriteHost,PSUseSingularNouns

.PARAMETER ExcludeRules
Exclude rules from report. Specify your own list.

.PARAMETER Export
Export results

.PARAMETER ReportPath
Where to export to.

.EXAMPLE
Start-PSScriptAnalyzer -Path C:\temp

#>
Function Start-PSScriptAnalyzer {
	[Cmdletbinding(DefaultParameterSetName = 'ExDef', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSScriptAnalyzer')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = 'ExDef')]
		[Parameter(ParameterSetName = 'ExCus')]
		[ValidateScript( { if (Test-Path $_) { $true }
				else {throw 'Not a valid path'}
				$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$True}
				else {Throw 'Must be running an elevated prompt'}})]
		[System.IO.DirectoryInfo[]]$Paths,

		[Parameter(ParameterSetName = 'ExCus')]
		[String[]]$ExcludeRules,

		[Parameter(ParameterSetName = 'ExDef')]
		[switch]$ExcludeDefault = $false,

		[Parameter(ParameterSetName = 'ExDef')]
		[Parameter(ParameterSetName = 'ExCus')]
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(ParameterSetName = 'ExDef')]
		[Parameter(ParameterSetName = 'ExCus')]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	if ($ExcludeDefault) {
		$ExcludeRules = @(
			'PSAvoidTrailingWhitespace',
			'PSUseShouldProcessForStateChangingFunctions',
			'PSAvoidUsingWriteHost',
			'PSUseSingularNouns'
		)
	}

	[System.Collections.ArrayList]$ScriptAnalyzerIssues = @()
	foreach ($path in $paths) {
		$Listissues = $null
		Write-Color '[Starting]', 'PSScriptAnalyzer', ' on ', "$($path)" -Color Yellow, Cyan, Green, Cyan -LinesBefore 2 -LinesAfter 1
		if ($ExcludeRules -like $null) {
			Get-ChildItem -Path "$($path)\*.ps1" -Recurse | ForEach-Object {
				Write-Color '[Processing]', " $($_.Name)" -Color Yellow, Cyan
				Invoke-ScriptAnalyzer -Path $_.FullName -IncludeDefaultRules -Severity Information, warning, error -Fix -OutVariable tmp | Out-Null
				$Listissues = $Listissues + $tmp
			}
		} else {
			Get-ChildItem -Path "$($path)\*.ps1" -Recurse | ForEach-Object {
				Write-Color '[Processing]', " $($_.Name)" -Color Yellow, Cyan
				Invoke-ScriptAnalyzer -Path $_.FullName -IncludeDefaultRules -Severity Information, warning, error -Fix -OutVariable tmp -ExcludeRule $ExcludeRules | Out-Null
				$Listissues = $Listissues + $tmp
			}
		}

		foreach ($item in $Listissues) {
			[void]$ScriptAnalyzerIssues.Add([PSCustomObject]@{
					File     = $item.scriptname
					RuleName = $item.RuleName
					line     = $item.line
					Message  = $item.Message
				})
		}
	}

	if ($Export -eq 'Excel') { $ScriptAnalyzerIssues | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ScriptAnalyzer -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PivotTableName Summery -PivotRows RuleName -PivotData Message}
	if ($Export -eq 'HTML') {
		$SectionSettings = @{
			HeaderTextSize        = '16'
			HeaderTextAlignment   = 'center'
			HeaderBackGroundColor = '#00203F'
			HeaderTextColor       = '#ADEFD1'
			backgroundColor       = 'lightgrey'
			CanCollapse           = $true
		}
		$TableSettings = @{
			SearchHighlight = $True
			AutoSize        = $true
			Style           = 'cell-border'
			ScrollX         = $true
			HideButtons     = $true
			HideFooter      = $true
			FixedHeader     = $true
			TextWhenNoData  = 'No Data to display here'
			DisableSearch   = $true
			ScrollCollapse  = $true
			ScrollY         = $true
			DisablePaging   = $true
			PagingLength    = '10'
		}
		$ImageLink = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome-black-1.png'

		New-HTML -FilePath $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") -Title 'PSScriptAnalyzer' -ShowHTML {
			New-HTMLHeader {
				New-HTMLLogo -RightLogoString $ImageLink
				New-HTMLText -FontSize 14 -FontStyle normal -TextTransform capitalize -Color AirForceBlue -Alignment right -Text "Date Collected: $(Get-Date)"
			}
			foreach ($item in ($ScriptAnalyzerIssues.RuleName | Sort-Object -Unique)) {
				$filtered = $ScriptAnalyzerIssues | Where-Object { $_.RuleName -like $item }
				New-HTMLSection -HeaderText "$($item) [ $($filtered.Count) ]" @SectionSettings -Collapsed { New-HTMLTable -DataTable $filtered @TableSettings	}
			}
		}
		$fragments = [system.collections.generic.list[string]]::new()
		$fragments.Add((New-MDHeader 'PSScriptAnalyzer Results'))
		$Fragments.Add("---`n")
		$fragments.Add((New-MDTable -Object $ScriptAnalyzerIssues))
		$Fragments.Add("---`n")
		$fragments.add("*Updated: $(Get-Date -Format U) UTC*")
		$fragments | Out-File -FilePath $(Join-Path -Path $ReportPath -ChildPath "\PSScriptAnalyzer-$(Get-Date -Format yyyy.MM.dd-HH.mm).md") -Encoding utf8 -Force
	}
	if ($Export -eq 'Host') { $ScriptAnalyzerIssues }

} #end Function
 
Export-ModuleMember -Function Start-PSScriptAnalyzer
#endregion
 
#region Start-PSToolkitSystemInitialize.ps1
######## Function 81 of 95 ##################
# Function:         Start-PSToolkitSystemInitialize
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/31 19:50:18
# Synopsis:         Initialize a blank machine.
#############################################
 
<#
.SYNOPSIS
Initialize a blank machine.

.DESCRIPTION
Initialize a blank machine with PSToolKit tools and dependencies.

.PARAMETER LabSetup
Commands only for my HomeLab

.PARAMETER PendingReboot
Will reboot the device if it is needed.

.PARAMETER InstallMyModules
Install my other published modules.

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false,
		[switch]$PendingReboot = $false
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Script Execution' -ForegroundColor Cyan
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Powershell Gallery' -ForegroundColor Cyan
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted' ) {
		$null = Install-PackageProvider Nuget -Force
		$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
		$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	}
	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Needed Powershell modules' -ForegroundColor Cyan

	'ImportExcel', 'PSWriteHTML', 'PSWriteColor', 'PSScriptTools', 'PoshRegistry', 'Microsoft.PowerShell.Archive','PWSHModule' | ForEach-Object {
		$module = $_
		if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
			try {
				Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
				Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
			} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
		}
	}

	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'PSToolKit Module' -ForegroundColor Cyan
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-MyModulesFromGitHub.ps1', "$($env:TEMP)\Update-MyModulesFromGitHub.ps1")
	$full = Get-Item "$($env:TEMP)\Update-MyModulesFromGitHub.ps1"
	Import-Module $full.FullName -Force
	Update-MyModulesFromGitHub -Modules PSToolkit -AllUsers
	Remove-Item $full.FullName

	Import-Module PSToolKit -Force
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Installing My Modules' -ForegroundColor Cyan
		'CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray','PWSHModule' | ForEach-Object {
			$module = $_
			Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
			if (-not(Get-Module $module) -and -not(Get-Module $module -ListAvailable)) {
				try {
					Write-Host "`t[Installing]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
					Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
				} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
			} else {
				$LocalMod = Get-Module $module
				if (-not($LocalMod)) {$LocalMod = Get-Module $module -ListAvailable}
				if (($LocalMod[0].Version) -lt (Find-Module $module).Version) {
					try {
						Write-Host "`t`t[Upgrading]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($module)" -ForegroundColor Cyan
						Update-Module -Name $module -Force -Scope AllUsers
					} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
				}
			}
		}
	}

	if ($LabSetup) {
		New-PSProfile
		Update-PSToolKitConfigFile -UpdateLocal -UpdateLocalFromModule
		Reset-PSGallery -Force
		Set-PSToolKitSystemSetting -RunAll
		Install-PWSHModule -GitHubUserID smitpi -PublicGist -ListName base -Scope AllUsers
		Install-ChocolateyClient
		Install-VMWareTool
		Install-PowerShell7x
		Install-ChocolateyApp -BaseApps
		Install-RSAT
		Install-MSUpdate
	}

	if ($PendingReboot) {
		Write-Host '[Checking]: ' -NoNewline -ForegroundColor Yellow; Write-Host "Pending Reboot for $($env:COMPUTERNAME)" -ForegroundColor Cyan
		if ((Test-PendingReboot -ComputerName $env:COMPUTERNAME).IsPendingReboot -like 'True') {
			Write-Host "`t[Reboot Needed]: " -NoNewline -ForegroundColor Yellow; Write-Host 'Rebooting in 60 sec' -ForegroundColor DarkRed
			Start-Sleep 60
			Restart-Computer -Force
		} else {
			Write-Host '[Reboot]: ' -NoNewline -ForegroundColor Yellow; Write-Host 'Not Necessary, continuing' -ForegroundColor Cyan
		}
	}

	Write-Host '[Complete] ' -NoNewline -ForegroundColor Yellow; Write-Host 'System Initialization' -ForegroundColor DarkRed
} #end Function
 
Export-ModuleMember -Function Start-PSToolkitSystemInitialize
#endregion
 
#region Test-CitrixCloudConnector.ps1
######## Function 82 of 95 ##################
# Function:         Test-CitrixCloudConnector
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/21 05:38:07
# Synopsis:         Perform basic connection tests to Citrix cloud.
#############################################
 
<#
.SYNOPSIS
Perform basic connection tests to Citrix cloud.

.DESCRIPTION
Perform basic connection tests to Citrix cloud.

.PARAMETER CustomerID
get from Citrix cloud.

.PARAMETER Export
Export the results

.PARAMETER ReportPath
Where report will be saved.

.EXAMPLE
Test-CitrixCloudConnector -CustomerID yourID

#>
Function Test-CitrixCloudConnector {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Test-CitrixCloudConnector')]
	PARAM(
		[string]$CustomerID,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
	)

	Write-Color 'Checking if needed CA certificates are installed.' -Color DarkCyan
	$online_root = '0563B8630D62D75ABBC8AB1E4BDFB5A899B24D43'
	$online_inter = '92C1588E85AF2201CE7915E8538B492F605B80C6'
	$root = Get-ChildItem -Path Cert:\LocalMachine\Root
	$Inter = Get-ChildItem -Path Cert:\LocalMachine\CA

	if ($online_root -notin $root.Thumbprint) {
		Write-Color 'Installing: ', 'DigiCertAssuredIDRootCA' -Color Cyan, Yellow -NoNewLine
		$rootca = 'c:\temp\DigiCert-rootca.crt'
		Invoke-WebRequest -Uri https://dl.cacerts.digicert.com/DigiCertAssuredIDRootCA.crt -OutFile $rootca | Out-Null
		Import-Certificate -FilePath $rootca -CertStoreLocation Cert:\LocalMachine\root\ | Out-Null
		Write-Color ' - Complete' -Color Green
	}
	if ($online_inter -notin $Inter.Thumbprint) {
		Write-Color 'Installing: ', 'DigiCertSHA2AssuredIDCodeSigningCA' -Color Cyan, Yellow -NoNewLine
		$ca_l1 = 'c:\temp\DigiCert-L1.crt'
		Invoke-WebRequest -Uri https://dl.cacerts.digicert.com/DigiCertSHA2AssuredIDCodeSigningCA.crt -OutFile $ca_l1
		Import-Certificate -FilePath $ca_l1 -CertStoreLocation Cert:\LocalMachine\CA | Out-Null
		Write-Color 'Complete' -Color Green
	}
	Write-Color 'Fetching url list from Citrix'

	$uri = 'https://fqdnallowlistsa.blob.core.windows.net/fqdnallowlist-commercial/allowlist.json'
	$siteList = Invoke-RestMethod -Uri $uri

	$members = $siteList | Get-Member -MemberType NoteProperty
	foreach ($item in $members) {
		Write-Color 'Checking Service:', $($item.Name) -Color Cyan, Yellow -LinesBefore 2
		Write-Color 'Last Change: ' -Color Yellow
		$siteList.$($item.Name).LatestChangeLog
		Write-Color 'Checking AllowList:'

		$list = $($siteList.$($item.Name).AllowList)
		foreach ($single in $list ) {
			Write-Color 'Checking - ', $($single) -Color Cyan, Yellow
			try {
				if ($single -like '<CUSTOMER_ID>*') { $single = $single.replace('<CUSTOMER_ID>', $($CustomerID)) }
				$Response = Invoke-WebRequest -Uri "https://$($single)"
				$StatusCode = $Response.StatusCode
				$StatusMessage = $Response.StatusDescription
			}
			catch {
				$StatusMessage = $_.Exception.Message
				$StatusCode = $_.Exception.Response.StatusCode.value__
			}
			$Fdata += @(
				[PSCustomObject]@{
					Service       = $($item.Name)
					Site          = $single
					statusCode    = $StatusCode
					StatusMessage = $StatusMessage
				}
			)
		}
	}

	if ($Export -eq 'Excel') { $fdata | Export-Excel -Path ($ReportPath + '\ConnectorUrl-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $fdata | Out-HtmlView -DisablePaging -Title 'ConnectorUrl-' -HideFooter -SearchHighlight -FixedHeader }
	if ($Export -eq 'Host') { $fdata }

} #end Function
 
Export-ModuleMember -Function Test-CitrixCloudConnector
#endregion
 
#region Test-CitrixVDAPort.ps1
######## Function 83 of 95 ##################
# Function:         Test-CitrixVDAPort
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/06/21 05:39:47
# Synopsis:         Test connection between DDC and VDI
#############################################
 
<#
.SYNOPSIS
 Test connection between DDC and VDI

.DESCRIPTION
 Test connection between DDC and VDI, you can also specify other ports.

.PARAMETER ServerList
List servers to test

.PARAMETER PortsList
List of ports to test, by default the citrix ports are selected.

.PARAMETER Export
Export the results.

.PARAMETER ReportPath
Where report will be saves.

.EXAMPLE
Test-CitrixVDAPorts -ServerList $list

#>
Function Test-CitrixVDAPort {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-CitrixVDAPort')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Collections.ArrayList]$ServerList,
        [Parameter(Mandatory = $false, Position = 1)]
        [System.Collections.ArrayList]$PortsList = @('80', '443', '1494', '2598'),
        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [Parameter(Mandatory = $false, Position = 4)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$ReportPath = $env:temp
    )

    $index = 0
    $object = @()
    $PortsList | ForEach-Object {
        $port = $_
        $ServerList | ForEach-Object {
            $test = Test-NetConnection -ComputerName $_ -Port $port -InformationLevel Detailed
            $ob = [PSCustomObject]@{
                index            = $index
                From_Host        = $env:COMPUTERNAME
                To_Host          = $_
                RemoteAddress    = $test.RemoteAddress
                Port             = $port
                TcpTestSucceeded = $test.TcpTestSucceeded
                Detail           = @(($test) | Out-String).Trim()
            }
            $object += $ob
            $index ++

        }
    }

    if ($Export -eq 'Excel') {
        foreach ($svr in $ServerList) {
            $object | Where-Object { $_.To_Host -like $svr } | Export-Excel -Path ($ReportPath + '\VDA_Ports-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Append -FreezeTopRow -TableStyle Dark11 -BoldTopRow -ConditionalText $(
                New-ConditionalText FALSE white red
                New-ConditionalText TRUE white green
            )
        }

    }
    if ($Export -eq 'HTML') {
        $HeadingText = 'VDA Ports Tests' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
        New-HTML -TitleText 'VDA Ports Tests' -FilePath ($ReportPath + '\VDA_Ports-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html') -ShowHTML {
            New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
            foreach ($svr in $ServerList) {
                $object | Where-Object { $_.To_Host -like $svr }
                New-HTMLSection @SectionSettings -Content {
                    New-HTMLSection -HeaderText "Source: $($svr)" @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $object }
                }
            }
        }
    }

    if ($Export -eq 'Host') { $object }


} #end Function
 
Export-ModuleMember -Function Test-CitrixVDAPort
#endregion
 
#region Test-IsFileOpen.ps1
######## Function 84 of 95 ##################
# Function:         Test-IsFileOpen
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/24 06:04:52
# Synopsis:         Checks if a file is open
#############################################
 
<#
.SYNOPSIS
Checks if a file is open

.DESCRIPTION
Checks if a file is open

.PARAMETER Path
Path to the file to check.

.PARAMETER FilterOpen
Only show open files.

.EXAMPLE
dir | Test-IsFileOpen


#>
Function Test-IsFileOpen {
	[Cmdletbinding( HelpURI = 'https://smitpi.github.io/PSToolKit/Test-IsFileOpen')]
	[OutputType([System.Object[]])]
	PARAM(
		[parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[Alias('FullName')]
		[string[]]$Path,
		[switch]$FilterOpen = $False
	)
	Process {
		ForEach ($Item in $Path) {
			#Ensure this is a full path
			$Item = Convert-Path $Item
			#Verify that this is a file and not a directory
			If ([System.IO.File]::Exists($Item)) {
				Try {
					$FileStream = [System.IO.File]::Open($Item, 'Open', 'Write')
					$FileStream.Close()
					$FileStream.Dispose()
					$IsLocked = $False
				} Catch [System.UnauthorizedAccessException] {$IsLocked = 'AccessDenied'}
				Catch { $IsLocked = $True}
				$result = [pscustomobject]@{
					File     = $Item
					IsLocked = $IsLocked
				}
				if ($FilterOpen) {
					if ($result.IsLocked -eq $True) {$result}
				} else {$result}
			}
		}
	}
} #end Function
 
Export-ModuleMember -Function Test-IsFileOpen
#endregion
 
#region Test-PendingReboot.ps1
######## Function 85 of 95 ##################
# Function:         Test-PendingReboot
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         This script tests various registry values to see if the local computer is pending a reboot.
#############################################
 
<#
.SYNOPSIS
This script tests various registry values to see if the local computer is pending a reboot.

.DESCRIPTION
This script tests various registry values to see if the local computer is pending a reboot.

.PARAMETER ComputerName
Computer to check.

.PARAMETER Credential
User with admin access.

.EXAMPLE
Test-PendingReboot -ComputerName localhost

.NOTES
General notes
#>
function Test-PendingReboot {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-PendingReboot')]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string[]]$ComputerName,

		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[pscredential]$Credential
	)

	$ErrorActionPreference = 'Stop'

	$scriptBlock = {

		$VerbosePreference = $using:VerbosePreference
		function Test-RegistryKey {
			[OutputType('bool')]
			[CmdletBinding()]
			param
			(
				[Parameter(Mandatory)]
				[ValidateNotNullOrEmpty()]
				[string]$Key
			)

			$ErrorActionPreference = 'Stop'

			if (Get-Item -Path $Key -ErrorAction Ignore) {
				$true
			}
		}

		function Test-RegistryValue {
			[OutputType('bool')]
			[CmdletBinding()]
			param
			(
				[Parameter(Mandatory)]
				[ValidateNotNullOrEmpty()]
				[string]$Key,

				[Parameter(Mandatory)]
				[ValidateNotNullOrEmpty()]
				[string]$Value
			)

			$ErrorActionPreference = 'Stop'

			if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
				$true
			}
		}

		function Test-RegistryValueNotNull {
			[OutputType('bool')]
			[CmdletBinding()]
			param
			(
				[Parameter(Mandatory)]
				[ValidateNotNullOrEmpty()]
				[string]$Key,

				[Parameter(Mandatory)]
				[ValidateNotNullOrEmpty()]
				[string]$Value
			)

			$ErrorActionPreference = 'Stop'

			if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
				$true
			}
		}

		# Added "test-path" to each test that did not leverage a custom function from above since
		# an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
		$tests = @(
			{ Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
			{ Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
			{ Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
			{ Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
			{ Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
			{ Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
			{ Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
			{
				# Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
				'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { Test-Path $_ -PathType Container } | ForEach-Object {
					(Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' -ErrorAction Ignore | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
				}
			}
			{ Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
			{ Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
			{ Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
			{ Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
			{
				# Added test to check first if keys exists, if not each group will return $Null
				# May need to evaluate what it means if one or both of these keys do not exist
				( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { Test-Path $_ } | ForEach-Object { (Get-ItemProperty -Path $_ ).ComputerName } ) -ne
				( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | ForEach-Object { (Get-ItemProperty -Path $_ ).ComputerName } )
			}
			{
				# Added test to check first if key exists
				'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object {
					(Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
			}
		)

		foreach ($test in $tests) {
			Write-Verbose "Running scriptblock: [$($test.ToString())]"
			if (& $test) {
				$true
				break
			}
		}
	}

	foreach ($computer in $ComputerName) {
		try {
			$connParams = @{
				'ComputerName' = $computer
			}
			if ($PSBoundParameters.ContainsKey('Credential')) {
				$connParams.Credential = $Credential
			}

			$output = @{
				ComputerName    = $computer
				IsPendingReboot = $false
			}

			$psRemotingSession = New-PSSession @connParams

			if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $scriptBlock)) {
				$output.IsPendingReboot = $false
			}
			[pscustomobject]$output
		}
		catch {
			Write-Error -Message $_.Exception.Message
		}
		finally {
			if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
				$psRemotingSession | Remove-PSSession
			}
		}
	}
}
 
Export-ModuleMember -Function Test-PendingReboot
#endregion
 
#region Test-PSRemote.ps1
######## Function 86 of 95 ##################
# Function:         Test-PSRemote
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Test PSb Remote to a device.
#############################################
 
<#
.SYNOPSIS
Test PSb Remote to a device.

.DESCRIPTION
Test PSb Remote to a device.

.PARAMETER ComputerName
Device to test.

.PARAMETER Credential
Username to use.

.EXAMPLE
Test-PSRemote -ComputerName Apollo

#>
Function Test-PSRemote {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-PSRemote')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { if (Test-Connection -ComputerName $_ -Count 2 -Quiet) { $true }
				else { throw "Unable to connect to $($_)" } })]
		[string[]]$ComputerName,
		[pscredential]$Credential
	)

	if ($null -like $Credential) {
		foreach ($comp in $ComputerName) {
			try {
				Invoke-Command -ComputerName $comp -ScriptBlock { Write-Output "PS Remote connection working on $($using:env:COMPUTERNAME)" }
			}
			catch { Write-Warning "Unable to connect to $($comp) - Error: `n $($_.Exception.Message)" }
		}
	}
	else {
		foreach ($comp in $ComputerName) {
			try {
				Invoke-Command -ComputerName $comp -Credential $Credential -ScriptBlock { Write-Output "PS Remote connection working on  $($using:env:COMPUTERNAME)" }
			}
			catch { Write-Warning "Unable to connect to $($comp) - Error: `n $($_.Exception.Message)" }
		}
	}
} #end Function
 
Export-ModuleMember -Function Test-PSRemote
#endregion
 
#region Update-ListOfDDC.ps1
######## Function 87 of 95 ##################
# Function:         Update-ListOfDDC
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Update list of ListOfDDCs in the registry
#############################################
 
<#
.SYNOPSIS
Update list of ListOfDDCs in the registry

.DESCRIPTION
Update list of ListOfDDCs in the registry

.PARAMETER ComputerName
Server to update

.PARAMETER CurrentOnly
Only display current setting.

.PARAMETER CloudConnectors
List of DDC or Cloud Connector FQDN

.EXAMPLE
Update-ListOfDDCs -ComputerName AD01 -CloudConnectors $DDC

#>
Function Update-ListOfDDC {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-ListOfDDCs')]
	PARAM(
		[string]$ComputerName = 'localhost',
		[switch]$CurrentOnly = $false,
		[string[]]$CloudConnectors
	)

	Import-Module PoshRegistry -Force
	if ($CurrentOnly) {
		$current = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "Current DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $current -ForegroundColor Red
	}
	else {
		$current = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "Current DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $current -ForegroundColor Red
		Write-Host '----------------------------------' -ForegroundColor Yellow

		foreach ($connector in $CloudConnectors) { if (-not(Test-Connection $connector -Count 1 -Quiet)) { Write-Warning "Unable to connect to $($connector)" } }
		$ListOfDDC = Join-String $CloudConnectors -Separator ' '

		Set-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs -Data $ListOfDDC -Force

		Get-Service -DisplayName 'Citrix Desktop Service' | Restart-Service -Force
		$currentnew = Get-RegString -ComputerName $ComputerName -Hive LocalMachine -Key SOFTWARE\Citrix\VirtualDesktopAgent -Value ListOfDDCs | ForEach-Object { $_.data }
		Write-Host "New DDCs for $ComputerName : " -ForegroundColor Cyan -NoNewline
		Write-Host $currentnew -ForegroundColor Green
	}
} #end Function
 
Export-ModuleMember -Function Update-ListOfDDC
#endregion
 
#region Update-LocalHelp.ps1
######## Function 88 of 95 ##################
# Function:         Update-LocalHelp
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/30 23:06:34
# Synopsis:         Downloads and saves help files locally
#############################################
 
<#
.SYNOPSIS
 Downloads and saves help files locally

.DESCRIPTION
 Downloads and saves help files locally

.EXAMPLE
Update-LocalHelp

#>
function Update-LocalHelp {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-LocalHelp')]
    PARAM()

   
    if ((Test-Path $profile) -eq $false ) {
        Write-Warning 'Profile does not exist, creating file.'
        New-Item -ItemType File -Path $Profile -Force
        $psfolder = (Get-Item $profile).DirectoryName
    } else { $psfolder = (Get-Item $profile).DirectoryName }

    if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory -Force -ErrorAction SilentlyContinue }

    $helpdir = Get-Item (Join-Path $psfolder -ChildPath 'Help')

    Start-ThreadJob -ScriptBlock {
        Update-Help -Force -Verbose
        Save-Help -DestinationPath $using:helpdir -Force -Verbose
    }

        
}
 
Export-ModuleMember -Function Update-LocalHelp
#endregion
 
#region Update-MyModulesFromGitHub.ps1
######## Function 89 of 95 ##################
# Function:         Update-MyModulesFromGitHub
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/06 00:30:58
# Synopsis:         Updates my modules
#############################################
 
<#
.SYNOPSIS
Updates my modules

.DESCRIPTION
Updates my modules

.PARAMETER Modules
Which modules to update.

.PARAMETER AllUsers
Will update to the AllUsers Scope.

.PARAMETER ForceUpdate
ForceUpdate the download and install.


.EXAMPLE
Update-MyModulesFromGitHub -AllUsers

#>
Function Update-MyModulesFromGitHub {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/$($ModuleName)/Update-MyModulesFromGitHub')]
	[OutputType([System.Object[]])]
	PARAM(
        [ValidateSet('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule', 'PSToolkit')]
        [string[]]$Modules = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule', 'PSToolkit'),
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$AllUsers,
		[switch]$ForceUpdate = $false
	)

	foreach ($ModuleName in $Modules) {
        Write-Host '[Checking]: ' -ForegroundColor Yellow -NoNewline; Write-Host "$($ModuleName): " -ForegroundColor Cyan

		if ($AllUsers) {
			$ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules', "$($ModuleName)")
		} else {
			$ModulePath = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell', 'Modules', "$($ModuleName)")
		}


		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder $($env:tmp) "
		if ((Test-Path "$env:tmp\$($ModuleName).zip") -eq $true ) { Remove-Item "$env:tmp\$($ModuleName).zip" -Force }

		if ((Test-Path $ModulePath)) {
			$ModChild = $InstalledVer = $OnlineVer = $null
			$ModChild = Get-ChildItem -Directory $ModulePath -ErrorAction SilentlyContinue
			if ($null -like $ModChild) {$ForceUpdate = $true}
			else {
				[version]$InstalledVer = ($ModChild | Sort-Object -Property Name -Descending)[0].Name
				[version]$OnlineVer = (Invoke-RestMethod "https://raw.githubusercontent.com/smitpi/$($ModuleName)/master/Version.json").version
				if ($InstalledVer -lt $OnlineVer) {
					$ForceUpdate = $true
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder to $(Join-Path -Path $ModulePath -ChildPath "$($ModuleName)-BCK.zip")"
					Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath "$($ModuleName)-BCK.zip") -Update
					Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder $($ModulePath)"
					Get-ChildItem -Directory $ModulePath | Remove-Item -Recurse -Force
				} else {
					Write-Host "`t[Done]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($ModuleName) ($($OnlineVer.ToString())): " -ForegroundColor Cyan -NoNewline; Write-Host 'Already Up To Date' -ForegroundColor DarkRed
				}
			}
		} else {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Creating Module directory $($ModulePath)"
			New-Item $ModulePath -ItemType Directory -Force | Out-Null
			$ForceUpdate = $true
		}

		if ($ForceUpdate) {
			$PathFullName = Get-Item $ModulePath
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
			Write-Host "`t[Downloading]: " -NoNewline -ForegroundColor Yellow; Write-Host "$($ModuleName): " -ForegroundColor DarkRed
			if (Get-Command Start-BitsTransfer) {
				try {
					Start-BitsTransfer -DisplayName "$($ModuleName) Download" -Source "https://codeload.github.com/smitpi/$($ModuleName)/zip/refs/heads/master" -Destination "$env:tmp\$($ModuleName).zip" -TransferType Download -ErrorAction Stop
				} catch {
					Write-Warning 'Bits Transer failed, defaulting to webrequest'
					Invoke-WebRequest -Uri https://codeload.github.com/smitpi/$($ModuleName)/zip/refs/heads/master -OutFile "$env:tmp\$($ModuleName).zip"
				}
			} else {
				Invoke-WebRequest -Uri https://codeload.github.com/smitpi/$($ModuleName)/zip/refs/heads/master -OutFile "$env:tmp\$($ModuleName).zip"
			}
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
			Expand-Archive "$env:tmp\$($ModuleName).zip" "$env:tmp" -Force

			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Copying to $($PathFullName.FullName)"
			$NewModule = Get-ChildItem -Directory "$env:tmp\$($ModuleName)-master\Output"
			Copy-Item -Path $NewModule.FullName -Destination $PathFullName.FullName -Recurse

			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Removing temp files"
			Remove-Item "$env:tmp\$($ModuleName).zip"
			Remove-Item "$env:tmp\$($ModuleName)-master" -Recurse
		}
		$ForceUpdate = $false
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete]"
    Remove-Module -Name $($ModuleName) -Force -ErrorAction SilentlyContinue
    Import-Module $($ModuleName) -Force -ErrorAction SilentlyContinue

    $module = Get-Module -Name $($ModuleName)
    if (-not($module)) { $module = Get-Module -Name $($ModuleName) -ListAvailable }
    $latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
    [string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version
    $Description = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Description
    [datetime]$CreateDate = (Get-Content -Path $($latestModule.Path.Replace('psm1', 'psd1')) | Where-Object { $_ -like '# Generated on: *' }).replace('# Generated on: ', '')
    $CreateDate = $CreateDate.ToUniversalTime()

    write-host "`t[$($ModuleName)]" -NoNewline -ForegroundColor Cyan; Write-Host " Details" -ForegroundColor Green
    [PSCustomObject]@{
            Name         = $($ModuleName)
            Description  = $Description
            Version      = $version
            Date         = (Get-Date($CreateDate) -Format F)
            Path         = $module.Path
        }
	}
} #end Function
 
Export-ModuleMember -Function Update-MyModulesFromGitHub
#endregion
 
#region Update-PSDefaultParameter.ps1
######## Function 90 of 95 ##################
# Function:         Update-PSDefaultParameter
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/17 13:39:28
# ModifiedOn:       2022/08/17 16:44:39
# Synopsis:         Updates the $PSDefaultParameterValues variable
#############################################
 
<#
.SYNOPSIS
Updates the $PSDefaultParameterValues variable

.DESCRIPTION
Updates the $PSDefaultParameterValues variable, and saves it to your profile.

.PARAMETER Function
The function name to add, you can also add wildcards.

.PARAMETER Parameter
The Parameter in that function to add.

.PARAMETER value
Value of the parameter

.PARAMETER WriteToProfile
Also write the result to your profile.

.EXAMPLE
Update-PSDefaultParameter -Function Connect-VMWareCluster -Parameter vCenterIp -value '192.168.x.x' -WriteToProfile

#>
Function Update-PSDefaultParameter {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSDefaultParameter')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Function,
		[string]$Parameter,
		[string]$value,
		[switch]$WriteToProfile
	)
	$PSDefaultParameterValues.Add("$($Function):$($Parameter)", $($value))
	$PSDefaultParameterValues

	if ($WriteToProfile) {

		$ProfileAdd = [System.Collections.Generic.List[string]]::new()
		$ProfileAdd.Add('#region PSDefaultParameter')
		$PSDefaultParameterValues.GetEnumerator() | ForEach-Object {$ProfileAdd.Add("`$PSDefaultParameterValues[""$($_.Name)""] = ""$($_.Value)""")}
		$ProfileAdd.Add('#endregion PSDefaultParameter')

		$PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
		$PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
		$Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
		$files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
		foreach ($file in $files) {	
			$tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSDefaultParameter*'}
			$tmp | Set-Content -Path $file.FullName -Force
			Add-Content -Value $ProfileAdd -Path $file.FullName -Force -Encoding utf8
			Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
		}



	}
		
} #end Function
 
Export-ModuleMember -Function Update-PSDefaultParameter
#endregion
 
#region Update-PSModuleInfo.ps1
######## Function 91 of 95 ##################
# Function:         Update-PSModuleInfo
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Update PowerShell module manifest file
#############################################
 
<#
.SYNOPSIS
Update PowerShell module manifest file

.DESCRIPTION
Update PowerShell module manifest file

.PARAMETER ModuleManifestPath
Path to .psd1 file

.PARAMETER Author
Who wrote the module.

.PARAMETER Description
What it does

.PARAMETER tag
Tags for searching

.PARAMETER MinorUpdate
Major update increase

.PARAMETER ChangesMade
What has changed in the module.

.EXAMPLE
Update-PSModuleInfo -ModuleManifestPath .\PSLauncher.psd1 -ChangesMade 'Added button to add more panels'

#>
Function Update-PSModuleInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSModuleInfo')]
	[OutputType([System.Collections.Hashtable])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psd1') })]
		[System.IO.FileInfo]$ModuleManifestPath,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $false)]
		[string]$Description,
		[Parameter(Mandatory = $false)]
		[string[]]$tag,
		[Parameter(Mandatory = $false)]
		[switch]$MinorUpdate = $false,
		[Parameter(Mandatory = $false)]
		[string]$ChangesMade = 'Module Info was updated')


	if ((Test-Path -Path $ModuleManifestPath) -eq $true ) {
		$Module = Get-Item -Path $ModuleManifestPath | Select-Object *
		try {
			$currentinfo = Test-ModuleManifest -Path $Module.fullname
			$currentinfo | Select-Object Path, RootModule, ModuleVersion, Author, Description, CompanyName, Tags, ReleaseNotes, GUID, FunctionsToExport | Format-List
		}
		catch { Write-Host 'No module Info found, using default values' -ForegroundColor Cyan }
	}
	if ([bool]$currentinfo -eq $true) {
		[version]$ver = $currentinfo.Version
		if ($MinorUpdate) { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, ($ver.Minor + 1), $ver.Build }
		else { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, $ver.Minor, ($ver.Build + 1) }
		$guid = $currentinfo.Guid
		$ReleaseNotes = 'Updated [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] ' + $ChangesMade
		if ($Description -like '') { $Description = $currentinfo.Description }
		$company = $currentinfo.CompanyName
		if ($Author -like '') { $Author = $currentinfo.Author }
		[string[]]$tags += $tag
		$tags += $currentinfo.Tags | Where-Object { $_ -ne '' } | Sort-Object -Unique

	}
	$manifestProperties = @{
		Path              = $Module.FullName
		RootModule        = $Module.Name.Replace('.psd1', '.psm1')
		ModuleVersion     = $Version
		Author            = $Author
		Description       = $Description
		CompanyName       = $company
		Tags              = [string[]]$($Tags) | Where-Object { $_ -ne '' } | Sort-Object -Unique
		ReleaseNotes      = @($ReleaseNotes)
		GUID              = $guid
		FunctionsToExport = @((Get-ChildItem -Path ($Module.DirectoryName + '\Public') -Include *.ps1 -Recurse | Select-Object basename).basename | Sort-Object)
	}

	$manifestProperties
	Update-ModuleManifest @manifestProperties
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] Processing file: $($Script.FullName)"

	#else { Write-Host "Path to script is invalid"; break }


} #end Function
 
Export-ModuleMember -Function Update-PSModuleInfo
#endregion
 
#region Update-PSToolKitConfigFile.ps1
######## Function 92 of 95 ##################
# Function:         Update-PSToolKitConfigFile
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/07/13 00:53:16
# Synopsis:         Manages the config files for the PSToolKit Module.
#############################################
 
<#
.SYNOPSIS
Manages the config files for the PSToolKit Module.

.DESCRIPTION
Manages the config files for the PSToolKit Module, By updating either the locally installed files, or the ones hosted on GitHub Gist.

.PARAMETER UpdateLocal
Overwrites the local files in C:\Program Files\PSToolKit\Config\

.PARAMETER UpdateLocalFromModule
Will be updated from the PSToolKit Modules files.

.PARAMETER UpdateLocalFromGist
Will be updated from the hosted gist files..

.PARAMETER UpdateGist
Update the Gist from the local files.

.PARAMETER GitHubUserID
GitHub User with access to the gist.

.PARAMETER GitHubToken
GitHub User's Token.

.EXAMPLE
Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule

#>
Function Update-PSToolKitConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'local', HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKitConfigFiles')]
	PARAM(
		[Parameter(ParameterSetName = 'local')]
		[Parameter(ParameterSetName = 'Localgist')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$UpdateLocal,
		[Parameter(ParameterSetName = 'gistupdate')]
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$UpdateGist,
		[Parameter(ParameterSetName = 'local')]
		[switch]$UpdateLocalFromModule,
		[Parameter(ParameterSetName = 'Localgist')]
		[switch]$UpdateLocalFromGist,
		[Parameter(ParameterSetName = 'gistupdate')]
		[Parameter(ParameterSetName = 'Localgist')]
		[string]$GitHubUserID,
		[Parameter(ParameterSetName = 'gistupdate')]
		[Parameter(ParameterSetName = 'Localgist')]
		[string]$GitHubToken
	)

 $ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	if (-not(Test-Path $ConfigPath)) { $ModuleConfigPath = New-Item $ConfigPath -ItemType Directory -Force }
	else { $ModuleConfigPath = Get-Item $ConfigPath }

	if ($UpdateLocal) {
		if ($UpdateLocalFromModule) {
			try {
				$module = Get-Module PSToolKit
				if (!$module) { $module = Get-Module PSToolKit -ListAvailable }
				Get-ChildItem (Join-Path $module.ModuleBase -ChildPath "\private\Config") | ForEach-Object {
					Copy-Item -Path $_.FullName -Destination $ModuleConfigPath.FullName -Force
					Write-Color '[Update]', "$($_.name): ", 'Completed' -Color Yellow, Cyan, Green
				}
			} catch {throw "Unable to update from module source:`n $($_.Exception.Message)"}
		}
		if ($UpdateLocalFromGist) {
			$headers = @{}
			$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
			$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
			$base64 = [System.Convert]::ToBase64String($bytes)
			$headers.Authorization = 'Basic {0}' -f $base64

			$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID

			$gistfiles = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
			$gistfiles = $gistfiles | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }
			$gistfileNames = $gistfiles.files | Get-Member | Where-Object { $_.memberType -eq 'NoteProperty' } | Select-Object Name
			foreach ($gistfileName in $gistfileNames) {
				$url = ($gistfiles.files."$($gistfileName.name)").raw_url
            (Invoke-WebRequest -Uri $url -Headers $headers).content | Set-Content (Join-Path $ModuleConfigPath.FullName -ChildPath $($gistfileName.name))
				Write-Color '[Update]', $($gistfileName.name), ': Complete' -Color Yellow, Cyan, Green
			}
		}

	}
	if ($UpdateGist) {
		try {
			$headers = @{}
			$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
			$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
			$base64 = [System.Convert]::ToBase64String($bytes)
			$headers.Authorization = 'Basic {0}' -f $base64

			$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
			$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
			$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }
		} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}

		if ($null -like $PRGist) {
			try {
				$Body = @{}
				$files = @{}
				Get-ChildItem $ModuleConfigPath.FullName | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } } -ErrorAction Stop
				$Body.files = $Files
				$Body.description = 'PSToolKit-Config'
				$json = ConvertTo-Json -InputObject $Body
				$json = [System.Text.Encoding]::UTF8.GetBytes($json)
				$null = Invoke-WebRequest -Headers $headers -Uri https://api.github.com/gists -Method Post -Body $json -ErrorAction Stop
				Write-Color '[Initial]-[Upload]', 'PSToolKit Config to Gist:', ' Completed' -Color Yellow, Cyan, Green
			} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}
		} else {
			try {
				$Body = @{}
				$files = @{}
				Get-ChildItem $ModuleConfigPath.FullName | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } } -ErrorAction Stop
				$Body.files = $Files
				$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
				$json = ConvertTo-Json -InputObject $Body
				$json = [System.Text.Encoding]::UTF8.GetBytes($json)
				$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
				Write-Color '[Upload]', 'PSToolKit Config to Gist:', ' Completed' -Color Yellow, Cyan, Green
			} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}
		}

	}


} #end
 
Export-ModuleMember -Function Update-PSToolKitConfigFile
#endregion
 
#region Write-Ascii.ps1
######## Function 93 of 95 ##################
# Function:         Write-Ascii
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Joakim Svendsen
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Create Ascii Art
#############################################
 
<#
.SYNOPSIS
Create Ascii Art

.DESCRIPTION
Create Ascii Art

.PARAMETER InputObject
The string

.PARAMETER PrependChar
char

.PARAMETER Compress
compress output

.PARAMETER ForegroundColor
ForegroundColor

.PARAMETER BackgroundColor
BackgroundColor

.EXAMPLE
Write-Ascii Blah
#>
function Write-Ascii {
    # Wrapping the script in a function to make it a module

    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline = $True,
            Mandatory = $True)]
        [Alias('InputText')]
        [String[]] $InputObject,
        [Switch] $PrependChar,
        [Alias('Compression')] [Switch] $Compress,
        [ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Default', 'Gray', 'Green',
            'Magenta', 'Red', 'Rainbow', 'White', 'Yellow')]
        [String] $ForegroundColor = 'Default',
        [ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Default', 'Gray', 'Green',
            'Magenta', 'Red', 'Rainbow', 'White', 'Yellow')]
        [String] $BackgroundColor = 'Default'
        #[int] $MaxChars = '25'
    )

    begin {

        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'

        # Algorithm from hell... This was painful. I hope there's a better way.
        function Get-Ascii {

            param([String] $Text)

            $LetterArray = [Char[]] $Text.ToLower()

            #Write-Host -fore green $LetterArray

            # Find the letter with the most lines.
            $MaxLines = 0
            $LetterArray | ForEach-Object {
                if ($Letters.([String] $_).Lines -gt $MaxLines ) {
                    $MaxLines = $Letters.([String] $_).Lines
                }
            }

            # Now this sure was a simple way of making sure all letter align tidily without changing a lot of code!
            if (-not $Compress) { $MaxLines = 6 }

            $LetterWidthArray = $LetterArray | ForEach-Object {
                $Letter = [String] $_
                $Letters.$Letter.Width
            }
            $LetterLinesArray = $LetterArray | ForEach-Object {
                $Letter = [String] $_
                $Letters.$Letter.Lines
            }

            #$LetterLinesArray

            $Lines = @{
                '1' = ''
                '2' = ''
                '3' = ''
                '4' = ''
                '5' = ''
                '6' = ''
            }

            #$LineLengths = @(0, 0, 0, 0, 0, 0)

            # Debug
            #Write-Host "MaxLines: $Maxlines"

            $LetterPos = 0
            foreach ($Letter in $LetterArray) {

                # We need to work with strings for indexing the hash by letter
                $Letter = [String] $Letter

                # Each ASCII letter can be from 4 to 6 lines.

                # If the letter has the maximum of 6 lines, populate hash with all lines.
                if ($LetterLinesArray[$LetterPos] -eq 6) {

                    #Write-Host "Six letter letter"

                    foreach ($Num in 1..6) {

                        $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 1]

                        if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                            $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                        }

                        $StringNum = [String] $Num
                        $Lines.$StringNum += $LineFragment

                    }

                }

                # Add padding for line 1 for letters with 5 lines and populate lines 2-6.
                ## Changed to top-adjust 5-line letters if there are 6 total.
                ## Added XML properties for letter alignment. Most are "default", which is top-aligned.
                ## Also added script logic to handle it (2012-12-29): <fixation>bottom</fixation>
                elseif ($LetterLinesArray[$LetterPos] -eq 5) {

                    if ($MaxLines -lt 6 -or $Letters.$Letter.fixation -eq 'bottom') {

                        $Padding = ' ' * $LetterWidthArray[$LetterPos]
                        $Lines.'1' += $Padding

                        foreach ($Num in 2..6) {

                            $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 2]

                            if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                                $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                            }

                            $StringNum = [String] $Num
                            $Lines.$StringNum += $LineFragment

                        }

                    }

                    else {

                        $Padding = ' ' * $LetterWidthArray[$LetterPos]
                        $Lines.'6' += $Padding

                        foreach ($Num in 1..5) {

                            $StringNum = [String] $Num

                            $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - 1]

                            if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                                $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                            }

                            $Lines.$StringNum += $LineFragment

                        }

                    }

                }

                # Here we deal with letters with four lines.
                # Dynamic algorithm that places four-line letters on the bottom line if there are
                # 4 or 5 lines only in the letter with the most lines.
                else {

                    # Default to putting the 4-liners at line 3-6
                    $StartRange, $EndRange, $IndexSubtract = 3, 6, 3
                    $Padding = ' ' * $LetterWidthArray[$LetterPos]

                    # If there are 4 or 5 lines...
                    if ($MaxLines -lt 6) {

                        $Lines.'2' += $Padding

                    }

                    # There are 6 lines maximum, put 4-line letters in the middle.
                    else {

                        $Lines.'1' += $Padding
                        $Lines.'6' += $Padding
                        $StartRange, $EndRange, $IndexSubtract = 2, 5, 2

                    }

                    # There will always be at least four lines. Populate lines 2-5 or 3-6 in the hash.
                    foreach ($Num in $StartRange..$EndRange) {

                        $StringNum = [String] $Num

                        $LineFragment = [String](($Letters.$Letter.ASCII).Split("`n"))[$Num - $IndexSubtract]

                        if ($LineFragment.Length -lt $Letters.$Letter.Width) {
                            $LineFragment += ' ' * ($Letters.$Letter.Width - $LineFragment.Length)
                        }

                        $Lines.$StringNum += $LineFragment

                    }

                }

                $LetterPos++

            } # end of LetterArray foreach

            # Return stuff
            $Lines.GetEnumerator() |
                Sort-Object -Property Name |
                    Select-Object -ExpandProperty Value |
                        Where-Object {
                            $_ -match '\S'
                        } | ForEach-Object {
                            if ($PrependChar) {
                                "'" + $_
                            } else {
                                $_
                            }
                        }

        }

        # Populate the $Letters hashtable with character data from the XML.
        Function Get-LetterXML {


            $LetterFile = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config', 'letters.xml')
            $Xml = [xml] (Get-Content $LetterFile)

            $Xml.Chars.Char | ForEach-Object {

                $Letters.($_.Name) = New-Object PSObject -Property @{

                    'Fixation' = $_.fixation
                    'Lines'    = $_.lines
                    'ASCII'    = $_.data
                    'Width'    = $_.width

                }

            }

        }

        function Write-RainbowString {

            param([String] $Line,
                [String] $ForegroundColor = '',
                [String] $BackgroundColor = '')

            $Colors = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow',
                'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')


            # $Colors[(Get-Random -Min 0 -Max 16)]

            [Char[]] $Line | ForEach-Object {

                if ($ForegroundColor -and $ForegroundColor -ieq 'rainbow') {

                    if ($BackgroundColor -and $BackgroundColor -ieq 'rainbow') {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -BackgroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    } elseif ($BackgroundColor) {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -BackgroundColor $BackgroundColor `
                            -NoNewline $_
                    } else {
                        Write-Host -ForegroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    }

                }
                # One of them has to be a rainbow, so we know the background is a rainbow here...
                else {

                    if ($ForegroundColor) {
                        Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $Colors[(
                            Get-Random -Min 0 -Max 16
                        )] -NoNewline $_
                    } else {
                        Write-Host -BackgroundColor $Colors[(Get-Random -Min 0 -Max 16)] -NoNewline $_
                    }
                }

            }

            Write-Host ''

        }

        # Get ASCII art letters/characters and data from XML. Make it persistent for the module.
        if (-not (Get-Variable -EA SilentlyContinue -Scope Script -Name Letters)) {
            $script:Letters = @{}
            Get-LetterXML
        }

        # Turn the [string[]] into a [String] the only way I could figure out how... wtf
        #$Text = ''
        #$InputObject | ForEach-Object { $Text += "$_ " }

        # Limit to 30 characters
        #$MaxChars = 30
        #if ($Text.Length -gt $MaxChars) { "Too long text. There's a maximum of $MaxChars characters."; return }

        # Replace spaces with underscores (that's what's used for spaces in the XML).
        #$Text = $Text -replace ' ', '_'

        # Define accepted characters (which are found in XML).
        #$AcceptedChars = '[^a-z0-9 _,!?./;:<>()�{}\[\]\|\^=\$\-''+`\\"�������������]' # Some chars only works when sent as UTF-8 on IRC
        $LetterArray = [string[]]($Letters.GetEnumerator() | Sort-Object Name | Select-Object -ExpandProperty Name)
        $AcceptedChars = [regex] ( '(?i)[^' + ([regex]::Escape(($LetterArray -join '')) -replace '-', '\-' -replace '\]', '\]') + ' ]' )
        # Debug
        #Write-Host -fore cyan $AcceptedChars.ToString()
    }

    process {
        if ($InputObject -match $AcceptedChars) {
            'Unsupported character, using these accepted characters: ' + ($LetterArray -replace '^template$' -join ', ') + '.'
            return
        }

        # Filthy workaround (now worked around in the foreach creating the string).
        #if ($Text.Length -eq 1) { $Text += '_' }

        $Lines = @()

        foreach ($Text in $InputObject) {

            $ASCII = Get-Ascii ($Text -replace ' ', '_')

            if ($ForegroundColor -ne 'Default' -and $BackgroundColor -ne 'Default') {
                if ($ForegroundColor -ieq 'rainbow' -or $BackGroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -Line $_
                    }
                } else {
                    Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor ($ASCII -join "`n")
                }
            } elseif ($ForegroundColor -ne 'Default') {
                if ($ForegroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -ForegroundColor $ForegroundColor -Line $_
                    }
                } else {
                    Write-Host -ForegroundColor $ForegroundColor ($ASCII -join "`n")
                }
            } elseif ($BackgroundColor -ne 'Default') {
                if ($BackgroundColor -ieq 'rainbow') {
                    $ASCII | ForEach-Object {
                        Write-RainbowString -BackgroundColor $BackgroundColor -Line $_
                    }
                } else {
                    Write-Host -BackgroundColor $BackgroundColor ($ASCII -join "`n")
                }
            } else { $ASCII -replace '\s+$' }

        } # end of foreach

    } # end of process block

} # end of function
 
Export-ModuleMember -Function Write-Ascii
#endregion
 
#region Write-PSToolKitLog.ps1
######## Function 94 of 95 ##################
# Function:         Write-PSToolKitLog
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/05/04 00:20:58
# Synopsis:         Create a log for scripts
#############################################
 
<#
.SYNOPSIS
Create a log for scripts

.DESCRIPTION
Create a log for scripts

.PARAMETER Initialize
Create the initial array.

.PARAMETER Severity
Severity of the entry.

.PARAMETER Action
Action for the object.

.PARAMETER Object
The object to be reported on.

.PARAMETER Message
Details.

.PARAMETER ShowVerbose
Show every entry as it is logged.

.PARAMETER ExportFinal
Export the final log file.

.PARAMETER Export
Export the log,

.PARAMETER LogName
Name for the log file.

.PARAMETER ReportPath
Path where it will be saved.

.EXAMPLE
dir | Write-PSToolKitLog -Severity Error -Action Starting -Message 'file list' -ShowVerbose

#>
Function Write-PSToolKitLog {
    [Cmdletbinding(DefaultParameterSetName = 'log'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitLog')]
    PARAM(
        [Parameter(ParameterSetName = 'Create')]
        [switch]$Initialize,
        [Parameter(ParameterSetName = 'log')]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',
        [Parameter(ParameterSetName = 'log')]
        [ValidateSet('Starting', 'Processing', 'Copying', 'Moving', 'Complete', 'Deleting', 'Modifying')]
        [string]$Action,
        [Parameter(ValueFromPipeline = $true, ValueFromRemainingArguments = $false)]
        [Parameter(ParameterSetName = 'log')]
        [string[]]$Object,
        [Parameter(ParameterSetName = 'log')]
        [string]$Message,
        [Parameter(ParameterSetName = 'log')]
        [switch]$ShowVerbose,
        [Parameter(ParameterSetName = 'Export')]
        [switch]$ExportFinal = $false,
        [Parameter(ParameterSetName = 'Export')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [Parameter(ParameterSetName = 'Export')]
        [string]$LogName = 'PSToolKitLog',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(ParameterSetName = 'Export')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
				)
    begin {
        if ($Initialize) { [System.Collections.ArrayList]$script:ExportLogs = @() }
    }
    process {
        if (-not($Initialize) -and -not($ExportFinal)) {
            [void]$ExportLogs.Add([PSCustomObject]@{
                    Time     = "[$(Get-Date -f g)] "
                    Severity = "[$($Severity)] "
                    Action   = "[$($Action)]: "
                    Object   = "($($Object)) "
                    Message  = $Message
                })
        }

        if ($ShowVerbose) {
            $VerbosePreference = 'Continue'
            switch ($($Severity)) {
                { $_ -in 'Debug', 'Information' } { Write-Verbose "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Action)$($ExportLogs[-1].object)$($ExportLogs[-1].Message)" }
                { $_ -in 'Warning', 'Error' } { Write-Warning "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Action)$($ExportLogs[-1].Object)$($ExportLogs[-1].Message)" }
            }
            $VerbosePreference = 'SilentlyContinue'
        }

        if ($ExportFinal) {
            if ($Export -eq 'Excel') { $ExportLogs | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\$($LogName)-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title "$($LogName)" -TitleBold -TitleSize 20 -FreezePane 3 -TitleFillPattern DarkGrid -FreezeTopRow -TableStyle Dark6 -BoldTopRow -Show }
            if ($Export -eq 'HTML') { $ExportLogs | Out-HtmlView -DisablePaging -Title "$($LogName)" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($LogName)-$(Get-Date -Format yyyy.MM.dd-HH.mm).html")}
            if ($Export -eq 'Host') { $ExportLogs | Format-Table -AutoSize -Wrap }
        }
    }
} #end Function
 
Export-ModuleMember -Function Write-PSToolKitLog
#endregion
 
#region Write-PSToolKitMessage.ps1
######## Function 95 of 95 ##################
# Function:         Write-PSToolKitMessage
# Module:           PSToolKit
# ModuleVersion:    0.1.50
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/16 10:02:35
# ModifiedOn:       2022/08/16 20:32:31
# Synopsis:         Writes the given into to screen
#############################################
 
<#
.SYNOPSIS
Writes the given into to screen

.DESCRIPTION
Writes the given into to screen

.PARAMETER Action
Action for the object.

.PARAMETER Severity
Severity of the entry.

.PARAMETER Object
The object to be reported on.

.PARAMETER Message
Message to display. This can be an array of strings as well, to have different colours in the text.+

.PARAMETER MessageColor
The Colour of the corresponding message in the array.

.PARAMETER InsertTabs
Insert tabs before writing the text.

.PARAMETER NoNewLine
Wont add a new line after writing to screen.

.EXAMPLE
Write-PSToolKitMessage -Action Getting -Severity Information -Object (get-item .) -Message "This is","the directory","you are in." -MessageColor Cyan,DarkGreen,DarkRed

#>
Function Write-PSToolKitMessage {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitMessage')]
	[OutputType([System.Object[]])]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$Action,
		[Parameter(Position = 1)]
		[ValidateSet('Information', 'Warning', 'Error')]
		[string]$Severity = 'Information',
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $false, Position = 2)]
		[string[]]$Object,
		[Parameter(Position = 3)]
		[string[]]$Message,
		[ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DArkCyan', 'DArkGrey', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]
		[Parameter(Position = 4)]
		[string[]]$MessageColor,
		[Parameter(Position = 6)]
		[int]$InsertTabs = 0,
		[Parameter(Position = 6)]
		[switch]$NoNewLine = $false
	)

	process {
		if ($InsertTabs -ne 0) {
			0..$InsertTabs | ForEach-Object {Write-Host "`t" -NoNewline}
		}
	
		if ($Severity -like 'Warning') {
			Write-Host 'WARNING - ' -ForegroundColor Yellow -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} elseif ($Severity -like 'Error') {
			Write-Host 'ERROR - ' -ForegroundColor Red -NoNewline
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		} else {
			Write-Host "[$(Get-Date -Format HH:mm:ss)]" -ForegroundColor Gray -NoNewline
			Write-Host "[$($Action)] " -ForegroundColor Yellow -NoNewline
			Write-Host "$($Object) " -ForegroundColor Cyan -NoNewline
		}
		0..($Message.Count - 1) | ForEach-Object {
			Write-Host "$($Message[$_]) " -ForegroundColor $MessageColor[$_] -NoNewline
		}
		if (-not($NoNewLine)) {
			Write-Host ''
		}

	}
} #end Function

#'Black','Blue','Cyan','DarkBlue','DArkCyan','DArkGrey','DarkGreen','DarkMagenta','DarkRed','DarkYellow','Gray','Green','Magenta','Red','White','Yellow',)

$scriptblock = {
	@('Starting', 'Getting', 'Copying', 'Moving', 'Complete', 'Deleting', 'Changing', 'Failed', 'Exists')
}
Register-ArgumentCompleter -CommandName Write-PSToolKitMessage -ParameterName Action -ScriptBlock $scriptBlock

 
Export-ModuleMember -Function Write-PSToolKitMessage
#endregion
 
#endregion
 
