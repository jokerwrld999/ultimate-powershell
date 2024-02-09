#Requires -RunAsAdministrator

[CmdletBinding()]
param(
  [Parameter()]
  [switch]$Boot
)

function Get-Confirmation ($message) {
    while ($true) {
        $choice = $(Write-Host "$message (Y/N)" -ForegroundColor DarkCyan -NoNewLine; Read-Host)
        $choice = $choice.ToLower()

        if ($choice -eq "y" -or $choice -eq "yes") {
            return $true
        } elseif ($choice -eq "n" -or $choice -eq "no") {
            return $false
        } else {
            Write-Host "Invalid input. Please enter 'y' or 'n'." -ForegroundColor DarkMagenta
        }
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
      if (Get-Confirmation "Would you like to perform an immediate reboot?") {
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
            if ! grep -q '%$SudoGroup ALL=(ALL) NOPASSWD: ALL' /etc/sudoers.d/$SudoGroup >/dev/null 2>&1; then
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
    Write-Host "####### Custom User $CustomUser set up is finished successfully. #######" -ForegroundColor Green
  } else {
    Write-Host "####### Custom User $CustomUser has been already configured... #######" -ForegroundColor Green
  }

}

function InstallArchDistro {
  $wsl_dir = "$env:userprofile\AppData\Local\Packages\"

  if (!(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
    Write-Host "####### Downloading Arch Distro... #######" -ForegroundColor Blue
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip","$wsl_dir\Arch.zip")

    Write-Host "####### Extracting Arch Distro... #######" -ForegroundColor Green
    Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

    if (Test-Path -Path "$wsl_dir\Arch.zip") {
      Write-Host "####### Removing Temp Files... #######" -ForegroundColor Green
      Remove-Item -Recurse -Force $wsl_dir\Arch.zip
    }
  }

  $jobName = "InstallArch"
  while ($true) {
    wsl -d Arch -u root /bin/bash -c "pacman -V >/dev/null 2>&1" | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "####### Arch Installed Successfully. #######" -ForegroundColor Green
      wsl -d Arch -u root /bin/bash -c "ls -la" | Out-Null
      Get-Service LxssManager | Restart-Service
      Start-Sleep 5
      # if (Get-Job -Name $jobName -ErrorAction SilentlyContinue) {
      #   Stop-Job -Name $jobName | Out-Null
      #   Remove-Job -Name $jobName | Out-Null
      # }

      wsl -d Arch -u root /bin/bash -c "ansible --version >/dev/null 2>&1" | Out-Null
      if ($LASTEXITCODE -ne 0) {
        Write-Host "####### Running Arch First Setup... #######" -ForegroundColor Blue
        wsl -d Arch -u root /bin/bash -c @"
                    rm -rf /var/lib/pacman/db.lck
                    pacman -Syyu --noconfirm >/dev/null 2>&1
                    pacman -S archlinux-keyring --needed --noconfirm >/dev/null 2>&1
                    localectl set-locale LANG=en_US.UTF-8
                    pacman -Suy --noconfirm >/dev/null 2>&1
                    pacman -S ansible git --noconfirm >/dev/null 2>&1
"@
        Write-Host "####### Arch First Setup is finished successfully. #######" -ForegroundColor Green
      } else {
        Write-Host "####### Arch First Setup has been already completed. #######" -ForegroundColor Green
      }
      break
    } else {
      if (!(Get-Job -Name $jobName -EA SilentlyContinue)) {
        Write-Host "####### Initializing Arch... #######" -ForegroundColor Blue
        Start-Job -Name $jobName -ScriptBlock {
          Start-Process -WindowStyle hidden "$env:userprofile\AppData\Local\Packages\Arch\Arch.exe"
        } | Receive-Job -AutoRemoveJob -Wait | Out-Null
      }
      Start-Sleep -s 10
    }
  }
}

function InstallUbuntuDistro {
  $jobName = "InstallUbuntu"
  while ($true) {
    wsl -d Ubuntu -u root /bin/bash -c "apt -v >/dev/null 2>&1" | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "####### Ubuntu installed successfully. #######" -ForegroundColor Green
      # if (Get-Job -Name $jobName -ErrorAction SilentlyContinue) {
      #   Stop-Job -Name $jobName | Out-Null
      #   Remove-Job -Name $jobName | Out-Null
      # }

      wsl -d Ubuntu -u root /bin/bash -c "ansible --version >/dev/null 2>&1" | Out-Null
      if ($LASTEXITCODE -ne 0) {
        Write-Host "####### Running Ubuntu First Setup... #######" -ForegroundColor Blue
        wsl -d Ubuntu -u root /bin/bash -c "apt update && apt upgrade -y; apt install ansible git -y >/dev/null 2>&1" | Out-Null

        Write-Host "####### Ubuntu First Setup is finished successfully. #######" -ForegroundColor Green
      } else {
        Write-Host "####### Ubuntu First Setup has been already completed. #######" -ForegroundColor Green
      }
      break
    } else {
      if (!(Get-Job -Name $jobName -EA SilentlyContinue)) {
        Write-Host "####### Initializing Ubuntu... #######" -ForegroundColor Blue
        Start-Job -Name $jobName -ScriptBlock { wsl --install -d Ubuntu } | Receive-Job -AutoRemoveJob -Wait | Out-Null
      }
      Start-Sleep -s 10
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
  Write-Host "####### Running Ansible Playbook on $Distro... #######" -ForegroundColor Blue

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
  Write-Host "####### Finished Ansible Playbook on $Distro... #######" -ForegroundColor Green
}

function SetupWSLDistro {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Distro,
    [Parameter(Mandatory = $false)]
    [string]$CustomUser = "jokerwrld",
    [Parameter(Mandatory = $false)]
    [string]$UserPass = $CustomUser,
    [Parameter(Mandatory = $true)]
    [string]$VaultPass
  )

  Write-Host "####### Installing $Distro... #######" -ForegroundColor Blue
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
      $distroChoice = $(Write-Host "Enter choice (1 or 2), or type 'exit' to quit: " -ForegroundColor DarkCyan -NoNewLine; Read-Host)

      if ([string]::IsNullOrWhiteSpace($distroChoice) -or $distroChoice.ToLower() -eq 'exit') {
         return $Global:break = $true
      }
  } until ($distroChoice -eq "1" -or $distroChoice -eq "2")

  $Distro = switch ($distroChoice) {
      "1" { "Arch" }
      "2" { "Ubuntu" }
  }

  $CustomUser = $(Write-Host "Custom user (default: jokerwrld): " -ForegroundColor DarkCyan -NoNewLine; Read-Host)
  if (!$CustomUser) { $CustomUser = "jokerwrld" }

  $UserPass = $(Write-Host "User password (default: $CustomUser): " -ForegroundColor DarkCyan -NoNewLine; Read-Host)
  if (!$UserPass) { $UserPass = $CustomUser }

  $VaultPass = $(Write-Host "Vault pass: " -ForegroundColor DarkCyan -NoNewLine; Read-Host -AsSecureString)
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

$hyperVInfo = Get-ComputerInfo -Property "HyperV*"

if ($hyperVInfo.HyperVRequirementVirtualizationFirmwareEnabled -eq $false) {
  Write-Host "Virtualization is disabled in BIOS. Please enable it to use WSL." -ForegroundColor DarkMagenta
  $break = $true
} else {
  $getWSLVars = if (!$Boot) { Set-WSLVars } else { Get-WSLVars }
}

$Distro = $getWSLVars.Distro
$CustomUser = $getWSLVars.CustomUser
$UserPass = $getWSLVars.UserPass
$VaultPass = $getWSLVars.VaultPass

if (!$Boot) {
  if (!$break) {
    CheckAndInstallFeatures
  }
} else {
  $jobName = "Update WSL Kernel"
  if (!(Get-Job -Name $jobName -EA SilentlyContinue)) {
    Write-Host "####### Updating WSL Kernel... #######" -ForegroundColor Blue
    Start-Job -Name $jobName -ScriptBlock {
      wsl --status
      wsl --update
      wsl --set-default-version 2
      wsl --shutdown
    } | Receive-Job -AutoRemoveJob -Wait | Out-Null
  }

  SetupWSLDistro -Distro $Distro -CustomUser $CustomUser -UserPass $UserPass -VaultPass $VaultPass

  if ($(Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName -eq $scheduledTaskName) {
    Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False | Out-Null
  }
}
