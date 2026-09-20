# FRONTLINE documentation map

This directory contains **active project authority** plus, under `archive/` and `current/history/`,
material that is explicitly non-authoritative.

## Start here

`docs/current/CURRENT_STATE.md` is the single source of current project truth — stage, gate,
window routing and the verified branch head. Nothing else in this tree states them.

## Active authority

- `current/CURRENT_STATE.md` — single source of current project truth
- `current/ACTIVE_WORK.md` — standing constraints and stopped routes (pointers only)
- `FRONTLINE_PROJECT_CHARTER_V3.md` — project authority and phase model
- `FRONTLINE_PROJECT_SYSTEM_V3.md` — task / decision / evidence workflow
- `current/DECISION_LOG.md` — append-only material decision history
- `current/VISUAL_QUALITY_BASELINE.md` — visual baseline and retained engine references
- `ops/REPOSITORY_MAP_V3.md` — repository navigation
- `audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md` — Window 03 audit protocol

The active GitHub Issue named by `CURRENT_STATE.md` is the working contract/evidence thread for the
current primary task.

## GPT four-window collaboration

- `GPT_FOUR_WINDOW_SYSTEM_V5.md` — the four-window collaboration system.
- `GPT_WINDOW_RUNTIME_PLAN_V2.md` — ACTIVE / STANDBY / phase and decision-gate runtime rules.
- `gpt_windows/` — ready-to-copy initialization prompts for WINDOW_00–WINDOW_03.

Window IDs are routing labels only. All windows share the same CURRENT_STATE and authority order.

## Non-authoritative material

- `archive/governance/` — superseded governance documents. `ARCHIVE_INDEX.md` there records each
  supersession chain (project system V1/V2, multi-window V2/V3, collaboration V4, runtime plan V1,
  repository map V2). None of them is authority.
- `current/history/` — one-off historical decisions that are not current state.
- `archive/legacy-unused` (branch) — early Battle01 contracts, retired visual targets and older
  material. Non-authoritative; may only regain authority if reaccepted through `main`.

## Rule of thumb

When two sources disagree, follow `current/CURRENT_STATE.md`; if the disagreement is about project
authority, follow `FRONTLINE_PROJECT_CHARTER_V3.md` and its authority order. Never restore an old
rule merely because it once carried a PASS/FROZEN label. A file declaring its own `STATUS=ACTIVE`
is not thereby authoritative — check the archive index and this map.
