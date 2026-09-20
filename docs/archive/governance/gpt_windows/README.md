# FRONTLINE GPT windows

These files are ready-to-copy initialization prompts for separate ChatGPT conversations.

They are routing contexts, not separate project states.

## Active window map

- `WINDOW_00_PROJECT_CONTROL.md` — project control, integration, state changes, conflict resolution and window activation.
- `WINDOW_01_DESIGN_EXPERIENCE.md` — game design, product discovery, UX/UI, readability, player feedback and first-use flow.
- `WINDOW_02_DEVELOPMENT.md` — Godot architecture, gameplay, combat, units, AI, implementation and technical verification.
- `WINDOW_03_REVIEW_OPERATIONS.md` — independent QA, playtest evidence, PR/CI review, repository hygiene and archival operations.

## Shared initialization

Every window first reads:

1. `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
2. `docs/FRONTLINE_PROJECT_SYSTEM_V3.md`
3. `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
4. `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md`
5. `docs/current/CURRENT_STATE.md`
6. the Active Issue referenced by CURRENT_STATE

Then read only task-relevant code/evidence.

## Runtime rule

Do not keep all windows busy.

At the current `P0_DISCOVER` stage:
- WINDOW_00 = ACTIVE
- WINDOW_01 = ACTIVE
- WINDOW_02 = STANDBY_FEASIBILITY_ONLY
- WINDOW_03 = STANDBY_ON_DEMAND

Use `docs/GPT_WINDOW_RUNTIME_PLAN_V2.md` for activation triggers and phase defaults.

## Shared-state rule

- only WINDOW_00 edits `CURRENT_STATE.md` by default;
- other windows do so only when explicitly delegated by the user/current task;
- no mandatory chat receipt chain;
- durable results should live in the Active Issue, branch/PR, code, tests or CI evidence.
