# FRONTLINE GPT WINDOW RUNTIME PLAN V2

STATUS=ACTIVE_RUNTIME_PLAN
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
WINDOW_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V3.md
SUPERSEDES=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md

## Current mode: Visual Production Reset

WINDOW_00=ACTIVE
WINDOW_01=ACTIVE_IMPLEMENTATION_GRADE_DESIGN
WINDOW_02=STANDBY_UNTIL_DESIGN_APPROVAL
WINDOW_03=ACTIVE_ONLY_FOR_EXISTING_PR30_REVIEW

## Immediate sequence

1. WINDOW_01 creates the new implementation-grade FRONTLINE design package.
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
