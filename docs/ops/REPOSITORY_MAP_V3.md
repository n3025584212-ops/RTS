# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-16
PROJECT=FRONTLINE
CONTROL_AUTHORITY=main

## Single recovery path

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/WINDOW_RECOVERY_INDEX.md`

On this branch these files are mirrors so windows do not recover obsolete control state. Final routing/product authority remains main / Window 00.

## Current authority layers

### main control plane

Use for:
- phase;
- active task;
- window routing;
- product-resume permission;
- branch/recycle policy;
- current/historical authority boundary.

### learning Sprint 01 execution plane

Branch:
`learning/sprint01-end-to-end-rts-production`

Use for:
- evidence and learning artifacts;
- Window 03 audits;
- isolated scenes/scripts;
- runtime evidence;
- learning-only workflows.

Key paths:
- `docs/learning/sprint01/`
- `docs/audit/`
- `scenes/learning/sprint01/`
- `scripts/learning/sprint01/`
- `artifacts/learning/sprint01/`
- `.github/workflows/learning-sprint01-*.yml`

## Current Sprint 01 gate

`SPRINT01_PLAYER_WORLD_DELIVERY_FIX`

Fresh world reproduction runtime has executed successfully.

Latest independent audit:
`docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md`

Passed:
- runtime execution;
- exact vehicle assets;
- world-method causal execution;
- player causal chain;
- capture-state alignment.

Failed:
- player unit readability;
- world-label occlusion;
- real-enough world delivery;
- player world readability.

Current route:
`02 repair PLAYER world delivery -> fresh runtime -> 03 re-audit -> 00 transfer/repair decision`

## Branch map

### ACTIVE — only 2
- `main`
- `learning/sprint01-end-to-end-rts-production`

### REFERENCE / HOLD — not current authority
- `archive/legacy-unused`
- `dev/godot-golden-scene-v1`
- `dev/visual-production-reset`
- `dev/river-town-local-high-fidelity-v1`
- `dev/reference-region-v1`
- `dev/prototype-b-representative-battle-content-v1`
- `discovery/prototype-b-task-reserve-v1`
- `agent/design-sandbox-01`
- `dev/asset-pipeline-v1`
- `dev/asset-pipeline-v2-multi-source`
- `dev/industrial-repair-workshop-v1`
- `ci/godot-toolchain-unified-cache-sha256-lock`

### RECYCLE BIN

First-pass cleanup reduced branch count from `37` to `14`.

23 reviewed stale/merged/superseded/CI-only branch heads were preserved as exact recovery tags under:

`recycle/2026-09-16/<original-branch-name>`

Canonical recycle policy and manifest live on `main`:
- `docs/ops/BRANCH_RECYCLE_BIN.md`
- `docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md`

Recycle tags are historical recovery pointers only.

## Directory meaning

- `docs/current/` = state/routing mirrors on this branch.
- `docs/learning/` = learning/evidence/reproduction contracts/results.
- `docs/audit/` = independent reviews.
- `scenes/learning/`, `scripts/learning/`, `artifacts/learning/` = isolated Sprint experiments.
- product directories do not resume until Window 00 authorizes transfer.

## Handoff completeness

A task is repository-visible only when it has:
- COMMIT_SHA;
- ARTIFACT_PATH;
- formal status/verdict;
- NEXT_ROUTE or blocker.
