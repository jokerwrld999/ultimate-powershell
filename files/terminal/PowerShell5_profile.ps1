# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$Env:currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

#######################################################
# GENERAL SCRIPTS
#######################################################
. $PSHOME\Scripts\SFTA.ps1
. $PSHOME\Scripts\wakeOnLan.ps1

#######################################################
# GENERAL ALIAS'S
#######################################################
Set-Alias -Name pss -Value Remote
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
Set-Alias -Name reboot -Value Restart-Computer
Set-Alias -Name rebootRemote -Value Restart-Remote
Set-Alias -Name profile -Value Restart-Profile
Set-Alias -Name ssh-copy-id -Value Copy-SshPublicKey
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name wol -Value Invoke-WakeOnLan

#######################################################
# GENERAL FUNCTIONS
#######################################################
# Useful shortcuts for traversing directories
function cd.. { Set-Location .. }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function cdls {
  Set-Location "$args"
  ls .
}

# Force remove
function rmf { rm -r -fo $args }

# Compute file hashes - useful for checking successful downloads
function md5 { Get-FileHash -Algorithm md5 $args }
function sha1 { Get-FileHash -Algorithm sha1 $args }
function sha256 { Get-FileHash -Algorithm sha256 $args }

# Quick shortcut to start code
function c { code "$args" }

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# Creates drive shortcut for Work Folders, if current user account is using it
if (Test-Path "$env:USERPROFILE\Work Folders") {
  New-PSDrive -Name Work -PSProvider FileSystem -Root "$env:USERPROFILE\Work Folders" -Description "Work Folders"
  function Work: { Set-Location Work: }
}

# Set up command prompt and window title. Use UNIX-style convention for identifying
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
function prompt {
  if ($isAdmin) {
    "[" + (Get-Location) + "] # "
  } else {
    "[" + (Get-Location) + "] $ "
  }
}

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin) {
  $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
  if ($args.Count -gt 0) {
    Get-ChildItem -Recurse -Include "$args" | ForEach-Object FullName
  } else {
    Get-ChildItem -Recurse | ForEach-Object FullName
  }
}

# Simple function to start a new elevated process. If arguments are supplied then
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
  if ($args.Count -gt 0) {
    $argList = "& '" + $args + "'"
    Start-Process "$PSHOME\powershell.exe" -Verb runAs -ArgumentList $argList
  } else {
    Start-Process "$PSHOME\powershell.exe" -Verb runAs
  }
}

# Make it easy to edit this profile once it's installed
function Edit-Profile {
  if ($host.Name -match "ise") {
    $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
  } else {
    notepad $profile.CurrentUserAllHosts
  }
}

# Delete temporary variables to get to $isAdmin.
Remove-Variable identity
Remove-Variable principal

function checkcommand {
  param($command)
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  try { if (Get-Command $command) { return $true } }
  catch { Write-Host "$command does not exist"; return $false }
  finally { $ErrorActionPreference = $oldPreference }
}

# List files
function lf { Get-ChildItem -Path $pwd -File }

# Go to the github folder
function g { Set-Location $env:USERPROFILE\github }

# Git commit
function gcom {
  git add .
  git commit -m "$args"
}

# Lazy git push
function lazyg {
  git add .
  git commit -m "$args"
  git push
}

# Git clone repo and go to the directory
function gclone {
  $basename = [io.path]::GetFileNameWithoutExtension($args)
  git clone $args
  Set-Location $basename
}

# Gh clone repo and go to the directory
function ghclone {
  $basename = "$args" -replace '^.*?/'
  gh repo clone $args
  Set-Location $basename
}
# Git push
function gpush { git push }

# Git status
function gs { git status }

# Get My Public IP
function pubip {
  (Invoke-RestMethod http://ifconfig.me/ip).Content
}

# Reload $PROFILE
function Restart-Profile {
  & "$PSHOME\profile.ps1"
}

function find-file ($name) {
  Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.Directory
    Write-Output "${place_path}\${_}"
  }
}

function unzip ($file) {
  Write-Output ("Extracting",$file,"to",$pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep ($regex,$dir) {
  if ($dir) {
    Get-ChildItem $dir | Select-String $regex
    return
  }
  $input | Select-String $regex
}

function touch ($file) {
  "" | Out-File $file -Encoding ASCII
}

function df {
  Get-Volume
}

function sed ($file,$find,$replace) {
  (Get-Content $file).Replace("$find",$replace) | Set-Content $file
}

function which ($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

function export ($name,$value) {
  Set-Item -Force -Path "env:$name" -Value $value;
}

function pkill ($name) {
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep ($name) {
  Get-Process $name
}

function speedtest ()
{
  & speedtest.exe --accept-license
}

function Remote($computerName){
  # if(!$Global:credential){
  #   $Global:credential =  Get-Credential
  # }
  $session = New-PSSession -ComputerName $computerName #-Credential $credential
  Invoke-Command -FilePath "$PSHome\profile.ps1" -Session $session
  Enter-PSSession -Session $session
}

function Restart-Remote {Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/files/terminal/pwsh_scripts/rebootRemotely.ps1" | Invoke-Expression}

function Copy-SshPublicKey {Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/files/terminal/pwsh_scripts/sshCopyID.ps1" | Invoke-Expression}

#######################################################
# IMPORT MODULES
#######################################################
Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key "Ctrl+Backspace" -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key "Ctrl+Spacebar" -Function SelectForwardChar

#######################################################
# SET PWSH PROMPT
#######################################################
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json' | Invoke-Expression
