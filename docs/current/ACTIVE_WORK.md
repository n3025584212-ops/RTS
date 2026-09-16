# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_WORLD_REPRODUCTION_RUNTIME_GATE

## One current task

WINDOW_02 is the only active production/implementation window for the current gate.

TASK=Complete a fresh Godot 4.7.1 runtime of the already-built isolated world reproduction and produce inspectable PLAYER evidence.

SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SCRIPT=res://scripts/learning/sprint01/sprint01_world_reproduction.gd
WORKFLOW=.github/workflows/learning-sprint01-world-reproduction.yml
IMPLEMENTATION_DOC=docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md
BLOCKER_DOC=docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md

## Why this is the current task

The project restart requires:

`REAL PRODUCT/PROBLEM -> EVIDENCE -> CAUSAL DECOMPOSITION -> INDEPENDENT REPRODUCTION -> REAL ARTIFACT -> COMPARISON -> FRONTLINE TRANSFER`

The system/player causal chain has already run successfully in the earlier isolated reproduction.

Window 01 then completed the missing world-production Stage 4:

`terrain -> transport -> land-use/constraints -> settlement/anchors -> vegetation -> tactical/movement space -> materials -> lighting/environment -> camera -> PLAYER`

Window 03 independently audited that work and returned `PASS_WITH_DOWNGRADES`, with zero blocking defects. Therefore the current work is no longer additional theory. It is runtime verification of the new world reproduction.

## Current implementation status

WORLD_CAUSAL_DECOMPOSITION_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
WORLD_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f
WORLD_REPRODUCTION_SCRIPT_FIX_COMMIT=202cc6a8d282d3ec5c8d40932cf740b5e664cfe9
WORLD_REPRODUCTION_SCENE_COMMIT=5df520722d32d4173fa9ea4c2307c95bed1daca5
WORLD_REPRODUCTION_IMPLEMENTATION_DOC_COMMIT=e5eff694f58144a162e411aae6fd50ecad299be2
WORLD_REPRODUCTION_WORKFLOW_COMMIT=7dd7c78160ec8952bf857fd8f2edd368e19de004
LATEST_KNOWN_BLOCKER_COMMIT=7a0f24d0ef82f6afcf1666610bd3eb520a94d3de

CODE_EXISTS=PASS
CODE_EXECUTES=UNKNOWN
WORLD_METHOD_RUNTIME=UNKNOWN
PLAYER_CHAIN_RUNTIME_ON_NEW_WORLD=UNKNOWN
PLAYER_VISIBLE_WORLD_EVIDENCE=NOT_PRODUCED

Latest hosted attempt:

RUN_ID=35004033644
JOB_ID=104499190425
RESULT=FAILURE_BEFORE_RUNNER
RUNNER_ID=0
JOB_STEPS=[]

This is an execution-infrastructure blocker. It is not evidence that the implementation passed or failed in Godot.

## Required runtime outputs

A valid Window 02 completion requires one fresh Godot 4.7.1 run with exact sanctioned asset bytes and actual player input, producing at minimum:

- runtime/import log without parse/load errors;
- world-method assertions including world-to-movement, constraints, material/surface binding, anchors and vegetation;
- external input evidence;
- preserved player causal-chain evidence;
- initial PLAYER screenshot;
- combat-feedback screenshot;
- final outcome screenshot;
- continuous runtime video.

Expected branch paths are under:

`artifacts/learning/sprint01/world_reproduction/`

No historical Golden Scene / River Town / Reference Region capture may substitute for this run.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=ACTIVE_RUNTIME_GATE
WINDOW_03=HOLD_PENDING_FRESH_RUNTIME

After fresh runtime evidence:

`02 -> 03 independent world/player artifact audit -> 00 transfer or repair decision`

## Current prohibitions

- do not restart Stage 4 from scratch;
- do not reopen old Battle01 / Golden Scene / River Town as product authority;
- do not redesign the proven combat chain to make the test easier;
- do not claim runtime from static code;
- do not accept CI status as PLAYER evidence;
- do not use old screenshots as fresh evidence;
- do not resume FRONTLINE product production before Sprint 01 passes.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
