Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force

New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -ItemType file
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name HideFirstRunExperience -Type DWord -Value 1
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name DefaultSearchProviderEnabled -Type DWord -Value 1
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name DefaultSearchProviderSearchURL -Type String -Value 'https://www.google.com/search?q=%s'
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name DefaultSearchProviderSuggestURL -Type String -Value 'https://www.google.com/search?q=%s'
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name NewTabPageSearchBox -Type String -Value 'redirect'
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name NewTabPageSearchBoxRedirectURL -Type String -Value 'https://www.google.com/search?q=%s'


#. { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force

#https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1
#Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1

#  C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe --app=https://boxstarter.org/package/url?https://raw.githubusercontent.com/smitpi/PSToolKit/master/PSToolKit/Control_Scripts/Initial-Setup.ps1