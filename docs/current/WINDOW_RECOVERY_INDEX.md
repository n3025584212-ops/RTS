# FRONTLINE — Window Recovery Index

STATUS=ACTIVE_RECOVERY_INDEX
PROJECT=FRONTLINE
CONTROL_AUTHORITY=main
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production

## Recovery rule

Any recovered window must read, in order:
1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. refresh both main and active-branch HEADs
5. inspect the current task/audit artifacts below.

Implementation/runtime facts belong to the active branch. Routing/product-resume authority belongs to main / Window 00.

## Current checkpoint

CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_FIX
ACTIVE_ISSUE=#39

Latest 03 audit:
`docs/audit/AUDIT_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1.md`

Audit commit:
`ec3536a5de8ab10fbec891cf59d94bd891a2bf5b`

Current 02 task:
`docs/learning/sprint01/TASK_02_TRANSPORT_TERRAIN_INTEGRATION_FIX_V1.md`

Task-routing commit:
`0188ff847b4407b33137e3b38c9addf26fb05016`

## Current windows

`00 = ACTIVE_CONTROL`
`01 = HOLD_STAGE4_COMPLETE`
`02 = ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX`
`03 = HOLD_PENDING_TRANSPORT_TERRAIN_RERUN`

## Preserved passes

Do not reopen without fresh regression evidence:
- player causal chain;
- exact Abrams/IFV binding;
- Abrams readability;
- persistent-label removal;
- PLAYER world readability;
- capture-state alignment;
- Stage 4/world-to-movement causal results.

## Only remaining repair boundary

`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

Window 02 must repair the visible road/shoulder/verge/junction/hardstand/terrain/asset integration while preserving authoritative corridor/passability semantics.

After fresh runtime:
`02 -> 03 audit REAL_ENOUGH_WORLD_DELIVERY -> 00 final Sprint01 decision`

## Historical checkpoint retained

Audited source/run/artifact that produced the current failure:
- source `b0fe6d8b1de747606138a9ce1b28b3541b8c464a`
- run `35185311167`
- artifact `10481469643`
- SHA256 `a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f`

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA or immutable Actions run/artifact identity;
- named artifact path/reference;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
