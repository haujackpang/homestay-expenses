# Task Context

## Current Task
Latest testing issues reported by the user:

1. Update PDF export layout for owner report. Status: implemented in code; needs deployment verification after push.
2. PDF title should use property + unit name. Status: implemented when HostPlatform mapping exists.
3. PDF should show booking details, cleaning fee, expense details, homestay management fee, owner expenses, and owner net amount. Status: implemented.
4. Configure AI provider secret. Status: still blocked until `OPENAI_API_KEY` is provided/configured in test Supabase; no OpenAI key exists in test or live secrets at this time.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test Supabase functions are deployed and direct function calls succeeded after secrets were copied.
- Test database now has `units.mapped_unit_name`.
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.
- Direct call to test `sync-units` returned HTTP 200 and synced 16 units, so the screenshot 401 is likely caused by stale browser auth token, not missing function deployment.
- Report PDF cleaning fee uses `(cleaning_fee + laundry_fee) x reservation count`.
- Report PDF homestay management fee uses booking total x `service_fee_pct` / 100, displayed as management fee/profit sharing.

## Do Not Do
- Do not move changes to live unless explicitly requested.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.
- Do not claim OCR is fully runnable in test until an AI provider key has been configured.
- Do not allow duplicate active HP mappings to the same internal unit.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
