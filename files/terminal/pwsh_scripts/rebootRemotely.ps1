$hostname = ([system.net.dns]::gethostentry('192.168.200.111')).HostName
$pingTimeout = 10

try {
    $initialBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $hostname).LastBootUpTime

    # Initiate remote reboot
    Invoke-Command -ComputerName $hostname -ScriptBlock {
        cmd /c "shutdown /r /t 0 /f"
    }

    # Wait for reboot with pings
    $success = $false
    for ($i = 0; $i -lt $pingTimeout; $i++) {
        Start-Sleep -Seconds 5
        if (Test-Connection -ComputerName $hostname -Quiet) {
            $success = $true
            break
        }
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
} catch {
    Write-Error "Error during remote reboot: $_"
}
