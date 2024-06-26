function Get-Confirmation ($message) {
    while ($true) {
        $choice = $(Write-Host "$message (Y/N): " -ForegroundColor DarkCyan -NoNewLine; Read-Host)
        $choice = $choice.ToLower()

        if ($choice -eq "y") {
            return $true
        } elseif ($choice -eq "n") {
            return $false
        } else {
            Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor DarkMagenta
        }
    }
}

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
$pingTimeout = 5
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$confirmationMessage = "Are you sure you want to reboot this machine?"
if (Get-Confirmation $confirmationMessage) {
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
    }

    Write-Host "Retrieving initial boot time..." -ForegroundColor Blue
    try {
        $initialBootTime = Invoke-Command -ComputerName $hostname -Credential $credentials -ScriptBlock {
            (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        }
        Write-Host "Initial Boot Time: $initialBootTime" -ForegroundColor Green
    } catch {
        Write-Host "Failed to retrieve initial boot time: $_" -ForegroundColor DarkMagenta
        exit
    }

    Write-Host "Initiating reboot..." -ForegroundColor Blue
    try {
        Invoke-Command -ComputerName $hostname -Credential $credentials -ScriptBlock {
            cmd /c "shutdown /r /t 0 /f"
        }
    } catch {
        Write-Host "Failed to initiate reboot: $_" -ForegroundColor DarkMagenta
        exit
    }

    $success = $false
    for ($i = 0; $i -lt $pingTimeout; $i++) {
        if (Test-Connection -ComputerName $hostname -Count 8 -Delay 4 -Quiet) {
            $success = $true
            Start-Sleep -Seconds 5
            break
        }
        Start-Sleep -Seconds 1
    }

    if ($success) {
        Write-Host "Retrieving final boot time..." -ForegroundColor Blue
        try {
            $finalBootTime = Invoke-Command -ComputerName $hostname -Credential $credentials -ScriptBlock {
                (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
            }
            Write-Host "Final Boot Time: $finalBootTime" -ForegroundColor Green
        } catch {
            Write-Host "Failed to retrieve final boot time. Testing network connectivity..." -ForegroundColor Blue
            $connectionRetryCount = 0
            $maxConnectionRetries = 5
            while ($connectionRetryCount -lt $maxConnectionRetries) {
                if (Test-Connection -ComputerName $hostname -Count 1 -Quiet) {
                    Write-Host "Network connection established. Assuming reboot completed." -ForegroundColor Cyan
                    break
                } else {
                    Write-Host "Machine still unreachable. Waiting 10 seconds before retry..." -ForegroundColor Blue
                    Start-Sleep -Seconds 10
                }
                $connectionRetryCount++
            }

            if ($connectionRetryCount -ge $maxConnectionRetries) {
                Write-Host "Failed to establish connection after multiple retries." -ForegroundColor DarkMagenta
                exit
            }
        }

        if ($finalBootTime -gt $initialBootTime) {
            Write-Host "Machine rebooted successfully." -ForegroundColor Green
        } else {
            Write-Host "Machine did not reboot successfully." -ForegroundColor DarkMagenta
        }
    } else {
        Write-Host "Failed to establish connection after reboot." -ForegroundColor DarkMagenta
    }
} else {
    Write-Host "Reboot has been canceled." -ForegroundColor Magenta
}
