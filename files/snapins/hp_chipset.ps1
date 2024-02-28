$hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Chipset(sp101759).exe"
$hpDriverTempDir = "C:\HpTemp"
$hpSrcUnzipPath = "$hpDriverTempDir\chipset.exe"
$hpDestUnzipPath = "$hpDriverTempDir\Chipset"
$hpDriverSrc = "$hpDestUnzipPath\SetupChipset.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$hpDriverTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"

if (!(Test-Path -Path $hpDriverSrc)) {
  if (!(Test-Path -Path $hpDriverTempDir)) {
    New-Item -Type Directory -Path $hpDriverTempDir | Out-Null
  }
  Write-Host "####### Downloading HP Chipset Driver... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($hpDriverRemote,$hpSrcUnzipPath)
}

if (!(Test-Path -Path $hpDriverSrc)) {
  if (![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
      Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
      Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
  }

  Write-Host "####### Extracting HP Chipset Driver... #######" -ForegroundColor Blue
  Start-Process $7zipExe -ArgumentList "x $hpSrcUnzipPath `"-o$($hpDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
}

$hpChipsetDriverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086')"
if ([bool]$hpChipsetDriverID) {
  Write-Host "####### Installing HP Chipset Driver... #######" -ForegroundColor Blue
  Start-Process -FilePath $hpDriverSrc -ArgumentList "/S" -Wait
} else {
    Write-Host "####### HP Chipset Driver has been already installed. #######" -ForegroundColor Green
}


if (Test-Path -Path $hpDriverSrc) {
  Remove-Item -Path $hpDriverTempDir -Recurse -Force
}
