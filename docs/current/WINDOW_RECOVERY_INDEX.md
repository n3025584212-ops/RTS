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

Final routing/product authority remains main / Window 00. This branch owns implementation/evidence facts only.

## Current checkpoint chain

### Player causal-chain runtime

Implementation:
`399b181fdf9b66bbd17ecded617ef7a124be8231`

Window 03 runtime/PLAYER audit:
`5c136ea93657cddf5db1111a680782d7b62b0e4d`

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

### Fresh world reproduction runtime

Runtime source commit:
`edf8cede10cea24a6218beb73bcca14ef424f5c7`

Evidence commit:
`03a56be1b0abfaf2248f23b4f9766ebd60aec27e`

Result artifact:
`docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md`

Fresh run:
`RUN_ID=35090538247`
`JOB_ID=104775532507`
`GODOT_VERSION=4.7.1.stable.official.a13da4feb`

### Latest Window 03 audit

Artifact:
`docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md`

Commit:
`6dfe56da2c87b62fcb581c06b728c965d4e47bac`

Verdict:
`WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY`

Passed:
- runtime execution;
- exact combat vehicle binding;
- world-method causal execution;
- preserved player causal chain;
- capture-state alignment.

Failed:
- player unit readability;
- world-label occlusion;
- real-enough world delivery;
- player world readability.

## Current windows

`00 = ACTIVE_CONTROL`
`01 = HOLD_STAGE4_COMPLETE`
`02 = ACTIVE_PLAYER_WORLD_DELIVERY_FIX`
`03 = HOLD_PENDING_REPAIRED_RUNTIME`

## Current next route

`02 repair player-world delivery while preserving proven causal semantics`
`-> fresh Godot 4.7.1 runtime + screenshots/video/logs`
`-> 03 independent re-audit`
`-> 00 transfer or repair decision`

## Branch/recycle state

Branch count after first cleanup:
`14`

Active branches:
- `main`
- `learning/sprint01-end-to-end-rts-production`

23 reviewed stale branch heads were removed from the Branch list after exact recovery tags were created under:

`recycle/2026-09-16/<original-branch-name>`

Reference/Hold branches are not current authority.

## Anti-loss handoff rule

Every material completion must leave:
- commit SHA;
- named artifact path;
- formal status/verdict;
- explicit NEXT_ROUTE or blocker.

A chat statement without repository anchors does not change project state.
