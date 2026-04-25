# GitHub Secrets Configuration

This file is the current reference for GitHub Actions secrets.

## Environment Names

| Environment | GitHub repo | Supabase project ref | Pages URL |
| --- | --- | --- | --- |
| Test | `haujackpang/homestayERP-test` | `afcifzghlkxvnpulahub` | `https://haujackpang.github.io/homestayERP-test` |
| Live | `haujackpang/homestay-expenses` | `skwogboredsczcyhlqgn` | `https://haujackpang.github.io/homestay-expenses` |

`haujackpang/homestayERP-prod` is obsolete and must not be used as the live deployment target.

## Required Secrets

Each active repo needs these Action secrets:

| Secret | Meaning |
| --- | --- |
| `SUPABASE_URL` | The environment-specific Supabase project URL. |
| `SUPABASE_KEY` | The environment-specific anon or publishable key used by the browser app. |
| `SUPABASE_SERVICE_KEY` | The environment-specific service-role key used only by backend/admin automation. |

Do not commit secret values into this repo. Use GitHub Secrets only.

## Correct URLs

Test repo:

```text
SUPABASE_URL=https://afcifzghlkxvnpulahub.supabase.co
```

Live repo:

```text
SUPABASE_URL=https://skwogboredsczcyhlqgn.supabase.co
```

## Recommended Setup

Use the safe helper script:

```powershell
.\auto-configure-secrets.ps1 -Target test
```

Live must be explicit:

```powershell
.\auto-configure-secrets.ps1 -Target live
```

The script reads current Supabase API keys from the Supabase CLI and writes them to the selected GitHub repo. It does not copy database data between environments.

## Pages Settings

Set Pages source to `GitHub Actions` for each active repo:

- Test: `https://github.com/haujackpang/homestayERP-test/settings/pages`
- Live: `https://github.com/haujackpang/homestay-expenses/settings/pages`

## Safety Rules

- Default target is test.
- Push to live only after the user explicitly says to push to live in that turn.
- A live push means code, workflow, Edge Functions, and required idempotent DB structure changes only.
- A live push must not copy, mirror, import, or sync business data from test to live.
- If a repo secret points to the wrong Supabase project, the deploy workflow should fail instead of publishing a mixed environment.
