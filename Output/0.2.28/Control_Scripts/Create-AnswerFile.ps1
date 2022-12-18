$PSTemp = "$env:TEMP\PSTemp"
if (Test-Path $PSTemp) {$PSDownload = Get-Item $PSTemp}
else {$PSDownload = New-Item $PSTemp -ItemType Directory -Force}

$AnswerFile = "$($PSDownload.FullName)\AnswerFile.json"

if (-not(Test-Path $AnswerFile)) {

	$output = [PSCustomObject]@{
		DomainName     = 'None'
		DomainUser     = 'None'
		DomainPassword = 'None'
		GitHubToken    = 'None'
	}

	$output | ConvertTo-Json | Out-File -FilePath $AnswerFile -Force

	Start-Process -FilePath notepad.exe -ArgumentList $AnswerFile -Wait
}

$AnswerFileImport = (Get-Content $AnswerFile | ConvertFrom-Json) 

foreach ($item in ($AnswerFileImport | Get-Member -MemberType noteProperty)) {
	New-Variable -Name $item.Name -Value $AnswerFileImport.$($item.Name) -Force -Scope Global
}
