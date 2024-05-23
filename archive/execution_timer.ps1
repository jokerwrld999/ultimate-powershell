$startTime = Get-Date

Invoke-RestMethod "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/ninite.ps1" | Invoke-Expression
Invoke-RestMethod "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/nvidia.ps1" | Invoke-Expression
Invoke-RestMethod "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/snapins/hp_z640_drivers.ps1" | Invoke-Expression

$endTime = Get-Date
$executionTime = $endTime - $startTime

$totalSeconds = [math]::Round($executionTime.TotalSeconds, 3)

# Calculating minutes, seconds, and milliseconds
$minutes = [math]::Floor($totalSeconds / 60)
$seconds = [math]::Floor($totalSeconds % 60)
$milliseconds = [math]::Round(($totalSeconds - [math]::Floor($totalSeconds)) * 1000)

# Formatting output with string formatting
Write-Host ("Script execution time: {0:00}m:{1:00}s'{2:000}ms" -f $minutes, $seconds, $milliseconds)
