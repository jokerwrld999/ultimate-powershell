function Get-Confirmation ($message) {
    $choice = Read-Host "$message (y/N)"
    if ($choice -eq "y") {
      return $true
    } else {
      return $false
    }
}

function Get-Hostname {
    $ipAddress = Read-Host "Enter a valid IPv4 address OR Press {Enter} to exit:"
    while ($true) {
        try {
            $ipv4Pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

            if ($ipAddress -match $ipv4Pattern) {
                Write-Host "Checking hostname..." -ForegroundColor Blue
                $hostname = ([system.net.dns]::GetHostEntry($ipAddress)).HostName
                Write-Host "Hostname $hostname exists with IP address $ipAddress." -ForegroundColor Green
                return $hostname
            } elseif ($ipAddress -eq '') {
                Write-Host "Exiting..." -ForegroundColor Blue
                exit
            } else {
                Write-Host "IPv4 Address is invalid." -ForegroundColor DarkMagenta
            }
        } catch {
            Write-Host "Failed to resolve hostname $Hostname" -ForegroundColor DarkMagenta
        }
        $ipAddress = Read-Host "Enter a valid IPv4 address OR Press {Enter} to exit:"
    }
}

$hostname = Get-Hostname
$pingTimeout = 5

if (Get-Confirmation "Are you sure you want to reboot $hostname's machine?") {
    $initialBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $hostname).LastBootUpTime
    Write-Host "Reboot is in progress..." -ForegroundColor Blue
    Invoke-Command -ComputerName $hostname -ScriptBlock {
        cmd /c "shutdown /r /t 0 /f"
    }

    $success = $false
    for ($i = 0; $i -lt $pingTimeout; $i++) {
        if (Test-Connection -ComputerName $hostname -Count 5 -Delay 4 -Quiet) {
            $success = $true
            Start-Sleep -Seconds 5
            break
        }
        Start-Sleep -Seconds 1
    }

    if ($success) {
        $finalBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $hostname).LastBootUpTime
        if ($finalBootTime -gt $initialBootTime) {
            Write-Host "Machine rebooted successfully." -ForegroundColor Green
        } else {
            Write-Warning "Machine did not reboot successfully."
        }
    } else {
        Write-Error "Failed to establish connection after reboot."
    }
} else {
    Write-Host "Reboot is paused." -ForegroundColor Magenta
}
