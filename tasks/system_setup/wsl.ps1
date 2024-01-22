#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Boot
)

function CheckAndInstallFeatures() {
    Write-Host "########## Checking WLS 2 features... ############" -ForegroundColor Blue
    if ((Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform").State -eq "Disabled") {
        try {
            Write-Host "Enabling WLS 2 features..." -ForegroundColor Blue
            Start-Process -Wait -NoNewWindow dism.exe -ArgumentList "/online", "/enable-feature", "/featurename:Microsoft-Windows-Subsystem-Linux", "/all", "/norestart"
            Start-Process -Wait -NoNewWindow dism.exe -ArgumentList "/online", "/enable-feature", "/featurename:VirtualMachinePlatform", "/all", "/norestart"

            $pendingRenameOperations = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA SilentlyContinue
            $restartRequired = $pendingRenameOperations -ne $null

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
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $PSCommandPath -Boot"
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

    $UserHomeDirectoryExists = Test-Path "\\wsl$\$Distro\home\$CustomUser"
    if (!$UserHomeDirectoryExists){
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
        Write-Host "####### Custom User $CustomUser has been already configured... #######" -ForegroundColor Green
    }

}


function InstallArchDistro {
    $wsl_dir = "$env:userprofile\AppData\Local\Packages\"

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
            Write-Host "####### Arch Installed Successfully#######" -f Green

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
            Write-Host "####### Installing Arch... #######" -f Blue
            Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
            Start-Sleep -s 20
        }
    }
}

function InstallUbuntuDistro {
    $jobName = "InstallUbuntu"  # Replace with the actual job name
    while($true) {
        wsl -d Ubuntu -u root /bin/bash -c "apt -v >/dev/null 2>&1"
        if($LASTEXITCODE -eq 0 ) {
            Write-Host "####### Ubuntu installed successfully#######" -f Green
            if (Get-Job -Name $jobName -ErrorAction SilentlyContinue) {
                Stop-Job -Name $jobName
                Remove-Job -Name $jobName
            }

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
            Start-Job -Name $jobName -ScriptBlock {wsl --install -d Ubuntu}
            Start-Sleep -s 20
        }
    }
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

    Write-Host "####### Running Ansible Playbook on $Distro... #######" -f Blue

    wsl -d $Distro -u $CustomUser bash -c @"
        mkdir -p ~/github
        cd ~/github
        if [ ! -d ansible-linux ]; then
            git clone https://github.com/jokerwrld999/ansible-linux.git >/dev/null 2>&1
        fi
        echo "$VaultPass" > ansible-linux/.vault_pass
        cd ansible-linux
        ansible-galaxy collection install -r requirements.yml >/dev/null 2>&1
        ansible-playbook local.yml
"@
    Write-Host "####### Finished Ansible Playbook on $Distro... #######" -f Green
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
        [string] $VaultPass = {Read-Host "Vault pass: " -AsSecureString}
    )

#    WSLKernelUpdate
    wsl --update
    wsl --set-default-version 2 | Out-null
    wsl --shutdown

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

$SetupWSLDistro = SetupWSLDistro -Distro Ubuntu #-CustomUser 'username' -UserPass 'password' -VaultPass '<your_vault_pass>'
if (!$Boot) {
    CheckAndInstallFeatures
}
else {
    $SetupWSLDistro
}

