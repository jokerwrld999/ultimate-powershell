# Checking latest driver version. Thanks to "https://github.com/lord-carlos/nvidia-update"
$uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php' +
'?func=DriverManualLookup' +
'&psid=120' + # Geforce RTX 30 Series
'&pfid=929' +  # RTX 3080
'&osID=57' + # Windows 10 64bit
'&languageCode=1033' + # en-US; seems to be "Windows Locale ID"[1] in decimal
'&isWHQL=1' + # WHQL certified
'&dch=1' + # DCH drivers (the new standard)
'&sort1=0' + # sort: most recent first(?)
'&numberOfResults=1' # single, most recent result is enough
$response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
$payload = $response.Content | ConvertFrom-Json
$nvLatestVersion =  $payload.IDS[0].downloadInfo.Version
$nvTempDir = "C:\NvidiaTemp"
$nvSrc = "$nvTempDir\driver.exe"
$nvRemote = "https://uk.download.nvidia.com/Windows/$nvLatestVersion/$nvLatestVersion-desktop-win10-win11-64bit-international-dch-whql.exe"
$nvDestUnzipPath = "$nvTempDir\$nvLatestVersion-Driver"
$nvSrcUnzipPath = "$nvDestUnzipPath\setup.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$nvTempDir\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"

if ([bool]((Get-WmiObject win32_VideoController).PNPDeviceID | Select-String "VEN_10DE")) {
  $nvGetVersion = (Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.devicename -like "*nvidia*" -and $_.devicename -notlike "*audio*"}).DriverVersion | Select-Object -Last 1 | Out-String
  $nvCurrentVersion = ($($nvGetVersion) | Select-String -Pattern '.{7}$').Matches.Value.Replace(".","").Insert(3,'.').Trim()

  if ($nvCurrentVersion -lt $nvLatestVersion){
    if (!(Test-Path -Path $nvSrc)) {
      Write-Host "####### Downloading Nvidia Driver... #######" -ForegroundColor Blue
      New-Item -Type Directory -Path $nvTempDir | Out-Null
      (New-Object System.Net.WebClient).DownloadFile($nvRemote,$nvSrc)
    }

    if (!(Test-Path -Path $nvSrcUnzipPath)) {
      if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
          Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
          (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
          Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
      }

      Write-Host "####### Extracting Nvidia Driver... #######" -ForegroundColor Blue
      Start-Process $7zipExe -ArgumentList "x $nvSrc `"-o$($nvDestUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
    }

    Write-Host "####### Installing Nvidia Driver... #######" -ForegroundColor Blue
    $nvInstallArgs = "-passive -noreboot -noeula -clean -s"
    Start-Process -FilePath $nvSrcUnzipPath -ArgumentList $nvInstallArgs -Wait

    if (Test-Path -Path $nvTempDir) {
      Remove-Item -Path $nvTempDir -Recurse -ErrorAction SilentlyContinue -Force
    }
    Write-Host "####### Nvidia Driver installed successfully. #######" -ForegroundColor Green
  }
  Write-Host "####### Nvidia Driver is already up to date. #######" -ForegroundColor Green
} else {
    Write-Host "####### There was no any Nvidia Card found. #######" -ForegroundColor DarkMagenta
}
