# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_REAUDIT_V2
ACTIVE_TASK=AUDIT_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V2
TASK_ARTIFACT=docs/audit/TASK_03_TRANSPORT_TERRAIN_REAUDIT_V1.md
HANDOFF_ARTIFACT=docs/learning/sprint01/HANDOFF_02_TRANSPORT_TERRAIN_TO_03_V1.md

## One current task

WINDOW_03 is the only active review window.

TASK=Independently inspect the V2 fresh PLAYER media and decide whether `PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION` is closed enough for the Sprint01 reproduction contract.

## Immutable audit input

RUNTIME_SOURCE_COMMIT=7eb34267d6fbbebd856001a7c17390c341835e59
WORLD_WORKFLOW_RUN=35204480034
WORLD_WORKFLOW_JOB=105146808996
WORLD_ARTIFACT_ID=10488929099
WORLD_ARTIFACT_SHA256=183e43456c951c8908c239c189f6f2cf12bbc865598c836b73146256656da500
GODOT_VERSION=4.7.1.stable.official.a13da4feb

Runtime/capture/artifact upload passed. The workflow's final evidence-writeback commit failed only due branch non-fast-forward race; do not classify that as runtime failure.

## Preserved runtime facts

- `CODE_EXECUTES=PASS`
- `WORLD_METHOD_RUNTIME=PASS`
- `WORLD_TO_MOVEMENT=PASS`
- `PLAYER_CHAIN_RUNTIME=PASS`
- `WORLD_AND_PLAYER_CHAIN_RUNTIME=PASS`
- `CAPTURE_ALIGNMENT=RENDER_FRAME_MARKERS`

These do not answer the visual audit by themselves.

## Direct media inspection required

03 must inspect artifact `10488929099`:
- `world_initial.png`
- `world_fire_feedback.png`
- `world_final.png`
- `world_reproduction.mp4`

Primary verdict:
`REAL_ENOUGH_WORLD_DELIVERY=PASS | FAIL`

Check whether road/shoulder/verge/junction/disturbed-ground/terrain/asset composition now reads as one physical region instead of a test layout.

## Visual baseline protection

The Sprint01 scene is learning/runtime evidence only. It is not the current highest FRONTLINE visual artifact and cannot replace the protected visual baseline.

Visual baseline index:
`docs/current/VISUAL_QUALITY_BASELINE.md`

Product visual contract:
`docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=HOLD_RUNTIME_CAPTURE_COMPLETE
WINDOW_03=ACTIVE_TRANSPORT_TERRAIN_REAUDIT

If 03 PASS:
`03 -> 00 Sprint01 final transfer decision`

If 03 FAIL:
`03 -> 02 concrete remaining PLAYER-visible defects only`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
