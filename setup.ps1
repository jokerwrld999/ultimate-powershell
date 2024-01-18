#Requires -RunAsAdministrator

# Set PowerShell execution policy to RemoteSigned for the current user
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Host("Execution policy is already set to RemoteSigned for the current user, skipping...") -f Green
}
else {
    Write-Host("Setting execution policy to RemoteSigned for the current user...") -f Green
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned > $null
}

if ([bool](DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | select-string BingNews)){
    Write-Host("Uninstalling some unwanted packages...") -f Blue

    DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | select-string "^((?!DesktopAppInstaller).)*$" | select-string "^((?!Photos).)*$" | select-string "^((?!Notepad).)*$" | select-string "^((?!Terminal).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}
}
else {
    Write-Host("All unwanted packages are already uninstalled.") -f Green
}

# Check if winget is already installed
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Windows Package Manager (winget) is already installed." -f Green
}
else {
    # Download the latest version of winget
    $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller.msixbundle"
    $outputPath = "winget_install.msixbundle"

    Write-Host "Downloading Windows Package Manager (winget)..." -f Blue
    (New-Object System.Net.WebClient).DownloadFile($url, $outputPath) > $null

    # Install winget
    Write-Host "Installing Windows Package Manager (winget)..."  -f Blue
    Add-AppxPackage -Path $outputPath > $null

    # Remove the downloaded file
    Remove-Item $outputPath

    Write-Host "Windows Package Manager (winget) has been successfully installed." -f Green
}

# Define an array of applications to install
$applications = @(
    @{ Name = "7-Zip"; Id = "7zip.7zip" },
    @{ Name = "Adobe Reader"; Id = "Adobe.Acrobat.Reader.64-bit" },
    @{ Name = "AutoHotkey"; Id = "AutoHotkey.AutoHotkey" },
    @{ Name = "CoreTemp"; Id = "ALCPU.CoreTemp" },
    @{ Name = "Discord"; Id = "Discord.Discord" },
    @{ Name = "Firefox"; Id = "Mozilla.Firefox" },
    @{ Name = "Git"; Id = "Git.Git" },
    @{ Name = "Github CLI"; Id = "GitHub.cli" },
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "Parsec"; Id = "Parsec.Parsec" },
    @{ Name = "Python 3"; Id = "Python.Python.3.11" },
    @{ Name = "ShareX"; Id = "ShareX.ShareX" },
    @{ Name = "Steam"; Id = "Valve.Steam" },
    @{ Name = "Tailscale"; Id = "tailscale.tailscale" },
    @{ Name = "TelegramDesktop"; Id = "Telegram.TelegramDesktop" },
    @{ Name = "VS Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" },
    @{ Name = "qBittorrent"; Id = "qBittorrent.qBittorrent" }
)

foreach ($app in $applications) {
    Write-Host ("Installing $($app.Name)...") -f Blue
    winget install -e --id $($app.Id) --accept-source-agreements --silent > $null
}


Write-Output("Changing registry settings for taskbar, lockscreen, and more...") -f Green

# Set the Windows Taskbar to always combine items
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 0 

# Set the Windows Taskbar to use small icons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 1

# Disable Chat, Widgets Taskbar Buttons
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0

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
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -PropertyType DWord -Value 3 -Force

# Get rid of the incredibly stupid "Show More Options" context menu default that NO ONE ASKED FOR
New-Item -Path 'HKCU:\Software\Classes\CLSID' -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -f
New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Name 'InprocServer32' -Value '' -f

# Set timezone automatically
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value "00000003";

# Disable prompts to create an MSFT account
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "00000000";

Write-Output("Disabling as much data collection / mining as we can...") -f Green
Get-Service DiagTrack | Set-Service -StartupType Disabled
Get-Service dmwappushservice | Set-Service -StartupType Disabled
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Finally, stop and restart explorer.
Get-Process -Name explorer | Stop-Process
start explorer.exe


# >>> Install Terminal Moudules
Install-Module -Name PowerShellGet -Force
Install-Module PSReadLine -AllowPrerelease -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force

# >>> If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
else {
    Remove-Item -Path $PROFILE
    Invoke-RestMethod https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
}
& $profile

# >>> Installing Scoop
if (!(Test-Path -Path ($env:userprofile + "\scoop"))) {
    Write-Host "Installing Scoop Module..." -f Blue
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"

    Write-Host "Check Scoop Module...." -f Blue
    ~\scoop\shims\scoop.cmd update
}
else {
    Write-Host "Updating Scoop Module..." -f Blue
    scoop update
}

# >>> Installing choco
# Install chocolatey
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Host("Chocolatey is already installed, skip installation.") -f Green
}
else {
    Write-Host("Installing Chocolatey...") -f Green
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# >>> Install Oh-My-Posh
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json

# >>> Install Speedtest
choco install speedtest > $null

# >>> Get the NerdFonts
scoop bucket add nerd-fonts > $null
scoop install Meslo-NF Meslo-NF-Mono Hack-NF Hack-NF-Mono FiraCode-NF FiraCode-NF-Mono FiraMono-NF FiraMono-NF-Mono > $null

# >>> Setting Up WSL2
#irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/wsl/SetupWSL.ps1" | iex

irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/AutoHotkey/autohotkey.ps1" | iex