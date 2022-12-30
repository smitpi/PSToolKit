Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force

#https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1
#Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1

#  C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe --app=https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1