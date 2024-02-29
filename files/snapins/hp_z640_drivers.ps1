$hpDriverTempDir = "C:\HpTemp"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$hpDriverTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"
$drivers = @(
  @{ Name = "Intel Rapid Storage Technology";
    installSwitches = "/S"
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Chipset(sp101759).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\chipset.exe";
    hpDestUnzipPath = "$hpDriverTempDir\Chipset";
    hpDriverSrc = "$hpDestUnzipPath\SetupChipset.exe";
    hpChipsetDriverID = "";
  },
  @{ Name = "Intel Management Engine";
    hpDriverID = "$(pnputil /enum-devices /problem | Select-string 'VEN_8086&DEV_8D3D&SUBSYS_212A103C')";
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/IntelME(sp74499).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\intelME.exe";
    hpDestUnzipPath = "$hpDriverTempDir\IntelME";
    hpDriverSrc = "$hpDestUnzipPath\SetupME.exe";
    installSwitches = "-overwrite -s"
  },
  @{ Name = "Intel Chipset";
    hpDriverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086')";
    hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Chipset(sp101759).exe";
    hpSrcUnzipPath = "$hpDriverTempDir\chipset.exe";
    hpDestUnzipPath = "$hpDriverTempDir\Chipset";
    hpDriverSrc = "$hpDestUnzipPath\SetupChipset.exe";
    installSwitches = "/S"
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
  if ([bool]$driver.hpDriverID -or $driver.Name -eq "Intel Rapid Storage Technology") {
    if (!(Test-Path -Path $driver.hpDriverSrc)) {
      Write-Host "####### Downloading HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($driver.hpDriverRemote,$driver.hpSrcUnzipPath)
    }

    if (!(Test-Path -Path $driver.hpDriverSrc)) {
      Write-Host "####### Extracting HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      Start-Process $7zipExe -ArgumentList "x $($driver.hpSrcUnzipPath) `"-o$($driver.hpDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
    }

    Write-Host "####### Installing HP $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process -FilePath $hpDriverSrc -ArgumentList $driver.installSwitches -Wait
  } else {
      Write-Host "####### HP $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

# if (Test-Path -Path $hpDriverSrc) {
#   Remove-Item -Path $hpDriverTempDir -Recurse -Force
# }
