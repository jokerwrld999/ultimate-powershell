Write-Host ("Installing Terminal Modules...") -f Blue
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PowerShellGet -Force -AllowClobber *>$null
Install-Module PSReadLine -AllowPrerelease -Force *>$null
Install-Module -Name Terminal-Icons -Repository PSGallery -Force *>$null

Write-Host ("Creating Powershell Profile...") -f Blue
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        $powershellScriptsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Documents\Powershell")
        if ($PSVersionTable.PSEdition -eq "Core" ) {
            if (!(Test-Path -Path $powershellScriptsFolder)) {
                New-Item -Path $powershellScriptsFolder -ItemType "directory" *>$null
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path $powershellScriptsFolder)) {
                New-Item -Path $powershellScriptsFolder -ItemType "directory" *>$null
            }
        }

        Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created." -f Green
    }
    catch {
        throw $_.Exception.Message
    }
}
else {
    Remove-Item -Path $PROFILE
    Invoke-RestMethod https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/PowerShell_profile.ps1 -o $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed." -f Green
}
& $profile


Write-Host ("Downloading Wallpapers...") -f Blue
$wallsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Pictures/Walls")
$url = 'https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/walls'

if (!(Test-Path -Path $wallsFolder)) {
    Write-Host ("Creating $wallsFolder folder...") -f Blue
    New-Item -Path $wallsFolder -ItemType "directory" *>$null
}

# enable TLS 1.2 and TLS 1.1 protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Tls11

Write-Host ("Downloading walls...") -f Blue
$WebResponse = Invoke-WebRequest -Uri $url
# get the list of links, skip the first one ("../") and download the files
$WebResponse.Links | Select-Object -ExpandProperty href -Skip 1 | ForEach-Object {
    Write-Host "Downloading file '$_'"
    $filePath = Join-Path -Path $wallsFolder -ChildPath $_
    $fileUrl  = '{0}/{1}' -f $url.TrimEnd('/'), $_
    Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
}
Write-Host ("Walls successfully downloaded @ [$wallsFolder]...") -f Green