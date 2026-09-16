# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-16
PROJECT=FRONTLINE

## 1. Single entry path

Start only here:

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/WINDOW_RECOVERY_INDEX.md`

Do not infer current work from old Issue/PR titles, recycle tags, reference branches or historical screenshots.

## 2. Authority layers

### A. CURRENT CONTROL AUTHORITY — main

Use for:
- current phase;
- current active task;
- window routing;
- product-resume permission;
- restart boundaries;
- branch/recycle policy;
- history/current separation.

Key files:
- `START_HERE.md`
- `docs/current/CURRENT_STATE.md`
- `docs/current/ACTIVE_WORK.md`
- `docs/current/WINDOW_RECOVERY_INDEX.md`
- `docs/current/RESTART_DECISION.md`
- `docs/current/DECISION_LOG.md`
- `docs/ops/BRANCH_RECYCLE_BIN.md`

### B. CURRENT SPRINT EXECUTION AUTHORITY — learning branch

Branch:
`learning/sprint01-end-to-end-rts-production`

Use for:
- evidence registers;
- Sprint 01 learning artifacts;
- Window 03 audits;
- isolated reproduction scenes/scripts;
- runtime evidence;
- learning-only workflows.

Important paths:
- `docs/learning/sprint01/`
- `docs/audit/`
- `scenes/learning/sprint01/`
- `scripts/learning/sprint01/`
- `artifacts/learning/sprint01/`
- `.github/workflows/learning-sprint01-*.yml`

### C. REFERENCE / HOLD BRANCHES

These may contain unique assets/evidence/tooling but have no current task authority:

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

They must be consolidated/reviewed before later recycling.

### D. RECYCLE BIN — TAGS, NOT BRANCHES

First-pass branch cleanup on 2026-09-16 reduced branch count:

`37 -> 14`

23 reviewed stale/merged/superseded/CI-only branch heads were preserved as exact tags:

`recycle/2026-09-16/<original-branch-name>`

Manifest:
`docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md`

Recycle policy:
`docs/ops/BRANCH_RECYCLE_BIN.md`

Recycle tags preserve recoverability without polluting the Branch list. They are historical pointers, not current authority.

## 3. Current Sprint 01 navigation

Current gate:

`SPRINT01_PLAYER_WORLD_DELIVERY_FIX`

The new world reproduction has now run successfully in fresh Godot 4.7.1 and Window 03 independently audited the artifact.

Accepted:
- runtime execution;
- exact vehicle assets;
- world-method causal execution;
- player causal chain;
- capture state alignment.

Current failures:
- player unit readability;
- world-label occlusion;
- real-enough world delivery;
- player world readability.

Current audit:
`docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md`

Current route:
`02 player-world delivery repair -> fresh runtime -> 03 re-audit -> 00 transfer/repair decision`

## 4. Current window locations

### 00 CONTROL

Main control files only. 00 resolves control-state conflicts, branch authority and product-transfer authority.

### 01 EVIDENCE

Current role: HOLD, Stage 4 complete.

Primary artifacts:
- `docs/learning/sprint01/EVIDENCE_REGISTER.md`
- `docs/learning/sprint01/END_TO_END_CHAIN.md`
- `docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

### 02 REPRODUCTION

Current role: ACTIVE_PLAYER_WORLD_DELIVERY_FIX.

Primary implementation/evidence:
- `scenes/learning/sprint01/Sprint01WorldReproduction.tscn`
- `scripts/learning/sprint01/sprint01_world_reproduction.gd`
- `docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`
- `docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md`
- `artifacts/learning/sprint01/world_reproduction/`

### 03 AUDIT

Current role: HOLD_PENDING_REPAIRED_RUNTIME.

Primary latest audit:
- `docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md`

Do not infer an audit PASS from file existence; read formal verdict fields.

## 5. Branch map

### ACTIVE — only 2
- `main`
- `learning/sprint01-end-to-end-rts-production`

### REFERENCE / HOLD — 12
See Section 2C. These are not active project lines.

### RECYCLED — 23
No longer appear as branches. Recover from `recycle/2026-09-16/...` tags if ever needed.

Future temporary branches should be merged/consolidated and recycled promptly after task closure instead of accumulating indefinitely.

## 6. Anti-confusion conventions

- `docs/current/` = current control authority, not detailed build evidence.
- `docs/learning/` = learning/evidence and reproduction contracts/results.
- `docs/audit/` = independent review artifacts.
- `scenes/learning/`, `scripts/learning/`, `artifacts/learning/` = isolated experiments only.
- recycle tags = recoverable history only.
- reference branches = evidence/tool pools only.
- production directories are not resumed until Window 00 authorizes transfer after Sprint PASS.

## 7. Handoff completeness rule

A material task is repository-visible only when it has:

- `COMMIT_SHA`;
- `ARTIFACT_PATH`;
- formal status/verdict;
- explicit `NEXT_ROUTE` or blocker.

Window 00 must then refresh main control files. This prevents chat-window context loss from becoming project-state loss.
