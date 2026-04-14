@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Enabling GitHub Pages...
echo ================================================
echo.

REM Prod Repository
echo.
echo 📦 Prod Repository: haujackpang/homestayERP-prod
echo Checking if Pages can be configured...
echo.

REM Check if repo exists and user has permission
gh repo view haujackpang/homestayERP-prod >nul 2>&1
if errorlevel 1 (
    echo ❌ Cannot access Prod repo. Please verify permissions.
    pause
    exit /b 1
)
echo ✅ Prod repo accessible

REM Try to enable Pages using GitHub API
echo.
echo Attempting to enable Pages for Prod...
curl -L ^
  -X POST ^
  -H "Accept: application/vnd.github+json" ^
  -H "Authorization: token %GH_TOKEN%" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  https://api.github.com/repos/haujackpang/homestayERP-prod/pages ^
  -d "{\"source\":{\"branch\":\"gh-pages\",\"path\":\"/\"}}" 2>nul

if %errorlevel% equ 0 (
    echo ✅ Pages enabled for Prod (or already enabled)
) else (
    echo ⚠️  Could not configure via API. Will use web interface.
)

echo.
echo ================================================
echo 📦 Test Repository: haujackpang/homestayERP-test
echo.

REM Check if repo exists and user has permission
gh repo view haujackpang/homestayERP-test >nul 2>&1
if errorlevel 1 (
    echo ❌ Cannot access Test repo. Please verify permissions.
    pause
    exit /b 1
)
echo ✅ Test repo accessible

REM Try to enable Pages using GitHub API
echo.
echo Attempting to enable Pages for Test...
curl -L ^
  -X POST ^
  -H "Accept: application/vnd.github+json" ^
  -H "Authorization: token %GH_TOKEN%" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  https://api.github.com/repos/haujackpang/homestayERP-test/pages ^
  -d "{\"source\":{\"branch\":\"gh-pages\",\"path\":\"/\"}}" 2>nul

if %errorlevel% equ 0 (
    echo ✅ Pages enabled for Test (or already enabled)
) else (
    echo ⚠️  Could not configure via API. Will use web interface.
)

echo.
echo ================================================
echo Alternative: Manual Web Configuration
echo ================================================
echo.
echo If the above did not work, please manually enable Pages:
echo.
echo 1. Prod Pages:
echo    https://github.com/haujackpang/homestayERP-prod/settings/pages
echo    Select Source = "GitHub Actions"
echo.
echo 2. Test Pages:
echo    https://github.com/haujackpang/homestayERP-test/settings/pages
echo    Select Source = "GitHub Actions"
echo.
pause
