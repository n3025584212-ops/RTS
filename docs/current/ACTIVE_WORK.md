# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_FIX
ACTIVE_TASK=REPAIR_SPRINT01_PLAYER_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/learning/sprint01/TASK_02_PLAYER_WORLD_DELIVERY_FIX_V1.md

## One current task

WINDOW_02 is the only active implementation window for this round.

TASK=Repair the PLAYER-facing world delivery of the already-running Sprint01 world reproduction without redesigning the already-proven causal methods.

SOURCE_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md
SOURCE_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac
TASK_ROUTING_COMMIT=5188884e4a1d04e78164a895296f2466af54658c

## Already accepted — preserve

- `RUNTIME_EXECUTION_VERDICT=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `WORLD_METHOD_SOURCE_PATH=PASS`
- `WORLD_METHOD_CAUSAL_EXECUTION=PASS`
- `PLAYER_CAUSAL_CHAIN_RUNTIME=PASS`
- `CAPTURE_STATE_ALIGNMENT=PASS`

Do not reopen the proven player/combat chain, topology/passability coupling, functional anchors, constraint logic or world-method causal execution merely because the PLAYER output failed.

## Failed boundary to repair

- `PLAYER_UNIT_READABILITY=FAIL`
- `WORLD_LABEL_OCCLUSION=FAIL`
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`
- `PLAYER_WORLD_READABILITY=FAIL`

## Required repair

1. make the exact Abrams visually coherent/readable at the accepted battlefield scale;
2. remove, shrink or reposition labels that occlude the battle;
3. materially upgrade primitive/placeholder terrain, material, vegetation and built-content presentation until the actual player-camera result no longer reads as a diagnostic scene;
4. use provenance-recorded assets/content or a supported content pipeline; historical visual branches may provide assets/tools/evidence but may not be restored wholesale;
5. preserve the accepted world/gameplay semantics;
6. rerun fresh Godot 4.7.1 runtime with external input and exact combat assets;
7. return fresh initial/fire/final screenshots, continuous video and runtime logs.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_PLAYER_WORLD_DELIVERY_FIX
WINDOW_03=HOLD_PENDING_REPAIRED_RUNTIME

On Window 02 completion:

`02 repaired runtime -> 03 independent PLAYER delivery re-audit -> 00 Sprint01 transfer or further repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
