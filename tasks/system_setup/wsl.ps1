#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Boot
)

function CheckAndInstallFeatures() {
    Write-Host "########## Checking WLS 2 features... ############" -ForegroundColor Blue
    if ((Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" | Where-Object { $_.State -eq "Disabled" }).Count -gt 0) {
        try {
            Write-Host "Enabling WLS 2 features..." -ForegroundColor Blue
            $restartRequired = (Install-WindowsFeature -Name "VirtualMachinePlatform" -IncludeAllSubFeature -Feature<OoB>e $true -Restart).RestartNeeded

            Write-Host "Restart is required: $restartRequired" -ForegroundColor Blue
            if ($restartRequired) {
                if (Get-Confirmation "Would you like to perform a immediate reboot? (Y/N)") {
                    Write-Host "Rescheduling task for next boot..." -ForegroundColor Blue
                    ScheduleTaskForNextBoot
                    Restart-Computer -force
                } else {
                    Write-Host "Installation paused. Please reboot manually to complete setup." -ForegroundColor Magenta
                }
            } else {
                Write-Host "Features enabled successfully." -ForegroundColor Green
            }
        } catch {
            Write-Host "An error occurred while configuring features." -ForegroundColor Red
        }
    } else {
        Write-Host "Features are already enabled." -ForegroundColor Green
        $SetupWSLDistro
    }
}

function ScheduleTaskForNextBoot() {
    Write-Host "Scheduling task for next boot..." -ForegroundColor Blue
    $action = New-ScheduledTaskAction -Execute "powershell.Exe" -Argument "-File $PSCommandPath -Boot"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -RunIdeIfIdle -RunIfAvailable
    $Principal = New-ScheduledTaskPrincipal -UserId "LOCALSERVICE" -LogonType 'Service'

    Register-ScheduledTask -TaskName "Continue After Boot" -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Continue Setting Up WLS After Boot"
}

function SetupCustomUser {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Distro,
        [Parameter(Mandatory = $true)]
        [string] $CustomUser,
        [Parameter(Mandatory = $false)]
        [string] $UserPass = $CustomUser,
        [Parameter(Mandatory = $true)]
        [string] $SudoGroup
    )

    wsl -d $Distro -u root bash -c "ls -la /home/$CustomUser >/dev/null 2>&1"
    if ($LASTEXITCODE -ne 0){
        Write-Host "####### Setting Up Custom User $CustomUser... #######" -ForegroundColor Blue
        wsl -d $Distro -u root /bin/bash -c @"
            if ! grep -q '%$SudoGroup ALL=(ALL) NOPASSWD: ALL' /etc/sudoers.d/$SudoGroup; then
                echo '%$SudoGroup ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$SudoGroup
            fi

            if ! grep -Eq '^systemd=true$' /etc/wsl.conf && ! grep -Eq "^\[user\]\ndefault=$CustomUser" /etc/wsl.conf; then
                echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$CustomUser' > /etc/wsl.conf
            fi

            if ! id -u $CustomUser >/dev/null 2>&1 || ! groups $CustomUser | grep -q "$SudoGroup"; then
                useradd -m -p '$UserPass' -s /bin/bash $CustomUser
                usermod -a -G $SudoGroup $CustomUser
            fi
"@
        wsl --shutdown $Distro
        Write-Host "####### Custom User $CustomUser set up is finished successfully. #######" -f Green
    }
    else {
        Write-Host "####### CustomUser $CustomUser has been already configured... #######" -ForegroundColor Green
    }

}

function WSLKernelUpdate {
    $releases = Invoke-WebRequest -Uri https://api.github.com/repos/microsoft/WSL2-Linux-Kernel/releases | ConvertFrom-Json
    $latestKernelVersion = $releases[0].tag_name
    $currentKernelVersion = (powershell -c "wsl --version") -match '(?i)^Kernel.*(\d+\.\d+\.\d+\.\d+)'
    $defaultWSLVersion = wsl --status | Select-Object -ExpandProperty DefaultDistribution

    if ($currentKernelVersion -ne $latestKernelVersion -or $defaultWSLVersion -ne "2") {
        wsl --update
        wsl --set-default-version 2 | Out-null
        wsl --shutdown

        Write-Host "WSL kernel updated and set to version 2."
    } else {
        Write-Host "WSL kernel is already up-to-date and set to version 2."
    }
}

function SetupWSLDistro {
    param (
        [Parameter(Mandatory = $false)]
        [string] $Distro = "Arch",
        [Parameter(Mandatory = $false)]
        [string] $CustomUser = "jokerwrld",
        [Parameter(Mandatory = $false)]
        [string] $UserPass = $CustomUser,
        [Parameter(Mandatory = $true)]
        [string] $VaultPass = {Read-Host "Vault pass: "}
    )

#    WSLKernelUpdate

    switch ($Distro) {
        "Arch" {
            InstallArchDistro
            SetupCustomUser -Distro $Distro -CustomUser $CustomUser -SudoGroup 'wheel'
        }
        "Ubuntu" {
            InstallUbuntuDistro
            SetupCustomUser -Distro $Distro -CustomUser $CustomUser -SudoGroup 'sudo'
        }
        default {
            Write-Host "No such distro in the list" -ForegroundColor Yellow
            return
        }
    }
    RunAnsiblePlaybook -Distro $Distro -CustomUser $CustomUser -VaultPass $VaultPass
}

function InstallArchDistro {
    $wsl_dir = "$env:userprofile\AppData\Local\Packages\"

    Write-Host "####### Installing Arch Distro... #######" -f Blue
    if (!(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
        Write-Host "####### Downloading Arch Distro... #######" -f Blue
        (new-Object System.Net.WebClient).DownloadFile("https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip", "$wsl_dir\Arch.zip")

        Write-Host "####### Extracting Arch Distro... #######" -f Green
        Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

        if (!(Test-Path -Path "$wsl_dir\Arch.zip") ){
            Write-Host "####### Removing Temp Files... #######" -f Green
            Remove-Item -Recurse -Force $wsl_dir\Arch.zip
        }
    }

    while($true) {
        wsl -d Arch -u root /bin/bash -c "pacman -V >/dev/null 2>&1"
        if($LASTEXITCODE -eq 0) {
            Write-Host "####### Arch Registered Successfully#######" -f Green

            wsl -d Arch -u root /bin/bash -c "ansible --version >/dev/null 2>&1"
            if ($LASTEXITCODE -ne 0){
                Write-Host "####### Running Arch First Setup... #######" -f Blue
                wsl -d Arch -u root /bin/bash -c @"
                    rm -rf /var/lib/pacman/db.lck
                    pacman -Syyu --noconfirm >/dev/null 2>&1
                    pacman -S archlinux-keyring --needed --noconfirm >/dev/null 2>&1
                    localectl set-locale LANG=en_US.UTF-8
                    pacman -Suy --noconfirm >/dev/null 2>&1
                    pacman -S ansible git --noconfirm >/dev/null 2>&1
"@
                Write-Host "####### Arch First Setup is finished successfully. #######" -f Green
            }
            else {
                Write-Host "####### Arch First Setup has been already completed. #######" -f Green
            }
            break
        }
        else {
            Write-Host "####### Registering Arch... #######" -f Blue
            Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
            Start-Sleep -s 20
        }
    }
}

function InstallUbuntuDistro {
    while($true) {
        wsl -d Ubuntu -u root /bin/bash -c "apt -v >/dev/null 2>&1"
        if($LASTEXITCODE -eq 0 ) {
            Write-Host "####### Ubuntu installed successfully#######" -f Green

            wsl -d Ubuntu -u root /bin/bash -c "ansible --version >/dev/null 2>&1"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "####### Running Ubuntu First Setup... #######" -f Blue
                wsl -d Ubuntu -u root /bin/bash -c "apt update && apt upgrade -y; apt install ansible git -y >/dev/null 2>&1"

                Write-Host "####### Ubuntu First Setup is finished successfully. #######" -f Green
            }
            else {
                Write-Host "####### Ubuntu First Setup has been already completed. #######" -f Green
            }
            break
        }
        else {
            Write-Host "####### Installing Ubuntu... #######" -f Blue
            Start-Process powershell.exe -c "wsl --install -d Ubuntu"
            Start-Sleep -s 20
        }
    }
}

function RunAnsiblePlaybook {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Distro,
        [Parameter(Mandatory = $true)]
        [string] $CustomUser,
        [Parameter(Mandatory = $true)]
        [string] $VaultPass
    )

    Write-Host "####### Running Ansible Playbook on $Distro... #######" -f Blue

    wsl -d $Distro -u $CustomUser bash -c @"
        mkdir -p ~/github
        cd ~/github
        if [ ! -d ansible-linux ]; then
            git clone https://github.com/jokerwrld999/ansible-linux.git
        fi
        echo "$VaultPass" > ansible-linux/.vault_pass
        cd ansible-linux
        ansible-galaxy collection install -r requirements.yml >/dev/null 2>&1
        ansible-playbook local.yml
"@
    Write-Host "####### Finished Ansible Playbook on $Distro... #######" -f Green
}

$SetupWSLDistro = SetupWSLDistro -Distro Arch #-CustomUser 'username' -UserPass 'password' -VaultPass '<your_vault_pass>'
if (!$Boot) {
    CheckAndInstallFeatures
}
else {
    $SetupWSLDistro
}

