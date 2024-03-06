$DriverTempDir = "C:\DesktopTemp"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$DriverTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"
$drivers = @(
  @{ Name = "Intel Chipset";
    DriverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086')";
    DriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/desktop_drivers/Chipset.zip";
    SrcUnzipPath = "$DriverTempDir\chipset.zip";
    DestUnzipPath = "$DriverTempDir\Chipset";
    DriverExe = "SetupChipset.exe";
    installSwitches = "-s -norestart"
  }
)

if (!(Test-Path -Path $DriverTempDir)) {
  New-Item -Type Directory -Path $DriverTempDir | Out-Null
}

if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
  Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
  Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
}

foreach ($driver in $drivers) {
  if ([bool]$driver.DriverID -or !(Test-Path -Path $intelRSTExe)) {
    if (!(Test-Path -Path "$($driver.DestUnzipPath)\$($driver.DriverExe)")) {
      Write-Host "####### Downloading Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($driver.DriverRemote,$driver.SrcUnzipPath)
    }

    if (!(Test-Path -Path "$($driver.DestUnzipPath)\$($driver.DriverExe)")) {
      Write-Host "####### Extracting Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
      if (Test-Path -Path $7zipExe){
        Start-Process $7zipExe -ArgumentList "x $($driver.SrcUnzipPath) `"-o$($driver.DestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      } else {
        Start-Process 7z -ArgumentList "x $($driver.SrcUnzipPath) `"-o$($driver.DestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      }
    }
    Write-Host "####### Installing Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process -FilePath "$($driver.DestUnzipPath)\$($driver.DriverExe)" -ArgumentList $driver.installSwitches -Wait
  } else {
      Write-Host "####### Desktop $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

if (Test-Path -Path $driver.DriverExe) {
  Remove-Item -Path $driver.DriverTempDir -Recurse -Force
}
