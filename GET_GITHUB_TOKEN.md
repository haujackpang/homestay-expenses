# GitHub Token / CLI Setup

Prefer GitHub CLI for secret setup:

```powershell
gh auth login
```

Then configure one environment at a time:

```powershell
.\auto-configure-secrets.ps1 -Target test
```

Live must be explicit:

```powershell
.\auto-configure-secrets.ps1 -Target live
```

## Active Repos

- Test: `haujackpang/homestayERP-test`
- Live: `haujackpang/homestay-expenses`

`haujackpang/homestayERP-prod` is obsolete and must not be used.

## If A Personal Access Token Is Needed

Create a GitHub token only if `gh auth login` is not possible.

Minimum useful scopes for repository automation:

- `repo`
- `workflow`

Do not commit the token. Delete it from GitHub after the setup work is complete.

## Safety

Secret setup changes deployment configuration only. It must not copy database data between test and live.
