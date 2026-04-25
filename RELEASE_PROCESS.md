# Release Process

## Purpose
This file defines how changes move through test and live environments for this project.

## Environments
- Test repo: `homestayERP-test`
- Live repo: `homestay-expenses`
- Test Supabase project: `skwogboredsczcyhlqgn`
- Live Supabase project: `afcifzghlkxvnpulahub`
- Obsolete repo: `homestayERP-prod` must not be used as the live deployment target.

## Current Live Setup
- Live repo `homestay-expenses` is the canonical production repo under `haujackpang`.
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
- Code/DB structure changes and data movement are separate. A live promotion must not copy or sync business data between test and live.

## Test-First Flow
1. Implement the change locally.
2. Run the safest practical verification.
3. Commit only the relevant files.
4. Push to `homestayERP-test`.
5. Validate in test environment.
6. Wait for explicit user approval before touching live.

## HostPlatform Unit Repair Rule
- If `HostPlatform Pairing` is blank after a unit sync, check the target `units` table before changing UI behavior.
- The canonical model is:
  - active HP rows use `source='hostplatform'`
  - internal/manual rows do not keep HP identity fields
  - `hp_unit_id` must be nullable for internal rows and uniquely indexed when non-null
- Use `supabase-repair-hp-unit-pairing.sql` for idempotent repair in the target environment first.
- After that repair, redeploy `sync-units` and `sync-reservations` in the same environment before promoting further.

## Live Promotion Rule
- Live deployment requires a clear user instruction in that turn.
- Prefer promoting a tested change, not redoing the work separately for live.
- When moving to live, verify:
  - target repo is `homestay-expenses`
  - target Supabase environment is live
  - required secrets/config are correct for live
- If the promoted feature depends on Supabase Functions or database schema, deploy the matching functions and run only idempotent live SQL upgrades that are required for the tested code to work.
- Do not copy, mirror, or reconcile table data between live and test during a live promotion unless the user gives a separate explicit data-migration instruction.

## Environment UI Rule
- Test-only UI markers, including the `TESTING` watermark, must be tied to the test GitHub Pages repo path (`/homestayERP-test`).
- Supabase project URL must not by itself enable test-only UI on the live repo.
- The deploy workflow should fail if the active repo is paired with the wrong known Supabase project.

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
