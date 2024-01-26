function ScheduleTaskForNextBoot() {
    Write-Host "Scheduling task for next boot..." -ForegroundColor Blue

    $ActionScript = '& {Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData(''https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1'')))) -ArgumentList $true}'

    $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoExit -Command `"$ActionScript`""

    $Trigger = New-ScheduledTaskTrigger -AtLogon

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

    Register-ScheduledTask -TaskName "WSL" -Action $Action -Trigger $Trigger -Principal $Principal -Description "Continue Setting Up WSL After Boot" -Force
}


function Get-Confirmation ($message) {
    $choice = Read-Host "$message (y/N)"
    if ($choice -eq "y") {
        return $true
    } else {
        return $false
    }
}
$restartRequired = $true # $pendingRenameOperations -ne $null

Write-Host "Restart is required: $restartRequired" -ForegroundColor Blue
if ($restartRequired) {
    if (Get-Confirmation "Would you like to perform a immediate reboot?") {
        Write-Host "Rescheduling task for next boot..." -ForegroundColor Blue
        ScheduleTaskForNextBoot
        Restart-Computer -force
    } else {
        Write-Host "Installation paused. Please reboot manually to complete setup." -ForegroundColor Magenta
    }
} else {
    Write-Host "Features enabled successfully." -ForegroundColor Green
}


