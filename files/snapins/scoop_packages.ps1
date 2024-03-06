#Requires -RunAsAdministrator

Write-Host "Current User: $(whoami)"
Write-Host "Current Work Dir: $(pwd)"

$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -ne "RemoteSigned") {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Scoop Module..." -ForegroundColor Blue
  Invoke-Expression "& {$(Invoke-RestMethod 'https://get.scoop.sh')} -RunAsAdmin -ScoopDir 'C:\Scoop' -ScoopGlobalDir `"$env:ProgramData\scoop`""
  [Environment]::SetEnvironmentVariable('SCOOP',"C:\Scoop\scoop",'Machine')
  scoop install gsudo git scoop-search -g *> $null
}

# $scoopAppsBucket = 'Scoop-Apps'
# if (!(scoop bucket list | Select-String $scoopAppsBucket)) {
#   Write-Host "Setting Scoop Apps Custom Bucket" -ForegroundColor Blue
#   scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core' *> $null
#   scoop bucket add 'Base' *> $null
#   scoop update *> $null
# }

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
  @{ Name = "Foxit Reader"; Id = "extras/foxit-reader" },
  @{ Name = "Google Chrome"; Id = "extras/googlechrome" },
  @{ Name = "Slack"; Id = "extras/slack" },
  @{ Name = "Notepad++"; Id = "extras/notepadplusplus" }
)

foreach ($app in $applications) {
  if (!(Get-Command -ErrorAction SilentlyContinue -Name $app.Name)) {
    scoop install $($app.Id) -g *> $null
  }
}

scoop cleanup * *> $null
