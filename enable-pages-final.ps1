$env:Path += ";C:\Program Files\GitHub CLI"

$token = @(gh auth token 2>$null)[0]

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Enable GitHub Pages for both repos" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Payload for GitHub Actions source
$payload = @{
    source = @{
        branch = "main"
        path = "/"
    }
} | ConvertTo-Json

Write-Host "Setting up Test Pages..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/pages" `
        -Method POST `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"
    Write-Host "✅ Test Pages created" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    Write-Host "Status: $statusCode" -ForegroundColor Yellow
}

Write-Host ""

Write-Host "Setting up Prod Pages..." -ForegroundColor Yellow
try {
    $r2 = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/pages" `
        -Method POST `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"
    Write-Host "✅ Prod Pages created" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    Write-Host "Status: $statusCode" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Pages enabled! Workflows will now deploy apps." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Workflows will auto-run and deploy in 2-3 minutes" -ForegroundColor Yellow
Write-Host ""
Write-Host "Apps:" -ForegroundColor Cyan
Write-Host "  Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor White
Write-Host "  Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor White
