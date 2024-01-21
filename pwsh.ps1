$wslInfo = $(powershell -c "wsl --version")
Write-Output "WSL Info: $wslInfo"
$pattern = '^Kernel version: (\d+\.\d+\.\d+\.\d+)'
$matches = [regex]::Match($wslInfo, $pattern)

if ($matches.Success) {
    $kernelVersion = $matches.Groups[1].Value
    Write-Output "Kernel Version: $kernelVersion"
} else {
    Write-Output "Kernel Version not found in the text."
}