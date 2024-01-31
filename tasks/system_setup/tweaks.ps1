if ([bool](DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | select-string BingNews)){
    Write-Host("Uninstalling some unwanted packages...") -f Blue

    DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename | % {$_ -replace("PackageName : ", "")} | select-string "^((?!WindowsStore).)*$" | select-string "^((?!DesktopAppInstaller).)*$" | select-string "^((?!Photos).)*$" | select-string "^((?!Notepad).)*$" | select-string "^((?!Terminal).)*$" | ForEach-Object {Remove-AppxPackage -allusers -package $_}
}
else {
    Write-Host("All unwanted packages are already uninstalled.") -f Green
}

$global:registryChangesCount = 0
function Set-RegistryTweaks {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
  
        [Parameter(Mandatory = $true)]
        [hashtable] $Properties
    )
  
    foreach ($property in $Properties.GetEnumerator()) {
      $itemValue = Get-ItemPropertyValue -Path $Path -Name $property.Key -ErrorAction SilentlyContinue
      if ($itemValue -ne $property.Value) {
        Set-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force
        $global:registryChangesCount = $global:registryChangesCount + 1
      }
    }
  }
  
  function Create-RegistryTweaks {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
  
        [Parameter(Mandatory = $true)]
        [hashtable] $Properties
    )
  
    foreach ($property in $Properties.GetEnumerator()) {
      $itemValue = Get-ItemPropertyValue -Path $Path -Name $property.Key -ErrorAction SilentlyContinue
      if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force
      }
      elseif ($itemValue -ne $property.Value) {
        New-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force
        $global:registryChangesCount = $global:registryChangesCount + 1
      }
    }
  }
  
  $setRegistryTweaks = @(
    @{
        Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Properties = @{
            TaskbarGlomLevel = 0
            TaskbarSmallIcons = 1
            MMTaskbarEnabled = 1
            MMTaskbarMode = 2
            TaskbarMn = 0
            TaskbarDa = 0
            ShowTaskViewButton = 0
            Hidden = 1
            HideFileExt = 1
            Start_SearchFiles = 1
        }
    },
    @{
        Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        Properties = @{
            AppsUseLightTheme = 0
            SystemUsesLightTheme = 0
        }
    },
    @{
      Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
      Properties = @{
        SearchboxTaskbarMode = 0
      }
    },
    @{
      Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
      Properties = @{
        ContentDeliveryAllowed = 1
        RotatingLockScreenEnabled = 1
        RotatingLockScreenOverlayEnabled = 0
        "SubscribedContent-338388Enabled" = 0
        "SubscribedContent-338389Enabled" = 0
        "SubscribedContent-88000326Enabled" = 0
      }
    },
    @{
      Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
      Properties = @{
        AppCaptureEnabled = 0
      }
    },
    @{
      Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
      Properties = @{
        NoConnectedUser = 3
        EnableLUA = 0
        ConsentPromptBehaviorAdmin = 0
      }
    },
    @{
      Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
      Properties = @{
        AllowTelemetry = 0
      }
    },
    @{
      Path = 'HKCU:\Control Panel\Mouse'
      Properties = @{
        MouseSpeed = 0
        MouseThreshold1 = 0
        MouseThreshold2 = 0
      }
    }
  )
  
foreach ($tweak in $setRegistryTweaks) {
    Set-RegistryTweaks @tweak
}
  
$createRegistryTweaks = @(
    @{
        Path = 'HKCU:\Console\%%Startup'
        Properties = @{
        DelegationConsole = "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
        DelegationTerminal = "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
        }
    },
    @{
        Path = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
        Properties = @{
        InprocServer32 = ''
        }
    }
)

  foreach ($tweak in $createRegistryTweaks) {
    Create-RegistryTweaks @tweak
  }

if ($global:registryChangesCount -ne 0){
    Write-Host ("Restarting Explorer...") -f Blue
    Get-Process -Name explorer | Stop-Process
    Start-Process Explorer.exe; Start-Sleep -s 2; (New-Object -comObject Shell.Application).Windows() | foreach-object {$_.quit()}
}

# Set region (US) and time zone if not already set
if ((Get-WinHomeLocation).GeoId -ne 241) {
    Set-WinHomeLocation -GeoID 241
}
if ((Get-TimeZone).Id -ne "FLE Standard Time") {
    Set-TimeZone -Name "FLE Standard Time"
}

Write-Host -ForegroundColor Blue "Disabling data collection..."
Get-Service DiagTrack, dmwappushservice | Where-Object StartupType -ne Disabled | Set-Service -StartupType Disabled

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