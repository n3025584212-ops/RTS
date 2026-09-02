# FRONTLINE GPT WINDOW RUNTIME PLAN V1

STATUS=ACTIVE_RUNTIME_PLAN
PROJECT=FRONTLINE
WINDOW_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md

## 1. Operating objective

Use the minimum number of GPT windows needed to move the current product decision forward while preserving one project truth.

DEFAULT_MODE=ONE_CONTROL_WINDOW_PLUS_ONLY_NEEDED_SPECIALISTS
ALL_WINDOWS_ALWAYS_ACTIVE=NO
MANDATORY_HANDOFF_CHAIN=NO

## 2. Window lifecycle states

Each specialist window may be:
- ACTIVE — currently doing work needed by the primary task;
- STANDBY — available, but should not create work;
- SLEEP — no reason to consult it in the current phase/task.

WINDOW_00 is normally ACTIVE whenever the project is being directed.

## 3. Current P0 configuration

CURRENT_PHASE=P0_DISCOVER

Recommended state now:
- WINDOW_00=ACTIVE
- WINDOW_01=ACTIVE
- WINDOW_02=STANDBY_FEASIBILITY_ONLY
- WINDOW_03=STANDBY_ON_DEMAND

Reason:
- the product decision is not yet accepted;
- design/experience work is the main need;
- development may inspect feasibility but must not pre-implement unaccepted gameplay;
- review/ops enters when independent evidence or repository work is needed.

## 4. Activation triggers

### Activate WINDOW_01 when
- the repeated player decision is unclear;
- interaction/UX/readability needs design;
- player feedback needs interpretation;
- visual communication affects understanding;
- a prototype concept needs alternatives or tradeoffs.

### Activate WINDOW_02 when
- feasibility must be checked;
- the user/current task authorizes implementation;
- an accepted prototype/gameplay change needs Godot work;
- gameplay/combat/AI/runtime behavior needs technical investigation;
- a technical defect blocks the current task.

During P0 before product acceptance, WINDOW_02 may inspect and recommend but must not expand gameplay implementation unless explicitly authorized.

### Activate WINDOW_03 when
- a playable needs independent verification;
- regressions/CI/PRs need review;
- human-play evidence needs a neutral protocol;
- repository hygiene or archival work is needed;
- release/build readiness needs checking.

WINDOW_03 does not decide whether gameplay is fun or redefine product intent.

## 5. Phase defaults

### P0 DISCOVER
ACTIVE: 00, 01
ON_DEMAND: 02 feasibility, 03 review/ops

### P1 PROVE
ACTIVE: 00, 01, 02
ACTIVE_WHEN_BUILD_EXISTS: 03

### P2 BUILD
ACTIVE: 00, 02
ON_DEMAND: 01 for gameplay/UX decisions; 03 for review/regression

### P3 REPRESENT
ACTIVE: 00, 01, 02
ACTIVE_REVIEW: 03

### P4 SHIP SLICE
ACTIVE: 00, 02, 03
ON_DEMAND: 01 for final player-facing polish/readability decisions

These are defaults, not permanent departments.

## 6. Work initiation

A window may start work when one of these is true:
1. the user asks that window directly;
2. `CURRENT_STATE` / Active Issue clearly contains work inside that window's role;
3. WINDOW_00 identifies a concrete need and the work does not require a new product decision.

Do not create filler work merely because a window exists.

## 7. Durable communication surfaces

Prefer durable project evidence over chat-to-chat copying.

Use:
- `CURRENT_STATE` — only integrated material state;
- Active Issue — product question, task contract and decision/evidence discussion;
- branch/PR — implementation and reviewable code changes;
- tests/CI/runtime evidence — technical verification;
- `DECISION_LOG` — finalized material decisions.

Chats are working contexts, not storage authorities.

## 8. Result routing

### WINDOW_01 result
Normally goes to Active Issue as a recommendation/design decision package.
It does not change `CURRENT_STATE` by default.

### WINDOW_02 result
Normally goes to a branch/PR plus focused runtime evidence; important limitations are recorded in the Active Issue.
It does not declare PRODUCT_PASS.

### WINDOW_03 result
Normally goes to PR review, CI/test evidence or the Active Issue as independent findings.
It does not rewrite product intent.

### WINDOW_00 result
Integrates accepted decisions/evidence and updates `CURRENT_STATE` / `DECISION_LOG` when material.

## 9. Decision gates

### Gate A — Product decision before coding
For unproven core gameplay:
WINDOW_01 proposes -> user KEEP/REWORK/KILL -> only KEEP authorizes WINDOW_02 implementation.

### Gate B — Technical gate
WINDOW_02 produces a real Godot runnable result and technical evidence.
TECHNICAL_PASS does not close the product question.

### Gate C — Independent evidence
WINDOW_03 checks build/regression/evidence quality when warranted.

### Gate D — Human product gate
User/direct human play determines whether the core interaction survives.
WINDOW_00 integrates KEEP/REWORK/KILL into project state.

## 10. Conflict handling

If two windows materially disagree:
1. do not edit project state to hide the disagreement;
2. identify exactly what evidence differs;
3. WINDOW_00 presents both positions;
4. user decides or authorizes a discriminating test.

## 11. Repository/branch rules

- `main` = current stable baseline.
- disposable prototypes may live on prototype branches and need not merge.
- accepted reusable implementation uses focused branches/PRs when appropriate.
- superseded/unused material goes to `archive/legacy-unused` when it should be retained outside main.
- no window may merge historical/archive material wholesale back into main.

## 12. Anti-bureaucracy rules

DO_NOT:
- require every task to visit all four windows;
- require receipt messages between windows;
- create separate state files per window;
- make 00 manually relay full outputs that already exist on GitHub;
- keep specialists busy for appearance;
- turn a temporary division of labor into a permanent product rule.

## 13. Current next action

For the present P0 task:
1. WINDOW_00 maintains the decision frame.
2. WINDOW_01 defines Prototype B's one repeated player decision and first-use interaction.
3. User decides KEEP / REWORK / KILL.
4. WINDOW_02 remains non-implementing until KEEP, except narrow feasibility checks.
5. After a runnable Prototype B exists, WINDOW_03 independently verifies it.
6. User plays it; WINDOW_00 integrates the result.
