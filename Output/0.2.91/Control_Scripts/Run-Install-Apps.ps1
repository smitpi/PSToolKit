
if ([string]::IsNullOrEmpty($GitHubUserID)) {
	$input = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the GitHub User:', 'User Input', '')
	if ([string]::IsNullOrWhiteSpace($input)) {
		$GitHubUserID = $input
	}
}
	
if ([string]::IsNullOrEmpty($GitHubToken)) {
	$input = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the GitHub Token:', 'User Input', '')
	if ([string]::IsNullOrWhiteSpace($input)) {$GitHubToken = $input}
}
$URL = 'https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Public/Install-AppsFromPSPackageMan.ps1'
(New-Object System.Net.WebClient).DownloadFile($($URL), "$($env:tmp)\Install-AppsFromPSPackageMan.ps1")
Import-Module (Get-Item "$($env:tmp)\Install-AppsFromPSPackageMan.ps1") -Force
Install-AppsFromPSPackageMan -GitHubUserID $GitHubUserID -GitHubToken $GitHubToken
