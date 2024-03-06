$driverSrcPath = "C:\drivers"
$drivers = @(
  @{ Name = "Intel Ethernet Adapter";
    driverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086&DEV_15F3')";
    installSwitches = "/add-driver `"$driverSrcPath\*.inf`" /subdirs /install"
  }
)

foreach ($driver in $drivers) {
  if ([bool]$driver.driverID) {
    Write-Host "####### Installing $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process PNPUTIL.exe -ArgumentList $driver.installSwitches -Wait -NoNewWindow | Out-Null
  } else {
      Write-Host "####### $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

if (Test-Path -Path $driverSrcPath) {
  Remove-Item -Path $driverSrcPath -Recurse -Force
}

Restart-Computer -Force
