$global:state_file = "c:\scripts\last_stage.dat"
$global:check_stage = 0

function Get-LastStage {
    if (Test-Path $global:state_file -PathType leaf) {
        $last_stage = [int] (Get-Content $global:state_file)
    } else {
        $last_stage = 0
        $last_stage > $global:state_file
    }
    return $last_stage
}

function Set-LastStage($last_stage) {
    $last_stage += 1
    $last_stage > $global:state_file
    Write-Host ("Stored Last Stage = " + $last_stage)
}

function Step-Stage($last_stage, $command) {
    if ($last_stage -eq $global:check_stage) {
        Invoke-Expression $command
        Set-LastStage $last_stage
        shutdown /r
    }
    $global:check_stage += 1
}


function SetupWindowsUpdates {
    Write-Host ("installing NuGet, PSWIndowsUpdate ...")
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -Force
    Install-Module PSWindowsUpdate -Force

    Write-Host ("installing all available windows updates ...")
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
}

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

    # configure user account control settings (UAC) - Note this will make everything run with max priviledges
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
    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:APPDATA\OneNote.lnk")
    $Shortcut.TargetPath = "shell:AppsFolder\Microsoft.Office.OneNote_8wekyb3d8bbwe!microsoft.onenoteim"
    $Shortcut.Save()

    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:APPDATA\WinTerminal.lnk")
    $Shortcut.TargetPath = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
    $Shortcut.Save()

    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:APPDATA\SoundRecorder.lnk")
    $Shortcut.TargetPath = "shell:AppsFolder\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe!App"
    $Shortcut.Save()

    $pin_util = "PinUtil.exe"
    Invoke-WebRequest -uri "$repo/PinUtil.exe" -OutFile $pin_util
    $app_list = @(
        "%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk",
		"C:\Program Files\Notepad++\notepad++.exe",
		"C:\Program Files\Oracle\VirtualBox\VirtualBox.exe",
		"%APPDATA%\Microsoft\Windows\Start Menu\Programs\Spotify.lnk",
		"C:\Program Files\Google\Chrome\Application\chrome.exe",
		"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
		"C:\Program Files\Microsoft VS Code\Code.exe",
		"C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2021.3\bin\idea64.exe",
		"C:\Program Files\Android\Android Studio\bin\studio64.exe",
		"C:\Program Files\DBeaver\dbeaver.exe",
        "%APPDATA%\OneNote.lnk",
		"C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE",
		"C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE",
		"C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE",
		"%APPDATA%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk",
		"%APPDATA%\Microsoft\Windows\Start Menu\Programs\WhatsApp\WhatsApp.lnk",
		"C:\Program Files (x86)\Steam\steam.exe",
		"C:\Program Files (x86)\VMware\VMware Player\vmplayer.exe",
        "%APPDATA%\WinTerminal.lnk",
        "%APPDATA%\SoundRecorder.lnk"
    )

    foreach ($app in $app_list) {
        & ".\$pin_util" "TaskBar", $app
        Start-Sleep -s 1
    }
    
    Remove-Item $pin_util
}

function InstallConfigFiles($repo) {
    # windows terminal
    New-Item -ItemType SymbolicLink -Force -Path "C:\Users\pteo9\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "C:\Users\pteo9\OneDrive\Configs\win_terminal.json"
    New-Item -ItemType SymbolicLink -Force -Path "C:\Users\pteo9\AppData\Roaming\AltDrag\AltDrag.ini" -Target "C:\Users\pteo9\OneDrive\Configs\altdrag.ini"
}

function DisableStartupApps() {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Discord"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "NetLimiter"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Spotify"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Steam"
}
function SetupWSL() {
    choco install wsl-ubuntu-2004 -y
    $username = "deckard"
    $password = "1234"
    Ubuntu2004 install --root
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/deckard93/install/master/linux_root_install.sh", "C:\scripts\linux_root_install.sh")
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/deckard93/install/master/linux_user_install.sh", "C:\scripts\linux_user_install.sh")
    bash "/mnt/c/scripts/linux_root_install.sh"
    wsl useradd -m -s /usr/bin/bash $username
    wsl usermod -aG sudo $username
    wsl usermod --password "`$(echo $password | openssl passwd -1 -stdin)" $username
    Ubuntu2004 config --default-user $username
    bash "/mnt/c/scripts/linux_user_install.sh"
}

function InstallOffice() {
    choco install -y microsoft-office-deployment --params '/64bit /Product:Professional2019Retail /Exclude=Publisher,Lync,Groove,Access,Publisher'
}

function InstallBasicApps() {
    $basic_apps = @(
        'googlechrome', 'vlc', 'notepadplusplus', 'winscp', 'filezilla', 'whatsapp', 'teamviewer', 'windirstat', 'audacity', 
        'k-litecodecpackfull', 'winrar', '7zip', 'blender', 'hwmonitor', 'adobedigitaleditions', 'linkshellextension', 
        'netlimiter', 'autohotkey', 'discord', 'qbittorrent', 'steam-client', 'spotify', 'altdrag'
    )

    InstallChoclatey 
    InstallApps $desktops $basic_apps
    InstallOffice
}

function InstallDevApps1() {
    $apps = @('vscode', 'virtualbox', 'wsl')
    InstallApps $desktops $apps
}

function InstallDevApps2() {
    $apps = @(
        'visualstudio2019community', 'vmware-workstation-player', 'git.install', 'microsoft-windows-terminal', 'javaruntime', 'postman', 
        'dbeaver', 'dotnet4.0', 'androidstudio', 'intellijidea-community', 'docker-desktop', 'python', 'terraform', 'yarn'
        # 'python2', 'openjdk', 'jdk8', 'nvm', 'itunes -y # optional - for managing iphone dev dev'
    )
    InstallApps $desktops $apps
}

function InstallConfigs() {
    ConfigureWindows $desktops
    ImportTaskbarLayout $repo
    InstallConfigFiles $repo
    DisableStartupApps
}

function Cleanup() {
    # disable auto-log in
    $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    Remove-ItemProperty $RegistryPath 'AutoAdminLogon'
    Remove-ItemProperty $RegistryPath 'DefaultUsername' 
    Remove-ItemProperty $RegistryPath 'DefaultPassword'
}

$repo = "https://raw.githubusercontent.com/deckard93/install/master"
$desktops = "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop"


$last_stage = Get-LastStage
Write-Host ("Last Stage: " + $last_stage)
Step-Stage $last_stage "SetupWindowsUpdates"
Step-Stage $last_stage "SetupWindowsUpdates"
Step-Stage $last_stage "InstallBasicApps"
Step-Stage $last_stage "InstallDevApps1"
Step-Stage $last_stage "InstallDevApps2"
Step-Stage $last_stage "InstallConfigs"
Step-Stage $last_stage "SetupWSL"
Step-Stage $last_stage "Cleanup"
Write-Host "finished script run ..."


# non-choclatey items
# GDS video thumbnailer https://www.gdsoftware.dk/More.aspx?id=7


