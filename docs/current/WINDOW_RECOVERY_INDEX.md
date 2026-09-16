# FRONTLINE — Window Recovery Index

STATUS=ACTIVE_RECOVERY_INDEX
PROJECT=FRONTLINE
PURPOSE=Recover any 00/01/02/03 window from GitHub without relying on chat memory.

## 1. Recovery rule

Every window recovery starts from `main` and then follows the active branch.

Do not assume the commit SHAs below remain the branch HEAD forever. They are checkpoints for reconstructing the current causal history. Always refresh branch HEAD first.

Authority split:

- `main` = control/routing/product-authority state.
- `learning/sprint01-end-to-end-rts-production` = Sprint 01 evidence, audits, implementation and runtime evidence.

If they diverge:

1. implementation/runtime facts are read from the active branch;
2. routing/product-resume authority is read from `main` / Window 00;
3. a window must not silently turn its own branch result into project authority.

## 2. Mandatory main files

Read in this order:

1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. `docs/current/RESTART_DECISION.md`
5. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
6. `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`

## 3. Active Sprint branch

BRANCH=`learning/sprint01-end-to-end-rts-production`
ACTIVE_ISSUE=`#39`

Latest known checkpoint at this reorganization:

`7a0f24d0ef82f6afcf1666610bd3eb520a94d3de`

Meaning: Window 02 world reproduction code exists, but the latest hosted runtime attempt failed before runner assignment and produced no fresh PLAYER runtime evidence.

Before answering any status question, refresh the branch HEAD. If it advanced, inspect the new commits and artifacts before using this snapshot.

## 4. Sprint 01 checkpoint chain

### A. Original player causal-chain reproduction

Implementation:
`399b181fdf9b66bbd17ecded617ef7a124be8231`

Fresh local runtime later proved:
`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

Window 03 runtime/PLAYER audit:
`5c136ea93657cddf5db1111a680782d7b62b0e4d`

Important result:
- causal runtime chain = PASS;
- exact combat assets = PASS;
- fire/outcome visibility = PASS;
- overall PLAYER delivery = FAIL because unit readability and primitive environment delivery failed.

This is why the project did not resume product production.

### B. Stage 4 world causal decomposition

Window 01 artifact:
`docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

Commit:
`dcd891d7947e0ec6b97257681f258ecf6432c037`

Key boundary:
- world model = branching constraint graph;
- candidate methods W-C1..W-C7 identified;
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

This approved only a bounded isolated reproduction. It did not approve a permanent FRONTLINE world architecture.

### D. Current world reproduction implementation

Script/corridor fix checkpoint:
`202cc6a8d282d3ec5c8d40932cf740b5e664cfe9`

Scene checkpoint:
`5df520722d32d4173fa9ea4c2307c95bed1daca5`

Implementation contract:
`docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`

Implementation-contract commit:
`e5eff694f58144a162e411aae6fd50ecad299be2`

Workflow commit:
`7dd7c78160ec8952bf857fd8f2edd368e19de004`

Runtime scene:
`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn`

Runtime script:
`res://scripts/learning/sprint01/sprint01_world_reproduction.gd`

Workflow:
`.github/workflows/learning-sprint01-world-reproduction.yml`

### E. Current blocker

Artifact:
`docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

Commit:
`7a0f24d0ef82f6afcf1666610bd3eb520a94d3de`

Hosted run:
`35004033644`

Job:
`104499190425`

Observed:
`RESULT=FAILURE_BEFORE_RUNNER`
`RUNNER_ID=0`
`JOB_STEPS=[]`

Allowed interpretation:
`CODE_EXISTS=PASS`
`CODE_EXECUTES=UNKNOWN`
`WORLD_METHOD_RUNTIME=UNKNOWN`
`PLAYER_VISIBLE_WORLD_EVIDENCE=NOT_PRODUCED`

Forbidden interpretations:
- world reproduction PASS;
- gameplay failure;
- exact GitHub billing/quota/policy root cause without evidence.

## 5. Current window recovery targets

### Window 00

Read main control files, refresh active branch, reconcile conflicts, keep one active primary task.

Current role:
`ACTIVE_CONTROL`

### Window 01

Current role:
`HOLD_STAGE4_COMPLETE`

Do not restart world-method research unless a specific later audit identifies a missing evidence edge.

### Window 02

Current role:
`ACTIVE_RUNTIME_GATE`

Resume from the existing world reproduction. Do not rebuild the task from scratch.

Required next action:
run the existing scene in fresh Godot 4.7.1 with exact sanctioned asset bytes, real external player input and fresh runtime capture.

### Window 03

Current role:
`HOLD_PENDING_FRESH_RUNTIME`

Do not audit static code again as if it were the final artifact. Wait for fresh world runtime evidence, then independently inspect runtime causality and PLAYER-visible result.

## 6. Historical branches are not missing current state

These are deliberately historical/tool pools unless re-authorized by 00:

- `dev/godot-golden-scene-v1`
- `dev/visual-production-reset`
- `dev/river-town-local-high-fidelity-v1`
- `dev/reference-region-v1`
- `dev/prototype-b-representative-battle-content-v1`
- Battle01-related older branches

A file only existing there is not automatically a current requirement. Conversely, do not delete unique assets/evidence merely because a branch is historical.

## 7. Anti-loss rule for future handoffs

Every material window completion must leave all four:

1. commit SHA;
2. named artifact path;
3. formal verdict/status fields;
4. explicit `NEXT_ROUTE` or blocker.

Window 00 then mirrors the resulting phase into `CURRENT_STATE.md` and `ACTIVE_WORK.md`.

A chat statement such as “完成了” without these repository anchors is not enough to change project state.
