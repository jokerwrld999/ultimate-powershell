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
#         wsl --set-default-version 2 | Out-null
#         wsl --shutdown

#         Write-Host "WSL kernel updated and set to version 2."
#     } else {
#         Write-Host "WSL kernel is already up-to-date and set to version 2."
#     }
# }

# WSLKernelUpdate

# Check if OneDrive is installed
$onedriveInstalled = Get-Command -ErrorAction SilentlyContinue -CommandType Application -Name OneDrive

if ($onedriveInstalled) {
    Write-Output "OneDrive is installed."
} else {
    Write-Output "OneDrive is not installed."
}
$oneDriveInstalled = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name OneDrive -ErrorAction SilentlyContinue)
if ($oneDriveInstalled) {
    Write-Host "OneDrive is installed." -f Blue
} else {
    Write-Host "OneDrive is not installed." -f Green
}
