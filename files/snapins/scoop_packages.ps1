#Requires -RunAsAdministrator

$env:SCOOP_GLOBAL="$env:programdata\GlobalScoopApps"
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
$env:SCOOP='c:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'MACHINE')
$Reg='Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment'
$OldPath=(Get-ItemProperty -Path $Reg -Name PATH).Path
$NewPath=$OldPath+';'+'c:\Scoop\shims'
Set-ItemProperty -Path $Reg -Name PATH -Value $NewPath
$CurrentValue=[Environment]::GetEnvironmentVariable('PSModulePath','Machine')
[Environment]::SetEnvironmentVariable('PSModulePath', $CurrentValue + ';c:\Scoop\modules', 'Machine')

if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop Module..." -ForegroundColor Blue
  iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
  # Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
}

# $scoopAppsBucket = 'Scoop-Apps'
# if (!(scoop bucket list | Select-String $scoopAppsBucket)) {
#   Write-Host "Setting Scoop Apps Custom Bucket" -ForegroundColor Blue
#   scoop install gsudo git scoop-search *> $null
#   scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core' *> $null
#   scoop bucket add 'Base' *> $null
#   [Environment]::SetEnvironmentVariable('SCOOP',"$env:UserProfile\scoop",'User')
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
