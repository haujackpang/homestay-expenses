$env:Path += ";C:\Program Files\GitHub CLI"

$token = @(gh auth token 2>$null)[0]
$wf = Get-Content "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml" -Raw
$b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($wf))

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Getting current file metadata..." -ForegroundColor Cyan

# Get Test file SHA (should exist)
try {
    $testFileInfo = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/contents/.github/workflows/deploy.yml" `
        -Headers $headers | ConvertFrom-Json
    $testSha = $testFileInfo.sha
    Write-Host "Test file SHA: $testSha" -ForegroundColor Green
} catch {
    Write-Host "Test file not found, will create new" -ForegroundColor Yellow
    $testSha = $null
}

Write-Host ""

# Update Test
Write-Host "Updating Test..." -ForegroundColor Yellow
$payload = @{
    message = "Update workflow file"
    content = $b64
    branch = "main"
} | ConvertTo-Json

if ($testSha) {
    $payload = @{
        message = "Update workflow file"
        content = $b64
        sha = $testSha
        branch = "main"
    } | ConvertTo-Json
}

try {
    $r = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-test/contents/.github/workflows/deploy.yml" `
        -Method PUT `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"
    Write-Host "✅ Test updated" -ForegroundColor Green
} catch {
    $err = $_.Exception.Response.StatusCode
    $body = $_.ErrorDetails.Message
    Write-Host "❌ Test failed: $err - $body" -ForegroundColor Red
}

Write-Host ""
Write-Host "Now trying Prod..." -ForegroundColor Yellow

# For Prod, try to get existing file or create new
try {
    $prodFileInfo = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/contents/.github/workflows/deploy.yml" `
        -Headers $headers | ConvertFrom-Json
    $prodSha = $prodFileInfo.sha
    Write-Host "Prod file already exists, SHA: $prodSha" -ForegroundColor Green
} catch {
    Write-Host "Prod file doesn't exist yet, will create" -ForegroundColor Yellow
    $prodSha = $null
}

$payload2 = @{
    message = "Add GitHub Pages workflow"
    content = $b64
    branch = "main"
} | ConvertTo-Json

if ($prodSha) {
    $payload2 = @{
        message = "Update workflow file"
        content = $b64
        sha = $prodSha
        branch = "main"
    } | ConvertTo-Json
}

try {
    $r = Invoke-WebRequest -Uri "https://api.github.com/repos/haujackpang/homestayERP-prod/contents/.github/workflows/deploy.yml" `
        -Method PUT `
        -Headers $headers `
        -Body $payload2 `
        -ContentType "application/json"
    Write-Host "✅ Prod updated/created" -ForegroundColor Green
} catch {
    $err = $_.Exception.Response.StatusCode
    $body = $_.ErrorDetails.Message
    Write-Host "❌ Prod failed: $err" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done! Check repos at: https://github.com/haujackpang/" -ForegroundColor Cyan
