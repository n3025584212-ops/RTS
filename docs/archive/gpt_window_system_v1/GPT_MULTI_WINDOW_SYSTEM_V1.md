# FRONTLINE GPT MULTI-WINDOW SYSTEM V1

STATUS=ACTIVE_COLLABORATION_SYSTEM
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_PROJECT_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md

## 1. Purpose

FRONTLINE may use multiple GPT chat windows in parallel so different kinds of reasoning and execution do not compete for one conversation context.

These windows are **collaboration roles**, not independent project authorities.

The system deliberately combines:
- multiple focused GPT contexts;
- one GitHub repository;
- one `CURRENT_STATE`;
- one current product question;
- normally one primary active task.

## 2. Non-negotiable shared truth

Every window uses the same authority order:

1. USER_EXPLICIT_DECISION
2. `docs/current/CURRENT_STATE.md`
3. accepted current decisions / `DECISION_LOG.md`
4. current Active Issue
5. current implementation, playtest and QA evidence
6. historical material

No window may maintain a competing project state, private frozen roadmap, or discipline-specific source of truth.

## 3. Window model

Window numbers are stable **routing labels** only.

They help the user reopen a dedicated GPT chat for a recurring capability without turning that chat into a separate project.

ACTIVE_WINDOWS:
- WINDOW_00 = Project Director / Integration
- WINDOW_01 = Game Design / Product Discovery
- WINDOW_02 = Technical Architecture / Godot
- WINDOW_03 = Gameplay / Combat / Units
- WINDOW_04 = Enemy AI / Simulation / Autonomy
- WINDOW_05 = UX / UI / Interaction Readability
- WINDOW_06 = Playtest / QA / Evidence
- WINDOW_07 = Visual / Audio / Presentation
- WINDOW_08 = Repository / Production Operations

Window prompts live in `docs/gpt_windows/`.

## 4. Common initialization

Every new GPT window must begin by reading from GitHub `main`:

1. `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
2. `docs/FRONTLINE_PROJECT_SYSTEM_V1.md`
3. `docs/GPT_MULTI_WINDOW_SYSTEM_V1.md`
4. `docs/current/CURRENT_STATE.md`
5. the Active Issue referenced by `CURRENT_STATE.md`
6. only the code, PRs, evidence or historical material directly needed by the task

Do not ask the user to restate project background that is available in these sources.

## 5. Shared operating rules

All windows must:
- stay aligned to the current phase and product question;
- distinguish hard constraints from soft choices;
- distinguish TECHNICAL_PASS from PRODUCT_PASS;
- prefer current evidence over historical labels;
- avoid resurrecting Battle01 production unless authorized by current state or user decision;
- avoid creating new governance files merely to acknowledge another file;
- use the Active Issue as the working contract/evidence thread when one exists;
- surface conflicts rather than silently resolving them in favor of their specialty.

## 6. State-write authority

`CURRENT_STATE.md` is not edited casually.

Default rule:
- WINDOW_00 integrates material state changes;
- other windows produce evidence, recommendations, implementation or review results;
- another window may edit `CURRENT_STATE.md` only when the user explicitly directs it to do so or the current task explicitly delegates that integration action.

The user remains final product authority.

## 7. Parallel work

Multiple GPT windows may work at the same time when their work is low-conflict.

Good parallel examples:
- WINDOW_01 compares Prototype B decision candidates while WINDOW_02 checks technical feasibility;
- WINDOW_05 tests interaction readability while WINDOW_06 prepares a human-play protocol;
- WINDOW_08 cleans repository structure without changing gameplay direction.

Bad parallel examples:
- two windows independently choosing different core loops;
- gameplay implementation beginning while the core decision is still awaiting user acceptance;
- visual production attempting to settle an unresolved gameplay question.

If two windows reach conflicting recommendations, WINDOW_00 presents the conflict to the user rather than averaging it away.

## 8. Task routing

Use the smallest set of windows that materially improves the result.

A task does not need to visit every window.

Typical flow during discovery:

WINDOW_00 / user frames the decision
-> WINDOW_01 designs candidate interaction
-> WINDOW_02 checks minimum technical feasibility
-> WINDOW_05 checks first-use readability
-> WINDOW_03 or WINDOW_04 implements only after authorization
-> WINDOW_06 gathers technical + human-play evidence
-> WINDOW_00 integrates KEEP / REWORK / KILL

This is a common path, not a mandatory handoff chain.

## 9. Communication format

Windows should return concise, decision-useful outputs. A useful default is:

WINDOW=
TASK_ID=
RESULT_OR_FINDING=
EVIDENCE=
RISKS_OR_CONFLICTS=
RECOMMENDED_NEXT_ACTION=
STATE_CHANGE_REQUIRED=YES/NO

This format is optional when prose, code, figures or direct implementation evidence is more useful.

## 10. Hard and soft boundaries

HARD:
- one current state;
- user product authority;
- current phase and paused/active production status;
- engine/runtime requirements;
- accepted product decisions;
- explicit task non-goals;
- direct human-play requirement for core gameplay acceptance.

SOFT:
- exact window boundaries;
- which window performs an overlapping capability;
- response format;
- exact terminology;
- internal sequencing when there is no authority conflict.

Windows may overlap when useful. They should not become rigid departments.

## 11. Archive rule

Historical, superseded and unused project material lives on:

`archive/legacy-unused`

Windows may consult that branch for recovery or evidence, but it has no current authority unless `main:docs/current/CURRENT_STATE.md` explicitly reaccepts something from it.

## 12. Current project condition

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED
CURRENT_PRIMARY_TASK=DEFINE_PROTOTYPE_B_CORE_PLAYER_DECISION_V1
ACTIVE_ISSUE=#20

GPT_MULTI_WINDOW_COLLABORATION=YES
INDEPENDENT_WINDOW_PROJECT_STATES=NO
PERMANENT_HANDOFF_CHAIN=NO
USER_PRODUCT_AUTHORITY=YES
