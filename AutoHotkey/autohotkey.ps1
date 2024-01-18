$destinationFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Documents\AutoHotkey")
$fileName = "ultimate_keys.ahk"
$sourceFile = [System.IO.Path]::Combine($destinationFolder, $fileName)
$shortcutDestination = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup\$fileName.lnk")

if (!(Test-Path -Path $destinationFolder -PathType Container)) {
    Write-Host "Creating $destinationFolder folder..." -f Blue
    New-Item -Path $destinationFolder -ItemType Directory -Force
}

Write-Host "Downloading AutoHotkey script..." -f Blue
Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/AutoHotkey/$fileName.ahk -OutFile $sourceFile

Write-Host "Creating Shortcut at the Startup folder..." -f Blue
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutDestination)
$Shortcut.TargetPath = $sourceFile
$Shortcut.Save()

Write-Host "The AutoHotkey script @ [$sourceFile] has been created and shortcut created in the Startup folder." -f Green

Write-Host "Pathing AutoHotkey..." -f Blue
$sourceFile = [System.IO.Path]::Combine("C:\Program Files", "AutoHotkey\UX\inc\identify.ahk")
Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/AutoHotkey/identify_fix.ahk -OutFile $sourceFile