# #Workflow definition
# workflow WorkflowDef
# {
#     Restart-Computer
#     Start-Sleep -Seconds 60
# }

# #Job scheduler options
# $AtStartup = New-JobTrigger -AtStartup
# $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
# $block = {[System.Management.Automation.Remoting.PSSessionConfigurationData]::IsServerManager = $true; Import-Module PSWorkflow; Resume-Job -Name WorkflowJob | Wait-Job}

# Register-ScheduledJob -Name ScheduledJob -Trigger $AtStartup -ScriptBlock $block -ScheduledJobOption $options

#  -AsJob -JobName WorkflowJob

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Boot
)

if ($Boot) {
    Write-Output "Running After Start"
    # Do my thing after rebooting
    Set-Content -Path C:\github\ultimate-powershell\Test.txt "Hi, Den. It worked!"
    Start-process Explorer.exe

    # Unregister the task if it exists
    $existingTask = Get-ScheduledTask -TaskName "ContinueAfterBoot" -ErrorAction SilentlyContinue
    if ($existingTask -ne $null) {
        Write-Output "Task 'ContinueAfterBoot' found. Unregistering..."
        Unregister-ScheduledTask -TaskName "ContinueAfterBoot" -Confirm:$false
    } else {
        Write-Output "Task 'ContinueAfterBoot' not found."
    }
}
else {
    # Do my thing before rebooting:
    Set-Content -Path C:\github\ultimate-powershell\Test.txt "It didn't work"
    Restart-Computer
    
    # Setup task for after reboot:
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $PSCommandPath -Boot"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Principal = New-ScheduledTaskPrincipal -LogonType ServiceAccount -UserId "NT AUTHORITY\LOCALSERVICE"
    $Settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries #-RunOnlyIfNetworkAvailable
    Register-ScheduledTask -TaskName "ContinueAfterBoot" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Description "Script After Boot Action"
}
