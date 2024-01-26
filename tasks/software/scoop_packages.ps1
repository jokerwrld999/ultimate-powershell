if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop Module..." -f Blue
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
}

$buckets = @('main', 'extras', 'nerd-fonts', 'nonportable', 'games', 'Scoop-Apps')
foreach ($bucket in $buckets) {
    if (!(scoop bucket list | Select-string $bucket)) {
        Write-Host "Adding Scoop bucket: $bucket" -f Blue
        scoop bucket add $bucket
    }
}

$scoopRepoUrl = 'https://github.com/Ash258/Scoop-Core'
if (!((scoop config SCOOP_REPO) -eq $scoopRepoUrl)) {
    Write-Host "Setting Scoop repository to $scoopRepoUrl" -f Blue
    scoop config SCOOP_REPO $scoopRepoUrl *>$null
}

# Update Scoop
Write-Host "Updating Scoop Module..." -f Blue
scoop update * *>$null

# Applications to install
$applications = @(
    @{ Name = "AdobeAcrobatReader"; Id = "Scoop-Apps/AdobeAcrobatReader-Install" },
    @{ Name = "Autohotkey"; Id = "extras/autohotkey" },
    @{ Name = "Coretemp"; Id = "extras/coretemp" },
    @{ Name = "Discord"; Id = "extras/discord" },
    @{ Name = "Firefox"; Id = "extras/firefox" },
    @{ Name = "Github CLI"; Id = "gh" },
    @{ Name = "Google Chrome"; Id = "googlechrome" },
    @{ Name = "Grep"; Id = "grep" },
    @{ Name = "NTop"; Id = "ntop" },
    @{ Name = "Oh-My-Posh"; Id = "main/oh-my-posh" },
    @{ Name = "OpenSSH"; Id = "openssh" },
    @{ Name = "Parsec"; Id = "nonportable/parsec-np" },
    @{ Name = "Python"; Id = "python" },
    @{ Name = "Sharex"; Id = "extras/sharex" },
    @{ Name = "Speedtest"; Id = "extras/speedtest" },
    @{ Name = "Steam"; Id = "games/steam" },
    @{ Name = "Tailscale"; Id = "extras/tailscale" },
    @{ Name = "Telegram"; Id = "extras/telegram" },
    @{ Name = "VsCode"; Id = "extras/vscode" },
    @{ Name = "qBittorrent"; Id = "extras/qbittorrent" }
)

foreach ($app in $applications) {
    if (!(Get-Command -ErrorAction SilentlyContinue -Name $app.Name)) {
        scoop install $($app.Id) *>$null
    }
}

$nerdFonts = @('Meslo-NF', 'Meslo-NF-Mono', 'Hack-NF', 'Hack-NF-Mono', 'FiraCode-NF', 'FiraCode-NF-Mono', 'FiraMono-NF', 'FiraMono-NF-Mono')
foreach ($font in $nerdFonts) {
    if (!(Get-Command -ErrorAction SilentlyContinue -Name $font)) {
        scoop install $font *>$null
    }
}

scoop cleanup * *>$null