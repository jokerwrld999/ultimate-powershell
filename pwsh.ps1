
[CmdletBinding()]
param (
    [Parameter()]
    [switch] $Boot
)

function CheckAndInstallFeatures() {
    Write-Host "########## Checking WLS 2 features... ############" -ForegroundColor Blue
    if (!((Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform").State -eq "Disabled")) {
            Write-Host "Enabling WLS 2 features..." -ForegroundColor Blue
            Write-Host "$Distro" -f Magenta
           Write-host "        $SetupWSLDistro" 
    }
}

    do {
  Write-Host "Choose a distro:"
  Write-Host "1. Arch"
  Write-Host "2. Ubuntu"
  $distroChoice = Read-Host "Enter choice (1 or 2):"
} until ($distroChoice -eq "1" -or $distroChoice -eq "2")
$Distro = switch ($distroChoice) {
  "1" { "Arch" }
  "2" { "Ubuntu" }
}

$CustomUser = Read-Host "Custom user (default: jokerwrld):"
if (!$CustomUser) { $CustomUser = "jokerwrld" }

$UserPass = Read-Host "User password (default: $CustomUser):"
if (!$UserPass) { $UserPass = $CustomUser }

$VaultPass = (Read-Host "Vault pass: " -AsSecureString)
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($VaultPass)
$VaultPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    
$SetupWSLDistro = "SetupWSLDistro -Distro $Distro -CustomUser $CustomUser -UserPass $UserPass -VaultPass $VaultPass"
if (!$Boot) {
   Write-Host "$SetupWSLDistro" -f Green 
    Write-host "CheckAndInstallFeatures"
    CheckAndInstallFeatures

}
else {
    Write-host "from restart"
}