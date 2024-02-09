Write-Host "Kill OneDrive process" -ForegroundColor Cyan
taskkill.exe /IM "OneDrive.exe" /F /FI "STATUS eq RUNNING"

Write-Host "Copy all OneDrive to Root UserProfile" -ForegroundColor Cyan
Start-Process -FilePath robocopy -ArgumentList "$env:USERPROFILE\OneDrive $env:USERPROFILE /e /xj" -NoNewWindow -Wait

Write-Host "Remove OneDrive" -ForegroundColor Cyan
Start-Process -FilePath winget -ArgumentList "uninstall -e --purge --force --silent Microsoft.OneDrive " -NoNewWindow -Wait

Write-Host "Removing OneDrive leftovers" -ForegroundColor Cyan
$OneDriveFolders = @("$env:localappdata\Microsoft\OneDrive", "$env:programdata\Microsoft OneDrive", "$env:systemdrive\OneDriveTemp")
$OneDriveFolders | ForEach-Object {
    Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
}

if (!(Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count) {
    Remove-Item -Path "$env:userprofile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Remove Onedrive from explorer sidebar" -ForegroundColor Cyan

if (!(Test-Path -Path "HKCR:")) {
  New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR
}

$registryPaths = @(
    "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)

foreach ($path in $registryPaths) {
    if (Test-Path -Path $path) {
        $property = Get-ItemProperty -Path $path -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue
        if ($property -and $property.'System.IsPinnedToNameSpaceTree' -ne 0) {
            Set-ItemProperty -Path $path -Name "System.IsPinnedToNameSpaceTree" -Value 0
            Write-Host "OneDrive removed from $path." -ForegroundColor Green
        } else {
            Write-Host "OneDrive already removed from $path." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "Path $path not found in registry." -ForegroundColor Yellow
    }
}

Write-Host "Removing run hook for new users" -ForegroundColor Cyan
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

Write-Host "Removing startmenu entry" -ForegroundColor Cyan
Remove-Item -Path "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -ErrorAction SilentlyContinue

Write-Host "Removing scheduled task" -ForegroundColor Cyan
Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

Write-Host "Shell Fixing" -ForegroundColor Cyan
$shellFolders = @{
    "AppData" = "$env:userprofile\AppData\Roaming";
    "Cache" = "$env:userprofile\AppData\Local\Microsoft\Windows\INetCache";
    "Cookies" = "$env:userprofile\AppData\Local\Microsoft\Windows\INetCookies";
    "Favorites" = "$env:userprofile\Favorites";
    "History" = "$env:userprofile\AppData\Local\Microsoft\Windows\History";
    "Local AppData" = "$env:userprofile\AppData\Local";
    "My Music" = "$env:userprofile\Music";
    "My Video" = "$env:userprofile\Videos";
    "NetHood" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Network Shortcuts";
    "PrintHood" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Printer Shortcuts";
    "Programs" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs";
    "Recent" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Recent";
    "SendTo" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo";
    "Start Menu" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu";
    "Startup" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup";
    "Templates" = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Templates";
    "{374DE290-123F-4565-9164-39C4925E467B}" = "$env:userprofile\Downloads";
    "Desktop" = "$env:userprofile\Desktop";
    "My Pictures" = "$env:userprofile\Pictures";
    "Personal" = "$env:userprofile\Documents";
    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" = "$env:userprofile\Documents";
    "{0DDD015D-B06C-45D5-8C4C-F59713854639}" = "$env:userprofile\Pictures";
}

$shellFolders.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $_.Key -Value $_.Value -Type ExpandString
}

Write-Host "Restarting explorer" -ForegroundColor Cyan
Get-Process -Name explorer -EA SilentlyContinue | Stop-Process
