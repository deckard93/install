Set-ExecutionPolicy unrestricted -Force

New-Item -ItemType Directory -Force -Path C:\scripts
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/deckard93/install/master/win_install.ps1", "C:\scripts\startup.ps1")

$Username = Read-Host 'Enter username for auto-logon'
$Pass = Read-Host "Enter password for $Username"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Username" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Pass" -type String

$Trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
$Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory C:/Scripts -Argument  "-command C:\scripts\startup.ps1 *> C:\scripts\log.txt" 
#$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
#Register-ScheduledTask -TaskName "Install" -Trigger $Trigger -Action $Action -Principal $Principal
Register-ScheduledTask -TaskName "Install" -Trigger $Trigger -Action $Action  -RunLevel Highest

shutdown /r
