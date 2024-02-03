#Requires -RunAsAdministrator

[CmdletBinding()]
param(
  [Parameter()]
  [switch]$Boot
)

function Get-Confirmation ($message) {
  $choice = Read-Host "$message (y/N)"
  if ($choice -eq "y") {
    return $true
  } else {
    return $false
  }
}

$scheduledTaskName = "WSL"
function CheckAndInstallFeatures () {
  Write-Host "########## Checking WLS 2 features... ############" -ForegroundColor Blue
  wsl --status | Out-Null
  if ($LASTEXITCODE -ne 0) {
      Write-Host "Enabling WLS 2 features..." -ForegroundColor Blue
      Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart | Out-Null
      Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null
      wsl --install --no-distribution | Out-Null

      $getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName
      if ($getScheduledTaskName -eq $scheduledTaskName) {
        Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False | Out-Null
        ScheduleTaskForNextBoot
      } else {
        ScheduleTaskForNextBoot
      }
      if (Get-Confirmation "Would you like to perform a immediate reboot?") {
        Restart-Computer -Force
      } else {
          Write-Host "Installation paused. Please reboot manually to complete setup." -ForegroundColor Magenta
      }
  } else {
    Write-Host "Features are already enabled." -ForegroundColor Green
    SetupWSLDistro -Distro $Distro -CustomUser $CustomUser -UserPass $UserPass -VaultPass $VaultPass
  }
}

function ScheduleTaskForNextBoot () {
  Write-Host "Scheduling task for next boot..." -ForegroundColor Blue

  $ActionScript = '& {Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData(''https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1'')))) -ArgumentList $true}'

  $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoExit -Command `"$ActionScript`""

  $Trigger = New-ScheduledTaskTrigger -AtLogon

  $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

  Register-ScheduledTask -TaskName $scheduledTaskName -Action $Action -Trigger $Trigger -Principal $Principal -Description "Continue Setting Up WSL After Boot"
}

function SetupCustomUser {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Distro,
    [Parameter(Mandatory = $true)]
    [string]$CustomUser,
    [Parameter(Mandatory = $false)]
    [string]$UserPass = $CustomUser,
    [Parameter(Mandatory = $true)]
    [string]$SudoGroup
  )

  $UserHomeDirectoryExists = Test-Path "\\wsl$\$Distro\home\$CustomUser"
  if (!$UserHomeDirectoryExists) {
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
  } else {
    Write-Host "####### Custom User $CustomUser has been already configured... #######" -ForegroundColor Green
  }

}

function InstallArchDistro {
  $wsl_dir = "$env:userprofile\AppData\Local\Packages\"

  if (!(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
    Write-Host "####### Downloading Arch Distro... #######" -f Blue
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip","$wsl_dir\Arch.zip")

    Write-Host "####### Extracting Arch Distro... #######" -f Green
    Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

    if (!(Test-Path -Path "$wsl_dir\Arch.zip")) {
      Write-Host "####### Removing Temp Files... #######" -f Green
      Remove-Item -Recurse -Force $wsl_dir\Arch.zip
    }
  }

  $jobName = "InstallArch"
  while ($true) {
    wsl -d Arch -u root /bin/bash -c "pacman -V >/dev/null 2>&1"
    if ($LASTEXITCODE -eq 0) {
      Write-Host "####### Arch Installed Successfully. #######" -f Green
      if (Get-Job -Name $jobName -ErrorAction SilentlyContinue) {
        Stop-Job -Name $jobName
        Remove-Job -Name $jobName
      }

      wsl -d Arch -u root /bin/bash -c "ansible --version >/dev/null 2>&1"
      if ($LASTEXITCODE -ne 0) {
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
      } else {
        Write-Host "####### Arch First Setup has been already completed. #######" -f Green
      }
      break
    } else {
      if (!(Get-Job -Name $jobName -EA SilentlyContinue)) {
        Write-Host "####### Initializing Arch... #######" -f Blue
        Start-Job -Name $jobName -ScriptBlock { Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe }
      }
      Start-Sleep -s 20
    }
  }
}

function InstallUbuntuDistro {
  $jobName = "InstallUbuntu"
  while ($true) {
    wsl -d Ubuntu -u root /bin/bash -c "apt -v >/dev/null 2>&1"
    if ($LASTEXITCODE -eq 0) {
      Write-Host "####### Ubuntu installed successfully. #######" -f Green
      if (Get-Job -Name $jobName -ErrorAction SilentlyContinue) {
        Stop-Job -Name $jobName
        Remove-Job -Name $jobName
      }

      wsl -d Ubuntu -u root /bin/bash -c "ansible --version >/dev/null 2>&1"
      if ($LASTEXITCODE -ne 0) {
        Write-Host "####### Running Ubuntu First Setup... #######" -f Blue
        wsl -d Ubuntu -u root /bin/bash -c "apt update && apt upgrade -y; apt install ansible git -y >/dev/null 2>&1"

        Write-Host "####### Ubuntu First Setup is finished successfully. #######" -f Green
      } else {
        Write-Host "####### Ubuntu First Setup has been already completed. #######" -f Green
      }
      break
    } else {
      if (!(Get-Job -Name $jobName -EA SilentlyContinue)) {
        Write-Host "####### Initializing Ubuntu... #######" -f Blue
        Start-Job -Name $jobName -ScriptBlock { wsl --install -d Ubuntu }
      }
      Start-Sleep -s 20
    }
  }
}

function RunAnsiblePlaybook {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Distro,
    [Parameter(Mandatory = $true)]
    [string]$CustomUser,
    [Parameter(Mandatory = $true)]
    [string]$VaultPass
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
  param(
    [Parameter(Mandatory = $true)]
    [string]$Distro = "Arch",
    [Parameter(Mandatory = $false)]
    [string]$CustomUser = "jokerwrld",
    [Parameter(Mandatory = $false)]
    [string]$UserPass = $CustomUser,
    [Parameter(Mandatory = $true)]
    [string]$VaultPass = (Read-Host "Vault pass: " -AsSecureString)
  )

  Write-Host "####### Installing $Distro... #######" -f Blue
  #    WSLKernelUpdate
  wsl --update
  wsl --set-default-version 2 | Out-Null
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

function Get-UserInput {
  do {
      Write-Host "Choose a distro:"
      Write-Host "1. Arch"
      Write-Host "2. Ubuntu"
      $distroChoice = Read-Host "Enter choice (1 or 2):"
  } until ($distroChoice -eq "1" -or $distroChoice -eq "2")

  $Distro = switch ($distroChoice) {
      "1" { "Arch" }
      "2" { "Ubuntu" }
  }

  $CustomUser = Read-Host "Custom user (default: jokerwrld):"
  if (!$CustomUser) { $CustomUser = "jokerwrld" }

  $UserPass = Read-Host "User password (default: $CustomUser):"
  if (!$UserPass) { $UserPass = $CustomUser }

  $VaultPass = (Read-Host "Vault pass: " -AsSecureString)
  $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($VaultPass)
  $VaultPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

  return @{
      Distro = $Distro
      CustomUser = $CustomUser
      UserPass = $UserPass
      VaultPass = $VaultPass
  }
}

$wslVarsFile = "$env:userprofile\.wsl_vars.json"
function Get-WSLVars {
  if (Test-Path -Path $wslVarsFile) {
      return Get-Content -Path $wslVarsFile -Raw | ConvertFrom-Json
  } else {
      return Save-UserInput
  }
}

function Set-WSLVars {

    $setWSLVars = Get-UserInput
    $setWSLVars | ConvertTo-Json | Out-File -FilePath $wslVarsFile

    return $setWSLVars
}

$getWSLVars = if (!$Boot) { Set-WSLVars } else { Get-WSLVars }

$Distro = $getWSLVars.Distro
$CustomUser = $getWSLVars.CustomUser
$UserPass = $getWSLVars.UserPass
$VaultPass = $getWSLVars.VaultPass

if (!$Boot) {
  CheckAndInstallFeatures
} else {
  Write-Host "After Boot"
  SetupWSLDistro -Distro $Distro -CustomUser $CustomUser -UserPass $UserPass -VaultPass $VaultPass

  if ($(Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName -eq $scheduledTaskName) {
    Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False | Out-Null
  }
}
