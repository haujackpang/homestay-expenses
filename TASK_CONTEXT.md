# Task Context

## Current Task
Latest completed task: simplify the unit-pairing UX so admin users can understand the difference between internal units and HostPlatform pairing.

Current focus:
1. Environment separation has been re-tightened: test is `homestayERP-test` / `skwogboredsczcyhlqgn`, live is `homestay-expenses` / `afcifzghlkxvnpulahub`, and `homestayERP-prod` is obsolete.
2. The `TESTING` watermark should be controlled by the test Pages path only, not by Supabase URL alone.
3. Pushing to live means code/workflow/functions/required idempotent DB structure only; do not copy or sync table data between environments.
4. HostPlatform pairing now assumes only active canonical `source='hostplatform'` rows should be shown in the pairing list.
5. Use `supabase-repair-hp-unit-pairing.sql` when a target environment has legacy HP rows, missing `hp_unit_id` uniqueness, or blank pairing after sync.

Recent unit-pairing context:
1. `Units` now acts as a landing page with separate entry points for `Internal Units`, `HostPlatform Pairing`, and `Unit Configuration`.
2. HostPlatform pairing remains `HostPlatform property + unit -> internal unit`, with clearer wording, search, and `All / Unmapped / Paired` filtering.
3. `property_short` is now presented in the UI as `Display code (optional)` and should be treated as a display/report helper, not the pairing key.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test and live Supabase functions are deployed and direct function calls succeeded after secrets were copied/configured.
- `admin-users` now supports user listing fallback and password reset updates for system admin accounts.
- The same `admin-users` fix was deployed to both test project `skwogboredsczcyhlqgn` and live project `afcifzghlkxvnpulahub`.
- Live repo and live Supabase remain separate from test; app code must not contain runtime fallback behavior that reconnects live pages to test data.
- Previous `homestayERP-prod` repo should be treated as obsolete and not used for deployment.
- Runtime config validation must not compare against placeholder literals that the deploy workflow replaces globally.
- Audit completed on 2026-04-24:
  - `profiles` are mirrored across test and live: 4 matching rows.
  - `claims` are mirrored across test and live for common fields: 31 matching rows.
  - Live `claims` schema is older than test and lacks newer OCR/import metadata columns.
- Follow-up audit on 2026-04-24:
  - `reservations` are not a perfect mirror: counts differ by 2, and shared rows diverge mainly on `hp_unit_id`, `extra_guest`, `rental`, and `total_charges`.
  - `units` are not a perfect mirror: counts differ by 14 and one shared unit row differs in `property_short`.
  - `unit_config`, `unit_types`, `sync_logs`, and `error_logs` also differ between the two projects.
- Test database now has `units.mapped_unit_name`.
- Test database repair on 2026-04-25 confirmed:
  - internal/manual rows no longer carry HP identity fields
  - `units_hp_unit_id_idx` now protects non-null `hp_unit_id`
  - matched legacy HP duplicates were deactivated
  - two unmatched legacy HP rows (`KT 150A`, `SG 34F`) remain active until HP returns canonical replacements
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.
- Live Supabase has `OPENROUTER_API_KEY`; OCR can use fallback there. Add `OPENAI_API_KEY` to live when switching specifically to OpenAI.
- Direct call to test `sync-units` returned HTTP 200 and synced 16 units, so the screenshot 401 is likely caused by stale browser auth token, not missing function deployment.
- Direct call to test `sync-reservations` returned HTTP 200 and upserted records, so browser 401 is likely caused by stale/rejected user-session JWT before the function runs.
- Manage Users 401/Unauthorized issues were traced to the admin-users backend permission check and function secret/env mismatch, then fixed by updating the function and redeploying.
- Report PDF cleaning fee uses `(cleaning_fee + laundry_fee) x reservation count`, displayed as `Cleaning fee` in the shared expenses/expense details area.
- Report page should display the same wording as `Cleaning fee` and include it in the visible Expenses detail list.
- Homestay profit = sales - sharing expenses charged to Both.
- Homestay Management Fee = homestay profit x `service_fee_pct` / 100.
- Owner Expenses = expenses charged to Owner, excluding Cleaning fee and Homestay Management Fee.
- Owner Profit = homestay profit - Homestay Management Fee - Owner Expenses.
- Report page Expenses section includes shared claims and Total Cleaning Fee.
- The admin user-management flow now uses `profiles` fallback when auth user listing is incomplete, so the UI can still show users and allow password resets.
- Internal units and HostPlatform rows should not share the same primary edit workflow in the admin UI.
- Editing a `source='hostplatform'` row should open a pairing-focused form, while editing a non-HP row should open the internal-unit form.
- The pairing screen should be the primary place where admins pair HostPlatform rows to internal units.
- `Display code (optional)` is editable only for internal units and read-only when shown in HostPlatform pairing.

## Do Not Do
- Do not move future changes to live unless explicitly requested again after this promotion is finished.
- Do not copy, mirror, or sync business data between test and live as part of a code or DB-structure push.
- Do not reintroduce `homestayERP-prod` as a live repo target.
- Do not trigger the testing watermark from Supabase URL alone.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.
- Do not claim OCR is fully runnable in test until an AI provider key has been configured.
- Do not allow duplicate active HP mappings to the same internal unit.
- Do not treat inactive legacy HP rows as valid pairing rows in the UI.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
