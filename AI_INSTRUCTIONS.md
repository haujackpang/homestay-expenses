# AI Instructions

Before making any code or database change, read and follow:
- `PROJECT_OVERVIEW.md`
- `BUSINESS_RULES.md`
- `DECISIONS_LOG.md`
- `TASK_CONTEXT.md`
- `RELEASE_PROCESS.md`

Strict behavior rules:
- Do NOT invent business logic.
- Do NOT remove validations unless explicitly approved.
- Prefer minimal safe changes.
- Ask or report first when logic is unclear or conflicts with code.
- Always align with `BUSINESS_RULES.md`.
- Protect secrets. Never print secret values in chat, commits, or docs.
- Keep test and live environments separate.
- When working on test, push only to `homestayERP-test` unless instructed otherwise.
- Live repo is `homestay-expenses`; `homestayERP-prod` is obsolete.
- If the user says push to live, promote only the tested code/workflow/Edge Functions/required idempotent DB structure. Do not copy or sync table data between test and live.
- After changes, run a syntax check or the closest practical verification.
- Update the memory files whenever business rules, release flow, task scope, or important decisions change.
- Do not rely on chat history alone for long-lived project rules.
