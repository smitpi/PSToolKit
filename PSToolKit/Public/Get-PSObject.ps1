
<#PSScriptInfo

.VERSION 0.1.0

.GUID 316ec452-c632-4bec-89b0-71901c22796c

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
Created [15/10/2022_09:55] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Show all Object Methods 

#> 


<#
.SYNOPSIS
Show all Object Methods and Properties.

.DESCRIPTION
Show all Object Methods and Properties.

.PARAMETER Data
The Object to Report on.

.EXAMPLE
Get-PSObject (get-item .)

#>
Function Get-PSObject {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-PSObject')]
	[OutputType([System.Object[]])]
	Param (
		[parameter( ValueFromPipeline = $True )]
		[object[]]$Data)
	begin {
		[System.Collections.generic.List[PSObject]]$ReturnObject = @()
	}

	Process {
		ForEach ( $Object in $Data ) {
			$ReturnObject.Add([PSCustomObject]@{
					Object     = $Object.psobject.BaseObject
					Members    = $Object.psobject.Members | Select-Object Name, MemberType, TypeNameOfValue, Value
					Properties = $Object.psobject.Properties | Select-Object Name, Value, TypeNameOfValue
				}) #PSList
		}
	}
	end {$ReturnObject}
} #end Function
