#Requires -RunAsAdministrator

$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -ne "RemoteSigned") {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

if (!(Get-Service -Name sshd -ErrorAction SilentlyContinue)) {
  Write-Host "Installing OpenSSH..." -ForegroundColor Blue
  $openSSHpackages = Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name
  foreach ($package in $openSSHpackages) {
    Add-WindowsCapability -Online -Name $package | Out-Null
  }
  Get-Service -Name sshd | Set-Service -StartupType Automatic
  Start-Service sshd
}

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

if (!(Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -ErrorAction SilentlyContinue)) {
  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -ErrorAction SilentlyContinue -Force | Out-Null
}

if ((Get-Service -Name ssh-agent -ErrorAction SilentlyContinue).Status -eq 'Stopped') {
    Get-Service ssh-agent | Set-Service -StartupType Automatic
    Start-Service ssh-agent
}

$sshPath = "$env:USERPROFILE\.ssh"
$keyPath = "$sshPath\id_ed25519"
if (!(Test-Path $keyPath)) {
  if (!(Test-Path -Path $sshPath)) {
    New-Item -Path $sshPath -ItemType Directory | Out-Null
  }

  ssh-keygen -q -t ed25519 -f $keyPath -N '""'

  ssh-add -l | Out-Null
  if ($LASTEXITCODE -ne 0) {
      ssh-add -q $keyPath
  } else {
    ssh-add -D
    ssh-add -q $keyPath
  }
}
