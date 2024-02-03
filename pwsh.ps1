function Get-UserInput {
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

  return @{
      Distro = $Distro
      CustomUser = $CustomUser
      UserPass = $UserPass
      VaultPass = $VaultPass  # Don't store sensitive data in plain text
  }
}

function Get-AndSaveUserInput {
    $wslVarsFile = ".\.wsl_vars.json"

    $setWSLVars = Get-UserInput
    $setWSLVars | ConvertTo-Json | Out-File -FilePath $wslVarsFile

    return $setWSLVars
}

# Usage
$getWSLVars = Get-AndSaveUserInput




Write-Host "Get Wsl Vars: $getWSLVars"
Write-Host "Get Wsl Vars:" $getWSLVars.Distro

# # Access the variables
# $Distro = $wslVariables.Distro
# $CustomUser = $wslVariables.CustomUser
# $UserPass = $wslVariables.UserPass
# $VaultPass = $wslVariables.VaultPass  # Not recommended for sensitive data
