$output = wsl --version
$output = $output | Select-Object -Skip 1
$output = $output.ToString().Trim()
$versionMatch = $output -match '(?i)^Kernel.*(\d+\.\d+\.\d+\.\d+)'
$version = $matches[1]
Write-Host "WSL kernel version: $version"
