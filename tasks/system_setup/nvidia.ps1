function Get-LatestNvidiaDriverVersion {
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
  return $payload.IDS[0].downloadInfo.Version
}

$latestNvidiaVersion = Get-LatestNvidiaDriverVersion
$driverTempPath = "C:\NvidiaTemp"
$nvidiaDriverPath = "$driverTempPath\driver.exe"
$nvidiaRemoteUrl = "https://uk.download.nvidia.com/Windows/$latestNvidiaVersion/$latestNvidiaVersion-desktop-win10-win11-64bit-international-dch-whql.exe"
$destinationUnzipPath = "$driverTempPath\$latestNvidiaVersion-Driver"
$sourceUnzipPath = "$destinationUnzipPath\setup.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$driverTempPath\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"

function Get-CurrentNvidiaDriverVersion {
  $getNvidiaVersion = ((Get-WmiObject Win32_VideoController).DriverVersion | Out-String).Trim()
  if ($getNvidiaVersion.Length -gt 12 ) {
    return ($getNvidiaVersion | Select-String -Pattern '.{7}$').Matches.Value.Replace(".","").Insert(3,'.').Trim()
  } else {
    return ($getNvidiaVersion | Select-String -Pattern '.{6}$').Matches.Value.Replace(".","").Insert(3,'.').Trim()
  }
}

if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
    Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
    (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
    Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
}

if ( [bool](pnputil /enum-devices | Select-string "VEN_10DE") ) {
  $currentNvidiaVersion = Get-CurrentNvidiaDriverVersion

  if ($currentNvidiaVersion -lt $latestNvidiaVersion){
    if (!(Test-Path -Path $driverTempPath)) {
      New-Item -Type Directory -Path $driverTempPath | Out-Null
    }

    if (!(Test-Path -Path $nvidiaDriverPath)) {
      Write-Host "####### Downloading Nvidia Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($nvidiaRemoteUrl,$nvidiaDriverPath)
    }

    if (!(Test-Path -Path $sourceUnzipPath)) {
      Write-Host "####### Extracting Nvidia Driver... #######" -ForegroundColor Blue
      if (Test-Path -Path $7zipExe){
        Start-Process $7zipExe -ArgumentList "x $nvidiaDriverPath `"-o$($destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      } else {
          Start-Process 7z -ArgumentList "x $nvidiaDriverPath `"-o$($destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      }
    }

    Write-Host "####### Installing Nvidia Driver... #######" -ForegroundColor Blue
    $installSwitches = "-passive -noreboot -noeula -clean -s"
    Start-Process -FilePath $sourceUnzipPath -ArgumentList $installSwitches -Wait

    if (Test-Path -Path $driverTempPath) {
      Remove-Item -Path $driverTempPath -Recurse -Force | Out-Null
    }
    Write-Host "####### Nvidia Driver installed successfully. #######" -ForegroundColor Green
  } else {
    Write-Host "####### Nvidia Driver is already up to date. #######" -ForegroundColor Green
  }
} else {
    Write-Host "####### There was no any Nvidia Card found. #######" -ForegroundColor DarkMagenta
}
