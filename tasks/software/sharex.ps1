$sharexFileName = "ShareX"
$sharexAppPath = "$env:USERPROFILE\scoop\apps\sharex\current\$sharexFileName.exe"
$sharexStartupShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$sharexFileName.lnk"
$sharexBackupFolder = "$env:USERPROFILE\Documents\ShareX\Backup"
$sharexBackupSource = "$sharexBackupFolder\ShareX_backup.sxb"
$sharexHashFile = "$sharexBackupSource.sha256"
$sharexRemoteFile = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/sharex/ShareX_backup.sxb"

function Get-UriHash {
  param(
    $Uri
  )
  $wc = [System.Net.WebClient]::new()
  $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
  $FileHash.Hash
}

if (!(Test-Path -Path $sharexBackupFolder -PathType Container)) {
  Write-Host "Creating $sharexBackupFolder folder..." -ForegroundColor Blue
  New-Item -Path $sharexBackupFolder -ItemType Directory -Force | Out-Null
}

if (!(Test-Path -Path $sharexBackupSource -PathType Leaf) -or
  (Get-UriHash -Uri $sharexRemoteFile) -ne (Get-Content $sharexHashFile -EA SilentlyContinue)) {

  Write-Host "Restoring ShareX Backup..." -ForegroundColor Blue
  Invoke-WebRequest -Uri $sharexRemoteFile -OutFile $sharexBackupSource
  (Get-FileHash $sharexBackupSource).Hash | Out-File $sharexHashFile

  Write-Host "The backup @ [$sharexBackupSource] has been restored." -ForegroundColor Green
} else {
  Write-Host "ShareX Backup has been already downloaded." -ForegroundColor Green
}

if (!(Test-Path -Path $sharexStartupShortcut -PathType Leaf)) {
  Write-Host "Creating ShareX Shortcut at the Startup folder..." -ForegroundColor Blue
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($sharexStartupShortcut)
  $Shortcut.TargetPath = $sharexAppPath
  $Shortcut.WindowStyle = 7
  $Shortcut.Save()

  Write-Host "Starting ShareX..." -ForegroundColor Blue
  Start-Process -FilePath $sharexStartupShortcut
  Write-Host "Startup Shortcut is created successfully." -ForegroundColor Green
} else {
  Write-Host "Startup Shortcut has been already created." -ForegroundColor Green
}
