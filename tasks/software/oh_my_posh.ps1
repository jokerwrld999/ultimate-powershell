#Requires -RunAsAdministrator

$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -ne "RemoteSigned") {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

$profile5Path = "C:\Windows\System32\WindowsPowerShell\v1.0"
$profile5ScriptsPath = "$profile5Path\Scripts"
$profile7Path = "C:\Program Files\PowerShell\7"
$profile7ScriptsPath = "$profile7Path\Scripts"
$profileName = "profile.ps1"
$profile5Source = "$profile5Path\$profileName"
$profile7Source = "$profile7Path\$profileName"
$profile5RemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/profiles/PowerShell5_profile.ps1"
$profile7RemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/profiles/PowerShell7_profile.ps1"
$sftaRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/scripts/SFTA.ps1"
$wakeOnLanRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/scripts/wakeOnLan.ps1"

function Get-UriHash {
  param(
    $Uri
  )
  $wc = [System.Net.WebClient]::new()
  $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
  $FileHash.Hash
}

function Update-Profile {
  param(
      $ProfileSource,
      $RemoteScript
  )

  if (!(Test-Path -Path $ProfileSource -PathType Leaf) -or
      (Get-UriHash -Uri $RemoteScript) -ne (Get-Content "$ProfileSource.sha256" -ErrorAction SilentlyContinue)) {

      Write-Host ("Updating PowerShell Profile: $ProfileSource") -ForegroundColor Blue
      Invoke-WebRequest -Uri $RemoteScript -OutFile $ProfileSource
      (Get-FileHash $ProfileSource).Hash | Out-File "$ProfileSource.sha256"

      & $ProfileSource *>$null

      Write-Host "The profile @ [$ProfileSource] has been created." -ForegroundColor Green
  } else {
      Write-Host "The profile @ [$ProfileSource] has already been created." -ForegroundColor Green
  }
}

$scripts = @($profile5ScriptsPath, $profile7ScriptsPath)

foreach ($script in $scripts) {
    if (!(Test-Path -Path $script)) {
        New-Item -Path $script -ItemType Directory | Out-Null
    }

    if (!(Test-Path -Path "$script\SFTA.ps1" -PathType Leaf) -or
       (Get-UriHash -Uri $sftaRemoteScript) -ne (Get-Content "$script\SFTA.ps1.sha256" -EA SilentlyContinue)) {
        Invoke-WebRequest -Uri $sftaRemoteScript -OutFile "$script\SFTA.ps1" | Out-Null
        (Get-FileHash "$script\SFTA.ps1").Hash | Out-File "$script\SFTA.ps1.sha256"
    }

    if (!(Test-Path -Path "$script\wakeOnLan.ps1" -PathType Leaf) -or
       (Get-UriHash -Uri $wakeOnLanRemoteScript) -ne (Get-Content "$script\wakeOnLan.ps1.sha256" -EA SilentlyContinue)) {
        Invoke-WebRequest -Uri $wakeOnLanRemoteScript -OutFile "$script\wakeOnLan.ps1" | Out-Null
        (Get-FileHash "$script\wakeOnLan.ps1").Hash | Out-File "$script\wakeOnLan.ps1.sha256"
    }
}


if ((Get-Service WinRM).Status -ne "Running") {
    Enable-PSRemoting -SkipNetworkProfileCheck -Force *>$null
    Write-Host "PowerShell Remoting enabled successfully." -ForegroundColor Green
}

$packages = @('Microsoft.Powershell', 'Microsoft.WindowsTerminal')
foreach ($package in $packages) {
  $versionMatch = winget list $package --source winget --accept-source-agreements | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)' -AllMatches

  if ($versionMatch.Matches.Count) {
    $updateAvailable = $versionMatch.Matches.Count -gt 1
    if ($updateAvailable) {
            Get-AppxPackage $package -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
            winget install --silent --id $package --source winget | Out-Null
        } else {
            continue
        }
    } else {
        winget install --silent --id $package --source winget | Out-Null
    }
}

if (!((Get-Command oh-my-posh -EA SilentlyContinue).Source)) {
  Write-Host "Installing Oh-My-Posh..." -ForegroundColor Blue
  winget install --silent JanDeDobbeleer.OhMyPosh -s winget | Out-Null
}

if (!(Get-PSRepository -Name 'PSGallery').InstallationPolicy -eq 'Trusted') {
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
}

if (!(Get-PackageProvider | Select-Object Name | Select-String "NuGet")) {
  Write-Host "Installing NuGet Provider..." -ForegroundColor Blue
  Install-PackageProvider -Name NuGet -Confirm:$False -Force
}

$modulesToInstall = @('NuGet', 'PowerShellGet', 'PSReadLine', 'Terminal-Icons')
foreach ($module in $modulesToInstall) {
  if (!(Get-Module -ListAvailable -Name $module)) {
    Install-Module -Name $module -Confirm:$False -Force | Out-Null
    Write-Host ("Installed module: $module") -ForegroundColor Green
  }
}

if (!(Test-Path -Path $profile5Path)) {
  New-Item -Path $profile5Path -ItemType Directory | Out-Null
}
if (!(Test-Path -Path $profile7Path)) {
  New-Item -Path $profile7Path -ItemType Directory | Out-Null
}

# Update Profile 5
Update-Profile -ProfileSource $profile5Source -RemoteScript $profile5RemoteScript

# Update Profile 7
Update-Profile -ProfileSource $profile7Source -RemoteScript $profile7RemoteScript

if (!(Test-Path -Path "$env:userprofile\github")) {
  New-Item -Path "$env:userprofile\github" -ItemType Directory | Out-Null
}
# Write-Host ("Walls successfully downloaded @ [$wallsFolder\$folderPath]...") -ForegroundColor Green
