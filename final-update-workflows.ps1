$env:Path += ";C:\Program Files\GitHub CLI"

$token = @(gh auth token 2>$null)[0]
$wf = Get-Content "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml" -Raw
$b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($wf))

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$payload = @{
    message = "Update: GitHub Pages workflow with correct versions"
    content = $b64
    branch = "main"
} | ConvertTo-Json

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Updating both repositories..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Prod
Write-Host "Pushing to Prod..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/contents/.github/workflows/deploy.yml" `
        -Method PUT `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"
    Write-Host "✅ Prod updated (Status: $($r.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Prod: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

Write-Host ""

# Test
Write-Host "Pushing to Test..." -ForegroundColor Yellow
try {
    $r2 = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/contents/.github/workflows/deploy.yml" `
        -Method PUT `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"
    Write-Host "✅ Test updated (Status: $($r2.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Test: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Deployment will start automatically in 1-2 minutes" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check progress:" -ForegroundColor Cyan
Write-Host "  Prod: https://github.com/haujackpang/homestayERP-prod/actions" -ForegroundColor White
Write-Host "  Test: https://github.com/haujackpang/homestayERP-test/actions" -ForegroundColor White
Write-Host ""
Write-Host "Apps:" -ForegroundColor Cyan
Write-Host "  Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor White
Write-Host "  Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor White
