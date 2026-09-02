# FRONTLINE GPT WINDOW RUNTIME PLAN V1

STATUS=ACTIVE_RUNTIME_PLAN
PROJECT=FRONTLINE
WINDOW_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md

## 1. Operating objective

Use the minimum number of GPT windows needed to move the current product forward while preserving one project truth.

DEFAULT_MODE=ONE_CONTROL_WINDOW_PLUS_ONLY_NEEDED_SPECIALISTS
ALL_WINDOWS_ALWAYS_ACTIVE=NO
MANDATORY_HANDOFF_CHAIN=NO
CODEX_SIMULATED_HUMAN_PLAY=NOT_VALID_EVIDENCE

## 2. Window lifecycle states

Each specialist window may be:
- ACTIVE — currently doing work needed by the primary task;
- STANDBY — available, but should not create work;
- SLEEP — no reason to consult it in the current phase/task.

WINDOW_00 is normally ACTIVE whenever the project is being directed.

## 3. Evidence layers

FRONTLINE separates three different questions.

### Layer 1 — Technical verification

Performed by development/QA tools and agents.

Checks things such as:
- parse/import/boot;
- commands execute;
- combat/AI/state changes behave as intended;
- no blocking runtime errors;
- focused regressions.

This is not player experience evidence.

### Layer 2 — Minimum playable readiness

Before asking the user to judge experience, the build must contain enough coherent game substance to justify human play.

A build is ready for meaningful human play when it has, at minimum:
- a visible situation/objective;
- controllable player action;
- an opposing force or changing battlefield state;
- consequences from player action;
- readable feedback;
- a beginning, continued play loop and recognizable result/restart path.

Exact content, timings, art level and scenario length are soft choices.

Codex/automation may inspect whether these pieces exist and function, but may not pretend to be a human player or declare the game understandable/fun.

### Layer 3 — Human product evidence

Only after minimum playable readiness is reached should the user be asked to judge:
- whether the interaction is understandable;
- whether decisions feel meaningful;
- whether the player wants to continue;
- whether the intended command experience exists.

Direct human play remains decisive for product acceptance, but it is not a gate to every small implementation step.

## 4. Current P0 configuration

CURRENT_PHASE=P0_DISCOVER

Recommended state now:
- WINDOW_00=ACTIVE
- WINDOW_01=ACTIVE_TARGET_DEFINITION
- WINDOW_02=ACTIVE_MINIMUM_PLAYABLE_BUILD
- WINDOW_03=STANDBY_ON_DEMAND

Reason:
- the project has enough reusable technical foundation to build a coherent greybox baseline;
- the previous process overused experience/readability gates before enough game existed to judge;
- WINDOW_01 should define player-facing intent while WINDOW_02 builds the minimum coherent playable needed to expose it;
- WINDOW_03 enters for independent technical/repository review when a real build exists.

## 5. Activation triggers

### Activate WINDOW_01 when
- the repeated player decision is unclear;
- interaction/UX/readability needs design;
- player feedback needs interpretation;
- visual communication affects understanding;
- a prototype concept needs alternatives or tradeoffs.

WINDOW_01 should not demand human-play conclusions from a build that has not reached minimum playable readiness.

### Activate WINDOW_02 when
- a minimum coherent playable needs to be built;
- feasibility must be checked;
- the user/current task authorizes implementation;
- gameplay/combat/AI/runtime behavior needs technical investigation;
- a technical defect blocks the current task.

During P0, WINDOW_02 may implement the authorized minimum playable baseline and disposable prototypes. It must not silently convert temporary prototype choices into final product rules or resume Battle01 production.

### Activate WINDOW_03 when
- a playable needs independent technical verification;
- regressions/CI/PRs need review;
- minimum playable readiness needs evidence checking;
- repository hygiene or archival work is needed;
- release/build readiness needs checking.

WINDOW_03 does not simulate a human player and does not decide whether gameplay is fun.

## 6. Phase defaults

### P0 DISCOVER
ACTIVE: 00, 01, 02 when building the current prototype
ON_DEMAND: 03 review/ops

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

## 7. Work initiation

A window may start work when one of these is true:
1. the user asks that window directly;
2. `CURRENT_STATE` / Active Issue clearly contains work inside that window's role;
3. WINDOW_00 identifies a concrete need and the work does not require inventing a new product direction.

Do not create filler work merely because a window exists.

## 8. Durable communication surfaces

Prefer durable project evidence over chat-to-chat copying.

Use:
- `CURRENT_STATE` — only integrated material state;
- Active Issue — product question, task contract and decision/evidence discussion;
- branch/PR — implementation and reviewable code changes;
- tests/CI/runtime evidence — technical verification;
- `DECISION_LOG` — finalized material decisions.

Chats are working contexts, not storage authorities.

## 9. Result routing

### WINDOW_01 result
Normally goes to Active Issue as player-facing target/design guidance.
It does not change `CURRENT_STATE` by default.

### WINDOW_02 result
Normally goes to a branch/PR plus focused runtime evidence.
It may build the current minimum playable without claiming PRODUCT_PASS.

### WINDOW_03 result
Normally goes to PR review, CI/test evidence or the Active Issue as independent technical/readiness findings.
It does not rewrite product intent.

### WINDOW_00 result
Integrates accepted decisions/evidence and updates `CURRENT_STATE` / `DECISION_LOG` when material.

## 10. Decision gates

### Gate A — Implementation target
WINDOW_01/00 define enough player-facing intent and scope that WINDOW_02 can build without inventing the product direction.

This gate does not require simulated human feedback and does not require the prototype to be self-explanatory before it exists.

### Gate B — Technical gate
WINDOW_02 produces a real Godot runnable result and technical evidence.

### Gate C — Minimum playable readiness
The build contains enough coherent gameplay substance to justify asking a human to evaluate it.
WINDOW_03 may independently check this evidence when useful.

### Gate D — Human product gate
The user directly plays the sufficiently developed prototype.
Only then are understandability, decision quality and player experience judged.
WINDOW_00 integrates KEEP / REWORK / KILL into project state.

## 11. Conflict handling

If two windows materially disagree:
1. do not edit project state to hide the disagreement;
2. identify exactly what evidence differs;
3. WINDOW_00 presents both positions;
4. user decides or authorizes a discriminating test.

## 12. Repository/branch rules

- `main` = current stable baseline.
- disposable prototypes may live on prototype branches and need not merge.
- accepted reusable implementation uses focused branches/PRs when appropriate.
- superseded/unused material goes to `archive/legacy-unused` when it should be retained outside main.
- no window may merge historical/archive material wholesale back into main.

## 13. Anti-bureaucracy rules

DO_NOT:
- require every task to visit all four windows;
- require receipt messages between windows;
- create separate state files per window;
- make 00 manually relay full outputs that already exist on GitHub;
- keep specialists busy for appearance;
- ask for human-play judgments before minimum playable readiness;
- use Codex/automation as fake human-play evidence;
- turn a temporary division of labor into a permanent product rule.

## 14. Current next action

For the present P0 task:
1. WINDOW_00 maintains a minimal product target and prevents scope drift.
2. WINDOW_01 defines enough of Prototype B's player-facing decision/feedback to guide implementation, without demanding player-experience proof first.
3. WINDOW_02 actively builds the minimum coherent playable Prototype B baseline from current reusable technology.
4. WINDOW_03 independently checks technical/readiness evidence when a real build exists.
5. Only after minimum playable readiness does the user directly play it.
6. WINDOW_00 then integrates the real product result.
