$env:Path += ";C:\Program Files\GitHub CLI"
$tempDir = $env:TEMP

Write-Host "Cloning and updating both repos with workflow..." -ForegroundColor Cyan
Write-Host ""

$sourceWorkflow = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"
$workflowContent = Get-Content $sourceWorkflow -Raw

# PROD
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 Prod: haujackpang/homestayERP-prod" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$prodDir = "$tempDir\prod-update-$(Get-Random)"
New-Item -ItemType Directory -path $prodDir > $null

Push-Location
cd $prodDir

Write-Host "Cloning..."
gh repo clone haujackpang/homestayERP-prod . 2>&1 | Select-Object -First 1
if (-not (Test-Path "home_expense.htm")) {
    Write-Host "❌ Clone failed or wrong repo" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✅ Cloned successfully" -ForegroundColor Green
Write-Host ""

New-Item -ItemType Directory ".\.github\workflows" -Force > $null
$workflowContent | Out-File ".\.github\workflows\deploy.yml" -Encoding UTF8 -NoNewline

Write-Host "Committing..."
git add ".github"
git commit -m "Add GitHub Pages deployment workflow" 2>&1 | Select-Object -First 1

Write-Host "Pushing..."
git push 2>&1 | Select-Object -First 2
Write-Host "✅ Prod pushed" -ForegroundColor Green

Pop-Location
Remove-Item -Recurse -Force $prodDir

Write-Host ""

# TEST
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📦 Test: haujackpang/homestayERP-test" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$testDir = "$tempDir\test-update-$(Get-Random)"
New-Item -ItemType Directory -path $testDir > $null

Push-Location
cd $testDir

Write-Host "Cloning..."
gh repo clone haujackpang/homestayERP-test . 2>&1 | Select-Object -First 1
if (-not (Test-Path "home_expense.htm")) {
    Write-Host "❌ Clone failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✅ Cloned successfully" -ForegroundColor Green
Write-Host ""

New-Item -ItemType Directory ".\.github\workflows" -Force > $null
$workflowContent | Out-File ".\.github\workflows\deploy.yml" -Encoding UTF8 -NoNewline

Write-Host "Committing..."
git add ".github"
git commit -m "Update GitHub Pages deployment workflow" 2>&1 | Select-Object -First 1

Write-Host "Pushing..."
git push 2>&1 | Select-Object -First 2
Write-Host "✅ Test pushed" -ForegroundColor Green

Pop-Location
Remove-Item -Recurse -Force $testDir

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✨ Workflow files deployed!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor White
Write-Host "✅ Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor White
Write-Host ""
Write-Host "Apps will be live in 2-3 minutes!" -ForegroundColor Yellow
