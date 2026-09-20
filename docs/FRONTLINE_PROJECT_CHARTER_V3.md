# FRONTLINE PROJECT CHARTER V3

STATUS=ACTIVE_PROJECT_CHARTER
PROJECT=FRONTLINE
FINAL_PRODUCT_AUTHORITY=USER_PRODUCT_OWNER
PROJECT_INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
ENGINE_BASELINE=GODOT_4_7_1

SUPERSEDES=
- FRONTLINE_PROJECT_CHARTER_V2 (superseded; not retained in this repository)
- fixed FRONTLINE numbered-window authority model
- the GPT four-window routing layer (retired 2026-09-20; see docs/FRONTLINE_EXECUTION_MODEL_V1.md)

LEGACY_PERMANENT_NUMBERED_WINDOW_SYSTEM=ABOLISHED
GPT_WINDOW_ROUTING_LAYER=RETIRED
ROUTING_BY_WINDOW_NUMBER=NO

---

## 1. Purpose

FRONTLINE uses one unified production system. The project is organized around the current product question and current playable, not around independent specialist silos.

The system exists to answer one thing efficiently: what should be built next to make the game better, and what evidence is sufficient to decide whether it worked.

---

## 2. Authority

When information conflicts, use this order:

1. USER_EXPLICIT_DECISION
2. CURRENT_STATE
3. CURRENT_ACCEPTED_PRODUCT_DECISIONS
4. CURRENT_TASK_CONTRACT
5. IMPLEMENTATION / ART / QA EVIDENCE
6. HISTORICAL_DOCUMENTS

The user owns major product direction.
The Project Director integrates design, playtest, engineering, art and QA evidence into CURRENT_STATE.
No specialist, test, implementation agent, GPT window, old window, old contract or historical PASS can independently redefine project truth.

---

## 3. No windows at all: one execution unit, one state

FRONTLINE has no numbered work windows — neither permanent authority windows nor routing labels.
The window layer was retired on 2026-09-20. It existed to move work between human-driven chat
conversations; the execution unit is now a single agent that reads and writes this repository, runs
the engine and spawns isolated sub-agents for review. See `docs/FRONTLINE_EXECUTION_MODEL_V1.md`.

There is no handoff chain, no window-to-window receipt protocol, no independent current state per
discipline, and no routing by window number.

Design, engineering, art, audio, AI, UX and QA are CAPABILITIES used when a task needs them. They
are not separate project authorities, and they are not windows.

Historical WINDOW references in older documents, audits and branch names remain historical. Those
numbers carry no authority and must not be revived.

One task is active at a time, chosen in `docs/current/CURRENT_STATE.md`. Capabilities may be
combined when that produces a better playable result, but the smallest set that does the job wins.

---

## 4. Single project state

The project maintains one living state:

`docs/current/CURRENT_STATE.md`

It should answer only the information needed to continue work:
- CURRENT_PHASE
- CURRENT_PRODUCT_QUESTION
- CURRENT_PLAYABLE
- ACCEPTED_DECISIONS
- ACTIVE_HYPOTHESES
- ACTIVE_TASK
- BLOCKERS
- NEXT_DECISION

Do not create competing current-state documents for specialties or GPT windows.

---

## 5. Production phases

FRONTLINE uses five phases. These are project phases, not departments.

### P0 DISCOVER
Find the repeated player decision and game identity. Research, paper exercises and disposable prototypes are allowed. Production scope is not protected here.

### P1 PROVE
Build the smallest playable that can prove or falsify the core loop through direct human play. Failure is a valid result.

### P2 BUILD
Once the core interaction is accepted, build the first coherent connected playable around it. Reuse existing code only when it serves the accepted game.

### P3 REPRESENT
Create representative art, UI, audio and presentation for normal gameplay. Visual quality must serve the proven interaction rather than define it accidentally.

### P4 SHIP SLICE
Integrate gameplay, AI, content, presentation, performance, stability and a real player build into the Battle01 vertical slice benchmark.

A phase may move backward when direct play evidence invalidates a core assumption.

---

## 6. Work model

At any time there should normally be one PRIMARY ACTIVE TASK.

Independent maintenance may occur in parallel only when it does not change product direction or distract from the primary task.

Every gameplay/product task must contain:
TASK_ID
CURRENT_PHASE
PRODUCT_QUESTION
PLAYER_FACING_CHANGE
HYPOTHESIS_OR_ACCEPTED_REQUIREMENT
AUTHORIZED_SCOPE
NON_GOALS
COMPLETION_EVIDENCE
DECISION_AFTER_EVIDENCE

Tasks should be large enough to produce a meaningful player-facing result and small enough to evaluate directly.
Avoid long chains of micro-tasks whose only result is internal system completeness.

---

## 7. Product discovery loop

QUESTION
-> HYPOTHESIS
-> MINIMUM PLAYABLE TEST
-> HUMAN_PLAY
-> KEEP / REWORK / KILL

Do not promote a hypothesis because it sounds plausible, resembles doctrine, has a document, or passed automated tests.
Do not add production art or system complexity to rescue an unclear prototype before the interaction itself is understood.

---

## 8. Accepted vs experimental decisions

Every important product statement is one of:
HYPOTHESIS
ACCEPTED
REOPENED
SUPERSEDED
HISTORICAL_REFERENCE

Only ACCEPTED decisions constrain downstream product work.
A design can be reopened whenever direct play contradicts it or the user changes direction.

Hard constraints and soft choices must be distinguished. Hard constraints protect product identity, safety, engine/runtime requirements or already-proven dependencies. Soft choices such as exact UI form, terminology, timings and layout remain adjustable until evidence justifies freezing them.

---

## 9. Engineering role

Codex and other coding agents are scoped construction executors.

They may:
- implement the authorized task;
- make local engineering decisions required for that task;
- run focused technical verification;
- report limitations and risks.

They may not:
- choose the roadmap;
- turn code gaps into product requirements;
- expand scope to make the repository feel complete;
- declare gameplay, fun or product direction proven.

Normal engineering flow:
SCOPED_TASK
-> FEATURE_OR_PROTOTYPE_BRANCH
-> REAL_GODOT_VERIFY
-> PLAY_OR_REVIEW_WHEN_RELEVANT
-> PR
-> MERGE_IF_RESULT_HAS_CURRENT_PRODUCT_VALUE

Disposable discovery prototypes do not have to merge into main merely because they work technically.

---

## 10. Human play and QA

Technical verification and product validation are separate.

TECHNICAL_VERIFICATION asks whether the implementation parses, boots, runs and behaves mechanically as specified.
PRODUCT_VALIDATION asks whether the player understands it, makes meaningful decisions, wants to continue playing, and experiences the intended causal loop.

TECHNICAL_PASS != PRODUCT_PASS

For core gameplay discovery, direct human play is the decisive evidence.
QA protects known behavior. QA does not invent product intent.

---

## 11. Visual and UX work

Visual work enters at the level needed by the current product question.
During discovery/proof, use the minimum presentation needed for the player to understand and judge the interaction.
If a player cannot understand a greybox because the interaction is not communicated, that is a product/UX finding. Do not hide it by adding decorative production art.
Once gameplay is proven, representative art direction can be developed against real normal-play scenes.
Historical visual targets are references until explicitly reaccepted.

---

## 12. Documentation

Prefer living documents over receipt chains.

Active authority should normally fit in:
- `docs/FRONTLINE_PROJECT_CHARTER_V3.md`
- `docs/current/CURRENT_STATE.md`
- active GitHub issue/PR for the current task

`docs/FRONTLINE_EXECUTION_MODEL_V1.md` defines how work is executed and reviewed. It states
permanent rules only and never declares current state.

Older contracts, audits and superseded window systems remain available through Git history or `archive/legacy-unused` but are historical unless CURRENT_STATE explicitly reaccepts them.
Do not create documents solely to acknowledge other documents.

---

## 13. Git and repository hygiene

`main` represents the current stable project baseline, not the entire history of every experiment.
Keep prototype branches when they contain useful experimental evidence. Merge them only if the code has reusable current product value.
Do not delete uncertain historical assets/source simply because the operating system changed. Classification remains KEEP / REWORK / REMOVE / HOLD based on current value and dependencies.
Clearly superseded/unused historical material may be stored on `archive/legacy-unused` to keep `main` focused.

---

## 14. Current recovery rule

The abolition of the old permanent numbered-window system does not automatically invalidate every result created under it.

Each existing result is judged by current value:
- proven reusable technical foundation -> KEEP
- unproven design assumption -> REOPEN / REWORK
- obsolete operating procedure -> HISTORICAL
- unknown dependency/value -> HOLD

This prevents both blind preservation and destructive reset.

---

## 15. Highest rule

FRONTLINE is built through a sequence of playable product decisions, not through departmental completion.

PLAYER_EVIDENCE_OVER_INTERNAL_COMPLETENESS=YES
ONE_CURRENT_STATE=YES
ONE_PRIMARY_PRODUCT_QUESTION=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
GPT_WINDOW_COUNT=4
SPECIALISTS_AS_CAPABILITIES_NOT_AUTHORITIES=YES
CODEX_ROADMAP_AUTHORITY=NO
