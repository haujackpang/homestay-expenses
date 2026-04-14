@echo off
setlocal enabledelayedexpansion
set PATH=%PATH%;C:\Program Files\GitHub CLI

echo ================================================
echo Monitoring Deployment Progress
echo ================================================
echo.

set count=0

:check_loop
cls
echo ================================================
echo Deployment Monitor
echo ================================================
echo Time: %date% %time%
echo Count: %count%
echo.

echo.
echo === TEST STATUS ===
gh run list --repo haujackpang/homestayERP-test --limit 1 --json status,conclusion,name 2>&1
echo.

echo.
echo === PROD STATUS ===  
gh run list --repo haujackpang/homestayERP-prod --limit 1 --json status,conclusion,name 2>&1
echo.

echo Checking app accessibility...
echo.

echo Testing Prod app...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://haujackpang.github.io/homestayERP-prod' -TimeoutSec 3; Write-Host 'Prod Status: '$r.StatusCode -ForegroundColor Green } catch { Write-Host 'Prod: Not yet...' }"

echo.

echo Testing Test app...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://haujackpang.github.io/homestayERP-test' -TimeoutSec 3; Write-Host 'Test Status: '$r.StatusCode -ForegroundColor Green } catch { Write-Host 'Test: Not yet...' }"

echo.
echo Wait 10 seconds...

timeout /t 10

set /a count+=1

if %count% lss 20 goto check_loop

echo.
echo ================================================
echo Timeout reached. Check status manually:
echo ================================================
echo.
echo Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions
echo Test Actions: https://github.com/haujackpang/homestayERP-test/actions
echo.
echo Apps:
echo Prod: https://haujackpang.github.io/homestayERP-prod
echo Test: https://haujackpang.github.io/homestayERP-test
echo.
pause
