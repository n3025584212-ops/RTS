# FRONTLINE Repository Map V3

STATUS=CURRENT_NAVIGATION
DATE=2026-09-20 (navigation revised; structure unchanged since V3, 2026-09-17)
PROJECT=FRONTLINE

## Single entry

`README.md -> START_HERE.md -> docs/current/CURRENT_STATE.md -> docs/current/ACTIVE_WORK.md -> docs/current/VISUAL_QUALITY_BASELINE.md`

## Authority

### main

Control/routing/product-resume authority. The only place where the current stage, gate, window
routing and verified branch head are stated: `docs/current/CURRENT_STATE.md`.

### product/frontline-high-fidelity-slice-v1

The product slice. Carries gate evidence under `docs/visual_baseline/gate_*/` and the independent
audit reports under `docs/current/GATE_*_INDEPENDENT_AUDIT_V1.md`. It holds no state authority —
its copy of `docs/current/CURRENT_STATE.md` is deliberately a pointer at main.

### learning/sprint01-end-to-end-rts-production

Sprint 01 learning evidence, implementation, runtime artifacts and audits. Stopped as an active
product route; see `docs/current/ACTIVE_WORK.md` for the standing rule.

### Reference / Hold

Historical assets/tools/evidence only; no current task authority.

### recycle tags

23 reviewed stale branch heads preserved under `recycle/2026-09-16/...`; not current authority.

## Current state

Deliberately not recorded here. `docs/current/CURRENT_STATE.md` is the only document that states
the current stage, gate, window routing and verified branch head. This map describes structure,
not status — if you need status, read the control state.

## Key paths

- `docs/current/` — control state, decision history, visual baseline, gate contract
- `docs/design/` — the formal visual target specification
- `docs/audit/` — Window 03 audit protocol and audit tasks
- `docs/ops/` — repository operations: branch recycling, archive manifests, this map
- `docs/archive/governance/` — superseded governance versions plus `ARCHIVE_INDEX.md`
- `scenes/production/RiverTownVisualSlice.tscn` — the product mother scene
- `scripts/production/` — product scripts
- `tools/` — capture drivers and checkers (`gate_*_capture.gd`, `compare_render_delta.py`,
  `check_doc_authority.py`)

## Branch hygiene

Active branches:

- `main`
- `product/frontline-high-fidelity-slice-v1`

Reference/Hold branches remain non-authoritative. Recycled branch heads remain recoverable through
tags. Superseded governance documents are **archived** under `docs/archive/governance/` rather than
deleted, so a supersession can be traced; `tools/check_doc_authority.py` fails if two documents of
the same topic family both claim to be current.

## Handoff completeness

A completion must leave an immutable commit SHA or Actions run/artifact identity, named artifact,
formal status and explicit next route.
