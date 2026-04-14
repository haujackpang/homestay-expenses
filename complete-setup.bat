@echo off
REM ==========================================
REM Home Expense - Manual Configuration Guide
REM ==========================================

setlocal enabledelayedexpansion

cls
echo.
echo ╔════════════════════════════════════════╗
echo ║   Home Expense - Configuration Guide   ║
echo ╚════════════════════════════════════════╝
echo.

echo This script will guide you through:
echo   1. Configuring GitHub Secrets
echo   2. Enabling GitHub Pages
echo   3. Monitoring deployment
echo.

echo Press any key to continue...
pause >nul

cls
echo ════════════════════════════════════════
echo Step 1: PROD Repository Configuration
echo ════════════════════════════════════════
echo.
echo Open this URL in your browser:
echo.
echo https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions
echo.

echo Add these 3 secrets (click "New repository secret" 3 times):
echo.
echo 1. Name: SUPABASE_URL
echo    Value: https://skwogboredsczcyhlqgn.supabase.co
echo.
echo 2. Name: SUPABASE_KEY
echo    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0
echo.
echo 3. Name: SUPABASE_SERVICE_KEY
echo    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY
echo.

start "" "https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions"

echo Press any key when you have added all 3 secrets to PROD...
pause >nul

cls
echo ════════════════════════════════════════
echo Step 2: TEST Repository Configuration
echo ════════════════════════════════════════
echo.
echo Open this URL in your browser:
echo.
echo https://github.com/haujackpang/homestayERP-test/settings/secrets/actions
echo.

echo Add these 3 secrets (click "New repository secret" 3 times):
echo.
echo 1. Name: SUPABASE_URL
echo    Value: https://afcifzghlkxvnpulahub.supabase.co
echo.
echo 2. Name: SUPABASE_KEY
echo    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0
echo.
echo 3. Name: SUPABASE_SERVICE_KEY
echo    Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q
echo.

start "" "https://github.com/haujackpang/homestayERP-test/settings/secrets/actions"

echo Press any key when you have added all 3 secrets to TEST...
pause >nul

cls
echo ════════════════════════════════════════
echo Step 3: Enable GitHub Pages (PROD)
echo ════════════════════════════════════════
echo.
echo Open this URL:
echo.
echo https://github.com/haujackpang/homestayERP-prod/settings/pages
echo.

echo Steps:
echo   1. Find "Source" dropdown
echo   2. Select "GitHub Actions"
echo   3. Click "Save"
echo.

start "" "https://github.com/haujackpang/homestayERP-prod/settings/pages"

echo Press any key when done...
pause >nul

cls
echo ════════════════════════════════════════
echo Step 4: Enable GitHub Pages (TEST)
echo ════════════════════════════════════════
echo.
echo Open this URL:
echo.
echo https://github.com/haujackpang/homestayERP-test/settings/pages
echo.

echo Steps:
echo   1. Find "Source" dropdown
echo   2. Select "GitHub Actions"
echo   3. Click "Save"
echo.

start "" "https://github.com/haujackpang/homestayERP-test/settings/pages"

echo Press any key when done...
pause >nul

cls
echo ════════════════════════════════════════
echo Step 5: Verify Deployment Status
echo ════════════════════════════════════════
echo.
echo Your deployments are now running! Check status:
echo.
echo Prod Actions:
echo   https://github.com/haujackpang/homestayERP-prod/actions
echo.
echo Test Actions:
echo   https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Expected status: Workflow should show as "running" then turn green (✓)
echo Typical wait time: 2-3 minutes
echo.

start "" "https://github.com/haujackpang/homestayERP-prod/actions"
start "" "https://github.com/haujackpang/homestayERP-test/actions"

timeout /t 5 /nobreak

cls
echo ════════════════════════════════════════
echo ✅ Configuration Summary
echo ════════════════════════════════════════
echo.
echo Actions completed:
echo   ✓ Prod Repository: 3 secrets + Pages enabled
echo   ✓ Test Repository: 3 secrets + Pages enabled
echo   ✓ Deployments triggered automatically
echo.
echo Next step: Wait for deployment to complete (2-3 minutes)
echo.
echo Once complete, access your applications:
echo.
echo   📱 Prod: https://haujackpang.github.io/homestayERP-prod
echo   🧪 Test: https://haujackpang.github.io/homestayERP-test
echo.
echo If you see the Home Expense form, deployment succeeded! 🎉
echo.
echo ════════════════════════════════════════
echo.

pause
