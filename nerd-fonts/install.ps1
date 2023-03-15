$fontsDir = "$PSScriptRoot\tmp-fonts"
$nerdFont = "Meslo"

If(!(Test-Path -Path $fontsDir))
{
    New-Item -ItemType Directory -Path $fontsDir
    Write-Host "New folder created successfully!" -f Green
}
else
{
  Write-Host "Folder already exists!" -f Yellow
}

Write-Host "####### Downloading Fonts....... #######" -f Green
If(!(Test-Path -Path $fontsDir\$nerdFont.zip))
{
    Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/$nerdFont.zip -OutFile $fontsDir\$nerdFont.zip
    Write-Host "####### Fonts downloaded successfully! #######" -f Green
}
else
{
  Write-Host "####### Fonts already downloaded! #######" -f Yellow
}

Write-Host "####### Extractiing Fonts....... #######" -f Green
If(!(Test-Path -Path  $fontsDir\$nerdFont))
{
    Expand-Archive -Path $fontsDir\$nerdFont.zip -DestinationPath $fontsDir\$nerdFont
    Write-Host "####### Fonts extracted successfully! #######" -f Green
}
else
{
  Write-Host "####### Fonts already extracted! #######" -f Yellow
}

function Install-Font {
    param
    (
         [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile
    )

    #Get Font Name from the File's Extended Attributes
    $oShell = new-object -com shell.application
    $Folder = $oShell.namespace($FontFile.DirectoryName)
    $Item = $Folder.Items().Item($FontFile.Name)
    $FontName = $Folder.GetDetailsOf($Item, 21)
    try {
         switch ($FontFile.Extension) {
              ".ttf" {$FontName = $FontName + [char]32 + '(TrueType)'}
              ".otf" {$FontName = $FontName + [char]32 + '(OpenType)'}
         }
         $Copy = $true
         Write-Host ('Copying' + [char]32 + $FontFile.Name + '.....') -NoNewline
         Copy-Item -Path $fontFile.FullName -Destination ("C:\Windows\Fonts\" + $FontFile.Name) -Force
         #Test if font is copied over
         If ((Test-Path ("C:\Windows\Fonts\" + $FontFile.Name)) -eq $true) {
              Write-Host ('Success') -Foreground Green
         } else {
              Write-Host ('Failed') -ForegroundColor Red
         }
         $Copy = $false
         #Test if font registry entry exists
         If ((Get-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue) -ne $null) {
              #Test if the entry matches the font file name
              If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {
                   Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline
                   Write-Host ('Success') -ForegroundColor Green
              } else {
                   $AddKey = $true
                   Remove-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force
                   Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline
                   New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
                   If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {
                        Write-Host ('Success') -ForegroundColor Green
                   } else {
                        Write-Host ('Failed') -ForegroundColor Red
                   }
                   $AddKey = $false
              }
         } else {
              $AddKey = $true
              Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline
              New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
              If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {
                   Write-Host ('Success') -ForegroundColor Green
              } else {
                   Write-Host ('Failed') -ForegroundColor Red
              }
              $AddKey = $false
         }

    } catch {
         If ($Copy -eq $true) {
              Write-Host ('Failed') -ForegroundColor Red
              $Copy = $false
         }
         If ($AddKey -eq $true) {
              Write-Host ('Failed') -ForegroundColor Red
              $AddKey = $false
         }
         write-warning $_.exception.message
    }
    Write-Host
}

foreach ($fontDir in (Get-ChildItem -Path $fontsDir)){
    $fontItems = "$fontsDir\$fontDir"

    foreach ($fontItem in (Get-ChildItem -Path  $fontItems |
    Where-Object {($_.Name -like '*.ttf') -or ($_.Name -like '*.otf') })) {

        Write-Host "####### Installing font $fontItem....... #######" -f Green
        if (!(Test-Path -Path "C:\Windows\fonts\$fontItem" )) {
            Install-Font -FontFile $fontItem
        }
        else {
            Write-Host "Font already installed" -f Yellow
        }
    }
}

If((Test-Path -Path  $fontsDir))
{
    Write-Host "####### Cleaning Temp Folder....... #######" -f Green
    Remove-Item -Recurse -Force $fontsDir
}
else
{
  Write-Host "####### Folder already removed! #######" -f Yellow
}
