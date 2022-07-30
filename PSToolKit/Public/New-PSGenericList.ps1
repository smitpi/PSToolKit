
<#PSScriptInfo

.VERSION 0.1.0

.GUID a4e3067b-399d-4b06-a400-7ef794ee7169

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
Created [30/07/2022_22:51] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Creates a .net list object 

#> 


<#
.SYNOPSIS
Creates a .net list object

.DESCRIPTION
Creates a .net list object


.PARAMETER Type
The type of objects in the list

.PARAMETER Values
Data to add.

.EXAMPLE
$list = New-GenericList -Type string -Values 'blah','two','one'

#>
Function New-PSGenericList {
	[cmdletbinding()]
	[alias('ngl')]
	[outputType('System.Collections.Generic.List[<type>]')]
	Param(
		[Parameter(
			Position = 0,
			ValueFromPipelineByPropertyname,
			HelpMessage = 'Enter the object type to be used for defining the list such as Int32 or String.'
		)]
		[ValidateNotNullOrEmpty()]
		[Type]$Type = 'String',
		[Parameter(
			ValueFromPipeline,
			HelpMessage = 'Specify the values or objects to add to the list.'
		)]
		[object[]]$Values
	)
	Begin {
		Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
		if ($PSBoundParameters.ContainsKey('Type')) {
			#create the list object if the type name is passed as a parameter value.
			Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Creating a generic list for $type objects"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}
	} #begin

	Process {
		#If the list is not defined in the Begin block define it here based on pipeline input.
		#The If statement should only run once, for the first pipelined object.
		if ((-Not $list.psbase) -AND ($psitem)) {
			$type = $psitem.gettype()
			if ($type.name -eq 'PSCustomObject') {
				Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Detected $type. Using PSObject as the type"
				$type = 'PSObject' -as [Type]
			}
			Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating a generic list for $type objects"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}

		#add each value to the list
		foreach ($value in $values) {
			if ($VerbosePreference -eq 'continue') {
				#display verbose output for each item added to the list using Write-Progress
				$paramHash = @{
					Activity         = $myinvocation.mycommand
					Status           = 'Adding items'
					CurrentOperation = "[$((Get-Date).TimeofDay) PROCESS] Adding $value to the list"
				}

				Write-Progress @paramHash

			}
			$list.Add($value)
		} #foreach value
	} #process

	End {
		if ($VerbosePreference -eq 'continue') {
			#reset the cursor position
			Write-Host "`r"
		}
		#create an empty generic string list if no type or values are specifed
		if (-Not $list) {
			Write-Verbose "[$((Get-Date).TimeofDay) END    ] Creating an empty $type generic list"
			$List = New-Object -TypeName system.collections.generic.list[$($Type.fullName)]
		}
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Added $($list.count) objects to the list"
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Writing object type $($list.psobject.typenames[0])"
		#need to return the list object not the values, and this syntax
		#appears to achieve this goal.
		, $list

		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
	} #end

} #close New-GenericList