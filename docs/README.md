# FRONTLINE documentation map — product branch

This branch carries **gate evidence and the product integration**. Governance authority lives on
`main`. Do not look for it here, and do not trust a governance document found on this branch.

## On this branch

- `current/GATE_*_INDEPENDENT_AUDIT_V1.md` — independent audit reports cited by main's control state
- `visual_baseline/gate_*/` — gate evidence: media, JSON, run logs, delta reports
- `licenses/` — asset provenance for the assets this branch ships
- `design/`, `production/` — visual spec and asset-manifest copies
- `audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md` — copy of the Window 03 audit protocol
  (canonical on main; keep the two in sync)

## On main (authority)

- `current/CURRENT_STATE.md` — the single control state (stage / gate / window / head)
- `current/DECISION_LOG.md`, `current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md`
- `FRONTLINE_PROJECT_CHARTER_V3.md`, `FRONTLINE_PROJECT_SYSTEM_V3.md`
- `GPT_FOUR_WINDOW_SYSTEM_V5.md`, `GPT_WINDOW_RUNTIME_PLAN_V2.md`
- `ops/REPOSITORY_MAP_V3.md`
- `archive/governance/ARCHIVE_INDEX.md` — the supersession chains

## Archived here

`archive/governance/` — the superseded governance versions this branch happened to carry
(project system V1/V2, multi-window V2/V3, runtime plan V1). Non-authoritative.

## Local copies of authority documents

`current/DECISION_LOG.md` and `current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md` also exist on this branch
as working copies. They are **not** authority; main's versions win. `current/CURRENT_STATE.md` on
this branch is deliberately reduced to a pointer at main's.
