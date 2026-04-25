# Deployment Guide

## Active Environments

| Environment | Git remote | GitHub repo | Supabase project | App URL |
| --- | --- | --- | --- | --- |
| Test | `origin-test` | `haujackpang/homestayERP-test` | `afcifzghlkxvnpulahub` | `https://haujackpang.github.io/homestayERP-test` |
| Live | `origin` | `haujackpang/homestay-expenses` | `skwogboredsczcyhlqgn` | `https://haujackpang.github.io/homestay-expenses` |

The old `homestayERP-prod` repo is obsolete and should not be used for live deployment.

## Default Flow

1. Make the code or schema change locally.
2. Verify locally as much as practical.
3. Commit only the intended files.
4. Push to test with `git push origin-test main`.
5. Wait for the test GitHub Pages deployment to pass.
6. Let the user test.
7. Promote to live only when the user explicitly says to push to live.

## Live Promotion

When live is approved:

1. Push the tested commit to `origin/main`.
2. Deploy matching Supabase Edge Functions to the live project only when the code depends on them.
3. Run only required idempotent DB structure upgrades on the live project.
4. Do not copy or sync database data between test and live.
5. Verify the live GitHub Actions run and the live app URL.

## GitHub Secrets

Use `GITHUB_SECRETS_CONFIG.md` as the source of truth.

Expected repo pairing:

- `haujackpang/homestayERP-test` must use `https://afcifzghlkxvnpulahub.supabase.co`.
- `haujackpang/homestay-expenses` must use `https://skwogboredsczcyhlqgn.supabase.co`.

The deploy workflow checks this pairing and fails if a known active repo is configured with the wrong Supabase project.

## Testing Watermark

The `TESTING` watermark belongs only to the test Pages path:

```text
/homestayERP-test
```

It must not be triggered by Supabase URL alone, because database configuration and visible deployment identity are separate concerns.

## Verification Commands

Check remotes:

```powershell
git remote -v
```

Check changed files:

```powershell
git status --short
```

Check recent deploy runs:

```powershell
gh run list --repo haujackpang/homestayERP-test --limit 3
gh run list --repo haujackpang/homestay-expenses --limit 3
```
