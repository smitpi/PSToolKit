
<#PSScriptInfo

.VERSION 0.1.0

.GUID 62b9e7e7-90c0-4f13-902d-79818c2cdb3f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [22/03/2022_09:27] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Enable Windows-Subsystem-Linux 

#> 


<#
.SYNOPSIS
Enable Windows-Subsystem-Linux

.DESCRIPTION
Enable Windows-Subsystem-Linux

.EXAMPLE
Install-WSL2

#>
Function Install-WSL2 {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSToolKit/Install-WSL2')]
	[OutputType([System.Object[]])]
	PARAM(
        [System.IO.DirectoryInfo]$DistroPath,
		[switch]$Ubuntu,
		[switch]$Debian
	)


	if (-not(Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online)) {Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux}
	if (-not(Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online)) {Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform}
    Start-BitsTransfer -source 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -Destination  "$($env:tmp)\wsl_update_x64.msi"
	& "$($env:tmp)\wsl_update_x64.msi"
    & wsl --set-default-version 2

if ($Ubuntu) {
		Start-BitsTransfer -source https://aka.ms/wslubuntu2004 -Destination $env:tmp\Ubuntu2004.zip
        if (test-path (join-path $DistroPath "Ubuntu2004")) {
            Rename-Item -Path (join-path $DistroPath "Ubuntu2004") -NewName "Ubuntu2004-$(get-date -Format yyyy.MM.dd)" -Force
            $distro = New-Item (join-path $DistroPath "Ubuntu2004") -ItemType Directory -Force
            }
        else { $distro = New-Item (join-path $DistroPath "Ubuntu2004") -ItemType Directory -Force}
		Expand-Archive "$($env:tmp)\Ubuntu2004.zip" $distro.FullName
        Get-ChildItem -Path "$($distro.FullName)\*x64*.appx" | Rename-Item -NewName Ubuntux64.zip
        $newdir = new-item -Path "$($distro.FullName)\Ubuntux64" -ItemType Directory -Force
        Expand-Archive "$($distro.FullName)\Ubuntux64.zip" $newdir.FullName
        & "$($newdir.FullName)\ubuntu.exe"
        wsl --set-default-version 2


	}
	if ($Debian) {
		Start-BitsTransfer -Source https://aka.ms/wsl-debian-gnulinux -Destination $env:tmp\Debian.zip

        if (test-path (join-path $DistroPath "Debian")) {Rename-Item -Path (join-path $DistroPath "Debian") -NewName "Debian-$(get-date -Format yyyy.MM.dd)" -Force}
        else {New-Item (join-path $DistroPath "Debian") -ItemType Directory -Force | Out-Null}
		Expand-Archive "$($env:tmp)\Debian.zip" (join-path $DistroPath "Debian")
	}

	Start-Process -FilePath 'C:\Windows\system32\wsl.exe' -ArgumentList '--help' -NoNewWindow
	& 'wsl' @('--help')

	C:\Distros\Ubuntu1804\ubuntu1804.exe




	$userenv = [System.Environment]::GetEnvironmentVariable('Path', 'User')
	[System.Environment]::SetEnvironmentVariable('PATH', $userenv + ';C:\Users\Administrator\Ubuntu', 'User')
} #end Function
