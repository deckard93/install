$StartTime = Get-Date

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install chocolatey-core.extension -y
choco install googlechrome -y
choco install vlc -y
choco install notepadplusplus -y
choco install winscp -y
choco install filezilla -y
choco install whatsapp -y
choco install teamviewer -y
choco install windirstat -y
choco install audacity -y
choco install k-litecodecpackfull -y
choco install spotify -y
choco install winrar -y
choco install 7zip -y
choco install blender -y
choco install hwmonitor -y
choco install adobedigitaleditions -y
choco install linkshellextension -y
choco install netlimiter -y
choco install autohotkey -y
choco install discord -y
#choco install steam-client -y
#choco install qbittorrent -y

# dev tools
choco install git.install -y 
choco install microsoft-windows-terminal -y
choco install vscode -y
choco install javaruntime -y
choco install vmware-workstation-player -y
choco install virtualbox -y
choco install postman -y
choco install dbeaver -y
choco install dotnet4.0 -y
choco install wsl -y
choco install wsl2 -y
choco install wsl-ubuntu-2004 -y # needs restart after installing wsl
choco install androidstudio -y
choco install visualstudio2019community -y
choco install intellijidea-community -y
choco install docker-desktop -y
#choco install mongodb-compass -
#choco install terraform -y
#choco install openjdk -y
#choco install jdk8 -y
#choco install yarn -y
#choco install nvm -y
#choco install itunes -y # optional - for managing iphone dev device
#choco install python -y
#choco install python2 -y

# cleanup any new shortcuts
$Desktops = "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop"
$Desktops | Get-ChildItem -Filter "*.lnk" | Remove-Item
$Desktops | Get-ChildItem -Filter "*.url" | Remove-Item -Force
# $Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime } | Remove-Item


# disable files/folders getting autoadded to quick access
Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Type 'DWord' -Name 'ShowFrequent' -value '0'
Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Type 'DWord' -Name 'ShowRecent' -value '0'
# open explorer to my pc by default 
Set-Itemproperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Type 'DWord' -Name 'LaunchTo' -value '1'

# configure user account control settings (UAC)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name PromptOnSecureDesktop -PropertyType DWord -Value 0 -Force

# hide icons on taskbar
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Type DWord -Force
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 0 -Type DWord -Force


# install WSL
#Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
#Add-AppxPackage .\Ubuntu.appx
# needs restart here
#wsl --set-default-version 1


