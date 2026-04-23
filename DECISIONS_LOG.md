# Decisions Log

## 2026-04-23: Fixed Short Code Dropdown
Decision: Property short code should use a predefined dropdown list instead of free text.

Reason:
Free typing caused human error, inconsistent codes, and downstream reporting problems.

## 2026-04-23: Property-Level Mapping Was Not Enough
Decision: Replace property-only mapping with HostPlatform property + unit mapping.

Reason:
One HostPlatform property can contain several units. Mapping at property level can assign the wrong unit or make several units indistinguishable.

## 2026-04-23: Unit-Level Rates
Decision: Cleaning and laundry rates belong to unit configuration, not unit type.

Reason:
The same property and unit type may still have different cleaning/laundry rates.

## 2026-04-23: Rename Service Fee Wording
Decision: Display `service_fee_pct` as `Profit Sharing %`.

Reason:
The business meaning is the percentage shared/charged against owner profit, not a generic service fee.

## 2026-04-23: Logs Must Include Operations
Decision: Logs page should include sync logs and admin action logs, not only frontend/backend errors.

Reason:
Testing and troubleshooting need visibility into sync success/failure and admin configuration changes.

## 2026-04-23: Test Sync Credentials
Decision: Copy HostPlatform reservation credentials from live Supabase to test Supabase.

Reason:
Test sync functions were deployed but failed login until test received the same HostPlatform credentials.

## 2026-04-23: Project Memory Files
Decision: Maintain project memory files in the repo so AI assistants must read stable business context before changing code.

Reason:
Important business rules were discussed over multiple turns and can be lost across sessions or model changes.

## 2026-04-23: Remove Separate Cleaning/Laundry Page
Decision: Remove the visible standalone `Cleaning & Laundry Rates` entry and route old access to `Unit Configuration`.

Reason:
Cleaning/laundry rates are unit-level configuration. Keeping a separate rates page duplicates the workflow and makes users think rates are managed somewhere else.

## 2026-04-23: Add `mapped_unit_name`
Decision: Store HostPlatform unit mapping in `units.mapped_unit_name`.

Reason:
HostPlatform unit names remain synced source data, while internal unit names remain controlled by this system. The mapping is explicit: HostPlatform property + HostPlatform unit -> internal unit.

## 2026-04-23: Repair Test Frontend 401
Decision: Refresh `homestayERP-test` GitHub Actions secrets for Supabase URL/key/service key.

Reason:
Direct test Edge Function calls succeeded, but the deployed frontend showed HTTP 401. That points to the deployed page using an invalid or stale Supabase key.

## 2026-04-23: Persistent Release Memory
Decision: Add a dedicated release-process file and require future updates to memory files whenever project logic or release status changes.

Reason:
Important deployment and environment decisions should not depend on session memory. They must live in the repo so future work stays aligned.

## 2026-04-23: OpenAI OCR Pipeline
Decision: Keep invoice OCR behind Supabase Edge Functions and prefer OpenAI `gpt-4o-mini` when `OPENAI_API_KEY` is configured.

Reason:
The browser must not hold AI provider secrets. `gpt-4o-mini` supports image input and structured text output at low cost, which fits invoice/receipt extraction better than a large reasoning model. Business formatting still belongs in `process-invoice` so the final description is consistent.

## 2026-04-23: Fixed Utility Description Format
Decision: Utility/internet OCR descriptions must be normalized server-side to `[WB] UNIT Mon YY`, `[EB] UNIT Mon YY`, or `[INT] UNIT Mon YY`.

Reason:
AI extraction can vary. The accounting/reporting description must be stable, and utility bills received in the following month normally belong to the previous month unless the invoice explicitly states a different service period.

## 2026-04-23: Reservation Details In Manager Report
Decision: Add reservation detail cards to the report page for the selected unit/month.

Reason:
Managers need to verify booking income context directly in the report, not only see booking count and revenue summary.

## 2026-04-23: One Active HP Mapping Per Internal Unit
Decision: Hide already-paired internal units from other HostPlatform mapping dropdowns and allow unmapping to release them.

Reason:
Duplicate mappings can cause reservations and expenses to attach to the wrong internal unit. The UI should prevent accidental double pairing.

## 2026-04-23: Refresh Function Token On 401
Decision: Refresh the Supabase session token before Edge Function calls when it is near expiry, and retry once on HTTP 401.

Reason:
The test Edge Function works from direct calls, but the browser can keep an expired session token and receive 401 before the function runs.

## 2026-04-23: Owner Statement PDF Layout
Decision: Update report PDF export into an owner-statement layout with property + unit title, booking details, cleaning fee, expense details, homestay management fee, owner expenses, and owner net amount.

Reason:
The owner PDF needs to show how the final owner amount is derived, not only summarize expense categories.
