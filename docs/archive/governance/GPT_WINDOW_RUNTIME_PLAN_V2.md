# FRONTLINE GPT WINDOW RUNTIME PLAN V2

ARCHIVED=2026-09-20 — non-authoritative. Retired with the window system; superseded by docs/FRONTLINE_EXECUTION_MODEL_V1.md
STATUS=ACTIVE_RUNTIME_PLAN
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
SUPERSEDES=docs/archive/governance/GPT_WINDOW_RUNTIME_PLAN_V1.md

## Mode and allocation

The current mode, window allocation and immediate sequence are stated in exactly one place:
`docs/current/CURRENT_STATE.md`. They are deliberately not repeated here — this section used to
carry a snapshot of the "Visual Production Reset" mode and drifted out of date.

## Standing sequence

The role sequence below holds at every gate; only the current instance of it lives in
`docs/current/CURRENT_STATE.md`.

1. WINDOW_01 produces the implementation-grade design package for the current product question.
2. User explicitly approves/rejects/revises it.
3. After approval, WINDOW_00 freezes that package as current visual/production authority.
4. WINDOW_02 implements the approved scene with logic and presentation together.
5. WINDOW_03 checks design compliance plus runtime/regressions.
6. Human product judgment occurs only when a sufficiently representative playable exists.

## Parallel exception

PR #30 may finish independent technical review because it already exists, but it does not authorize further greybox/content expansion under the old visual direction.

## Production rule

No new production batch begins from old design images.
No feature is delivered as boxes or abstract placeholders when the approved design specifies concrete visible content.
