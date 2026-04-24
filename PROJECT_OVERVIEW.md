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

## Project Memory Files
These files are part of the working system and must be kept updated when relevant changes happen:
- `PROJECT_OVERVIEW.md`
- `BUSINESS_RULES.md`
- `DECISIONS_LOG.md`
- `TASK_CONTEXT.md`
- `AI_INSTRUCTIONS.md`
- `RELEASE_PROCESS.md`
