# Task Context

## Current Task
Latest release status:

1. User explicitly approved live promotion on 2026-04-23.
2. `homestayERP-prod` was created, GitHub Pages was enabled in workflow mode, and `main` was pushed to live.
3. Live GitHub Pages deployment succeeded and is configured for live Supabase project `skwogboredsczcyhlqgn`.
4. Live Supabase Edge Functions deployed: `analyze-receipt`, `process-invoice`, `sync-reservations`, `sync-units`.
5. Live SQL upgrades applied idempotently: unit mapping column, unit-level cleaning/laundry columns, and invoice automation columns/functions.
6. Live manual sync verification succeeded:
   - Reservations: 4381 fetched, 4378 upserted.
   - Units: 16 synced.
7. Configure AI provider secret. Status: live has `OPENROUTER_API_KEY` fallback configured. OpenAI-specific OCR requires adding `OPENAI_API_KEY` and optional `OPENAI_OCR_MODEL` to the target Supabase secrets.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test and live Supabase functions are deployed and direct function calls succeeded after secrets were copied/configured.
- Test database now has `units.mapped_unit_name`.
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.
- Live Supabase has `OPENROUTER_API_KEY`; OCR can use fallback there. Add `OPENAI_API_KEY` to live when switching specifically to OpenAI.
- Direct call to test `sync-units` returned HTTP 200 and synced 16 units, so the screenshot 401 is likely caused by stale browser auth token, not missing function deployment.
- Direct call to test `sync-reservations` returned HTTP 200 and upserted records, so browser 401 is likely caused by stale/rejected user-session JWT before the function runs.
- Report PDF cleaning fee uses `(cleaning_fee + laundry_fee) x reservation count`, displayed as `Cleaning fee` in the shared expenses/expense details area.
- Homestay profit = sales - sharing expenses charged to Both.
- Homestay Management Fee = homestay profit x `service_fee_pct` / 100.
- Owner Expenses = expenses charged to Owner, excluding Cleaning fee and Homestay Management Fee.
- Owner Profit = homestay profit - Homestay Management Fee - Owner Expenses.
- Report page Expenses section includes shared claims and Total Cleaning Fee.

## Do Not Do
- Do not move future changes to live unless explicitly requested again.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.
- Do not claim OCR is fully runnable in test until an AI provider key has been configured.
- Do not allow duplicate active HP mappings to the same internal unit.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
