# FRONTLINE PROJECT SYSTEM V1

STATUS=ACTIVE_PROJECT_SYSTEM
PROJECT=FRONTLINE
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
ENGINE_BASELINE=Godot_4_7_1
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V1.md

This document defines how FRONTLINE is operated day to day. It does not create a second project state and does not override the charter.

---

## 1. System objective

Keep the project centered on one product question, one primary task, direct playable evidence, and explicit decisions.

The system must reduce coordination cost rather than create paperwork.

SYSTEM_GOALS:
- one current state;
- one primary product question;
- normally one primary active task;
- product decisions separated from implementation details;
- direct play separated from technical verification;
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

Defines durable project rules and authority.

### B. Current State
`docs/current/CURRENT_STATE.md`

The only living project truth. It should stay compact and answer:
- current phase;
- current product question;
- current playable;
- accepted / reopened decisions;
- active hypotheses;
- primary task and active Issue;
- blockers;
- next decision.

### C. Active Issue
GitHub Issue for the current primary task.

The Issue contains the working contract and evidence thread. It is not a second current-state document.

### D. Decision Log
`docs/current/DECISION_LOG.md`

Records material decisions after they are made. It is append-only history, not an alternative roadmap.

---

## 4. Task model

A primary task should produce a player-facing result, decision-quality evidence, or a necessary enabling result directly tied to the current product question.

Every primary task should state:

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

HARD_CONSTRAINTS protect accepted product identity, engine/runtime requirements, safety, explicit user decisions, or proven dependencies.

SOFT_CHOICES are implementation, UX, terminology, timing, layout, tuning and presentation choices that remain adjustable unless evidence justifies freezing them.

Do not convert a convenient implementation choice into a permanent product rule.

---

## 5. Discovery and proof loop

For unproven gameplay:

QUESTION
-> CANDIDATE DECISION
-> PAPER/UI FLOW
-> MINIMUM PLAYABLE TEST
-> REAL GODOT VERIFY
-> HUMAN PLAY
-> KEEP / REWORK / KILL

Technical PASS proves only that the implementation works as built.
Human play determines whether a core interaction is understandable and valuable.

A failed prototype is valid evidence. Do not rescue a weak interaction through scope growth or decorative production work.

---

## 6. Build loop after a product decision is accepted

For accepted requirements:

SCOPED ISSUE
-> FEATURE / PROTOTYPE BRANCH WHEN NEEDED
-> IMPLEMENT
-> FOCUSED TECHNICAL VERIFY
-> PLAYER / UX REVIEW WHEN RELEVANT
-> PR
-> MERGE IF CURRENT PRODUCT VALUE EXISTS
-> UPDATE CURRENT_STATE

Disposable prototypes do not need to merge to main.

---

## 7. Evidence scale

Use minimum sufficient evidence proportional to risk.

LOW:
- focused diff or artifact;
- one relevant verification.

MEDIUM:
- revision identity;
- direct runtime evidence;
- focused regression around affected systems.

HIGH / CORE GAMEPLAY:
- revision identity;
- real Godot runtime verification;
- direct player-facing evidence;
- relevant regressions;
- explicit product decision from human play.

Never treat an aggregate PASS line as sufficient when the important behavior cannot be reconstructed.

---

## 8. Capabilities and GPT windows

Design, engineering, AI, combat, UX, art, audio, QA, research and production remain capabilities selected per task.

FRONTLINE also permits persistent GPT chat contexts labeled WINDOW_00–WINDOW_08 under `docs/GPT_MULTI_WINDOW_SYSTEM_V1.md`.

Those window IDs are routing labels for reusable specialist conversations. They do not maintain separate current states, independent roadmaps, freeze rights or mandatory handoff chains.

Several GPT windows may work on the same primary task when useful, but all must read the same CURRENT_STATE and Active Issue.

The old permanent numbered-window operating model remains retired. Reusing numbers for the new GPT collaboration system does not restore the old authority model.

LEGACY_PERMANENT_WINDOW_SYSTEM=ABOLISHED
GPT_MULTI_WINDOW_ROUTING=YES
INDEPENDENT_WINDOW_PROJECT_STATES=NO
PERMANENT_HANDOFF_CHAIN=NO
SPECIALIST_ROADMAP_AUTHORITY=NO

---

## 9. Parallel work rule

Normally keep one primary task.

Parallel work is allowed only when it:
- does not change product direction;
- does not compete for the same decision;
- does not resume paused production implicitly;
- is clearly maintenance, investigation, tooling, evidence collection or another low-coupling support action.

If parallel work begins to affect the roadmap, it must become visible in CURRENT_STATE.

---

## 10. State transition rule

Update CURRENT_STATE only when something material changes:
- user makes a product decision;
- human play changes a hypothesis;
- a task becomes active / complete / blocked;
- a prototype becomes the current playable;
- a requirement becomes ACCEPTED, REOPENED or SUPERSEDED;
- next decision changes.

Do not update CURRENT_STATE for routine implementation noise.

When a material decision is finalized, append it to DECISION_LOG.

---

## 11. Historical governance handling

Older FRONTLINE governance, Battle01 contracts and legacy permanent-window documents remain in Git history or `archive/legacy-unused` as evidence.

Unless explicitly reaccepted by CURRENT_STATE, classify them as:
- HISTORICAL_REFERENCE;
- reusable technical evidence;
- candidate material to re-evaluate.

They must not silently override V3 charter or current product state.

---

## 12. Current operating rule

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED
PRIMARY_TASK_MUST_SERVE_CORE_DECISION=YES
NO_GAMEPLAY_SCOPE_EXPANSION_WITHOUT_PRODUCT_DECISION=YES
PLAYER_EVIDENCE_OVER_INTERNAL_COMPLETENESS=YES
GPT_MULTI_WINDOW_COLLABORATION=YES
