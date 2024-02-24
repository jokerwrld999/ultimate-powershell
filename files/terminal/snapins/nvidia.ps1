$nvTempDir = "C:\NvidiaTemp"
$nvSrc = "$nvTempDir\driver.exe"
$nvLatestVersion = "551.61"
$nvRemote = "https://uk.download.nvidia.com/Windows/$nvLatestVersion/$nvLatestVersion-desktop-win10-win11-64bit-international-dch-whql.exe"
$nvGetVersion = (Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.devicename -like "*nvidia*" -and $_.devicename -notlike "*audio*"}).DriverVersion | Select-Object -Last 1 | Out-String
$nvCurrentVersion = ($nvGetVersion | Select-String -Pattern '.{7}$').Matches.Value.Replace(".","").Insert(3,'.').Trim()
$nvDestUnzipPath = "$nvTempDir\$nvLatestVersion-Driver"
$nvSrcUnzipPath = "$nvDestUnzipPath\setup.exe"


if ($nvCurrentVersion -lt $nvLatestVersion){
  if (!(Test-Path -Path $nvSrc)) {
    Write-Host "####### Downloading Nvidia Driver... #######" -ForegroundColor Blue
    New-Item -Type Directory -Path $nvTempDir
    (New-Object System.Net.WebClient).DownloadFile($nvRemote,$nvSrc)
  }

  if (!(Test-Path -Path $nvSrcUnzipPath)) {
    Write-Host "####### Extracting Nvidia Driver... #######" -ForegroundColor Blue
    Start-Process 7z.exe -ArgumentList "x $nvSrc `"-o$($nvDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
  }

  Write-Host "####### Installing Nvidia Driver... #######" -ForegroundColor Blue
  $nvInstallArgs = "-passive -noreboot -noeula -clean -s"
  Start-Process -FilePath $nvSrcUnzipPath -ArgumentList $nvInstallArgs -Wait

  if (Test-Path -Path $nvTempDir) {
    Remove-Item -Path $nvTempDir -Recurse -ErrorAction SilentlyContinue -Force
  }
}
