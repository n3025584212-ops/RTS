# FRONTLINE GPT MULTI-WINDOW SYSTEM V2

STATUS=ACTIVE_COLLABORATION_SYSTEM
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_PROJECT_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md
RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md

SUPERSEDES=docs/GPT_MULTI_WINDOW_SYSTEM_V1.md

## 1. Purpose

FRONTLINE uses a small number of persistent GPT chat contexts to separate reasoning workloads without splitting project truth.

The operating model is:
- four reusable GPT windows;
- one GitHub repository;
- one `CURRENT_STATE`;
- one current product question;
- normally one primary active task;
- no mandatory handoff chain.

Window numbers are routing labels only. They do not own independent state, roadmap, freeze authority or product authority.

## 2. Active windows

ACTIVE_WINDOWS:
- WINDOW_00 = Project Control / Integration
- WINDOW_01 = Design / Experience
- WINDOW_02 = Development
- WINDOW_03 = Review / Operations

### WINDOW_00 — Project Control / Integration
Owns integration, priority framing, conflict resolution, task routing and material `CURRENT_STATE` updates.

### WINDOW_01 — Design / Experience
Combines game design, product discovery, interaction/UX, UI readability, playtest interpretation and player-facing visual direction.

During early construction it defines enough player-facing target to guide implementation; it does not require simulated player-experience proof before the game is sufficiently playable.

### WINDOW_02 — Development
Combines Godot architecture, gameplay, combat, units, AI/autonomy, implementation and focused technical verification.

When `CURRENT_STATE` authorizes minimum-playable construction, WINDOW_02 actively builds it without waiting for fake-player approval on each increment.

### WINDOW_03 — Review / Operations
Combines independent QA, regression review, playable-readiness evidence, PR/CI review, repository hygiene and production operations.

It may verify readiness evidence but does not simulate a human player or decide whether the game is fun.

## 3. Shared initialization

Every window begins by reading from GitHub `main`:

1. `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
2. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md`
3. `docs/GPT_MULTI_WINDOW_SYSTEM_V2.md`
4. `docs/GPT_WINDOW_RUNTIME_PLAN_V1.md`
5. `docs/current/CURRENT_STATE.md`
6. the Active Issue referenced by `CURRENT_STATE.md`
7. only the code, PRs, evidence or archived material directly needed for its current work

Do not ask the user to restate information available from these sources.

## 4. Authority order

All windows use:

1. USER_EXPLICIT_DECISION
2. `docs/current/CURRENT_STATE.md`
3. accepted current decisions / `DECISION_LOG.md`
4. current Active Issue
5. current implementation, playtest and QA evidence
6. historical material

If sources conflict, do not silently choose the specialist-preferred interpretation.

## 5. State ownership

`CURRENT_STATE.md` remains the only living project truth.

Default write authority:
- WINDOW_00 integrates material state changes;
- WINDOW_01–03 produce decisions, evidence, implementation or review results;
- WINDOW_01–03 edit `CURRENT_STATE.md` only when the user or active task explicitly delegates that action.

The user remains final product authority.

## 6. Evidence boundaries

FRONTLINE distinguishes:

1. TECHNICAL_VERIFICATION — agents/tests may perform this;
2. MINIMUM_PLAYABLE_READINESS — agents may check whether enough coherent game exists to justify human evaluation;
3. HUMAN_PRODUCT_EVIDENCE — only real human play counts.

CODEX_SIMULATED_HUMAN_PLAY=INVALID
AUTOMATION_CANNOT_DECLARE_PLAYER_EXPERIENCE_PASS=YES

Human experience testing is important, but it is not required after every small implementation increment.

## 7. No manual receipt chain

The system does not require:

`00 -> 01 -> receipt -> 00 -> 02 -> receipt -> 00`.

Instead, each window reads shared GitHub state and writes useful durable outputs to the appropriate project surface:
- Active Issue for decision/evidence discussion;
- branch/PR for implementation;
- tests/CI for technical evidence;
- current state only for material integrated changes.

WINDOW_00 reads those durable results when integration is needed.

## 8. Activation model

Do not keep every window busy.

WINDOW_00 is the normal persistent control context.
WINDOW_01–03 are activated only when their context materially helps the current task.

Detailed phase/trigger rules are defined in `docs/GPT_WINDOW_RUNTIME_PLAN_V1.md`.

## 9. Parallel work

Parallel work is allowed when low-conflict.

Good examples:
- WINDOW_01 defines the player-facing target while WINDOW_02 builds the authorized minimum coherent playable;
- WINDOW_02 implements while WINDOW_03 prepares independent technical/readiness verification;
- WINDOW_03 performs repository cleanup while WINDOW_01 continues product analysis, provided cleanup does not alter product direction.

Bad examples:
- WINDOW_01 and WINDOW_02 independently choosing different final core loops;
- WINDOW_01 demanding simulated-human approval before every implementation step;
- WINDOW_02 expanding beyond the current prototype into Battle01 production;
- WINDOW_03 treating test completeness as product authority;
- WINDOW_00 manufacturing work merely to keep all windows active.

## 10. Conflict rule

When windows disagree on a material product question:
- preserve each supported position;
- identify the evidence gap;
- WINDOW_00 presents the conflict to the user;
- the user decides direction or authorizes a discriminating test.

Do not average incompatible recommendations into a false consensus.

## 11. Hard and soft boundaries

HARD:
- one current state;
- user product authority;
- current phase and production status;
- engine/runtime requirements;
- accepted decisions;
- explicit task non-goals;
- actual human-play requirement for final core gameplay acceptance;
- no Codex-simulated human evidence.

SOFT:
- exact internal capability boundary between the four windows;
- whether one window temporarily performs an overlapping low-risk task;
- prototype implementation details;
- response format;
- terminology and sequencing when authority is unaffected.

## 12. Archive rule

Superseded, historical or unused project material belongs on:

`archive/legacy-unused`

Historical material may be consulted but does not regain authority unless explicitly reaccepted through `main:docs/current/CURRENT_STATE.md`.

## 13. Current condition

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED
CURRENT_PRIMARY_TASK=BUILD_PROTOTYPE_B_MINIMUM_COHERENT_PLAYABLE_V1
ACTIVE_ISSUE=#20

CURRENT_WINDOW_RUNTIME:
- WINDOW_00=ACTIVE
- WINDOW_01=ACTIVE_TARGET_DEFINITION
- WINDOW_02=ACTIVE_MINIMUM_PLAYABLE_BUILD
- WINDOW_03=STANDBY_ON_DEMAND

PLAYER_EXPERIENCE_GATE=AFTER_MINIMUM_PLAYABLE_READINESS
CODEX_SIMULATED_HUMAN_PLAY=INVALID
GPT_WINDOW_COUNT=4
INDEPENDENT_WINDOW_PROJECT_STATES=NO
PERMANENT_HANDOFF_CHAIN=NO
USER_PRODUCT_AUTHORITY=YES
