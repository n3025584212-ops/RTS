# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V4
INTEGRATION_AUTHORITY=WINDOW_00_GAME_DIRECTOR_PRODUCER
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V2.md

This file records the accepted current project state. Historical contracts, tests, implementation notes and prior frozen design assumptions do not override it unless explicitly re-accepted here or by the user.

---

## CURRENT_PHASE

CURRENT_PHASE=GAME_DISCOVERY_RESET
M0_PROJECT_RECOVERY=CLOSED
M1_GAME_DEFINITION=REOPENED
M2_CONNECTED_PLAYABLE=PAUSED
M3_REPRESENTATIVE_VISUAL_SLICE=NOT_STARTED
M4_PLAYER_BUILD=NOT_STARTED
M5_BATTLE01_VERTICAL_SLICE=NOT_STARTED

Reason for reset:
- M2-01 proved the new runtime shell can function technically;
- subsequent design review concluded the accepted Battle01 gameplay design itself is not yet proven;
- continuing terrain/AI/visual implementation would risk building more production on an unproven game core.

M2 is paused, not discarded. Work resumes only after a core gameplay prototype produces convincing direct play evidence.

---

## CURRENT_PLAYABLE

STATUS=M2_RUNTIME_SHELL_VERIFIED_BUT_PRODUCT_CORE_UNPROVEN
PRODUCT_VERTICAL_SLICE_STATUS=NOT_ACCEPTED
M2_CONNECTED_PLAYABLE_STATUS=PAUSED_AFTER_M2_01

M2_01_RUNTIME_SHELL=COMPLETE
M2_01_RUNTIME_SHELL_PRODUCT_VALUE=REUSABLE_TECHNICAL_FOUNDATION

The verified Battle01 runtime shell currently provides:
- BLUE Recon x1, Infantry x2, IFV x1, Armor x1;
- RED Infantry x2, IFV x1, Armor x1;
- one RED Command Area;
- no active Supply Truck / Resupply / Reserve Unlock / PreBattleStaging / runtime reinforcement flow;
- selection and MOVE / ADVANCE / WITHDRAW / HOLD FIRE foundations;
- Recon default HOLD FIRE;
- existing 2D simulation truth + 3D presentation/input foundation.

This proves technical runtime capability only. It does not prove the game design is fun, distinctive, or ready for continued Battle01 production.

---

## CURRENT_GAME_DESIGN

GAME_DESIGN_STATUS=REOPENED_NOT_PROVEN
BATTLE01_CONNECTED_PLAYABLE_CONTRACT_V1_STATUS=REOPENED_REFERENCE_ONLY
PREVIOUS_NORTH_CENTRAL_SOUTH_DESIGN=NOT_AUTHORIZED_FOR_IMPLEMENTATION

The previous assumptions around fixed North/Central/South tactical sectors, incomplete information as the primary core, and the existing roster/command structure are no longer treated as proven product answers.

Current discovery hypothesis, NOT frozen:

COMMAND_AND_RESPONSE_HYPOTHESIS=
Player expresses formation-level intent rather than continuous micro;
formations execute locally inside understandable boundaries;
player actions create credible problems the opponent must answer;
commitment changes both sides' future freedom of action;
opportunities emerge from those responses rather than scripted lane choices;
player re-enters when a plan assumption breaks, an execution is blocked, or a meaningful opportunity appears.

Candidate command-design concepts under test, NOT product requirements:
- persistent formation tasks rather than repeated one-shot movement orders;
- command effect + boundary + limited priority as a possible command contract;
- execution autonomy for local routing/cover/engagement while strategic escalation remains player-owned;
- low click density but high judgment density;
- battlefield-attached command visualization instead of HUD-heavy instructions;
- preserve future options versus exploit current opportunities;
- create a dilemma -> force a commitment -> exploit the response.

No candidate above becomes a product rule until directly tested in a playable discovery prototype.

---

## CURRENT_ART_DIRECTION

STATUS=DEFERRED_DURING_GAME_DISCOVERY

The recovered Battle01 visual target package remains historical visual lineage/reference only.

INTERNAL_FORMAL_TARGET_SET=YES
WINDOW_06_TARGET_PACKAGE_VALIDATED=YES
USER_EXPLICIT_PER_IMAGE_APPROVAL=NOT_RECOVERED
CURRENT_3D_PRODUCTION_AUTHORITY=NOT_YET_RECONFIRMED

Production art must not drive or constrain the discovery prototype. Greybox/abstract presentation is preferred until the core interaction is proven.

---

## CURRENT_IMPLEMENTATION

ENGINE=GODOT_4_7_1
CURRENT_ARCHITECTURE=2D_SIMULATION_TRUTH_PLUS_3D_PRESENTATION_INPUT_FOUNDATION

M2_01_IMPLEMENTED_AND_VERIFIED=YES

KEEP_AVAILABLE_AS_TOOLBOX=
- Camera3D foundation;
- 3D presentation/input adapter;
- selection and multi-selection primitives;
- Formation movement/path foundation;
- Intel/LOS foundation;
- Objective capture/ownership foundation;
- deterministic combat foundation;
- M2-01 verified runtime shell.

None of these components are allowed to define the new game design merely because they already exist.

NO_BATTLE01_FEATURE_PRODUCTION_WHILE_DISCOVERY_ACTIVE=YES
NO_M2_02_NORTH_CENTRAL_SOUTH_IMPLEMENTATION=YES
NO_REACTIVE_AI_PRODUCTION_FOR_OLD_CONTRACT=YES
NO_PRODUCTION_ART_PASS=YES

---

## CURRENT_DISCOVERY_TARGET

DISCOVERY_PROTOTYPE_ID=DISCOVERY_PROTOTYPE_A_COMMAND_AND_RESPONSE
STATUS=AUTHORIZED_FOR_DESIGN_AND_MINIMAL_IMPLEMENTATION

The first prototype must be deliberately small and independent of Battle01 content assumptions.

Minimum target:
- BLUE abstract formations = 3;
- RED abstract formations = 3;
- simple readable space;
- persistent player intent/task representation;
- at least one clear execution boundary;
- minimal subordinate execution behavior;
- simple opponent responses caused by player pressure;
- pause/resume acceptable;
- direct visualization of own tasks and important response changes;
- no production art requirement.

Primary questions:
1. Does the player feel they are maintaining a plan rather than repeatedly issuing movement commands?
2. Does the player watch and interpret the opponent's response rather than primarily babysit friendly movement?
3. When intervention is required, can the player understand why the existing plan needs revision?
4. Can a player action create a credible dilemma whose opponent response opens a new choice?
5. Does subordinate autonomy feel like execution of player intent rather than AI playing the game or fighting the player?

FAIL conditions include:
- traditional right-click micro remains clearly more effective or more satisfying;
- player spends most attention correcting subordinate pathing/execution;
- fixed optimal sequence emerges immediately;
- pressure/feint actions are free spam with no commitment cost;
- enemy responses are scripted events rather than consequences of state/actions;
- interface tells the player what decision to make instead of showing facts and plan state;
- prototype requires Battle01 complexity to become interesting.

---

## KNOWN_PRODUCT_BLOCKERS

1. FRONTLINE's core repeated player decision is not yet proven by playable evidence.
2. Formation-level command autonomy has not yet been proven to feel better than conventional RTS micro.
3. The candidate flexibility-versus-initiative and force-a-choice loops remain hypotheses.
4. Unit/formation identities must be re-justified after the interaction core is proven; existing Recon/Infantry/IFV/Armor roles are not protected merely by history.
5. Battle01 battlefield design must be redesigned after, not before, core discovery success.
6. Representative art direction and a Windows player build remain later milestones.

---

## KNOWN_TECHNICAL_BLOCKERS

1. GitHub Frontline Core Verify still has a known CI infrastructure failure mode where jobs can fail before any Godot step executes.
2. Local Godot use has produced pre-existing untracked `.uid/.import` files; repository disposition remains HOLD pending focused hygiene review.
3. Legacy documents/source may retain obsolete Battle01 assumptions; current state and direct user decisions override them.

These technical issues do not block an isolated greybox discovery prototype.

---

## VERIFIED_RUNTIME_EVIDENCE

M2_01_VERIFIED_HEAD_SHA=2638a749654eb73ab18245876d347736e5f36bed
M2_01_LOCAL_VERIFY_TASK=M2_01_LOCAL_GODOT_VERIFY_V1
M2_01_LOCAL_VERIFY_RESULT=PASS
REAL_GODOT_VERSION=4.7.1.stable.official.a13da4feb
PARSE=PASS
BOOT=PASS
SELECTION=PASS
MOVE=PASS
ADVANCE=PASS
WITHDRAW=PASS
HOLD_FIRE=PASS
RUNTIME_ERRORS=NONE
ACCEPTED_WINDOWS_PLAYER_BUILD=NONE

---

## NEXT_DECISION

NEXT=BUILD_DISCOVERY_PROTOTYPE_A_COMMAND_AND_RESPONSE

The next production action is a deliberately isolated discovery prototype, not M2-02 and not a Battle01 feature pass.

The prototype exists to falsify or support the command-and-response hypothesis with direct play evidence. It must remain disposable: no broad architecture, no formal asset pipeline, no production terrain, no old Battle01 contract completion work, and no repository-wide gap search.

CODEX_AUTHORITY=SCOPED_CONSTRUCTION_EXECUTOR_ONLY
CODEX_GAMEPLAY_WORK=ONLY_THE_DISCOVERY_PROTOTYPE_TASK
NO_OPEN_ENDED_CODEX_ROADMAP_AUTHORITY=YES
