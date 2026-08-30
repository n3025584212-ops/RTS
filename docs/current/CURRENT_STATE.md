# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V3
INTEGRATION_AUTHORITY=WINDOW_00_GAME_DIRECTOR_PRODUCER
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V2.md
ACTIVE_BATTLE_CONTRACT=docs/current/BATTLE01_CONNECTED_PLAYABLE_CONTRACT_V1.md

This is the single accepted current state for FRONTLINE. Historical documents, tests, specialist receipts and legacy implementation rules do not override it unless explicitly integrated here or changed by the user.

---

## CURRENT_MILESTONE

CURRENT_MILESTONE=M2_CONNECTED_PLAYABLE

M0_PROJECT_RECOVERY=CLOSED
M1_GAME_DEFINITION=CLOSED
M2_CONNECTED_PLAYABLE=ACTIVE
M3_REPRESENTATIVE_VISUAL_SLICE=NOT_STARTED
M4_PLAYER_BUILD=NOT_STARTED
M5_BATTLE01_VERTICAL_SLICE=NOT_STARTED

M2 is implementing the frozen approximately 10-15 minute connected decision loop one coherent player-facing layer at a time.

---

## CURRENT_PLAYABLE

STATUS=M2_RUNTIME_SHELL_VERIFIED
PRODUCT_VERTICAL_SLICE_STATUS=NOT_ACCEPTED
M2_CONNECTED_PLAYABLE_STATUS=PARTIALLY_IMPLEMENTED

M2_01_RUNTIME_SHELL=COMPLETE

The accepted Battle01 runtime now boots directly into the M2 structure:
- BLUE Recon x1, Infantry x2, IFV x1, Armor x1;
- RED Infantry x2, IFV x1, Armor x1;
- one RED Command Area;
- no active Supply Truck / Resupply / Reserve Unlock / PreBattleStaging / runtime reinforcement flow;
- Recon starts HOLD FIRE;
- selection, MOVE, ADVANCE, WITHDRAW and HOLD FIRE / WEAPONS FREE are available.

This runtime shell was verified locally with real Godot 4.7.1. The full connected playable is not yet complete because the tactical-sector battlefield and reactive RED AI still require M2 implementation.

---

## CURRENT_GAME_DESIGN

PLAYER_ROLE=FRONTLINE_BATTLE_GROUP_COMMANDER
CORE_EXPERIENCE=BATTLEFIELD_JUDGMENT_UNDER_INCOMPLETE_INFORMATION

CORE_DECISION_LOOP=
OBSERVE
-> INTERPRET
-> COMMIT
-> WORLD_AND_ENEMY_RESPONSE
-> REASSESS
-> PRESERVE_OR_PRESS
-> COMMIT_AGAIN

PRODUCT_PILLARS=
1. INFORMATION_BEFORE_COMMITMENT
2. TERRAIN_CREATES_TACTICAL_PROBLEMS
3. ENEMY_REACTS_NOT_CHEATS
4. PRESERVE_COMBAT_POWER

BATTLE01_PRODUCT_DESIGN=FROZEN_CONNECTED_PLAYABLE_CONTRACT_V1

Frozen essentials remain unchanged:
- BLUE=Recon x1 / Infantry x2 / IFV x1 / Armor x1;
- RED=Infantry x2 / IFV x1 / Armor x1;
- North / Central / South must create distinct tactical problems;
- one final RED Command Area;
- three authored hidden RED defensive plans using the same finite roster;
- symmetric limited information using UNSEEN / CONTACT / CONFIRMED / LAST_KNOWN principles;
- player commands MOVE / ADVANCE / WITHDRAW / HOLD FIRE<->WEAPONS FREE;
- RED must distinguish probe from major commitment using legitimate information;
- finite RED redeployment must have commitment inertia;
- no Supply/Resupply or scripted reserve/reinforcement flow in M2.

---

## CURRENT_ART_DIRECTION

STATUS=RECOVERED_BUT_NOT_RECONFIRMED_FOR_3D_PRODUCTION

INTERNAL_FORMAL_TARGET_SET=YES
WINDOW_06_TARGET_PACKAGE_VALIDATED=YES
USER_EXPLICIT_PER_IMAGE_APPROVAL=NOT_RECOVERED
CURRENT_3D_PRODUCTION_AUTHORITY=NOT_YET_RECONFIRMED

M2 may use greybox/proxy presentation. Production art must not block gameplay validation.

---

## CURRENT_IMPLEMENTATION

ENGINE=GODOT_4_7_1
CURRENT_ARCHITECTURE=2D_SIMULATION_TRUTH_PLUS_3D_PRESENTATION_INPUT_FOUNDATION

M2_01_IMPLEMENTED_AND_VERIFIED=
- new five-Formation BLUE starting roster;
- finite four-Formation RED roster;
- single Command Area mission shell;
- legacy Supply/Staging/Reserve Unlock/Reinforcement runtime flow inactive;
- minimal M2 HUD;
- selection and movement foundation retained;
- MOVE / ADVANCE / WITHDRAW / HOLD FIRE active;
- Recon default HOLD FIRE;
- deterministic combat foundation retained.

KEEP_FOR_M2=
- Camera3D foundation;
- 3D simulation/presentation adapter;
- GUI-first/unhandled 3D input routing;
- selection/multi-selection primitives;
- Formation movement/path base;
- Intel state model;
- core LOS;
- Objective ownership/capture/contest core;
- deterministic damage/ammo foundation.

REWORK_NEXT_FOR_M2=
- battlefield geometry and navigation into true North / Central / South tactical sectors;
- RED AI around authored plans, symmetric information, pressure classification and commitment inertia;
- HUD only where needed to make the connected decision loop readable.

Removal from M2 active flow does not authorize source deletion of historical systems.

---

## KNOWN_PRODUCT_BLOCKERS

1. North / Central / South do not yet constitute the frozen three tactical problems in the accepted M2 runtime.
2. New RED reactive AI is not yet implemented.
3. The complete approximately 10-15 minute OBSERVE->COMMIT->REASSESS loop has not yet been proven by direct human play.
4. Exact movement/combat/detection/capture values remain M2 tuning variables.
5. Representative 3D art direction remains unconfirmed and is deferred to M3.
6. There is no accepted Windows player build yet.

---

## KNOWN_TECHNICAL_BLOCKERS

1. GitHub Frontline Core Verify still has a PROJECT_SYSTEM_BUG / CI_INFRASTRUCTURE mode where jobs fail before any step executes and provide no Godot logs.
2. Local Godot use has produced pre-existing untracked `.uid/.import` files; repository disposition remains HOLD pending focused hygiene review.
3. Legacy documents/source may retain obsolete Battle01 assumptions; they are not authority over the frozen M2 contract.

No current runtime blocker is known for the merged M2-01 shell.

---

## CURRENT_BUILD

CURRENT_MAIN_AFTER_M2_01=ba4f3f1c5f3dce7736014963230b6103ef029c0d
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

NEXT=M2_02_BUILD_NORTH_CENTRAL_SOUTH_TACTICAL_SECTORS

M2-02 must make terrain itself create three materially different player judgments:
- North = broken information / close approach;
- Central = fastest and most exposed direct approach;
- South = mobile but exposed maneuver.

The next task must remain scoped to battlefield geometry, LOS and pathing needed to prove those differences. It must not prematurely implement RED reactive AI, production art, logistics, economy or unrelated systems.

CODEX_GAMEPLAY_WORK=AUTHORIZED_ONLY_BY_SCOPED_M2_TASK
NO_OPEN_ENDED_CODEX_ROADMAP_AUTHORITY=YES
