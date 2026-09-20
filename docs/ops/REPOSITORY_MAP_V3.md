# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-17
PROJECT=FRONTLINE

## Single entry

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/VISUAL_QUALITY_BASELINE.md`

## Authority

### main
Control/routing/product-resume authority.

### learning/sprint01-end-to-end-rts-production
Sprint 01 evidence, implementation, runtime artifacts and audits.

### Reference / Hold
Historical assets/tools/evidence only; no current task authority.

### recycle tags
23 reviewed stale branch heads preserved under `recycle/2026-09-16/...`; not current authority.

## Current Sprint gate

`SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT`

Latest implementation/runtime source:
`b0fe6d8b1de747606138a9ce1b28b3541b8c464a`

Latest handoff:
`docs/learning/sprint01/HANDOFF_02_REAL_ENOUGH_WORLD_DELIVERY_TO_03_V1.md`

Latest audit task:
`docs/audit/TASK_03_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT_V1.md`

Fresh artifact:
`Actions run 35185311167 / artifact 10481469643`

The Actions run is red only at the final evidence branch writeback; runtime/capture/artifact upload succeeded.

## Current windows

- `00 CONTROL` — ACTIVE_CONTROL
- `01 EVIDENCE` — HOLD_STAGE4_COMPLETE
- `02 REPRODUCTION` — HOLD_RUNTIME_CAPTURE_COMPLETE
- `03 AUDIT` — ACTIVE_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT

03 now decides only the latest `REAL_ENOUGH_WORLD_DELIVERY` and `CAPTURE_STATE_ALIGNMENT` from actual fresh media, while checking for regressions in already-passed causal/readability fields.

## Key paths

- `docs/current/` — current control state
- `docs/learning/sprint01/` — learning/reproduction tasks, results, handoffs
- `docs/audit/` — independent audits/tasks
- `scenes/learning/sprint01/` — isolated Sprint scenes
- `scripts/learning/sprint01/` — isolated Sprint scripts
- `artifacts/learning/sprint01/` — branch-persisted evidence; always check Actions artifact identity for the newest run when a writeback race is recorded

## Branch hygiene

Active branches:
- `main`
- `learning/sprint01-end-to-end-rts-production`

Reference/Hold branches remain non-authoritative. Recycled branch heads remain recoverable through tags.

## Handoff completeness

A completion must leave an immutable commit SHA or Actions run/artifact identity, named artifact, formal status and explicit next route.
