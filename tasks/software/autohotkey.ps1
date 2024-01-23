# Paths and variables
$ahkScriptsFolder = "$env:USERPROFILE\Documents\AutoHotkey"
$ahkScriptName = "ultimate_keys.ahk"
$ahkSourceScript = "$ahkScriptsFolder\$ahkScriptName"
$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$ahkScriptName.lnk"
$runAsAdminReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$ahkInstallationPath = "$env:userprofile\scoop\apps\autohotkey\current"
$ahkExe = "$ahkInstallationPath\v2\AutoHotkey64.exe"
$ahkFixSource = "$ahkInstallationPath\UX\inc\identify.ahk"
$runAsAdminValue = "~ RUNASADMIN"
$sftaScript = "$env:userprofile\Documents\PowerShell\Scripts\SFTA.ps1"
$hashFile = "$ahkScriptsFolder\ultimate_keys.ahk.sha256"

# Check for existing folders and registry values
if (!(Test-Path -Path $ahkScriptsFolder -PathType Container)) {
    Write-Host "Creating $ahkScriptsFolder folder..." -f Blue
    New-Item -Path $ahkScriptsFolder -ItemType Directory -Force | Out-Null
}

# Download or update AHK script based on content check
if (!(Test-Path -Path $ahkSourceScript -PathType Leaf) -or
    (Get-FileHash $ahkSourceScript).Hash -ne (Get-Content $hashFile)) {
    Write-Host "Downloading or updating AutoHotkey script..." -f Blue
    Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/ultimate_keys.ahk" -OutFile $ahkSourceScript | Out-Null
    Get-FileHash $ahkSourceScript | Out-File $hashFile
} else {
    Write-Host "AutoHotkey script is already up-to-date." -f Green
}

# Create startup shortcut only if it doesn't exist
if (!(Test-Path -Path $startupFolder -PathType Leaf)) {
    Write-Host "Creating a shortcut at the Startup folder..." -f Blue
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($startupFolder)
    $Shortcut.TargetPath = $ahkSourceScript
    $Shortcut.Save() | Out-Null

    Write-Host "Startup Shortcut is created successfully." -f Green
} else {
    Write-Host "Startup Shortcut has been already created." -f Green
}

# Patch AutoHotkey (consider conditional logic if applicable)
Write-Host "Patching AutoHotkey..." -f Blue
Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/identify_fix.ahk" -OutFile $ahkFixSource | Out-Null
Write-Host "AutoHotkey was successfully patched @ [$ahkFixSource]." -f Green

# Set .ahk association and Run as admin property if not already set
if (!(Get-ItemPropertyValue -Path $runAsAdminReg -Name $ahkExe -ErrorAction SilentlyContinue)) {
    if (!(Test-Path -Path $sftaScript -PathType Leaf)) {
        Write-Host "Downloading PowerShell SFTA..." -f Blue
        Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/pwsh_scripts/SFTA.ps1" -OutFile $sftaScript | Out-Null
    }

    Write-Host "Setting .ahk association and Run as an administrator property..." -f Blue
    powershell.exe -c "& { . $sftaScript; Set-FTA $ahkExe '.ahk' }" | Out-Null
    New-ItemProperty -Path $runAsAdminReg -Name $ahkExe -Value $runAsAdminValue -PropertyType string -Force | Out-Null

    Write-Host ".ahk association and Run as admin property set." -f Green
} else {
    Write-Host ".ahk association and Run as admin property already set." -f Green
}
Write-Host "Starting AutoHotkey script..." -f Blue
Start-Process -FilePath "$ahkExe" -ArgumentList "$ahkSourceScript" -NoNewWindow *>$null
