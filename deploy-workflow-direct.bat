@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Creating Deploy Workflow in GitHub Repositories
echo ================================================
echo.

REM Read the workflow content
set "WORKFLOW_FILE=.github\workflows\deploy.yml"
if not exist "!WORKFLOW_FILE!" (
    echo Error: Workflow file not found!
    pause
    exit /b 1
)

REM Create temporary file with workflow content
echo Creating workflow file in both repositories...
echo.

REM Create in Prod repo using GitHub API
echo 1. Creating/updating in Prod repository...
echo    https://github.com/haujackpang/homestayERP-prod

REM Simply push to prod repo
git push https://haujackpang:^!ghp_YOUR_TOKEN_HERE@github.com/haujackpang/homestayERP-prod.git main 2>nul

if !errorlevel! neq 0 (
    echo Trying alternative method for Prod...
    gh repo clone haujackpang/homestayERP-prod temp-prod 2>nul
    if exist "temp-prod" (
        echo ✅ Cloned Prod repo
        
        REM Copy workflow
        mkdir temp-prod\.github\workflows 2>nul
        copy "!WORKFLOW_FILE!" "temp-prod\.github\workflows\deploy.yml" >nul
        copy "home_expense.htm" "temp-prod\home_expense.htm" >nul
        
        cd temp-prod
        git add .github\workflows\deploy.yml
        git add home_expense.htm
        git commit -m "Add/update deploy workflow" 2>nul
        git push 2>nul
        cd ..
        
        rmdir /s /q temp-prod 2>nul
        echo ✅ Prod repo updated
    )
)

echo.

REM Create in Test repo
echo 2. Creating/updating in Test repository...
echo    https://github.com/haujackpang/homestayERP-test

gh repo clone haujackpang/homestayERP-test temp-test 2>nul
if exist "temp-test" (
    echo ✅ Cloned Test repo
    
    REM Copy workflow
    mkdir temp-test\.github\workflows 2>nul
    copy "!WORKFLOW_FILE!" "temp-test\.github\workflows\deploy.yml" >nul
    copy "home_expense.htm" "temp-test\home_expense.htm" >nul
    
    cd temp-test
    git add .github\workflows\deploy.yml
    git add home_expense.htm
    git commit -m "Add/update deploy workflow" 2>nul
    git push 2>nul
    cd ..
    
    rmdir /s /q temp-test 2>nul
    echo ✅ Test repo updated
)

echo.
echo ================================================
echo Workflow files created/updated!
echo ================================================
echo.

timeout /t 3
echo.
echo Now triggering manual workflow runs...
echo.

REM Trigger Prod
echo Triggering Prod...
gh workflow run deploy.yml --repo haujackpang/homestayERP-prod -b main 2>&1 | find /v "Scheduled"
echo.

REM Trigger Test
echo Triggering Test...
gh workflow run deploy.yml --repo haujackpang/homestayERP-test -b main 2>&1 | find /v "Scheduled"
echo.

echo ================================================
echo Workflow execution initiated!
echo ================================================
echo.
echo Check deployment status:
echo   Prod: https://github.com/haujackpang/homestayERP-prod/actions
echo   Test: https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Apps will be available at:
echo   Prod: https://haujackpang.github.io/homestayERP-prod
echo   Test: https://haujackpang.github.io/homestayERP-test
echo.
echo (Waiting 2-3 minutes for deployment...)
echo.
pause
