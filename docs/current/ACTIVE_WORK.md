# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_FIX
ACTIVE_TASK=REPAIR_SPRINT01_PLAYER_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/learning/sprint01/TASK_02_PLAYER_WORLD_DELIVERY_FIX_V1.md
TASK_ROUTING_COMMIT=5188884e4a1d04e78164a895296f2466af54658c

## One current task

WINDOW_02 is the only active implementation window.

TASK=Repair the PLAYER-facing world delivery of the already-running Sprint01 world reproduction without redesigning already-proven causal methods.

SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SCRIPT=res://scripts/learning/sprint01/sprint01_world_reproduction.gd
RUNTIME_RESULT=docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md
LATEST_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md

## Passed runtime/method facts — preserve

RUNTIME_EXECUTION_VERDICT=PASS
GODOT_4_7_1_RUNTIME=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
WORLD_METHOD_SOURCE_PATH=PASS
WORLD_METHOD_CAUSAL_EXECUTION=PASS
PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
CAPTURE_STATE_ALIGNMENT=PASS

## Current blocking PLAYER failures

PLAYER_UNIT_READABILITY=FAIL
WORLD_LABEL_OCCLUSION=FAIL
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=FAIL

Window 03 verdict:
`WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY`

## Window 02 repair scope

Do only this:

1. make the exact Abrams visibly coherent/readable at battlefield scale;
2. remove/shrink/reposition occluding world labels;
3. replace or materially upgrade primitive semantic terrain/material/vegetation/built-content presentation until the player camera no longer reads as a diagnostic placeholder scene;
4. preserve topology/passability, anchor/constraint and player/combat semantics;
5. rerun fresh Godot 4.7.1 runtime with exact sanctioned combat assets and real external input;
6. produce fresh initial/fire/final screenshots, continuous video and runtime logs.

Do not restart Stage 4 theory. Do not restore old Golden Scene/River Town/Reference Region coordinates as current world authority. Historical/reference branches may only supply provenance-valid assets, tools, and evidence.

## Latest checkpoints

WORLD_CAUSAL_DECOMPOSITION_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
WORLD_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f
WORLD_REPRODUCTION_RUNTIME_SOURCE_COMMIT=edf8cede10cea24a6218beb73bcca14ef424f5c7
WORLD_REPRODUCTION_EVIDENCE_COMMIT=03a56be1b0abfaf2248f23b4f9766ebd60aec27e
WORLD_REPRODUCTION_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_PLAYER_WORLD_DELIVERY_FIX
WINDOW_03=HOLD_PENDING_REPAIRED_RUNTIME

After repaired fresh runtime:
`02 -> 03 independent repaired PLAYER artifact audit -> 00 transfer or repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
