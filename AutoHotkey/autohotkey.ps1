$destinationFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Documents\AutoHotkey")
$fileName = "ultimate_keys.ahk"
$sourceFile = [System.IO.Path]::Combine($destinationFolder, $fileName)
$shortcutDestination = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup\$fileName.lnk")

# >>> If the file does not exist, create it.
if (!(Test-Path -Path $destinationFolder -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force
        }

        Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/AutoHotkey/ultimate_keys_v2.ahk -OutFile $sourceFile

        # Create a shortcut to the script in the Startup folder
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutDestination)
        $Shortcut.TargetPath = $sourceFile
        $Shortcut.Save()

        Write-Host "The AutoHotkey script @ [$sourceFile] has been created and shortcut created in the Startup folder."
    }
    catch {
        throw $_.Exception.Message
    }
}

