$pwshScriptsPath = "$env:USERPROFILE\Documents\Powershell"
$sftaScript = "$pwshScriptsPath\Scripts\SFTA.ps1"
$PROFILE = $PROFILE.AllUsersAllHosts

Write-Host ("Installing Terminal Modules...") -f Blue
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PowerShellGet -Force -AllowClobber *>$null
Install-Module PSReadLine -AllowPrerelease -Force *>$null
Install-Module -Name Terminal-Icons -Repository PSGallery -Force *>$null

Write-Host ("Creating Powershell Profile...") -f Blue
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) {
            if (!(Test-Path -Path $pwshScriptsPath)) {
                New-Item -Path $pwshScriptsPath -ItemType "directory" *>$null
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path $pwshScriptsPath)) {
                New-Item -Path $pwshScriptsPath -ItemType "directory" *>$null
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
& $PROFILE

if (!(Test-Path -Path $sftaScript -PathType Leaf)) {
    Write-Host "Downloading PowerShell SFTA..." -f Blue
    Invoke-WebRequest -Uri "https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/pwsh_scripts/SFTA.ps1" -OutFile $sftaScript
}


# Write-Host ("Downloading Wallpapers...") -f Blue
# $wallsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Pictures")
# $folderPath = "Walls"
# $githubUrl = "https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/jokerwrld999/ultimate-powershell/tree/main/files/terminal/walls"

# if (!(Test-Path -Path "$wallsFolder\$folderPath")) {
#     Write-Host ("Creating $wallsFolder\$folderPath folder...") -f Blue
#     # GitHub API URL for downloading a zip archive of the folder
#     $repositoryName = "ultimate-powershell"
#     $branchName = "main"


#     # Download the HTML content from the provided URL
#     $htmlContent = Invoke-WebRequest -Uri $githubUrl

#     # Extract the download link from the HTML content
#     $downloadLink = $htmlContent.ParsedHtml.getElementById("do").href

#     # Download the zip archive
#     Invoke-WebRequest -Uri $downloadLink -OutFile "$wallsFolder\repo.zip"

#     # Expand the downloaded zip archive
#     Expand-Archive -Path "$wallsFolder\repo.zip" -DestinationPath $wallsFolder

#     # Remove the downloaded zip archive
#     Remove-Item -Path "$wallsFolder\repo.zip"
# }

# Write-Host ("Walls successfully downloaded @ [$wallsFolder\$folderPath]...") -f Green