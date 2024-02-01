#Requires -RunAsAdministrator

$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
  Write-Host ("Execution policy is already set to RemoteSigned for the current user, skipping...") -f Green
}
else {
  Write-Host ("Setting execution policy to RemoteSigned for the current user...") -f Green
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned | Out-Null
}

Invoke-RestMethod "https://github.com/jokerwrld999/ultimate-powershell/raw/main/tasks/main.ps1" | Invoke-Expression
