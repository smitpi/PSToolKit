
<#PSScriptInfo

.VERSION 0.1.0

.GUID b0c7c507-19f6-46e2-920c-2b12659f01f3

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
Created [28/01/2022_16:58] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Update the config files hosted on GitHub

#>


<#
.SYNOPSIS
 Update the config files hosted on GitHub

.DESCRIPTION
 Update the config files hosted on GitHub

.PARAMETER UserID
GitHub userid hosting the gist.

.PARAMETER GitHubToken
GitHub Token

.EXAMPLE
Update-PSToolKitGistConfigFiles -UserID smitpi -GitHubToken xxxxxx

.NOTES
General notes
#>
Function Update-PSToolKitGistConfigFiles {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Update-PSToolKitGistConfigFiles')]
	PARAM(
		[string]$UserID,
		[string]$GitHubToken
	)
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$headers = @{}
	$auth = '{0}:{1}' -f $UserID, $GitHubToken
	$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
	$base64 = [System.Convert]::ToBase64String($bytes)
	$headers.Authorization = 'Basic {0}' -f $base64

	$url = 'https://api.github.com/users/{0}/gists' -f $Userid
	$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
	$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSToolKit-Config' }

	if ($null -like $PRGist) {
		$Body = @{}
		$files = @{}
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		Get-ChildItem $ConfigPath | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } }
		$Body.files = $Files
		$Body.description = 'PSToolKit-Config'
		$json = ConvertTo-Json -InputObject $Body
		$json = [System.Text.Encoding]::UTF8.GetBytes($json)
		$RawReq = Invoke-WebRequest -Headers $headers -Uri https://api.github.com/gists -Method Post -Body $json
		ConvertFrom-Json -InputObject $RawReq

	}
	else {
		$Body = @{}
		$files = @{}
		$ConfigPath = [IO.Path]::Combine($env:ProgramFiles, 'PSToolKit', 'Config')
		Get-ChildItem $ConfigPath | ForEach-Object { $Files[$_.Name] = @{content = ( Get-Content $_.FullName -Encoding UTF8 | Out-String ) } }
		$Body.files = $Files

		$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
		$json = ConvertTo-Json -InputObject $Body
		$json = [System.Text.Encoding]::UTF8.GetBytes($json)
		$RawReq = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json
		ConvertFrom-Json -InputObject $RawReq
	}
} #end Function
