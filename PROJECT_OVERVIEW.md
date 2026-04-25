# Project Overview

## System Name
Homestay Expense System / Homestay ERP Test

## System Goal
This system helps a homestay operator record expenses, review claims, reimburse staff, sync HostPlatform reservations/units, and generate owner-facing monthly expense reports.

## Users
- System Admin: manages users, units, mappings, settings, logs, and system sync.
- Manager: submits/approves operational expenses and uses AI receipt scanning.
- Employee/Staff: submits expense claims and tracks claim status.
- Owner: not a direct system user yet, but receives reports and pays/receives profit sharing based on configured rules.

## Current Modules
- Authentication and role-based views.
- Staff/user management.
- Expense submission and approval.
- Payout tracking.
- Unit management.
- HostPlatform unit/reservation sync.
- Unit mapping.
- Unit configuration: owner, cleaning fee, laundry fee, profit sharing percentage.
- OCR/AI receipt extraction.
- Error/admin/sync logs.
- Monthly expense reporting and PDF export.

## Current Stage
Testing environment remains the default working target in `homestayERP-test`.

Canonical live environment is `homestay-expenses`.

Recent completed work:
- HostPlatform unit pairing data was repaired in test:
  - `units.hp_unit_id` is now treated as nullable for internal units and protected by a unique non-null index for synced HP rows.
  - Legacy `auto_synced` rows are normalized into the canonical `source='hostplatform'` model.
  - Legacy HP duplicates that already have a canonical `property_name + unit` replacement are deactivated instead of continuing to clutter pairing.
  - The pairing screen now shows active HostPlatform rows only, while the Units summary still reports how many inactive HP rows are hidden.
  - `sync-units` and `sync-reservations` now fail closed when required env/config is missing instead of returning a misleading success.
- Environment separation was tightened:
  - Test remains `homestayERP-test` with Supabase `skwogboredsczcyhlqgn`.
  - Live remains `homestay-expenses` with Supabase `afcifzghlkxvnpulahub`.
  - `homestayERP-prod` is obsolete and must not be used as the live repo.
  - The `TESTING` watermark is tied to the test Pages path, not Supabase URL alone.
  - Live promotion must not copy or sync database table data between test and live.
- Unit pairing UX was clarified in the admin frontend:
  - `Units` now separates `Internal Units` from `HostPlatform Pairing`.
  - HostPlatform pairing uses pairing-first wording, search, and `All / Unmapped / Paired` filters.
  - `Property short code` is presented as `Display code (optional)` for internal units and read-only in pairing flows.
  - Editing a HostPlatform row now routes to a pairing-focused form instead of the generic internal-unit form.
- Admin user management was fixed and promoted to both environments:
  - `admin-users` now lists users with a `profiles` fallback when auth listing is incomplete.
  - System admin password reset works again for test and live.
  - The updated Edge Function was deployed to `skwogboredsczcyhlqgn` and `afcifzghlkxvnpulahub`.
- Test Supabase Edge Functions `sync-units` and `sync-reservations` were deployed.
- HostPlatform sync credentials were copied from live to test Supabase.
- Test sync was verified successfully:
  - Units: 16 synced.
  - Reservations: 4376 fetched, 4373 upserted.
- Unit-level cleaning/laundry/profit sharing configuration was added.
- Property-level mapping is being replaced by HostPlatform property + unit mapping.
- OCR/AI invoice extraction now runs through Supabase Edge Functions:
  - `process-invoice` handles auth, duplicate checks, unit matching, expense month, and final description formatting.
  - `analyze-receipt` handles image/PDF-derived image OCR using OpenAI when configured, with fallback support.
- Repo/environment mapping was corrected on 2026-04-24:
  - Test repo `homestayERP-test` -> Supabase `skwogboredsczcyhlqgn`
  - Live repo `homestay-expenses` -> Supabase `afcifzghlkxvnpulahub`
- Follow-up CLI audit on 2026-04-24 found:
  - `profiles` and `claims` are mirrored on the audited business fields.
  - `reservations`, `units`, `unit_config`, `unit_types`, and log tables are not fully mirrored.
  - Cleanup should not delete rows until a row-by-row source-of-truth decision is made.

## Project Memory Files
These files are part of the working system and must be kept updated when relevant changes happen:
- `PROJECT_OVERVIEW.md`
- `BUSINESS_RULES.md`
- `DECISIONS_LOG.md`
- `TASK_CONTEXT.md`
- `AI_INSTRUCTIONS.md`
- `RELEASE_PROCESS.md`
