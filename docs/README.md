# FRONTLINE documentation map

This directory contains only **active project authority and current-state support**.

## Active authority

Use these files for current work:

- `current/CURRENT_STATE.md` — single source of current project truth.
- `FRONTLINE_PROJECT_CHARTER_V3.md` — project authority and phase model.
- `FRONTLINE_PROJECT_SYSTEM_V1.md` — day-to-day task/decision/evidence workflow.
- `current/DECISION_LOG.md` — append-only material decision history.

The active GitHub Issue named by `CURRENT_STATE.md` is the working contract/evidence thread for the current primary task.

## GPT four-window collaboration

- `GPT_MULTI_WINDOW_SYSTEM_V2.md` — shared rules for the four GPT routing contexts.
- `GPT_WINDOW_RUNTIME_PLAN_V1.md` — ACTIVE / STANDBY / phase and decision-gate runtime rules.
- `gpt_windows/` — ready-to-copy initialization prompts for WINDOW_00–WINDOW_03.

Window IDs are routing labels only. All windows share the same CURRENT_STATE and authority order.

## Historical / unused material

Clearly superseded Battle01 contracts, retired governance documents, old visual targets and superseded GPT window systems are stored on:

`archive/legacy-unused`

That branch is non-authoritative. Material there may only regain current authority if explicitly reaccepted through `docs/current/CURRENT_STATE.md` on `main`.

## Rule of thumb

When two sources disagree, follow the authority order in `FRONTLINE_PROJECT_CHARTER_V3.md`; do not restore an old rule merely because it once had a PASS/FROZEN label.
