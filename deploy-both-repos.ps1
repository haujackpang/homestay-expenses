powershell -Command {
    $env:Path += ";C:\Program Files\GitHub CLI"
    $repos = @("haujackpang/homestay-expenses", "haujackpang/homestayERP-test")
    $workflowFile = "c:\Users\localad\Desktop\homestay-expenses\.github\workflows\deploy.yml"

    foreach ($repo in $repos) {
        Write-Host "Deploying to: $repo"
        
        $tempDir = "C:\temp_push_$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        cd $tempDir
        
        git clone "https://github.com/$repo.git" . 2>&1 | Out-Null
        
        $workflowDir = ".\.github\workflows"
        if (-not (Test-Path $workflowDir)) {
            New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
        }
        
        Copy-Item $workflowFile "$workflowDir\deploy.yml" -Force
        
        git config user.email "bot@local.dev" | Out-Null
        git config user.name "Deploy Bot" | Out-Null
        git add ".github/workflows/deploy.yml" 2>&1 | Out-Null
        git commit -m "fix: Deploy directly to gh-pages branch" 2>&1 | Out-Null
        git push 2>&1 | Out-Null
        
        cd ..
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "  Done!"
    }
}
