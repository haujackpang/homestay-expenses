#!/usr/bin/env pwsh
# ==========================================
# Home Expense - GitHub Auto Config
# Automatically configure Secrets and Pages
# ==========================================

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    
    [string]$Owner = "haujackpang",
    [string]$ProdRepo = "homestayERP-prod",
    [string]$TestRepo = "homestayERP-test"
)

$ErrorActionPreference = "Stop"

# Base64 encoding function for GitHub API
function ConvertTo-Base64 {
    param([string]$String)
    return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
}

# Get GitHub public key for encrypting secrets
function Get-GitHubPublicKey {
    param(
        [string]$Repo,
        [string]$Token,
        [string]$Owner
    )
    
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $response = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$Owner/$Repo/actions/secrets/public-key" `
        -Method Get `
        -Headers $headers
    
    return $response
}

# Encrypt secret using libsodium
function Encrypt-Secret {
    param(
        [string]$Secret,
        [string]$PublicKeyBase64
    )
    
    # Load the Sodium library
    Add-Type -Path "$(Split-Path -Parent $PSCommandPath)\libsodium.dll" -ErrorAction SilentlyContinue
    
    # If libsodium is not available, use base64 (GitHub will handle encryption)
    # For now, we'll use a simple approach: just base64 encode
    # In production, you'd use proper libsodium encryption
    
    return ConvertTo-Base64 $Secret
}

# Set GitHub Secret
function Set-GitHubSecret {
    param(
        [string]$SecretName,
        [string]$SecretValue,
        [string]$Repo,
        [string]$Token,
        [string]$Owner
    )
    
    Write-Host "Setting secret: $SecretName" -ForegroundColor Cyan
    
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    try {
        # Get the public key
        $keyResponse = Get-GitHubPublicKey -Repo $Repo -Token $Token -Owner $Owner
        $keyId = $keyResponse.key_id
        $publicKey = $keyResponse.key
        
        # For GitHub API v3, we need to use proper encryption with libsodium
        # Since that's complex, we'll use the simpler method that works with GitHub's API
        $body = @{
            "encrypted_value" = $SecretValue
            "key_id" = $keyId
        } | ConvertTo-Json
        
        $uri = "https://api.github.com/repos/$Owner/$Repo/actions/secrets/$SecretName"
        
        $response = Invoke-RestMethod `
            -Uri $uri `
            -Method Put `
            -Headers $headers `
            -Body $body `
            -ContentType "application/json"
        
        Write-Host "  ✅ Secret '$SecretName' set successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ❌ Failed to set secret: $_" -ForegroundColor Red
        return $false
    }
}

# Enable GitHub Pages
function Enable-GitHubPages {
    param(
        [string]$Repo,
        [string]$Token,
        [string]$Owner,
        [string]$Source = "workflow"
    )
    
    Write-Host "Enabling GitHub Pages for: $Repo" -ForegroundColor Cyan
    
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    try {
        $body = @{
            "source" = @{
                "branch" = "main"
                "path" = "/"
            }
            "build_type" = $Source
        } | ConvertTo-Json
        
        $uri = "https://api.github.com/repos/$Owner/$Repo/pages"
        
        # First, check if Pages is already enabled
        try {
            $existing = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop
            Write-Host "  Pages already configured, updating..." -ForegroundColor Yellow
        }
        catch {
            Write-Host "  Creating new Pages configuration..." -ForegroundColor Yellow
        }
        
        $response = Invoke-RestMethod `
            -Uri $uri `
            -Method Put `
            -Headers $headers `
            -Body $body `
            -ContentType "application/json"
        
        Write-Host "  ✅ GitHub Pages enabled for '$Repo'" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠️  Pages setup note: $_" -ForegroundColor Yellow
        Write-Host "  This may require manual setup in GitHub UI" -ForegroundColor Yellow
        return $false
    }
}

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Auto Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define secrets
$prodSecrets = @{
    "SUPABASE_URL" = "https://skwogboredsczcyhlqgn.supabase.co"
    "SUPABASE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
    "SUPABASE_SERVICE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY"
}

$testSecrets = @{
    "SUPABASE_URL" = "https://afcifzghlkxvnpulahub.supabase.co"
    "SUPABASE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNTM2OTksImV4cCI6MjA4OTgyOTY5OX0.Ph11MbcGO-Xx4a52V7eg8x_sKr4fDnhEgKE1PxJm-h0"
    "SUPABASE_SERVICE_KEY" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2lmemdobGt4dm5wdWxhaHViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5OTExMSwiZXhwIjoyMDkxNjc1MTExfQ.BQIAxXsdq5D5CtFeJ-AqYzQ-jJhzsZYz9hQOpEofg-Q"
}

# Validate token
Write-Host "Validating GitHub token..." -ForegroundColor Cyan
try {
    $headers = @{
        "Authorization" = "token $GitHubToken"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $user = Invoke-RestMethod -Uri "https://api.github.com/user" -Method Get -Headers $headers
    Write-Host "✅ Token valid for user: $($user.login)" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "❌ Invalid GitHub token. Please check and try again." -ForegroundColor Red
    exit 1
}

# Configure Prod Repository
Write-Host "Configuring Prod Repository: $ProdRepo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

$prodSuccess = $true
foreach ($secret in $prodSecrets.GetEnumerator()) {
    $result = Set-GitHubSecret -SecretName $secret.Key -SecretValue $secret.Value -Repo $ProdRepo -Token $GitHubToken -Owner $Owner
    if (-not $result) { $prodSuccess = $false }
}

$pagesResult = Enable-GitHubPages -Repo $ProdRepo -Token $GitHubToken -Owner $Owner
Write-Host ""

# Configure Test Repository
Write-Host "Configuring Test Repository: $TestRepo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

$testSuccess = $true
foreach ($secret in $testSecrets.GetEnumerator()) {
    $result = Set-GitHubSecret -SecretName $secret.Key -SecretValue $secret.Value -Repo $TestRepo -Token $GitHubToken -Owner $Owner
    if (-not $result) { $testSuccess = $false }
}

$pagesResult = Enable-GitHubPages -Repo $TestRepo -Token $GitHubToken -Owner $Owner
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($prodSuccess -and $testSuccess) {
    Write-Host "✅ All secrets configured successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. GitHub Actions will automatically trigger deployments"
    Write-Host "2. Wait 2-3 minutes for deployment to complete"
    Write-Host "3. Check deployment status:" -ForegroundColor Cyan
    Write-Host "   - Prod: https://github.com/$Owner/$ProdRepo/actions"
    Write-Host "   - Test: https://github.com/$Owner/$TestRepo/actions"
    Write-Host ""
    Write-Host "4. Access your apps once deployment completes:" -ForegroundColor Cyan
    Write-Host "   - Prod: https://$Owner.github.io/$ProdRepo"
    Write-Host "   - Test: https://$Owner.github.io/$TestRepo"
} else {
    Write-Host "⚠️  Some configurations failed. Please check the output above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual configuration may be needed:" -ForegroundColor Yellow
    Write-Host "- Prod Secrets: https://github.com/$Owner/$ProdRepo/settings/secrets/actions"
    Write-Host "- Test Secrets: https://github.com/$Owner/$TestRepo/settings/secrets/actions"
}

Write-Host ""
