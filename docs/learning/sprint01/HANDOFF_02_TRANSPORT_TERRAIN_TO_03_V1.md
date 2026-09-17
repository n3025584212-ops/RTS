# Sprint 01 Window 02 -> Window 03 Transport-Terrain Handoff V1

STATUS=READY_FOR_WINDOW_03_REAUDIT
PROJECT=FRONTLINE
ACTIVE_ISSUE=#39
FROM_WINDOW=02
TO_WINDOW=03

## Immutable runtime identity

RUNTIME_SOURCE_COMMIT=7eb34267d6fbbebd856001a7c17390c341835e59
WORLD_WORKFLOW_RUN=35204480034
WORLD_WORKFLOW_JOB=105146808996
ARTIFACT_ID=10488929099
ARTIFACT_NAME=sprint01-world-reproduction-7eb34267d6fbbebd856001a7c17390c341835e59
ARTIFACT_SHA256=183e43456c951c8908c239c189f6f2cf12bbc865598c836b73146256656da500
GODOT_VERSION=4.7.1.stable.official.a13da4feb
SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn

The workflow's runtime/capture/artifact steps passed. The overall workflow is red only because the final evidence writeback commit hit a branch race/non-fast-forward condition. Do not classify that as Godot/runtime failure.

## Runtime observations

CODE_EXECUTES=PASS
WORLD_METHOD_RUNTIME=PASS
WORLD_TO_MOVEMENT=PASS
CONSTRAINT_LAYERS=PASS
SEMANTIC_SURFACE_BINDING=PASS
FUNCTIONAL_ANCHORS=PASS
PLAYER_CHAIN_RUNTIME=PASS
WORLD_AND_PLAYER_CHAIN_RUNTIME=PASS
CAPTURE_ALIGNMENT=RENDER_FRAME_MARKERS

Observed player chain remained:
`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

Observed combat outcome:
- Abrams selected through external X11 keyboard input;
- ATTACK_MOVE issued;
- movement/contact occurred;
- four fire events consumed ammo 4 -> 0;
- target HP changed 100 -> 0;
- muzzle/tracer/impact feedback was produced;
- target destroyed;
- PLAYER_CHAIN_PASS=YES;
- WORLD_AND_PLAYER_CHAIN_PASS=YES.

## V2 visible transport-terrain repair

V2 implementation source:
`res://scripts/learning/sprint01/sprint01_transport_terrain_integration_v2.gd`

Compared with the previously audited failure, this runtime intentionally changes only PLAYER-visible physical integration while inheriting gameplay/passability authority:
- narrower visible asphalt;
- visibly meandered main-road presentation inside the authoritative corridor;
- more gradual branch departure;
- layered shoulder/verge transition;
- compact asymmetric disturbed-ground patches instead of large radial hardstands;
- stronger off-corridor relief plus drainage/bank cues;
- small additional provenance-recorded built/roadside anchors.

It does NOT authorize a change to the FRONTLINE visual-quality baseline.

## Required media to inspect directly

Inside artifact `10488929099`:
- `artifacts/learning/sprint01/world_reproduction/world_initial.png`
- `artifacts/learning/sprint01/world_reproduction/world_fire_feedback.png`
- `artifacts/learning/sprint01/world_reproduction/world_final.png`
- `artifacts/learning/sprint01/world_reproduction/world_reproduction.mp4`
- `artifacts/learning/sprint01/world_reproduction/runtime.log`
- `artifacts/learning/sprint01/world_reproduction/world_chain_extract.txt`
- `artifacts/learning/sprint01/world_reproduction/input_injection.log`
- `artifacts/learning/sprint01/world_reproduction/exact_asset_binding.txt`

## Window 03 decision boundary

03 must decide from the actual fresh media:

`REAL_ENOUGH_WORLD_DELIVERY=PASS | FAIL`

Primary question:
Has the specific previously failed boundary `PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION` been closed enough for Sprint01's independent reproduction contract?

03 must check for regressions in already-passed fields, but must not silently change this learning scene into the FRONTLINE visual-quality baseline.

## Visual-baseline protection

Sprint01 is a learning/reproduction artifact, not the project's highest visual-quality artifact.
The separate FRONTLINE visual-quality baseline remains protected by main control state and the approved Golden Frame contract. River Town / Golden Scene / Reference Region may remain visual/reference evidence without regaining old product-direction authority.

WINDOW_02_SELF_ACCEPTANCE=FORBIDDEN
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
NEXT=WINDOW_03_REAUDIT_TRANSPORT_TERRAIN_INTEGRATION_V2
