# >>> Installing Scoop
if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop Module..." -f Blue
    iex "& {$(irm get.scoop.sh *>$null)} -RunAsAdmin"
} else {
    Write-Host "Scoop is already installed, skip installation." -f Green
}

# Set Scoop variables
$scoopAppsBucket = 'Scoop-Apps'
$scoopMainBucket = 'main'
$scoopExtrasBucket = 'extras'
$scoopNonPortableBucket = 'nonportable'
$scoopVersionsBucket = 'versions'
$scoopGamesBucket = 'games'

# Add buckets if not already added
$buckets = @($scoopAppsBucket, $scoopMainBucket, $scoopExtrasBucket, $scoopNonPortableBucket, $scoopVersionsBucket, $scoopGamesBucket)
foreach ($bucket in $buckets) {
    if (!(scoop bucket list | Out-String) -contains $bucket) {
        Write-Host "Adding Scoop bucket: $bucket" -f Blue
        scoop bucket add $bucket *>$null
    } else {
        Write-Host "Scoop bucket $bucket is already added, skip adding." -f Green
    }
}

# Set Scoop config
$scoopRepoUrl = 'https://github.com/Ash258/Scoop-Core'
if (!(scoop config SCOOP_REPO | Out-String) -eq $scoopRepoUrl) {
    Write-Host "Setting Scoop repository to $scoopRepoUrl" -f Blue
    scoop config SCOOP_REPO $scoopRepoUrl *>$null
} else {
    Write-Host "Scoop repository is already set to $scoopRepoUrl, skip setting." -f Green
}

# Update Scoop
Write-Host "Updating Scoop Module..." -f Blue
scoop update *>$null

# Applications to install
$applications = @(
    @{ Name = "AdobeAcrobatReader"; Id = "AdobeAcrobatReader-Install" },
    @{ Name = "Autohotkey"; Id = "extras/autohotkey" },
    @{ Name = "Coretemp"; Id = "extras/coretemp" },
    @{ Name = "Discord"; Id = "extras/discord" },
    @{ Name = "Firefox"; Id = "extras/firefox" },
    @{ Name = "Github CLI"; Id = "main/gh" },
    @{ Name = "Google Chrome"; Id = "googlechrome" },
    @{ Name = "Oh-My-Posh"; Id = "main/oh-my-posh" },
    @{ Name = "Parsec"; Id = "nonportable/parsec-np" },
    @{ Name = "Python311"; Id = "versions/python311" },
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
        Write-Host ("Installing $($app.Name)...") -f Blue
        scoop install $($app.Id) *>$null
    } else {
        Write-Host ("$($app.Name) is already installed, skip installation.") -f Green
    }
}

# Install Nerd Fonts
Write-Host("Installing Nerd Fonts...") -f Blue
if (!(scoop bucket list | Out-String) -contains 'nerd-fonts') {
    Write-Host "Adding Scoop bucket: nerd-fonts" -f Blue
    scoop bucket add nerd-fonts *>$null
} else {
    Write-Host "Scoop bucket nerd-fonts is already added, skip adding." -f Green
}

$nerdFonts = @('Meslo-NF', 'Meslo-NF-Mono', 'Hack-NF', 'Hack-NF-Mono', 'FiraCode-NF', 'FiraCode-NF-Mono', 'FiraMono-NF', 'FiraMono-NF-Mono')
foreach ($font in $nerdFonts) {
    if (!(Get-Command -ErrorAction SilentlyContinue -Name $font)) {
        scoop install $font *>$null
    } else {
        Write-Host ("$font is already installed, skip installation.") -f Green
    }
}
