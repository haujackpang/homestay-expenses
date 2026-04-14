$env:Path += ";C:\Program Files\GitHub CLI"
$repos = @("haujackpang/homestay-expenses", "haujackpang/homestayERP-test")

foreach ($repo in $repos) {
    Write-Host "Enabling Pages for $repo..."
    $tempFile = "c:\Users\localad\Desktop\homestay-expenses\pages_payload.json"
    
    @{ 
        source = @{ branch = "main"; path = "/" }
    } | ConvertTo-Json | Out-File $tempFile -Encoding UTF8 -Force
    
    $result = gh api -X POST "repos/$repo/pages" --input $tempFile 2>&1
    Write-Host "Result: $($result | Select-Object -First 1)"
    
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}

Write-Host "`nVerifying setup..."
foreach ($repo in $repos) {
    $check = gh api "repos/$repo/pages" 2>&1
    if ($check -like "*404*") {
        Write-Host "- $($repo): Need manual action"
    } else {
        Write-Host "- $($repo): OK"
    }
}
