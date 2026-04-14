@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Enabling GitHub Pages with GitHub CLI
echo ================================================
echo.

REM 获取 token
for /f "tokens=*" %%i in ('gh auth token 2^>nul') do set "TOKEN=%%i"

if "!TOKEN!"=="" (
    echo Error: Cannot get GitHub token
    pause
    exit /b 1
)

echo Token acquired. Configuring Pages...
echo.

REM Prod Repository
echo Setting up Prod Pages...
curl -s -X POST ^
  -H "Authorization: token !TOKEN!" ^
  -H "Accept: application/vnd.github+json" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  https://api.github.com/repos/haujackpang/homestayERP-prod/pages ^
  -d "{\"build_type\":\"workflow\"}" >nul 2>&1

echo.

REM Test Repository  
echo Setting up Test Pages...
curl -s -X POST ^
  -H "Authorization: token !TOKEN!" ^
  -H "Accept: application/vnd.github+json" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  https://api.github.com/repos/haujackpang/homestayERP-test/pages ^
  -d "{\"build_type\":\"workflow\"}" >nul 2>&1

echo.
echo ================================================
echo Checking status...
echo ================================================
echo.

REM Check Prod status
for /f "tokens=*" %%i in ('curl -s -H "Authorization: token !TOKEN!" https://api.github.com/repos/haujackpang/homestayERP-prod/pages') do (
    echo Prod: %%i
)

echo.

REM Check Test status
for /f "tokens=*" %%i in ('curl -s -H "Authorization: token !TOKEN!" https://api.github.com/repos/haujackpang/homestayERP-test/pages') do (
    echo Test: %%i
)

echo.
echo ================================================
echo Deployment URLs:
echo ================================================
echo.
echo Prod: https://haujackpang.github.io/homestayERP-prod
echo Test: https://haujackpang.github.io/homestayERP-test
echo.
echo Actions status:
echo   Prod: https://github.com/haujackpang/homestayERP-prod/actions
echo   Test: https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Waiting 3 minutes for deployment... (you can check the Actions page meanwhile)
echo.
pause
