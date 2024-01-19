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

Write-Host("Installing Nerd Fonts...") -f Blue
scoop bucket add nerd-fonts *>$null
scoop install Meslo-NF Meslo-NF-Mono Hack-NF Hack-NF-Mono FiraCode-NF FiraCode-NF-Mono FiraMono-NF FiraMono-NF-Mono *>$null