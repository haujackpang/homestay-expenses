@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Configuring GitHub Secrets...
echo ================================================
echo.

REM Check if logged in
gh auth status >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI is not authenticated.
    echo Please run: gh auth login
    echo.
    pause
    exit /b 1
)

echo Prod Repository: haujackpang/homestayERP-prod
echo.

echo Setting SUPABASE_URL for Prod...
echo https://skwogboredsczcyhlqgn.supabase.co | gh secret set SUPABASE_URL --repo haujackpang/homestayERP-prod
if %errorlevel% equ 0 (echo [OK] SUPABASE_URL) else (echo [SKIP] SUPABASE_URL already exists)

echo Setting SUPABASE_KEY for Prod...
echo eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0 | gh secret set SUPABASE_KEY --repo haujackpang/homestayERP-prod
if %errorlevel% equ 0 (echo [OK] SUPABASE_KEY) else (echo [SKIP] SUPABASE_KEY already exists)

echo Setting SUPABASE_SERVICE_KEY for Prod...
echo eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY | gh secret set SUPABASE_SERVICE_KEY --repo haujackpang/homestayERP-prod
if %errorlevel% equ 0 (echo [OK] SUPABASE_SERVICE_KEY) else (echo [SKIP] SUPABASE_SERVICE_KEY already exists)

echo.
echo ================================================
echo Test Repository: haujackpang/homestayERP-test
echo.

echo Setting SUPABASE_URL for Test...
echo https://afcifzghlkxvnpulahub.supabase.co | gh secret set SUPABASE_URL --repo haujackpang/homestayERP-test
if %errorlevel% equ 0 (echo [OK] SUPABASE_URL) else (echo [SKIP] SUPABASE_URL already exists)

echo Setting SUPABASE_KEY for Test...
echo eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0 | gh secret set SUPABASE_KEY --repo haujackpang/homestayERP-test
if %errorlevel% equ 0 (echo [OK] SUPABASE_KEY) else (echo [SKIP] SUPABASE_KEY already exists)

echo Setting SUPABASE_SERVICE_KEY for Test...
echo eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q | gh secret set SUPABASE_SERVICE_KEY --repo haujackpang/homestayERP-test
if %errorlevel% equ 0 (echo [OK] SUPABASE_SERVICE_KEY) else (echo [SKIP] SUPABASE_SERVICE_KEY already exists)

echo.
echo ================================================
echo All Secrets Configured!
echo ================================================
echo.
echo Next: Enable GitHub Pages
echo.
echo 1. Prod: https://github.com/haujackpang/homestayERP-prod/settings/pages
echo    Select Source = "GitHub Actions"
echo.
echo 2. Test: https://github.com/haujackpang/homestayERP-test/settings/pages
echo    Select Source = "GitHub Actions"
echo.
echo Press any key to open links...
pause >nul

start https://github.com/haujackpang/homestayERP-prod/settings/pages
start https://github.com/haujackpang/homestayERP-test/settings/pages

echo.
echo Waiting 10 seconds before continuing...
timeout /t 10

echo.
echo Both Pages should now be enabled.
echo Deployment will start automatically!
echo.
echo Check status:
echo   Prod: https://github.com/haujackpang/homestayERP-prod/actions
echo   Test: https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Apps will be live at:
echo   Prod: https://haujackpang.github.io/homestayERP-prod
echo   Test: https://haujackpang.github.io/homestayERP-test
echo.
pause
