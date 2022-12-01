
<#PSScriptInfo

.VERSION 0.1.0

.GUID aef15d49-a705-4ab1-9f7a-4263ce645b98

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS PS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [26/10/2021_22:32] Initialize Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Creates a new PowerShell script. With PowerShell Script Info

#>

<#
.SYNOPSIS
 Creates a new PowerShell script. With PowerShell Script Info

.DESCRIPTION
 Creates a new PowerShell script. With PowerShell Script Info

.PARAMETER Path
Where the script will be created.

.PARAMETER Verb
Approved PowerShell verb

.PARAMETER Noun
Second part of script name.

.PARAMETER Author
Who wrote it.

.PARAMETER Description
What it does.

.PARAMETER RequiredModules
List of required modules.

.PARAMETER tags
Tags for searches.

.EXAMPLE
New-PSScript -Path .\PSToolKit\Private\ -Verb get -Noun blah -Description 'blah' -tags PS

#>
function New-PSScript {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/New-PSScript')]
	param (
		[ValidateScript( { Test-Path -Path $_ })]
		[System.IO.DirectoryInfo]$Path = $pwd,
		[Parameter(Mandatory)]
		[ValidateScript( { Get-Verb -Verb $_ })]
		[string]$Verb,
		[Parameter(Mandatory)]
		[string]$Noun,
		[string]$Author = 'Pierre Smit',
		[Parameter(Mandatory)]
		[string]$Description,
		[ValidateScript( { Get-Module -Name $_ -ListAvailable })]
		[string[]]$RequiredModules,
		[Parameter(Mandatory)]
		[string[]]$tags)

	$checkpath = Get-Item $Path
	$ValidVerb = Get-Verb -Verb $Verb
	if ([bool]$ValidVerb -ne $true) { Write-Warning 'Script name is not valid, Needs to be in verb-noun format'; break }

	$properverb = (Get-Culture).TextInfo.ToTitleCase($Verb)
	$propernoun = $Noun.substring(0, 1).toupper() + $Noun.substring(1)

	try {
		$module = Get-Item (Join-Path $checkpath.Parent -ChildPath "$((Get-Item $checkpath.Parent).BaseName).psm1") -ErrorAction Stop
		$modulename = $module.BaseName
	} catch { Write-Warning 'Could not detect module'; $modulename = Read-Host 'Module Name: ' }


	$functionText = @"
<#
.SYNOPSIS
$Description

.DESCRIPTION
$Description

.EXAMPLE
$properverb-$propernoun -Export HTML -ReportPath C:\temp

#>
Function $properverb-$propernoun {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/$modulename/$properverb-$propernoun")]
	    [OutputType([System.Object[]])]
                #region Parameter
                PARAM(
					[Parameter(Position = 0,Mandatory,ParameterSetName = 'Set1',HelpMessage = "Specify the name of a remote computer. The default is the local host.")]
					[alias("CN", "host")]
					[ValidateNotNullorEmpty()]
					[ValidateScript( { (Test-Path `$_) -and ((Get-Item `$_).Extension -eq ".csv") })]
					[System.IO.FileInfo]`$File,

                    [Parameter(Mandatory,
								ValueFromPipeline,
								ValueFromPipelineByPropertyName,
								ValueFromRemainingArguments)]
					[ValidateScript({`$IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
									if (`$IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {`$True}
									else {Throw "Must be running an elevated prompt to use this function"}})]
					[switch]`$ForceAdmin,
					
					[ValidateScript({if (Test-Connection -ComputerName `$_ -Count 2 -Quiet) {`$true}
									else {throw "Unable to connect to `$(`$_)"} })]
					[string[]]`$ComputerName,

					[ValidateSet('Excel', 'HTML', 'Host')]
					[string]`$Export = 'Host',

					[ValidateScript( { if (Test-Path `$_) { `$true }
                                else { Write-Warning "Folder does not exist, creating folder now."
                                New-Item -Path `$_ -ItemType Directory -Force | Out-Null; `$true }
                    })]
					[System.IO.DirectoryInfo]`$ReportPath = 'C:\Temp'
				)
                #endregion
    Begin {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"

    } #End Begin
    Process {
    
    } #End Process
    End {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Complete"
    }#End End
} #end Function
"@
	$ScriptFullPath = $checkpath.fullname + "\$properverb-$propernoun.ps1"

	$manifestProperties = @{
		Path         = $ScriptFullPath
		Version      = '0.1.0'
		Author       = $Author
		Description  = $Description
		CompanyName  = 'HTPCZA Tech'
		Tags         = @($Tags)
		ReleaseNotes = 'Created [' + (Get-Date -Format dd/MM/yyyy_HH:mm) + '] Initial Script'
		GUID         = (New-Guid)
	}

	if ($RequiredModules) {
		$manifestProperties.RequiredModules = @($RequiredModules)
	}
	
	New-ScriptFileInfo @manifestProperties -Force
	$content = Get-Content $ScriptFullPath | Where-Object { $_ -notlike 'Param*' }
	Set-Content -Value ($content + $functionText) -Path $ScriptFullPath -Force
}
