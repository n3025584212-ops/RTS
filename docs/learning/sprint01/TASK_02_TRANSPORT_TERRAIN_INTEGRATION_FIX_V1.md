# FRONTLINE — Sprint 01 Window 02 Transport-Terrain Integration Fix V1

STATUS=ACTIVE_TASK
TASK_ID=REPAIR_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V1
WINDOW_ID=02
WINDOW_ROLE=REPRODUCTION_AND_BUILD
ACTIVE_ISSUE=#39
BRANCH=learning/sprint01-end-to-end-rts-production
SOURCE_AUDIT=docs/audit/AUDIT_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1.md
SOURCE_AUDIT_COMMIT=ec3536a5de8ab10fbec891cf59d94bd891a2bf5b

## Purpose

Close the single remaining PLAYER-visible world boundary:

`FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`

Do not reopen the already-proven gameplay, world-causality, exact-asset, readability, label or capture-state work.

## Window 03 preserved PASS results

- `RUNTIME_EVIDENCE_IDENTITY=PASS`
- `PLAYER_CAUSAL_CHAIN_PRESERVED=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `PLAYER_UNIT_READABILITY=PASS`
- `WORLD_LABEL_OCCLUSION=PASS`
- `PLAYER_WORLD_READABILITY=PASS`
- `CAPTURE_STATE_ALIGNMENT=PASS`

The remaining blocking field is:

`REAL_ENOUGH_WORLD_DELIVERY=FAIL`

## Remaining PLAYER-visible defect

The fresh 1600x900 PLAYER view is improved but still reads as a prototype/test battlefield because:

1. the main road still dominates as a broad clean straight-edged asphalt strip;
2. the branch joins at a hard near-right-angle and preserves test-layout geometry;
3. junction/objective hardstand still reads as a radial decal/patch;
4. grass/road/forest-floor/hardstand transitions remain abrupt and semantic-zone-like;
5. central terrain relief, verge variation and roadside physical cues remain too weak;
6. houses/vegetation/rocks remain sparse islands around the transport surface instead of belonging to one physical landscape.

## Required repair — narrow only

Preserve the authoritative corridor and all movement/passability semantics, while changing only the PLAYER-visible physical integration:

1. Break up clean road edges with shoulders, verge variation and contextually irregular transitions.
2. Visually grade the branch/junction connection so it no longer reads like an orthogonal test layout.
3. Replace obvious radial hardstand/decal reading with context-shaped compacted/disturbed ground.
4. Increase terrain relief and roadside physical cues such as embankment/cut, shallow ditching, erosion/wear and edge breakup without altering authoritative passability.
5. Integrate houses, vegetation and rocks with the road/terrain composition instead of placing them as isolated decorations.
6. Preserve provenance-recorded real assets/textures and exact Abrams/IFV identities.
7. Preserve the validated rendered-frame capture markers.
8. Rerun fresh Godot 4.7.1 with external input and produce fresh initial/fire/final screenshots plus continuous video.

## Forbidden reopening

Unless fresh regression evidence appears, do not modify or re-prove:

- input;
- selection;
- command routing;
- movement/contact/combat semantics;
- exact vehicle binding;
- Stage 4 world decomposition;
- world-to-movement logic;
- Abrams readability;
- persistent-label removal;
- capture-state marker logic.

Do not restore old Golden Scene / River Town / Reference Region coordinates as authority.
Do not substitute flat/primitive diagnostic geometry with differently shaped diagnostic geometry and call it solved.

## Acceptance target

The PLAYER camera must stop reading primarily as:

`broad road slab + orthogonal branch + radial hardstand + sparse asset islands`

and instead read as one coherent transport corridor embedded in a physical battlefield region, while preserving the proven causal game slice.

This is a Sprint 01 reproduction boundary, not authorization for final FRONTLINE product-quality production.

## Required fresh evidence

Return at minimum:

- runtime source commit;
- Godot 4.7.1 import/runtime log;
- exact vehicle binding evidence;
- external input evidence;
- preserved world/player-chain assertions;
- fresh aligned initial screenshot;
- fresh aligned fire-feedback screenshot;
- fresh final/outcome screenshot;
- continuous runtime MP4;
- updated reproduction result;
- immutable workflow run/artifact identity;
- evidence commit or, if writeback races again, explicit immutable artifact handoff.

## Routing

`WINDOW_00=ACTIVE_CONTROL`
`WINDOW_01=HOLD_STAGE4_COMPLETE`
`WINDOW_02=ACTIVE_TRANSPORT_TERRAIN_INTEGRATION_FIX`
`WINDOW_03=HOLD_PENDING_TRANSPORT_TERRAIN_RERUN`

On completion:

`02 fresh transport-terrain runtime -> 03 audit REAL_ENOUGH_WORLD_DELIVERY only (plus regression checks) -> 00 Sprint 01 final transfer or further repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
