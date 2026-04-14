#!/usr/bin/env pwsh

$ErrorActionPreference = "SilentlyContinue"
$env:Path += ";C:\Program Files\GitHub CLI"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🔧 启用 GitHub Pages" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 获取 GitHub token
$token = & gh auth token 2>$null
if (-not $token) {
    Write-Host "❌無法获取 GitHub token" -ForegroundColor Red
    exit 1
}

Write-Host "✅ GitHub token 已获取" -ForegroundColor Green
Write-Host ""

# Prod 仓库
Write-Host "📦 配置 Prod 仓库..." -ForegroundColor Yellow
$prodRepo = "haujackpang/homestayERP-prod"
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$prodPayload = @{
    build_type = "workflow"
    source     = @{
        branch = "main"
        path   = "/"
    }
} | ConvertTo-Json

try {
    $prodResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$prodRepo/pages" `
        -Method POST `
        -Headers $headers `
        -Body $prodPayload `
        -ContentType "application/json" `
        -SkipHttpErrorCheck
    
    Write-Host "✅ Prod Pages 配置已发送" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Prod Pages 配置失败: $_" -ForegroundColor Yellow
}

Write-Host ""

# Test 仓库
Write-Host "📦 配置 Test 仓库..." -ForegroundColor Yellow
$testRepo = "haujackpang/homestayERP-test"

$testPayload = @{
    build_type = "workflow"
    source     = @{
        branch = "main"
        path   = "/"
    }
} | ConvertTo-Json

try {
    $testResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$testRepo/pages" `
        -Method POST `
        -Headers $headers `
        -Body $testPayload `
        -ContentType "application/json" `
        -SkipHttpErrorCheck
    
    Write-Host "✅ Test Pages 配置已发送" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Test Pages 配置失败: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "⏳ 验证 Pages 配置状态..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Prod
try {
    $prodStatus = Invoke-RestMethod -Uri "https://api.github.com/repos/$prodRepo/pages" `
        -Headers $headers -SkipHttpErrorCheck
    Write-Host "✅ Prod Pages:" -ForegroundColor Green
    Write-Host "   Status: $($prodStatus.status)" -ForegroundColor White
    Write-Host "   URL: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor Cyan
} catch {
    Write-Host "❓ Prod Pages 状态不可用" -ForegroundColor Yellow
}

Write-Host ""

# 检查 Test
try {
    $testStatus = Invoke-RestMethod -Uri "https://api.github.com/repos/$testRepo/pages" `
        -Headers $headers -SkipHttpErrorCheck
    Write-Host "✅ Test Pages:" -ForegroundColor Green
    Write-Host "   Status: $($testStatus.status)" -ForegroundColor White
    Write-Host "   URL: https://haujackpang.github.io/homestayERP-test" -ForegroundColor Cyan
} catch {
    Write-Host "❓ Test Pages 状态不可用" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📝 部署状态检查" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions" -ForegroundColor Cyan
Write-Host "Test Actions: https://github.com/haujackpang/homestayERP-test/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Pages 启用后，部署将在 2-3 分钟内自动完成！" -ForegroundColor Green
