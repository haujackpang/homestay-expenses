$ErrorActionPreference = "SilentlyContinue"
$env:Path += ";C:\Program Files\GitHub CLI"
$tempDir = $env:TEMP

Write-Host "Adding deployment workflows to both repositories..." -ForegroundColor Cyan
Write-Host ""

$sourceWorkflow = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"

if (-not (Test-Path $sourceWorkflow)) {
    Write-Host "Error: Workflow file not found!" -ForegroundColor Red
    exit 1
}

$workflowContent = Get-Content $sourceWorkflow -Raw

# Process PROD
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 PROD Repository" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

$prodDir = "$tempDir\prod-repo-$(Get-Random)"
New-Item -itemType Directory -path $prodDir >$null

Push-Location
cd $prodDir

Write-Host "1. Cloning Prod repo..."
& gh repo clone haujackpang/homestayERP-prod . 2>&1 | Select-Object -First 2
Write-Host "✅ Cloned" -ForegroundColor Green

Write-Host "2. Creating workflow directory..."
New-Item -ItemType Directory -Path ".\.github\workflows" -Force >$null

Write-Host "3. Adding workflow..."
$workflowContent | Out-File -FilePath ".\.github\workflows\deploy.yml" -Encoding UTF8 -NoNewline
Write-Host "✅ Workflow added" -ForegroundColor Green

Write-Host "4. Committing..."
git add ".github"
$commitMsg = "Add GitHub Pages deployment workflow"
git commit -m $commitMsg 2>&1 | Select-Object -First 1

Write-Host "5. Pushing..."
git push origin main 2>&1 | Select-Object -First 2
Write-Host "✅ Prod pushed" -ForegroundColor Green

Pop-Location
Remove-Item -Recurse -Force $prodDir

Write-Host ""

# Process TEST
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 TEST Repository" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

$testDir = "$tempDir\test-repo-$(Get-Random)"
New-Item -itemType Directory -path $testDir >$null

Push-Location
cd $testDir

Write-Host "1. Cloning Test repo..."
& gh repo clone haujackpang/homestayERP-test . 2>&1 | Select-Object -First 2
Write-Host "✅ Cloned" -ForegroundColor Green

Write-Host "2. Creating workflow directory..."
New-Item -ItemType Directory -Path ".\.github\workflows" -Force >$null

Write-Host "3. Adding workflow..."
$workflowContent | Out-File -FilePath ".\.github\workflows\deploy.yml" -Encoding UTF8 -NoNewline
Write-Host "✅ Workflow added" -ForegroundColor Green

Write-Host "4. Committing..."
git add ".github"
git commit -m $commitMsg 2>&1 | Select-Object -First 1

Write-Host "5. Pushing..."
git push origin main 2>&1 | Select-Object -First 2
Write-Host "✅ Test pushed" -ForegroundColor Green

Pop-Location
Remove-Item -Recurse -Force $testDir

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 Triggering Deployments" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Triggering Prod workflow..."
& gh workflow run deploy.yml --repo haujackpang/homestayERP-prod -b main 2>&1 | Where-Object {$_}
Write-Host "✅ Prod triggered" -ForegroundColor Green

Write-Host ""

Write-Host "Triggering Test workflow..."
& gh workflow run deploy.yml --repo haujackpang/homestayERP-test -b main 2>&1 | Where-Object {$_}
Write-Host "✅ Test triggered" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✨ Deployment in progress!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Apps:" -ForegroundColor Cyan
Write-Host "  Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor White
Write-Host "  Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor White
Write-Host ""
Write-Host "Status:" -ForegroundColor Cyan
Write-Host "  Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions" -ForegroundColor White
Write-Host "  Test Actions: https://github.com/haujackpang/homestayERP-test/actions" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Waiting... (refresh pages in 2-3 minutes)" -ForegroundColor Yellow
