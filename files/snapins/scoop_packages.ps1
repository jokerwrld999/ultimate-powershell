#Requires -RunAsAdministrator

if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Scoop Module..." -ForegroundColor Blue
  Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin" *> $null
}

$scoopAppsBucket = 'Scoop-Apps'
if (!(scoop bucket list | Select-String $scoopAppsBucket)) {
  Write-Host "Setting Scoop Apps Custom Bucket" -ForegroundColor Blue
  scoop install gsudo git scoop-search *> $null
  scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core' *> $null
  scoop bucket add 'Base' *> $null
  [Environment]::SetEnvironmentVariable('SCOOP',"$env:UserProfile\scoop",'User')
  scoop update *> $null
}

$buckets = @('main','extras')
foreach ($bucket in $buckets) {
  if (!(scoop bucket list | Select-String $bucket)) {
    Write-Host "Adding Scoop bucket: $bucket" -ForegroundColor Blue
    scoop bucket add $bucket *> $null
  }
}

Write-Host "Updating Scoop Module..." -ForegroundColor Blue
scoop update * *> $null

$applications = @(
  @{ Name = "Firefox"; Id = "extras/firefox" },
  @{ Name = "Google Chrome"; Id = "googlechrome" }
)

foreach ($app in $applications) {
  if (!(Get-Command -ErrorAction SilentlyContinue -Name $app.Name)) {
    scoop install $($app.Id) -g *> $null
  }
}

scoop cleanup * *> $null
