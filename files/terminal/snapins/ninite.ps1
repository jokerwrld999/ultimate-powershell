$jobName = "InstallNinite"
$niniteTempPath= "C:\NiniteTemp"
$niniteAppsSource = "$niniteTempPath\NiniteApps.exe"
$niniteAppsRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/snapins/ninite/NiniteApps.exe"
$niniteAppsInstalled = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (!(Test-Path -Path $niniteTempPath)) {
  Write-Host "####### Downloading Ninite Apps... #######" -ForegroundColor Blue
  New-Item -Path $niniteTempPath -ItemType Directory | Out-Null
  Invoke-WebRequest -Uri $niniteAppsRemote -OutFile $niniteAppsSource
}

Write-Host "####### Installing Ninite Apps... #######" -ForegroundColor Blue
Start-Job -Name $jobName -ScriptBlock {
  Start-Process -WindowStyle hidden -FilePath "C:\NiniteTemp\NiniteApps.exe" -Wait
} | Out-Null

while ($true) {
  if ((Test-Path -Path $niniteAppsInstalled)) {
    Start-Sleep 60
    taskkill.exe /IM "Ninite.exe" /F /FI "STATUS eq RUNNING"
    # Get-Process Ninite -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue
    Stop-Job -Name $jobName
    Remove-Job -Name $jobName
    Write-Host "####### Ninite Apps installed successfully. #######" -ForegroundColor Green
    break
  }
  Start-Sleep 120
}

if ((Test-Path -Path $niniteTempPath)) {
  Write-Host "####### Cleaning $niniteTempPath... #######" -ForegroundColor Blue
  Remove-Item -Path "C:\NiniteTemp" -Recurse -Force
}
