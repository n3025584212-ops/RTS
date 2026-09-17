# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_FIX
ACTIVE_TASK=REPAIR_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/learning/sprint01/TASK_02_REAL_ENOUGH_WORLD_DELIVERY_FIX_V1.md

## One current task

WINDOW_02 is the only active implementation window for this round.

TASK=Close the single remaining blocking PLAYER boundary: `REAL_ENOUGH_WORLD_DELIVERY`.

## Latest Window 03 re-audit

AUDIT=docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md
AUDIT_COMMIT=0d49839bf433d88018e81d0762eb0103a1e603e2

Passed:
- `RUNTIME_EVIDENCE_IDENTITY=PASS`
- `PLAYER_CAUSAL_CHAIN_PRESERVED=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `PLAYER_UNIT_READABILITY=PASS`
- `WORLD_LABEL_OCCLUSION=PASS`
- `PLAYER_WORLD_READABILITY=PASS`

Failed:
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`

Evidence-packaging defect:
- `CAPTURE_STATE_ALIGNMENT=FAIL_NONBLOCKING_TO_CURRENT_VISUAL_DECISION`

## Preserve — do not reopen

Do not redesign or re-audit without regression evidence:
- player input -> command -> movement -> contact -> combat -> feedback -> outcome;
- world topology/passability and constraint logic;
- functional anchors;
- exact Abrams/IFV identities;
- repaired Abrams readability;
- removal of persistent world-label occlusion;
- provenance-recorded vegetation/rock/house/texture asset pool.

## Remaining repair only

The player camera still reads as a textured diagnostic/tabletop prototype because the world has a flat board/slab silhouette, roads appear as rectangular overlays, circular hardstands dominate, and the overlay layer masks terrain relief/transitions.

Window 02 must:
1. remove the board/slab reading;
2. integrate terrain, roads, shoulders and hardstand/defensive surfaces into one coherent physical world;
3. stop using visually dominant flat BoxMesh/CylinderMesh overlay surfaces as the delivered battlefield;
4. preserve the real delivery asset pool and proven causal semantics;
5. rerun fresh Godot 4.7.1 with external input and exact combat assets;
6. fix temporal alignment of named initial/fire/final capture checkpoints.

## Required handoff

Fresh outputs:
- runtime/import log;
- exact asset binding;
- external input log;
- preserved world/player-chain assertions;
- aligned initial screenshot;
- aligned fire-feedback screenshot;
- final/outcome screenshot;
- continuous runtime video;
- result artifact;
- runtime source SHA and evidence SHA.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_FIX
WINDOW_03=HOLD_PENDING_REAL_ENOUGH_WORLD_RERUN

After Window 02 completion:
`02 fresh repaired world runtime -> 03 audit REAL_ENOUGH_WORLD_DELIVERY + capture alignment -> 00 final Sprint01 transfer/repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
