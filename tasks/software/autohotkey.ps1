$autoHotkeyScriptsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Documents\AutoHotkey")
$scriptFileName = "ultimate_keys.ahk"
$autoHotkeyScriptPath = [System.IO.Path]::Combine($autoHotkeyScriptsFolder, $scriptFileName)
$startupShortcutPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup\$scriptFileName.lnk")

if (!(Test-Path -Path $autoHotkeyScriptsFolder -PathType Container)) {
    Write-Host "Creating $autoHotkeyScriptsFolder folder..." -f Blue
    New-Item -Path $autoHotkeyScriptsFolder -ItemType Directory -Force
}

Write-Host "Downloading AutoHotkey script..." -f Blue
Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/ultimate_keys.ahk" -OutFile $autoHotkeyScriptPath

Write-Host "Creating Shortcut at the Startup folder..." -f Blue
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($startupShortcutPath)
$Shortcut.TargetPath = $autoHotkeyScriptPath
$Shortcut.Save()

Write-Host "The AutoHotkey script @ [$autoHotkeyScriptPath] has been created, and a shortcut was created in the Startup folder." -f Green

Write-Host "Patching AutoHotkey..." -f Blue
$pattern = '^\s*(C:\\.*\\autohotkey\\\d.*$)'
$autoHotkeyInstallPath = (powershell -c "scoop info autohotkey") -match $pattern
$autoHotkeySourcePath = [System.IO.Path]::Combine($autoHotkeyInstallPath.Trim(), "UX\inc\identify.ahk")
Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/identify_fix.ahk" -OutFile $autoHotkeySourcePath
Write-Host "AutoHotkey was successfully patched @ [$autoHotkeySourcePath]." -f Green

if (!(Get-ItemProperty -Path "HKCU\Software\Classes\.ahk" -Name (Default) -ErrorAction SilentlyContinue).Value -match "AutoHotkey.ahk") {
    Write-Host "Setting .ahk association to Registry..." -f Blue
    Set-ItemProperty -Path "HKCU\Software\Classes\.ahk" -Name (Default) -Value "AutoHotkey.ahk"
    New-ItemProperty -Path "HKCU\Software\Classes\.ahk\shell\open\command" -Name (Default) -Value "$env:userprofile\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"

    New-ItemProperty -Path "HKCU\Software\Classes\.ahk\shell\open\command" -Name (Default) -Value "runas /user:administrator $env:userprofile\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"

    Write-Host ".ahk association is successfully set" -f Green
} else {
  Write-Host ".ahk association already set in Registry." -f Green
}

Write-Host "Starting AutoHotkey script..." -f Blue
Start-Process -FilePath "$env:USERPROFILE\scoop\shims\autohotkey.exe" -ArgumentList "$autoHotkeyScriptPath" -NoNewWindow *>$null
