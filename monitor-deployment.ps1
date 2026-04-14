#!/usr/bin/env pwsh
# ==========================================
# Home Expense - Deployment Monitor
# Check GitHub Actions deployment status
# ==========================================

param(
    [switch]$Watch = $false
)

$ErrorActionPreference = "Continue"
$WarningPreference = "SilentlyContinue"

function Get-DeploymentStatus {
    param(
        [string]$Repo,
        [string]$Owner = "haujackpang"
    )
    
    Write-Host "Checking: $Owner/$Repo" -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/actions/runs?per_page=1" `
            -Method Get `
            -Headers @{"Accept" = "application/vnd.github.v3+json"} `
            -ErrorAction Stop
        
        if ($response.workflow_runs -and $response.workflow_runs.Count -gt 0) {
            $run = $response.workflow_runs[0]
            $status = $run.status
            $conclusion = $run.conclusion
            $name = $run.name
            $created = [DateTime]::Parse($run.created_at)
            $updated = [DateTime]::Parse($run.updated_at)
            
            # Determine visual status
            $statusIcon = "⏳"
            if ($status -eq "completed") {
                if ($conclusion -eq "success") {
                    $statusIcon = "✅"
                } elseif ($conclusion -eq "failure") {
                    $statusIcon = "❌"
                } else {
                    $statusIcon = "⚠️"
                }
            }
            
            Write-Host "  Status: $statusIcon $status" -ForegroundColor $(if ($statusIcon -eq "✅") {"Green"} else {if ($statusIcon -eq "❌") {"Red"} else {"Yellow"}})
            if ($conclusion) {
                Write-Host "  Result: $conclusion"
            }
            Write-Host "  Job: $name"
            Write-Host "  Created: $($created.ToString('yyyy-MM-dd HH:mm:ss'))"
            Write-Host "  Duration: $(($updated - $created).TotalSeconds) seconds"
            Write-Host ""
            
            return @{
                Status = $status
                Conclusion = $conclusion
                StatusIcon = $statusIcon
            }
        } else {
            Write-Host "  ⚠️  No deployment runs found yet" -ForegroundColor Yellow
            Write-Host ""
            return @{Status = "pending"; Conclusion = $null; StatusIcon = "⏳"}
        }
    } catch {
        Write-Host "  ❌ Error: $_" -ForegroundColor Red
        Write-Host ""
        return @{Status = "error"; Conclusion = $null; StatusIcon = "❌"}
    }
}

function Test-AppAccess {
    param(
        [string]$Url
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            if ($response.Content -match "home.*expense|claim|report") {
                return $true
            }
        }
    } catch {
        # App not ready yet
    }
    return $false
}

# Main monitoring loop
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Home Expense - Deployment Monitor" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$prodStatus = Get-DeploymentStatus "homestayERP-prod"
$testStatus = Get-DeploymentStatus "homestayERP-test"

# Check app accessibility
Write-Host "Checking app accessibility..." -ForegroundColor Cyan
Write-Host ""

$prodUrl = "https://haujackpang.github.io/homestayERP-prod"
$testUrl = "https://haujackpang.github.io/homestayERP-test"

Write-Host "Testing Prod App: $prodUrl"
if (Test-AppAccess $prodUrl) {
    Write-Host "  ✅ Prod app is accessible!" -ForegroundColor Green
} else {
    Write-Host "  ⏳ Prod app not yet available or still loading..." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Testing Test App: $testUrl"
if (Test-AppAccess $testUrl) {
    Write-Host "  ✅ Test app is accessible!" -ForegroundColor Green
} else {
    Write-Host "  ⏳ Test app not yet available or still loading..." -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$allSuccess = ($prodStatus.Status -eq "completed" -and $prodStatus.Conclusion -eq "success") -and `
              ($testStatus.Status -eq "completed" -and $testStatus.Conclusion -eq "success")

if ($allSuccess) {
    Write-Host "✅ Both applications deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now access:" -ForegroundColor Green
    Write-Host "  📱 Prod: $prodUrl" -ForegroundColor Cyan
    Write-Host "  🧪 Test: $testUrl" -ForegroundColor Cyan
} else {
    Write-Host "⏳ Deployment in progress..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Check progress at:" -ForegroundColor Yellow
    Write-Host "  Prod Actions: https://github.com/haujackpang/homestayERP-prod/actions" -ForegroundColor Cyan
    Write-Host "  Test Actions: https://github.com/haujackpang/homestayERP-test/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Typical deployment time: 2-3 minutes" -ForegroundColor Yellow
}

Write-Host ""

if ($Watch) {
    Write-Host "Watching for updates (press Ctrl+C to stop)..." -ForegroundColor Cyan
    while ($true) {
        Start-Sleep -Seconds 30
        Clear-Host
        Write-Host "Checking deployment status at $(Get-Date -Format 'HH:mm:ss')..." -ForegroundColor Gray
        Write-Host ""
        
        $prodStatus = Get-DeploymentStatus "homestayERP-prod"
        $testStatus = Get-DeploymentStatus "homestayERP-test"
        
        if (($prodStatus.Status -eq "completed" -and $prodStatus.Conclusion -eq "success") -and `
            ($testStatus.Status -eq "completed" -and $testStatus.Conclusion -eq "success")) {
            Write-Host "✅ Deployment complete! Apps are ready." -ForegroundColor Green
            Write-Host ""
            Write-Host "Access your apps:" -ForegroundColor Green
            Write-Host "  📱 Prod: https://haujackpang.github.io/homestayERP-prod" -ForegroundColor Cyan
            Write-Host "  🧪 Test: https://haujackpang.github.io/homestayERP-test" -ForegroundColor Cyan
            break
        }
    }
}
