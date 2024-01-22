
# >>> Running Tweaks
Write-Host "####### Running Tweaks....... #######" -f Cyan
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks.ps1" | iex

# >>> Installing Scoop Packages
Write-Host "####### Installing Scoop Packages....... #######" -f Cyan
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/scoop_packages.ps1" | iex

# >>> Setting Up Oh-My-Posh
Write-Host "####### Setting Up Oh-My-Posh....... #######" -f Cyan
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/oh_my_posh.ps1" | iex

# >>> Setting Up AutoHotkey
Write-Host "####### Setting Up AutoHotkey....... #######" -f Cyan
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/autohotkey.ps1" | iex

# >>> Setting Up ShareX
Write-Host "####### Setting Up ShareX....... #######" -f Cyan
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/sharex.ps1" | iex

# >>> Setting Up WSL2
# irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1" | iex
