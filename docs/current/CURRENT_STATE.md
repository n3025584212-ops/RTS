# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V8
INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
GPT_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md
DECISION_HISTORY=docs/current/DECISION_LOG.md
SOURCE_OF_TRUTH=THIS_FILE

LEGACY_PERMANENT_WINDOW_SYSTEM=ABOLISHED
GPT_MULTI_WINDOW_COLLABORATION=ENABLED
GPT_WINDOW_IDS_ARE_ROUTING_LABELS=YES
INDEPENDENT_WINDOW_PROJECT_STATES=NO
GPT_WINDOW_COUNT=4

---

## CURRENT_PHASE

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED

The repeated player decision and command experience are not yet proven. The project remains in core-game discovery.

---

## CURRENT_PRODUCT_QUESTION

QUESTION=
What repeated real-time decision makes FRONTLINE worth playing as a formation-level command game rather than as a conventional RTS with fewer units?

The game must be discovered and proven through direct play before Battle01 production resumes.

---

## CURRENT_PLAYABLE

### Reusable production foundation

M2_01_RUNTIME_SHELL=KEEP_AS_TECHNICAL_TOOLBOX
REAL_GODOT_4_7_1_VERIFY=PASS

Reusable foundations include selection, movement/pathing, 2D simulation truth + 3D presentation/input, LOS/intel, deterministic combat, objective primitives and the verified M2-01 runtime shell.

These components do not define the future game merely because they already exist.

### Discovery Prototype A

PROTOTYPE=DISCOVERY_PROTOTYPE_A_COMMAND_AND_RESPONSE
BRANCH=discovery/prototype-a-command-response-v1
HEAD_SHA=6deda2c8921dba55617eb7258dcdb866085cba24
TECHNICAL_RESULT=PASS
PRODUCT_RESULT=REWORK_REQUIRED
MERGE_TO_MAIN=NOT_AUTHORIZED

Direct first-use evidence: player response was "没看懂". The current interaction appears too close to select -> right-click location -> pressure, so the core command hypothesis is not proven.

---

## ACCEPTED_DECISIONS

ACCEPTED:
- FRONTLINE remains a modern-warfare formation/platoon-level tactical game project.
- high-APM unit micromanagement is not an assumed product goal.
- technical PASS and product PASS are separate.
- direct human play outranks automated evidence for core gameplay acceptance.
- Codex is a scoped construction executor, not roadmap/product authority.
- old North/Central/South Battle01 construction is not authorized.
- production art must not be used to hide an unclear core interaction.
- one shared current state replaces permanent specialist/window states.
- FRONTLINE_PROJECT_SYSTEM_V1 is the active day-to-day operating system under the V3 charter.
- GPT multi-window collaboration uses four routing contexts only: 00 Project Control, 01 Design/Experience, 02 Development, 03 Review/Operations.
- the four GPT windows share this single state and do not own independent roadmaps, freeze rights or mandatory handoff chains.

REOPENED / NOT PROVEN:
- incomplete information as the primary game core;
- Recon/Infantry/IFV/Armor as protected final roles;
- old Battle01 command set;
- old Battle01 map structure;
- Command & Response as the final core loop;
- formation autonomy as the final control solution.

---

## GPT_WINDOW_RUNTIME

WINDOW_00=ACTIVE
WINDOW_01=ACTIVE
WINDOW_02=STANDBY_FEASIBILITY_ONLY
WINDOW_03=STANDBY_ON_DEMAND

CURRENT_RUNTIME_REASON=
P0 discovery currently needs product/experience work first. Development may inspect feasibility but must not pre-implement unaccepted core gameplay. Independent review/ops enters when a runnable result, evidence review or repository task exists.

WINDOW_00_STATE_WRITE_AUTHORITY=DEFAULT
WINDOW_01_02_03_STATE_WRITE_AUTHORITY=ONLY_IF_USER_OR_TASK_EXPLICITLY_DELEGATES
MANDATORY_WINDOW_HANDOFF_CHAIN=NO
DURABLE_RESULTS_OVER_CHAT_RECEIPTS=YES

---

## ACTIVE_HYPOTHESES

H1_COMMAND_LEVEL_PLAY=
The player should spend more attention forming, observing and revising plans than repeatedly correcting local movement.
STATUS=STILL_PLAUSIBLE_NOT_PROVEN

H2_ACTION_RESPONSE=
Player action should cause understandable opponent responses that change subsequent choices.
STATUS=STILL_PLAUSIBLE_NOT_PROVEN

H3_CURRENT_PROTOTYPE_EXPRESSION=
A single right-click maintain-pressure task is sufficient to communicate and test the above ideas.
STATUS=FAILED_REWORK_REQUIRED

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=DEFINE_PROTOTYPE_B_CORE_PLAYER_DECISION_V1
ACTIVE_ISSUE=#20
ACTIVE_ISSUE_URL=https://github.com/n3025584212-ops/RTS/issues/20

The current product task is to define one concrete repeated player decision for Prototype B before writing more gameplay code.

No additional core gameplay implementation is authorized until the decision is stated clearly enough that a first-time player can understand what decision the prototype is asking them to make and the user accepts it for implementation.

---

## BLOCKERS

PRODUCT_BLOCKERS:
1. The core repeated player decision is not proven.
2. Prototype A is not self-explanatory to a first-time player.
3. The current pressure interaction may be MOVE renamed rather than a distinct command decision.
4. Formation autonomy has not yet demonstrated clear player value.
5. Battle01 design cannot be responsibly rebuilt until the core interaction is clearer.

TECHNICAL_BLOCKERS:
- no known technical blocker prevents isolated prototyping;
- existing CI infrastructure failure mode remains non-product-critical.

---

## NEXT_DECISION

NEXT=ACCEPT_REWORK_OR_KILL_PROTOTYPE_B_CORE_DECISION

Required sequence:
1. WINDOW_00 maintains the decision frame.
2. WINDOW_01 states one concrete repeated player decision, information, alternatives, tradeoff, immediate feedback, recurrence and minimum first-use flow.
3. User decides KEEP / REWORK / KILL before implementation.
4. If KEEP, WINDOW_02 implements one disposable Prototype B and produces real Godot technical evidence.
5. WINDOW_03 independently checks the runnable result/evidence when warranted.
6. User directly plays the prototype.
7. WINDOW_00 integrates the product result and updates state.

Do not resume Battle01, formal art production, broad AI work or repository-wide system completion until a core interaction survives this loop.

ONE_PRIMARY_PRODUCT_QUESTION=YES
ONE_PRIMARY_ACTIVE_TASK=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
