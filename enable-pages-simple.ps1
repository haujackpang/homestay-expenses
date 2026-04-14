$ErrorActionPreference = "SilentlyContinue"
$env:Path += ";C:\Program Files\GitHub CLI"

Write-Host "Enabling GitHub Pages..." -ForegroundColor Cyan

# Get token
$token = & gh auth token 2>$null
if (-not $token) {
    Write-Host "Error: Cannot get GitHub token" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$payload = @{ build_type = "workflow" } | ConvertTo-Json

# Prod
Write-Host "Configuring Prod Pages..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/pages" `
    -Method POST -Headers $headers -Body $payload -ContentType "application/json" `
    -SkipHttpErrorCheck | Out-Null
Write-Host "Done" -ForegroundColor Green

# Test
Write-Host "Configuring Test Pages..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/pages" `
    -Method POST -Headers $headers -Body $payload -ContentType "application/json" `
    -SkipHttpErrorCheck | Out-Null
Write-Host "Done" -ForegroundColor Green

Write-Host ""
Write-Host "Checking status..." -ForegroundColor Cyan

# Check Prod
$prodStatus = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/pages" `
    -Headers $headers -SkipHttpErrorCheck
$prodJson = $prodStatus.Content | ConvertFrom-Json 2>$null
Write-Host "Prod: $($prodJson.status)" -ForegroundColor Green

# Check Test
$testStatus = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/pages" `
    -Headers $headers -SkipHttpErrorCheck
$testJson = $testStatus.Content | ConvertFrom-Json 2>$null
Write-Host "Test: $($testJson.status)" -ForegroundColor Green

Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor White
Write-Host "  Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor White
