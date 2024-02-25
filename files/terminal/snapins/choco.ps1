# Install chocolatey
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
  Write-Verbose "Chocolatey is already installed, skip installation." -Verbose
}
else {
  Write-Verbose "Installing Chocolatey..." -Verbose
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}


$applications = @(
  @{ Name = "Notepad++"; Id = "notepadplusplus" },
  @{ Name = "Firefox"; Id = "firefox" }
)

foreach ($app in $applications) {
  if (!(Get-Command -ErrorAction SilentlyContinue -Name $app.Name)) {
    Write-Host "Installing $($app.Name)..." -ForegroundColor Blue
    choco install $($app.Id) *> $null
  }
}
