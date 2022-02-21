
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0a386554-5681-479d-99b4-6fd09f255fa5

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
 Find and update script info

#>

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
