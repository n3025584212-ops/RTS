# FRONTLINE — Sprint 01 World Reproduction Implementation

STATUS=CODE_BUILT_RUNTIME_PENDING
TASK_ID=BUILD_SPRINT01_WORLD_CAUSAL_REPRODUCTION_V1
ACTIVE_ISSUE=#39
BRANCH=learning/sprint01-end-to-end-rts-production
SOURCE_AUDIT=docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md
SOURCE_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f
SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SCRIPT=res://scripts/learning/sprint01/sprint01_world_reproduction.gd

## Scope

This is an isolated learning reproduction. It does not authorize FRONTLINE product production and does not define a permanent product world architecture.

The existing verified player-chain semantics are preserved:

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

This task changes the isolated reproduction's world construction and movement/world verification boundary rather than redesigning combat.

## Audited method implementation

- W-C1 corrected: topology/passability and intended corridor clearance are explicit and verified against the movement representation before world acceptance. No false claim is made that every terrain operation must occur before every built/decorative operation.
- W-C2: local built content is placed relative to a new junction anchor and defensive-objective anchor; 0 A.D. player-base semantics and old FRONTLINE scene coordinates are not copied.
- W-C3: route-protection, anchor exclusion, blocker bounds and vegetation exclusion act as named spatial constraints. Main-road and branch-road centerlines are sampled for blocker clearance.
- W-C4: semantic surface roles (`meadow`, `forest_floor`, `transition`, `rock`, `road`, `shoulder`, `hardstand`, `earthwork`) bind to deterministic material identities produced by this reproduction's local content pipeline.
- W-C5: vegetation is generated as coherent constrained patches over forest-floor/transition terrain plus separately authored sparse stragglers. No LOS/cover semantic claim is imported.
- W-C6: camera, sun, ambient light and fog values are frozen and logged as acceptance inputs.
- W-C7: the audited Abrams and IFV assets are reused by exact repository path through the inherited player-chain reproduction, but world layout is newly rule-driven rather than restored from Golden Scene, River Town or Reference Region coordinates.

## Content/provenance boundary

World terrain, road ribbons, material textures, earthworks, vegetation and rock detail are generated deterministically by the checked-in Typed GDScript content pipeline. No external unlicensed world content is introduced.

The environment does not use `PlaneMesh` or `BoxMesh` semantic placeholders as its delivered world construction. The inherited helper definitions may still exist in the base script, but the world reproduction override does not call the old `_build_environment()` implementation.

## Movement/world coupling

Movement remains deliberately bounded to the already-proven isolated deterministic player-chain behavior. The reproduction adds a world passability gate: every proposed movement point must lie in an explicit protected transport corridor and outside authored blocker bounds. Runtime logs identify this as:

`MOVEMENT_REPRESENTATION=DIRECT_KINEMATIC_WITH_WORLD_PASSABILITY_GATE`

This demonstrates a causal world-to-movement dependency without falsely claiming that a Godot NavigationServer/navmesh architecture has been reproduced.

## Required runtime evidence before any reproduction PASS

A code commit is not runtime proof. The next gate requires a fresh Godot 4.7.1 execution of `Sprint01WorldReproduction.tscn`, external keyboard injection, and PLAYER-visible capture. Required evidence:

- Godot import/parse log with no script/load errors;
- `WORLD_REPRODUCTION_METHOD_PASS=YES`;
- `WORLD_TO_MOVEMENT=PASS`;
- `CONSTRAINT_LAYERS=PASS`;
- `SURFACE_BINDING=PASS`;
- `VEGETATION_WORLD_CHECK=PASS`;
- `ANCHOR_WORLD_CHECK=PASS`;
- `OLD_SCENE_COORDINATE_COPY=NO`;
- inherited `PLAYER_CHAIN_PASS=YES`;
- `WORLD_AND_PLAYER_CHAIN_PASS=YES`;
- initial PLAYER screenshot before input;
- combat feedback screenshot;
- final outcome screenshot;
- continuous runtime video.

Until those are produced:

`WORLD_REPRODUCTION_STATUS=CODE_BUILT_RUNTIME_PENDING`
`SPRINT_PASS=NO`
`PRODUCT_PRODUCTION_RESUME=NO`

After runtime evidence exists, Window 03 must independently falsify the fresh reproduction. Window 02 does not self-approve visual/player acceptance or permanent transfer to FRONTLINE.
