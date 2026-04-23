# Task Context

## Current Task
Latest testing issues reported by the user:

1. Remove unrelated dirty/useless local files. Status: done for the known unrelated files from the previous deployment/debug session.
2. Add OpenAI/Codex-style OCR AI function to automate expense invoice input. Status: implemented in code and deployed to test Supabase functions.
3. Normalize OCR descriptions for fixed bills. Status: implemented for `[WB]`, `[EB]`, and `[INT]` formats.
4. Configure AI provider secret. Status: blocked until `OPENAI_API_KEY` is provided/configured in test Supabase; no OpenAI key exists in test or live secrets at this time.
5. User message ended with unfinished phrase `那unit`; wait for clarification before inventing extra unit behavior beyond current OCR unit hint/selected-unit handling.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test Supabase functions are deployed and direct function calls succeeded after secrets were copied.
- The 401 shown in the browser likely came from deployed frontend configuration or GitHub Pages secret replacement, not the Edge Function itself.
- Test database now has `units.mapped_unit_name`.
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.

## Do Not Do
- Do not move changes to live unless explicitly requested.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.
- Do not claim OCR is fully runnable in test until an AI provider key has been configured.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
