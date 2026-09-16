# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACTIVE_BRANCH_MIRROR_OF_CONTROL_STATE
PROJECT=FRONTLINE
STATE_VERSION=V33
CONTROL_AUTHORITY=main:docs/current/CURRENT_STATE.md
BRANCH_ROLE=SPRINT01_EVIDENCE_BUILD_RUNTIME_ARTIFACTS

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
WINDOW_RECOVERY_INDEX=docs/current/WINDOW_RECOVERY_INDEX.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V3.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Authority rule

This branch-local file prevents a window checked out on the learning branch from recovering obsolete project state.

Final control/routing authority remains `main` / Window 00.
Branch-local implementation, audit and runtime facts are authoritative for work performed here, but product-resume and routing decisions are not self-authorized by this branch.

## Current phase

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_FIX
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

## Latest evidence

WORLD_CAUSAL_DECOMPOSITION_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
WORLD_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f
WORLD_REPRODUCTION_RUNTIME_SOURCE_COMMIT=edf8cede10cea24a6218beb73bcca14ef424f5c7
WORLD_REPRODUCTION_EVIDENCE_COMMIT=03a56be1b0abfaf2248f23b4f9766ebd60aec27e
WORLD_REPRODUCTION_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac

RUNTIME_EXECUTION_VERDICT=PASS
GODOT_4_7_1_RUNTIME=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
WORLD_METHOD_SOURCE_PATH=PASS
WORLD_METHOD_CAUSAL_EXECUTION=PASS
PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
CAPTURE_STATE_ALIGNMENT=PASS

## Current failed boundary

WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY
PLAYER_UNIT_READABILITY=FAIL
WORLD_LABEL_OCCLUSION=FAIL
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=FAIL

The previous runner blocker is closed for this gate. The current failure is downstream at PLAYER delivery, not runtime infrastructure.

## Current windows

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_01_STATUS=HOLD_STAGE4_COMPLETE
WINDOW_02_STATUS=ACTIVE_PLAYER_WORLD_DELIVERY_FIX
WINDOW_03_STATUS=HOLD_PENDING_REPAIRED_RUNTIME

## Window 02 repair scope

Preserve:
- topology/passability coupling;
- functional anchors and constraint rules;
- exact Abrams/IFV identity;
- player input -> command -> movement -> combat -> feedback -> outcome semantics;
- fresh player-camera capture process.

Repair only:
1. exact Abrams player readability;
2. occluding world labels;
3. primitive/placeholder terrain/material/vegetation/built-content presentation.

Then rerun fresh Godot 4.7.1 evidence and return to Window 03.

## Repository hygiene

Current active branches:
- `main`
- `learning/sprint01-end-to-end-rts-production`

First-pass cleanup reduced branches from 37 to 14. Recycled historical branch heads are preserved as tags under `recycle/2026-09-16/...` according to the main branch recycle policy.

## Next route

NEXT=WINDOW_02_PLAYER_WORLD_DELIVERY_FIX
NEXT_AFTER_FIX=WINDOW_03_REAUDIT_REPAIRED_WORLD_PLAYER_ARTIFACT
NEXT_AFTER_AUDIT=WINDOW_00_SPRINT01_TRANSFER_OR_REPAIR_DECISION

## Historical boundary

Battle01, Prototype B, Golden Scene, River Town, Reference Region and local-high-fidelity work remain historical/reference evidence/tool pools and do not automatically regain current product authority.
