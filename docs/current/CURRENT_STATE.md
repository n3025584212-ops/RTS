# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V36
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-17

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
WINDOW_RECOVERY_INDEX=docs/current/WINDOW_RECOVERY_INDEX.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V3.md
BRANCH_RECYCLE_POLICY=docs/ops/BRANCH_RECYCLE_BIN.md
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Branch authority

MAIN_BRANCH=main
MAIN_ROLE=CONTROL_STATE_AND_ROUTING
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_BRANCH_ROLE=SPRINT01_EVIDENCE_BUILD_RUNTIME_ARTIFACTS
LATEST_KNOWN_ACTIVE_BRANCH_HEAD=7df9b3ecfde6f8e7c731a9f36fe6a0067836da55

BRANCH_COUNT_AFTER_RECYCLE=14
RECYCLED_BRANCH_COUNT=23
RECYCLE_TAG_PREFIX=recycle/2026-09-16/
RECYCLE_MANIFEST=docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md

IMPORTANT=main does not duplicate every learning-branch artifact. A window recovering state MUST refresh ACTIVE_BRANCH HEAD and read the branch artifacts listed in WINDOW_RECOVERY_INDEX.md.

If control and active-branch facts differ:
- branch-local implementation/evidence facts come from the active branch;
- task authority, routing, product-resume authority and conflict resolution come from Window 00 / main;
- no window may silently overwrite one with the other.

## Current phase

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_FIX
ACTIVE_TASK=REPAIR_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1
ACTIVE_TASK_ARTIFACT=docs/learning/sprint01/TASK_02_REAL_ENOUGH_WORLD_DELIVERY_FIX_V1.md
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

## Latest Window 03 re-audit

AUDIT_ARTIFACT=docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md
AUDIT_COMMIT=0d49839bf433d88018e81d0762eb0103a1e603e2
AUDITED_RUNTIME_SOURCE_COMMIT=73224323dea523e43d773b539912a700d286ddec
AUDITED_EVIDENCE_COMMIT=79e7b738816c1ba476f6b4a05505e97ab1b73491

RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
PLAYER_WORLD_READABILITY=PASS

REAL_ENOUGH_WORLD_DELIVERY=FAIL
CAPTURE_STATE_ALIGNMENT=FAIL
CAPTURE_STATE_ALIGNMENT_BLOCKING_TO_VISUAL_DECISION=NO

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_FAILED

The previous tiny-Abrams and persistent-label defects are closed. The remaining blocking boundary is only the PLAYER-facing physical-world presentation.

## Remaining visual defect

The fresh player camera still reads as a textured diagnostic/tabletop prototype because:
- playable ground appears as a large flat rectangular slab with a hard boundary;
- main/branch roads read as rectangular overlay slabs rather than terrain-integrated roads;
- circular hardstand/diagnostic surfaces remain visually dominant;
- real trees/houses/rocks decorate the world but do not eliminate the board-like silhouette;
- the visual overlay masks much of the parent terrain relief and surface transitions.

Real/provenance assets are present and on the runtime path, but asset presence is not PLAYER acceptance.

## Current four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_01_STATUS=HOLD_STAGE4_COMPLETE
WINDOW_02_STATUS=ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_FIX
WINDOW_02_TASK_ARTIFACT=docs/learning/sprint01/TASK_02_REAL_ENOUGH_WORLD_DELIVERY_FIX_V1.md
WINDOW_03_STATUS=HOLD_PENDING_REAL_ENOUGH_WORLD_RERUN

## Window 02 scope

Preserve:
- player input -> command -> movement -> contact -> combat -> feedback -> outcome;
- world topology/passability and constraints;
- functional anchors;
- exact Abrams/IFV identity;
- already-fixed Abrams readability and no persistent world-label occlusion;
- provenance-recorded delivery asset pool.

Repair only:
1. remove flat board/slab reading;
2. integrate terrain, roads, shoulders and defensive/hardstand surfaces into one coherent physical world;
3. stop relying on visually dominant BoxMesh/CylinderMesh overlay slabs for the delivered battlefield surface;
4. keep real vegetation/rock/house/textures already proven on the runtime path;
5. rerun fresh Godot 4.7.1 with external input;
6. fix initial/fire PNG temporal alignment during capture.

## Next route

NEXT=WINDOW_02_EXECUTE_REAL_ENOUGH_WORLD_DELIVERY_FIX_V1
NEXT_AFTER_FIX=WINDOW_03_AUDIT_REAL_ENOUGH_WORLD_DELIVERY_AND_CAPTURE_ALIGNMENT
NEXT_AFTER_AUDIT=WINDOW_00_SPRINT01_FINAL_TRANSFER_OR_REPAIR_DECISION
NEXT_AFTER_SPRINT_PASS=FIRST_POST_RESTART_FRONTLINE_PRODUCT_SLICE

## Hard boundaries

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
CODE_EXISTS_NOT_RUNTIME_PROOF=YES
ASSET_COUNT_NOT_VISUAL_ACCEPTANCE=YES
REAL_TEXTURE_ON_BOX_NOT_REAL_ENOUGH_WORLD_BY_ITSELF=YES
GREYBOX_AS_PRODUCTION_DELIVERY=FORBIDDEN
OLD_VISUAL_BRANCH_AS_CURRENT_AUTHORITY=FORBIDDEN
UNKNOWN_ALLOWED=YES
PLAYER_LAYER_MUST_BE_REACHED=YES
RECYCLED_TAG_NOT_CURRENT_AUTHORITY=YES
