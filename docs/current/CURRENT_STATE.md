# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V9
INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V1.md
GPT_COLLABORATION_SYSTEM=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md
GPT_RUNTIME_PLAN=docs/GPT_WINDOW_RUNTIME_PLAN_V1.md
DECISION_HISTORY=docs/current/DECISION_LOG.md
SOURCE_OF_TRUTH=THIS_FILE

LEGACY_PERMANENT_WINDOW_SYSTEM=ABOLISHED
GPT_MULTI_WINDOW_COLLABORATION=ENABLED
GPT_WINDOW_COUNT=4
INDEPENDENT_WINDOW_PROJECT_STATES=NO
CODEX_SIMULATED_HUMAN_PLAY=INVALID_EVIDENCE
PLAYER_EXPERIENCE_GATE=AFTER_MINIMUM_PLAYABLE_READINESS

---

## CURRENT_PHASE

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED

The core command identity is still being discovered, but the project must now build enough coherent game substance before repeatedly asking for player-experience judgments.

The prior process over-weighted early readability/experience gates while the playable was too thin to support a meaningful product judgment.

---

## CURRENT_PRODUCT_QUESTION

QUESTION=
What repeated real-time decision makes FRONTLINE worth playing as a formation-level command game rather than as a conventional RTS with fewer units?

This remains the product question, but it no longer blocks all prototype construction until a paper/design answer is proven.

---

## CURRENT_PLAYABLE

### Reusable technical foundation

M2_01_RUNTIME_SHELL=KEEP_AS_TECHNICAL_TOOLBOX
REAL_GODOT_4_7_1_VERIFY=PASS

Reusable foundations include selection, movement/pathing, 2D simulation truth + 3D presentation/input, LOS/intel, deterministic combat, objective primitives and the verified runtime shell.

These are construction material, not final product rules.

### Discovery Prototype A

PROTOTYPE=DISCOVERY_PROTOTYPE_A_COMMAND_AND_RESPONSE
BRANCH=discovery/prototype-a-command-response-v1
HEAD_SHA=6deda2c8921dba55617eb7258dcdb866085cba24
TECHNICAL_RESULT=PASS
PRODUCT_RESULT=REWORK_REQUIRED
MERGE_TO_MAIN=NOT_AUTHORIZED

Direct first-use evidence was "没看懂". That evidence remains valid, but it must not be generalized into a rule that every early implementation increment requires player-experience validation.

---

## ACCEPTED_DECISIONS

ACCEPTED:
- FRONTLINE remains a modern-warfare formation/platoon-level tactical game project.
- high-APM unit micromanagement is not an assumed product goal.
- TECHNICAL_PASS != PRODUCT_PASS.
- direct human play is decisive for product acceptance when the build is sufficiently developed to justify human judgment.
- Codex/automation may perform technical verification and heuristic inspection but may not simulate or stand in for a human player.
- player-experience testing is deferred until MINIMUM_PLAYABLE_READINESS is reached.
- early development may proceed when the player-facing target and scope are clear enough to build without inventing a new product direction.
- old North/Central/South Battle01 production remains unauthorized.
- production art must not be used to hide an unclear interaction.
- one shared current state replaces permanent specialist/window states.
- the active GPT system uses four routing contexts only: 00 Project Control, 01 Design/Experience, 02 Development, 03 Review/Operations.

REOPENED / NOT PROVEN:
- incomplete information as the primary game core;
- Recon/Infantry/IFV/Armor as protected final roles;
- old Battle01 command set;
- old Battle01 map structure;
- Command & Response as the final core loop;
- formation autonomy as the final control solution.

---

## EVIDENCE_MODEL

LAYER_1_TECHNICAL_VERIFICATION=
Codex/tests/CI verify that the build runs and specified mechanics work. This is not player evidence.

LAYER_2_MINIMUM_PLAYABLE_READINESS=
The build has enough coherent game substance that asking a human to judge it is meaningful.

MINIMUM_PLAYABLE_READINESS requires, at minimum:
- a visible situation or objective;
- controllable player action;
- an opposing force or changing battlefield state;
- consequences from player action;
- readable feedback;
- a beginning, continued play loop and recognizable result/restart path.

Exact scenario length, visual style, timings, unit abstraction and presentation are soft choices.

LAYER_3_HUMAN_PRODUCT_EVIDENCE=
Only after readiness should the user judge understandability, decision quality, engagement and the intended command experience.

---

## GPT_WINDOW_RUNTIME

WINDOW_00=ACTIVE
WINDOW_01=ACTIVE_TARGET_DEFINITION
WINDOW_02=ACTIVE_MINIMUM_PLAYABLE_BUILD
WINDOW_03=STANDBY_ON_DEMAND

CURRENT_RUNTIME_REASON=
The game currently needs more coherent playable substance, not repeated simulated-player judgment. WINDOW_01 should define enough intent to guide construction; WINDOW_02 should actively build; WINDOW_03 enters for independent technical/readiness review when a real build exists.

WINDOW_00_STATE_WRITE_AUTHORITY=DEFAULT
WINDOW_01_02_03_STATE_WRITE_AUTHORITY=ONLY_IF_USER_OR_TASK_EXPLICITLY_DELEGATES
MANDATORY_WINDOW_HANDOFF_CHAIN=NO
DURABLE_RESULTS_OVER_CHAT_RECEIPTS=YES

---

## ACTIVE_HYPOTHESES

H1_COMMAND_LEVEL_PLAY=
The player should spend more attention forming, observing and revising plans than repeatedly correcting local movement.
STATUS=PLAUSIBLE_NOT_PROVEN

H2_ACTION_RESPONSE=
Player action should cause understandable opponent responses that change subsequent choices.
STATUS=PLAUSIBLE_NOT_PROVEN

H3_CURRENT_PROTOTYPE_EXPRESSION=
A single right-click maintain-pressure task is sufficient to communicate and test the above ideas.
STATUS=FAILED_REWORK_REQUIRED

H4_PROCESS_READINESS=
Meaningful player-experience judgment requires a more coherent playable than Prototype A currently provides.
STATUS=ACCEPTED_PROCESS_RULE

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=BUILD_PROTOTYPE_B_MINIMUM_COHERENT_PLAYABLE_V1
ACTIVE_ISSUE=#20
ACTIVE_ISSUE_URL=https://github.com/n3025584212-ops/RTS/issues/20

Immediate goal:
Build a small but coherent Prototype B greybox that is sufficiently game-like to justify later human experience evaluation.

WINDOW_01 must provide enough player-facing intent, information/choice/feedback guidance and non-goals for WINDOW_02 to build without inventing a new product direction.

WINDOW_02 is authorized to implement the minimum coherent playable baseline using current reusable technology. It does not need simulated human approval for every implementation increment.

This authorization does not resume Battle01 production and does not freeze temporary prototype choices as final design.

---

## BLOCKERS

CURRENT_PRODUCT_BLOCKERS:
1. The repeated formation-level decision remains unproven.
2. The current playable lacks enough coherent game substance for repeated player-experience judgments to be useful.
3. Prototype A's pressure expression remains too close to MOVE renamed.
4. Formation autonomy has not demonstrated clear player value.

CURRENT_BUILD_NEED:
- connect enough objective, controllable action, opposition/change, consequence, feedback and result flow to create a meaningful greybox playable.

TECHNICAL_BLOCKERS:
- no known technical blocker prevents building the minimum coherent playable;
- existing CI infrastructure issues remain non-product-critical.

---

## NEXT_DECISION

NEXT=MINIMUM_PLAYABLE_READY_FOR_HUMAN_TEST_OR_CONTINUE_BUILD

Required sequence:
1. WINDOW_00 keeps scope small and prevents accidental Battle01/product freeze.
2. WINDOW_01 defines only the player-facing target necessary for construction.
3. WINDOW_02 builds a coherent Prototype B greybox using existing reusable foundations.
4. Technical verification proves that the build runs and mechanics function.
5. WINDOW_03 may independently assess technical/readiness evidence.
6. If MINIMUM_PLAYABLE_READINESS is not reached, continue building rather than asking for player-experience judgment.
7. Only when readiness is reached does the user directly play and judge the experience.
8. WINDOW_00 then integrates KEEP / REWORK / KILL or the next build decision.

Do not use Codex, scripted agents or automated tests as fake human-player evidence.

ONE_PRIMARY_PRODUCT_QUESTION=YES
ONE_PRIMARY_ACTIVE_TASK=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
