# Release Process

## Purpose
This file defines how changes move through test and live environments for this project.

## Environments
- Test repo: `homestayERP-test`
- Live repo: `homestayERP-prod`
- Test Supabase project: `afcifzghlkxvnpulahub`
- Live Supabase project: `skwogboredsczcyhlqgn`

## Current Live Setup
- Live repo `homestayERP-prod` exists under `haujackpang`.
- GitHub Pages is enabled using workflow deployment.
- Repo secrets required by `.github/workflows/deploy.yml`:
  - `SUPABASE_URL`
  - `SUPABASE_KEY`
- Live Supabase Edge Functions expected by the app:
  - `sync-reservations`
  - `sync-units`
  - `analyze-receipt`
  - `process-invoice`

## Default Rule
- All changes go to test first unless the user explicitly says otherwise.
- Never assume a change should go to live just because test is working.

## Test-First Flow
1. Implement the change locally.
2. Run the safest practical verification.
3. Commit only the relevant files.
4. Push to `homestayERP-test`.
5. Validate in test environment.
6. Wait for explicit user approval before touching live.

## Live Promotion Rule
- Live deployment requires a clear user instruction in that turn.
- Prefer promoting a tested change, not redoing the work separately for live.
- When moving to live, verify:
  - target repo is `homestayERP-prod`
  - target Supabase environment is live
  - required secrets/config are correct for live
- If the promoted feature depends on Supabase Functions or database schema, deploy the matching functions and run only idempotent live SQL upgrades that are required for the tested code to work.

## Commit / Push Checklist
Before every commit or push, confirm:
- Which repo is the target: test or live
- Whether the user approved live promotion
- Whether the changes belong to the requested environment
- Whether unrelated local changes are being left untouched

## Memory Maintenance
- Update this file whenever release flow or environment handling changes.
- Update `TASK_CONTEXT.md` whenever the current target environment changes.
- Update `DECISIONS_LOG.md` whenever a release-related decision is made.
