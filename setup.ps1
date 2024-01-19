#Requires -RunAsAdministrator

# Set PowerShell execution policy to RemoteSigned for the current user
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Host("Execution policy is already set to RemoteSigned for the current user, skipping...") -f Green
}
else {
    Write-Host("Setting execution policy to RemoteSigned for the current user...") -f Green
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned *>$null
}

Start-Process 

# >>> Running Tweaks
Write-Host "####### Running Tweaks....... #######" -f Blue
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks.ps1" | iex

# >>> Installing Scoop Packages
Write-Host "####### Installing Scoop Packages....... #######" -f Blue
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/scoop_packages.ps1" | iex

# >>> Setting Up Oh-My-Posh
Write-Host "####### Setting Up Oh-My-Posh....... #######" -f Blue
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/oh_my_posh.ps1" | iex

# >>> Setting Up AutoHotkey
Write-Host "####### Setting Up AutoHotkey....... #######" -f Blue
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/autohotkey.ps1" | iex

# >>> Setting Up ShareX
Write-Host "####### Setting Up ShareX....... #######" -f Blue
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/sharex.ps1" | iex

# >>> Setting Up WSL2
# irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1" | iex
