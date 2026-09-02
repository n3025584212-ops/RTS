# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V10
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
PLAYER_EXPERIENCE_GATE=AFTER_REPRESENTATIVE_SLICE_READINESS
TOY_MECHANIC_DEMO_AS_PRODUCT_EVIDENCE=REJECTED
SINGLE_DECISION_REDUCTION_AS_GAME_DEFINITION=REJECTED_AS_TOO_NARROW

---

## CURRENT_PHASE

CURRENT_PHASE=P0_DISCOVER
BATTLE01_PRODUCTION=PAUSED

The core command identity is still being discovered, but discovery must now happen through a representative command-battle system rather than repeated ultra-thin mechanic demos.

A tiny scenario with a few abstract formations, one contact and one isolated choice may verify implementation, but it cannot represent an RTS battle or justify product conclusions.

---

## CURRENT_PRODUCT_QUESTION

QUESTION=
What interacting real-time command decisions and battle loop make FRONTLINE worth playing as a formation-level command game rather than as a conventional RTS with fewer units?

The earlier framing around finding exactly one repeated decision was useful diagnostically but is too narrow as a definition of the game. FRONTLINE must be evaluated as an interacting battle system.

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

Prototype A remains useful negative evidence: a thin command demonstration can technically work while still failing to resemble a worthwhile game experience.

---

## ACCEPTED_DECISIONS

ACCEPTED:
- FRONTLINE remains a modern-warfare formation/platoon-level tactical command game project.
- high-APM unit micromanagement is not an assumed product goal.
- TECHNICAL_PASS != PRODUCT_PASS.
- direct human play is decisive for product acceptance only when the build is sufficiently representative to justify human judgment.
- Codex/automation may perform technical verification and heuristic inspection but may not simulate or stand in for a human player.
- early development may proceed when the player-facing target and scope are clear enough to build without inventing a new product direction.
- FRONTLINE must not be reduced to a toy mechanism demo or an arbitrary small number of boxes/formations for product evaluation.
- representative readiness is systemic, not a fixed unit-count/map-size/minutes checklist.
- the player-facing battle must create sustained command load through interacting responsibilities, changing threats and continuing consequences.
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
- formation autonomy as the final control solution;
- the earlier assumption that one isolated repeated decision can define or sufficiently test the game.

---

## EVIDENCE_MODEL

LAYER_1_TECHNICAL_VERIFICATION=
Codex/tests/CI verify that the build runs and specified mechanics work. This is not player evidence.

LAYER_2_REPRESENTATIVE_COMMAND_BATTLE_READINESS=
The build contains enough interacting RTS/tactical-battle substance that human judgment is meaningful.

Readiness is demonstrated when the battle creates sustained command load, including:
- multiple formations/task-capable groups carrying distinct responsibilities;
- multiple sectors, axes, objectives or competing demands;
- enemy action that changes the situation over time;
- local autonomous execution so routine tactical details do not require continuous babysitting;
- reconnaissance/contact information and changing battlefield knowledge;
- committed versus uncommitted/reserve combat power whose use matters;
- maneuver, combat and support consequences that change formation/battlefield state;
- retasking, setbacks, escalation and a recognizable battle outcome/restart path;
- enough interacting events that the control model is tested under command load rather than a scripted single-choice vignette.

Exact formation count, subordinate entity count, map dimensions, scenario duration, mission fiction and command vocabulary remain soft choices.

LAYER_3_HUMAN_PRODUCT_EVIDENCE=
Only after representative readiness should the user judge command quality, workload, readability, engagement and whether the game actually feels distinct from conventional RTS micromanagement.

---

## GPT_WINDOW_RUNTIME

WINDOW_00=ACTIVE
WINDOW_01=ACTIVE_BATTLE_AND_COMMAND_DESIGN
WINDOW_02=ACTIVE_REPRESENTATIVE_SLICE_BUILD
WINDOW_03=STANDBY_ON_DEMAND

CURRENT_RUNTIME_REASON=
The project now needs a representative RTS/tactical command battle, not another ultra-thin proof. WINDOW_01 defines enough battle structure and command responsibilities to guide construction; WINDOW_02 actively builds the integrated slice; WINDOW_03 enters for independent technical/readiness review once substantive implementation exists.

WINDOW_00_STATE_WRITE_AUTHORITY=DEFAULT
WINDOW_01_02_03_STATE_WRITE_AUTHORITY=ONLY_IF_USER_OR_TASK_EXPLICITLY_DELEGATES
MANDATORY_WINDOW_HANDOFF_CHAIN=NO
DURABLE_RESULTS_OVER_CHAT_RECEIPTS=YES

---

## ACTIVE_HYPOTHESES

H1_COMMAND_LEVEL_PLAY=
The player should spend more attention assigning tasks, interpreting contacts, prioritizing sectors, committing reserves and revising plans than repeatedly correcting local movement.
STATUS=PLAUSIBLE_NOT_PROVEN

H2_ACTION_RESPONSE=
Player action should cause understandable battlefield and opponent responses that change subsequent choices.
STATUS=PLAUSIBLE_NOT_PROVEN

H3_CURRENT_PROTOTYPE_EXPRESSION=
A single right-click maintain-pressure task is sufficient to communicate and test the above ideas.
STATUS=FAILED_REWORK_REQUIRED

H4_REPRESENTATIVE_SYSTEM_NEED=
FRONTLINE can only be meaningfully judged when several command systems interact under sustained battle load rather than in an isolated mechanic demonstration.
STATUS=ACCEPTED_PROCESS_RULE

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=BUILD_PROTOTYPE_B_REPRESENTATIVE_COMMAND_BATTLE_SLICE_V1
ACTIVE_ISSUE=#20
ACTIVE_ISSUE_URL=https://github.com/n3025584212-ops/RTS/issues/20

Immediate goal:
Build a coherent greybox battle slice that behaves like an actual small RTS/tactical battle rather than a mechanism demonstration.

WINDOW_01 defines the command structure, simultaneous responsibilities, battle flow and player-facing information only to the level needed for construction.

WINDOW_02 is authorized to implement the integrated representative slice using current reusable technology, including formation tasks/autonomy, enemy reaction, multiple battlefield demands, reserve/retask flow and readable state feedback as needed.

This authorization does not resume formal Battle01 production and does not freeze temporary prototype choices as final design.

---

## BLOCKERS

CURRENT_PRODUCT_BLOCKERS:
1. FRONTLINE does not yet have a representative integrated command-battle slice.
2. The interaction among command responsibilities, formation autonomy, enemy reaction, information and reserves remains unproven under sustained battle load.
3. Prototype A remains too thin and too close to MOVE renamed to answer the product question.
4. The game must demonstrate that higher-level command reduces babysitting without making the player passive.

CURRENT_BUILD_NEED:
- connect enough battlefield sectors/demands, persistent tasks, autonomous local execution, enemy activity, combat consequences, reserve commitment, retasking and outcome flow to produce a sustained playable battle.

TECHNICAL_BLOCKERS:
- no known technical blocker prevents building the representative slice;
- existing CI infrastructure issues remain non-product-critical.

---

## NEXT_DECISION

NEXT=REPRESENTATIVE_SLICE_READY_FOR_HUMAN_PLAY_OR_CONTINUE_BUILD

Required sequence:
1. WINDOW_00 prevents regression into toy proofs or accidental formal production freeze.
2. WINDOW_01 defines a representative battle/command structure, not a one-button mechanic exercise.
3. WINDOW_02 builds the integrated command-battle slice using existing reusable foundations.
4. Technical verification proves that the integrated systems run and interact as specified.
5. WINDOW_03 may independently assess technical and representative-readiness evidence.
6. If the build still behaves like a tiny scripted mechanism demo, continue building rather than requesting a player verdict.
7. Only after representative readiness does the user directly play and judge the game.
8. WINDOW_00 integrates the result and next product/build decision.

Do not use Codex, scripted agents, a few boxes, or automated tests as substitutes for an actual representative RTS battle and later human evidence.

ONE_PRIMARY_PRODUCT_QUESTION=YES
ONE_PRIMARY_ACTIVE_TASK=YES
PERMANENT_AUTHORITY_WINDOWS=NO
GPT_ROUTING_WINDOWS=YES
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
