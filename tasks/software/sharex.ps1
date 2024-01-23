$sharexFileName = "ShareX.exe"
$sharexAppPath = "$env:USERPROFILE\scoop\apps\sharex\current\$sharexFileName"
$startupShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$sharexFileName.lnk"
$sharexBackupFolder = "$env:USERPROFILE\Documents\ShareX\Backup"
$sourceFile = "$sharexBackupFolder\ShareX_backup.sxb"

Write-Host "Creating ShareX Shortcut at the Startup folder..." -f Blue
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($startupShortcutPath)
$Shortcut.TargetPath = $sharexAppPath
$Shortcut.Save()

Write-Host "Starting ShareX..." -f Blue
Start-Process -FilePath $sharexAppPath -WindowStyle hidden *>$null
Write-Host "The ShareX app has been started and shortcut was created at the Startup folder." -f Green

Write-Host "Restoring ShareX backup..." -f Blue
if (!(Test-Path -Path $sharexBackupFolder -PathType Leaf)) {
  Write-Host ("Creating $sharexBackupFolder folder...") -f Blue
  New-Item -Path $sharexBackupFolder -ItemType "directory" *>$null
}

Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/sharex/ShareX_backup.sxb -OutFile $sourceFile
Write-Host "The backup @ [$sourceFile] has been restored." -f Green
