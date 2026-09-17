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
4. `docs/current/VISUAL_QUALITY_BASELINE.md`
5. refresh both main and active-branch HEADs
6. inspect the current task/audit artifacts below.

Never infer visual quality from artifact recency. Always distinguish current task evidence from FRONTLINE visual baseline.

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

Do not reopen without regression evidence:
- player causal chain;
- exact Abrams/IFV binding;
- Abrams readability;
- persistent-label removal;
- PLAYER world readability;
- capture-state alignment;
- Stage 4/world-to-movement causal results.

## Only remaining Sprint repair boundary

`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

Window 02 repairs road/shoulder/verge/junction/hardstand/terrain/asset integration while preserving corridor/passability and gameplay semantics.

After fresh runtime:
`02 -> 03 audit REAL_ENOUGH_WORLD_DELIVERY -> 00 final Sprint01 decision`

## Visual continuity checkpoint

CANONICAL_PRODUCT_VISUAL_TARGET=`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`
VISUAL_BASELINE_INDEX=`docs/current/VISUAL_QUALITY_BASELINE.md`

Retained engine references:
- `dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`
- `dev/godot-golden-scene-v1@ec8e49e27b278299ec5654b1094789c6a9d39f6e`
- `dev/reference-region-v1@5f2ff1c0e86553234490063e640cef8d0a2fb9f7`

`Sprint01WorldReproduction` media is `LEARNING_AND_RUNTIME_EVIDENCE`, not the product visual baseline.

## Historical audited artifact

- source `b0fe6d8b1de747606138a9ce1b28b3541b8c464a`
- run `35185311167`
- artifact `10481469643`
- SHA256 `a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f`

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA or immutable Actions run/artifact identity;
- named artifact path/reference;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker;
- correct classification as task/runtime evidence versus visual baseline/product result.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
