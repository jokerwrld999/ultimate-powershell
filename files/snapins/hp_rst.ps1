$hpDriverRemote = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp/Raid(sp96420).exe"
$hpDriverTempDir = "C:\HpTemp"
$hpSrcUnzipPath = "$hpDriverTempDir\rst.exe"
$hpDestUnzipPath = "$hpDriverTempDir\RST"
$hpDriverSrc = "$hpDestUnzipPath\Setup.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$hpDriverTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"



if (!(Test-Path -Path $hpDriverSrc)) {
  if (!(Test-Path -Path $hpDriverTempDir)) {
    New-Item -Type Directory -Path $hpDriverTempDir | Out-Null
  }
  Write-Host "####### Downloading HP RST Driver... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($hpDriverRemote,$hpSrcUnzipPath)
}

if (!(Test-Path -Path $hpDriverSrc)) {
  if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
      Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
      Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
  }

  Write-Host "####### Extracting HP RST Driver... #######" -ForegroundColor Blue
  Start-Process $7zipExe -ArgumentList "x $hpSrcUnzipPath `"-o$($hpDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
}

Write-Host "####### Installing HP RST Driver... #######" -ForegroundColor Blue
Start-Process -FilePath $hpDriverSrc -ArgumentList "/S" -Wait

if (Test-Path -Path $hpDriverSrc) {
  Remove-Item -Path $hpDriverTempDir -Recurse -Force
}
