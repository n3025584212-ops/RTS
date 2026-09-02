# FRONTLINE documentation map

This directory contains only **active project authority and current-state support**.

## Active authority

Use these files for current work:

- `current/CURRENT_STATE.md` — single source of current project truth.
- `FRONTLINE_PROJECT_CHARTER_V3.md` — project authority and phase model.
- `FRONTLINE_PROJECT_SYSTEM_V1.md` — day-to-day task/decision/evidence workflow.
- `current/DECISION_LOG.md` — append-only product decision history.

The active GitHub Issue named by `CURRENT_STATE.md` is the working contract/evidence thread for the current primary task.

## GPT multi-window collaboration

- `GPT_MULTI_WINDOW_SYSTEM_V1.md` — shared rules for using multiple GPT chats without splitting project truth.
- `gpt_windows/` — ready-to-copy initialization prompts for WINDOW_00–WINDOW_08.

Window IDs are routing labels only. All windows share the same CURRENT_STATE and authority order.

## Historical / unused material

Clearly superseded Battle01 contracts, retired governance documents and old visual targets are stored on the branch:

`archive/legacy-unused`

That branch is non-authoritative. Material there may only regain current authority if explicitly reaccepted through `docs/current/CURRENT_STATE.md` on `main`.

## Rule of thumb

When two sources disagree, follow the authority order in `FRONTLINE_PROJECT_CHARTER_V3.md`; do not restore an old rule merely because it once had a PASS/FROZEN label.
