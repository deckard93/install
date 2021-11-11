$repo = "https://raw.githubusercontent.com/deckard93/install/master"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$StartTime = Get-Date

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
choco install qbittorrent -y
#choco install steam-client -y

# non-choclatey items
# GDS video thumbnailer https://www.gdsoftware.dk/More.aspx?id=7


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
$Desktops | Get-ChildItem -Filter "*.url" | Remove-Item -Force # some win images have extra urls on desktop
$Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime } | Remove-Item


# disable files/folders getting autoadded to quick access
Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Type 'DWord' -Name 'ShowFrequent' -value '0'
Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Type 'DWord' -Name 'ShowRecent' -value '0'
# open explorer to my pc by default
Set-Itemproperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Type 'DWord' -Name 'LaunchTo' -value '1'


# configure user account control settings (UAC)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name PromptOnSecureDesktop -PropertyType DWord -Value 0 -Force


# hide special icons on taskbar
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Type DWord -Force
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 0 -Type DWord -Force
# remove default pinned apps from taskbar
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ForEach-Object { $_.Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true} })
# import taskbar layout
$temp_file = New-TemporaryFile
Invoke-WebRequest -uri "$repo/taskbar.xml" -OutFile $temp_file
Import-StartLayout -LayoutPath $temp_file -MountPath "C:\"


# apply windows terminal settings file
Invoke-WebRequest -uri "$repo/win_terminal.json" -OutFile C:\Users\pteo9\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json


# install WSL
choco install wsl -y
choco install wsl-ubuntu-2004 -y
# install WSL
# First define path to the installed ubuntu2004.exe
$str1="/Users/"
$str2="/AppData/Local/Microsoft/WindowsApps/ubuntu2004"
$hdd_name=(Get-WmiObject Win32_OperatingSystem).SystemDrive
$username=$env:UserName
[String] $ubuntu1804_path=$hdd_name+$str1+$username+$str2


# let root be default username
$ubuntu1804_path=Ubuntu2004
$str1=" install --root"
$set_user=$ubuntu1804_path+$str1
Write-Output $set_user
invoke-expression -Command $set_user 

Ubuntu2004 install --root
Ubuntu2004 run useradd -m tpetrescu
Ubuntu2004 run usermod --password '$(echo 1 | openssl passwd -1 -stdin)' tpetrescu
Ubuntu2004 run usermod -aG sudo tpetrescu
Ubuntu2004 config --default-user tpetrescu


Write-Host "Done with setup."

