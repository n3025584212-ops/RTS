# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_FIX
ACTIVE_TASK=REPAIR_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V1
TASK_ARTIFACT=docs/learning/sprint01/TASK_02_TRANSPORT_TERRAIN_INTEGRATION_FIX_V1.md

## One current task

WINDOW_02 is the only active implementation window.

TASK=Close the remaining `PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION` boundary.

## Latest Window 03 verdict

Audit:
`docs/audit/AUDIT_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1.md`

Audit commit:
`ec3536a5de8ab10fbec891cf59d94bd891a2bf5b`

Passed and frozen unless regression appears:
- `RUNTIME_EVIDENCE_IDENTITY=PASS`
- `PLAYER_CAUSAL_CHAIN_PRESERVED=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `PLAYER_UNIT_READABILITY=PASS`
- `WORLD_LABEL_OCCLUSION=PASS`
- `PLAYER_WORLD_READABILITY=PASS`
- `CAPTURE_STATE_ALIGNMENT=PASS`

Failed:
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`
- `FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

## Remaining repair only

Window 02 must preserve the authoritative corridor and movement/passability semantics while repairing PLAYER-visible physical integration:
1. road edge breakup, shoulders and verge variation;
2. graded branch/junction composition rather than hard orthogonal test geometry;
3. context-shaped compacted/disturbed ground rather than radial hardstand/decal reading;
4. stronger terrain relief and roadside physical cues;
5. houses/vegetation/rocks integrated into the transport/terrain region rather than isolated decoration;
6. fresh Godot 4.7.1 runtime and aligned PLAYER screenshots/video.

Do not reopen input, command, movement, contact, combat, exact vehicle binding, Stage 4, world-to-movement logic, readability or capture marker logic without regression evidence.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX
WINDOW_03=HOLD_PENDING_TRANSPORT_TERRAIN_RERUN

After Window 02 completion:
`02 fresh transport-terrain runtime -> 03 real-enough-world re-audit -> 00 Sprint01 final transfer/repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
