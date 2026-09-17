# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V40
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-17

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
WINDOW_RECOVERY_INDEX=docs/current/WINDOW_RECOVERY_INDEX.md
VISUAL_QUALITY_BASELINE=docs/current/VISUAL_QUALITY_BASELINE.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V3.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md

## Two independent authorities

CURRENT_TASK_AUTHORITY=this file + docs/current/ACTIVE_WORK.md
VISUAL_QUALITY_AUTHORITY=docs/current/VISUAL_QUALITY_BASELINE.md

The newest learning/runtime artifact is not automatically the best FRONTLINE visual result.
Sprint01 media may prove a method but must never replace the protected FRONTLINE visual baseline by recency alone.

## Branch authority

MAIN_BRANCH=main
MAIN_ROLE=CONTROL_STATE_AND_ROUTING
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_BRANCH_ROLE=SPRINT01_EVIDENCE_BUILD_RUNTIME_ARTIFACTS
LATEST_KNOWN_ACTIVE_BRANCH_HEAD=71a6a3bd2571eb1b78375eb3c9496c3f145843a4

Implementation/runtime facts come from the active branch. Routing/product-resume authority comes from main / Window 00.

## Canonical visual continuity

CANONICAL_PRODUCT_VISUAL_TARGET=FRONTLINE_GOLDEN_FRAME_V1
CANONICAL_PRODUCT_VISUAL_SPEC=docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md
CURRENT_BEST_VISUAL_REFERENCE_INDEX=docs/current/VISUAL_QUALITY_BASELINE.md

RETAINED_ENGINE_VISUAL_REFERENCE_1=dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07
RETAINED_ENGINE_VISUAL_REFERENCE_1_SCREENSHOT=artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png
RETAINED_ENGINE_VISUAL_REFERENCE_2=dev/godot-golden-scene-v1@ec8e49e27b278299ec5654b1094789c6a9d39f6e
RETAINED_ENGINE_VISUAL_REFERENCE_2_SCREENSHOT=artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png
RETAINED_ASSET_TOOL_REFERENCE=dev/reference-region-v1@5f2ff1c0e86553234490063e640cef8d0a2fb9f7

These references remain visual/reference evidence only; they are not restored as old product-direction authority.

## Current gate

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_REAUDIT_V2
ACTIVE_TASK=AUDIT_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V2
ACTIVE_TASK_ARTIFACT=docs/audit/TASK_03_TRANSPORT_TERRAIN_REAUDIT_V1.md
HANDOFF_ARTIFACT=docs/learning/sprint01/HANDOFF_02_TRANSPORT_TERRAIN_TO_03_V1.md
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

CURRENT_SPRINT_ARTIFACT_CLASS=LEARNING_AND_RUNTIME_EVIDENCE
CURRENT_SPRINT_ARTIFACT_IS_PRODUCT_VISUAL_BASELINE=NO

## Fresh Window 02 V2 runtime handed to 03

RUNTIME_SOURCE_COMMIT=7eb34267d6fbbebd856001a7c17390c341835e59
WORLD_WORKFLOW_RUN=35204480034
WORLD_WORKFLOW_JOB=105146808996
WORLD_ARTIFACT_ID=10488929099
WORLD_ARTIFACT_SHA256=183e43456c951c8908c239c189f6f2cf12bbc865598c836b73146256656da500
GODOT_VERSION=4.7.1.stable.official.a13da4feb

CODE_EXECUTES=PASS
WORLD_METHOD_RUNTIME=PASS
WORLD_TO_MOVEMENT=PASS
PLAYER_CHAIN_RUNTIME=PASS
WORLD_AND_PLAYER_CHAIN_RUNTIME=PASS
CAPTURE_ALIGNMENT=RENDER_FRAME_MARKERS

The workflow runtime/capture/artifact steps passed. Its final evidence-writeback step failed due a branch race/non-fast-forward condition and is not classified as a Godot/runtime failure.

## What V2 changed at PLAYER presentation layer

Without changing gameplay/passability authority, V2 presents:
- narrower visible asphalt;
- a visibly meandered main road inside the authoritative corridor;
- a more gradual branch departure;
- layered road/shoulder/verge transition;
- compact asymmetric disturbed ground rather than large radial hardstands;
- stronger off-corridor relief and drainage/bank cues;
- a small additional set of provenance-recorded physical roadside/built anchors.

Window 02 may not self-accept these changes. Window 03 must inspect the actual fresh screenshots/video.

## Current four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_01_STATUS=HOLD_STAGE4_COMPLETE
WINDOW_02_STATUS=HOLD_RUNTIME_CAPTURE_COMPLETE
WINDOW_03_STATUS=ACTIVE_TRANSPORT_TERRAIN_REAUDIT

## Window 03 decision boundary

Primary verdict:
`REAL_ENOUGH_WORLD_DELIVERY=PASS | FAIL`

03 must determine whether the previously failed boundary:
`PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`
has actually been closed at PLAYER layer.

Regression checks remain required for runtime identity, player causal chain, exact vehicle binding, unit readability, label occlusion, player world readability and capture-state alignment.

A Sprint01 PASS, if eventually granted, does NOT mean the learning scene meets FRONTLINE_GOLDEN_FRAME_V1 or becomes the project's visual baseline.

## Next route

NEXT=WINDOW_03_EXECUTE_TRANSPORT_TERRAIN_REAUDIT_V1
NEXT_IF_PASS=WINDOW_00_SPRINT01_FINAL_TRANSFER_DECISION
NEXT_IF_FAIL=WINDOW_02_REPAIR_ONLY_CONCRETE_REMAINING_PLAYER_WORLD_DEFECTS
NEXT_AFTER_SPRINT_PASS=FIRST_POST_RESTART_FRONTLINE_PRODUCT_SLICE

The first post-restart product slice must start from the Golden Frame visual contract and retained visual references while using Sprint-validated production methods. It must not inherit the learning scene as its product visual ancestor.

## Hard boundaries

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
CODE_EXISTS_NOT_RUNTIME_PROOF=YES
ASSET_COUNT_NOT_VISUAL_ACCEPTANCE=YES
PRIMITIVE_CLASS_REPLACEMENT_NOT_PLAYER_ACCEPTANCE=YES
OLD_VISUAL_BRANCH_AS_PRODUCT_DIRECTION_AUTHORITY=FORBIDDEN
OLD_VISUAL_ARTIFACT_AS_VISUAL_REFERENCE=ALLOWED
LEARNING_SCENE_AS_PRODUCT_VISUAL_BASELINE=FORBIDDEN
WINDOW_02_SELF_ACCEPTANCE=FORBIDDEN
PLAYER_LAYER_MUST_BE_REACHED=YES
PRODUCT_PRODUCTION_RESUME=NO
