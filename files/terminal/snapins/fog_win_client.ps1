$fogTempDir = "C:\fogtemp"
$fogMsiPath = "$fogTempDir\fog.msi"
$fogInstalledPath = "C:\Program Files (x86)\FOG\FOGService.exe"
$fogserver = "10.2.252.200"

if (!(Test-Path $fogMsiPath)) {
  New-Item -Type Directory -Path $fogTempDir
  if (!(Test-Path $fogInstalledPath)) {
    (New-Object System.Net.WebClient).DownloadFile("http://$fogserver/fog/client/download.php?newclient",$fogMsiPath)
    Start-Process msiexec.exe "/i $fogMsiPath /quiet /norestart /qn USETRAY=`"0`" WEBADDRESS=`"$fogserver`"" -Wait
  }
  Get-Service "*Fog*" |  Set-Service -Status Running -StartupType Automatic
  Get-Service "*Fog*" | Start-Service
  Remove-Item -Path $fogTempDir -Recurse -ErrorAction SilentlyContinue -Force
}
