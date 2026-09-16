# FRONTLINE Branch Recycle Bin

STATUS=ACTIVE
DATE=2026-09-16
OWNER=WINDOW_00_CONTROL

## Goal

Keep the GitHub branch list small enough that active work is obvious, without throwing away historical commit pointers.

## Branch classes

### ACTIVE
Only branches that can receive current project work:

- `main` — control state, routing, repository entrypoints.
- `learning/sprint01-end-to-end-rts-production` — current Sprint 01 evidence/build/runtime branch.

### REFERENCE / HOLD
Branches that still contain unique or not-yet-consolidated assets/evidence. They are not current work and should not be used as task authority:

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

These can be consolidated/recycled later only after a separate uniqueness check.

### RECYCLE
Stale/merged/superseded/CI-only branches already reviewed in Issue #37 are not kept as branch refs.

Before deletion, each exact HEAD is preserved as a lightweight Git tag:

`recycle/2026-09-16/<original-branch-name>`

The original branch name and exact SHA are recorded in:

`docs/ops/BRANCH_RECYCLE_MANIFEST_2026-09-16.md`

## Recovery

To restore a recycled branch named `<old-branch>`:

```bash
git switch -c <old-branch> recycle/2026-09-16/<old-branch>
git push -u origin <old-branch>
```

No recycled tag is product authority. It is only a recoverable historical pointer.

## Safety rules

- Never recycle `main`.
- Never recycle the current `ACTIVE_BRANCH` from `docs/current/CURRENT_STATE.md`.
- Never recycle a branch whose HEAD changed after the manifest review without re-review.
- Validate all candidate branch HEAD SHAs before deleting any branch refs.
- Create and verify recycle tags before deleting branch refs.
- Reference/Hold branches require a separate uniqueness review before moving into recycle.

## Expected result of first cleanup

Branch count before cleanup: `37`.

First-pass reviewed recycle candidates: `23`.

Expected branch count after successful cleanup: approximately `14`.

The recycle tags remain visible under Tags, not Branches, so normal branch navigation stays focused on current work.
