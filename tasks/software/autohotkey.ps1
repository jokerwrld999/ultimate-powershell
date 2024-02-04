#Requires -RunAsAdministrator

$ahkScriptsFolder = "$env:USERPROFILE\Documents\AutoHotkey"
$ahkScriptName = "ultimate_keys.ahk"
$ahkSourceScript = "$ahkScriptsFolder\$ahkScriptName"
$ahkStartupShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$ahkScriptName.lnk"
$runAsAdminReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$ahkInstallationPath = "$env:userprofile\scoop\apps\autohotkey\current"
$ahkExe = "$ahkInstallationPath\v2\AutoHotkey64.exe"
$ahkFixSourceScript = "$ahkInstallationPath\UX\inc\identify.ahk"
$runAsAdminValue = "~ RUNASADMIN"
$ahkHashFile = "$ahkSourceScript.sha256"
$ahkFixHashFile = "$ahkFixSourceScript.sha256"
$ahkRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/ultimate_keys.ahk"
$ahkFixRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/identify_fix.ahk"
$getSFTAApp =  PowerShell -Command  "& { . $PSHome\Scripts\SFTA.ps1; Get-FTA .ahk }"

function Stream-FileHash {
  param(
    $Uri
  )
  $wc = [System.Net.WebClient]::new()
  $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
  $FileHash.Hash
}

if (!(Test-Path -Path $ahkScriptsFolder -PathType Container)) {
  Write-Host "Creating $ahkScriptsFolder folder..." -f Blue
  New-Item -Path $ahkScriptsFolder -ItemType Directory -Force | Out-Null
}

if (!(Test-Path -Path $ahkFixHashFile -PathType Leaf) -or
  (Stream-FileHash -Uri $ahkFixRemoteScript) -ne (Get-Content $ahkFixHashFile -EA SilentlyContinue)) {

  Write-Host "Patching AutoHotkey..." -f Blue
  Invoke-WebRequest -Uri $ahkFixRemoteScript -OutFile $ahkFixSourceScript | Out-Null
  (Get-FileHash $ahkFixSourceScript).Hash | Out-File $ahkFixHashFile

  Write-Host "AutoHotkey was successfully patched @ [$ahkFixSourceScript]." -f Green
} else {
  Write-Host "AutoHotkey has been already patched." -f Green
}

if ($getSFTAAPP -ne "SFTA.AutoHotkey64.ahk") {
  Write-Host "Setting SFTA..." -f Blue
  PowerShell -Command  "& { . $PSHome\Scripts\SFTA.ps1; Register-FTA $ahkExe .ahk }"
}

if (!(Get-ItemPropertyValue -Path $runAsAdminReg -Name $ahkExe -ErrorAction SilentlyContinue)) {
  New-Item -Path $runAsAdminReg -Force | Out-Null
  New-ItemProperty -Path $runAsAdminReg -Name $ahkExe -Value $runAsAdminValue -Force | Out-Null
}

if (!(Test-Path -Path $ahkSourceScript -PathType Leaf) -or
  (Stream-FileHash -Uri $ahkRemoteScript) -ne (Get-Content $ahkHashFile -EA SilentlyContinue) -or
  !(Test-Path -Path $ahkStartupShortcut -PathType Leaf)) {
  Write-Host "Downloading or updating AutoHotkey script..." -f Blue

  Invoke-WebRequest -Uri $ahkRemoteScript -OutFile $ahkSourceScript | Out-Null
  (Get-FileHash $ahkSourceScript).Hash | Out-File $ahkHashFile

  if (!(Test-Path -Path $ahkStartupShortcut -PathType Leaf)) {
    Write-Host "Creating a shortcut at the Startup folder..." -f Blue
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ahkStartupShortcut)
    $Shortcut.TargetPath = $ahkSourceScript
    $Shortcut.Save() | Out-Null

    Write-Host "Startup Shortcut is created successfully." -f Green
  } else {
    Write-Host "Startup Shortcut has been already created." -f Green
  }

  Write-Host "Starting AutoHotkey script..." -f Blue
  Start-Process -FilePath "$ahkStartupShortcut" | Out-Null
} else {
  Write-Host "AutoHotkey script is already up-to-date." -f Green
}
