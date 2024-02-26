$fogTempDir = "C:\fogtemp"
$fogMsiPath = "$fogTempDir\fog.msi"
$fogserver = "10.2.252.200"

if (!(Test-Path $fogMsiPath)) {
  New-Item -Type Directory -Path $fogTempDir
  (New-Object System.Net.WebClient).DownloadFile("http://$fogserver/fog/client/download.php?newclient",$fogMsiPath)
  Start-Process msiexec.exe "/i $fogMsiPath /quiet /norestart /qn USETRAY=`"0`" WEBADDRESS=`"10.2.252.200`"" -Wait
  Get-Service "*Fog*" | Set-Service -StartupType Automatic
  Get-Service "*Fog*" | Start-Service
  Remove-Item -Path $fogTempDir -Recurse -ErrorAction SilentlyContinue -Force
}
