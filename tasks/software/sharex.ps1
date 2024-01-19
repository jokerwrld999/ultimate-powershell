$sharexBackupFolder = [System.IO.Path]::Combine($env:USERPROFILE, "scoop\apps\sharex\current\ShareX\Backup")
$sourceFile = [System.IO.Path]::Combine($sharexBackupFolder, "ShareX_backup.sxb")

Write-Host "Restoring ShareX backup..." -f Blue
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
  Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/sharex/ShareX_backup.sxb -OutFile $sourceFile
  Write-Host "The backup @ [$sourceFile] has been restored." -f Green
}