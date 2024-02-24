$fogTempDir = "C:\fogtemp"
$fogMsiPath = "$fogTempDir\fog.msi"
$fogserver = "10.2.252.200"

if (!(Test-Path $fogMsiPath)) {
  New-Item -Type Directory -Path $fogTempDir
  (New-Object System.Net.WebClient).DownloadFile("http://$fogserver/fog/client/download.php?newclient",$fogMsiPath)
  Start-Process -FilePath msiexec -ArgumentList @('/i',$fogMsiPath,'/quiet','/qn','/norestart') -NoNewWindow -Wait
  Remove-Item -Path $fogTempDir -Recurse -ErrorAction SilentlyContinue -Force
}
