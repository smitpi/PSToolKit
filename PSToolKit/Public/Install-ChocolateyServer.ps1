
<#PSScriptInfo

.VERSION 0.1.0

.GUID 62e4dd59-6f86-4367-9335-047908dabb0f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [12/01/2022_09:00] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 This will download, install and setup a new Chocolatey Repo Server 

#> 

<#
.SYNOPSIS
This will download, install and setup a new Chocolatey Repo Server

.DESCRIPTION
This will download, install and setup a new Chocolatey Repo Server

.PARAMETER SiteName
Name of the new repo

.PARAMETER AppPoolName
Pool name in IIS

.PARAMETER SitePath
Path where packages will be saved.

.PARAMETER APIKey
Change the default api to this key.

.EXAMPLE
Install-ChocolateyServer -SiteName blah -AppPoolName blah -SitePath c:\temp\blah -APIKey 123456789

#>
Function Install-ChocolateyServer {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Install-ChocolateyServer')]

    PARAM(
        [Parameter(Mandatory = $true)]
        [string]$SiteName,
        [Parameter(Mandatory = $true)]
        [String]$AppPoolName,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { (Test-Path $_) })]
        [string]$SitePath,
        [string]$APIKey
    )


    function Add-Acl {
        Param (
            [string]$Path,
            [System.Security.AccessControl.FileSystemAccessRule]$AceObject
        )

        Write-Verbose "Retrieving existing ACL from $Path"
        $objACL = Get-Acl -Path $Path
        $objACL.AddAccessRule($AceObject)
        Write-Verbose "Setting ACL on $Path"
        Set-Acl -Path $Path -AclObject $objACL
    }

    function New-AclObject {
        Param (
            [string]$SamAccountName,
            [System.Security.AccessControl.FileSystemRights]$Permission,
            [System.Security.AccessControl.AccessControlType]$AccessControl = 'Allow',
            [System.Security.AccessControl.InheritanceFlags]$Inheritance = 'None',
            [System.Security.AccessControl.PropagationFlags]$Propagation = 'None'
        )

        New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule($SamAccountName, $Permission, $Inheritance, $Propagation, $AccessControl)
    }

    if ($null -eq (Get-Command -Name 'choco.exe' -ErrorAction SilentlyContinue)) {
        Write-Warning 'Chocolatey not installed. Cannot install standard packages.'
        Exit 1
    }
    # Install Chocolatey.Server prereqs
    choco install IIS-WebServer --source windowsfeatures
    choco install IIS-ASPNET45 --source windowsfeatures

    # Install Chocolatey.Server
    choco upgrade chocolatey.server -y

    # Step by step instructions here https://docs.chocolatey.org/en-us/guides/organizations/set-up-chocolatey-server#setup-normally
    # Import the right modules
    Import-Module WebAdministration
    # Disable or remove the Default website
    Get-Website -Name 'Default Web Site' | Stop-Website
    Set-ItemProperty 'IIS:\Sites\Default Web Site' serverAutoStart False    # disables website

    # Set up an app pool for Chocolatey.Server. Ensure 32-bit is enabled and the managed runtime version is v4.0 (or some version of 4). Ensure it is "Integrated" and not "Classic".
    New-WebAppPool -Name $appPoolName -Force
    Set-ItemProperty IIS:\AppPools\$appPoolName enable32BitAppOnWin64 True       # Ensure 32-bit is enabled
    Set-ItemProperty IIS:\AppPools\$appPoolName managedRuntimeVersion v4.0       # managed runtime version is v4.0
    Set-ItemProperty IIS:\AppPools\$appPoolName managedPipelineMode Integrated   # Ensure it is "Integrated" and not "Classic"
    Restart-WebAppPool -Name $appPoolName   # likely not needed ... but just in case

    # Set up an IIS website pointed to the install location and set it to use the app pool.
    New-Website -Name $siteName -ApplicationPool $appPoolName -PhysicalPath $sitePath

    # Add permissions to c:\tools\chocolatey.server:
    'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$appPoolName" | ForEach-Object {
        $obj = New-AclObject -SamAccountName $_ -Permission 'ReadAndExecute' -Inheritance 'ContainerInherit', 'ObjectInherit'
        Add-Acl -Path $sitePath -AceObject $obj
    }

    # Add the permissions to the App_Data subfolder:
    $appdataPath = Join-Path -Path $sitePath -ChildPath 'App_Data'
    'IIS_IUSRS', "IIS APPPOOL\$appPoolName" | ForEach-Object {
        $obj = New-AclObject -SamAccountName $_ -Permission 'Modify' -Inheritance 'ContainerInherit', 'ObjectInherit'
        Add-Acl -Path $appdataPath -AceObject $obj
    }

    if (-not($null -like $APIKey)) { ((Get-Content (Join-Path $sitePath -ChildPath '\web.config') -Raw) -replace 'chocolateyrocks', 'white') | Set-Content -Path (Join-Path $sitePath -ChildPath '\web.config') -Force ; iisreset.exe }
    Write-Color '[Installing] ', 'Chocolaty Server: ', 'Complete' -Color Cyan, Yellow, Green


} #end Function
