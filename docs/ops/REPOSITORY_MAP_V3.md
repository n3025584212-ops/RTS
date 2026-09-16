# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-16
PROJECT=FRONTLINE

## 1. Single entry path

Start only here:

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/WINDOW_RECOVERY_INDEX.md`

Do not infer current work from old Issue/PR titles, old window prompts, archived branches or historical screenshots.

## 2. Authority layers

### A. CURRENT CONTROL AUTHORITY — main

Use for:
- current phase;
- current active task;
- window routing;
- product-resume permission;
- restart boundaries;
- history/current separation.

Key files:
- `START_HERE.md`
- `docs/current/CURRENT_STATE.md`
- `docs/current/ACTIVE_WORK.md`
- `docs/current/WINDOW_RECOVERY_INDEX.md`
- `docs/current/RESTART_DECISION.md`
- `docs/current/DECISION_LOG.md`

### B. CURRENT SPRINT EXECUTION AUTHORITY — learning branch

Branch:
`learning/sprint01-end-to-end-rts-production`

Use for:
- evidence registers;
- Sprint 01 learning artifacts;
- Window 03 audits;
- isolated reproduction scenes/scripts;
- runtime blockers and evidence;
- learning-only workflows.

Important paths:
- `docs/learning/sprint01/`
- `docs/audit/`
- `scenes/learning/sprint01/`
- `scripts/learning/sprint01/`
- `artifacts/learning/sprint01/`
- `.github/workflows/learning-sprint01-*.yml`

### C. REUSABLE TECHNICAL FOUNDATION

Can be reused after evidence support but does not define product direction:
- Godot 4.7.1 project/runtime tooling;
- Formation / Task / Navigation / Combat reusable code;
- legal asset import/provenance tooling;
- screenshot/video/CI tooling;
- audited combat assets;
- preserved environment/content assets where provenance is valid.

### D. HISTORICAL / FAILURE EVIDENCE

Examples:
- Battle01;
- Prototype A/B;
- Golden Scene V1;
- River Town;
- Reference Region;
- local-high-fidelity visual branches;
- old three-lane battlefield attempts;
- superseded window/governance documents.

These may explain what was tried or supply reusable assets/tools. They do not automatically become the next product baseline.

## 3. Current Sprint 01 navigation

Current learning question:
prove a transferable RTS production chain from content/world through actual PLAYER result.

Completed checkpoints:

1. evidence/reference chain;
2. first player causal-chain reproduction;
3. independent audit;
4. Stage 4 world causal decomposition;
5. independent world-method audit;
6. current world-reproduction implementation.

Current unresolved checkpoint:

`fresh Godot 4.7.1 world-reproduction runtime + PLAYER-visible capture`

Canonical current blocker:
`docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

## 4. Current window locations

### 00 CONTROL

Main control files only. 00 is the only window that resolves control-state conflicts and product-transfer authority.

### 01 EVIDENCE

Primary current/finished artifacts:
- `docs/learning/sprint01/EVIDENCE_REGISTER.md`
- `docs/learning/sprint01/END_TO_END_CHAIN.md`
- `docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

### 02 REPRODUCTION

Current implementation:
- `scenes/learning/sprint01/Sprint01WorldReproduction.tscn`
- `scripts/learning/sprint01/sprint01_world_reproduction.gd`
- `docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`
- `.github/workflows/learning-sprint01-world-reproduction.yml`
- `docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

### 03 AUDIT

Primary audit chain:
- `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`
- `docs/audit/AUDIT_SPRINT01_REPAIR_AND_ASSET_GATE_V1.md`
- `docs/audit/AUDIT_SPRINT01_WINDOW02_REPRODUCTION_V1.md`
- fresh runtime/PLAYER audit for first reproduction;
- `docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md`

Do not infer an audit PASS from the existence of an audit file; read its formal verdict fields.

## 5. Branch map

### Current
- `main` — control state and repository entrypoint.
- `learning/sprint01-end-to-end-rts-production` — active Sprint 01 execution branch.

### Preserve as evidence/tool pools
- `dev/godot-golden-scene-v1`
- `dev/visual-production-reset`
- `dev/river-town-local-high-fidelity-v1`
- `dev/reference-region-v1`
- `dev/prototype-b-representative-battle-content-v1`
- `archive/legacy-unused`

KEEP does not mean CURRENT.

### Cleanup candidates

Continue tracking safe deletions in Issue #37. Do not delete branches with unique assets, evidence or unresolved provenance simply to simplify the branch list.

## 6. Anti-confusion conventions

- `docs/current/` = current control authority, not detailed build evidence.
- `docs/learning/` = learning/evidence and reproduction contracts.
- `docs/audit/` = independent review artifacts.
- `scenes/learning/`, `scripts/learning/`, `artifacts/learning/` = isolated experiments only.
- production directories are not resumed until Window 00 authorizes transfer after Sprint PASS.

## 7. Handoff completeness rule

A material task is considered repository-visible only when it has:

- `COMMIT_SHA`;
- `ARTIFACT_PATH`;
- formal status/verdict;
- explicit `NEXT_ROUTE` or blocker.

Window 00 must then refresh main control files. This prevents chat-window context loss from becoming project-state loss.
