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

Current state:
- WINDOW_00=ACTIVE
- WINDOW_01=ACTIVE_BATTLE_AND_COMMAND_DESIGN
- WINDOW_02=ACTIVE_REPRESENTATIVE_SLICE_BUILD
- WINDOW_03=STANDBY_ON_DEMAND

Reason:
- the game must now be explored through a representative command-battle slice rather than another tiny mechanic demo;
- design work must establish enough battle structure and command responsibility to guide construction;
- development is authorized to build an integrated playable battle using reusable systems;
- review/ops enters when substantive build or repository evidence exists.

## 4. Activation triggers

### Activate WINDOW_01 when
- battle structure, command responsibilities or player-facing information need design;
- task/autonomy boundaries are unclear;
- several systems must be composed into a coherent battle loop;
- player feedback from a representative build needs interpretation.

WINDOW_01 should not reduce the game to a single isolated decision merely for analytical convenience.

### Activate WINDOW_02 when
- the current representative slice needs implementation;
- gameplay/combat/AI/runtime behavior needs technical work;
- existing reusable foundations must be integrated or revised;
- a technical defect blocks the battle slice.

WINDOW_02 is currently authorized for active implementation. It should build enough integrated battlefield substance to create sustained command load, not merely make a small scripted demo technically pass.

### Activate WINDOW_03 when
- a substantive playable needs independent verification;
- regressions/CI/PRs need review;
- representative-readiness evidence needs neutral checking;
- repository hygiene or archival work is needed;
- release/build readiness needs checking.

WINDOW_03 does not decide whether gameplay is fun or redefine product intent.

## 5. Phase defaults

### P0 DISCOVER
ACTIVE: 00, 01, 02 while building the representative command-battle slice
ON_DEMAND: 03

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
Normally goes to Active Issue as battle/command design guidance. It does not change `CURRENT_STATE` by default.

### WINDOW_02 result
Normally goes to a branch/PR plus focused runtime evidence; important limitations are recorded in the Active Issue. It does not declare PRODUCT_PASS.

### WINDOW_03 result
Normally goes to PR review, CI/test evidence or the Active Issue as independent findings. It does not rewrite product intent.

### WINDOW_00 result
Integrates accepted decisions/evidence and updates `CURRENT_STATE` / `DECISION_LOG` when material.

## 9. Evidence gates

### Gate A — Representative battle structure
WINDOW_01 and WINDOW_02 must converge on a battle that contains enough interacting responsibilities, enemy activity, autonomous local execution, reserve/retask pressure and outcome flow to resemble an actual RTS/tactical battle.

A few boxes, one contact, one objective or one scripted choice cannot satisfy this gate.

### Gate B — Technical integration
WINDOW_02 produces a real Godot runnable result and technical evidence for the integrated battle systems.
TECHNICAL_PASS does not close the product question.

### Gate C — Independent readiness evidence
WINDOW_03 checks whether the build actually satisfies representative-slice conditions and whether regressions/evidence are credible.

### Gate D — Human product gate
Only after representative readiness does the user directly judge command quality, workload, readability, engagement and whether FRONTLINE feels distinct.
WINDOW_00 integrates the result.

## 10. Conflict handling

If two windows materially disagree:
1. do not edit project state to hide the disagreement;
2. identify exactly what evidence differs;
3. WINDOW_00 presents both positions;
4. user decides or authorizes a discriminating test.

## 11. Repository/branch rules

- `main` = current stable baseline.
- discovery/representative slices may live on prototype branches and need not merge.
- accepted reusable implementation uses focused branches/PRs when appropriate.
- superseded/unused material goes to `archive/legacy-unused` when it should be retained outside main.
- no window may merge historical/archive material wholesale back into main.

## 12. Anti-bureaucracy / anti-toy rules

DO_NOT:
- require every task to visit all four windows;
- require receipt messages between windows;
- create separate state files per window;
- make 00 manually relay full outputs that already exist on GitHub;
- keep specialists busy for appearance;
- turn a temporary division of labor into a permanent product rule;
- reduce the game to an arbitrary small formation count merely to make testing easier;
- treat a single isolated decision as sufficient evidence for the whole RTS;
- request human product judgment on a toy mechanism demo.

## 13. Current next action

For the present P0 task:
1. WINDOW_00 holds the representative-battle standard and scope boundaries.
2. WINDOW_01 defines the battle/command structure needed for sustained play, not a one-button exercise.
3. WINDOW_02 actively builds the representative greybox battle using existing reusable foundations.
4. WINDOW_03 independently verifies technical/readiness evidence when the build becomes substantive.
5. If the build still behaves like a tiny scripted demo, continue building.
6. Only after representative readiness does the user directly play and judge the game.
