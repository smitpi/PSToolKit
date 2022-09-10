
<#PSScriptInfo

.VERSION 0.1.0

.GUID 92959e8c-88c5-4da5-bcb2-df74f707237f

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
Created [07/09/2022_07:23] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Gallery report 

#> 


<#
.SYNOPSIS
Gallery report

.DESCRIPTION
Gallery report

.PARAMETER GitHubUserID
The GitHub User ID.

.PARAMETER GitHubToken
GitHub Token with access to the Users' Gist.

.EXAMPLE
Get-MyPSGalleryReport 

#>
Function Get-MyPSGalleryReport {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryReport')]
	PARAM(
		[string]$GitHubUserID,
		[string]$GitHubToken
	)
 try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
		$headers = @{}
		$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
		$base64 = [System.Convert]::ToBase64String($bytes)
		$headers.Authorization = 'Basic {0}' -f $base64

		$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
		$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
		$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'smitpi-gallery-statsV2' }

		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
		$Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStatsV2.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop

		[System.Collections.generic.List[PSObject]]$GalStats = @()
		try {
			$Content | ForEach-Object {$GalStats.Add($_)}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	
	$dateCollect = Get-Date
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Collecting my modules"
	Find-Module -Repository PSGallery | Where-Object {$_.author -like 'Pierre Smit'} | ForEach-Object {
		$_.AdditionalMetadata | Add-Member -MemberType NoteProperty -Name DateCollected -Value $dateCollect
		$GalStats.add($_.AdditionalMetadata)
	}
	try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to gist"
		$Body = @{}
		$files = @{}
		$Files['PSGalleryStatsV2.json'] = @{content = ( $GalStats | ConvertTo-Json -Depth 10 | Out-String ) }
		$Body.files = $Files
		$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
		$json = ConvertTo-Json -InputObject $Body
		$json = [System.Text.Encoding]::UTF8.GetBytes($json)
		$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
		Write-Host '[Upload] [PSGallery StatsV2] To Github Gist Complete'
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Done]"
	} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
} #end Function