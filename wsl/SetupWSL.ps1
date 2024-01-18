#Requires -RunAsAdministrator

Write-Host "####### Enabling Hyper-V....... #######" -f Blue
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart *>$null

Write-Host "####### Enabling WSL....... #######" -f Blue
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart *>$null

Write-Host "####### Enabling Virtual Machine Platform....... #######" -f Blue
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart *>$null

Write-Host "####### Setting WSL 2....... #######" -f Blue
wsl --set-default-version 2 *>$null

$distro = $args[0]
$wsl_dir = "$env:userprofile\AppData\Local\Packages\"

if ($custom_user -eq $null) {
    if ($args[1] -ne $null) {
        $custom_user = $args[1]
    } else {
        $custom_user = "jokerwrld"
    }
}
if ($passwd -eq $null) {
    if ($args[2] -ne $null) {
        $passwd = $args[2]
    } else {
        $passwd = $custom_user
    }
}
if ($vault_pass -eq $null) {
    if ($args[3] -ne $null) {
        $vault_pass = $args[3]
    } else {
        $vault_pass = Read-Host "Vault pass: "
    }
}

function setupUser($sudo_group) {
    wsl -d $distro -u root /bin/bash -c "echo '%$sudo_group ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$sudo_group; echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$custom_user' > /etc/wsl.conf; useradd -m -p $passwd -G $sudo_group -s /bin/bash $custom_user &> /dev/null; usermod -a -G $sudo_group $custom_user &> /dev/null" *>$null
    wsl --shutdown $distro *>$null
}

if ($distro -eq "Arch" -or $distro -eq $null) {
    $distro = "Arch"
    Write-Host "####### Installing Arch Distro....... #######" -f Blue
    if (!(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
        Write-Host "####### Downloading Arch Distro....... #######" -f Blue
        (new-Object System.Net.WebClient).DownloadFile("https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip", "$wsl_dir\Arch.zip")

        Write-Host "####### Extractiing Arch Distro....... #######" -f Green
        Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

        if (!(Test-Path -Path "$wsl_dir\Arch.zip") ){
            Write-Host "####### Removing Temp Files....... #######" -f Green
            Remove-Item -Recurse -Force $wsl_dir\Arch.zip
        }
    }

    while($true) {
        wsl -d Arch -u root /bin/bash -c "cd; ls -la"
        if($? -eq "true") {
            Write-Host "####### Configuring Arch Distro....... #######" -f Blue
            wsl -d Arch -u root /bin/bash -c "rm -rf /var/lib/pacman/db.lck; pacman -Syu --noconfirm &> /dev/null; pacman -S archlinux-keyring --needed --noconfirm &> /dev/null; pacman -S ansible git --noconfirm &> /dev/null; sudo localectl set-locale LANG=en_US.UTF-8 &> /dev/null"

            Write-Host "####### Setting Up Default User....... #######" -f Blue
            setupUser 'wheel'
            break
        }
        else {
            Write-Host "####### Starting Arch Distro....... #######" -f Blue
            Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
            Write-Host "####### Registring Arch Distro....... #######" -f Blue
            Start-Sleep -s 20
        }
    }
}
elseif ($distro -eq "Ubuntu") {
    $distro = "Ubuntu"
    Write-Host "####### Installing Ubuntu Distro....... #######" -f Blue
    wsl --install -d $distro *>$null

    Write-Host "####### Updating Distro....... #######" -f Blue
    wsl -d $distro -u root /bin/bash -c "apt update && apt upgrade -y; apt install ansible git -y &> /dev/null"

    Write-Host "####### Setting Up Distro....... #######" -f Blue
    setupUser 'sudo' *>$null
}
else {
    Write-Host "No shuch distro in the list" -f Yellow
}

Write-Host "####### Runing Ansible Playbook on $distro....... #######" -f Blue
wsl -d $distro -u $custom_user /bin/bash -c "mkdir ~/github &> /dev/null; cd ~/github; git clone https://github.com/jokerwrld999/ansible-linux.git &> /dev/null; echo $vault_pass > ~/github/ansible-linux/.vault_pass"

wsl -d $distro -u $custom_user /bin/bash -c "cd ~/github/ansible-linux; ansible-galaxy collection install -r requirements.yml &> /dev/null; ansible-playbook local.yml"
