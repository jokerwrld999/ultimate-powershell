#Requires -RunAsAdministrator

# Set PowerShell execution policy to RemoteSigned for the current user
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Host("Execution policy is already set to RemoteSigned for the current user, skipping...") -f Green
}
else {
    Write-Host("Setting execution policy to RemoteSigned for the current user...") -f Green
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned *>$null
}

if ([bool](DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | select-string BingNews)){
    Write-Host("Uninstalling some unwanted packages...") -f Blue

    DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | select-string "^((?!DesktopAppInstaller).)*$" | select-string "^((?!Photos).)*$" | select-string "^((?!Notepad).)*$" | select-string "^((?!Terminal).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}
}
else {
    Write-Host("All unwanted packages are already uninstalled.") -f Green
}

# >>> Installing Scoop
if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is already installed, skip installation." -f Green
}
else {
    Write-Host "Installing Scoop Module..." -f Blue
    iex "& {$(irm get.scoop.sh *>$null)} -RunAsAdmin"
}

Write-Host "Updating Scoop Module..." -f Blue
scoop install 7zip git sudo dark innounp lessmsi aria2 --global --no-cache *>$null
scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core' *>$null
scoop bucket add Scoop-Apps 'https://github.com/ACooper81/scoop-apps' *>$null
scoop bucket add main *>$null
scoop bucket add extras *>$null
scoop bucket add nonportable *>$null
scoop bucket add versions *>$null
scoop bucket add games *>$null
scoop update *>$null

# Define an array of applications to install
$applications = @(
    @{ Name = "Adobe Reader"; Id = "AdobeAcrobatReader-Install" },
    @{ Name = "AutoHotkey"; Id = "extras/autohotkey" },
    @{ Name = "CoreTemp"; Id = "extras/coretemp" },
    @{ Name = "Discord"; Id = "extras/discord" },
    @{ Name = "Firefox"; Id = "extras/firefox" },
    @{ Name = "Github CLI"; Id = "main/gh" },
    @{ Name = "Google Chrome"; Id = "googlechrome" },
    @{ Name = "Oh My Posh"; Id = "main/oh-my-posh" },
    @{ Name = "Parsec"; Id = "nonportable/parsec-np" },
    @{ Name = "Python 3.11"; Id = "versions/python311" },
    @{ Name = "ShareX"; Id = "extras/sharex" },
    @{ Name = "Speedtest CLI"; Id = "extras/speedtest" },
    @{ Name = "Steam"; Id = "games/steam" },
    @{ Name = "Tailscale"; Id = "extras/tailscale" },
    @{ Name = "TelegramDesktop"; Id = "extras/telegram" },
    @{ Name = "VS Code"; Id = "extras/vscode" },
    @{ Name = "qBittorrent"; Id = "extras/qbittorrent" }
)

foreach ($app in $applications) {
    Write-Host ("Installing $($app.Name)...") -f Blue
    scoop install $($app.Id) *>$null
}

Write-Host ("Changing registry settings for taskbar, lockscreen, and more...") -f Blue

# Set the Windows Taskbar to always combine items
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 0

# Set the Windows Taskbar to use small icons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 1

# Disable Chat, Widgets Taskbar Buttons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0

# Set Dark Windows Theme
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

# Disable Game Overlays
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0

# Show hidden files and folders
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1

# Don't hide file extensions
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1

# Don't include public folders in search (faster)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_SearchFiles' -Value 1

# Disable Taskbar / Cortana Search Box on Windows 11
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "00000000";

# Don't show ads / nonsense on the lockscreen
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'ContentDeliveryAllowed' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenEnabled' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338388Enabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-88000326Enabled' -Value 0

# Stop pestering to create a Microsoft Account. Local accounts: this is the way.
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force *>$null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -PropertyType DWord -Value 3 -Force *>$null

# Get rid of the incredibly stupid "Show More Options" context menu default that NO ONE ASKED FOR
New-Item -Path 'HKCU:\Software\Classes\CLSID' -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -f *>$null
New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Name 'InprocServer32' -Value '' -f *>$null

# Set timezone automatically
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value "00000003";

# Disable prompts to create an MSFT account
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "00000000";

Write-Host ("Disabling as much data collection / mining as we can...") -f Blue
Get-Service DiagTrack | Set-Service -StartupType Disabled
Get-Service dmwappushservice | Set-Service -StartupType Disabled
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Finally, stop and restart explorer.
Write-Host ("Restarting Explorer...") -f Blue
Get-Process -Name explorer | Stop-Process
Start-Process Explorer.exe; Start-Sleep -s 2; (New-Object -comObject Shell.Application).Windows() | foreach-object {$_.quit()}

Write-Host ("Installing Terminal Modules...") -f Blue
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PowerShellGet -Force -AllowClobber *>$null
Install-Module PSReadLine -AllowPrerelease -Force *>$null
Install-Module -Name Terminal-Icons -Repository PSGallery -Force *>$null

Write-Host ("Creating Powershell Profile...") -f Blue
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory" *>$null
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory" *>$null
            }
        }

        Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created." -f Green
    }
    catch {
        throw $_.Exception.Message
    }
}
else {
    Remove-Item -Path $PROFILE
    Invoke-RestMethod https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed." -f Green
}
& $profile


# >>> Installing Chocolatey
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Host("Chocolatey is already installed, skip installation.") -f Green
}
else {
    Write-Host("Installing Chocolatey...") -f Blue
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host("Installing Nerd Fonts...") -f Blue
scoop bucket add nerd-fonts *>$null
scoop install Meslo-NF Meslo-NF-Mono Hack-NF Hack-NF-Mono FiraCode-NF FiraCode-NF-Mono FiraMono-NF FiraMono-NF-Mono *>$null

# >>> Setting Up AutoHotkey
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/AutoHotkey/autohotkey.ps1" | iex

# >>> Setting Up WSL2
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/wsl/SetupWSL.ps1" | iex
