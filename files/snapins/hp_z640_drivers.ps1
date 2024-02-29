$hpDriverTempDir = "C:\HpTemp"
$intelRSTExe = "C:\Program Files (x86)\Intel\Intel(R) Rapid Storage Technology enterprise\IAStorUI.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$hpDriverTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"
$drivers = @(
  @{ Name = "Intel Rapid Storage Technology";
    # hpDriverID = "";
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/IntelRST(sp96420).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\rst.exe";
    hpDestUnzipPath = "$hpDriverTempDir\RST";
    hpDriverExe = "Setup.exe";
    installSwitches = "-notray -s"
  },
  @{ Name = "Intel Management Engine";
    hpDriverID = "$(pnputil /enum-devices /problem | Select-string 'VEN_8086&DEV_8D3D&SUBSYS_212A103C')";
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/IntelME(sp74499).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\intelME.exe";
    hpDestUnzipPath = "$hpDriverTempDir\IntelME";
    hpDriverExe = "SetupME.exe";
    installSwitches = "-overwrite -noIMSS -s"
  },
  @{ Name = "Intel Chipset";
    hpDriverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086')";
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Chipset(sp101759).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\chipset.exe";
    hpDestUnzipPath = "$hpDriverTempDir\Chipset";
    hpDriverExe = "SetupChipset.exe";
    installSwitches = "-s -norestart"
  }
)

if (!(Test-Path -Path $hpDriverTempDir)) {
  New-Item -Type Directory -Path $hpDriverTempDir | Out-Null
}

if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
  Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
  Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
}

foreach ($driver in $drivers) {
  if ([bool]$driver.hpDriverID -or !(Test-Path -Path $intelRSTExe)) {
    if (!(Test-Path -Path "$($driver.hpDestUnzipPath)\$($driver.hpDriverExe)")) {
      Write-Host "####### Downloading HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($driver.hpDriverRemote,$driver.hpSrcUnzipPath)
    }

    if (!(Test-Path -Path "$($driver.hpDestUnzipPath)\$($driver.hpDriverExe)")) {
      Write-Host "####### Extracting HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      Start-Process $7zipExe -ArgumentList "x $($driver.hpSrcUnzipPath) `"-o$($driver.hpDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
    }
    Write-Host "DRIversrc: $($driver.hpDestUnzipPath)\$($driver.hpDriverExe)" -ForegroundColor DarkYellow
    Write-Host "####### Installing HP $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process -FilePath "$($driver.hpDestUnzipPath)\$($driver.hpDriverExe)" -ArgumentList $driver.installSwitches -Wait
  } else {
      Write-Host "####### HP $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

# if (Test-Path -Path $hpDriverExe) {
#   Remove-Item -Path $hpDriverTempDir -Recurse -Force
# }
