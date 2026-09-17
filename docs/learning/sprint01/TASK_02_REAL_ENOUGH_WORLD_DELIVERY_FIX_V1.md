# FRONTLINE — Sprint 01 Window 02 Real-Enough World Delivery Fix V1

STATUS=ACTIVE_TASK
TASK_ID=REPAIR_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1
WINDOW_ID=02
WINDOW_ROLE=REPRODUCTION_AND_BUILD
ACTIVE_ISSUE=#39
BRANCH=learning/sprint01-end-to-end-rts-production
SOURCE_AUDIT=docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md
SOURCE_AUDIT_COMMIT=0d49839bf433d88018e81d0762eb0103a1e603e2

## Purpose

Close the one remaining blocking Sprint 01 PLAYER boundary: `REAL_ENOUGH_WORLD_DELIVERY`.

Do not restart world-method learning or redesign already-proven gameplay/world causality.

## 03 re-audit result — preserve

The latest independent re-audit accepted:

- `RUNTIME_EVIDENCE_IDENTITY=PASS`
- `PLAYER_CAUSAL_CHAIN_PRESERVED=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `PLAYER_UNIT_READABILITY=PASS`
- `WORLD_LABEL_OCCLUSION=PASS`
- `PLAYER_WORLD_READABILITY=PASS`

The only blocking PLAYER failure is:

`REAL_ENOUGH_WORLD_DELIVERY=FAIL`

A separate evidence-packaging defect also exists:

`CAPTURE_STATE_ALIGNMENT=FAIL_NONBLOCKING_TO_CURRENT_VISUAL_DECISION`

## Remaining visual defect

The fresh player camera still reads as a textured diagnostic/tabletop prototype because:

1. the playable ground reads as a large flat rectangular slab with a hard boundary;
2. main and branch roads read as broad straight rectangular overlay slabs instead of terrain-integrated roads;
3. circular hardstand/diagnostic areas remain visually dominant;
4. real trees/houses/rocks are present but sit on top of a board-like world silhouette;
5. terrain relief and transitions are visually weakened/masked by the delivery overlay layer.

## Required repair

Repair only the physical-world presentation boundary:

1. Remove the flat board/slab reading.
2. Integrate terrain, roads, shoulders and defensive/hardstand surfaces into one coherent physical world instead of visually dominant BoxMesh/CylinderMesh overlay slabs.
3. Preserve and reuse the provenance-recorded delivery textures, vegetation, rocks and house GLBs already proven to be on the runtime path.
4. Preserve terrain/topology/passability, transport/corridor, functional-anchor, route/blocker/vegetation constraints, exact Abrams/IFV identity and full player/combat semantics.
5. Do not restore old Golden Scene / River Town / Reference Region coordinates or treat historical visual branches as current authority. They may supply provenance-valid assets/tools/evidence only.
6. Rerun fresh Godot 4.7.1 with external player input and exact sanctioned combat assets.
7. Repair checkpoint capture synchronization so named initial/fire/final PNGs correspond to their intended visible/rendered states; do not rely only on fixed sleeps after log lines.

## PLAYER acceptance target

The next fresh player-camera artifact must no longer read primarily as:

- a flat rectangular game board;
- road rectangles placed on top of terrain;
- diagnostic circular hardstands;
- real assets decorating a prototype slab.

It must read as one coherent battlefield surface/region in which terrain relief, roads, shoulders, defensive surfaces, vegetation/built content, friendly/enemy vehicles and combat feedback belong to the same physical world.

This is a bounded Sprint-learning acceptance target, not authorization for final FRONTLINE product visual quality.

## Required fresh evidence

Return at minimum:

- fresh runtime/import log;
- exact asset binding evidence;
- external input evidence;
- preserved world-method/player-chain assertions;
- fresh initial PLAYER screenshot aligned to initial state;
- fresh fire-feedback screenshot aligned to visible fire/impact state;
- fresh final/outcome screenshot;
- continuous runtime video;
- updated result artifact;
- explicit runtime source commit and evidence commit.

## Forbidden shortcuts

- no reopening Stage 4 theory;
- no redesign of proven input/command/movement/contact/combat semantics;
- no fake combat-unit substitution;
- no declaring visual PASS from asset counts/provenance/CI/logs;
- no flat textured BoxMesh board as the final answer;
- no old-scene coordinate restoration;
- no product-production resume.

## Routing

`WINDOW_00=ACTIVE_CONTROL`
`WINDOW_01=HOLD_STAGE4_COMPLETE`
`WINDOW_02=ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_FIX`
`WINDOW_03=HOLD_PENDING_REAL_ENOUGH_WORLD_RERUN`

On completion:

`02 fresh repaired world runtime -> 03 audit REAL_ENOUGH_WORLD_DELIVERY + capture alignment -> 00 Sprint 01 final transfer or further repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
