# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_FIX

## One current task

WINDOW_02 is the only active implementation window for the current gate.

TASK=Repair the PLAYER-facing world delivery of the already-running Sprint01 world reproduction without redesigning the already-proven causal methods.

SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SCRIPT=res://scripts/learning/sprint01/sprint01_world_reproduction.gd
RUNTIME_RESULT=docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md
LATEST_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md

## What is already proven

Fresh hosted Godot 4.7.1 runtime now exists and Window 03 independently audited it.

Accepted:

- `RUNTIME_EXECUTION_VERDICT=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `WORLD_METHOD_SOURCE_PATH=PASS`
- `WORLD_METHOD_CAUSAL_EXECUTION=PASS`
- `PLAYER_CAUSAL_CHAIN_RUNTIME=PASS`
- `CAPTURE_STATE_ALIGNMENT=PASS`

The following methods are not to be redesigned just because the PLAYER output failed:

- topology/passability coupling;
- functional anchors;
- named constraint layers;
- semantic surface binding in the narrow causal sense;
- vegetation region + straggler distribution in the narrow causal sense;
- frozen camera/environment acceptance inputs;
- exact Abrams/IFV identity;
- player input -> command -> movement -> combat -> feedback -> outcome chain.

## Current failed boundary

Window 03 verdict:

`WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY`

Blocking PLAYER failures:

- `PLAYER_UNIT_READABILITY=FAIL`
- `WORLD_LABEL_OCCLUSION=FAIL`
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`
- `PLAYER_WORLD_READABILITY=FAIL`

The world is more causally structured than the old Plane/Box test scene, but still reads as a low-poly diagnostic/prototype world. Primitive content such as generated coarse textures, CylinderMesh earthworks/hardstands/tree parts, SphereMesh rocks and coarse procedural surfaces still dominates the delivered look.

## Window 02 repair scope

Do only this:

1. make the exact Abrams visibly coherent/readable at the player battlefield scale;
2. remove, shrink or reposition world labels that obscure the battle;
3. replace or upgrade primitive semantic terrain/material/vegetation/built-content presentation with sufficiently real, provenance-recorded assets/content or a pipeline whose actual player-camera result is no longer placeholder-like;
4. preserve current world topology, transport/corridor clearance, anchor/constraint logic and player/combat semantics;
5. rerun fresh Godot 4.7.1 runtime with exact sanctioned combat assets and external player input;
6. produce fresh initial/fire/final screenshots, continuous video and runtime logs.

Do not restart Stage 4 learning from scratch. Do not restore old Golden Scene/River Town/Reference Region coordinates as the new world. Those branches are evidence/tool pools only.

## Latest evidence checkpoints

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

After repaired fresh runtime evidence:

`02 -> 03 independent repaired PLAYER artifact audit -> 00 transfer or repair decision`

## Repository hygiene

Branches were reduced from 37 to 14 on 2026-09-16.

Recycled historical heads are preserved as tags under:

`recycle/2026-09-16/...`

Policy:
`docs/ops/BRANCH_RECYCLE_BIN.md`

Do not resurrect a recycled or reference branch as current authority without Window 00 routing.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
