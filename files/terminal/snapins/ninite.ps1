$jobName = "InstallNinite"
$niniteTempPath= "C:\NiniteTemp"
$niniteAppsSource = "$niniteTempPath\niniteN.exe"
$niniteAppsRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/snapins/ninite/niniteN.exe"

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
  if (((Get-Job -Name $jobName).State -eq "Completed")) {
    Get-Process Ninite | Stop-Process
    Remove-Job -Name $jobName
    Remove-Item -Path $niniteTempPath -Recurse -ErrorAction SilentlyContinue -Force
    break
  }
  Start-Sleep 3
}
