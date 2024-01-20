#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Boot
)

function CheckAndInstallFeatures() {
    Write-Host "########## Checking WLS 2 features ############" -ForegroundColor Blue
    if ((Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" | Where-Object { $_.State -eq "Disabled" }).Count -gt 0) {
        try {
            Write-Host "Enabling WLS 2 features..." -ForegroundColor Blue
            $restartRequired = (Install-WindowsFeature -Name "VirtualMachinePlatform" -IncludeAllSubFeature -Feature<OoB>e $true -Restart).RestartNeeded

            Write-Host "Restart is required: $restartRequired" -ForegroundColor Blue
            if ($restartRequired) {
                if (Get-Confirmation "Would you like to perform a immediate reboot? (Y/N)") {
                    Write-Host "Rescheduling task for next boot..." -ForegroundColor Blue
                    ScheduleTaskForNextBoot
                    # Restart-Computer -force
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
        SetupWSLDistro
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
        [string] $Password,
        [Parameter(Mandatory = $true)]
        [string] $SudoGroup = "wheel"
    )

    Write-Host "####### Setting Up CustomUser $CustomUser....... #######" -f Blue
    # wsl -d $Distro -u root /bin/bash -c "echo '%$SudoGroup ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$SudoGroup; echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$CustomUser' > /etc/wsl.conf; useradd -m -p $Password -G $SudoGroup -s /bin/bash $CustomUser &> /dev/null; usermod -a -G $SudoGroup $CustomUser &> /dev/null" *>$null
    # wsl --shutdown $Distro *>$null
}

function SetupWSLDistro {
    param (
        [Parameter(Mandatory = $false)]
        [string] $Distro = "Arch",
        [Parameter(Mandatory = $false)]
        [string] $CustomUser = "jokerwrld",
        [Parameter(Mandatory = $false)]
        [string] $Password = $CustomUser,
        [Parameter(Mandatory = $true)]
        [string] $VaultPass = {Read-Host "Vault pass: "}
    )

    Write-Host "Continuing WSL setup..." -ForegroundColor Blue

    wsl --set-default-version 2 | Out-null

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

    Write-Host "####### Installing Arch Distro....... #######" -f Blue
    # if (!(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
    #     Write-Host "####### Downloading Arch Distro....... #######" -f Blue
    #     (new-Object System.Net.WebClient).DownloadFile("https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip", "$wsl_dir\Arch.zip")

    #     Write-Host "####### Extractiing Arch Distro....... #######" -f Green
    #     Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

    #     if (!(Test-Path -Path "$wsl_dir\Arch.zip") ){
    #         Write-Host "####### Removing Temp Files....... #######" -f Green
    #         Remove-Item -Recurse -Force $wsl_dir\Arch.zip
    #     }
    # }

    # while($true) {
    #     wsl -d Arch -u root /bin/bash -c "cd; ls -la"
    #     if($? -eq "true") {
    #         Write-Host "####### Configuring Arch Distro....... #######" -f Blue
    #         wsl -d Arch -u root /bin/bash -c "rm -rf /var/lib/pacman/db.lck; pacman -Syu --noconfirm &> /dev/null; pacman -S archlinux-keyring --needed --noconfirm &> /dev/null; pacman -S ansible git --noconfirm &> /dev/null; sudo localectl set-locale LANG=en_US.UTF-8 &> /dev/null"

    #         Write-Host "####### Setting Up Default User....... #######" -f Blue
    #         setupUser 'wheel'
    #         break
    #     }
    #     else {
    #         Write-Host "####### Registring Arch Distro....... #######" -f Blue
    #         Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
    #         Start-Sleep -s 20
    #     }
    # }
}

function InstallUbuntuDistro {
    Write-Host "####### Installing Ubuntu Distro....... #######" -f Blue
    # wsl --install -d Ubuntu *>$null

    # Write-Host "####### Updating Distro....... #######" -f Blue
    # wsl -d Ubuntu -u root /bin/bash -c "apt update && apt upgrade -y; apt install ansible git -y &> /dev/null"
}

function RunAnsiblePlaybook {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Distro,
        [Parameter(Mandatory = $true)]
        [string] $CustomUser,
        [Parameter(Mandatory = $true)]
        [string] $VaultPass
    )

    Write-Host "####### Runing Ansible Playbook on $Distro....... #######" -f Blue
    # wsl -d $Distro -u $CustomUser /bin/bash -c "mkdir ~/github &> /dev/null; cd ~/github; git clone https://github.com/jokerwrld999/ansible-linux.git &> /dev/null; echo $VaultPass > ~/github/ansible-linux/.vault_pass"

    # wsl -d $Distro -u $CustomUser /bin/bash -c "cd ~/github/ansible-linux; ansible-galaxy collection install -r requirements.yml &> /dev/null; ansible-playbook local.yml"
}

if (!$Boot) {
    CheckAndInstallFeatures
}
else {
    SetupWSLDistro
}

