Get-Module boxstarter* -ListAvailable | Import-Module -Force

Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1 -KeepWindowOpen

Install-BoxstarterPackage -PackageName 'D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\PSToolKit\PSToolKit\Control_Scripts\Run-Install-Apps.ps1' -KeepWindowOpen