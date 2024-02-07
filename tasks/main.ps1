
# >>> Running Tweaks
Write-Host "####### Running Tweaks....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks.ps1" | Invoke-Expression

# >>> Setting Up OpenSSH
Write-Host "####### Setting Up OpenSSH....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/openssh.ps1" | Invoke-Expression

# >>> Installing Scoop Packages
Write-Host "####### Installing Scoop Packages....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/scoop_packages.ps1" | Invoke-Expression

# >>> Setting Up Oh-My-Posh
Write-Host "####### Setting Up Oh-My-Posh....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/oh_my_posh.ps1" | Invoke-Expression

# >>> Setting Up AutoHotkey
Write-Host "####### Setting Up AutoHotkey....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/autohotkey.ps1" | Invoke-Expression

# >>> Setting Up ShareX
Write-Host "####### Setting Up ShareX....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/sharex.ps1" | Invoke-Expression

# >>> Setting Up WSL2
Write-Host "####### Setting Up WSL....... #######" -ForegroundColor Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1" | Invoke-Expression
