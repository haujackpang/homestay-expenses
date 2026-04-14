# GitHub 自动配置脚本 - 配置所有 Secrets
# 自动为 Prod 和 Test 仓库设置 Secrets

$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\GitHub CLI"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🔧 GitHub 自动配置脚本" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 检查登录状态
Write-Host "📍 检查 GitHub 登录状态..." -ForegroundColor Yellow
$authStatus = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ GitHub CLI 未登录！" -ForegroundColor Red
    Write-Host "请先运行: gh auth login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ GitHub 已登录" -ForegroundColor Green
Write-Host ""

# Prod 仓库 配置
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 配置 Prod 仓库 (haujackpang/homestayERP-prod)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

$prodRepo = "haujackpang/homestayERP-prod"
$prodUrl = "https://skwogboredsczcyhlqgn.supabase.co"
$prodKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
$prodServiceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY"

Write-Host "设置 SUPABASE_URL..." -ForegroundColor Gray
$prodUrl | gh secret set SUPABASE_URL --repo $prodRepo
Write-Host "✅ SUPABASE_URL 已设置" -ForegroundColor Green

Write-Host "设置 SUPABASE_KEY..." -ForegroundColor Gray
$prodKey | gh secret set SUPABASE_KEY --repo $prodRepo
Write-Host "✅ SUPABASE_KEY 已设置" -ForegroundColor Green

Write-Host "设置 SUPABASE_SERVICE_KEY..." -ForegroundColor Gray
$prodServiceKey | gh secret set SUPABASE_SERVICE_KEY --repo $prodRepo
Write-Host "✅ SUPABASE_SERVICE_KEY 已设置" -ForegroundColor Green

Write-Host ""

# Test 仓库 配置
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 配置 Test 仓库 (haujackpang/homestayERP-test)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

$testRepo = "haujackpang/homestayERP-test"
$testUrl = "https://afcifzghlkxvnpulahub.supabase.co"
$testKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
$testServiceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q"

Write-Host "设置 SUPABASE_URL..." -ForegroundColor Gray
$testUrl | gh secret set SUPABASE_URL --repo $testRepo
Write-Host "✅ SUPABASE_URL 已设置" -ForegroundColor Green

Write-Host "设置 SUPABASE_KEY..." -ForegroundColor Gray
$testKey | gh secret set SUPABASE_KEY --repo $testRepo
Write-Host "✅ SUPABASE_KEY 已设置" -ForegroundColor Green

Write-Host "设置 SUPABASE_SERVICE_KEY..." -ForegroundColor Gray
$testServiceKey | gh secret set SUPABASE_SERVICE_KEY --repo $testRepo
Write-Host "✅ SUPABASE_SERVICE_KEY 已设置" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ 所有 Secrets 配置完成！" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 现在需要手动启用 GitHub Pages：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Prod 仓库：" -ForegroundColor Cyan
Write-Host "   https://github.com/haujackpang/homestayERP-prod/settings/pages" -ForegroundColor White
Write-Host "   → 选择 Source = 'GitHub Actions'" -ForegroundColor Yellow
Write-Host ""
Write-Host "2️⃣  Test 仓库：" -ForegroundColor Cyan
Write-Host "   https://github.com/haujackpang/homestayERP-test/settings/pages" -ForegroundColor White
Write-Host "   → 选择 Source = 'GitHub Actions'" -ForegroundColor Yellow
Write-Host ""
Write-Host "✨ Pages 启用后，2-3 分钟后部署将自动完成！" -ForegroundColor Green
