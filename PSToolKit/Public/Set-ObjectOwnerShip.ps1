
<#PSScriptInfo

.VERSION 0.1.0

.GUID 9e859028-f2bf-4a82-ac28-cf459e297db9

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
Created [02/08/2022_23:37] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Reset the ownership of a folder, and add the specified user with full control. 

#> 


<#
.SYNOPSIS
Reset the ownership of a folder, and add the specified user with full control.

.DESCRIPTION
Reset the ownership of a folder, and add the specified user with full control.


#>
Function Set-ObjectOwnerShip {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Set-ObjectOwnerShip')]
	[OutputType([System.Object[]])]
	param (
		[Parameter(Mandatory = $true)]
		[validatescript({if (Test-Path $_) {$true}
				else {throw 'Unknown Path...'}})]
		[Alias('Name')]
		[System.IO.DirectoryInfo[]]$FolderPath,

		[Parameter(Mandatory = $true)]
		[string[]]$UserName
	)

	[System.Collections.generic.List[PSObject]]$Object2 = @()
	[System.Collections.generic.List[PSObject]]$object = @()
	

	foreach ($Path in $FolderPath) {
		$FullPath = Get-Item $Path
		Start-Process -FilePath takeown -ArgumentList "/f $($FullPath.FullName) /r /d y" -NoNewWindow -RedirectStandardError "$($env:TMP)\error.log" -RedirectStandardOutput "$($env:TMP)\std.log" -Wait
		$Errors += Get-Content "$($env:TMP)\error.log"
		$StandardOut = Get-Content "$($env:TMP)\std.log" | Where-Object {$_ -notlike $null}
		$StandardOut | ForEach-Object {
			$object.Add([PSCustomObject]@{
					Status = $_.split('"')[0].split(':')[0]
					File   = $_.split('"')[1]
					Owner  = $_.split('"')[3]
				})
		}
        

		foreach ($User in $UserName) {

			Start-Process -FilePath icacls -ArgumentList "$($FullPath.FullName) /grant $($User):F /t /C" -NoNewWindow -RedirectStandardError "$($env:TMP)\icacls_error.log" -RedirectStandardOutput "$($env:TMP)\icalcs_std.log" -Wait
			$Errors += Get-Content "$($env:TMP)\icacls_error.log" 
			$icacls_StandardOut = Get-Content "$($env:TMP)\icalcs_std.log"
			$icacls_StandardOut | ForEach-Object {
				$Object2.Add([PSCustomObject]@{
						User   = $User
						Status = $_.split(' ')[0]
						Object = $_.split(' ')[1]
						File   = $_.split(' ')[2]
					})
			}
		}
		return [PSCustomObject]@{
			OwnweShip = $object
			ICalcs    = $Object2
			Error     = $Errors
		}

	}
} #end Function