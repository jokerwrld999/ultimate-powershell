# Paths and variables
$ahkScriptsFolder = "$env:USERPROFILE\Documents\AutoHotkey"
$ahkScriptName = "ultimate_keys.ahk"
$ahkSourceScript = "$ahkScriptsFolder\$ahkScriptName"
$ahkStartupShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$ahkScriptName.lnk"
$runAsAdminReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$ahkInstallationPath = "$env:userprofile\scoop\apps\autohotkey\current"
$ahkExe = "$ahkInstallationPath\v2\AutoHotkey64.exe"
$ahkFixSourceScript = "$ahkInstallationPath\UX\inc\identify.ahk"
$runAsAdminValue = "~ RUNASADMIN"
$sftaScript = "$env:userprofile\Documents\PowerShell\Scripts\SFTA.ps1"
$ahkHashFile = "$ahkSourceScript.sha256"
$ahkFixHashFile = "$ahkFixSourceScript.sha256"
$ahkRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/ultimate_keys.ahk"
$ahkFixRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/identify_fix.ahk"

function Stream-FileHash {
    param (
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

if (!(Test-Path -Path $ahkSourceScript -PathType Leaf) -or
    (Stream-FileHash -Uri $ahkRemoteScript) -ne (Get-Content $ahkHashFile -EA SilentlyContinue)) {

    Write-Host "Downloading or updating AutoHotkey script..." -f Blue
    Invoke-WebRequest -Uri $ahkRemoteScript -OutFile $ahkSourceScript | Out-Null
    (Get-FileHash $ahkSourceScript).Hash | Out-File $ahkHashFile

    # Create startup shortcut only if it doesn't exist
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
    Start-Process -FilePath "$ahkExe" -ArgumentList "$ahkSourceScript" -NoNewWindow *>$null
} else {
    Write-Host "AutoHotkey script is already up-to-date." -f Green
}
