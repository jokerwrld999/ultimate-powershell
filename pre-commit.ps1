#!powershell

if (!(Get-Module -Name PowerShell-Beautifier)) {
  Install-Module -Name PowerShell-Beautifier -Force
}

Import-Module PowerShell-Beautifier.psd1

Write-Host "Formatting code"
Get-ChildItem -Path .\ -Include .ps1,.psm1 -Recurse | Edit-DTWBeautifyScript -NewLine LF

Write-Host "Testing complete. Exit code: $LASTEXITCODE"

exit $LASTEXITCODE
