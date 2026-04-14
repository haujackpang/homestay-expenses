@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set PATH=%PATH%;C:\Program Files\GitHub CLI

cd /d "%TEMP%"
echo ================================================
echo Adding workflow to Prod repository using clone method
echo ================================================
echo.

REM Clone prod repo
echo Cloning Prod repository...
if exist "prod-repo" rmdir /s /q prod-repo 2>nul
gh repo clone haujackpang/homestayERP-prod prod-repo
cd prod-repo

if exist "home_expense.htm" (
    echo ✅ Cloned successfully
) else (
    echo ❌ Clone failed
    cd ..
    exit /b 1
)

echo.
echo Creating workflow directory structure...
if not exist ".github\workflows" mkdir .github\workflows

echo Copying workflow file...
copy "..\..\..\..\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml" ".github\workflows\deploy.yml"

echo.
echo Checking if files exist:
if exist ".github\workflows\deploy.yml" (
    echo ✅ Workflow file ready
) else (
    echo ❌ Workflow file not found
    exit /b 1
)

echo.
echo Adding files to git...
git add .github
git add .github/workflows
git add .github/workflows/deploy.yml

echo.
echo Checking git status...
git status --short

echo.
echo Committing...
git commit -m "Add GitHub Pages deployment workflow" 2>&1 | findstr /v "nothing to commit"

echo.
echo Pushing to Prod repository...
git push origin main

if %errorlevel% equ 0 (
    echo ✅ Prod repository updated successfully
) else (
    echo ⚠️  Push may have encountered issues
)

cd ..
echo.
echo ================================================
now doing Test repo
echo ================================================

REM Clone test repo
if exist "test-repo" rmdir /s /q test-repo 2>nul
echo.
echo Cloning Test repository...
gh repo clone haujackpang/homestayERP-test test-repo  
cd test-repo

if exist "home_expense.htm" (
    echo ✅ Cloned successfully
) else (
    echo ❌ Clone failed
    exit /b 1
)

echo.
echo Creating workflow directory structure...
if not exist ".github\workflows" mkdir .github\workflows

echo Copying workflow file...
copy "..\..\..\..\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml" ".github\workflows\deploy.yml"

echo.
echo Adding files to git...
git add .github
git add .github/workflows
git add .github/workflows/deploy.yml

echo.
echo Committing...
git commit -m "Add GitHub Pages deployment workflow" 2>&1 | findstr /v "nothing to commit"

echo.
echo Pushing to Test repository...
git push origin main

if %errorlevel% equ 0 (
    echo ✅ Test repository updated successfully
) else (
    echo ⚠️  Push may have encountered issues
)

cd ..

echo.
echo ================================================
echo Cleanup and next steps
echo ================================================

REM Cleanup
rmdir /s /q prod-repo test-repo

echo.
echo ✅ Both repositories updated with workflow file
echo.
echo.
echo Triggering deployments...
echo.

%PATH% >nul
gh workflow run deploy.yml --repo haujackpang/homestayERP-prod -b main 2>&1 | findstr /c:"Scheduled"
gh workflow run deploy.yml --repo haujackpang/homestayERP-test -b main 2>&1 | findstr /c:"Scheduled"

echo.
echo Apps will deploy within 2-3 minutes:
echo   Prod: https://haujackpang.github.io/homestayERP-prod
echo   Test: https://haujackpang.github.io/homestayERP-test
echo.
pause
