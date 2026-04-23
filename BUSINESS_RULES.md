# Business Rules

## Core Rules
- Do not invent missing business logic.
- Do not remove validation unless the user explicitly approves.
- Prefer minimal safe changes that fit the existing single-file app pattern.
- If code conflicts with these rules, stop and explain the conflict before changing behavior.

## Environment Rules
- Testing app must use `homestayERP-test`.
- Test Supabase project ref: `afcifzghlkxvnpulahub`.
- Live Supabase project ref: `skwogboredsczcyhlqgn`.
- Do not push test changes to live unless explicitly requested.
- Do not expose secret values in chat or committed files.
- Default deployment target is test, not live.
- Live deployment requires explicit user approval in that turn.
- When a change affects business logic, environment handling, release flow, or current priorities, update the memory files before finishing.

## Project Memory Rules
- Before making changes, read:
  `PROJECT_OVERVIEW.md`, `BUSINESS_RULES.md`, `DECISIONS_LOG.md`, `TASK_CONTEXT.md`, `AI_INSTRUCTIONS.md`, `RELEASE_PROCESS.md`
- After making meaningful changes, update the relevant memory files in the same turn.
- Do not leave business-rule changes only inside chat history.
- If code behavior and memory files conflict, stop and surface the conflict before continuing.

## Unit And Mapping Rules
- HostPlatform records must not be treated as permanent internal naming source.
- HostPlatform property alone is not enough for mapping because one property may contain several units.
- Correct mapping key is:
  `HostPlatform property + HostPlatform unit -> Internal Unit`
- Internal unit naming remains controlled by this system.
- Property short code is only a display/report helper, not the full mapping.
- Manual units are internal units.
- HostPlatform synced units should be mapped to internal units through Unit Mapping.

## Unit Configuration Rules
- Cleaning and laundry rates are unit-level settings.
- Do not rely on unit type for cleaning/laundry rates because the same property and same unit type may still have different rates.
- `Service Fee %` wording must be shown as `Profit Sharing %`.
- Existing database column `service_fee_pct` may remain as implementation detail unless a migration is explicitly approved.

## Logs Rules
- Logs page must show useful operational logs, not only error logs.
- Sync success/failure should be visible in the app.
- Admin changes such as unit mapping, unit activation, and unit configuration should be logged.

## Sync Rules
- `sync-units` imports HostPlatform unit records.
- `sync-reservations` imports HostPlatform reservation records.
- Sync errors must be actionable. Avoid vague `Failed to fetch` messages when possible.
- If sync fails with 401 in test, first check deployed GitHub/Supabase key configuration and function JWT/auth behavior.
