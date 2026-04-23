# Task Context

## Current Task
Latest testing issues reported by the user:

1. Add reservation details to manager report page. Status: implemented in code; needs deployment verification after push.
2. Recheck Unit Mapping workflow. Status: improved to hide already-paired internal units from other HP rows and allow unmapping.
3. Fix `Sync from HP` browser 401. Status: front-end token refresh/retry implemented; direct test Edge Function call already returns HTTP 200.
4. Configure AI provider secret. Status: still blocked until `OPENAI_API_KEY` is provided/configured in test Supabase; no OpenAI key exists in test or live secrets at this time.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test Supabase functions are deployed and direct function calls succeeded after secrets were copied.
- Test database now has `units.mapped_unit_name`.
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.
- Direct call to test `sync-units` returned HTTP 200 and synced 16 units, so the screenshot 401 is likely caused by stale browser auth token, not missing function deployment.

## Do Not Do
- Do not move changes to live unless explicitly requested.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.
- Do not claim OCR is fully runnable in test until an AI provider key has been configured.
- Do not allow duplicate active HP mappings to the same internal unit.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
