# FRONTLINE — Window Recovery Index

STATUS=ACTIVE_RECOVERY_INDEX
PROJECT=FRONTLINE
CONTROL_AUTHORITY=main
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production

## Recovery rule

Any recovered window must:

1. read `START_HERE.md`;
2. read `docs/current/CURRENT_STATE.md`;
3. read `docs/current/ACTIVE_WORK.md`;
4. refresh this branch HEAD;
5. inspect the checkpoint chain below before answering status or resuming work.

Final routing/product authority remains main / Window 00. This branch owns its implementation/evidence facts only.

## Sprint 01 checkpoint chain

### Player causal-chain runtime

Implementation commit:
`399b181fdf9b66bbd17ecded617ef7a124be8231`

Window 03 fresh runtime/PLAYER audit:
`5c136ea93657cddf5db1111a680782d7b62b0e4d`

Result:
- causal runtime chain PASS;
- exact combat assets PASS;
- visible fire/outcome PASS;
- overall PLAYER delivery FAIL because unit readability and primitive environment failed.

### Stage 4 world causal decomposition

Artifact:
`docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

Commit:
`dcd891d7947e0ec6b97257681f258ecf6432c037`

### World-method audit

Artifact:
`docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md`

Commit:
`7e6bf5636af83933b6e0b60269f33aafa8a7715f`

Verdict:
`PASS_WITH_DOWNGRADES`
`BLOCKING_DEFECTS=0`
`WINDOW_02_ROUTING=READY_FOR_02_WORLD_REPRODUCTION`

### Current world reproduction

Script/fix checkpoint:
`202cc6a8d282d3ec5c8d40932cf740b5e664cfe9`

Scene checkpoint:
`5df520722d32d4173fa9ea4c2307c95bed1daca5`

Implementation doc:
`docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`

Implementation doc commit:
`e5eff694f58144a162e411aae6fd50ecad299be2`

Workflow commit:
`7dd7c78160ec8952bf857fd8f2edd368e19de004`

Scene:
`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn`

Script:
`res://scripts/learning/sprint01/sprint01_world_reproduction.gd`

### Current blocker checkpoint

Artifact:
`docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

Commit:
`7a0f24d0ef82f6afcf1666610bd3eb520a94d3de`

Hosted run:
`35004033644`

Job:
`104499190425`

Observed:
`FAILURE_BEFORE_RUNNER`
`RUNNER_ID=0`
`JOB_STEPS=[]`

Allowed status:
`CODE_EXISTS=PASS`
`CODE_EXECUTES=UNKNOWN`
`WORLD_METHOD_RUNTIME=UNKNOWN`
`PLAYER_VISIBLE_WORLD_EVIDENCE=NOT_PRODUCED`

Do not turn this into either gameplay failure or reproduction PASS.

## Current windows

`00 = ACTIVE_CONTROL`
`01 = HOLD_STAGE4_COMPLETE`
`02 = ACTIVE_RUNTIME_GATE`
`03 = HOLD_PENDING_FRESH_RUNTIME`

## Current next route

`02 fresh Godot 4.7.1 world runtime + exact sanctioned assets + real input + fresh capture`
`-> 03 independent world/player artifact audit`
`-> 00 Sprint01 transfer or repair decision`

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA;
- named artifact path;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker.

A chat statement without repository anchors does not change project state.
