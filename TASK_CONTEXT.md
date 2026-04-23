# Task Context

## Current Task
Latest testing issues reported by the user:

1. Remove the separate `Cleaning & Laundry Rates` page/entry because rates now belong inside Unit Configuration. Status: implemented in code.
2. Fix unit pairing workflow so it maps `HostPlatform property + HostPlatform unit` to an internal unit, not just a property short code. Status: implemented with `units.mapped_unit_name`.
3. Investigate and fix the test frontend `Sync from HP` error showing `Request failed (HTTP 401)`. Status: GitHub test secrets refreshed; needs redeploy verification after push.
4. Establish repo memory files and follow them before making future changes. Status: implemented.
5. Add persistent release-process documentation and require future memory-file updates. Status: in progress.

## Current Working Assumptions
- User has already executed the test Supabase script that adds unit-level cleaning/laundry columns.
- Test Supabase functions are deployed and direct function calls succeeded after secrets were copied.
- The 401 shown in the browser likely came from deployed frontend configuration or GitHub Pages secret replacement, not the Edge Function itself.
- Test database now has `units.mapped_unit_name`.

## Do Not Do
- Do not move changes to live unless explicitly requested.
- Do not remove unit configuration fields.
- Do not reintroduce unit-type-based rate logic.
- Do not expose secret values in final messages.

## Memory Update Requirement
- When business rules, release targets, deployment state, or current priorities change, update the relevant memory files before ending the turn.
