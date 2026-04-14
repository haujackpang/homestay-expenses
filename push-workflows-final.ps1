$env:Path += ";C:\Program Files\GitHub CLI"
$repos = @("haujackpang/homestay-expenses", "haujackpang/homestayERP-test")
$workflowFile = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"

Write-Host "=== Pushing latest workflow to both repos ==="

foreach ($repo in $repos) {
    Write-Host "`nDeploying to: $repo"
    
    $tempDir = "C:\temp_push_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        Push-Location $tempDir
        
        # Clone repo
        Write-Host "  Cloning..."
        git clone "https://github.com/$repo.git" . 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ✗ Clone failed"
            Pop-Location
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
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
        git config user.name "Deploy Bot" | Out-Null
        
        # Add and commit
        git add ".github/workflows/deploy.yml" 2>&1 | Out-Null
        git commit -m "fix: Deploy directly to gh-pages branch" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            # Push
            git push 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Successfully pushed to $repo"
            } else {
                Write-Host "  ✗ Push failed"
            }
        } else {
            Write-Host "  ℹ️  No changes to commit"
        }
    }
    catch {
        Write-Host "  ✗ Error: $_"
    }
    finally {
        Pop-Location
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n=== Done! Workflows have been pushed to both repos ==="
Write-Host "Please wait 1-2 minutes for GitHub Actions to trigger and deploy..."
