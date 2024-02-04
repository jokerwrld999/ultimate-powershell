
# >>> Running Tweaks
Write-Host "####### Running Tweaks....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks.ps1" | Invoke-Expression

# >>> Setting Up OpenSSH
Write-Host "####### Setting Up OpenSSH....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/openssh.ps1" | Invoke-Expression

# >>> Installing Scoop Packages
Write-Host "####### Installing Scoop Packages....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/scoop_packages.ps1" | Invoke-Expression

# >>> Setting Up Oh-My-Posh
Write-Host "####### Setting Up Oh-My-Posh....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/oh_my_posh.ps1" | Invoke-Expression

# >>> Setting Up AutoHotkey
Write-Host "####### Setting Up AutoHotkey....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/autohotkey.ps1" | Invoke-Expression

# >>> Setting Up ShareX
Write-Host "####### Setting Up ShareX....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/sharex.ps1" | Invoke-Expression

# >>> Setting Up WSL2
Write-Host "####### Setting Up WSL....... #######" -f Cyan
Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1" | Invoke-Expression
