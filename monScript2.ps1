$source = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.7/npp.8.4.7.Installer.exe'

$destination = 'c:\Users\cp-18sas\Downloads\npp.8.4.7.Installer.exe'

Invoke-WebRequest -Uri $source -OutFile $destination

Start-Process C:\Users\cp-18sas\Downloads\npp.8.4.7.Installer.exe /S -NoNewWindow -Wait -PassThru

Set-Location ..\..\..

Uninstall-Package -Name 

Get-Service | Where-Object {$_.Status -eq "Running"}

Get-Service WSearch

(Get-Service WSearch).Status
Get-Service WSearch | Stop-Service
Stop-Service WSearch
Start-Service WSearch


Get-Process | Sort-Object -Property CPU -Descending

Start-Process Notepad -WindowStyle Minimized
Get-Process Notepad | Stop-Process
Get-Process -id 18764 | Stop-Process




Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty -Name DisplayName | Select-Object DisplayName | Sort-Object DisplayName

Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"

Start-Process "C:\Program Files (x86)\Notepad++\uninstall.exe" /S -NoNewWindow -Wait -PassThru

Start-Process (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++").UninstallString /S

