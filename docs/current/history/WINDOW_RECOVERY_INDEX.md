# FRONTLINE — Window Recovery Index

ARCHIVED=2026-09-20 — non-authoritative, historical decision record; chains in docs/archive/governance/ARCHIVE_INDEX.md

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
6. inspect the current handoff/audit artifacts below.

Never infer visual quality from artifact recency. Always distinguish current Sprint evidence from the FRONTLINE visual baseline.

## Current checkpoint

CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_REAUDIT_V2
ACTIVE_ISSUE=#39

Current 02 -> 03 handoff:
`docs/learning/sprint01/HANDOFF_02_TRANSPORT_TERRAIN_TO_03_V1.md`

Current 03 task:
`docs/audit/TASK_03_TRANSPORT_TERRAIN_REAUDIT_V1.md`

Immutable runtime identity:
- source `7eb34267d6fbbebd856001a7c17390c341835e59`
- run `35204480034`
- job `105146808996`
- artifact `10488929099`
- SHA256 `183e43456c951c8908c239c189f6f2cf12bbc865598c836b73146256656da500`
- Godot `4.7.1.stable.official.a13da4feb`

The workflow's runtime/capture/artifact steps passed. Its final evidence commit failed only because of a non-fast-forward branch race.

## Current windows

`00 = ACTIVE_CONTROL`
`01 = HOLD_STAGE4_COMPLETE`
`02 = HOLD_RUNTIME_CAPTURE_COMPLETE`
`03 = ACTIVE_TRANSPORT_TERRAIN_REAUDIT`

## Preserved runtime results

- world method runtime;
- player causal chain;
- exact Abrams/IFV binding;
- external input;
- movement/contact/combat/outcome;
- capture-state alignment.

03 must still inspect the actual screenshots/video before deciding the remaining visual boundary.

## Current independent decision boundary

`REAL_ENOUGH_WORLD_DELIVERY=PASS | FAIL`

Specifically re-audit:
`PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

After 03:
- PASS -> `00 Sprint01 final transfer decision`
- FAIL -> `02 concrete remaining PLAYER-visible repair only`

## Visual continuity checkpoint

CANONICAL_PRODUCT_VISUAL_TARGET=`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`
VISUAL_BASELINE_INDEX=`docs/current/VISUAL_QUALITY_BASELINE.md`

Retained engine visual/reference evidence:
- `dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`
- `dev/godot-golden-scene-v1@ec8e49e27b278299ec5654b1094789c6a9d39f6e`
- `dev/reference-region-v1@5f2ff1c0e86553234490063e640cef8d0a2fb9f7`

`Sprint01WorldReproduction` media is `LEARNING_AND_RUNTIME_EVIDENCE`, not the product visual baseline.

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA or immutable Actions run/artifact identity;
- named artifact path/reference;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker;
- correct classification as task/runtime evidence versus visual baseline/product result.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
