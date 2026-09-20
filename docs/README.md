# FRONTLINE documentation map

This directory contains **active project authority** plus, under `archive/` and `current/history/`,
material that is explicitly non-authoritative.

## Start here

`docs/current/CURRENT_STATE.md` is the single source of current project truth — stage, gate and the
verified branch head. Nothing else in this tree states them.

## Active authority

- `current/CURRENT_STATE.md` — single source of current project truth
- `current/ACTIVE_WORK.md` — standing constraints and stopped routes (pointers only)
- `FRONTLINE_EXECUTION_MODEL_V1.md` — how work is executed and reviewed; evidence rules
- `FRONTLINE_PROJECT_CHARTER_V3.md` — project authority and phase model
- `FRONTLINE_PROJECT_SYSTEM_V3.md` — task / decision / evidence workflow
- `current/DECISION_LOG.md` — append-only material decision history
- `current/VISUAL_QUALITY_BASELINE.md` — visual baseline and retained engine references
- `ops/REPOSITORY_MAP_V3.md` — repository navigation
- `audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md` — independent review / falsification protocol
  (filename retained; it contains no routing rule)

The active GitHub Issue named by `CURRENT_STATE.md` is the working contract/evidence thread for the
current primary task.

## No windows

The GPT four-window routing layer was retired on 2026-09-20 and archived under
`archive/governance/`. Work is executed directly by a single agent; see
`FRONTLINE_EXECUTION_MODEL_V1.md`. Nothing routes by window number.

## Non-authoritative material

- `archive/governance/` — superseded governance documents. `ARCHIVE_INDEX.md` there records each
  supersession chain (project system V1/V2, multi-window V2/V3, collaboration V4, four-window V5,
  runtime plan V1/V2, the `gpt_windows/` prompts, repository map V2). None of them is authority.
- `current/history/` — one-off historical decisions that are not current state.
- `archive/legacy-unused` (branch) — early Battle01 contracts, retired visual targets and older
  material. Non-authoritative; may only regain authority if reaccepted through `main`.

## Rule of thumb

When two sources disagree, follow `current/CURRENT_STATE.md`; if the disagreement is about project
authority, follow `FRONTLINE_PROJECT_CHARTER_V3.md` and its authority order. Never restore an old
rule merely because it once carried a PASS/FROZEN label. A file declaring its own `STATUS=ACTIVE`
is not thereby authoritative — check the archive index and this map.
