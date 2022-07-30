
<#PSScriptInfo

.VERSION 0.1.0

.GUID 5cc30782-f0f0-4969-ad75-dafb54024e03

.AUTHOR Jeff Hicks

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
Created [30/07/2022_21:49] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Resolves the Sid 

#> 


<#
.SYNOPSIS
Resolves the Sid

.DESCRIPTION
Resolves the Sid

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Resolve-SID -Export HTML -ReportPath C:\temp

#>
Function Resolve-SID {
	[cmdletbinding()]
	[OutputType('ResolvedSID', 'String')]
	Param(
		[Parameter(
			Position = 0,
			Mandatory,
			ValueFromPipeline,
			ValueFromPipelineByPropertyName,
			HelpMessage = 'Enter a SID string.'
		)]
		[ValidateScript({
				If ($_ -match 'S-1-[1235]-\d{1,2}(-\d+)*') {
					$True
				} else {
					Throw 'The parameter value does not match the pattern for a valid SID.'
					$False
				}
			})]
		[string]$SID,
		[Parameter(HelpMessage = 'Display the resolved account name as a string.')]
		[switch]$ToString
	)
	Begin {
		Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
	} #begin

	Process {
		Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Converting $SID "
		Try {
			if ($SID -eq 'S-1-5-32') {
				#apparently you can't resolve the builtin account
				$resolved = "$env:COMPUTERNAME\BUILTIN"
			} else {
				$resolved = [System.Security.Principal.SecurityIdentifier]::new($sid).Translate([system.security.principal.NTAccount]).value
			}

			if ($ToString) {
				$resolved
			} else {
				if ($resolved -match '\\') {
					$domain = $resolved.Split('\')[0]
					$username = $resolved.Split('\')[1]
				} else {
					$domain = $Null
					$username = $resolved
				}
				[pscustomObject]@{
					PSTypename = 'ResolvedSID'
					NTAccount  = $resolved
					Domain     = $domain
					Username   = $username
					SID        = $SID
				}
			}
		} Catch {
			Write-Warning "Failed to resolve $SID. $($_.Exception.InnerException.Message)"
		}
	} #process

	End {
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
	} #end

} #close Resolve-SID
