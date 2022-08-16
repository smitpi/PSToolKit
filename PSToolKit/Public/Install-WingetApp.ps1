
<#PSScriptInfo

.VERSION 0.1.0

.GUID 4ee5f108-37f8-4eda-bd93-005ee6a00df4

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
Created [03/08/2022_21:52] Initial Script Creating

.PRIVATEDATA

#>



<#

.DESCRIPTION
 Install apps from a json file.

#>


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
