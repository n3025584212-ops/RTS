# FRONTLINE CURRENT PRODUCT STATE — SUPERSEDED COPY (POINTER)

STATUS=SUPERSEDED_POINTER
PROJECT=FRONTLINE
SUPERSEDED_ON=2026-09-20
LAST_FULL_REVISION_IN_THIS_FILE=V22
AUTHORITY=main::docs/current/CURRENT_STATE.md

THIS FILE IS NOT THE CONTROL STATE.

Until 2026-09-20 this branch carried a full copy of the control state. It drifted to
V22 while main advanced to V44, and both copies declared SOURCE_OF_TRUTH=THIS_FILE,
so a window working in this product worktree read a stale state and never saw the main
authority: it believed the active gate was MINIMUM_ARMORED_UNIT_INTEGRATION while main
had already closed Gate D2. Do not read this file for state.

Read the authority instead — all of it lives on main:

- Control state ......... main::docs/current/CURRENT_STATE.md
- Gate contract ......... main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md
- Audit protocol ........ main::docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md
- Decision history ...... main::docs/current/DECISION_LOG.md
- Active work ........... main::docs/current/ACTIVE_WORK.md

This branch (product/frontline-high-fidelity-slice-v1) carries gate EVIDENCE only:

- docs/visual_baseline/gate_b_20260920/
- docs/visual_baseline/gate_d1_20260920/
- docs/visual_baseline/gate_d2_20260920/
- docs/current/GATE_*_INDEPENDENT_AUDIT_V1.md  (audit reports cited by the main control state)

Do not record product state in this worktree, and do not grow this file back into a
state copy. The V22 text is preserved in git history (the commit before this one).
