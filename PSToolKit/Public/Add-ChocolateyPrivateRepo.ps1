
<#PSScriptInfo

.VERSION 0.1.0

.GUID 031c0969-bec6-4eb7-bf22-b209ed0b784e

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
Created [10/01/2022_14:06] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Add a private repository to choco

#>


<#
.SYNOPSIS
Add a private repository to Chocolatey.

.DESCRIPTION
Add a private repository to Chocolatey.

.PARAMETER RepoName
Name of the repo

.PARAMETER RepoURL
URL of the repo

.PARAMETER Priority
Priority of server, 1 being the highest.

.PARAMETER RepoApiKey
API key to allow uploads to the server.

.PARAMETER DisableCommunityRepo
Disable the community repo, and will only use the private one.

.EXAMPLE
Add-ChocolateyPrivateRepo -RepoName XXX -RepoURL https://choco.xxx.lab/chocolatey -Priority 3

#>
Function Add-ChocolateyPrivateRepo {
  [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Add-ChocolateyPrivateRepo')]
  PARAM(
    [Parameter(Mandatory = $true)]
    [ValidateScript( {
        $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
        else { Throw 'Must be running an elevated prompt to use this fuction.' } })]
    [string]$RepoName,
    [Parameter(Mandatory = $true)]
    [string]$RepoURL,
    [Parameter(Mandatory = $true)]
    [int]$Priority,
    [string]$RepoApiKey,
    [switch]$DisableCommunityRepo
  )

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {Install-ChocolateyClient}

  [System.Collections.ArrayList]$sources = @()
  choco source list --limit-output | ForEach-Object {
    [void]$sources.Add([pscustomobject]@{
        Name     = $_.split('|')[0]
        URL      = $_.split('|')[1]
        Priority = $_.split('|')[5]
      })
  }
  $RepoExists = $RepoURL -in $sources.Url
  if (!$RepoExists) {
    try {
      choco source add --name="$($RepoName)" --source=$($RepoURL) --priority=$($Priority) --limit-output
      [void]$sources.add([pscustomobject]@{
          Name     = $($RepoName)
          URL      = $($RepoURL)
          Priority = $($Priority)
        })
      Write-PSMessage -Action Installing -Object 'Chocolatey Private Repo' -Message Complete -MessageColor Green
      $sources.Url | Write-PSMessage -Action Getting -Message 'Choco Source' -MessageColor Yellow -LinesAfter 2
    } catch { Write-Warning "[Installing] Chocolatey Private Repo Failed:`n $($_.Exception.Message)" }

  } else {
    Write-PSMessage -Action Installing -Severity Error -BeforeMessage 'Chocolatey Private Repo' -BeforeMessageColor Magenta -Object $RepoName -AfterMessage 'Already Installed' -AfterMessageColor Red
  }

  if ($null -notlike $RepoApiKey) {
    choco apikey --source="$($RepoURL)" --api-key="$($RepoApiKey)" --limit-output | Out-Null
    if ($LASTEXITCODE -ne 0) {Write-Warning "Error Installing APIKey Code: $($LASTEXITCODE)"}
    else { Write-PSMessage -Action Installing -Object 'RepoAPIKey' -AfterMessage Complete -AfterMessageColor Green}
  }
  if ($DisableCommunityRepo) {
    choco source disable --name=chocolatey --limit-output | Out-Null
    if ($LASTEXITCODE -ne 0) {Write-Warning "Error disabling repo Code: $($LASTEXITCODE)"}
    else {Write-PSMessage -Action Disabling -Object 'Community Repo' -AfterMessage Complete -AfterMessageColor Green}
  }


} #end Function
