
$buckets = @('main', 'extras', 'nerd-fonts', 'nonportable', 'games', 'Scoop-Apps')
foreach ($bucket in $buckets) {
    if (!(scoop bucket list) | Select-string $bucket) {
        Write-Host "Adding Scoop bucket: $bucket" -f Blue
        # scoop bucket add $bucket *>$null
    }
    else {
        Write-Host "Skeept buckt... $bucket"
    }
}
