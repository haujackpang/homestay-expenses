$env:Path += ";C:\Program Files\GitHub CLI"

$repos = @("haujackpang/homestay-expenses", "haujackpang/homestayERP-test")
$workflowFile = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"

foreach ($repo in $repos) {
    Write-Host "`n========================================`n$repo`n========================================`n"
    
    $tempDir = "C:\temp_gh_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        Push-Location $tempDir
        
        # Clone repo
        Write-Host "Cloning..."
        git clone "https://github.com/$repo.git" . | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Clone failed"
            continue
        }
        
        # Create workflows directory if not exists
        $workflowDir = ".\.github\workflows"
        if (-not (Test-Path $workflowDir)) {
            New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
        }
        
        # Copy workflow file
        Copy-Item $workflowFile "$workflowDir\deploy.yml" -Force
        
        # Git config
        git config user.email "bot@local.dev" | Out-Null
        git config user.name "Automation Bot" | Out-Null
        
        # Add and commit
        git add ".github/workflows/deploy.yml" | Out-Null
        $commitMsg = "feat: Update workflow with Python placeholder replacement"
        git commit -m $commitMsg | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            # Push
            git push 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $repo updated successfully"
            } else {
                Write-Host "❌ Push failed"
            }
        } else {
            Write-Host "⚠️  No changes (commit would fail)"
        }
    }
    catch {
        Write-Host "❌ Error: $_"
    }
    finally {
        Pop-Location
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n========================================`nDone!`n========================================"
