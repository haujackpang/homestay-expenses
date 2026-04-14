$ErrorActionPreference = "SilentlyContinue"
$env:Path += ";C:\Program Files\GitHub CLI"

Write-Host "Creating workflow file directly via GitHub API..." -ForegroundColor Cyan
Write-Host ""

# Read workflow
$workflowPath = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"
$workflowContent = Get-Content $workflowPath -Raw

# Get token
$token = @(gh auth token 2>$null)[0]
if (-not $token) {
    Write-Host "Error: No token" -ForegroundColor Red
    exit 1
}

Write-Host "Token obtained" -ForegroundColor Green
Write-Host ""

# Encode to base64
$bytes = [System.Text.Encoding]::UTF8.GetBytes($workflowContent)
$base64 = [System.Convert]::ToBase64String($bytes)

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Create for PROD
Write-Host "Creating in Prod..." -ForegroundColor Yellow

$payload = @{
    message = "Add GitHub Pages deployment workflow"
    content = $base64
    branch = "main"
} | ConvertTo-Json

$uri = "https://api.github.com/repos/haujackpang/homestayERP-prod/contents/.github/workflows/deploy.yml"

$response = Invoke-WebRequest -Uri $uri `
    -Method PUT `
    -Headers $headers `
    -Body $payload `
    -ContentType "application/json" `
    -SkipHttpErrorCheck

Write-Host "Prod Response: $($response.StatusCode)" -ForegroundColor Green

# Parse and check
if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
    Write-Host "✅ Prod file created" -ForegroundColor Green
} else {
    Write-Host "Response: $($response.Content)" -ForegroundColor Yellow
}

Write-Host ""

# Create for TEST
Write-Host "Creating in Test..." -ForegroundColor Yellow

$uri2 = "https://api.github.com/repos/haujackpang/homestayERP-test/contents/.github/workflows/deploy.yml"

$response2 = Invoke-WebRequest -Uri $uri2 `
    -Method PUT `
    -Headers $headers `
    -Body $payload `
    -ContentType "application/json" `
    -SkipHttpErrorCheck

Write-Host "Test Response: $($response2.StatusCode)" -ForegroundColor Green

if ($response2.StatusCode -eq 201 -or $response2.StatusCode -eq 200) {
    Write-Host "✅ Test file created" -ForegroundColor Green
} else {
    Write-Host "Response: $($response2.Content)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Workflow files should now be committed to both repos!" -ForegroundColor Cyan
