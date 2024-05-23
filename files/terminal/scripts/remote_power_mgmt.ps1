param (
    [switch]$Confirm,
    [switch]$Shutdown,
    [switch]$Check,
    [string]$Path
)

function Get-Confirmation ($message) {
    if ($Confirm) {
        return $true
    }

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

function Get-ValidHostname ($hostname) {
    $validPattern = '^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][a-zA-Z0-9\-]*[A-Za-z0-9])$|^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

    if ($hostname -match $validPattern){
        return $hostname
    } else {
        Write-Host "Invalid IP address or hostname: $hostname." -ForegroundColor DarkMagenta
        continue
    }
}

function Get-Hostname {
    while ($true) {
        $getHostname = $(Write-Host "Enter IP address or hostname of the machine (or press Enter to exit): " -ForegroundColor DarkCyan -NoNewLine; Read-Host)
        if ([string]::IsNullOrEmpty($getHostname)) {
            exit
        }

        $hostname = Get-ValidHostname($getHostname)

        if (Test-Connection -ComputerName $hostname -Count 1 -Quiet) {
            Write-Host "$hostname is reachable." -ForegroundColor Green
            return $hostname
        } else {
            Write-Host "$hostname is not reachable." -ForegroundColor Red
        }
    }
}

function Get-HostStatus ($hostname, [switch]$Silent) {
    $isOnline = Test-Connection -ComputerName $hostname -Count 1 -Quiet
    if (-not $Silent) {
        if ($isOnline) {
            Write-Host "$hostname is ONLINE" -ForegroundColor Green
        } else {
            Write-Host "$hostname is OFFLINE" -ForegroundColor Red
        }
    }
    return $isOnline
}

function Get-HostnamesFromFile ($filePath) {
    if (-not (Test-Path $filePath)) {
        Write-Host "File path '$filePath' does not exist." -ForegroundColor DarkMagenta
        exit
    }
    return Get-Content -Path $filePath
}

function Out-LogResult ($hostname, $result) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = "~/RemotePowerMGMT"
    $logFile = "$logPath/reboot_log.txt"
    $entry = "$timestamp - $hostname - $result"

    if (!(Test-Path -Path $logPath)){
        New-Item -ItemType Directory -Path $logPath
    }

    Add-Content -Path $logFile -Value $entry
}

$hostnames = @()
$offlineHostnames = @()
if ($Path) {
    $hostnames = Get-HostnamesFromFile $Path
} else {
    $hostname = Get-Hostname
    $hostnames += $hostname
}

$pingTimeout = 5
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Find the first online host
$firstOnlineHost = $null
Write-Host "Checking available hosts for credential validation..." -ForegroundColor Blue
foreach ($hostname in $hostnames) {
    $hostname = Get-ValidHostname($hostname)
    if (Get-HostStatus $hostname -Silent) {
        $firstOnlineHost = $hostname
        break
    } else {
        $offlineHostnames += $hostname
        Out-LogResult $hostname "SKIPPED_OFFLINE"
    }
}

if (-not $firstOnlineHost) {
    Write-Host "No online hosts available for credential validation. Exiting." -ForegroundColor DarkMagenta
    exit
}

# Validate global credentials against the first online host
$maxRetries = 3
$currentRetry = 0
while ($currentRetry -lt $maxRetries) {
    $password = $(Write-Host "$currentUser, please enter your password: " -ForegroundColor DarkCyan -NoNewLine; Read-Host -AsSecureString)
    $globalCredentials = New-Object System.Management.Automation.PSCredential ($currentUser, $password)

    try {
        Invoke-Command -ComputerName $firstOnlineHost -Credential $globalCredentials -ScriptBlock { Get-Date } -ErrorAction Stop | Out-Null
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

if ($Check) {
    Write-Host "Checking if machines are available and retrieving initial boot times..." -ForegroundColor Cyan
    foreach ($hostname in $hostnames) {
        $hostname = Get-ValidHostname($hostname)
        if (-not (Get-HostStatus $hostname)) {
            Write-Host "Skipping offline machine: $hostname" -ForegroundColor Yellow
            $offlineHostnames += $hostname
            Out-LogResult $hostname "SKIPPED_OFFLINE"
            continue
        }

        Write-Host "Retrieving initial boot time for $hostname..." -ForegroundColor Blue
        try {
            $initialBootTime = Invoke-Command -ComputerName $hostname -Credential $globalCredentials -ScriptBlock {
                (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
            }
            Write-Host "Initial Boot Time for ${hostname}: $initialBootTime" -ForegroundColor Green
            Out-LogResult $hostname "INITIAL_BOOT_TIME: $initialBootTime"
        } catch {
            Write-Host "Failed to retrieve initial boot time for ${hostname}: $_" -ForegroundColor DarkMagenta
            Out-LogResult $hostname "FAIL"
        }
    }
    exit
}

$confirmationMessage = "Are you sure you want to reboot these machines?"
if ($Shutdown) {
    $confirmationMessage = "Are you sure you want to shutdown these machines?"
}

if (-not (Get-Confirmation $confirmationMessage)) {
    Write-Host "Action has been canceled." -ForegroundColor Magenta
    exit
}

$initialBootTimes = @{}

# Execute action on all machines
foreach ($hostname in $hostnames) {
    $hostname = Get-ValidHostname($hostname)
    if (-not (Get-HostStatus $hostname)) {
        Write-Host "Skipping offline machine: $hostname" -ForegroundColor Yellow
        $offlineHostnames += $hostname
        Out-LogResult $hostname "SKIPPED_OFFLINE"
        continue
    }

    if (-not $Shutdown) {
        Write-Host "Retrieving initial boot time for $hostname..." -ForegroundColor Blue
        try {
            $initialBootTime = Invoke-Command -ComputerName $hostname -Credential $globalCredentials -ScriptBlock {
                (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
            }
            $initialBootTimes[$hostname] = $initialBootTime
            Write-Host "Initial Boot Time for ${hostname}: $initialBootTime" -ForegroundColor Green
        } catch {
            Write-Host "Failed to retrieve initial boot time for ${hostname}: $_" -ForegroundColor DarkMagenta
            Out-LogResult $hostname "FAIL"
            continue
        }
    }

    Write-Host "Initiating action on $hostname..." -ForegroundColor Blue
    try {
        if ($Shutdown) {
            Invoke-Command -ComputerName $hostname -Credential $globalCredentials -ScriptBlock {
                cmd /c "shutdown /s /t 0 /f"
            }
        } else {
            Invoke-Command -ComputerName $hostname -Credential $globalCredentials -ScriptBlock {
                cmd /c "shutdown /r /t 0 /f"
            }
        }
        Out-LogResult $hostname "ACTION_INITIATED"
    } catch {
        Write-Host "Failed to initiate action on ${hostname}: $_" -ForegroundColor DarkMagenta
        Out-LogResult $hostname "FAIL"
    }
}

# Ensure action is completed on all machines
foreach ($hostname in $hostnames) {
    $hostname = Get-ValidHostname($hostname)
    if ($offlineHostnames -contains $hostname) {
        continue
    }

    $initialBootTime = $null
    if ($initialBootTimes.ContainsKey($hostname)) {
        $initialBootTime = $initialBootTimes[$hostname]
    }

    if ($Shutdown) {
        $success = $false
                        Start-Sleep -Seconds 5
        for ($i = 0; $i -lt $pingTimeout; $i++) {
            if (-not (Test-Connection -ComputerName $hostname -Count 1 -Quiet)) {
                $success = $true
                Start-Sleep -Seconds 5
                break
            }
            Start-Sleep -Seconds 1
        }

        if ($success) {
            Write-Host "Machine $hostname shutdown successfully." -ForegroundColor Green
            Out-LogResult $hostname "SUCCESS"
        } else {
            Write-Host "Failed to confirm machine $hostname shutdown." -ForegroundColor DarkMagenta
            Out-LogResult $hostname "FAIL"
        }
    } else {
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
            Write-Host "Retrieving final boot time for $hostname..." -ForegroundColor Blue
            try {
                $finalBootTime = Invoke-Command -ComputerName $hostname -Credential $globalCredentials -ScriptBlock {
                    (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
                }
                Write-Host "Final Boot Time for ${hostname}: $finalBootTime" -ForegroundColor Green

                if ($finalBootTime -gt $initialBootTime) {
                    Write-Host "Machine $hostname rebooted successfully." -ForegroundColor Green
                    Out-LogResult $hostname "SUCCESS"
                } else {
                    Write-Host "Machine $hostname did not reboot successfully." -ForegroundColor DarkMagenta
                    Out-LogResult $hostname "FAIL"
                }
            } catch {
                Write-Host "Failed to retrieve final boot time for ${hostname}: $_" -ForegroundColor DarkMagenta
                Out-LogResult $hostname "FAIL"
            }
        } else {
            Write-Host "Failed to establish connection after reboot for $hostname." -ForegroundColor DarkMagenta
            Out-LogResult $hostname "FAIL"
        }
    }
}