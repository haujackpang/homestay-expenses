#!/usr/bin/env pwsh
# ==========================================
# Home Expense - Interactive Setup Wizard
# ==========================================

Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Home Expense - GitHub Setup Wizard   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Explain what we're doing
Write-Host "📋 This wizard will configure your GitHub repositories for deployment." -ForegroundColor Yellow
Write-Host ""
Write-Host "Tasks to perform:" -ForegroundColor Cyan
Write-Host "  1. Configure 3 secrets for Prod repository (homestayERP-prod)"
Write-Host "  2. Configure 3 secrets for Test repository (homestayERP-test)"
Write-Host "  3. Enable GitHub Pages for both repositories"
Write-Host ""
Write-Host "Total time: ~5 minutes" -ForegroundColor Green
Write-Host ""

# Step 2: Check if token exists
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 1: GitHub Authentication" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "You need a GitHub Personal Access Token to proceed." -ForegroundColor Yellow
Write-Host ""
Write-Host "Don't have one? Generate it here:" -ForegroundColor Yellow
Write-Host "  🔗 https://github.com/settings/tokens/new?scopes=repo,workflow" -ForegroundColor Cyan
Write-Host ""
Write-Host "Token permissions required:" -ForegroundColor Green
Write-Host "  ✅ repo (full repository access)"
Write-Host "  ✅ workflow (GitHub Actions)"
Write-Host ""

$token = Read-Host "Paste your GitHub token here (or press Enter to skip)"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host ""
    Write-Host "❌ No token provided. Setup cannot continue." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try again with a valid GitHub token." -ForegroundColor Yellow
    exit 1
}

# Step 3: Validate token
Write-Host ""
Write-Host "Validating token..." -ForegroundColor Cyan

try {
    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $user = Invoke-RestMethod -Uri "https://api.github.com/user" -Method Get -Headers $headers -TimeoutSec 10
    
    Write-Host "✅ Token valid! Authenticated as: $($user.login)" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "❌ Token validation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  - Token is correct (copy-paste carefully)"
    Write-Host "  - Token has not expired"
    Write-Host "  - Token has required permissions"
    exit 1
}

# Step 4: Prepare secrets
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 2: Preparing Configuration" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$prodSecrets = @{
    "SUPABASE_URL" = "https://skwogboredsczcyhlqgn.supabase.co"
    "SUPABASE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
    "SUPABASE_SERVICE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY"
}

$testSecrets = @{
    "SUPABASE_URL" = "https://afcifzghlkxvnpulahub.supabase.co"
    "SUPABASE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
    "SUPABASE_SERVICE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q"
}

Write-Host "Prod Repository Secrets:" -ForegroundColor Cyan
foreach ($secret in $prodSecrets.Keys) {
    Write-Host "  📌 $secret"
}

Write-Host ""
Write-Host "Test Repository Secrets:" -ForegroundColor Cyan
foreach ($secret in $testSecrets.Keys) {
    Write-Host "  📌 $secret"
}

Write-Host ""

# Step 5: Configure via GitHub Web UI (since API requires complex encryption)
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 3: Manual Configuration (Web UI)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Due to GitHub's encryption requirements, secrets must be set via web UI." -ForegroundColor Yellow
Write-Host ""

# Generate quick-copy snippets
Write-Host "PROD Repository Configuration:" -ForegroundColor Green
Write-Host "  🔗 Settings: https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Copy & Paste these into 'New repository secret':" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Name:  SUPABASE_URL"
Write-Host "    Value: https://skwogboredsczcyhlqgn.supabase.co"
Write-Host ""
Write-Host "    Name:  SUPABASE_KEY"
Write-Host "    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
Write-Host "           (see GITHUB_SECRETS_CONFIG.md for full value)"
Write-Host ""
Write-Host "    Name:  SUPABASE_SERVICE_KEY"
Write-Host "    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
Write-Host "           (prod service key)"
Write-Host ""

Write-Host "TEST Repository Configuration:" -ForegroundColor Green
Write-Host "  🔗 Settings: https://github.com/haujackpang/homestayERP-test/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Copy & Paste same process with test values:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Name:  SUPABASE_URL"
Write-Host "    Value: https://afcifzghlkxvnpulahub.supabase.co"
Write-Host ""

Write-Host ""
Write-Host "💡 Tip: Open both URLs in separate tabs for easier configuration" -ForegroundColor Cyan
Write-Host ""

# Verify completion
$continueSetup = Read-Host "Have you configured all 6 secrets in GitHub? (yes/no)"

if ($continueSetup -ne "yes" -and $continueSetup -ne "y") {
    Write-Host ""
    Write-Host "⏸️  Setup paused. Complete the GitHub configuration and run this script again." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Great! Continuing with Pages setup..." -ForegroundColor Green
Write-Host ""

# Step 6: Enable Pages
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 4: Enable GitHub Pages" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Now enabling GitHub Pages for both repositories..." -ForegroundColor Cyan
Write-Host ""

$pagesUrls = @(
    "https://github.com/haujackpang/homestayERP-prod/settings/pages",
    "https://github.com/haujackpang/homestayERP-test/settings/pages"
)

Write-Host "For each repository:" -ForegroundColor Yellow
Write-Host "  1. Go to: Settings → Pages"
Write-Host "  2. Under 'Source' select: GitHub Actions"
Write-Host "  3. Click Save"
Write-Host ""

Write-Host "PROD Pages: https://github.com/haujackpang/homestayERP-prod/settings/pages" -ForegroundColor Cyan
Write-Host "TEST Pages: https://github.com/haujackpang/homestayERP-test/settings/pages" -ForegroundColor Cyan
Write-Host ""

$pagesComplete = Read-Host "Have you enabled Pages for both repositories? (yes/no)"

if ($pagesComplete -ne "yes" -and $pagesComplete -ne "y") {
    Write-Host ""
    Write-Host "⏸️  Please complete the Pages setup and run this script again." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Step 7: Summary and next steps
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 5: Deployment Monitoring" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ All configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your deployments should now be triggered. Here's what happens next:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. GitHub automatically runs the deployment workflow"
Write-Host "  2. Wait 2-3 minutes for completion"
Write-Host "  3. Check status:" -ForegroundColor Green
Write-Host "     - Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions"
Write-Host "     - Test Actions: https://github.com/haujackpang/homestayERP-test/actions"
Write-Host ""
Write-Host "  4. Once complete, access your apps:" -ForegroundColor Green
Write-Host "     - Prod: https://haujackpang.github.io/homestayERP-prod"
Write-Host "     - Test: https://haujackpang.github.io/homestayERP-test"
Write-Host ""

Write-Host "Waiting for Actions workflow to complete..." -ForegroundColor Yellow
Write-Host ""

# Run deployment monitor
$runMonitor = Read-Host "Run deployment monitor now? (yes/no)"

if ($runMonitor -eq "yes" -or $runMonitor -eq "y") {
    Write-Host ""
    Write-Host "Starting monitor..." -ForegroundColor Cyan
    Write-Host ""
    
    & powershell -ExecutionPolicy Bypass -File "c:\Users\localad\Desktop\homestay-expenses\monitor-deployment.ps1" -Watch
} else {
    Write-Host ""
    Write-Host "You can manually run the monitor later:" -ForegroundColor Cyan
    Write-Host "  powershell -ExecutionPolicy Bypass -File 'c:\Users\localad\Desktop\homestay-expenses\monitor-deployment.ps1' -Watch"
    Write-Host ""
}

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        Setup Complete! 🎉             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
