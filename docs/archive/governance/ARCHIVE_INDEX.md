# FRONTLINE — PRODUCT-BRANCH GOVERNANCE ARCHIVE

STATUS=ARCHIVE_NON_AUTHORITATIVE
ARCHIVED_ON=2026-09-20
RULE=Nothing here is authority. Governance authority lives on `main`; the full supersession chains
are recorded in main's `docs/archive/governance/ARCHIVE_INDEX.md`.

This branch carried stale copies of the governance chain. They were moved here on the same day as
the main-branch archive pass, so that a window working in this product worktree cannot load
V1/V2-era rules as if they were current:

- `FRONTLINE_PROJECT_SYSTEM_V1.md`, `FRONTLINE_PROJECT_SYSTEM_V2.md`
  → current: main `docs/FRONTLINE_PROJECT_SYSTEM_V3.md`
- `GPT_MULTI_WINDOW_SYSTEM_V2.md`, `GPT_MULTI_WINDOW_SYSTEM_V3.md`
  → current: main `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
- `GPT_WINDOW_RUNTIME_PLAN_V1.md`
  → current: main `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md`

Note that this branch never received the multi-window collaboration V4 or the four-window V5
document at all — one more reason not to read governance from this branch.
