#Requires -RunAsAdministrator

if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Scoop Module..." -ForegroundColor Blue
  Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
}

$scoopAppsBucket = 'Scoop-Apps'
if (!(scoop bucket list | Select-String $scoopAppsBucket)) {
  Write-Host "Setting Scoop Apps Custom Bucket" -ForegroundColor Blue
  scoop install gsudo git scoop-search *> $null
  scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core' *> $null
  scoop bucket add 'Base' *> $null
  scoop bucket add Scoop-Apps 'https://github.com/ACooper81/scoop-apps' *> $null
  [Environment]::SetEnvironmentVariable('SCOOP',"$env:UserProfile\scoop",'User')
  scoop update *> $null
}

$buckets = @('main','extras','nerd-fonts','nonportable','games','Scoop-Apps')
foreach ($bucket in $buckets) {
  if (!(scoop bucket list | Select-String $bucket)) {
    Write-Host "Adding Scoop bucket: $bucket" -ForegroundColor Blue
    scoop bucket add $bucket *> $null
  }
}

Write-Host "Updating Scoop Module..." -ForegroundColor Blue
scoop update * *> $null

$applications = @(
  @{ Name = "AdobeAcrobatReader"; Id = "Scoop-Apps/AdobeAcrobatReader-Install" },
  @{ Name = "Autohotkey"; Id = "extras/autohotkey" },
  @{ Name = "Coretemp"; Id = "extras/coretemp" },
  @{ Name = "Discord"; Id = "extras/discord" },
  @{ Name = "Firefox"; Id = "extras/firefox" },
  @{ Name = "Github CLI"; Id = "gh" },
  @{ Name = "Google Chrome"; Id = "googlechrome" },
  @{ Name = "Grep"; Id = "grep" },
  @{ Name = "Nano"; Id = "nano" },
  @{ Name = "NTop"; Id = "ntop" },
  @{ Name = "Oh-My-Posh"; Id = "main/oh-my-posh" },
  @{ Name = "Parsec"; Id = "nonportable/parsec-np" },
  @{ Name = "Python"; Id = "python" },
  @{ Name = "Sharex"; Id = "extras/sharex" },
  @{ Name = "Speedtest"; Id = "main/speedtest-cli" },
  @{ Name = "Steam"; Id = "games/steam" },
  @{ Name = "Tailscale"; Id = "extras/tailscale" },
  @{ Name = "Telegram"; Id = "extras/telegram" },
  @{ Name = "Vim"; Id = "vim" },
  @{ Name = "VsCode"; Id = "extras/vscode" },
  @{ Name = "qBittorrent"; Id = "extras/qbittorrent" }
)

foreach ($app in $applications) {
  if (!(Get-Command -ErrorAction SilentlyContinue -Name $app.Name)) {
    scoop install $($app.Id) *> $null
  }
}

$nerdFonts = @('Meslo-NF','Meslo-NF-Mono','Hack-NF','Hack-NF-Mono','FiraCode-NF','FiraCode-NF-Mono','FiraMono-NF','FiraMono-NF-Mono')
foreach ($font in $nerdFonts) {
  if (!(Get-Command -ErrorAction SilentlyContinue -Name $font)) {
    scoop install $font *> $null
  }
}

scoop cleanup * *> $null
