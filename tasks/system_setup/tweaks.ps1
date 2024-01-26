if ([bool](DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | select-string BingNews)){
    Write-Host("Uninstalling some unwanted packages...") -f Blue

    DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | select-string "^((?!DesktopAppInstaller).)*$" | select-string "^((?!Photos).)*$" | select-string "^((?!Notepad).)*$" | select-string "^((?!Terminal).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}
}
else {
    Write-Host("All unwanted packages are already uninstalled.") -f Green
}

$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$name = "ConsentPromptBehaviorAdmin"
$UACValue = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction SilentlyContinue

if ($UACValue -ne 0) {
    Write-Host ("Changing registry settings for taskbar, lockscreen, and more...") -f Blue

    # Set the Windows Taskbar to always combine items
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -Value 0

    # Set the Windows Taskbar to use small icons
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Value 1

    # Disable Chat, Widgets Taskbar Buttons
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarEnabled' -Value 1
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarMode' -Value 2
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0

    # Set Dark Windows Theme
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value 0 -Type Dword -Force
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

    # Set Terminal as Default
    New-Item -Path "HKCU:\Console\%%Startup" -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" -Force
    New-Item -Path "HKCU:\Console\%%Startup" -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" -Force

    # Disable Game Overlays
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0

    # Show hidden files and folders
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1

    # Don't hide file extensions
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1

    # Don't include public folders in search (faster)
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_SearchFiles' -Value 1

    # Disable Taskbar / Cortana Search Box on Windows 11
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "00000000";

    # Don't show ads / nonsense on the lockscreen
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'ContentDeliveryAllowed' -Value 1
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenEnabled' -Value 1
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338388Enabled' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Value 0
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-88000326Enabled' -Value 0

    # Stop pestering to create a Microsoft Account. Local accounts: this is the way.
    New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -PropertyType DWord -Value 3 -Force | Out-Null

    # Get rid of the incredibly stupid "Show More Options" context menu default that NO ONE ASKED FOR
    New-Item -Path 'HKCU:\Software\Classes\CLSID' -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -f | Out-Null
    New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Name 'InprocServer32' -Value '' -f | Out-Null

    # Set region(US) and timezone
    Set-WinHomeLocation -GeoID 244
    Set-TimeZone -Name "GTB Standard Time"

    # Disable prompts to create an MSFT account
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "00000000"

    # Disable Uac
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0

    Write-Host ("Disabling as much data collection / mining as we can...") -f Blue
    Get-Service DiagTrack | Set-Service -StartupType Disabled
    Get-Service dmwappushservice | Set-Service -StartupType Disabled
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    Write-Host ("Restarting Explorer...") -f Blue
    Get-Process -Name explorer | Stop-Process
    Start-Process Explorer.exe; Start-Sleep -s 2; (New-Object -comObject Shell.Application).Windows() | foreach-object {$_.quit()}
}
else {
    Write-Host "####### Registry tweaks has been already configured... #######" -ForegroundColor Green
}

# Run OOSU10
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks/oosu10.ps1" | iex

$edgePackage = Get-Command -ErrorAction SilentlyContinue -CommandType Application -Name msedge
if ($edgePackage) {
    Write-Host "Removing Microsoft Edge..." -f Blue
    irm "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/edgeremoval.ps1" | iex *> $null
} else {
    Write-Host "Microsoft Edge has been already uninstalled." -f Green
}

$oneDriveInstalled = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name OneDrive -ErrorAction SilentlyContinue)
if ($oneDriveInstalled) {
    Write-Host ("Removing OneDrive...") -f Blue
    irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks/remove_onedrive.ps1" | iex *> $null
} else {
    Write-Host "OneDrive has been already uninstalled." -f Green
}

Write-Host ("Deleting Temp Files...") -f Blue
Get-ChildItem -Path "C:\Windows\Temp\" *.* -Recurse | Remove-Item -Force -Recurse -EA SilentlyContinue *> $null
Get-ChildItem -Path $env:TEMP *.* -Recurse | Remove-Item -Force -Recurse -EA SilentlyContinue *> $null