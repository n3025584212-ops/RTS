# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V43
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-20
USER_DIRECTION_OVERRIDE=STOP_TEST_SCENE_VISUAL_ITERATION_AND_RESUME_HIGH_FIDELITY_PRODUCT_SLICE

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
VISUAL_QUALITY_BASELINE=docs/current/VISUAL_QUALITY_BASELINE.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md

## Active product route

ACTIVE_ISSUE=#41
ACTIVE_BRANCH=product/frontline-high-fidelity-slice-v1
ACTIVE_BRANCH_BASE=dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07
ACTIVE_BRANCH_VERIFIED_HEAD=7a4d688
ACTIVE_PRODUCT_SCENE=res://scenes/production/RiverTownVisualSlice.tscn
ACTIVE_TASK_ARTIFACT=docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md
PRODUCT_PRODUCTION_RESUME=YES_HIGH_FIDELITY_SLICE_ONLY
GATE_B_EVIDENCE=product/frontline-high-fidelity-slice-v1::docs/visual_baseline/gate_b_20260920/EVIDENCE_RECORD.md
GATE_D2_EVIDENCE=product/frontline-high-fidelity-slice-v1::docs/visual_baseline/gate_d2_20260920/EVIDENCE_RECORD.md

## Learning route status

SPRINT01_ISSUE=#39
SPRINT01_STATUS=STOPPED_AS_ACTIVE_PRODUCT_CONSTRUCTION_ROUTE
SPRINT01_SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SPRINT01_SCENE_CLASS=ARCHIVED_LEARNING_AND_RUNTIME_EVIDENCE_ONLY
SPRINT01_FURTHER_PLAYER_VISUAL_ITERATION=FORBIDDEN_UNLESS_USER_REOPENS

Validated Sprint01 gameplay/runtime evidence may be transferred into the high-fidelity product scene. The learning scene itself must not be extended into the product scene.

## Visual authority

CANONICAL_PRODUCT_VISUAL_TARGET=FRONTLINE_GOLDEN_FRAME_V1
CANONICAL_PRODUCT_VISUAL_SPEC=docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md
LOCAL_PRODUCT_VISUAL_FLOOR=artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png
LOCAL_PRODUCT_VISUAL_FLOOR_SOURCE=dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07

RETAINED_ENGINE_REFERENCE_GOLDEN_SCENE=dev/godot-golden-scene-v1@ec8e49e27b278299ec5654b1094789c6a9d39f6e
RETAINED_ASSET_TOOL_REFERENCE=dev/reference-region-v1@5f2ff1c0e86553234490063e640cef8d0a2fb9f7

## Product construction rule

The high-fidelity River Town scene is the product construction mother scene.
Gameplay integration must move into this scene without degrading its terrain/material/architecture/vegetation/lighting/atmosphere/water/camera pipeline.

NO_BOX_PROXY_BATTLEFIELD=YES
NO_CYLINDER_PROXY_BATTLEFIELD=YES
NO_COLOR_BLOCK_ENVIRONMENT=YES
NO_DEBUG_LABEL_DOMINATED_CAPTURE=YES
NO_LEARNING_SCENE_AS_PRODUCT_ANCESTOR=YES
NO_VISUAL_REGRESSION_BELOW_RIVER_TOWN_WITHOUT_EXPLICIT_APPROVAL=YES

## Baseline gate result

BASELINE_REPRODUCTION_STATUS=PASS
BASELINE_WORKFLOW=FRONTLINE River Town Visual Slice
BASELINE_RUN_NUMBER=7
BASELINE_RUN_ID=35325714573
BASELINE_RUN_CONCLUSION=SUCCESS
BASELINE_RUN_HEAD=7032c91ccd9c58244ce36f944558fa3dd4727d01
BASELINE_RUN_COMPLETED_AT=2026-09-18T08:49:23Z

The fresh River Town baseline reproduction gate is closed. CI success proves the technical baseline pipeline is functioning; it is not final visual/product acceptance.

## Immediate execution

CURRENT_GATE=MULTI_FORMATION_SELECTION (Gate D2)
GATE_B_STATUS=GATE_B_PASS
GATE_C_STATUS=CLOSED (PASS_WITH_ONE_CONDITION; condition closed by product commit 394460d)
GATE_D1_STATUS=GATE_D1_PASS (product::docs/current/GATE_D1_INDEPENDENT_AUDIT_V1.md, 49318e7)
GATE_D2_STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT (product::docs/visual_baseline/gate_d2_20260920/EVIDENCE_RECORD.md, 9d026ed)
CURRENT_TASK=INTEGRATE_VALIDATED_MULTI_FORMATION_SELECTION_INTO_RIVER_TOWN

Execution contract:
1. Keep `res://scenes/production/RiverTownVisualSlice.tscn` as the mother scene.
2. Transfer only validated gameplay/runtime logic into River Town.
3. Preserve the high-fidelity terrain, architecture, vegetation, PBR materials, lighting, atmosphere, water and camera pipeline.
4. Produce a fresh Godot 4.7.1 / Forward+ / 1920x1080 runtime capture with a controllable armored unit visibly operating inside River Town.
4b. Gate D2: the capture must show platoon selection (single click and drag box) and a group order operating on several real vehicles at once.
5. Compare the fresh runtime against the retained River Town visual floor before advancing.

## Four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_01_STATUS=HOLD_LEARNING_EVIDENCE_ONLY
WINDOW_02_STATUS=ACTIVE_MULTI_FORMATION_SELECTION
WINDOW_03_STATUS=HOLD_PENDING_GATE_D2_AUDIT

## Next route

NEXT=WINDOW_03_INDEPENDENT_AUDIT_OF_GATE_D2 (evidence complete at 7a4d688, CI 35488489417 success) THEN user selects: human playtest checkpoint OR Gate D3 (RED force and victory conditions)
NOTE=D-gate evidence policy going forward: archive raw run log alongside JSON; driver output paths migrate to user:// (D1 audit non-blocking suggestions)

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
PLAYER_LAYER_MUST_BE_REACHED=YES
