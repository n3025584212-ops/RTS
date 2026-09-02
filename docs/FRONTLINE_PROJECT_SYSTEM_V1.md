# FRONTLINE PROJECT SYSTEM V1

STATUS=ACTIVE_PROJECT_SYSTEM
PROJECT=FRONTLINE
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
ENGINE_BASELINE=Godot_4_7_1
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
GPT_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md

This document defines how FRONTLINE is operated day to day. It does not create a second project state and does not override the charter.

---

## 1. System objective

Keep the project centered on one product question, one primary task, enough real construction to test meaningfully, and explicit decisions.

The system must reduce coordination cost rather than create paperwork or endless premature validation loops.

SYSTEM_GOALS:
- one current state;
- one primary product question;
- normally one primary active task;
- product decisions separated from implementation details;
- technical verification separated from playable readiness and human product evidence;
- enough history to explain why a decision exists without turning history into current authority.

---

## 2. Authority order

When information conflicts:

1. USER_EXPLICIT_DECISION
2. docs/current/CURRENT_STATE.md
3. ACCEPTED product decisions recorded in current state / decision log
4. active task Issue
5. current implementation, playtest and QA evidence
6. historical documents, old Issues, old PRs and old window contracts

Historical PASS does not automatically create current product authority.

---

## 3. Active project surfaces

Only four surfaces are needed for normal work.

### A. Charter
`docs/FRONTLINE_PROJECT_CHARTER_V3.md`

### B. Current State
`docs/current/CURRENT_STATE.md`

The only living project truth.

### C. Active Issue
The working contract and evidence thread for the current primary task. It is not a second state document.

### D. Decision Log
`docs/current/DECISION_LOG.md`

Append-only material decision history, not an alternative roadmap.

---

## 4. Task model

A primary task should produce a player-facing result, decision-quality evidence, or a necessary enabling result directly tied to the current product question.

Every primary task should state as needed:
- TASK_ID
- CURRENT_PHASE
- PRODUCT_QUESTION
- PLAYER_FACING_CHANGE or DECISION_OUTPUT
- HYPOTHESIS_OR_ACCEPTED_REQUIREMENT
- AUTHORIZED_SCOPE
- HARD_CONSTRAINTS
- SOFT_CHOICES
- NON_GOALS
- COMPLETION_EVIDENCE
- DECISION_AFTER_EVIDENCE

HARD_CONSTRAINTS protect accepted product identity, engine/runtime requirements, safety, explicit user decisions or proven dependencies.

SOFT_CHOICES are implementation, UX, terminology, timing, layout, tuning and presentation choices that remain adjustable unless evidence justifies freezing them.

Do not convert a convenient implementation choice into a permanent product rule.

---

## 5. Discovery and construction loop

For unproven gameplay, use a loop that builds enough substance before asking for product judgment:

QUESTION
-> PLAYER-FACING TARGET
-> MINIMUM COHERENT PLAYABLE
-> REAL GODOT TECHNICAL VERIFY
-> PLAYABLE READINESS CHECK
-> HUMAN PLAY WHEN READY
-> KEEP / REWORK / KILL / CONTINUE BUILD

Do not require a paper design to prove player experience before implementation exists.
Do not ask the user to repeatedly judge half-formed increments that do not yet constitute a meaningful playable.

A failed prototype is valid evidence. A thin prototype may also simply be NOT_READY_FOR_PRODUCT_JUDGMENT rather than a meaningful product failure.

---

## 6. Build loop after a product decision is accepted

SCOPED ISSUE
-> FEATURE / PROTOTYPE BRANCH WHEN NEEDED
-> IMPLEMENT
-> FOCUSED TECHNICAL VERIFY
-> PLAYER / UX REVIEW WHEN RELEVANT AND READY
-> PR
-> MERGE IF CURRENT PRODUCT VALUE EXISTS
-> UPDATE CURRENT_STATE

Disposable prototypes do not need to merge to main.

---

## 7. Three evidence layers

### Layer 1 — Technical verification

Answers: does the implementation work as specified?

Evidence may include:
- parse/import/boot;
- runtime behavior;
- deterministic or focused mechanical checks;
- regressions;
- CI/tests.

Codex, scripted agents and automation are valid here.

TECHNICAL_PASS proves only technical behavior.

### Layer 2 — Minimum playable readiness

Answers: is there enough coherent game here that asking a human to judge experience is worthwhile?

Typical readiness includes:
- visible situation/objective;
- controllable player action;
- opposition or changing battlefield state;
- consequences;
- readable feedback;
- continued play loop;
- recognizable result/restart path.

This is a readiness threshold, not a claim that the game is fun.

### Layer 3 — Human product evidence

Answers questions such as:
- does the player understand what they are doing?
- are choices meaningful?
- is the command experience interesting?
- does the player want to continue?

Only actual human play provides this evidence.

CODEX_SIMULATED_HUMAN_PLAY=INVALID
AUTOMATED_PLAYER_EXPERIENCE_CLAIM=INVALID

Direct human play remains decisive for core gameplay acceptance, but it is used when Layer 2 has been reached rather than after every implementation increment.

---

## 8. Capabilities and four GPT windows

Design, engineering, AI, combat, UX, art, audio, QA, research and production remain capabilities selected per task.

For persistent ChatGPT contexts FRONTLINE uses four routing windows under `docs/GPT_MULTI_WINDOW_SYSTEM_V2.md`:

- WINDOW_00 = Project Control / Integration
- WINDOW_01 = Design / Experience
- WINDOW_02 = Development
- WINDOW_03 = Review / Operations

These are reusable contexts, not departments. They do not maintain separate current states, roadmaps, freeze rights or mandatory handoff chains.

Activation and standby rules are defined by `docs/GPT_WINDOW_RUNTIME_PLAN_V1.md`. Use the minimum number of windows needed; do not manufacture work to keep windows active.

LEGACY_PERMANENT_WINDOW_SYSTEM=ABOLISHED
GPT_MULTI_WINDOW_ROUTING=YES
GPT_WINDOW_COUNT=4
INDEPENDENT_WINDOW_PROJECT_STATES=NO
PERMANENT_HANDOFF_CHAIN=NO
SPECIALIST_ROADMAP_AUTHORITY=NO

---

## 9. Parallel work rule

Normally keep one primary task.

Parallel work is allowed only when it:
- does not create competing product directions;
- does not resume paused production implicitly;
- is clearly scoped construction, design support, maintenance, investigation, tooling or evidence work;
- shares durable results through GitHub rather than chat receipt chains.

If parallel work begins to affect the roadmap, it must become visible in CURRENT_STATE.

---

## 10. State transition rule

Update CURRENT_STATE only when something material changes:
- user makes a product/process decision;
- human play changes a hypothesis;
- a task becomes active / complete / blocked;
- a prototype becomes the current playable;
- a requirement becomes ACCEPTED, REOPENED or SUPERSEDED;
- next decision changes.

Do not update CURRENT_STATE for routine implementation noise.
When a material decision is finalized, append it to DECISION_LOG.

---

## 11. Historical governance handling

Older FRONTLINE governance, Battle01 contracts, legacy permanent-window documents and superseded GPT window systems remain in Git history or `archive/legacy-unused` as evidence.

Unless explicitly reaccepted by CURRENT_STATE, classify them as HISTORICAL_REFERENCE, reusable evidence or candidate material to re-evaluate. They must not silently override V3 charter or current product state.

---

## 12. Current operating rule

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED
PRIMARY_TASK=BUILD_PROTOTYPE_B_MINIMUM_COHERENT_PLAYABLE_V1
PLAYER_EXPERIENCE_GATE=AFTER_MINIMUM_PLAYABLE_READINESS
CODEX_SIMULATED_HUMAN_PLAY=INVALID
NO_GAMEPLAY_SCOPE_EXPANSION_BEYOND_ACTIVE_TASK=YES
PLAYER_EVIDENCE_OVER_INTERNAL_COMPLETENESS=YES
GPT_MULTI_WINDOW_COLLABORATION=YES
GPT_WINDOW_COUNT=4
