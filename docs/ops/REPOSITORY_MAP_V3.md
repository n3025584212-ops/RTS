# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-16
PROJECT=FRONTLINE

## Single recovery path

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/WINDOW_RECOVERY_INDEX.md`

On this branch, these files are mirrors so windows do not recover obsolete control state. Final routing/product authority remains main / Window 00.

## Current authority layers

### main control plane

Use for:
- phase;
- active task;
- window routing;
- product-resume permission;
- current/historical authority boundary.

### learning Sprint 01 execution plane

Branch:
`learning/sprint01-end-to-end-rts-production`

Use for:
- evidence and learning artifacts;
- Window 03 audits;
- isolated scenes/scripts;
- runtime blockers and evidence;
- learning-only workflows.

Key paths:
- `docs/learning/sprint01/`
- `docs/audit/`
- `scenes/learning/sprint01/`
- `scripts/learning/sprint01/`
- `artifacts/learning/sprint01/`
- `.github/workflows/learning-sprint01-*.yml`

## Current Sprint 01 objects

World learning:
- `docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md`

World audit:
- `docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md`

World reproduction:
- `scenes/learning/sprint01/Sprint01WorldReproduction.tscn`
- `scripts/learning/sprint01/sprint01_world_reproduction.gd`
- `docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md`
- `.github/workflows/learning-sprint01-world-reproduction.yml`

Current blocker:
- `docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md`

## Current unresolved gate

`fresh Godot 4.7.1 world reproduction runtime + PLAYER-visible capture`

No runtime evidence currently exists for the new world reproduction because the latest hosted attempt failed before runner assignment.

## Historical/tool pools

The following remain useful evidence/assets/tools but are not current product authority:
- Battle01;
- Prototype A/B;
- Golden Scene V1;
- River Town;
- Reference Region;
- local-high-fidelity branches;
- older visual and three-lane experiments.

## Directory meaning

- `docs/current/` = state/routing mirrors on this branch.
- `docs/learning/` = learning/evidence/reproduction contracts.
- `docs/audit/` = independent reviews.
- `scenes/learning/`, `scripts/learning/`, `artifacts/learning/` = isolated Sprint experiments.
- product directories do not resume until Window 00 authorizes transfer.

## Handoff completeness

A task is repository-visible only when it has:
- COMMIT_SHA;
- ARTIFACT_PATH;
- formal status/verdict;
- NEXT_ROUTE or blocker.
