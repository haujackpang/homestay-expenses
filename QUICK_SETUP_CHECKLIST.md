# Quick Setup Checklist

## Current Naming

- Test repo: `haujackpang/homestayERP-test`
- Test Supabase: `skwogboredsczcyhlqgn`
- Test app: `https://haujackpang.github.io/homestayERP-test`
- Live repo: `haujackpang/homestay-expenses`
- Live Supabase: `afcifzghlkxvnpulahub`
- Live app: `https://haujackpang.github.io/homestay-expenses`

Do not use `haujackpang/homestayERP-prod`; it is obsolete.

## Secrets Checklist

For each active repo, confirm these secrets exist:

- `SUPABASE_URL`
- `SUPABASE_KEY`
- `SUPABASE_SERVICE_KEY`

Expected `SUPABASE_URL` values:

- Test: `https://skwogboredsczcyhlqgn.supabase.co`
- Live: `https://afcifzghlkxvnpulahub.supabase.co`

Use the helper script when possible:

```powershell
.\auto-configure-secrets.ps1 -Target test
.\auto-configure-secrets.ps1 -Target live
```

Only run the live command after live approval.

## Pages Checklist

- Test Pages source is `GitHub Actions`.
- Live Pages source is `GitHub Actions`.
- Test Actions page: `https://github.com/haujackpang/homestayERP-test/actions`
- Live Actions page: `https://github.com/haujackpang/homestay-expenses/actions`

## Release Checklist

- Push normal changes to test first.
- Do not push to live unless the user explicitly says to push to live.
- For live, promote the tested commit instead of rebuilding a separate change.
- Apply only required live DB structure changes.
- Never copy or sync test data into live, or live data into test, as part of a push.
- Confirm live has no `TESTING` watermark.
