# FRONTLINE — Sprint 01 Window 02 Player-World Delivery Fix V1

STATUS=ACTIVE
TASK_ID=REPAIR_SPRINT01_PLAYER_WORLD_DELIVERY_V1
WINDOW_ID=02
WINDOW_ROLE=REPRODUCTION_AND_BUILD
ACTIVE_ISSUE=#39
BRANCH=learning/sprint01-end-to-end-rts-production
SOURCE_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md
SOURCE_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac

## Purpose

Repair only the PLAYER-facing delivery boundary that failed independent audit. Do not redesign or reopen already-proven runtime/world/gameplay causality.

## Preserve — already accepted

The following are frozen for this repair unless the repair itself changes them and therefore requires re-audit:

- Godot 4.7.1 hosted runtime path;
- exact Abrams and IFV asset identity/binding;
- `PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`;
- world topology/passability coupling;
- functional anchors;
- route/blocker/vegetation constraint logic;
- narrow semantic-surface binding method;
- narrow vegetation region + straggler distribution method;
- camera/environment acceptance inputs;
- fresh screenshot/video/log capture process.

## Failed PLAYER boundary to repair

Window 03 verdict:

`WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY`

Blocking failures:

- `PLAYER_UNIT_READABILITY=FAIL`
- `WORLD_LABEL_OCCLUSION=FAIL`
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`
- `PLAYER_WORLD_READABILITY=FAIL`

## Required repair

1. Make the exact Abrams visibly coherent and readable at the same player-camera battlefield scale as the IFV. Do not replace it with a semantic proxy.
2. Remove, shrink or reposition diagnostic/world labels so they no longer occlude the battlefield or dominate the PLAYER image.
3. Replace or materially upgrade primitive/prototype world presentation that still reads as a diagnostic scene. This includes coarse generated terrain/material presentation, primitive earthworks/hardstands/rocks/vegetation and any other semantic placeholder-like delivery visible from the accepted player camera.
4. Use provenance-recorded reusable assets or an evidence-backed/generated content pipeline whose actual PLAYER output is no longer placeholder-like. Old Golden Scene, River Town, Reference Region and local-high-fidelity branches may supply assets/tools/evidence but may not be restored wholesale or regain product authority.
5. Preserve the accepted topology, transport/corridor, anchor, constraint, movement and player/combat semantics.
6. Rerun the same complete chain in fresh Godot 4.7.1 with external player input and exact sanctioned combat assets.

## Required fresh evidence

Minimum outputs:

- fresh runtime/import log;
- exact asset binding evidence;
- fresh external input evidence;
- world-method assertions still passing;
- player causal-chain assertions still passing;
- fresh initial PLAYER screenshot;
- fresh combat/fire-feedback screenshot;
- fresh final/outcome screenshot;
- continuous runtime video;
- updated `docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md` or a clearly named repaired result artifact;
- explicit repair commit SHA and runtime source commit SHA.

## PLAYER acceptance questions for Window 03

The next audit must be able to answer YES from actual screenshots/video, not code intent:

- Can the player visually identify the Abrams as a coherent combat vehicle at the accepted battlefield camera scale?
- Are labels subordinate to the battlefield rather than covering it?
- Does the terrain/material/vegetation/built-content presentation read as a real-enough battlefield region rather than a primitive diagnostic construction?
- Is the world readable enough that roads/corridors, terrain organization, local anchors, units, combat feedback and outcome form one coherent PLAYER image?
- Did the repair preserve the already-proven runtime causal chain?

## Forbidden shortcuts

- no rebuilding Stage 4 theory from scratch;
- no restoring old scene coordinates/layout as the answer;
- no Box/Cylinder/color-block semantic proxy substitution for combat units;
- no declaring PASS from code existence, asset count, CI green or log assertions alone;
- no generated target image as acceptance evidence;
- no broad new gameplay/system scope;
- no product-production resume.

## Routing

`WINDOW_00=ACTIVE_CONTROL`
`WINDOW_01=HOLD_STAGE4_COMPLETE`
`WINDOW_02=ACTIVE_PLAYER_WORLD_DELIVERY_FIX`
`WINDOW_03=HOLD_PENDING_REPAIRED_RUNTIME`

On completion:

`02 repaired fresh runtime -> 03 independent PLAYER delivery re-audit -> 00 Sprint01 transfer or further repair decision`

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
