
<#PSScriptInfo

.VERSION 0.1.0

.GUID 81ade2f4-83d3-4a7d-bfda-99e7b5fec6a7

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [14/02/2022_11:39] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Edit the hosts file

#>
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
