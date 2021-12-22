function RestartExplorer {
    # restart explorer
    taskkill /f /im explorer.exe
    Start-Process explorer.exe
}

function ConfigureWindows($desktops) {
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

    $desktops | Get-ChildItem -Filter "*.url" | Remove-Item -Force # some win images have extra urls on desktop
    $desktops | Get-ChildItem -Filter "*.lnk" | Remove-Item -Force # remove desktop shortcuts

    RestartExplorer
}

function InstallChoclatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install chocolatey-core.extension -y
}

function InstallApps($desktops, $app_list) {
    $start_time = Get-Date

    foreach ($app in $app_list) {
        choco install $app -y
    }

    # cleanup any new shortcuts
    $desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $start_time } | Remove-Item
}

function ImportTaskbarLayout($repo) {
    $temp_file = New-TemporaryFile
    Invoke-WebRequest -uri "$repo/taskbar.xml" -OutFile $temp_file
    Import-StartLayout -LayoutPath $temp_file -MountPath "C:\"
    RestartExplorer
}

function InstallConfigFiles($repo) {
    # windows terminal
    Invoke-WebRequest -uri "$repo/win_terminal.json" -OutFile C:\Users\pteo9\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
}


$repo = "https://raw.githubusercontent.com/deckard93/install/master"
$basic_apps = @(
    'googlechrome', 'vlc', 'notepadplusplus', 'winscp', 'filezilla', 'whatsapp', 'teamviewer', 'windirstat', 'audacity', 
    'k-litecodecpackfull', 'spotify', 'winrar', '7zip', 'blender', 'hwmonitor', 'adobedigitaleditions', 'linkshellextension', 
    'netlimiter', 'autohotkey', 'discord', 'qbittorrent', 'steam-client'
)
$dev_apps = @(
    'git.install', 'microsoft-windows-terminal', 'vscode', 'javaruntime', 'vmware-workstation-player', 'virtualbox', 'postman', 
    'dbeaver', 'dotnet4.0', 'androidstudio', 'visualstudio2019community', 'intellijidea-community', 'docker-desktop'
    # 'terraform', 'openjdk', 'jdk8', 'yarn', 'nvm', 'itunes -y # optional - for managing iphone dev dev', 'python', 'python2'
)
$desktops = "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop"


ConfigureWindows $desktops
InstallChoclatey 
InstallApps $desktops $basic_apps
InstallApps $desktops $dev_apps
ImportTaskbarLayout $repo
InstallConfigFiles $repo


# non-choclatey items
# GDS video thumbnailer https://www.gdsoftware.dk/More.aspx?id=7


# install WSL
choco install wsl -y # needs restart
choco install wsl-ubuntu-2004 -y

$username = "tpetrescu"
$password = "1234"
Ubuntu2004 install --root
Ubuntu2004 run useradd -m $username
#Ubuntu2004 run usermod --password '$(echo 1 | openssl passwd -1 -stdin)' $username
Ubuntu2004 run usermod --password $password $username
Ubuntu2004 run usermod -aG sudo $username
Ubuntu2004 config --default-user $username


Write-Host "Done with setup."


