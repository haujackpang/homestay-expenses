# Safely configure GitHub Actions secrets for one environment.
# Default target is test. Live must be requested explicitly.

param(
    [ValidateSet("test", "live", "both")]
    [string]$Target = "test"
)

$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\GitHub CLI"

$Environments = @{
    test = @{
        Label = "TEST"
        Repo = "haujackpang/homestayERP-test"
        ProjectRef = "skwogboredsczcyhlqgn"
        Url = "https://skwogboredsczcyhlqgn.supabase.co"
    }
    live = @{
        Label = "LIVE"
        Repo = "haujackpang/homestay-expenses"
        ProjectRef = "afcifzghlkxvnpulahub"
        Url = "https://afcifzghlkxvnpulahub.supabase.co"
    }
}

function Assert-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is not available in PATH."
    }
}

function Get-ProjectKeys {
    param([string]$ProjectRef)

    $json = & supabase projects api-keys --project-ref $ProjectRef --output json
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to read Supabase API keys for $ProjectRef."
    }

    $keys = $json | ConvertFrom-Json
    $anon = $keys | Where-Object { $_.id -eq "anon" -or $_.name -eq "anon" } | Select-Object -First 1
    $service = $keys | Where-Object { $_.id -eq "service_role" -or $_.name -eq "service_role" } | Select-Object -First 1

    if (-not $anon -or -not $anon.api_key) {
        throw "Anon key not found for $ProjectRef."
    }
    if (-not $service -or -not $service.api_key) {
        throw "Service role key not found for $ProjectRef."
    }

    return @{
        Anon = $anon.api_key
        Service = $service.api_key
    }
}

function Set-RepoSecrets {
    param(
        [string]$Repo,
        [string]$Label,
        [string]$Url,
        [string]$AnonKey,
        [string]$ServiceKey
    )

    Write-Host "Configuring $Label repo: $Repo" -ForegroundColor Cyan

    $Url | gh secret set SUPABASE_URL --repo $Repo | Out-Null
    $AnonKey | gh secret set SUPABASE_KEY --repo $Repo | Out-Null
    $ServiceKey | gh secret set SUPABASE_SERVICE_KEY --repo $Repo | Out-Null

    Write-Host "$Label secrets updated." -ForegroundColor Green
}

Assert-Command "gh"
Assert-Command "supabase"

& gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not logged in. Run: gh auth login"
}

$targets = @()
if ($Target -eq "both") {
    $targets = @("test", "live")
} else {
    $targets = @($Target)
}

foreach ($name in $targets) {
    $envConfig = $Environments[$name]
    $keys = Get-ProjectKeys -ProjectRef $envConfig.ProjectRef
    Set-RepoSecrets `
        -Repo $envConfig.Repo `
        -Label $envConfig.Label `
        -Url $envConfig.Url `
        -AnonKey $keys.Anon `
        -ServiceKey $keys.Service
}

Write-Host "Done. No database data was copied or synced." -ForegroundColor Green
