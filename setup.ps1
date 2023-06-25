#Requires -RunAsAdministrator

Set-ExecutionPolicy ByPass -Scope Process -Force

# >>> Installing Scoop
if (!(Test-Path -Path ($env:userprofile + "\scoop"))) {
    Write-Host "Installing Scoop Module"
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    $env:Path += ";$env:userprofile\scoop\shims\scoop.cmd"
    Write-Host "Check Scoop Module...."
    echo $env:userprofile
    scoop update
} 
else {
    Write-Host "Updating Scoop Module"
    scoop update
}


# >>> Installing choco
iwr -useb chocolatey.org/install.ps1 | iex

# >>> Install Terminal Moudules
Install-Module -Name PowerShellGet -Force
Install-Module PSReadLine -AllowPrerelease -Force
Install-Module -Name Terminal-Icons -Repository PSGallery

# >>> If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# >>> If the file already exists, show the message and do nothing.
else {
    Remove-Item -Path $PROFILE
    Invoke-RestMethod https://github.com/jokerwrld999/ultimate-powershell/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
}
& $profile

# >>> Install Oh-My-Posh
scoop update
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
# >>> Install Speedtest
choco install speedtest

# >>> Get the NerdFonts
scoop bucket add nerd-fonts
scoop install Meslo-NF Meslo-NF-Mono Hack-NF Hack-NF-Mono FiraCode-NF FiraCode-NF-Mono FiraMono-NF FiraMono-NF-Mono

# >>> Setting Up WSL2
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/wsl/SetupWSL.ps1" | iex