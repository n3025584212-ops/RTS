# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V38
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-17

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
WINDOW_RECOVERY_INDEX=docs/current/WINDOW_RECOVERY_INDEX.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V3.md
BRANCH_RECYCLE_POLICY=docs/ops/BRANCH_RECYCLE_BIN.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Branch authority

MAIN_BRANCH=main
MAIN_ROLE=CONTROL_STATE_AND_ROUTING
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_BRANCH_ROLE=SPRINT01_EVIDENCE_BUILD_RUNTIME_ARTIFACTS
LATEST_KNOWN_ACTIVE_BRANCH_HEAD=0188ff847b4407b33137e3b38c9addf26fb05016

Implementation/runtime facts come from the active branch. Routing/product-resume authority comes from main / Window 00.

## Current gate

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_FIX
ACTIVE_TASK=REPAIR_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V1
ACTIVE_TASK_ARTIFACT=docs/learning/sprint01/TASK_02_TRANSPORT_TERRAIN_INTEGRATION_FIX_V1.md
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

## Latest Window 03 re-audit

AUDIT_ARTIFACT=docs/audit/AUDIT_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1.md
AUDIT_COMMIT=ec3536a5de8ab10fbec891cf59d94bd891a2bf5b
AUDITED_RUNTIME_SOURCE_COMMIT=b0fe6d8b1de747606138a9ce1b28b3541b8c464a
AUDITED_RUN_ID=35185311167
AUDITED_ARTIFACT_ID=10481469643
AUDITED_ARTIFACT_SHA256=a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f

RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
PLAYER_WORLD_READABILITY=PASS
CAPTURE_STATE_ALIGNMENT=PASS

REAL_ENOUGH_WORLD_DELIVERY=FAIL
FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION
REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_STILL_FAILED

## Remaining PLAYER-visible defect

The world no longer exposes the old rectangular outer board boundary and no longer uses BoxMesh road slabs/CylinderMesh hardstands, but the actual PLAYER result still reads as a test battlefield because:
- the main road remains a broad, clean, straight-edged asphalt strip dominating the frame;
- the branch/junction remains hard and near-orthogonal;
- hardstand/disturbed ground still reads as radial decal geometry;
- surface transitions are abrupt and semantic-zone-like;
- central terrain relief and roadside physical cues are too weak;
- real houses/vegetation/rocks remain sparse islands around transport geometry.

Implementation primitive class changes are not PLAYER acceptance.

## Current four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_01_STATUS=HOLD_STAGE4_COMPLETE
WINDOW_02_STATUS=ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX
WINDOW_03_STATUS=HOLD_PENDING_TRANSPORT_TERRAIN_RERUN

## Window 02 scope

Preserve all accepted gameplay, world-causality, exact-vehicle, readability and capture-state results.

Repair only the visible physical integration:
1. break up clean road edges with shoulder/verge variation;
2. visually grade branch/junction geometry without changing authoritative corridor semantics;
3. replace radial hardstand/decal reading with context-shaped compacted/disturbed ground;
4. add terrain relief and roadside physical cues without changing passability semantics;
5. integrate houses/vegetation/rocks with road and terrain rather than sparse decorative islands;
6. rerun fresh Godot 4.7.1 and return actual aligned PLAYER media.

## Next route

NEXT=WINDOW_02_EXECUTE_TRANSPORT_TERRAIN_INTEGRATION_FIX_V1
NEXT_AFTER_FIX=WINDOW_03_REAUDIT_REAL_ENOUGH_WORLD_DELIVERY
NEXT_AFTER_AUDIT=WINDOW_00_SPRINT01_FINAL_TRANSFER_OR_REPAIR_DECISION
NEXT_AFTER_SPRINT_PASS=FIRST_POST_RESTART_FRONTLINE_PRODUCT_SLICE

## Hard boundaries

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
CODE_EXISTS_NOT_RUNTIME_PROOF=YES
ASSET_COUNT_NOT_VISUAL_ACCEPTANCE=YES
PRIMITIVE_CLASS_REPLACEMENT_NOT_PLAYER_ACCEPTANCE=YES
OLD_VISUAL_BRANCH_AS_CURRENT_AUTHORITY=FORBIDDEN
PLAYER_LAYER_MUST_BE_REACHED=YES
PRODUCT_PRODUCTION_RESUME=NO
