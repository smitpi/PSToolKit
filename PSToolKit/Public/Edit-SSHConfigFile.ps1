
<#PSScriptInfo

.VERSION 0.1.0

.GUID e90db633-4b22-4260-ba84-723309fa8715

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ssh

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [21/03/2022_06:59] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Creates and modifies the ssh config file in their profile

#>

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
