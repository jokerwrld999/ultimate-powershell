$pwshScriptsPath = "$env:USERPROFILE\Documents\Powershell"
$profile5Path = "C:\Windows\System32\WindowsPowerShell\v1.0"
$profile7Path = "C:\Program Files\PowerShell\7"
$profileName = "profile.ps1"
$profile5Source = "$profile5Path\$profileName"
$profile7Source = "$profile7Path\$profileName"
$sftaScript = "$pwshScriptsPath\Scripts\SFTA.ps1"

winget install --id Microsoft.Powershell --source winget

Write-Host ("Installing Terminal Modules...") -f Blue
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PowerShellGet -Force -AllowClobber *>$null
Install-Module PSReadLine -AllowPrerelease -Force *>$null
Install-Module -Name Terminal-Icons -Repository PSGallery -Force *>$null


$profiles = @($profile5Source, $profile7Source)
foreach ($profile in $profiles) {
    if (!(Test-Path -Path $profile -PathType Leaf)) {
        try {
            # Detect Version of Powershell & Create Profile directories if they do not exist.
                if (!(Test-Path -Path $profile5Path)) {
                    New-Item -Path $profile5Path -ItemType "directory" *>$null
                }
                if (!(Test-Path -Path $profile7Path)) {
                    New-Item -Path $profile7Path -ItemType "directory" *>$null
                }
            Write-Host ("Creating Powershell Profile...") -f Blue
            Invoke-WebRequest -Uri https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/PowerShell_profile.ps1 -OutFile $profile
            Write-Host "The profile @ [$profile] has been created." -f Green
            }

        catch {
            throw $_.Exception.Message
        }
    }
    else {
        Remove-Item -Path $profile
        Invoke-RestMethod https://github.com/jokerwrld999/ultimate-powershell/raw/main/files/terminal/PowerShell_profile.ps1 -o $profile
        Write-Host "The profile @ [$profile] has been created and old profile removed." -f Green
    }
}

& $profile5Source
& $profile7Source

if (!(Test-Path -Path $sftaScript -PathType Leaf)) {
    New-Item -Path "$pwshScriptsPath\Scripts" -ItemType "directory" *>$null
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