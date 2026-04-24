# Task Context

## Current Task
Current test-first fixes requested by the user on 2026-04-24:

1. Keep test and live strictly separated at database level. Live must not show the test watermark or test-only manual entries.
2. Replace report wording from `Total Cleaning Fee` to `Cleaning fee`.
3. Replace `Sharing Expenses` wording with `Expenses`.
4. Show `Cleaning fee` inside the Expenses details list/table.
5. These changes are being prepared in test first. Do not move them to live until the user explicitly approves again.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test and live Supabase functions are deployed and direct function calls succeeded after secrets were copied/configured.
- Live repo and live Supabase remain separate from test; app code must not contain runtime fallback behavior that reconnects live pages to test data.
- Test database now has `units.mapped_unit_name`.
- OpenAI API usage requires an API key in Supabase secrets. Codex itself is not an app-callable OCR backend.
- The current OCR implementation uses `gpt-4o-mini` by default when `OPENAI_API_KEY` is available.
- Test Supabase currently has no `OPENAI_API_KEY` and no `OPENROUTER_API_KEY`, so OCR returns a clear configuration error until a provider key is added.
- Live Supabase has `OPENROUTER_API_KEY`; OCR can use fallback there. Add `OPENAI_API_KEY` to live when switching specifically to OpenAI.
- Direct call to test `sync-units` returned HTTP 200 and synced 16 units, so the screenshot 401 is likely caused by stale browser auth token, not missing function deployment.
- Direct call to test `sync-reservations` returned HTTP 200 and upserted records, so browser 401 is likely caused by stale/rejected user-session JWT before the function runs.
- Report PDF cleaning fee uses `(cleaning_fee + laundry_fee) x reservation count`, displayed as `Cleaning fee` in the shared expenses/expense details area.
- Report page should display the same wording as `Cleaning fee` and include it in the visible Expenses detail list.
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
