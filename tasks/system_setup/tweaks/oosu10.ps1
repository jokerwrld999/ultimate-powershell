$folderPath = "$ENV:userprofile\OOSU10"
$cfgRemoteScript = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/ooshutup10_winutil_settings.cfg"
$cfgFilePath = "$folderPath\ooshutup10.cfg"
$cfgHashFile = "$folderPath\ooshutup10.cfg.sha256"
$exeFilePath = "$folderPath\OOSU10.exe"

function Stream-FileHash {
    param (
        $Uri
    )
    $wc = [System.Net.WebClient]::new()
    $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
    $FileHash.Hash
}

if (!(Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
}

if (!(Test-Path -Path $exeFilePath)) {
    Write-Host "Downloading OOSU10 executable..." -ForegroundColor Blue
    Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $exeFilePath
}

if (!(Test-Path -Path $cfgFilePath) -or
    (Stream-FileHash -Uri $cfgRemoteScript) -ne (Get-Content $cfgHashFile -EA SilentlyContinue)) {

    Invoke-WebRequest -Uri $cfgRemoteScript -OutFile $cfgFilePath | Out-Null
    (Get-FileHash $cfgFilePath).Hash | Out-File $cfgHashFile

    Write-Host "Downloading ooshutup10 configuration file..." -ForegroundColor Blue
    Invoke-WebRequest -Uri $cfgRemoteScript -OutFile $cfgFilePath

    Write-Host "Executing OOSU10..." -ForegroundColor Blue
    Start-Process -FilePath $exeFilePath -ArgumentList "$cfgFilePath /quiet" -NoNewWindow

    Write-Host "OOSU10 completed successfully." -ForegroundColor Green
}
