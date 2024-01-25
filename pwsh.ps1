[CmdletBinding()]
param (
    [Parameter()]
    [switch] $Boot
)

if ($Boot){
    Write-Host "Wooow, Boot is working"
}

# function Get-Confirmation ($message) {
#     $choice = Read-Host "$message (y/N)"
#     if ($choice -eq "y") {
#         return $true
#     } else {
#         return $false
#     }
# }

# Write-Host "Restart is required: $restartRequired" -ForegroundColor Blue
# $restartRequired = $true
# if ($restartRequired) {
#     if (Get-Confirmation "Would you like to perform an immediate reboot?") {
#         Write-Host "Rescheduling task for next boot..." -ForegroundColor Blue
#         # Restart-Computer -force
#     } else {
#         Write-Host "Installation paused. Please reboot manually to complete setup." -ForegroundColor Magenta
#     }
# } else {
#     Write-Host "Features enabled successfully." -ForegroundColor Green
# }




# $scriptPath = ((new-object net.webclient).DownloadString('https://gist.githubusercontent.com/AndrewSav/c4fb71ae1b379901ad90/raw/23f2d8d5fb8c9c50342ac431cc0360ce44465308/SO33205298'))
# Invoke-Command -ScriptBlock ([scriptblock]::Create($scriptPath)) -ArgumentList "coucou"

# function Invoke-Wsl {
#     ((Invoke-Expression "wsl $($args -join ' ')")) -replace [char]0
# }

# function WSLKernelUpdate {
#     $pattern = '(\d+\.\d+\.\d+\.\d+)'
#     $wslInfo = Invoke-Wsl -v
#     $releases = Invoke-WebRequest -Uri https://api.github.com/repos/microsoft/WSL2-Linux-Kernel/releases | ConvertFrom-Json
#     $latestKernelRelease = $releases[0].tag_name
#     $latestKernelVersion = [regex]::Match($latestKernelRelease, $pattern).Groups[1].Value
#     $currentKernelVersion = [regex]::Match($wslInfo, "Kernel version: $pattern").Groups[1].Value
#     # $defaultWSLVersion = wsl --status | Select-Object -ExpandProperty DefaultDistribution

#     Write-Host "Latest Kernel: $latestKernelVersion" 
#     Write-Host "Current Kernel: $currentKernelVersion" 

#     if ($currentKernelVersion -ne $latestKernelVersion) {
#         $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
#         $outFile = ".\wsl_update_x64.msi"

#         Invoke-WebRequest -Uri $url -OutFile $outFile

#         Start-Process msiexec.exe -Wait -ArgumentList '/I $outFile /quiet'
#         wsl --update
#         wsl --set-default-version 2 | Out-Null
#         wsl --shutdown

#         Write-Host "WSL kernel updated and set to version 2."
#     } else {
#         Write-Host "WSL kernel is already up-to-date and set to version 2."
#     }
# }

# WSLKernelUpdate

# Check if OneDrive is installed
# $onedriveInstalled = Get-Command -ErrorAction SilentlyContinue -CommandType Application -Name OneDrive

# if ($onedriveInstalled) {
#     Write-Output "OneDrive is installed."
# } else {
#     Write-Output "OneDrive is not installed."
# }
# $oneDriveInstalled = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name OneDrive -ErrorAction SilentlyContinue)
# if ($oneDriveInstalled) {
#     Write-Host "OneDrive is installed." -f Blue
# } else {
#     Write-Host "OneDrive is not installed." -f Green
# }

# Function Create-Association($ext, $exe) {
#     $name = cmd /c "assoc $ext 2>NUL"
#     if ($name) { # Association already exists: override it
#         $name = $name.Split('=')[1]
#     } else { # Name doesn't exist: create it
#         $name = "$($ext.Replace('.',''))file" # ".log.1" becomes "log1file"
#         cmd /c "assoc $ext=$name"
#     }
#     cmd /c "ftype $name=`"$exe`" `"%1`""
# }

# Create-Association(".ahk", "notepad.exe")

#   .\SetUserFTA .ahk `"$env:userprofile\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe`"
#   Write-Host "Set .ahk association to $env:userprofile\scoop\apps\autohotkey\current\v2\AutoHotkey64"
# powershell -command "& { . .\files\terminal\pwsh_scripts\SFTA.ps1; Set-FTA 'C:\Users\jokerwrld\scoop\apps\vscode\current\Code.exe' '.ahk' }"

# $ahkRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/autohotkey/ultimate_keys.ahk"

# function Stream-FileHash {
#     param (
#         $Uri
#     )

#     $wc = [System.Net.WebClient]::new()
#     $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
#     $FileHash.Hash
# }

# $(Stream-FileHash -Uri $ahkRemoteScript) -eq (Get-Content "$env:USERPROFILE\Documents\AutoHotkey\ultimate_keys.ahk.sha256")


# $packageInfo = winget list --id Microsoft.Powershell --source winget
# $versionMatch = $packageInfo | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)' -AllMatches
# if ($versionMatch){
#     $currentVersion = $versionMatch.Matches[0].Groups[1].Value
#     $availableVersion = $versionMatch.Matches.Count -gt 1
#     if ($availableVersion) {
#         Write-Host "An update is available for Google Chrome:"
#         Write-Host "  Current version: $currentVersion"
#         Write-Host "  Available version: $availableVersion"
#                 Write-Host " Uninstalling... And Installing"
#     }
#     else {
#     Write-host "Up to date"
#     }
# }
# else {
#   Write-Host "Installing...."
# }
# Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1')))) -ArgumentList "-Boot"