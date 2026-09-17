# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_FIX
ACTIVE_TASK=REPAIR_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/learning/sprint01/TASK_02_REAL_ENOUGH_WORLD_DELIVERY_FIX_V1.md

## One current task

WINDOW_02 is the only active implementation window.

Latest Window 03 re-audit:
`docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md`
commit `0d49839bf433d88018e81d0762eb0103a1e603e2`

Passed and frozen unless the next repair regresses them:
- `RUNTIME_EVIDENCE_IDENTITY=PASS`
- `PLAYER_CAUSAL_CHAIN_PRESERVED=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `PLAYER_UNIT_READABILITY=PASS`
- `WORLD_LABEL_OCCLUSION=PASS`
- `PLAYER_WORLD_READABILITY=PASS`

Remaining blocker:
`REAL_ENOUGH_WORLD_DELIVERY=FAIL`

Nonblocking evidence defect to repair on rerun:
`CAPTURE_STATE_ALIGNMENT=FAIL`

## Window 02 scope

Repair only the physical-world presentation boundary:
1. remove the flat board/slab reading;
2. integrate terrain, roads, shoulders and defensive/hardstand surfaces into one coherent physical world;
3. stop relying on visually dominant flat BoxMesh/CylinderMesh overlay slabs;
4. retain provenance-recorded textures and real vegetation/rocks/houses already on the runtime path;
5. preserve topology/passability, anchors/constraints, exact vehicles and player/combat chain;
6. rerun fresh Godot 4.7.1 with external player input;
7. fix temporal alignment of initial/fire/final screenshots.

Do not reopen Stage 4 theory. Do not restore old Golden Scene/River Town/Reference Region coordinates. Historical/reference branches remain asset/tool/evidence pools only.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_FIX
WINDOW_03=HOLD_PENDING_REAL_ENOUGH_WORLD_RERUN

On completion:
`02 fresh repaired world runtime -> 03 audit real-enough world delivery + capture alignment -> 00 Sprint01 final decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
