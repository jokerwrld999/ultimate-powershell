$jobName = "InstallNinite"
$niniteTempPath= "C:\NiniteTemp"
$niniteAppsSource = "$niniteTempPath\niniteN.exe"
$niniteAppsRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/snapins/ninite/niniteN.exe"
$niniteAppsInstalled = "C:\Program Files (x86)\Notepad++\notepad++.exe"

if (!(Test-Path -Path $niniteTempPath)) {
  Write-Host "####### Downloading Ninite Apps... #######" -ForegroundColor Blue
  New-Item -Path $niniteTempPath -ItemType Directory | Out-Null
  Invoke-WebRequest -Uri $niniteAppsRemote -OutFile $niniteAppsSource
}

Write-Host "####### Installing Ninite Apps... #######" -ForegroundColor Blue
Start-Job -Name $jobName -ScriptBlock {
  Start-Process -WindowStyle hidden -FilePath "C:\NiniteTemp\niniteN.exe" -Wait
} | Out-Null

while ($true) {
  if ((Test-Path -Path $niniteAppsInstalled)) {
    Get-Process Ninite -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue
    Stop-Job -Name $jobName
    Remove-Job -Name $jobName
    Write-Host "####### Ninite Apps installed successfully. #######" -ForegroundColor Green
    break
  }
  Start-Sleep 3
}

if ((Test-Path -Path $niniteTempPath)) {
  Write-Host "####### Cleaning... #######" -ForegroundColor Blue
  Remove-Item -Path $niniteTempPath -Recurse -ErrorAction SilentlyContinue -Force
}
