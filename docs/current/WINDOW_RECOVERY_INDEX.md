# FRONTLINE — Window Recovery Index

STATUS=ACTIVE_RECOVERY_INDEX
PROJECT=FRONTLINE
PURPOSE=Recover any 00/01/02/03 window from GitHub without relying on chat memory.

## 1. Recovery rule

Every window recovery starts from `main` and then follows the active branch.

Authority split:

- `main` = control/routing/product-authority state.
- `learning/sprint01-end-to-end-rts-production` = Sprint 01 evidence, audits, implementation and runtime evidence.

If they diverge:

1. implementation/runtime facts are read from the active branch;
2. routing/product-resume authority is read from `main` / Window 00;
3. a window must not silently turn its own branch result into project authority.

Before answering any status question, always refresh both branch HEADs.

## 2. Mandatory main files

Read in this order:

1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. `docs/current/RESTART_DECISION.md`
5. `docs/ops/REPOSITORY_MAP_V3.md`
6. `docs/ops/BRANCH_RECYCLE_BIN.md`
7. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
8. `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`

## 3. Active Sprint branch

BRANCH=`learning/sprint01-end-to-end-rts-production`
ACTIVE_ISSUE=`#39`
LATEST_KNOWN_CHECKPOINT=`6dfe56da2c87b62fcb581c06b728c965d4e47bac`

Meaning at this checkpoint:
- fresh hosted Godot 4.7.1 world reproduction runtime exists;
- world-method causal execution = PASS;
- preserved player causal chain = PASS;
- exact combat vehicle binding = PASS;
- Window 03 rejected final PLAYER delivery because unit/world readability and real-enough world presentation still fail.

Always refresh branch HEAD before relying on this checkpoint.

## 4. Sprint 01 checkpoint chain

### A. Original player causal-chain reproduction

Implementation:
`399b181fdf9b66bbd17ecded617ef7a124be8231`

Fresh runtime later proved:
`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

Window 03 audit:
`5c136ea93657cddf5db1111a680782d7b62b0e4d`

Result:
- causal runtime chain = PASS;
- exact combat assets = PASS;
- overall PLAYER delivery = FAIL because unit readability and primitive environment delivery failed.

### B. Stage 4 world causal decomposition

Artifact:
`docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

Commit:
`dcd891d7947e0ec6b97257681f258ecf6432c037`

Boundary:
- world model = branching constraint graph;
- candidates W-C1..W-C7 identified;
- exact R28 identity remains UNKNOWN;
- no product transfer self-approval.

### C. Independent world-method audit

Artifact:
`docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md`

Commit:
`7e6bf5636af83933b6e0b60269f33aafa8a7715f`

Verdict:
`WINDOW_03_WORLD_METHOD_AUDIT=PASS_WITH_DOWNGRADES`
`BLOCKING_DEFECTS=0`
`WINDOW_02_ROUTING=READY_FOR_02_WORLD_REPRODUCTION`

### D. World reproduction implementation and runtime

Scene:
`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn`

Script:
`res://scripts/learning/sprint01/sprint01_world_reproduction.gd`

Implementation contract:
`docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`

Fresh runtime source commit:
`edf8cede10cea24a6218beb73bcca14ef424f5c7`

Evidence commit:
`03a56be1b0abfaf2248f23b4f9766ebd60aec27e`

Runtime result:
`docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md`

Fresh run:
`RUN_ID=35090538247`
`JOB_ID=104775532507`
`GODOT_VERSION=4.7.1.stable.official.a13da4feb`

Runtime facts accepted by 03:
- hosted runtime PASS;
- world method causal execution PASS;
- world-to-movement causal gate PASS;
- exact Abrams/IFV asset binding PASS;
- player input-to-outcome chain PASS;
- capture state alignment PASS.

### E. Current independent audit

Artifact:
`docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md`

Commit:
`6dfe56da2c87b62fcb581c06b728c965d4e47bac`

Verdict:

`WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY`

Passed:
- `RUNTIME_EXECUTION_VERDICT=PASS`
- `EXACT_VEHICLE_ASSET_BINDING=PASS`
- `WORLD_METHOD_SOURCE_PATH=PASS`
- `WORLD_METHOD_CAUSAL_EXECUTION=PASS`
- `PLAYER_CAUSAL_CHAIN_RUNTIME=PASS`
- `CAPTURE_STATE_ALIGNMENT=PASS`

Failed:
- `PLAYER_UNIT_READABILITY=FAIL`
- `WORLD_LABEL_OCCLUSION=FAIL`
- `REAL_ENOUGH_WORLD_DELIVERY=FAIL`
- `PLAYER_WORLD_READABILITY=FAIL`

Current route:
`RETURN_TO_02_FOR_PLAYER_WORLD_DELIVERY_FIX`

## 5. Current window recovery targets

### Window 00

Role:
`ACTIVE_CONTROL`

Read main, refresh active branch, preserve one active task, maintain branch/recycle clarity.

### Window 01

Role:
`HOLD_STAGE4_COMPLETE`

Do not restart world-method research unless a later audit identifies a specific missing evidence edge.

### Window 02

Role:
`ACTIVE_PLAYER_WORLD_DELIVERY_FIX`

Resume from the existing running world reproduction. Do not rebuild from scratch.

Repair only:
1. exact Abrams player readability;
2. occluding world labels;
3. primitive/placeholder terrain/material/vegetation/built-content presentation.

Preserve already-proven topology/passability, anchor/constraint and player/combat semantics.

Then rerun fresh Godot 4.7.1 evidence.

### Window 03

Role:
`HOLD_PENDING_REPAIRED_RUNTIME`

When repaired fresh screenshots/video/logs exist, independently re-audit the PLAYER delivery boundary.

## 6. Branch recovery / recycle map

Current branch count after first cleanup:
`14`

ACTIVE branches:
- `main`
- `learning/sprint01-end-to-end-rts-production`

Reference/Hold branches are listed in:
`docs/ops/REPOSITORY_MAP_V3.md`

23 stale reviewed branches were removed from the Branch list after preserving their exact HEADs as:

`recycle/2026-09-16/<original-branch-name>`

Manifest:
`docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md`

Do not treat recycle tags as current authority.

## 7. Anti-loss rule for future handoffs

Every material window completion must leave all four:

1. commit SHA;
2. named artifact path;
3. formal verdict/status fields;
4. explicit `NEXT_ROUTE` or blocker.

Window 00 then mirrors the resulting phase into `CURRENT_STATE.md` and `ACTIVE_WORK.md`.

A chat statement such as “完成了” without these repository anchors is not enough to change project state.
