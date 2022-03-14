#region Private Functions
#endregion
#region Public Functions
#region Add-ChocolateyPrivateRepo.ps1
############################################
# source: Add-ChocolateyPrivateRepo.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
  if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
   Install-ChocolateyClient
  }

  [System.Collections.ArrayList]$sources = @()
  choco source list --limit-output | ForEach-Object {
    $tmp = [pscustomobject]@{
      Name     = $_.split('|')[0]
      URL      = $_.split('|')[1]
      Priority = $_.split('|')[5]
    }
    $sources.Add($tmp) | Out-Null
  }
  $RepoExists = $RepoURL -in $sources.Url
  if (!$RepoExists) {
    try {
      choco source add --name="$($RepoName)" --source=$($RepoURL) --priority=$($Priority) --limit-output
      $sources.add([pscustomobject]@{
          Name     = $($RepoName)
          URL      = $($RepoURL)
          Priority = $($Priority)
        }) | Out-Null
      Write-Color '[Install]', 'Private Repo: ', 'Complete' -Color Yellow, Cyan, Green
      Write-Output $sources
      Write-Output '_______________________________________'
    }
    catch { Write-Warning "[Install] Private Repo: Failed:`n $($_.Exception.Message)" }

  }
  else { Write-Warning "Private repo $RepoName already exists on $env:computername." }

  if ($null -notlike $RepoApiKey) { choco apikey --source="$($RepoURL)" --api-key="$($RepoApiKey)" --limit-output }
  if ($DisableCommunityRepo) { choco source disable --name=chocolatey --limit-output }


} #end Function
 
Export-ModuleMember -Function Add-ChocolateyPrivateRepo
#endregion
 
#region Backup-ElevatedShortcut.ps1
############################################
# source: Backup-ElevatedShortcut.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Backup-PowerShellProfile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Connect-VMWareCluster.ps1
############################################
# source: Connect-VMWareCluster.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Edit-ChocolateyAppsList.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
		[Parameter(Mandatory = $true)]
		[ValidateSet('BaseApps', 'ExtendedApps')]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string]$List,
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
		[switch]$AddApp,
		[Parameter(ParameterSetName = 'Add')]
		[string]$ChocoID,
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

	if ($removeApp) {
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

	if ($AddApp) {
		$AppSearch = choco search $($ChocoID) --source=$($ChocoSource) --limit-output | ForEach-Object { ($_ -split '\|')[0] }
		if ($null -like $AppSearch) { Write-Error "Could not find the app in source: $($ChocoSource)" }
		if ($AppSearch.count -eq 1) {
			$tmp = New-Object -TypeName psobject -Property @{
				'Name'   = $ChocoID
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
############################################
# source: Edit-HostsFile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Edit-PSModulesLists.ps1
############################################
# source: Edit-PSModulesLists.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
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
		[string]$AddModule
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
	if (-not($RemoveModule) -and -not($ShowCurrent)) {
		if ($null -like $AddModule) {throw "AddModule cant be an empty string"}
		$findmods = Find-Module -Filter $AddModule
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
 
Export-ModuleMember -Function Edit-PSModulesLists
#endregion
 
#region Enable-RemoteHostPSRemoting.ps1
############################################
# source: Enable-RemoteHostPSRemoting.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Export-CitrixPolicySettings.ps1
############################################
# source: Export-CitrixPolicySettings.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Citrix policy export.

.DESCRIPTION
Citrix policy export. Run it from the DDC.

.PARAMETER FormatTable
Display as a table

.PARAMETER ExportToExcel
Export output to excel

.PARAMETER ReportPath
Path to where it will be saved

.PARAMETER ReportName
Name of the report

.EXAMPLE
Export-CitrixPolicySettings -FormatTable
#>
Function Export-CitrixPolicySettings {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-CitrixPolicySettings')]
	[OutputType([System.Object[]])]
	PARAM(
		[switch]$FormatTable = $false,
		[switch]$ExportToExcel = $false,
		[string]$ReportPath = $env:TMP,
		[string]$ReportName)


	if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
		Import-Module Citrix.GroupPolicy.Commands
		if ((Get-Module Citrix.GroupPolicy.Commands) -like '') {
			Write-Error 'Unable to find module'
			break
		}
	}

	New-PSDrive -Name LocalFarmGpo -PSProvider CitrixGroupPolicy -controller Localhost \
	$Polobject = @()

	Get-CtxGroupPolicy | ForEach-Object {

		$settingdetail = Get-CtxGroupPolicyConfiguration -PolicyName $_.PolicyName -ConfiguredOnly
		$settingdetail | Get-Member -MemberType NoteProperty | Where-Object { $_.definition -like '*PSCustomObject*' } | ForEach-Object {

			$PolObject += [PSCustomObject]@{
				PolicyName   = @(($settingdetail.PolicyName) | Out-String).Trim()
				PolicyType   = @(($settingdetail.Type) | Out-String).Trim()
				SettingName  = $_.name
				SettingState = $settingdetail.($_.name).state
				SettingValue = $settingdetail.($_.name).Value
				SettingPath  = $settingdetail.($_.name).Path
			}

		}
	}
	if ($FormatTable -eq $true) { $Polobject | Format-Table -AutoSize }
	else { $Polobject }


	if ($ExportToExcel -eq $true) {
		if ((Test-Path $ReportPath) -eq $true) {
			$pol = [IO.Path]::Combine($ReportPath, "$ReportName.xlsx")
			$PolObject | Export-Excel -Path $pol -Title 'Citrix Policies' -TitleBold -TitleSize 20 -AutoSize -AutoFilter -TitleFillPattern DarkGray
		}
		else { Write-Warning 'Invalid Path'; break }
 }



} #end Function
 
Export-ModuleMember -Function Export-CitrixPolicySettings
#endregion
 
#region Export-ESXTemplates.ps1
############################################
# source: Export-ESXTemplates.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Export-ESXTemplates {
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
 
Export-ModuleMember -Function Export-ESXTemplates
#endregion
 
#region Export-PSGallery.ps1
############################################
# source: Export-PSGallery.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Export details of all modules and scripts on psgallery to excel

.DESCRIPTION
Export details of all modules and scripts on psgallery to excel

.PARAMETER ReportPath
Where the excel file will be saved.

.EXAMPLE
Export-PSGallery -ReportPath c:\temp

#>
function Export-PSGallery {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Export-PSGallery')]
    PARAM(
        [Parameter(Mandatory = $false)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$ReportPath = $env:temp
    )
    $ReportSavePath = Get-Item $ReportPath
    [string]$Reportname = 'PSGallery.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'
    $ReportSave = Join-Path $ReportSavePath.FullName -ChildPath $Reportname

    Write-Output 'Collecting Modules'
    $newObject = @()
    $ResultModule = Find-Module
    foreach ($mod in $ResultModule) {
        $newObject += [PSCustomObject]@{
            title                = $mod.AdditionalMetadata.title
            tags                 = @($mod.AdditionalMetadata.tags) | Out-String
            ItemType             = $mod.AdditionalMetadata.ItemType
            published            = $mod.AdditionalMetadata.published
            downloadCount        = $mod.AdditionalMetadata.downloadCount
            versionDownloadCount = $mod.AdditionalMetadata.versionDownloadCount
            Authors              = $mod.AdditionalMetadata.Authors
            CompanyName          = $mod.AdditionalMetadata.CompanyName
            ProjectUri           = $mod.ProjectUri
            summary              = $mod.AdditionalMetadata.summary
        }
    }
    $newObject | Export-Excel -Path $ReportSave -WorksheetName Modules -AutoSize -AutoFilter

    Write-Output 'Collecting Scripts'
    $newObject2 = @()
    $ResultScript = Find-Script
    foreach ($scr in $ResultScript) {
        $newObject2 += [PSCustomObject]@{
            title                = $scr.AdditionalMetadata.title
            tags                 = @($scr.AdditionalMetadata.tags) | Out-String
            ItemType             = $scr.AdditionalMetadata.ItemType
            published            = $scr.AdditionalMetadata.published
            downloadCount        = $scr.AdditionalMetadata.downloadCount
            versionDownloadCount = $scr.AdditionalMetadata.versionDownloadCount
            Authors              = $scr.AdditionalMetadata.Authors
            CompanyName          = $scr.AdditionalMetadata.CompanyName
            ProjectUri           = $scr.ProjectUri
            summary              = $scr.AdditionalMetadata.summary
        }
    }
    $newObject2 | Export-Excel -Path $ReportSave -WorksheetName Scripts -AutoSize -AutoFilter -Show
}
 
Export-ModuleMember -Function Export-PSGallery
#endregion
 
#region Find-ChocolateyApps.ps1
############################################
# source: Find-ChocolateyApps.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Search the online repo for software

.DESCRIPTION
Search the online repo for software

.PARAMETER SearchString
What to search for

.EXAMPLE
Find-ChocolateyApps -SearchString Citrix

#>
Function Find-ChocolateyApps {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Find-ChocolateyApps')]
	PARAM(
		[ValidateNotNullOrEmpty()]
		[string]$SearchString
	)

	[System.Collections.ArrayList]$inst = @()

	choco search $SearchString --limit-output --order-by-popularity --source chocolatey | Select-Object -First 25 | ForEach-Object {
		$appdetail = (choco info ($_ -split '\|')[0])
		New-Object -TypeName psobject -Property @{
			id          = ($_ -split '\|')[0]
			Title       = ($appdetail[2].Split('|')[0].split(':')[1] | Out-String).Trim()
			Published   = [DateTime]($appdetail[2].Split('|')[1].split(':')[1] | Out-String).Trim()
  	Downloads   = ($appdetail[5].Split('|').split(':')[1] | Out-String).Trim()
			site        = $appdetail[10].Replace(' Software Site: ', '')
			Summary     = ($appdetail | Where-Object { $_ -like '*Summary*' }).replace(' Summary: ', '')
			Description = ($appdetail | Where-Object { $_ -like '*Description*' }).replace(' Description: ', '')
		} | Select-Object id, Title, Published, Downloads, site, Summary, Description
	} | Tee-Object -Variable inst

	$selected = $inst | Out-GridView -OutputMode Multiple
	Write-Color 'Apps Selected' -Color Green
	$selected.id
	$selected.id | Out-Clipboard

} #end Function
 
Export-ModuleMember -Function Find-ChocolateyApps
#endregion
 
#region Find-OnlineModule.ps1
############################################
# source: Find-OnlineModule.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Find a module on psgallery

.DESCRIPTION
Find a module on psgallery

.PARAMETER Keyword
What to search for

.PARAMETER install
install selected searched module

.EXAMPLE
Find-OnlineModule -Keyword Citrix -install


#>
function Find-OnlineModule {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineModule')]
	PARAM(
		[string]$Keyword,
		[switch]$install = $false
	)

	$selectedmod = Find-Module -Filter $Keyword -Repository PSGallery | Select-Object * | ForEach-Object {
		[PSCustomObject]@{
			Name                 = $_.Name
			Version              = $_.Version
			PublishedDate        = $_.PublishedDate
			UpdatedDate          = $_.AdditionalMetadata.updated
			downloadCount        = [int32]$_.AdditionalMetadata.downloadCount
			versionDownloadCount = [int32]$_.AdditionalMetadata.versionDownloadCount
			Authors              = $_.Author
			releaseNotes         = $_.ReleaseNotes
			tags                 = $_.Tags
			summary              = $_.AdditionalMetadata.summary
		} | Select-Object Name, version, PublishedDate, UpdatedDate , downloadCount, versionDownloadCount, Authors, releaseNotes, tags, summary
	} | Sort-Object -Property downloadCount -Descending | Out-GridView -OutputMode Multiple

	if ($install) {
		foreach ($item in $selectedmod) {
			Install-Module -Name $item.name -Scope CurrentUser -AllowClobber
			Get-Command -Module $item.name

		}
	}
}
 
Export-ModuleMember -Function Find-OnlineModule
#endregion
 
#region Find-OnlineScript.ps1
############################################
# source: Find-OnlineScript.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
function Find-OnlineScript {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-OnlineScript')]
	PARAM(
		[string]$Keyword,
		[switch]$install = $false
	)

	$selectedscript = Find-Script -Filter $Keyword -Repository PSGallery | Select-Object * | ForEach-Object {
		[PSCustomObject]@{
			Name                 = $_.Name
			Version              = $_.Version
			PublishedDate        = $_.PublishedDate
			UpdatedDate          = $_.AdditionalMetadata.lastUpdated
			downloadCount        = [int32]$_.AdditionalMetadata.downloadCount
			versionDownloadCount = [int32]$_.AdditionalMetadata.versionDownloadCount
			Authors              = $_.Author
			tags                 = $_.Tags
			summary              = $_.AdditionalMetadata.summary
		} | Select-Object Name, Version, PublishedDate, UpdatedDate , downloadCount, versionDownloadCount, Authors, tags, summary
	} | Sort-Object -Property downloadCount -Descending | Out-GridView -OutputMode Multiple

	if ($install) {
		foreach ($item in $selectedscript) {
			Install-Script -Name $item.name -Scope CurrentUser -AcceptLicense
		}
	}
}

 
Export-ModuleMember -Function Find-OnlineScript
#endregion
 
#region Find-PSScripts.ps1
############################################
# source: Find-PSScripts.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Find and update script info

.DESCRIPTION
Find and update script info

.PARAMETER Path
Path to scripts

.PARAMETER InHours
Changed in the last x hours

.PARAMETER SelectGrid
Display a out-grid view

.PARAMETER UpdateUnknown
Update if info is unknown

.PARAMETER NeedUpdate
Update if info is old

.PARAMETER UpdateAll
Update all

.EXAMPLE
Find-PSScripts -path . -SelectGrid

#>
Function Find-PSScripts {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Find-PSScripts')]
	PARAM(
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$Path = $pwd,
		[Parameter(Mandatory = $false)]
		[int]$InHours = 0,
		[switch]$SelectGrid = $false,
		[switch]$UpdateUnknown = $false,
		[switch]$NeedUpdate = $false,
		[switch]$UpdateAll = $false)

	try {
		$Path = Get-Item $Path
		$AllScripts = Get-ChildItem -Path $Path.fullname -Include *.ps1 -Recurse | Select-Object * -ErrorAction SilentlyContinue
	}
 catch { Write-Error 'invalid path' ; break }

	if ($InHours -gt 0) {
		$ChangedDate = (Get-Date) - (New-TimeSpan -Hours $InHours)
		$ModifiedScripts = $AllScripts | Where-Object { $_.LastWriteTime -gt $ChangedDate }
	}
 else { $ModifiedScripts = $AllScripts }

	$ScriptInfo = @()
	$ErrorFiles = @()
	foreach ($ModScript in $ModifiedScripts) {
		try {
			$currentinfo = $null
			$currentinfo = Test-ScriptFileInfo -Path $ModScript.FullName | Select-Object * -ErrorAction SilentlyContinue
		}
		catch { Write-Warning "$ModScript.Name: No Script Info found" }
		try {
			if ([bool]$currentinfo -eq $true) {
				[version]$Version = $currentinfo.Version
				$Description = $currentinfo.Description
				$Author = $currentinfo.Author
				[string[]]$tags = $currentinfo.tags
				$ReleaseNotes = @()
				try {
					$ReleaseNotes = $currentinfo.ReleaseNotes
					$LatestReleaseNotes = ($ReleaseNotes[-1].Split('[')[1].substring(0, 16)).split('_')
					$DateUploaded = Get-Date -Day $LatestReleaseNotes[0].Split('/')[0] -Month $LatestReleaseNotes[0].Split('/')[1] -Year $LatestReleaseNotes[0].Split('/')[2] -Hour $LatestReleaseNotes[1].Split(':')[0] -Minute $LatestReleaseNotes[1].Split(':')[1]
				}
				catch {
					$ReleaseNotes = 'Unknown'
					$LatestReleaseNotes = 'Unknown'
					$DateUploaded = (Get-Date).AddYears(-25)
				}
			}
			else {
				$Version = '0.0.0'
				$Description = 'Unknown'
				$Author = 'Unknown'
				$Tags = 'Unknown'
				$DateUploaded = 'Unknown'
			}


			$ScriptInfo += [PSCustomObject]@{
				Name             = $ModScript.Name
				Version          = $Version
				Author           = $Author
				Description      = $Description
				Tags             = [string[]]$tags
				ReleaseNotes     = $ReleaseNotes[-1]
				ScriptInfoUpdate = (Get-Date $DateUploaded -Format dd/MM/yyyy)
				DateCreated      = (Get-Date $ModScript.CreationTime -Format dd/MM/yyyy)
				DateLastUpdated  = (Get-Date $ModScript.LastWriteTime -Format dd/MM/yyyy)
				FullName         = $ModScript.fullname
			}
		}
		catch {
			Write-Warning "$($ModScript.Name) - Unable to get script info"
			$ErrorFiles += $ModScript
			$check = Read-Host 'Create it now? (y/n)'
			if ($check.ToUpper() -like 'Y')	{
				$search = Select-String -Path $ModScript.FullName -Pattern 'function'
				$tmpcontent = Get-Content -Path $ModScript.FullName
				$description = ((Get-Help $ModScript.basename).description | Out-String).Trim()
				if ([bool]$description -eq $false) { $description = $tmpcontent[([int]((Select-String -Path $ModScript.FullName -Pattern '.DESCRIPTION ' -SimpleMatch)[0].LineNumber))] }
				if ([bool]$description -eq $false) { $description = Read-Host description }
				$functioncontent = $tmpcontent[($search[0].LineNumber - 1)..($tmpcontent.Length)]
				$splat = @{
					Path         = $ModScript.fullname
					Version      = '0.1.0'
					Author       = 'Pierre Smit'
					Description  = $description
					Guid         = (New-Guid)
					CompanyName  = 'HTPCZA Tech'
					Tags         = 'ps'
					ReleaseNotes = 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initital Script Creating'
				}
				New-ScriptFileInfo @splat -Force -Verbose
				$newcontent = Get-Content -Path $ModScript.FullName | Where-Object { $_ -notlike 'Param()' }
				($newcontent + $functioncontent) | Set-Content -Path $ModScript.FullName
			}
		}
	}


	If ($UpdateUnknown) {
		$ScriptInfo | Where-Object Author -Like 'Unknown' | ForEach-Object {
			Write-Color -Text '[Processing]', $_.Name.ToString() -Color Yellow, Green
			Update-PSScriptInfo -Fullname $_.fullname -Author 'Pierre Smit' -Description (Read-Host 'Description') -tag (Read-Host 'tag') -ChangesMade (Read-Host 'Changes made')
		}
	}
	If ($UpdateAll) {
		$ScriptInfo | ForEach-Object {
			Write-Color -Text '[Processing]', $_.Name.ToString() -Color Yellow, Green
			Update-PSScriptInfo -Fullname $_.fullname -ChangesMade (Read-Host 'Changes made')
		}

	}

	if ($NeedUpdate) {
		$ScriptInfo | Where-Object { $_.DateLastUpdated -gt $_.ScriptInfoUpdate } | Select-Object Name, ScriptInfoUpdate, DateLastUpdated | Sort-Object -Property ScriptInfoUpdate | Format-Table -AutoSize
		$ScriptInfo | Where-Object { $_.DateLastUpdated -gt $_.ScriptInfoUpdate } | ForEach-Object {
			Write-Output $_.name
			Update-PSScriptInfo -Fullname $_.fullname -ChangesMade (Read-Host 'Changes made')
		}
	}

	if ($SelectGrid) {
		$select = $ScriptInfo | Out-GridView -OutputMode Multiple
		$select | ForEach-Object {
			Write-Output $_.name
			Update-PSScriptInfo -Fullname $_.fullname -Description (Read-Host 'Description') -tag (Read-Host 'tag') -ChangesMade (Read-Host 'Changes made')
		}
	}
	$ScriptInfo

 #end Function
}
 
Export-ModuleMember -Function Find-PSScripts
#endregion
 
#region Format-AllObjectsInAListView.ps1
############################################
# source: Format-AllObjectsInAListView.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Cast an array or psobject and display it in list view

.DESCRIPTION
Cast an array or psobject and display it in list view

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
 
#region Get-AllUsersInGroup.ps1
############################################
# source: Get-AllUsersInGroup.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
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
 
Export-ModuleMember -Function Get-AllUsersInGroup
#endregion
 
#region Get-CitrixClientVersions.ps1
############################################
# source: Get-CitrixClientVersions.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Get-CitrixClientVersions {
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
 
Export-ModuleMember -Function Get-CitrixClientVersions
#endregion
 
#region Get-CommandFiltered.ps1
############################################
# source: Get-CommandFiltered.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
	[Alias('fcmd')]
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
New-Alias -Name fcmd -Value Get-CommandFiltered -Description 'Filter Get-command with keyword' -Option AllScope -Force
 
Export-ModuleMember -Function Get-CommandFiltered
#endregion
 
#region Get-DeviceUptime.ps1
############################################
# source: Get-DeviceUptime.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Get-FolderSize.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
            [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/')]

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
############################################
# source: Get-FQDN.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
			[void]$outobject.add([pscustomobject]@{
					Host   = $($_)
					FQDN   = ([System.Net.Dns]::GetHostEntry(($($_)))).HostName
					Online = Test-Connection -ComputerName $(([System.Net.Dns]::GetHostEntry(($($_)))).HostName) -Quiet -Count 2
				})
		}
	}
	end {return $outobject}
} #end Function
 
Export-ModuleMember -Function Get-FQDN
#endregion
 
#region Get-FullADUserDetail.ps1
############################################
# source: Get-FullADUserDetail.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Extract handy info of an AD user

.DESCRIPTION
Extract handy info of an AD user

.PARAMETER UserToQuery
AD User name to search.

.EXAMPLE
Get-FullADUserDetail -UserToQuery ps

#>
Function Get-FullADUserDetail {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-FullADUserDetail')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$UserToQuery)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
	$UserSummery = Get-ADUser $UserToQuery -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
	$AllUserDetails = Get-ADUser $UserToQuery -Properties *
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] User Groups"
	$AllUserGroups = Get-ADUser $UserToQuery -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ }
	$CusObject = New-Object PSObject -Property @{
		DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		UserSummery    = $UserSummery
		AllUserDetails = $AllUserDetails
		AllUserGroups  = $AllUserGroups
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] User Details"
	$CusObject

} #end Function

 
Export-ModuleMember -Function Get-FullADUserDetail
#endregion
 
#region Get-MyPSGalleryStats.ps1
############################################
# source: Get-MyPSGalleryStats.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show stats about my published modules.

.DESCRIPTION
Show stats about my published modules.

.PARAMETER Display
How to display the output.

.EXAMPLE
Get-MyPSGalleryStats -Display TableView

#>
Function Get-MyPSGalleryStats {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [ValidateSet('GridView', 'TableView')]
        [string]$Display = 'Host'
    )

    [System.Collections.ArrayList]$newObject = @()
    $ResultModule = Find-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Repository PSGallery
    foreach ($mod in $ResultModule) {
        [void]$newObject.Add([PSCustomObject]@{
                Sum = [PSCustomObject]@{
                    Name            = $mod.Name
                    Version         = $mod.Version
                    Date            = [datetime]$mod.AdditionalMetadata.published
                    TotalDownload   = $mod.AdditionalMetadata.downloadCount
                    VersionDownload = $mod.AdditionalMetadata.versionDownloadCount
                }
                All = $mod
            })
    }
    if ($Display -like 'GridView') {$newObject.Sum | ConvertTo-WPFGrid}
    if ($Display -like 'TableView') {$newObject.Sum | Format-Table -AutoSize}
    if ($Display -like 'Host') {$newObject}


} #end Function


 
Export-ModuleMember -Function Get-MyPSGalleryStats
#endregion
 
#region Get-ProcessPerformance.ps1
############################################
# source: Get-ProcessPerformance.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Get-PropertiesToCSV.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Get-SoftwareAudit.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Get-SoftwareAudit')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = 'Set1')]
		[string[]]$ComputerName,
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $false)]
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { (Test-Path $_) })]
		[string]$ReportPath = "$env:TEMP"
	)
	$Software = foreach ($CompName in $ComputerName) {
		try {
			$rawdata = Invoke-Command -ComputerName $CompName -ScriptBlock {
				Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
				Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty
			}
			foreach ($item in $rawdata) {
				if (-not($null -eq $item.DisplayName)) {
					[pscustomobject]@{
						CompName        = $($item.PSComputerName)
						DisplayName     = $item.DisplayName
						DisplayVersion  = $item.DisplayVersion
						Publisher       = $item.Publisher
						EstimatedSize   = [Decimal]::Round([int]$item.EstimatedSize / 1024, 2)
						UninstallString = $item.UninstallString
					}
				}
			}
		}
		catch { Write-Warning "Error: $($_.Exception.Message)" }
	} 
	$Software = $Software | Sort-Object -Property DisplayName -Unique

	if ($Export -eq 'Excel') {
		$Software | Export-Excel -Path ($ReportPath + '\SoftwareAudit-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Show
	}
	if ($Export -eq 'HTML') { $Software | Out-GridHtml -DisablePaging -Title 'SoftwareAudit' -HideFooter -SearchHighlight -FixedHeader }
	if ($Export -eq 'Host') { $Software }


} #end Function
 
Export-ModuleMember -Function Get-SoftwareAudit
#endregion
 
#region Get-SystemInfo.ps1
############################################
# source: Get-SystemInfo.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } } -X 160px -Y 160px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 50% -Width 30% -Title 'Software' { New-HTMLTable -DataTable $SysInfo.Software @TableSettings } -X 190px -Y 190px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 20% -Width 50% -Title 'Network' { New-HTMLTable -DataTable $SysInfo.Network @TableSettings } -X 220px -Y 220px
                        New-HTMLWinBox -BackgroundColor '#00203F' -NoCloseIcon -NoFullScreenIcon -NoMinmizeIcon -NoMaximizeIcon -Theme modern -Height 70% -Width 20% -Title 'Services' { New-HTMLTable -DataTable $SysInfo.Services @TableSettings {
                                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Operator eq -Value 'Stopped' -Color GhostWhite -Row -BackgroundColor FaluRed } } -X 250px -Y 250px
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
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                                New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange
                                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Operator eq -Value 'Stopped' -Color GhostWhite -Row -BackgroundColor FaluRed
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
############################################
# source: Get-WinEventLogExtract.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
    [OutputType([System.Object[]])]
    PARAM(
        [string[]]$ComputerName = @($($env:COMPUTERNAME)),
        [int]$Days = 7,
        [validateset('Critical', 'Error', 'Warning', 'Informational')]
        [string]$ErrorLevel = 'Warning',
        [switch]$FilterCitrix = $false,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )
    [System.Collections.ArrayList]$AllEvents = @()
    $ComputerName | ForEach-Object {
        $comp = $_
        Write-Host 'Processing Events for server: ' -ForegroundColor Cyan -NoNewline
        Write-Host "$($comp)" -ForegroundColor Yellow
        if (-not(Test-Connection $comp -Count 2 -Quiet)) { Write-Warning "Unable to connect to $($comp)" }
        else {
            try {
                [hashtable]$filter = @{
                    StartTime = $((Get-Date).AddDays(-$days))
                }

                if ($FilterCitrix) { $filter.Add('ProviderName', '*Citrix*') }
                if ($ErrorLevel -like 'Critical') { $filter.Add('Level', @(1)) }
                if ($ErrorLevel -like 'Error') { $filter.Add('Level', @(1, 2)) }
                if ($ErrorLevel -like 'Warning') { $filter.Add('Level', @(1, 2, 3)) }
                if ($ErrorLevel -like 'Informational') { $filter.Add('Level', @(1, 2, 3, 4)) }

                $tmpNames = Get-WinEvent -ListLog * -ComputerName $comp | Where-Object { $_.IsEnabled -like 'True' -and $_.RecordCount -gt 0 -and $_.LogType -like 'Administrative' } | ForEach-Object {
                    [pscustomobject]@{
                        MachineName   = $comp
                        LogName       = $_.LogName
                        RecordCount   = $_.RecordCount
                        IsClassicLog  = $_.IsClassicLog
                        IsEnabled     = $_.IsEnabled
                        LogMode       = $_.LogMode
                        LogType       = $_.LogType
                        LastWriteTime = $_.LastWriteTime
                    }
                }
                $filter.Add('LogName',@("Application","System","Security","Setup") )
                $tmpEvents = Get-WinEvent -ComputerName $comp -FilterHashtable $filter | Select-Object MachineName, TimeCreated, UserId, Id, LevelDisplayName, LogName, ProviderName, Message

                [void]$AllEvents.Add([pscustomobject]@{
                        Host     = $comp
                        Lognames = $tmpNames
                        Events   = $tmpEvents
                    })
            } catch {Write-Warning "Error: `nMessage:$($_.Exception)`nItem:$($_.Exception.ItemName)"}
        }
    }

    if ($Export -eq 'Excel') {
        $AllEvents | ForEach-Object {
            $_.lognames | Export-Excel -Path ($ReportPath + "\$($_.host)-Events-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -WorksheetName LogNames -AutoSize -AutoFilter -Title "$($_.host)`'s Log Names" -TitleBold -TitleSize 20 -FreezePane 3
            $_.Events | Export-Excel -Path ($ReportPath + "\$($_.host)-Events-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "$($_.host)`'s Log Names" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot -FreezeTopRow -TableStyle Dark8 -BoldTopRow -ConditionalText $(
                New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' -PatternType Gray125
                New-ConditionalText -Text 'Error' -ConditionalTextColor white -BackgroundColor red -Range 'E:E' -PatternType Gray125
            ) -Show
        }
    }

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
            #AutoSize        = $true
            Style           = 'cell-border'
            ScrollX         = $true
            HideButtons     = $true
            HideFooter      = $true
            FixedHeader     = $true
            TextWhenNoData  = 'No Data to display here'
            #DisableSearch   = $true
            ScrollCollapse  = $true
            ScrollY         = $true
            DisablePaging   = $true
        }

        $AllEvents | ForEach-Object {
            $path = Get-Item $ReportPath
            $HTMLPath = Join-Path $Path.FullName -ChildPath "$($_.host)-WinEvents-$(Get-Date -Format yyyy.MM.dd-HH.mm).html"

            New-HTML -TitleText "$($_.host)-WinEvents" -FilePath $HTMLPath {
                New-HTMLHeader {
                    New-HTMLText -FontSize 28 -FontStyle oblique -Color '#00203F' -Alignment center -Text "$($_.host)"
                    New-HTMLText -FontSize 20 -FontStyle oblique -Color '#00203F' -Alignment center -Text "Date Collected: $(Get-Date)"
                }
                New-HTMLSection -HeaderText "Log Names [$($_.lognames.count)]" @SectionSettings -Collapsed {
                    New-HTMLSection -Invisible { New-HTMLTable -DataTable $($_.lognames) @TableSettings }
                }
                New-HTMLSection -HeaderText "Events [$($_.events.count)]" @SectionSettings -Collapsed {
                    New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.events) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-HTMLTableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }
                }
            } -Online -Encoding UTF8 -ShowHTML
        }
    }
    if ($Export -eq 'Host') { $AllEvents }

} #end Function


 
Export-ModuleMember -Function Get-WinEventLogExtract
#endregion
 
#region Import-CitrixSiteConfigFile.ps1
############################################
# source: Import-CitrixSiteConfigFile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
		[string]$CitrixSiteConfigFilePath = (Get-Item $profile).DirectoryName + '\Config\CTXSiteConfig.json'
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
############################################
# source: Import-XamlConfigFile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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

    Function Get-FormVariables {
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
 
#region Install-ChocolateyApps.ps1
############################################
# source: Install-ChocolateyApps.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Install-ChocolateyApps {
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
			Write-Color 'Installing App: ', $($app.name), ' from source ', $app.Source -Color Cyan, Yellow, Cyan, Yellow
			choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
			if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
		} else {
			Write-Color 'Using Installed App: ', $($ChocoApp.split('|')[0]), " -- (version: $($ChocoApp.split('|')[1]))" -Color Cyan, Green, Yellow
			if ($($ChocoApp.split('|')[1]) -lt $($ChocoAppOnline.split('|')[1])) {
				Write-Color 'Update Available: ', $($app.name), " (Version:$($ChocoAppOnline.split('|')[1]))", ' from source ', $app.Source -Color Cyan, green, Yellow, Cyan, Yellow
				choco upgrade $($app.name) --accept-license --limit-output -y | Out-Null
				if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing $($app.name) Code: $($LASTEXITCODE)"}
			}
		}
	}


} #end Function
 
Export-ModuleMember -Function Install-ChocolateyApps
#endregion
 
#region Install-ChocolateyClient.ps1
############################################
# source: Install-ChocolateyClient.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
    & "$($env:TEMP)\choco-install.ps1"
    Write-Color '[Installing] ', 'Chocolatey Client: ', 'Complete' -Color Cyan, Yellow, Green
    choco config set --name="'useEnhancedExitCodes'" --value="'true'"
    choco config set --name="'allowGlobalConfirmation'" --value="'true'"
    choco config set --name="'removePackageInformationOnUninstall'" --value="'true'"
    Write-Color '[Set] ', 'Chocolatey Client Config: ', 'Complete' -Color Cyan, Yellow, Green
  }
  else {
    Write-Color '[Installing] ', 'Chocolatey Client: ', 'Aleady Installed' -Color Cyan, Yellow, Green
  }
} #end Function
 
Export-ModuleMember -Function Install-ChocolateyClient
#endregion
 
#region Install-ChocolateyServer.ps1
############################################
# source: Install-ChocolateyServer.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Install-CitrixCloudConnector.ps1
############################################
# source: Install-CitrixCloudConnector.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Install Citrix cloud connector

.DESCRIPTION
Install Citrix cloud connector

.PARAMETER Customer_Id
Parameter description

.PARAMETER Client_Id
Parameter description

.PARAMETER Client_Secret
Parameter description

.PARAMETER Customer_Name
Parameter description

.EXAMPLE
Install-CitrixCloudConnector

#>
Function Install-CitrixCloudConnector {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-CitrixCloudConnector')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[string]$Customer_Id,
		[Parameter(Mandatory = $true)]
		[string]$Client_Id,
		[Parameter(Mandatory = $true)]
		[string]$Client_Secret,
		[Parameter(Mandatory = $true)]
		[string]$Customer_Name
	)

	## TODO Move script to ctxcloudapi module
	try {
		Import-Module CtxCloudAPI -Force -ErrorAction Stop
	}
 catch {
		Write-Warning 'Installing missing module CTXCloudApi'
		Install-Module -Name CTXCloudApi -Scope CurrentUser -Force -AllowClobber
		Import-Module CTXCloudApi -Force
	}

	$splat = @{
		Customer_Id   = $Customer_Id
		Client_Id     = $Client_Id
		Client_Secret = $Client_Secret
		Customer_Name = $Customer_Name
	}
	$APIHeader = Connect-CTXAPI @splat

	$ResourceLocationId = (Get-CTXAPI_ResourceLocations $APIHeader | Out-GridView -Title 'Resource Locations' -OutputMode Single).id

	if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

	$uri = 'https://downloads.cloud.com/dcintab5def1/connector/cwcconnector.exe'
	$outputfile = 'C:\Temp\cwcconnector.exe'
	Write-Host 'Dowloading latest release' -ForegroundColor Cyan
	Invoke-WebRequest -Uri $uri -OutFile $outputfile

	Write-Host 'Installing Cloud connector' -ForegroundColor Yellow
	Start-Process -FilePath $outputfile -ArgumentList "/q /Customer:$Customer_ID  /ClientId:$Client_id  /ClientSecret:$Client_id  /ResourceLocationId:$ResourceLocationId  /AcceptTermsOfService:$true" -NoNewWindow -Wait

	Get-CTXAPI_CloudConnectors -APIHeader $apiheader | Select-Object fqdn, location, status, lastContactDate, inMaintenance | Format-Table -AutoSize

} #end Function
 
Export-ModuleMember -Function Install-CitrixCloudConnector
#endregion
 
#region Install-MSWinget.ps1
############################################
# source: Install-MSWinget.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Install-PS7.ps1
############################################
# source: Install-PS7.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
 Install PS7 on the device

.DESCRIPTION
 Install PS7 on the device

.EXAMPLE
 Install-PS7

.NOTES
General notes
#>
function Install-PS7 {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PS7')]
	PARAM()
 if ((Test-Path 'C:\Program Files\PowerShell\7') -eq $false) {
	 Install-PowerShell -Mode Quiet -EnableRemoting -EnableContextMenu -EnableRunContext
	 Write-Host 'PowerShell 7 Installation:' -ForegroundColor Cyan -NoNewline
	 Write-Host 'Successfull' -ForegroundColor Yellow
	}
 else {
	 Write-Host 'PowerShell 7 Installation:' -ForegroundColor Cyan -NoNewline
 	Write-Host 'Already Installed' -ForegroundColor Yellow
	}
}
 
Export-ModuleMember -Function Install-PS7
#endregion
 
#region Install-PSModules.ps1
############################################
# source: Install-PSModules.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
 Install modules from .json file.

.DESCRIPTION
 Install modules from .json file.

.PARAMETER BaseModules
Only base list.

.PARAMETER ExtendedModules
Use longer list.

.PARAMETER Scope
Scope to install modules (CurrentUser or AllUsers).

.PARAMETER OtherModules
Use Manual list.

.PARAMETER JsonPath
Path to manual list.

.PARAMETER ForceInstall
Force reinstall.

.PARAMETER UpdateModules
Update the modules.

.PARAMETER RemoveAll
Remove the modules.

.EXAMPLE
Install-PSModules -BaseModules -Scope AllUsers

#>
Function Install-PSModules {
	[Cmdletbinding(DefaultParameterSetName = 'base', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSModules')]
	PARAM(
		[Parameter(ParameterSetName = 'base')]
		[switch]$BaseModules = $false,
		[Parameter(ParameterSetName = 'ext')]
		[switch]$ExtendedModules = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[validateset('CurrentUser', 'AllUsers')]
		[string]$Scope = 'CurrentUser',
		[Parameter(ParameterSetName = 'other')]
		[switch]$OtherModules = $false,
		[Parameter(ParameterSetName = 'other')]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JsonPath,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$ForceInstall = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$UpdateModules = $false,
		[Parameter(ParameterSetName = 'base')]
		[Parameter(ParameterSetName = 'ext')]
		[Parameter(ParameterSetName = 'other')]
		[switch]$RemoveAll = $false
	)

	$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
	try {
		$ConPath = Get-Item $ConfigPath
	} catch { Write-Error 'Config path foes not exist'; exit }
	if ($BaseModules) { $ModuleList = (Join-Path $ConPath.FullName -ChildPath BaseModuleList.json) }
	if ($ExtendedModules) { $ModuleList = (Join-Path $ConPath.FullName -ChildPath ExtendedModuleList.json) }
	if ($OtherModules) { $ModuleList = Get-Item $JsonPath }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$mods = Get-Content $ModuleList | ConvertFrom-Json
	if ($RemoveAll) {
		try {
			$mods | ForEach-Object { Write-Host 'Uninstalling Module:' -ForegroundColor Cyan -NoNewline; Write-Host $_.Name -ForegroundColor red
				Get-Module -Name $_.Name -ListAvailable | Uninstall-Module -AllVersions -Force
			}
		} catch { Write-Error "Error Uninstalling $($mod.Name)" }
	}
	if ($UpdateModules) {
		try {
			$mods | ForEach-Object { Write-Host 'Updating Module:' -ForegroundColor Cyan -NoNewline; Write-Host $_.Name -ForegroundColor yello
				Get-Module -Name $_.Name -ListAvailable | Select-Object -First 1 | Update-Module -Force
			}
		} catch { Write-Error "Error Updating $($mod.Name)" }
	}

	foreach ($mod in $mods) {
		if ($ForceInstall -eq $false) { $PSModule = Get-Module -Name $mod.Name -ListAvailable | Select-Object -First 1 }
		if ($PSModule.Name -like '') {
			Write-Host 'Installing Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $mod.Name -ForegroundColor Yellow
			Install-Module -Name $mod.Name -Scope $Scope -AllowClobber -Force
		} else {
			Write-Host 'Using Installed Module:' -ForegroundColor Cyan -NoNewline
			Write-Host "$PSModule.Name - $PSModule.Path" -ForegroundColor Yellow
		}
	}
}
 
Export-ModuleMember -Function Install-PSModules
#endregion
 
#region Install-PSWinUpdates.ps1
############################################
# source: Install-PSWinUpdates.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Install windows updates

.DESCRIPTION
Install windows updates

.EXAMPLE
Install-PSWinUpdates

#>
function Install-PSWinUpdates {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-PSWinUpdates')]
	PARAM()
	Try {
		Install-WindowsUpdate -MicrosoftUpdate -UpdateType Software -AcceptAll -IgnoreReboot
		Install-WindowsUpdate -MicrosoftUpdate -UpdateType Driver -AcceptAll -IgnoreReboot

		Test-PendingReboot -ComputerName $env:computername
	} catch {Write-Warning "Error Updating: `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
}
 
Export-ModuleMember -Function Install-PSWinUpdates
#endregion
 
#region Install-RSAT.ps1
############################################
# source: Install-RSAT.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Install All Remote Support Tools

.DESCRIPTION
Install All Remote Support Tools

.EXAMPLE
Install-RSAT

#>
Function Install-RSAT {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-RSAT')]
	PARAM()

	$checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
	if ($checkver -notlike '*server*') {
		Write-Host 'Installing RSAT on device type:' -ForegroundColor Cyan -NoNewline
		Write-Host 'Workstation' -ForegroundColor red

		$currentInstalled = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.state -like 'Installed' } | Select-Object -Property DisplayName, State, name
		Write-Host 'Currenly Installed RSAT modules:' -ForegroundColor Cyan
		$currentInstalled | ForEach-Object { Write-Host $_.DisplayName -ForegroundColor Green }

		Write-Host ' '
		Write-Host '------------------------------------------------------'
		Write-Host ' '
		Write-Host 'Installing remaining RSAT modules:' -ForegroundColor Cyan
		$currentmissing = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.state -notlike 'Installed' } | Select-Object -Property DisplayName, State, name
		$currentmissing | ForEach-Object {
			Write-Host $_.DisplayName -ForegroundColor Green
			Add-WindowsCapability -Name $_.name -Online
		}
	}
 else {
		Write-Host 'Installing RSAT on device type:' -ForegroundColor Cyan -NoNewline
		Write-Host 'Server' -ForegroundColor red

		$currentInstalled = Get-WindowsFeature | Where-Object { $_.name -like 'RSAT*' -and $_.InstallState -like 'Installed' } | Select-Object DisplayName, InstallState, name
		Write-Host 'Currenly Installed RSAT modules:' -ForegroundColor Cyan
		$currentInstalled | ForEach-Object { Write-Host $_.DisplayName -ForegroundColor Green }

		Write-Host ' '
		Write-Host '------------------------------------------------------'
		Write-Host ' '
		Write-Host 'Installing remaining RSAT modules:' -ForegroundColor Cyan
		$currentmissing = Get-WindowsFeature | Where-Object { $_.name -like 'RSAT*' -and $_.InstallState -notlike 'Installed' } | Select-Object DisplayName, InstallState, name
		$currentmissing | ForEach-Object {
			Write-Host $_.DisplayName -ForegroundColor Green
			Install-WindowsFeature -Name $_.name -IncludeAllSubFeature
		}

	}

} #end Function
 
Export-ModuleMember -Function Install-RSAT
#endregion
 
#region Install-SSHServer.ps1
############################################
# source: Install-SSHServer.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Install and setup OpenSSH on device.

.DESCRIPTION
Install and setup OpenSSH on device.

.PARAMETER AddPowerShellSubsystem
Add the ps subsystem to the ssh config file.

.EXAMPLE
 Install-SSHServer

#>
Function Install-SSHServer {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-SSHServer')]
	PARAM(
		[switch]$AddPowerShellSubsystem = $false
	)
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
		$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
		$request = [System.Net.WebRequest]::Create($url)
		$request.AllowAutoRedirect = $false
		$response = $request.GetResponse()
		$DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + '/OpenSSH-Win64.zip'
		$OutFile = $env:TEMP + '\OpenSSH-Win64.zip'
		Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile -Verbose
		if (Test-Path 'C:\Program Files\OpenSSH-Win64') { Rename-Item -Path 'C:\Program Files\OpenSSH-Win64' -NewName OpenSSH-Win64-old -Force }
		New-Item 'C:\Program Files\OpenSSH-Win64' -ItemType Directory -Force
		Expand-Archive -Path $OutFile -OutputPath 'C:\Program Files\OpenSSH-Win64' -ShowProgress -FlattenPaths
	} else {
		Get-ChocoPackage -Name openssh -Exact | Install-ChocoPackage -Force
	}
	Import-Module 'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'
	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
	'sshd', 'ssh-agent' | Set-Service -StartupType Automatic -Status Running -Verbose

	$SSHConf = Get-Content "$env:ProgramData\ssh\sshd_config"
	$NewSSHConf = $SSHConf -replace ('#PasswordAuthentication yes', 'PasswordAuthentication yes')
	$NewSSHConf = $NewSSHConf -replace ('#PubkeyAuthentication yes', 'PubkeyAuthentication yes')
	$NewSSHConf | Set-Content "$env:ProgramData\ssh\sshd_config" -Force
	'sshd', 'ssh-agent' | Get-Service | Stop-Service
	'sshd', 'ssh-agent' | Get-Service | Start-Service -Verbose

	if ($AddPowerShellSubsystem) {
		$PowerShellPath = (Get-Command -Name pwsh.exe).Path
		$fso = New-Object -ComObject Scripting.FileSystemObject
		$NewSSHConf += ' '
		$NewSSHConf += '# Required (Windows): Define the PowerShell subsystem'
		$NewSSHConf += 'Subsystem powershell ' + $fso.GetFile($PowerShellPath).ShortPath + ' -sshs -NoLogo'
		$NewSSHConf | Set-Content "$env:ProgramData\ssh\sshd_config" -Force

		'sshd', 'ssh-agent' | Get-Service | Stop-Service
		'sshd', 'ssh-agent' | Get-Service | Start-Service -Verbose

	}

} #end Function

 
Export-ModuleMember -Function Install-SSHServer
#endregion
 
#region Install-WindowsTerminal.ps1
############################################
# source: Install-WindowsTerminal.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Install Windows Terminal from GitHub on any OS

.DESCRIPTION
Install Windows Terminal from GitHub on any OS

.EXAMPLE
Install-WindowsTerminal

#>
Function Install-WindowsTerminal {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-WindowsTerminal')]

    PARAM(				)
    $package = Get-AppxPackage -Name Microsoft.WindowsTerminal
    if ($package.Status -like 'OK') { Write-Color 'Windows Terminal: ', 'Already Installed' -Color Cyan, Yellow }
    else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = 'https://github.com/microsoft/terminal/releases/latest/'
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $ver = ($([String]$response.GetResponseHeader('Location')).split('/'))[-1].Replace('v', '')
        $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + "/Microsoft.WindowsTerminal_$($ver)_8wekyb3d8bbwe.msixbundle"
        $OutFile = [IO.Path]::Combine('c:\temp', 'MSTerminal-latest.msixbundle')

        if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

        Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile
        Add-AppxPackage -Path $OutFile -ForceUpdateFromAnyVersion -InstallAllResources

    }
    $package = Get-AppxPackage -Name Microsoft.WindowsTerminal
    if ($package.Status -like 'OK') {
        Write-Color 'Windows Terminal: ', 'Installation Successful' -Color Cyan, Green
        $settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', $((Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName), 'LocalState', 'Settings.json')

        Invoke-WebRequest -Uri 'https://git.io/JMTRv' -OutFile $settingsFile
        Write-Color 'Windows Terminal Settings: ', 'Installation Successful' -Color Cyan, Green

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = 'https://github.com/microsoft/cascadia-code/releases/latest/'
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $ver = ($([String]$response.GetResponseHeader('Location')).split('/'))[-1].Replace('v', '')
        $DownloadLink = $([String]$response.GetResponseHeader('Location')).Replace('tag', 'download') + "/CascadiaCode-$($ver).zip"
        $OutFile = [IO.Path]::Combine('c:\temp', 'CascadiaCode.zip')
        $ExpandDir = New-Item ([IO.Path]::Combine('c:\temp', 'CascadiaCode')) -ItemType Directory -Force
        $ttf = [IO.Path]::Combine('c:\temp', 'CascadiaCode', 'ttf', 'CascadiaCodePL.ttf')

        Invoke-WebRequest -Uri $DownloadLink -OutFile $OutFile -Verbose
        Expand-Archive -Path $OutFile -OutputPath $ExpandDir -ShowProgress

        $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
        $tt = Get-Item $ttf
        $tt | ForEach-Object { $fonts.CopyHere($_.fullname) }

        Write-Color 'Windows Terminal Fonts: ', 'Installation Successful' -Color Cyan, Green

    }
    else { Write-Color 'Windows Terminal Settings: ', 'Installation Failed' -Color Cyan, red }

} #end Function
 
Export-ModuleMember -Function Install-WindowsTerminal
#endregion
 
#region New-CitrixSiteConfigFile.ps1
############################################
# source: New-CitrixSiteConfigFile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
 All a config file with Citrix server details. To be imported as variables.

.DESCRIPTION
 All a config file with Citrix server details. To be imported as variables.

.EXAMPLE
New-CitrixSiteConfigFile

#>
Function New-CitrixSiteConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-CitrixSiteConfigFile')]

	$path = Read-Host 'Where to save the config file'
	if (Test-Path $path) { $fullname = (Get-Item $path).FullName }
	else { Throw 'Path does not exist' }


	[System.Collections.ArrayList]$DataColectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Data Collector'
		if ($null -notlike $tmpobj) {
			[void]$DataColectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$CloudConnectors = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Cloud Connectors'
		if ($null -notlike $tmpobj) {
			[void]$CloudConnectors.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$storefont = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix StoreFont'
		if ($null -notlike $tmpobj) {
			[void]$storefont.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$Director = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Citrix Director'
		if ($null -notlike $tmpobj) {
			[void]$Director.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$VDA = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'VDA Test Boxes'
		if ($null -notlike $tmpobj) {
			[void]$VDA.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	[System.Collections.ArrayList]$Other = @()
	$UserInput = ''
	While ($UserInput.ToLower() -ne 'n') {
		$tmpobj = $null
		$tmpobj = Read-Host 'Other Servers'
		if ($null -notlike $tmpobj) {
			[void]$Other.Add("$((Get-FQDN -ComputerName $tmpobj).FQDN)")
			$UserInput = Read-Host 'Add more? (y/n)'
		} else {$UserInput = 'n'}
	}

	$RDSLicenseServer = $((Get-FQDN -ComputerName (Read-Host 'RDS License Server') ).FQDN)
	try {
		$site = Get-BrokerSite -AdminAddress $DataColectors[0] -ErrorAction Stop
		$DDCDetails = Get-BrokerController -AdminAddress $DataColectors[0] | Select-Object -First 1 -ErrorAction Stop
		$CTXLicenseServer = $site.LicenseServerName
		$siteName = $site.Name
		$funcionlevel = $site.DefaultMinimumFunctionalLevel
		$version = $DDCDetails.ControllerVersion
	} catch {
		Write-Warning 'Unable to connect to the Farm.'
		$CTXLicenseServer = $((Get-FQDN -ComputerName (Read-Host 'Citrix License Server') ).FQDN)
		$siteName = Read-Host 'Site Name'
		$funcionlevel = 'Unknown'
		$version = 'Unknown'
		$site = 'Unknown'
		$DDCDetails = 'Unknown'
	}


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
		}
	}

	$CTXSiteDetails

	if (Test-Path (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json')) {
		Write-Warning 'Config File Exists, renaming the old config file.'
		Rename-Item -Path (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json') -NewName "CTXSiteConfig_$(Get-Date -Format yyyyMMdd_HHmm).json"
	}
	$CTXSiteDetails | ConvertTo-Json | Out-File (Join-Path -Path $fullname -ChildPath 'CTXSiteConfig.json') -Encoding utf8
} #end Function
 
Export-ModuleMember -Function New-CitrixSiteConfigFile
#endregion
 
#region New-ElevatedShortcut.ps1
############################################
# source: New-ElevatedShortcut.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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

.EXAMPLE
New-ElevatedShortcut -ShortcutName blah -FilePath cmd.exe

#>
Function New-ElevatedShortcut {
	[Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/New-ElevatedShortcut')]

	PARAM(
		[Parameter(Mandatory = $true)]
		[string]$ShortcutName,
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.ps1') -or ((Get-Item $_).Extension -eq '.exe') })]
		[string]$FilePath
	)

	$ScriptInfo = Get-Item $FilePath

	if ($ScriptInfo.Extension -eq '.ps1') {
		$taskActionSettings = @{
			Execute  = 'powershell.exe'
			Argument = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File ""$($ScriptInfo.FullName)"" -Verb RunAs"
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

	Start-Process -FilePath explorer.exe -ArgumentList $($ScriptInfo.DirectoryName)

} #end Function
 
Export-ModuleMember -Function New-ElevatedShortcut
#endregion
 
#region New-GodModeFolder.ps1
############################################
# source: New-GodModeFolder.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
	[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSToolKit/New-GodModeFolder")]
                PARAM()


$link = New-Item -Path ([Environment]::GetFolderPath('Desktop')) -Name 'God Mode .{ED7BA470-8E54-465E-825C-99712043E01C}' -ItemType directory -Force

explorer.exe $link

} #end Function
 
Export-ModuleMember -Function New-GodModeFolder
#endregion
 
#region New-PSModule.ps1
############################################
# source: New-PSModule.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: New-PSProfile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSProfile')]
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

    foreach ($folder in $folders) {
        if (-not(Test-Path ([IO.Path]::Combine($folder.FullName, 'Config')))) { New-Item ([IO.Path]::Combine($folder.FullName, 'Config')) -ItemType Directory | Out-Null }

        if (Test-Path ([IO.Path]::Combine($folder.FullName, $ise))) { Move-Item ([IO.Path]::Combine($folder.FullName, $ise)) -Destination ([IO.Path]::Combine($folder.FullName, 'Config', "ISEProfile-$(Get-Date -Format yyyy-MM-dd).ps1")) -Force }
        if (Test-Path ([IO.Path]::Combine($folder.FullName, $ps))) { Move-Item ([IO.Path]::Combine($folder.FullName, $ps)) -Destination ([IO.Path]::Combine($folder.FullName, 'Config', "PSProfile-$(Get-Date -Format yyyy-MM-dd).ps1")) -Force }
        if (Test-Path ([IO.Path]::Combine($folder.FullName, $vscode))) { Move-Item ([IO.Path]::Combine($folder.FullName, $vscode)) -Destination ([IO.Path]::Combine($folder.FullName, 'Config', "VSCodeProfile-$(Get-Date -Format yyyy-MM-dd).ps1"))-Force }

        $ModModules = Get-Module PSToolKit
        if (-not($ModModules)) { $ModModules = Get-Module PSToolKit -ListAvailable }
        if (-not($ModModules)) { throw 'Module not found' }

        $NewFile = @"
#Force TLS 1.2 for all connections
if (`$PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

#Enable concise errorview for PS7 and up
if (`$psversiontable.psversion.major -ge 7) {
    `$ErrorView = 'ConciseView'
}

`$PRModule = get-item `"$((Join-Path ((Get-Item $ModModules.ModuleBase).Parent).FullName "\*\$($ModModules.name).psm1"))`"
Import-Module `$PRModule.FullName -Force
Start-PSProfile

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
############################################
# source: New-PSScript.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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

.EXAMPLE
$properverb-$propernoun

#>
Function $properverb-$propernoun {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/$modulename/$properverb-$propernoun")]
	    [OutputType([System.Object[]])]
                PARAM(
					[Parameter(Mandatory = `$true)]
					[Parameter(ParameterSetName = 'Set1')]
					[ValidateScript( { (Test-Path `$_) -and ((Get-Item `$_).Extension -eq ".csv") })]
					[System.IO.FileInfo]`$InputObject = "c:\temp\tmp.csv",
					[ValidateNotNullOrEmpty()]
					[string]`$Username,
					[ValidateSet('Excel', 'HTML')]
					[string]`$Export = 'Host',
                	[ValidateScript( { if (Test-Path `$_) { `$true }
                                else { New-Item -Path `$_ -ItemType Directory -Force | Out-Null; `$true }
                        })]
                	[System.IO.DirectoryInfo]`$ReportPath = 'C:\Temp',
					[ValidateScript({`$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            						if (`$IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {`$True}
            						else {Throw "Must be running an elevated prompt to use ClearARPCache"}})]
        			[switch]`$ClearARPCache,
        			[ValidateScript({if (Test-Connection -ComputerName `$_ -Count 2 -Quiet) {`$true}
                            		else {throw "Unable to connect to `$(`$_)"} })]
        			[string[]]`$ComputerName
					)



	if (`$Export -eq 'Excel') { `$data | Export-Excel -Path `$(Join-Path -Path `$ReportPath -ChildPath "\$propernoun-`$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
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
 
#region New-SuggestedInfraNames.ps1
############################################
# source: New-SuggestedInfraNames.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function New-SuggestedInfraNames {
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
 
Export-ModuleMember -Function New-SuggestedInfraNames
#endregion
 
#region Remove-CIMUserProfiles.ps1
############################################
# source: Remove-CIMUserProfiles.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Remove-CIMUserProfiles {
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
 
Export-ModuleMember -Function Remove-CIMUserProfiles
#endregion
 
#region Remove-FaultyProfileList.ps1
############################################
# source: Remove-FaultyProfileList.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Remove-HiddenDevices.ps1
############################################
# source: Remove-HiddenDevices.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
function Remove-HiddenDevices {
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
 
Export-ModuleMember -Function Remove-HiddenDevices
#endregion
 
#region Remove-UserProfile.ps1
############################################
# source: Remove-UserProfile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Restore-ElevatedShortcut.ps1
############################################
# source: Restore-ElevatedShortcut.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
    [Cmdletbinding(DefaultParameterSetName = 'Set1'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Restore-ElevatedShortcut')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [Parameter(ParameterSetName = 'Set1')]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.zip') })]
        [System.IO.FileInfo]$ZipFilePath,
        [switch]$ForceReinstall = $false
				)

    if ((Test-Path -Path C:\Temp) -eq $false) { New-Item -Path C:\Temp -ItemType Directory -Force -ErrorAction SilentlyContinue }

    Expand-Archive $ZipFilePath -DestinationPath C:\Temp -Force
    $files = Get-ChildItem C:\temp\Tasks\*.xml
    foreach ($file in $files) {
        $checktask = $null
        try {
            if ($ForceReinstall) { Get-ScheduledTask -TaskName "$($file.BaseName)" -TaskPath '\RunAs\' | Unregister-ScheduledTask -Confirm:$false }
            $checktask = Get-ScheduledTaskInfo "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
        }
        catch { $checktask = $null }
        if ( $null -eq $checktask) {
            try {
                Write-Host 'Task:' -ForegroundColor Cyan -NoNewline
                Write-Host "$($file.BaseName)" -ForegroundColor red
                [xml]$importfile = Get-Content $file.FullName
                $sid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).value
                $importfile.Task.Principals.Principal.UserId = $sid
                Register-ScheduledTask -Xml ($importfile.OuterXml | Out-String) -TaskName "\RunAs\$($file.BaseName)" -ErrorAction SilentlyContinue
            }
            Catch { Write-Warning "$($_.BaseName) - wrong domain" }
            finally { Write-Warning "$($_.BaseName)" }
        }
    }
    Remove-Item -Path C:\Temp\Tasks -Recurse

} #end Function
 
Export-ModuleMember -Function Restore-ElevatedShortcut
#endregion
 
#region Search-Scripts.ps1
############################################
# source: Search-Scripts.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
FUNCTION Search-Scripts {
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
 
Export-ModuleMember -Function Search-Scripts
#endregion
 
#region Set-PSProjectFiles.ps1
############################################
# source: Set-PSProjectFiles.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates and modify needed files for a PS project from existing module files.

.DESCRIPTION
Creates and modify needed files for a PS project from existing module files.

.PARAMETER ModulePSM1
Path to module .psm1 file.

.PARAMETER VersionBump
This will increase the version of the module.

.PARAMETER mkdocs
Create and test the mkdocs site

.EXAMPLE
Set-PSProjectFiles -ModulePSM1 c:\temp\blah.psm1 -VersionBump Minor -mkdocs serve

#>
Function Set-PSProjectFiles {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSProjectFiles')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psm1') })]
		[System.IO.FileInfo]$ModulePSM1,
		[ValidateSet('Minor', 'Build', 'CombineOnly')]
		[string]$VersionBump = 'None',
		[ValidateSet('serve', 'gh-deploy')]
		[string]$mkdocs = 'None'
	)

	#region module
	Write-Color '[Starting]', 'Module Import' -Color Yellow, DarkCyan
 try {

		if ($VersionBump -like 'Minor' -or $VersionBump -like 'Build' ) {
			$ModuleManifestFileTMP = Get-Item ((Get-Item $ModulePSM1).FullName.Replace('psm1', 'psd1'))
			[version]$ModuleversionTMP = (Test-ModuleManifest -Path $ModuleManifestFileTMP.FullName).version

			if ($VersionBump -like 'Minor') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, ($ModuleversionTMP.Minor + 1), $ModuleversionTMP.Build }
			if ($VersionBump -like 'Build') { [version]$ModuleversionTMP = '{0}.{1}.{2}' -f $ModuleversionTMP.Major, $ModuleversionTMP.Minor, ($ModuleversionTMP.Build + 1) }

			$ModuleFunctionFile = Get-Item $ModulePSM1
			$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			if ((Get-Module $module.Name).count -gt 1) {
				Remove-Module $module.Name -Force | Out-Null
				$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			}
			$manifestProperties = @{
				Path              = $ModuleManifestFileTMP.FullName
				ModuleVersion     = $ModuleversionTMP
				FunctionsToExport = (Get-Command -Module $module.Name | Select-Object name).name | Sort-Object
			}
			Update-ModuleManifest @manifestProperties
		} else {
			$ModuleFunctionFile = Get-Item $ModulePSM1
			$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			if ((Get-Module $module.Name).count -gt 1) {
				Remove-Module $module.Name -Force | Out-Null
				$module = Import-Module $ModuleFunctionFile.FullName -Force -PassThru
			}
		}
		$ModuleManifestFile = Get-Item ($ModuleFunctionFile.FullName.Replace('psm1', 'psd1'))
		$ModuleManifest = Test-ModuleManifest -Path $ModuleManifestFile.FullName | Select-Object *
	} catch { Write-Error 'Unable to load module.'; exit }

	Write-Color '[Starting]', 'Creating Folder Structure' -Color Yellow, DarkCyan
	$ModuleBase = Get-Item ((Get-Item $ModuleFunctionFile.Directory).Parent).FullName
	$ModuleOutput = [IO.Path]::Combine($ModuleBase, 'Output', $($ModuleManifest.Version.ToString()))
	$Moduledocs = [IO.Path]::Combine($ModuleBase, 'docs', 'docs')
	$ModuleExternalHelp = [IO.Path]::Combine($ModuleOutput, 'en-US')
	$ModulesInstuctions = [IO.Path]::Combine($ModuleBase, 'instructions.md')
	$ModuleReadme = [IO.Path]::Combine($ModuleBase, 'README.md')
	$ModuleIssues = [IO.Path]::Combine($ModuleBase, 'Issues.md')
	$ModuleIssuesExcel = [IO.Path]::Combine($ModuleBase, 'Issues.xlsx')
	$ModulePublicFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Public') | Get-Item
	$ModulePrivateFunctions = [IO.Path]::Combine($ModuleFunctionFile.PSParentPath, 'Private') | Get-Item
	$ModuleMkdocs = [IO.Path]::Combine($ModuleBase, 'docs', 'mkdocs.yml')
	$ModfuleIndex = [IO.Path]::Combine($ModuleBase, 'docs', 'docs', 'index.md')
	[System.Collections.ArrayList]$Issues = @()
	[System.Collections.ArrayList]$ScriptAnalyzerIssues = @()
	#endregion

	function exthelp {
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'Output'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'Output')) -Recurse -Force }
		if (Test-Path ([IO.Path]::Combine($ModuleBase, 'docs'))) { Remove-Item ([IO.Path]::Combine($ModuleBase, 'docs')) -Recurse -Force }
		if (Test-Path $ModuleReadme) { Remove-Item $ModuleReadme -Force }
		if (Test-Path $ModuleIssues) { Remove-Item $ModuleIssues -Force }
		if (Test-Path $ModuleIssuesExcel) { Remove-Item $ModuleIssuesExcel -Force }
		if (Test-Path $ModuleMkdocs) { Remove-Item $ModuleMkdocs -Force }

		$ModuleOutput = New-Item $ModuleOutput -ItemType Directory -Force | Get-Item
		$Moduledocs = New-Item $Moduledocs -ItemType Directory -Force | Get-Item
		$ModuleExternalHelp = New-Item $ModuleExternalHelp -ItemType Directory -Force | Get-Item


		#region platyps
		Write-Color '[Starting]', 'Creating External help files' -Color Yellow, DarkCyan
		$markdownParams = @{
			Module         = $module.Name
			OutputFolder   = $Moduledocs.FullName
			WithModulePage = $false
			Locale         = 'en-US'
			HelpVersion    = $ModuleManifest.Version.ToString()
		}
		New-MarkdownHelp @markdownParams

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

		New-ExternalHelp -Path $Moduledocs.FullName -OutputPath $ModuleExternalHelp.FullName -Force -ShowProgress

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
	(Get-Command -Module $module).Name | ForEach-Object { ($aboutfile.Add("`t $_ -- $((Get-Help $_).synopsis)")) }
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
	(Get-Command -Module $module).Name | ForEach-Object { $readme.add("- [$_](https://smitpi.github.io/$($module.Name)/#$_) -- " + (Get-Help $_).SYNOPSIS) }
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
		$mkdocsFunc | Set-Content -Path $ModuleMkdocs -Force

		$indexFile = [System.Collections.Generic.List[string]]::new()
		Get-Content -Path $ModulesInstuctions | ForEach-Object { $indexFile.add($_) }
		$indexFile.add(' ')
		$indexFile.add('## Functions')
	(Get-Command -Module $module).Name | ForEach-Object { $indexFile.add("- [$_](https://smitpi.github.io/$($module.Name)/#$_) -- " + (Get-Help $_).SYNOPSIS) }
		$indexFile | Set-Content -Path $ModfuleIndex -Force
		#endregion
	}
	function ScriptAnalyzer {
		#region ScriptAnalyzer
		$Listissues = $Null
		$ExcludeRules = @(
			'PSMissingModuleManifestField',
			'PSAvoidUsingWriteHost',
			'PSUseSingularNouns',
			'PSReviewUnusedParameter'
		)
		Write-Color '[Starting]', 'PSScriptAnalyzer' -Color Yellow, DarkCyan
		Invoke-ScriptAnalyzer -Path $ModulePublicFunctions -Recurse -OutVariable Listissues -ExcludeRule $ExcludeRules | Out-Null

		foreach ($item in $Listissues) {
			Write-Color "$($item.scriptname): ", $($item.Message) -Color Cyan, Yellow
			[void]$ScriptAnalyzerIssues.Add([PSCustomObject]@{
					Catagory = 'ScriptAnalyzer'
					File     = $item.scriptname
					RuleName = $item.RuleName
					line     = $item.line
					Message  = $item.Message
				})
		}
		#endregion
	}
	function combine {
		#region copy files
		Write-Color '[Starting]', 'Creating new module files' -Color Yellow, DarkCyan

		$ModuleOutput = Get-Item $ModuleOutput
		$rootModule = ([IO.Path]::Combine($ModuleOutput.fullname, "$($module.Name).psm1"))

		Copy-Item -Path $ModuleManifestFile.FullName -Destination $ModuleOutput.fullname -Force
		$PrivateFiles = Get-ChildItem -Path $ModulePrivateFunctions.FullName -Exclude *.ps1
		if ($null -notlike $PrivateFiles) {
			Copy-Item -Path $ModulePrivateFunctions.FullName -Destination $ModuleOutput.fullname -Recurse -Exclude *.ps1 -Force
		}

		$public = @(Get-ChildItem -Path "$($ModulePublicFunctions.FullName)\*.ps1" -Recurse -ErrorAction Stop)
		$private = @(Get-ChildItem -Path "$($ModulePrivateFunctions.FullName)\*.ps1" -ErrorAction Stop)
		$file = [System.Collections.Generic.List[string]]::new()
		$file.add('#region Private Functions')
		foreach ($privateitem in $private) {
			$file.Add('########### Private Function ###############')
			$file.Add("# source: $($privateitem.name)")
			$file.Add("# Module: $($module.Name)")
			$file.Add('############################################')
			Write-Color '[Processing]: ', $($privateitem.name) -Color Cyan, Yellow
			Get-Content $privateitem.fullname | ForEach-Object { $file.add($_) }
		}
		$file.add('#endregion')
		$file.add('#region Public Functions')
		foreach ($publicitem in $public) {
			$file.add("#region $($publicitem.name)")
			$file.Add('############################################')
			$file.Add("# source: $($publicitem.name)")
			$file.Add("# Module: $($module.Name)")
			$file.Add("# version: $($moduleManifest.version)")
			$file.Add("# Author: $($moduleManifest.author)")
			$file.Add("# Company: $($moduleManifest.CompanyName)")
			$file.Add('#############################################')
			$file.Add(' ')
			Write-Color '[Processing]: ', $($publicitem.name) -Color Cyan, Yellow

			[int]$StartIndex = (Select-String -InputObject $publicitem -Pattern '.SYNOPSIS*').LineNumber[0] - 2
			[int]$EndIndex = (Get-Content $publicitem.FullName).length
			Get-Content -Path $publicitem.FullName | Select-Object -Index ($StartIndex..$EndIndex) | ForEach-Object { $file.Add($_) }
			$file.Add(' ')
			$file.Add("Export-ModuleMember -Function $($publicitem.BaseName)")
			$file.add('#endregion')
			$file.Add(' ')
		}
		$file.add('#endregion')
		$file | Set-Content -Path $rootModule -Encoding utf8 -Force

		$newfunction = ((Select-String -Path $rootModule -Pattern '^# source:').Line).Replace('# source:', '').Replace('.ps1', '').Trim()
		$ModCommands = Get-Command -Module $module | ForEach-Object { $_.name }

		Compare-Object -ReferenceObject $ModCommands -DifferenceObject $newfunction | ForEach-Object {
			[void]$Issues.Add([PSCustomObject]@{
					Catagory = 'Not Copied'
					File     = $_.InputObject
					details  = $_.SideIndicator
				})
		}
	}
	function mkdocs {
		#region mkdocs
		Write-Color '[Starting]', 'mkdocs' -Color Yellow, DarkCyan
		if ($mkdocs -like 'serve') {
			Set-Location (Split-Path -Path $Moduledocs -Parent)
			Start-Process mkdocs serve
			Start-Sleep 5
			Start-Process "http://127.0.0.1:8000/$($module.Name)/"
		}
		if ($mkdocs -like 'gh-deploy') {
			Set-Location (Split-Path -Path $Moduledocs -Parent)
			Start-Process mkdocs gh-deploy
		}
		#endregion
	}

	if ($VersionBump -like 'CombineOnly') { 
		combine
		mkdocs
	} else {
		exthelp
		ScriptAnalyzer
		combine
		mkdocs
	}
	if ($null -notlike $ScriptAnalyzerIssues) { $ScriptAnalyzerIssues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName ScriptAnalyzer -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PivotTableName Summery -PivotRows RuleName -PivotData Message }
	if ($null -notlike $Issues) { $issues | Export-Excel -Path $ModuleIssuesExcel -WorksheetName Other -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow }

	#endregion

} #end Function
 
Export-ModuleMember -Function Set-PSProjectFiles
#endregion
 
#region Set-PSToolKitSystemSettings.ps1
############################################
# source: Set-PSToolKitSystemSettings.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Set multiple settings on desktop or server

.DESCRIPTION
Set multiple settings on desktop or server

.PARAMETER RunAll
Enable all the options in this function.

.PARAMETER ExecutionPolicy
Set ps execution policy to unrestricted.

.PARAMETER PSGallery
Enable and set PS gallery to defaults

.PARAMETER ForcePSGallery
Force the reinstall of ps gallery

.PARAMETER IntranetZone
Setup intranet zones for mapped drives.

.PARAMETER IntranetZoneIPRange
Setup intranet zones for mapped drives from ip addresses.

.PARAMETER PSTrustedHosts
Set trusted hosts to domain servers.

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

.PARAMETER InstallVMWareTools
Install VMware tools if device is a VM.

.PARAMETER InstallAnsibleRemote
Configure ps remoting for ansible.

.PARAMETER EnableNFSClient
Install NFS Client.

.EXAMPLE
Set-PSToolKitSystemSettings -RunAll

#>
Function Set-PSToolKitSystemSettings {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-PSToolKitSystemSettings')]
    PARAM(
        [switch]$RunAll,
        [switch]$ExecutionPolicy,
        [switch]$PSGallery,
        [switch]$ForcePSGallery,
        [switch]$IntranetZone,
        [switch]$IntranetZoneIPRange,
        [switch]$PSTrustedHosts,
        [switch]$FileExplorerSettings,
        [switch]$DisableIPV6,
        [switch]$DisableFirewall,
        [switch]$DisableInternetExplorerESC,
        [switch]$DisableServerManager,
        [switch]$EnableRDP,
        [switch]$InstallVMWareTools,
        [switch]$InstallAnsibleRemote,
        [switch]$EnableNFSClient
    )

    if ($RunAll) {
        $ExecutionPolicy = $PSGallery = $IntranetZone = $IntranetZoneIPRange = $PSTrustedHosts = $FileExplorerSettings = $DisableIPV6 = $DisableFirewall = $DisableInternetExplorerESC = $DisableServerManager = $EnableRDP = $InstallVMWareTools = $InstallAnsibleRemote = $EnableNFSClient = $true
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

    if ($PSGallery) {
        if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
            try {
                $wc = New-Object System.Net.WebClient
                $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

                Install-PackageProvider Nuget -Force | Out-Null
                Register-PSRepository -Default | Out-Null
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

                $BaseModules = @('PowerShellGet', 'PackageManagement')
                foreach ($base in $BaseModules) {
                    Install-Module -Name $base -Force -AllowClobber -Scope AllUsers
                    Import-Module $base -Force
                    Get-Module $base | Update-Module -Force -PassThru
                    Import-Module $base -Force
                }

                Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
            } catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
        } else {Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, DarkRed}
    }

    if ($ForcePSGallery) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            Install-PackageProvider Nuget -Force | Out-Null
            Register-PSRepository -Default | Out-Null
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

            $BaseModules = @('PowerShellGet', 'PackageManagement')
            foreach ($base in $BaseModules) {
                Install-Module -Name $base -Force -AllowClobber -Scope AllUsers
                Import-Module $base -Force
                Get-Module $base | Update-Module -Force -PassThru
                Import-Module $base -Force
            }

            Write-Color '[Set]', 'PSGallery: ', 'Complete' -Color Yellow, Cyan, Green
            else { Write-Color '[Set]', 'PSGallery: ', 'Already Set' -Color Yellow, Cyan, Magenta }
        } catch { Write-Warning "[Set]PSGallery: Failed:`n $($_.Exception.Message)" }
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
                if ((Test-Path -Path $key) -eq $false ) { New-Item -Path $parent -ItemType File -Name 'Domains' }
                New-Item -Path $key -ItemType File -Name "$LocalIntranetSite"
                Set-ItemProperty -Path $CompRegPath -Name 'file' -Value $DWord
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
                if (-not(Test-Path -Path $Key)) { New-Item -Path $parent -ItemType File -Name 'Ranges'}
                if (-not(Test-Path -Path $keychild)) {
                    New-Item -Path $key -ItemType File -Name "Range$($index)"
                    Set-ItemProperty -Path $keychild -Name 'file' -Value $DWord
                    Set-ItemProperty -Path $keychild -Name ':Range' -Value "$($ipdata[0]).$($ipdata[1]).$($ipdata[2]).*"
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
        } catch { Write-Warning "[Set]File Explorer Settings: Failed:`n $($_.Exception.Message)" }

    } #end if

    if ($InstallVMWareTools) {
        try {
            if ((Get-CimInstance -ClassName win32_bios).Manufacturer -like '*VMware*') {
                Install-ChocolateyClient
                Write-Color 'Installing App: ', 'vmware-tools', ' from source ', 'chocolatey' -Color Cyan, Yellow, Cyan, Yellow
                choco upgrade vmware-tools --accept-license --limit-output -y --source chocolatey | Out-Null
                if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing vmware-tools Code: $($LASTEXITCODE)"}
            } else {Write-Color '[Installing]', 'VMWare Tools:', ' Not a VMWare VM' -Color Yellow, Cyan, DarkRed}
        } catch { Write-Warning "[Installing] VMWare Tools: Failed:`n $($_.Exception.Message)" }

    }

    if ($InstallAnsibleRemote) {
        try {
            $web = New-Object System.Net.WebClient
            $web.DownloadFile('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1', "$($env:TEMP)\ConfigureRemotingForAnsible.ps1")
            & "$($env:TEMP)\ConfigureRemotingForAnsible.ps1"

            Write-Color '[Installing] ', 'Ansible Remote: ', 'Complete' -Color Yellow, Cyan, Green
        } catch { Write-Warning "[Installing]Ansible Remote: Failed:`n $($_.Exception.Message)" }

    } #end

    if ($EnableNFSClient) {
        try {
            if ((Get-WindowsOptionalFeature -Online -FeatureName *nfs*).state -contains 'Disabled') {
                $checkver = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object caption
                if ($checkver -like '*server*') {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ServerAndClient' -All
                } else {
                    Enable-WindowsOptionalFeature -Online -FeatureName 'ServicesForNFS-ClientOnly' -All
                }
                Enable-WindowsOptionalFeature -Online -FeatureName 'ClientForNFS-Infrastructure' -All
                Enable-WindowsOptionalFeature -Online -FeatureName 'NFS-Administration' -All
                nfsadmin client stop
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousUID' -Type DWord -Value 0
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -Name 'AnonymousGID' -Type DWord -Value 0
                nfsadmin client start
                nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
                Write-Color 'Useage:', 'mount -o anon <server>:/<path> <drive letter>' -Color Cyan, DarkCyan
                Write-Color '[Installing] ', 'NFS Client: ', 'Complete' -Color Yellow, Cyan, Green
            } else {
                Write-Color '[Installing] ', 'NFS Client: ', 'Already Installed' -Color Yellow, Cyan, DarkRed
            }
        } catch { Write-Warning "[Installing] NFS Client: Failed:`n $($_.Exception.Message)" }
    } #end

} #end Function
 
Export-ModuleMember -Function Set-PSToolKitSystemSettings
#endregion
 
#region Set-SharedPSProfile.ps1
############################################
# source: Set-SharedPSProfile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Redirects PowerShell profile to network share.

.DESCRIPTION
Redirects PowerShell profile to network share.

.PARAMETER PathToSharedProfile
The new path.

.EXAMPLE
Set-SharedPSProfile PathToSharedProfile "\\nas01\profile"

#>
function Set-SharedPSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Set-SharedPSProfile')]
	param (
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( {
				if (-Not (Test-Path $_) ) { stop }
				$true
			})]
		[string[]]$PathToSharedProfile
	)

	$PersonalDocuments = [Environment]::GetFolderPath('MyDocuments')
	$PersonalPSFolder = $PersonalDocuments + '\WindowsPowerShell'
	if ((Test-Path $PersonalPSFolder) -eq $true ) {
		Write-Warning 'Folder exists, renamig now...'
		Rename-Item -Path $PersonalPSFolder -NewName "WindowsPowerShell-$(Get-Random)" -Force -Verbose
	}

	if ((Test-Path $PersonalPSFolder) -eq $false ) {
		New-Item -ItemType SymbolicLink -Name WindowsPowerShell -Path $PersonalDocuments -Value (Get-Item $PathToSharedProfile).FullName

		Write-Host 'Move PS Profile to the shared location: ' -ForegroundColor Cyan -NoNewline
		Write-Host Completed -ForegroundColor green
	}
 else {
		Write-Warning "$($PersonalPSFolder) Already Exists, remove old profile fist"
	}
}

 
Export-ModuleMember -Function Set-SharedPSProfile
#endregion
 
#region Set-StaticIP.ps1
############################################
# source: Set-StaticIP.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Set-TempFolder.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Set-WindowsAutoLogin.ps1
############################################
# source: Set-WindowsAutoLogin.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Show-ComputerManagement.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Show-PSToolKit.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show details of the commands in this module

.DESCRIPTION
Show details of the commands in this module

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
        [switch]$ShowCommand = $false,
        [switch]$ExportToHTML = $false
    )

    Write-Color 'Collecting Command Details' -Color DarkCyan
    Remove-Module -Name PSToolKit -Force -ErrorAction SilentlyContinue
    $module = Get-Module -Name PSToolKit
    if (-not($module)) { $module = Get-Module -Name PSToolKit -ListAvailable }
    $latestModule = $module | Sort-Object -Property version -Descending | Select-Object -First 1
    [string]$version = (Test-ModuleManifest -Path $($latestModule.Path.Replace('psm1', 'psd1'))).Version

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

    if ($ShowCommand) {
        $select = $commands | Select-Object Name, Description | Out-GridView -OutputMode Single
        Show-Command -Name $select.name
    }

    if (!$ShowCommand) {
        $out = ConvertTo-ASCIIArt -Text 'PSToolKit' -Font basic
        $out += "`n"
        $out += ConvertTo-ASCIIArt -Text $version -Font basic
        $out += "`n"
        $out += ("Module Path: $($module.Path)" | Out-String)
        Add-Border -TextBlock $out -Character % -ANSIBorder "$([char]0x1b)[38;5;47m" -ANSIText "$([char]0x1b)[93m"

        foreach ($item in ($commands.verb | Sort-Object -Unique)) {
            Write-Color 'Verb:', $item -Color Cyan, Red -StartTab 1 -LinesBefore 1
            $filtered = $commands | Where-Object { $_.Verb -like $item }
            foreach ($filter in $filtered) {
                Write-Color "$($filter.name)", ' - ', $($filter.Description) -Color Gray, Red, Yellow

            }
        }
    }

    if ($ExportToHTML) {
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
                        $filtered | ForEach-Object { New-HTMLContent -Invisible -Content {
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
 
#region Start-PSModuleMaintenance.ps1
############################################
# source: Start-PSModuleMaintenance.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
			}
			catch { $OnlineModule = $null }
			$moduleReport.Add([pscustomobject]@{
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

		if ($ListUpdateAvailable) { return $moduleReport | Where-Object { $_.Update -like 'UpdateAvailable' } }
		if ($PerformUpdate) {
			$moduleReport | Where-Object { $_.Update -like 'ListUpdateAvailable' } | ForEach-Object {
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
					}
					catch {
						Write-Warning "Unable to uninstall $($removemod.name):`n $($_.Exception.Message)"
						if ($ForceRemove) {
							try {
								Write-Color "[$($removemod.name)]", "[$(((Get-Item $removemod.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
								Remove-Item -Path (Get-Item $removemod.Path).Directory -Recurse -Force
							}
							catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
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
			}
			catch { Write-Warning "Unable to remove:`n $($_.Exception.Message)" }
			try {
				if (Test-Path (Get-Item $dup.Path).Directory) {
					Write-Color "[$($dup.name)]", "[$(((Get-Item $dup.Path).Directory).FullName)]", 'Force Remove Directory' -Color Yellow, DarkCyan, Red
					Remove-Item -Path ((Get-Item $dup.Path).Directory).FullName -Recurse -Force -ErrorAction Stop
				}
			}
			catch { Write-Warning "Unable to delete directory:`n $($_.Exception.Message)" }
		}

		Write-Color 'Reinstall Module:' -Color Cyan
		$duplicates.name | Sort-Object -Unique | ForEach-Object {
			try {
				Write-Color "[$($_)]" -Color Yellow
				Install-Module -Name $_ -Scope AllUsers -AllowClobber -Force -ErrorAction Stop
			}
			catch { Write-Warning "Unable to install from:`n $($_.Exception.Message)" }
		}
	}
} #end Function
 
Export-ModuleMember -Function Start-PSModuleMaintenance
#endregion
 
#region Start-PSProfile.ps1
############################################
# source: Start-PSProfile.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
My PS Profile for all sessions.

.DESCRIPTION
My PS Profile for all sessions.

.PARAMETER ClearHost
Clear the screen before loading.

.PARAMETER AddFun
Add fun details in the output.

.PARAMETER GalleryStats
Stats about my published modules..

.PARAMETER ShowModuleList
Summary of installed modules.

.PARAMETER ShortenPrompt
Shorten the command prompt for more coding space.

.EXAMPLE
Start-PSProfile -ClearHost

#>
Function Start-PSProfile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSProfile')]
	PARAM(
		[switch]$ClearHost = $false,
		[switch]$AddFun = $false,
		[switch]$GalleryStats = $false,
		[switch]$ShowModuleList = $false,
		[switch]$ShortenPrompt = $false
	)
	<##>
	$ErrorActionPreference = 'Stop'

	if ($ClearHost) { Clear-Host }

	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$psfolder = (Get-Item $profile).DirectoryName
	} else { $psfolder = (Get-Item $profile).DirectoryName }

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	try {
		## Create folders for PowerShell profile
		if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory | Out-Null }
		if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory | Out-Null }
	} catch { Write-Warning 'Unable to create default folders' }

	try {
		$ProdModules = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\PowerShell\ProdModules)
		if (Test-Path $ProdModules) {
			Set-Location $ProdModules
		} else {
			$ScriptFolder = (Join-Path $([Environment]::GetFolderPath('MyDocuments')) -ChildPath .\WindowsPowerShell\Scripts) | Get-Item
			Set-Location $ScriptFolder
		}
	} catch { Write-Warning 'Unable to set location' }

	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
	Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
	Write-Host (' {0,23} ' -f 'Loading Functions') -ForegroundColor DarkRed
	Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray

	try {
		Set-PSReadLineOption -PredictionSource History -HistorySearchCursorMovesToEnd -HistorySaveStyle SaveIncrementally -ShowToolTips -BellStyle Visual -HistorySavePath "$([environment]::GetFolderPath('ApplicationData'))\Microsoft\Windows\PowerShell\PSReadLine\history.txt"
		Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadLineKeyHandler -Key 'Ctrl+m' -Function ForwardWord
		Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
		Write-Host (' {0,-36}: ' -f 'PSReadLineOptions Functions') -ForegroundColor Cyan -NoNewline
		Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
	} catch { Write-Warning 'PSReadLineOptions: Could not be loaded' }

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
 if ($AddFun) {
	 try {
			$chuck = (Invoke-RestMethod -Uri https://api.chucknorris.io/jokes/random?category=dev).value
			Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'Chuck Detail') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'Chuck gave up...' }

		try {
			$weather = Invoke-RestMethod 'https://weatherdbi.herokuapp.com/data/weather/Johannesburg'
			Write-Host ('[Loading]') -ForegroundColor Yellow -NoNewline
			Write-Host (' {0,-36}: ' -f 'Weather') -ForegroundColor Cyan -NoNewline
			Write-Host ('{0,-20}' -f 'Complete') -ForegroundColor Green
		} catch { Write-Warning 'Error on weather' }
	}

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

	if ($AddFun) {
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'Fun Stuff') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,-35}: ' -f 'Current weather') -ForegroundColor Cyan -NoNewline
		Write-Host (' {0,-20} ' -f "$($weather.currentConditions.comment) | Temperature:$($weather.currentConditions.temp.c)°C | Wind:$($weather.currentConditions.wind.km)km/h |") -ForegroundColor Green
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,-35}: ' -f 'Chuck Noris in Dev:') -ForegroundColor Cyan -NoNewline
		Write-Host (' {0,-20} ' -f "$($chuck)") -ForegroundColor Green
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
 }

 if ($GalleryStats) {
		Write-Host ("[$((Get-Date -Format HH:mm:ss).ToString())]") -ForegroundColor DarkYellow -NoNewline
		Write-Host (' {0,15} ' -f 'My PSGallery Stats') -ForegroundColor DarkRed
		Write-Host '--------------------------------------------------------' -ForegroundColor DarkGray
		Write-Host "$((Get-MyPSGalleryStats -Display TableView) | Out-String)" -ForegroundColor Green
 }

	if ($ShortenPrompt) {
		Function prompt {
			$location = $executionContext.SessionState.Path.CurrentLocation.path
			#what is the maximum length of the path before you begin truncating?
			$len = 10

			if ($location.length -gt $len) {

				#split on the path delimiter which might be different on non-Windows platforms
				$dsc = [system.io.path]::DirectorySeparatorChar
				#escape the separator character to treat it as a literal
				#filter out any blank entries which might happen if the path ends with the delimiter
				$split = $location -split "\$($dsc)" | Where-Object { $_ -match '\S+' }
				#reconstruct a shorted path
				$here = "{0}$dsc{1}...$dsc{2}" -f $split[0], $split[1], $split[-1]

			} else {
				#length is ok so use the current location
				$here = $location
			}

			"PS $here$('>' * ($nestedPromptLevel + 1)) "
			# .Link
			# https://go.microsoft.com/fwlink/?LinkID=225750
			# .ExternalHelp System.Management.Automation.dll-help.xml

		}
	}

} #end Function
 
Export-ModuleMember -Function Start-PSProfile
#endregion
 
#region Start-PSRoboCopy.ps1
############################################
# source: Start-PSRoboCopy.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
        [void]$RoboArgs.Add('/COPYALL')
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
 
#region Start-PSToolkitSystemInitialize.ps1
############################################
# source: Start-PSToolkitSystemInitialize.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Initialize a blank machine.

.DESCRIPTION
Initialize a blank machine with PSToolKit tools and dependencies.

.PARAMETER LabSetup
Commands only for my HomeLab

.PARAMETER InstallMyModules
Install my other published modules.

.EXAMPLE
Start-PSToolkitSystemInitialize -InstallMyModules

#>
Function Start-PSToolkitSystemInitialize {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Start-PSToolkitSystemInitialize')]
	PARAM(
		[switch]$LabSetup = $false,
		[switch]$InstallMyModules = $false
	)

	$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Powershell Script Execution' -ForegroundColor Yellow
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope Process
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser

	Write-Host '[Setting]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Powershell Gallery' -ForegroundColor Yellow
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted' ) {
		$null = Install-PackageProvider Nuget -Force
		$null = Register-PSRepository -Default -ErrorAction SilentlyContinue
		$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	}
	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Needed Powershell modules' -ForegroundColor Yellow

	"ImportExcel", "PSWriteHTML", "PSWriteColor", "PSScriptTools", "PoshRegistry", "Microsoft.PowerShell.Archive" | ForEach-Object {
		$module = $_
		if (-not(get-module $module) -and -not(get-module $module -ListAvailable)) {
			try {
			Write-Host '[Installing] Module: ' -NoNewline -ForegroundColor Cyan; Write-Host "$($module)" -ForegroundColor Yellow
			Install-Module -Name $module -Scope AllUsers -AllowClobber -ErrorAction stop
			} catch {Write-Warning "Error installing module $($module): `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
		}
	}

	Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'PSToolKit Module' -ForegroundColor Yellow
	$web = New-Object System.Net.WebClient
	$web.DownloadFile('https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Update-PSToolKit.ps1', "$($env:TEMP)\Update-PSToolKit.ps1")
	$full = Get-Item "$($env:TEMP)\Update-PSToolKit.ps1"
	Import-Module $full.FullName -Force
	Update-PSToolKit -AllUsers
	Remove-Item $full.FullName

	Import-Module PSToolKit -Force
	if ($LabSetup) {
		New-PSProfile
		Set-PSToolKitSystemSettings -ExecutionPolicy
		Set-PSToolKitSystemSettings -PSGallery
		Set-PSToolKitSystemSettings -IntranetZone
		Set-PSToolKitSystemSettings -IntranetZoneIPRange
		Set-PSToolKitSystemSettings -PSTrustedHosts
		Set-PSToolKitSystemSettings -FileExplorerSettings
		Set-PSToolKitSystemSettings -DisableIPV6
		Set-PSToolKitSystemSettings -DisableFirewall
		Set-PSToolKitSystemSettings -DisableInternetExplorerESC
		Set-PSToolKitSystemSettings -DisableServerManager
		Set-PSToolKitSystemSettings -EnableRDP
		Set-PSToolKitSystemSettings -InstallVMWareTools
		Set-PSToolKitSystemSettings -InstallAnsibleRemote
		Set-PSToolKitSystemSettings -EnableNFSClient
		Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule
		Install-PSModules -BaseModules
		Install-PS7
		Install-ChocolateyClient
		Add-ChocolateyPrivateRepo -RepoName Proget -RepoURL http://progetserver.internal.lab/nuget/htpcza-choco/ -Priority 1
		Install-ChocolateyApps -BaseApps
	}
	if ($InstallMyModules) {
		Write-Host '[Installing]: ' -NoNewline -ForegroundColor Cyan; Write-Host 'Installing Other Modules' -ForegroundColor Yellow
		Install-Module CTXCloudApi, PSConfigFile, PSLauncher, XDHealthCheck -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
	}
	Start-PSProfile -ClearHost -AddFun -ShowModuleList
} #end Function
 
Export-ModuleMember -Function Start-PSToolkitSystemInitialize
#endregion
 
#region Sync-PSFolders.ps1
############################################
# source: Sync-PSFolders.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Compare two directories and copy the differences

.DESCRIPTION
Compare two directories and copy the differences. Newest file wins

.PARAMETER LeftFolder
First Folder to compare

.PARAMETER RightFolder
Second folder to compare

.PARAMETER SetLongPathRegKey
Enable long file path in registry

.EXAMPLE
Sync-PSFolders -LeftFolder C:\Temp\one -RightFolder C:\Temp\6

.NOTES
General notes
#>
function Sync-PSFolders {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Sync-PSFolders')]
	Param(
		[parameter(Mandatory = $true)]
		[System.IO.DirectoryInfo]$LeftFolder,
		[parameter(Mandatory = $true)]
		[System.IO.DirectoryInfo]$RightFolder,
		[switch]$SetLongPathRegKey = $false
	)

	function Write-Log {
		param(
			[ValidateSet('Debug', 'Information', 'Warning', 'Error')]
			[string]$Severity = 'Information',
			[ValidateNotNullOrEmpty()]
			[string]$Message,
			[ValidateNotNullOrEmpty()]
			[string]$LogPath,
			[ValidateNotNullOrEmpty()]
			[switch]$ExportFinal = $false
		)

		$object = [PSCustomObject]@{
			Time     = '[' + (Get-Date -f g) + '] '
			Severity = "[$Severity] "
			Message  = $Message
		} | Select-Object Time, Severity, Message


		[array]$script:ExportLogs += $object

		if ($script:ExportLogs[-1].Severity -notlike '*Debug*') { $script:ExportLogs[-1] | Format-Table -HideTableHeaders -RepeatHeader -Wrap }

		if ($ExportFinal) {
			$script:ExportLogs | Format-Table -AutoSize
		}

	}

	$ErrorActionPreference = 'Stop'
	if ($SetLongPathRegKey) { Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1; Get-Process explorer | Stop-Process }
	[array]$script:ExportLogs = @()
	if (!(Test-Path $LeftFolder)) { write-log -Severity Warning -Message "Creating $($LeftFolder)"; New-Item $LeftFolder -ItemType Directory | Out-Null }
	if (!(Test-Path $RightFolder)) { write-log -Severity Warning -Message "Creating $($RightFolder)"; New-Item $RightFolder -ItemType Directory | Out-Null }

	try {
		$LeftFolder = Get-Item $LeftFolder
		$RightFolder = Get-Item $RightFolder
		write-log -Severity Information -Message 'Collecting Left Folder Content'
		$LeftFolderContent = Get-ChildItem -Path $($LeftFolder.FullName) -Recurse -ErrorAction Stop
		write-log -Severity Information -Message 'Collecting Right Folder Content'
		$RightFolderContent = Get-ChildItem -Path $($RightFolder.FullName) -Recurse -ErrorAction Stop
	}
	catch { Write-Log -Severity Error -Message "Object = $($_.TargetObject)"; Write-Log -Severity Error -Message "ErrorDetail = $($_.Exception.Message)" }


	#if ($LeftFolder.FullName -like "*\\*") {$LeftFolderContent = Get-ChildItem -LiteralPath "\\?\UNC\$($LeftFolder.FullName.Replace('\\',''))" -Recurse -ErrorAction Stop} else {$LeftFolderContent = Get-ChildItem -LiteralPath "\\?\$($LeftFolder.FullName)" -Recurse -ErrorAction Stop }
	#if ($RightFolder.FullName -like "*\\*") {$RightFolderContent = Get-ChildItem -LiteralPath "\\?\UNC\$($RightFolder.FullName.Replace('\\',''))" -Recurse -ErrorAction Stop} else {$RightFolderContent = Get-ChildItem -LiteralPath "\\?\$($RightFolder.FullName)" -Recurse -ErrorAction Stop }

	try {
		if ($null -eq $LeftFolderContent) {
			write-log -Severity Warning -Message "$($LeftFolder) is empty, copying all files"
			Copy-Item "$RightFolder\*" -Destination $LeftFolder.FullName -Recurse -PassThru | ForEach-Object { Write-Log -Severity Debug -Message "$($_.fullname)" }
			$LeftFolderContent = Get-ChildItem -Path $($LeftFolder.FullName) -Recurse -ErrorAction Stop

		}
		if ($null -eq $RightFolderContent) {
			write-log -Severity Warning -Message "$($RightFolder) is empty, copying all files"
			Copy-Item "$LeftFolder\*" -Destination $RightFolder.FullName -Recurse -PassThru | ForEach-Object { Write-Log -Severity Debug -Message "$($_.fullname)" }
			$RightFolderContent = Get-ChildItem -Path $($RightFolder.FullName) -Recurse -ErrorAction Stop

		}

	}
	catch { Write-Log -Severity Error -Message "Object = $($_.TargetObject)"; Write-Log -Severity Error -Message "ErrorDetail = $($_.Exception.Message)" }

	try {
		write-log -Severity Information -Message 'Comparing the folder stucture'
		$1stdir = (($LeftFolderContent | Where-Object { $_.Attributes -like 'Directory' }).FullName).Replace($($LeftFolder.FullName), '')
		$2ndDir = (($RightFolderContent | Where-Object { $_.Attributes -like 'Directory' }).FullName).Replace($($RightFolder.FullName), '')

		$DirDiffs = Compare-Object -ReferenceObject $1stdir -DifferenceObject $2ndDir | Sort-Object -Property SideIndicator | Sort-Object -Property InputObject
		foreach ($Dir in $Dirdiffs) {
			if ($Dir.SideIndicator -eq '=>') {
				Write-Log -Severity Debug -Message "Creating folder $(Join-Path $LeftFolder.FullName -ChildPath $Dir.InputObject)"
				New-Item -Path (Join-Path $LeftFolder.FullName -ChildPath $Dir.InputObject) -ItemType Directory
			}
			if ($Dir.SideIndicator -eq '<=') {
				Write-Log -Severity Debug -Message "Creating folder $(Join-Path $LeftFolder.FullName -ChildPath $Dir.InputObject)"
				New-Item -Path (Join-Path $RightFolder.FullName -ChildPath $Dir.InputObject) -ItemType Directory
			}
		}
	}
	catch { Write-Log -Severity Error -Message "Object = $($_.TargetObject)"; Write-Log -Severity Error -Message "ErrorDetail = $($_.Exception.Message)" }

	write-log -Severity Information -Message 'Comparing the file structure'
	$1stFileList = (($LeftFolderContent | Where-Object { $_.Attributes -notlike 'Directory' }).FullName).Replace($($LeftFolder.FullName), '')
	$2ndFileList = (($RightFolderContent | Where-Object { $_.Attributes -notlike 'Directory' }).FullName).Replace($($RightFolder.FullName), '')
	$FileDiffs = Compare-Object -ReferenceObject $1stFileList -DifferenceObject $2ndFileList -IncludeEqual | Sort-Object -Property SideIndicator | Sort-Object -Property InputObject
	foreach (${File} in ${Filediffs}) {
		try {
			if ($file.SideIndicator -like '=>') {
				$Copyfile = Get-Item (Join-Path $RightFolder.FullName -ChildPath $File.InputObject)
				Write-Log -Severity Debug -Message "Copying $($Copyfile.FullName) to $($Copyfile.DirectoryName.Replace($RightFolder.FullName, $LeftFolder.FullName))"
				Copy-Item -Path $Copyfile.FullName -Destination ($Copyfile.DirectoryName.Replace($RightFolder.FullName, $LeftFolder.FullName))
			}
			if ($file.SideIndicator -like '<=') {
				$Copyfile = Get-Item (Join-Path $LeftFolder.FullName -ChildPath $File.InputObject)
				Write-Log -Severity Debug -Message "Copying $($Copyfile.FullName) to $($Copyfile.DirectoryName.Replace($LeftFolder.FullName, $RightFolder.FullName))"
				Copy-Item -Path $Copyfile.FullName -Destination ($Copyfile.DirectoryName.Replace($LeftFolder.FullName, $RightFolder.FullName))
			}
  }
		catch { Write-Log -Severity Error -Message "Object = $($_.TargetObject)"; Write-Log -Severity Error -Message "ErrorDetail = $($_.Exception.Message)" }
		try {
			if ($file.SideIndicator -eq '==') {
				$1st = Get-Item (Join-Path $LeftFolder.FullName -ChildPath $File.InputObject)
				$2nd = Get-Item (Join-Path $RightFolder.FullName -ChildPath $File.InputObject)
				if ($1st.LastWriteTime -gt $2nd.LastWriteTime) {
					Write-Log -Severity Warning -Message "$($1st.FullName) is newer, and will replace file in $($2nd.DirectoryName)"
					Copy-Item $1st.FullName -Destination $2nd.DirectoryName -Force
				}
				if ($2nd.LastWriteTime -gt $1st.LastWriteTime) {
					Write-Log -Severity Warning -Message "$($2nd.FullName) is newer, and will replace file in $($1st.DirectoryName)"
					Copy-Item $2nd.FullName -Destination $1st.DirectoryName -Force
				}
			}
  }
		catch { Write-Log -Severity Error -Message "Object = $($_.TargetObject)"; Write-Log -Severity Error -Message "ErrorDetail = $($_.Exception.Message)" }
	}
	write-log -Severity Information -Message 'End of Transmission' -ExportFinal
	$ErrorActionPreference = 'Continue'
}
 
Export-ModuleMember -Function Sync-PSFolders
#endregion
 
#region Test-CitrixCloudConnector.ps1
############################################
# source: Test-CitrixCloudConnector.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Perform basic connection tests to CItrix cloud.

.DESCRIPTION
Perform basic connection tests to CItrix cloud.

.PARAMETER CustomerID
get from CItrix cloud.

.PARAMETER Export
Export the results

.PARAMETER ReportPath
Where report will be saved.

.EXAMPLE
An example

.NOTES
General notes
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
 
#region Test-CitrixVDAPorts.ps1
############################################
# source: Test-CitrixVDAPorts.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
 Test connection between ddc and vda

.DESCRIPTION
 Test connection between ddc and vda

.PARAMETER ServerList
List servers to test

.PARAMETER PortsList
List of ports to test

.PARAMETER Export
Export the results.

.PARAMETER ReportPath
Where report will be saves.

.EXAMPLE
Test-CitrixVDAPorts -ServerList $list

#>
Function Test-CitrixVDAPorts {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Test-CitrixVDAPorts')]
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
 
Export-ModuleMember -Function Test-CitrixVDAPorts
#endregion
 
#region Test-PendingReboot.ps1
############################################
# source: Test-PendingReboot.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
############################################
# source: Test-PSRemote.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Update-ListOfDDCs.ps1
############################################
# source: Update-ListOfDDCs.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Update-ListOfDDCs {
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
 
Export-ModuleMember -Function Update-ListOfDDCs
#endregion
 
#region Update-LocalHelp.ps1
############################################
# source: Update-LocalHelp.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
    }
    else { $psfolder = (Get-Item $profile).DirectoryName }
    if ((Test-Path -Path $psfolder\Help) -eq $false) { New-Item -Path "$psfolder\Help" -ItemType Directory -Force -ErrorAction SilentlyContinue }
    $helpdir = Get-Item (Join-Path $psfolder -ChildPath 'Help')


    Update-Help -Force -Verbose -ErrorAction SilentlyContinue
    Save-Help -DestinationPath $helpdir.FullName -Force
}
 
Export-ModuleMember -Function Update-LocalHelp
#endregion
 
#region Update-PSModuleInfo.ps1
############################################
# source: Update-PSModuleInfo.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
 
#region Update-PSScriptInfo.ps1
############################################
# source: Update-PSScriptInfo.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Update PowerShell ScriptFileInfo

.DESCRIPTION
Update PowerShell ScriptFileInfo

.PARAMETER FullName
FullName of the script

.PARAMETER Author
Who wrote it

.PARAMETER Description
What it does

.PARAMETER tag
Tags for searching

.PARAMETER MinorUpdate
Minor version increase

.PARAMETER ChangesMade
What has changed.

.EXAMPLE
Update-PSScriptInfo -FullName .\PSToolKit\Public\Start-ClientPSProfile.ps1 -ChangesMade "blah"

#>
Function Update-PSScriptInfo {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSScriptInfo')]
	[OutputType([System.Collections.Hashtable])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.ps1') })]
		[System.IO.FileInfo]$FullName,
		[Parameter(Mandatory = $false)]
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory = $false)]
		[string]$Description,
		[Parameter(Mandatory = $false)]
		[string[]]$tag = 'ps',
		[Parameter(Mandatory = $false)]
		[switch]$MinorUpdate = $false,
		[Parameter(Mandatory = $true)]
		[string]$ChangesMade = (Read-Host 'Changes Made '))

	$Script = Get-Item -Path $FullName
	$ValidVerb = (Get-Verb -Verb ($Script.BaseName.Split('-'))[0])
	if ([bool]$ValidVerb -ne $true) { Write-Warning 'Script name is not valid, Needs to be in verb-noun format'; break }
	else {
		try {
			$currentinfo = $null
			$currentinfo = Test-ScriptFileInfo -Path $FullName -ErrorAction SilentlyContinue
		}
		catch {
			Write-Warning "$($Script.name): No Script Info found, using default values"

		}
		if ([bool]$currentinfo -eq $true) {
			[version]$ver = $currentinfo.Version
			if ($MinorUpdate) { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, ($ver.Minor + 1), $ver.Build }
			else { [version]$Version = '{0}.{1}.{2}' -f $ver.Major, $ver.Minor, ($ver.Build + 1) }
			$guid = $currentinfo.Guid
			$ReleaseNotes = @()
			$ReleaseNotes = $currentinfo.ReleaseNotes
			$ReleaseNotes += 'Updated [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] ' + $ChangesMade
			if ($Description -like '') { $Description = $currentinfo.Description }
			if ($currentinfo.Author -notlike '') { $Author = $currentinfo.Author }
			[string[]]$tags += $tag
			[string[]]$tags += $currentinfo.Tags | Where-Object { $_ -ne '' } | Sort-Object -Unique
			if ($currentinfo.CompanyName -like '') { [string]$company = 'HTPCZA Tech' }
			else { [string]$company = $currentinfo.CompanyName }
		}
		else {
			[version]$Version = '0.1.0'
			$guid = New-Guid
			$ReleaseNotes = @()
			$ReleaseNotes += 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initial Script creation'
			[string]$Description = "Description for script $($script.name) needs an update"
			[string]$company = 'HTPCZA Tech'
		}


		$manifestProperties = @{
			Path         = $Script.FullName
			GUID         = $guid
			Version      = $Version
			Author       = $Author
			Description  = $Description
			CompanyName  = $company
			Tags         = $tags | Where-Object { $_ -ne '' } | Sort-Object -Unique
			ReleaseNotes = $ReleaseNotes
		}
		$manifestProperties
		Write-Color -Text 'Updating: ', "$($Script.Name)" -Color Cyan, green -LinesBefore 1 -NoNewLine
		Update-ScriptFileInfo @manifestProperties -Force
		Write-Color ' Done' -Color Yellow -LinesAfter 1
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete] Processing file: $($Script.Name)"
	}

}
 
Export-ModuleMember -Function Update-PSScriptInfo
#endregion
 
#region Update-PSToolKit.ps1
############################################
# source: Update-PSToolKit.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Update PSToolKit from GitHub.

.DESCRIPTION
Update PSToolKit from GitHub.

.PARAMETER AllUsers
Will update to the AllUsers Scope

.EXAMPLE
Update-PSToolKit

#>
Function Update-PSToolKit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKit')]
	PARAM(
		[ValidateScript({ $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt run this function' } })]
		[switch]$AllUsers
	)

	if ($AllUsers) {
		$ModulePath = [IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules', 'PSToolKit')
	} else {
		$ModulePath = [IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'WindowsPowerShell', 'Modules', 'PSToolKit')
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Checking] Temp folder $($env:tmp) "
	if ((Test-Path $env:tmp\private.zip) -eq $true ) { Remove-Item $env:tmp\private.zip -Force }

	if ((Test-Path $ModulePath  )) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Backup old folder to $(Join-Path -Path $ModulePath -ChildPath 'PSToolKit-BCK.zip')"
		Get-ChildItem -Directory $ModulePath | Compress-Archive -DestinationPath (Join-Path -Path $ModulePath -ChildPath 'PSToolKit-BCK.zip') -Update
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Remove old folder $($ModulePath)"
		Get-ChildItem -Directory $ModulePath | Remove-Item -Recurse -Force
	} else {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Creating Module directory $($ModulePath)"
		New-Item $ModulePath -ItemType Directory -Force | Out-Null
	}

	$PathFullName = Get-Item $ModulePath
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] download from github"
	Invoke-WebRequest -Uri https://codeload.github.com/smitpi/PSToolKit/zip/refs/heads/master -OutFile $env:tmp\private.zip
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] expand into module folder"
	Expand-Archive $env:tmp\private.zip $env:tmp -Force

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Copying to $($PathFullName.FullName)"
	Copy-Item -Path $env:tmp\PSToolKit-master\Output\* -Destination $PathFullName.FullName -Recurse

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Removing temp files"
	Remove-Item $env:tmp\private.zip
	Remove-Item $env:tmp\PSToolKit-master -Recurse
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Complete]"

} #end Function
 
Export-ModuleMember -Function Update-PSToolKit
#endregion
 
#region Update-PSToolKitConfigFiles.ps1
############################################
# source: Update-PSToolKitConfigFiles.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
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
Function Update-PSToolKitConfigFiles {
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
				Get-ChildItem (Join-Path $module.ModuleBase -ChildPath \private) | ForEach-Object {
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
 
Export-ModuleMember -Function Update-PSToolKitConfigFiles
#endregion
 
#region Write-PSToolKitLog.ps1
############################################
# source: Write-PSToolKitLog.ps1
# Module: PSToolKit
# version: 0.1.25
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Create a log for scripts

.DESCRIPTION
Create a log for scripts

.PARAMETER CreateArray
Run at the begining to create the initial arrray.

.PARAMETER Severity
Level of the message to be logged.

.PARAMETER Message
Details to be logged.

.PARAMETER ShowVerbose
Also show output to screen.

.PARAMETER ExportFinal
Run at the end to finalize the report.

.PARAMETER Export
Export the log to excel of html.

.PARAMETER ReportPath
Where to save the log.

.EXAMPLE
Write-PSToolKitLog -Severity Information -Message 'Where details are?'

.NOTES
General notes
#>
Function Write-PSToolKitLog {
    [Cmdletbinding(DefaultParameterSetName = 'Set'	, HelpURI = 'https://smitpi.github.io/PSToolKit/Write-PSToolKitLog')]
    PARAM(
        [Parameter(ParameterSetName = 'Create')]
        [switch]$CreateArray,
        [Parameter(ParameterSetName = 'Set')]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',
        [Parameter(ParameterSetName = 'Set')]
        [string]$Message,
        [Parameter(ParameterSetName = 'Set')]
        [switch]$ShowVerbose,
        [Parameter(ParameterSetName = 'Export')]
        [switch]$ExportFinal = $false,
        [Parameter(ParameterSetName = 'Export')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { (Test-Path $_) })]
        [Parameter(ParameterSetName = 'Export')]
        [System.IO.DirectoryInfo]$ReportPath = "$env:TEMP"
				)

    if ($CreateArray) { [System.Collections.ArrayList]$script:ExportLogs = @() }


    $object = [PSCustomObject]@{
        Time     = '[' + (Get-Date -f g) + '] '
        Severity = "[$Severity] "
        Message  = $Message
    } | Select-Object Time, Severity, Action, Message
    $ExportLogs.Add($object)

    if ($ShowVerbose) {
        $VerbosePreference = 'Continue'
        switch ($($Severity)) {
            { $_ -in 'Debug', 'Information' } { Write-Verbose "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Message)" }
            { $_ -in 'Warning', 'Error' } { Write-Warning "$($ExportLogs[-1].Time)$($ExportLogs[-1].Severity)$($ExportLogs[-1].Message)" }

        }
        $VerbosePreference = 'SilentlyContinue'
    }


    if ($ExportFinal) {
        if ($Export -eq 'Excel') { $ExportLogs | Export-Excel -Path ($ReportPath + '\PrivRepoLog-' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx') -AutoSize -AutoFilter -Show }
        if ($Export -eq 'HTML') { $ExportLogs | Out-GridHtml -DisablePaging -Title 'PrivRepoLog' -HideFooter -SearchHighlight -FixedHeader }
        if ($Export -eq 'Host') { $ExportLogs | Format-Table -AutoSize }
    }
} #end Function
 
Export-ModuleMember -Function Write-PSToolKitLog
#endregion
 
#endregion
