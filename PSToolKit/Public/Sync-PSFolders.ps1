
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7b182167-66a9-40fd-8c21-e79ea4689a7b

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
Compare two directories and copy the differences

#>


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
