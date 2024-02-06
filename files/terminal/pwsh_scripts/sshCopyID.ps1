function Get-Hostname {
  while ($true) {
      $hostAddress = $(Write-Host "Enter IP address or hostname of the machine to reboot (or press Enter to exit): " -ForegroundColor DarkCyan -NoNewLine; Read-Host)
      if ([string]::IsNullOrEmpty($hostAddress)) {
          exit
      }

      try {
          $combinedPattern = '^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][a-zA-Z0-9\-]*[A-Za-z0-9])$|^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
          if ($hostAddress -match $combinedPattern) {
              if (Test-Connection -ComputerName $hostAddress -Count 1 -Quiet) {
                  Write-Host "$hostAddress is reachable." -ForegroundColor Green
                  return $hostAddress
              } else {
                  Write-Host "$hostAddress is not reachable." -ForegroundColor Red
              }
          } else {
              Write-Host "Invalid IP address or hostname." -ForegroundColor DarkMagenta
          }
      } catch {
          Write-Host "Something went wrong: $_" -ForegroundColor DarkMagenta
      }
  }
}

$hostname = Get-Hostname
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

function Copy-SshPublicKey ($hostname) {
  $maxRetries = 3
  $currentRetry = 0

  while ($currentRetry -lt $maxRetries) {
    $password = $(Write-Host "$currentUser, please enter your password: " -ForegroundColor DarkCyan -NoNewLine; Read-Host -AsSecureString)
    $credentials = New-Object System.Management.Automation.PSCredential ($currentUser, $password)

      try {
        Invoke-Command -ComputerName $hostname -Credential $credentials -ScriptBlock { Get-Date } -ErrorAction Stop | Out-Null
          break
        } catch {
          $currentRetry++
          Write-Host "Incorrect password. Please try again. ($($maxRetries - $currentRetry) attempts remaining)" -ForegroundColor DarkMagenta
        }
      }

      if ($currentRetry -ge $maxRetries) {
        Write-Host "Maximum password attempts exceeded. Exiting." -ForegroundColor DarkMagenta
        exit
      } else {
        $localPublicKeyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"

        if (Test-Path $localPublicKeyPath) {
            $authorizedKey = Get-Content -Path $localPublicKeyPath
        } else {
            Write-Host "Public key file not found at $localPublicKeyPath. Please check the path." -ForegroundColor DarkMagenta
            return
        }

        Invoke-Command -ComputerName $hostname -Credential $credentials -ScriptBlock {
            $remotePublicKeyPath = "$env:ProgramData\ssh\administrators_authorized_keys"
            New-Item -ItemType File -Path $remotePublicKeyPath -Force
            Add-Content -Path $remotePublicKeyPath -Value $args[0]
            icacls.exe $remotePublicKeyPath /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
        } -ArgumentList $authorizedKey | Out-Null

        Write-Host "Public key copied to $hostname successfully." -ForegroundColor Green
    }
}

Copy-SshPublicKey $hostname
