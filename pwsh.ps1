# $packages = @('Microsoft.Powershell', 'Microsoft.WindowsTerminal')
# foreach ($package in $packages) {
#   $packageInfo = winget list --id $package --source winget
#   $versionMatch = $packageInfo | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)' -AllMatches
#   if ($versionMatch) {
#     $availableVersion = $versionMatch.Matches.Count -gt 1
#     if ($availableVersion) {
#       winget install --silent --id $package --source winget | Out-Null
#     }
#   } else {
#     winget install --silent --id $package --source winget | Out-Null
#   }
# }

$packages = @('Microsoft.Powershell', 'Microsoft.WindowsTerminal')
foreach ($package in $packages) {
  $packageInfo = winget list --id $package --source winget
  $versionMatch = $packageInfo | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)' -AllMatches

  if ($versionMatch.Matches.Count) {
    $updateAvailable = $versionMatch.Matches.Count -gt 1
    if ($updateAvailable) {
            Get-AppxPackage $package -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
            winget install --silent --id $package --source winget -ErrorAction Stop
        } else {
            # No update needed, skip to next package
            continue
        }
    } else {
        winget install --silent --id $package --source winget -ErrorAction Stop
    }
}
