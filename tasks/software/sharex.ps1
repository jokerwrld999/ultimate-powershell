$sharexBackupFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Documents\ShareX\Backup")
$sourceFile = [System.IO.Path]::Combine($sharexBackupFolder, "ShareX_backup.sxb")

Write-Host "Restoring ShareX backup..." -f Blue
if (!(Test-Path -Path $sharexBackupFolder -PathType Leaf)) {
  Write-Host ("Creating $sharexBackupFolder folder...") -f Blue
  New-Item -Path $sharexBackupFolder -ItemType "directory" *>$null
}

Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/sharex/ShareX_backup.sxb -OutFile $sourceFile
Write-Host "The backup @ [$sourceFile] has been restored." -f Green
