$hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Chipset(sp101759).exe"
$hpDriverTempDir = "C:\HpTemp"
$hpDriverSrc = "$hpDriverTempDir\chipset.exe"
$hpDestUnzipPath = "$hpDriverTempDir\Chipset"

if (!(Test-Path -Path $hpDriverTempDir)) {
  New-Item -Type Directory -Path $hpDriverTempDir
}

Write-Host "####### Downloading HP Chipset Driver... #######" -ForegroundColor Blue
(New-Object System.Net.WebClient).DownloadFile($hpDriverRemote,$hpDriverSrc)

Start-Process -FilePath $hpDriverSrc -ArgumentList "/f $hpDestUnzipPath" -Wait

# if (Test-Path -Path $hpDriverSrc) {
#   Remove-Item -Path $hpDriverTempDir -Recurse -Force
# }
