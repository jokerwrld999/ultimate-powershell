#Requires -RunAsAdministrator

$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -ne "RemoteSigned") {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

Invoke-RestMethod "https://github.com/jokerwrld999/ultimate-powershell/raw/main/tasks/main.ps1" | Invoke-Expression
