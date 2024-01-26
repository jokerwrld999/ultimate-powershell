$pwshScriptsPath = "$env:USERPROFILE\Documents\Powershell\Scripts"
$profile5Path = "C:\Windows\System32\WindowsPowerShell\v1.0"
$profile7Path = "C:\Program Files\PowerShell\7"
$profileName = "profile.ps1"
$profile5Source = "$profile5Path\$profileName"
$profile7Source = "$profile7Path\$profileName"
$profileRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/PowerShell_profile.ps1"
$sftaSourceScript = "$pwshScriptsPath\SFTA.ps1"
$sftaHashFile = "$sftaSourceScript.sha256"
$sftaRemoteScript = "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/pwsh_scripts/SFTA.ps1"

function Stream-FileHash {
    param (
        $Uri
    )
    $wc = [System.Net.WebClient]::new()
    $FileHash = Get-FileHash -InputStream ($wc.OpenRead($Uri))
    $FileHash.Hash
}

if (!(Test-Path -Path $sftaSourceScript -PathType Leaf) -or
    (Stream-FileHash -Uri $sftaRemoteScript) -ne (Get-Content $sftaHashFile -EA SilentlyContinue)) {
    if (!(Test-Path -Path $pwshScriptsPath)) {
        New-Item -Path $pwshScriptsPath -ItemType Directory | Out-Null
    }

    Invoke-WebRequest -Uri $sftaRemoteScript -OutFile $sftaSourceScript | Out-Null
    (Get-FileHash $sftaSourceScript).Hash | Out-File $sftaHashFile
}

$packageInfo = winget list --id Microsoft.Powershell --source winget
$versionMatch = $packageInfo | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)' -AllMatches
if ($versionMatch){
    $currentVersion = $versionMatch.Matches[0].Groups[1].Value
    $availableVersion = $versionMatch.Matches.Count -gt 1
    if ($availableVersion) {
        winget uninstall Microsoft.Powershell
        winget install --id Microsoft.Powershell --source winget
    }
}
else {
  winget install --id Microsoft.Powershell --source winget
}

if (!(Get-PSRepository -Name 'PSGallery').InstallationPolicy -eq 'Trusted') {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
}

if (!(Get-packageProvider | Select-Object Name | Select-string "NuGet")) {
  Install-PackageProvider -Name NuGet -Confirm:$False -Force
} else {
  Write-Host "NuGet provider is already present."
}

$modulesToInstall = @('NuGet', 'PowerShellGet', 'PSReadLine', 'Terminal-Icons')
foreach ($module in $modulesToInstall) {
    if (!(Get-InstalledModule -Name $module)) {
        $ProgressPreference = "SilentlyContinue"
        Install-Module -Name $module -Confirm:$False -Force | Out-Null
        Write-Host ("Installed module: $module") -f Green
    }
}

if (!(Test-Path -Path $profile5Path)) {
    New-Item -Path $profile5Path -ItemType Directory | Out-Null
}
if (!(Test-Path -Path $profile7Path)) {
    New-Item -Path $profile7Path -ItemType Directory | Out-Null
}

$profiles = @($profile5Source, $profile7Source)
foreach ($profile in $profiles) {
    if (!(Test-Path -Path $profile -PathType Leaf) -or
    (Stream-FileHash -Uri $profileRemoteScript) -ne (Get-Content "$profile.sha256" -EA SilentlyContinue)) {

        Write-Host ("Creating Powershell Profile...") -f Blue
        Invoke-WebRequest -Uri $profileRemoteScript -OutFile $profile
        (Get-FileHash $profile).Hash | Out-File "$profile.sha256"
        Write-Host "The profile @ [$profile] has been created." -f Green
    }
    else {
        Write-Host "The profile @ [$profile] has been already created." -f Green
    }
}

& $profile5Source
& $profile7Source


# Write-Host ("Walls successfully downloaded @ [$wallsFolder\$folderPath]...") -f Green