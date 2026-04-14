$ErrorActionPreference = "SilentlyContinue"
$env:Path += ";C:\Program Files\GitHub CLI"

# Read workflow file
$workflowPath = ".\.github\workflows\deploy.yml"
$workflowContent = Get-Content $workflowPath -Raw

# Get API token
$token = @(gh auth token)[0]
if (-not $token) {
    Write-Host "Error: Cannot get GitHub token" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Creating workflow files..." -ForegroundColor Cyan
Write-Host ""

# Create Prod workflow
Write-Host "1. Creating workflow in Prod repository..." -ForegroundColor Yellow
$prodPayload = @{
    message = "Add GitHub Pages deployment workflow"
    content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($workflowContent))
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/contents/.github/workflows/deploy.yml" `
    -Method PUT `
    -Headers $headers `
    -Body $prodPayload `
    -ContentType "application/json" `
    -SkipHttpErrorCheck

if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
    Write-Host "✅ Prod workflow created/updated" -ForegroundColor Green
} else {
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Yellow
    $response.Content | ConvertFrom-Json | Select-Object message | Out-Host
}

Write-Host ""

# Create Test workflow
Write-Host "2. Creating workflow in Test repository..." -ForegroundColor Yellow
$testPayload = @{
    message = "Add GitHub Pages deployment workflow"
    content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($workflowContent))
} | ConvertTo-Json

$response2 = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/contents/.github/workflows/deploy.yml" `
    -Method PUT `
    -Headers $headers `
    -Body $testPayload `
    -ContentType "application/json" `
    -SkipHttpErrorCheck

if ($response2.StatusCode -eq 201 -or $response2.StatusCode -eq 200) {
    Write-Host "✅ Test workflow created/updated" -ForegroundColor Green
} else {
    Write-Host "Status: $($response2.StatusCode)" -ForegroundColor Yellow
    $response2.Content | ConvertFrom-Json | Select-Object message | Out-Host
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Triggering manual workflow runs..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Trigger Prod
Write-Host "Triggering Prod deployment..." -ForegroundColor Yellow
& gh workflow run deploy.yml --repo haujackpang/homestayERP-prod -b main 2>&1 | Select-Object -FirstIndex 0
Write-Host "✅ Prod workflow triggered" -ForegroundColor Green

Write-Host ""

# Trigger Test
Write-Host "Triggering Test deployment..." -ForegroundColor Yellow
& gh workflow run deploy.yml --repo haujackpang/homestayERP-test -b main 2>&1 | Select-Object -FirstIndex 0
Write-Host "✅ Test workflow triggered" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Deployment initiated!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check deployment progress:" -ForegroundColor Cyan
Write-Host "  Prod: https://github.com/haujackpang/homestayERP-prod/actions" -ForegroundColor White
Write-Host "  Test: https://github.com/haujackpang/homestayERP-test/actions" -ForegroundColor White
Write-Host ""
Write-Host "Your apps will be live at:" -ForegroundColor Green
Write-Host "  Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor Cyan
Write-Host "  Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ Waiting 2-3 minutes for deployment..." -ForegroundColor Yellow
