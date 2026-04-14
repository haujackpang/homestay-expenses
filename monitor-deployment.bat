@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Monitoring Deployment Progress
echo ================================================
echo.

:loop
echo Time: %date% %time%
echo.

echo Checking Prod deployment...
for /f "tokens=*" %%i in ('gh run list --repo haujackpang/homestayERP-prod --limit 1 --json status,conclusion 2^>nul') do (
    echo  %%i
)

echo.

echo Checking Test deployment...
for /f "tokens=*" %%i in ('gh run list --repo haujackpang/homestayERP-test --limit 1 --json status,conclusion 2^>nul') do (
    echo  %%i
)

echo.
echo Checking app accessibility...
echo.

echo Prod app: https://haujackpang.github.io/homestayERP-prod
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://haujackpang.github.io/homestayERP-prod' -TimeoutSec 5; Write-Host '  Status: ' $r.StatusCode -ForegroundColor Green } catch { Write-Host '  Checking...' -ForegroundColor Yellow }"

echo.

echo Test app: https://haujackpang.github.io/homestayERP-test
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://haujackpang.github.io/homestayERP-test' -TimeoutSec 5; Write-Host '  Status: ' $r.StatusCode -ForegroundColor Green } catch { Write-Host '  Checking...' -ForegroundColor Yellow }"

echo.
echo ================================================
echo Actions URLs:
echo   Prod: https://github.com/haujackpang/homestayERP-prod/actions
echo   Test: https://github.com/haujackpang/homestayERP-test/actions
echo ================================================
echo.

timeout /t 5
cls
goto loop
