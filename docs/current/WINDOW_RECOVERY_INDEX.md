# FRONTLINE — Window Recovery Index

STATUS=ACTIVE_RECOVERY_INDEX
PROJECT=FRONTLINE
CONTROL_AUTHORITY=main
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production

## Recovery rule

Any recovered window must read, in order:
1. `START_HERE.md`
2. `docs/current/CURRENT_STATE.md`
3. `docs/current/ACTIVE_WORK.md`
4. refresh both main and active-branch HEADs
5. inspect the current task/handoff artifacts below.

Implementation/runtime facts belong to the active branch. Routing/product-resume authority belongs to main / Window 00.

## Current checkpoint

CURRENT_GATE=SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT
ACTIVE_ISSUE=#39

Latest 02 source:
`b0fe6d8b1de747606138a9ce1b28b3541b8c464a`

Latest 02 handoff:
`docs/learning/sprint01/HANDOFF_02_REAL_ENOUGH_WORLD_DELIVERY_TO_03_V1.md`

Latest 03 task:
`docs/audit/TASK_03_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT_V1.md`

Fresh Actions evidence:
- run `35185311167`
- job `105086008221`
- artifact `10481469643`
- SHA256 `a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f`

Important: the workflow is red only because its final git evidence push lost a non-fast-forward race. Godot import/runtime, external input, world/player assertions, screenshots/video and artifact upload all passed.

## Current windows

`00 = ACTIVE_CONTROL`
`01 = HOLD_STAGE4_COMPLETE`
`02 = HOLD_RUNTIME_CAPTURE_COMPLETE`
`03 = ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT`

## 03 decision boundary

03 inspects actual fresh media and decides:
- `REAL_ENOUGH_WORLD_DELIVERY`
- `CAPTURE_STATE_ALIGNMENT`

Previously passed causal/readability facts remain frozen unless regression is found.

If PASS:
`03 -> 00 Sprint01 final transfer decision`

If FAIL:
`03 -> 02 concrete remaining player-world defect only`

## Historical checkpoints

Stage 4 world decomposition:
`dcd891d7947e0ec6b97257681f258ecf6432c037`

World-method audit:
`7e6bf5636af83933b6e0b60269f33aafa8a7715f`

First world runtime/audit:
`edf8cede10cea24a6218beb73bcca14ef424f5c7` / `6dfe56da2c87b62fcb581c06b728c965d4e47bac`

First PLAYER delivery repair runtime/audit:
`73224323dea523e43d773b539912a700d286ddec` / `0d49839bf433d88018e81d0762eb0103a1e603e2`

## Branch/recycle state

Active branches only:
- `main`
- `learning/sprint01-end-to-end-rts-production`

23 reviewed stale branch heads are preserved under `recycle/2026-09-16/...` tags. Reference/Hold branches are not current authority.

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA or immutable Actions run/artifact identity;
- named artifact path/reference;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker.

A chat statement alone does not change project state.
