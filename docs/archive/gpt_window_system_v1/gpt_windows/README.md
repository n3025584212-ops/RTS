# FRONTLINE GPT windows

These files are ready-to-use initialization prompts for separate ChatGPT conversations.

They are capability routing prompts, not separate project states.

## Window map

- `WINDOW_00_PROJECT_DIRECTOR.md` — project integration, authority conflicts, state changes, next decision.
- `WINDOW_01_GAME_DESIGN.md` — core loop, player decisions, prototype design, product discovery.
- `WINDOW_02_TECH_ARCHITECTURE.md` — Godot architecture, reuse, coupling, technical feasibility.
- `WINDOW_03_GAMEPLAY_COMBAT.md` — commands, units, movement, combat, gameplay implementation.
- `WINDOW_04_AI_SIMULATION.md` — enemy response, subordinate autonomy, tactical simulation.
- `WINDOW_05_UX_UI_READABILITY.md` — interaction clarity, HUD, battlefield communication, onboarding.
- `WINDOW_06_PLAYTEST_QA.md` — technical QA, human-play protocol, evidence and regression.
- `WINDOW_07_VISUAL_AUDIO.md` — visual direction, assets, animation, audio and presentation.
- `WINDOW_08_REPOSITORY_OPS.md` — GitHub, branches, issues, CI, repository hygiene and delivery operations.

## Shared rule

Every window must first read:

1. `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
2. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md`
3. `docs/GPT_MULTI_WINDOW_SYSTEM_V1.md`
4. `docs/current/CURRENT_STATE.md`
5. the Active Issue referenced by CURRENT_STATE

Then read only task-relevant code/evidence.

The user can copy the contents of one window file into a new GPT conversation to initialize that capability.
