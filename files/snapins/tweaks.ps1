#Requires -RunAsAdministrator

$packagesToRemove = @(
  'Microsoft.AppConnector'
  'Microsoft.BingFinance'
  'Microsoft.BingNews'
  'Microsoft.BingSports'
  'Microsoft.BingTranslator'
  'Microsoft.BingWeather'
  'Microsoft.BingFoodAndDrink'
  'Microsoft.BingHealthAndFitness'
  'Microsoft.BingTravel'
  'Microsoft.MinecraftUWP'
  'Microsoft.GamingServices'
  'Microsoft.GamingApp'
  'Microsoft.GetHelp'
  'Microsoft.Getstarted'
  'Microsoft.Messaging'
  'Microsoft.Microsoft3DViewer'
  'Microsoft.MicrosoftOfficeHub'
  'Microsoft.MicrosoftSolitaireCollection'
  'Microsoft.NetworkSpeedTest'
  'Microsoft.News'
  'Microsoft.Office.Lens'
  'Microsoft.Office.Sway'
  'Microsoft.MicrosoftStickyNotes'
  'Microsoft.MixedReality.Portal'
  'Microsoft.Office.OneNote'
  'Microsoft.OneConnect'
  'Microsoft.People'
  'Microsoft.PowerAutomateDesktop'
  'Microsoft.Print3D'
  'Microsoft.ScreenSketch'
  'Microsoft.SkypeApp'
  'Microsoft.Todos'
  'Microsoft.Windows.Photos'
  'Microsoft.WindowsAlarms'
  'Microsoft.Wallet'
  'Microsoft.Whiteboard'
  'Microsoft.WindowsCamera'
  'microsoft.windowscommunicationsapps'
  'Microsoft.WindowsFeedbackHub'
  'Microsoft.WindowsMaps'
  'Microsoft.WindowsSoundRecorder'
  'Microsoft.Xbox'
  'Microsoft.Xbox.TCUI'
  'Microsoft.XboxApp'
  'Microsoft.XboxGameOverlay'
  'Microsoft.XboxSpeechToTextOverlay'
  'Microsoft.MixedReality.Portal'
  'Microsoft.XboxIdentityProvider'
  'Microsoft.ConnectivityStore'
  'Microsoft.CommsPhone'
  'Microsoft.YourPhone'
  'Microsoft.ZuneMusic'
  'Microsoft.ZuneVideo'
  'MicrosoftTeams'
)

foreach ($package in $packagesToRemove) {
  if (Get-AppxPackage -all -Name $package) {
    Get-AppxPackage -all -Name $package | Remove-AppxPackage *>$null
  }
}

$Global:registryChangesCount = 0
function New-Registry {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [hashtable]$Properties
  )

  foreach ($property in $Properties.GetEnumerator()) {
    if (!(Test-Path $Path)) {
      New-Item -Path $Path -Force | Out-Null
    }

    if ((Get-ItemProperty -Path $Path -EA SilentlyContinue).PSObject.Properties[$property.Key].value -ne $property.Value) {
      New-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force | Out-Null
      $Global:registryChangesCount = $Global:registryChangesCount + 1
    }
  }
}

$RegistryTweaks = @(
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
    Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    Properties = @{
      NoPinningStoreToTaskbar = 1
    }
  },
  @{
    Path = 'HKCU:\Control Panel\Mouse'
    Properties = @{
      MouseSpeed = 0
      MouseThreshold1 = 0
      MouseThreshold2 = 0
    }
  },
  @{
    Path = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    Properties = @{
      "(Default)" = ''
    }
  }
)

foreach ($tweak in $RegistryTweaks) {
  New-Registry @tweak
}

if ($Global:registryChangesCount -ne 0) {
  Write-Host ("Restarting Explorer...") -ForegroundColor Blue
  Get-Process -Name explorer -EA SilentlyContinue | Stop-Process
}

Get-Service DiagTrack,dmwappushservice | Where-Object StartupType -ne Disabled | Set-Service -StartupType Disabled

Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks/oosu10.ps1" | Invoke-Expression
