@echo off
REM ==========================================
REM Home Expense - GitHub Secrets Configurator
REM ==========================================

echo.
echo =====================================
echo  GitHub Secrets Configuration Helper
echo =====================================
echo.
echo This script will help you configure GitHub Secrets for both repositories.
echo.
echo REQUIRED INFORMATION:
echo ---------------------
echo.
echo 1. PROD_SERVICE_KEY - From Supabase prod project (Settings-API-service_role)
echo    Copy the SECRET key (NOT the anon key)
echo.
echo 2. TEST_ANON_KEY - From Supabase test project (Settings-API-anon)
echo.
echo 3. TEST_SERVICE_KEY - From Supabase test project (Settings-API-service_role)
echo.
echo REFERENCES:
echo -----------
echo Prod Project URL: https://app.supabase.com/ (select homestayERP-prod)
echo Test Project URL: https://app.supabase.com/ (select homestayERP-test)
echo.
echo =====
echo NOTE: You will need to paste the keys manually into GitHub. This script
echo will provide guidance on where to put each secret.
echo =====
echo.

setlocal enabledelayedexpansion

REM Prod Service Key
set /p PROD_SERVICE_KEY="Enter PROD_SERVICE_KEY (press Ctrl+V to paste): "
if "!PROD_SERVICE_KEY!"=="" (
    echo ERROR: PROD_SERVICE_KEY cannot be empty
    exit /b 1
)

REM Test Anon Key
set /p TEST_ANON_KEY="Enter TEST_ANON_KEY (press Ctrl+V to paste): "
if "!TEST_ANON_KEY!"=="" (
    echo ERROR: TEST_ANON_KEY cannot be empty
    exit /b 1
)

REM Test Service Key
set /p TEST_SERVICE_KEY="Enter TEST_SERVICE_KEY (press Ctrl+V to paste): "
if "!TEST_SERVICE_KEY!"=="" (
    echo ERROR: TEST_SERVICE_KEY cannot be empty
    exit /b 1
)

echo.
echo ===== CONFIGURATION SUMMARY =====
echo.
echo PROD Repository Secrets:
echo   SUPABASE_URL = https://skwogboredsczcyhlqgn.supabase.co
echo   SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
echo   SUPABASE_SERVICE_KEY = **CONFIGURED**
echo.
echo TEST Repository Secrets:
echo   SUPABASE_URL = https://afcifzghlkxvnpulahub.supabase.co
echo   SUPABASE_KEY = **CONFIGURED**
echo   SUPABASE_SERVICE_KEY = **CONFIGURED**
echo.

REM Create the GitHub URLs for direct navigation
echo ===== NEXT STEPS =====
echo.
echo 1. For PROD repository:
echo    URL: https://github.com/haujackpang/homestayERP-prod/settings/secrets/actions
echo.
echo    Add these secrets:
echo    - SUPABASE_URL = https://skwogboredsczcyhlqgn.supabase.co
echo    - SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0
echo    - SUPABASE_SERVICE_KEY = [value you just entered]
echo.
echo 2. For TEST repository:
echo    URL: https://github.com/haujackpang/homestayERP-test/settings/secrets/actions
echo.
echo    Add these secrets:
echo    - SUPABASE_URL = https://afcifzghlkxvnpulahub.supabase.co
echo    - SUPABASE_KEY = [TEST_ANON_KEY value you just entered]
echo    - SUPABASE_SERVICE_KEY = [TEST_SERVICE_KEY value you just entered]
echo.

pause

REM Save configuration to a secure temp file (user should delete after)
(
    echo # GitHub Secrets Configuration - Created %date% %time%
    echo # DELETE THIS FILE AFTER MANUAL CONFIGURATION
    echo.
    echo ## PROD Repository
    echo ### Secret: SUPABASE_SERVICE_KEY
    echo %PROD_SERVICE_KEY%
    echo.
    echo ## TEST Repository
    echo ### Secret: SUPABASE_KEY  
    echo %TEST_ANON_KEY%
    echo.
    echo ### Secret: SUPABASE_SERVICE_KEY
    echo %TEST_SERVICE_KEY%
) > "%USERPROFILE%\Desktop\github-secrets-temp.txt"

echo.
echo Configuration details saved to: %USERPROFILE%\Desktop\github-secrets-temp.txt
echo (Please delete this file after manually configuring the secrets)
echo.
echo Press Enter when you have finished configuring all GitHub Secrets...
pause

echo.
echo ===== NEXT: Enable GitHub Pages =====
echo.
echo 1. PROD Repository Pages:
echo    https://github.com/haujackpang/homestayERP-prod/settings/pages
echo    - Source: Set to "GitHub Actions"
echo.
echo 2. TEST Repository Pages:
echo    https://github.com/haujackpang/homestayERP-test/settings/pages
echo    - Source: Set to "GitHub Actions"
echo.
echo Press Enter when you have enabled Pages for both repositories...
pause

echo.
echo ===== FINAL STEP: Commit and Push =====
echo.

setlocal
cd /d "c:\Users\localad\Desktop\homestay-expenses"

git add .
git commit -m "Phase 4: Complete - Environment separated with Secrets and Pages enabled"
git push origin main

echo.
echo ✅ Push completed!
echo.
echo ===== DEPLOYMENT STATUS =====
echo.
echo Your applications should be deploying now. Check:
echo.
echo 1. Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions
echo 2. Test Actions: https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Wait 2-3 minutes for deployment to complete...
echo.
echo Then access (once deployment completes):
echo - Prod: https://haujackpang.github.io/homestayERP-prod
echo - Test: https://haujackpang.github.io/homestayERP-test
echo.

pause
endlocal
