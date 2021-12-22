# allow running scripts
Set-ExecutionPolicy unrestricted -Force

# download install script
New-Item -ItemType Directory -Force -Path C:\scripts
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/deckard93/install/master/win_install.ps1", "C:\scripts\startup.ps1")

# autologin for restarts
$Username = Read-Host 'Enter username for auto-logon'
$Pass = Read-Host "Enter password for $Username"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Username" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Pass" -type String

# schedule install job to run
$Trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
$Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory C:/Scripts -Argument  "-command C:\scripts\startup.ps1" 
Register-ScheduledTask -TaskName "Install" -Trigger $Trigger -Action $Action  -RunLevel Highest

# restart to start install
shutdown /r
