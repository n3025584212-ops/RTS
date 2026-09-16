# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V33
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-16

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
LATEST_KNOWN_ACTIVE_BRANCH_HEAD=6dfe56da2c87b62fcb581c06b728c965d4e47bac

BRANCH_COUNT_AFTER_RECYCLE=14
RECYCLED_BRANCH_COUNT=23
RECYCLE_TAG_PREFIX=recycle/2026-09-16/
RECYCLE_MANIFEST=docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md

IMPORTANT=main does not duplicate every learning-branch artifact. A window recovering state MUST read this file and then refresh ACTIVE_BRANCH HEAD plus the branch artifacts listed in WINDOW_RECOVERY_INDEX.md.

If control and active-branch facts appear different:
- branch-local implementation/evidence facts come from the active branch;
- task authority, routing, product-resume authority and conflict resolution come from Window 00 / main;
- no window may silently overwrite one with the other.

## Current phase

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_FIX
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

The restart remains active. Old Battle01, Prototype B, Golden Scene, River Town, Reference Region and local-high-fidelity work remain historical evidence/tool pools, not current product-direction authority.

## Passed evidence and execution

PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
CHAIN=`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

WORLD_CAUSAL_DECOMPOSITION=PASS_FOR_REPRODUCTION_INPUT
WORLD_CAUSAL_DECOMPOSITION_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
WORLD_METHOD_AUDIT=PASS_WITH_DOWNGRADES
WORLD_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f

WORLD_REPRODUCTION_RUNTIME_SOURCE_COMMIT=edf8cede10cea24a6218beb73bcca14ef424f5c7
WORLD_REPRODUCTION_EVIDENCE_COMMIT=03a56be1b0abfaf2248f23b4f9766ebd60aec27e
WORLD_REPRODUCTION_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac
WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY

RUNTIME_EXECUTION_VERDICT=PASS
GODOT_4_7_1_RUNTIME=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
WORLD_METHOD_SOURCE_PATH=PASS
WORLD_METHOD_CAUSAL_EXECUTION=PASS
PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
CAPTURE_STATE_ALIGNMENT=PASS

The previous runner/infrastructure blocker is closed for this gate because a fresh successful hosted runtime now exists.

## Current failure boundary

PLAYER_UNIT_READABILITY=FAIL
WORLD_LABEL_OCCLUSION=FAIL
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=FAIL

The current world is causally structured and runtime-valid, but still reads as a low-poly/diagnostic placeholder world at the PLAYER camera. Primitive/prototype content still dominates parts of terrain/material/vegetation/built-content presentation.

This failure does NOT invalidate the already-proven topology/passability, anchor, constraint, semantic-surface, vegetation-distribution, camera/environment or player/combat causal methods.

## Current four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_00_TASK=Maintain one shared state, branch hygiene, evidence gates and final transfer authority.

WINDOW_01_STATUS=HOLD_STAGE4_COMPLETE
WINDOW_01_TASK=Do not extend theory unless a later audit identifies a specific missing evidence edge.

WINDOW_02_STATUS=ACTIVE_PLAYER_WORLD_DELIVERY_FIX
WINDOW_02_TASK=Preserve the proven causal/world method and repair only the failed PLAYER output boundary: unit readability, label occlusion, and primitive/placeholder world presentation. Then rerun fresh Godot 4.7.1 evidence.

WINDOW_03_STATUS=HOLD_PENDING_REPAIRED_RUNTIME
WINDOW_03_TASK=After Window 02 produces repaired fresh screenshots/video/logs, independently re-audit PLAYER delivery without reopening already-proven source/runtime semantics unless changed.

## Required Window 02 repair

1. make the exact Abrams visibly coherent/readable at the same battlefield scale as the IFV;
2. remove/shrink/reposition occluding world labels;
3. replace/upgrade primitive semantic world content/material/vegetation presentation until the fresh player camera no longer reads as a diagnostic placeholder scene;
4. preserve current topology/passability, functional-anchor, constraint and combat semantics;
5. rerun the exact player chain in Godot 4.7.1;
6. return fresh initial/fire/final screenshots + continuous video + runtime log to Window 03.

## Next route

NEXT=WINDOW_02_PLAYER_WORLD_DELIVERY_FIX
NEXT_AFTER_FIX=WINDOW_03_REAUDIT_REPAIRED_WORLD_PLAYER_ARTIFACT
NEXT_AFTER_AUDIT=WINDOW_00_SPRINT01_TRANSFER_OR_REPAIR_DECISION
NEXT_AFTER_SPRINT_PASS=FIRST_POST_RESTART_FRONTLINE_PRODUCT_SLICE

## Hard boundaries

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
CODE_EXISTS_NOT_RUNTIME_PROOF=YES
SCREENSHOT_NOT_HIDDEN_CAUSAL_PROOF=YES
GREYBOX_AS_PRODUCTION_DELIVERY=FORBIDDEN
OLD_VISUAL_BRANCH_AS_CURRENT_AUTHORITY=FORBIDDEN
UNKNOWN_ALLOWED=YES
VERSION_IDENTITY_REQUIRED=YES
COUNTEREXAMPLE_SEARCH_REQUIRED_FOR_GENERALIZATION=YES
PLAYER_LAYER_MUST_BE_REACHED=YES
RECYCLED_TAG_NOT_CURRENT_AUTHORITY=YES
