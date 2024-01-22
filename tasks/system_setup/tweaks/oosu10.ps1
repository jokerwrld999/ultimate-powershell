$folderPath = "$ENV:userprofile\OOSU10"

if (-not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
}

$cfgFilePath = Join-Path -Path $folderPath -ChildPath "ooshutup10.cfg"
$exeFilePath = Join-Path -Path $folderPath -ChildPath "OOSU10.exe"

if (-not (Test-Path -Path $cfgFilePath)) {
    Write-Host "Downloading ooshutup10 configuration file..." -ForegroundColor Blue
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/ooshutup10_winutil_settings.cfg" -OutFile $cfgFilePath
}

if (-not (Test-Path -Path $exeFilePath)) {
    Write-Host "Downloading OOSU10 executable..." -ForegroundColor Blue
    Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $exeFilePath
}

Write-Host "Executing OOSU10..." -ForegroundColor Blue
Start-Process -FilePath $exeFilePath -ArgumentList "$cfgFilePath /quiet" -NoNewWindow

Write-Host "OOSU10 completed successfully." -ForegroundColor Green
