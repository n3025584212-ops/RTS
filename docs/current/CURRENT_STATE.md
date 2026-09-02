# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V5
INTEGRATION_AUTHORITY=PROJECT_DIRECTOR
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
SOURCE_OF_TRUTH=THIS_FILE

NUMBERED_WINDOW_SYSTEM=ABOLISHED
LEGACY_WINDOW_REFERENCES=HISTORICAL_METADATA_ONLY

---

## CURRENT_PHASE

CURRENT_PHASE=P0_DISCOVER

The previous fixed numbered-window operating model has been retired. FRONTLINE now uses one unified project state and task-based capabilities.

The project remains in core-game discovery because the repeated player decision and command experience are not yet proven.

Battle01 production remains paused.

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

Technical evidence:
- Godot 4.7.1 parse/boot PASS;
- BLUE=3 / RED=3;
- persistent pressure task executes;
- local autonomous execution exists;
- visible boundary exists;
- RED response is state-driven;
- task revision and restart work;
- no runtime errors reported.

Direct first-use product evidence:
- the player could launch the prototype;
- the player response was "没看懂";
- the battlefield presentation did not make the intended command-and-response loop self-evident;
- the current interaction appears too close to select -> right-click location -> pressure, so the core command hypothesis is not proven.

This is useful negative evidence, not a gameplay PASS.

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

REOPENED / NOT PROVEN:
- incomplete information as the primary game core;
- Recon/Infantry/IFV/Armor as protected final roles;
- old Battle01 command set;
- old Battle01 map structure;
- Command & Response as the final core loop;
- formation autonomy as the final control solution.

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
STATUS=FAILED / REWORK_REQUIRED

---

## CURRENT_TASK

ACTIVE_PRIMARY_TASK=REDESIGN_DISCOVERY_TEST

The unified production-system migration is complete.
The current product task is to redesign the discovery test itself before writing more gameplay code.

No additional gameplay implementation is authorized until one concrete player decision is stated clearly enough that a first-time player can understand what decision the prototype is asking them to make.

---

## BLOCKERS

PRODUCT_BLOCKERS:
1. The core repeated player decision is not proven.
2. Prototype A is not self-explanatory to a first-time player.
3. The current pressure interaction may be MOVE renamed rather than a distinct command decision.
4. Formation autonomy has not yet demonstrated clear player value.
5. Battle01 design cannot be responsibly rebuilt until the core interaction is clearer.

TECHNICAL_BLOCKERS:
- no known technical blocker prevents further isolated prototyping;
- existing CI infrastructure failure mode remains non-product-critical;
- pre-existing local generated files remain a hygiene issue, not a gameplay authority.

---

## NEXT_DECISION

NEXT=DEFINE_ONE_CLEAR_PLAYER_DECISION_FOR_PROTOTYPE_B

Required sequence:

1. State one concrete player decision the prototype must make understandable without explanation.
2. Design the smallest interaction that exposes that decision.
3. Check the paper/UI flow before coding.
4. Build one disposable prototype iteration.
5. Put it in front of the user immediately.
6. Decide KEEP / REWORK / KILL from direct play.

Do not resume Battle01, formal art production, broad AI work or repository-wide system completion until a core interaction survives this loop.

ONE_PRIMARY_PRODUCT_QUESTION=YES
NUMBERED_WINDOWS=NO
BATTLE01_PRODUCTION=PAUSED
CODEX_ROADMAP_AUTHORITY=NO
