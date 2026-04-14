@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Fixing GitHub Pages Deployment
echo ================================================
echo.

REM Check current remotes
echo Current git remotes:
git remote -v
echo.

REM Add/Update remotes if needed
echo Setting up remotes...
git remote remove origin-prod 2>nul
git remote remove origin-test 2>nul

git remote add origin-prod https://github.com/haujackpang/homestayERP-prod.git 2>nul
git remote add origin-test https://github.com/haujackpang/homestayERP-test.git 2>nul

echo Remotes setup complete.
echo.

REM Check if deploy.yml needs to be committed
if not exist ".github\workflows\deploy.yml" (
    echo Error: deploy.yml not found!
    pause
    exit /b 1
)

echo ================================================
echo Checking git status...
echo ================================================
git status
echo.

REM Add and commit workflow file
git add .github/workflows/deploy.yml 2>nul
git add home_expense.htm 2>nul

for /f "tokens=*" %%i in ('git status --short') do (
    if not "%%i"=="" (
        echo Found changes: %%i
        set HAS_CHANGES=1
    )
)

if "!HAS_CHANGES!"=="1" (
    echo.
    echo Committing changes...
    git commit -m "Fix: Ensure deploy.yml exists for Pages build" 2>nul
    echo ✅ Changes committed
) else (
    echo No changes to commit
)

echo.
echo ================================================
echo Pushing to both repositories...
echo ================================================
echo.

REM Push to Prod
echo Pushing to Prod (origin-prod)...
git push origin-prod main 2>nul
if !errorlevel! equ 0 (
    echo ✅ Prod pushed successfully
) else (
    echo ⚠️  Prod push may have failed (might already be up to date)
)

echo.

REM Push to Test  
echo Pushing to Test (origin-test)...
git push origin-test main 2>nul
if !errorlevel! equ 0 (
    echo ✅ Test pushed successfully
) else (
    echo ⚠️  Test push may have failed (might already be up to date)
)

echo.
echo ================================================
echo Triggering manual workflow runs...
echo ================================================
echo.

REM Manual trigger for Prod
echo Triggering Prod deployment...
gh workflow run deploy.yml --repo haujackpang/homestayERP-prod -b main 2>nul
if !errorlevel! equ 0 (
    echo ✅ Prod workflow triggered
) else (
    echo ⚠️  Could not trigger Prod workflow
)

echo.

REM Manual trigger for Test
echo Triggering Test deployment...
gh workflow run deploy.yml --repo haujackpang/homestayERP-test -b main 2>nul
if !errorlevel! equ 0 (
    echo ✅ Test workflow triggered
) else (
    echo ⚠️  Could not trigger Test workflow
)

echo.
echo ================================================
echo Checking workflow status...
echo ================================================
echo.

echo Prod recent runs:
gh run list --repo haujackpang/homestayERP-prod --limit 3 --json status,conclusion,name 2>nul

echo.

echo Test recent runs:
gh run list --repo haujackpang/homestayERP-test --limit 3 --json status,conclusion,name 2>nul

echo.
echo ================================================
echo Please wait 1-2 minutes for deployment...
echo Check status at:
echo   Prod: https://github.com/haujackpang/homestayERP-prod/actions
echo   Test: https://github.com/haujackpang/homestayERP-test/actions
echo ================================================
echo.
pause
