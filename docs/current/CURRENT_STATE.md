# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V2
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

M1 is closed by the frozen Battle01 Connected Playable Contract V1.
M2 exists to implement and directly play the approximately 10-15 minute connected decision loop defined by that contract.

---

## CURRENT_PLAYABLE

STATUS=TECHNICAL_PLAYABLE_PROTOTYPE
PRODUCT_VERTICAL_SLICE_STATUS=NOT_ACCEPTED
M2_CONNECTED_PLAYABLE_STATUS=NOT_YET_IMPLEMENTED

The historical Battle01 remains a working technical prototype and reusable toolbox. It is not the accepted M2 Battle01 design.

Real Godot 4.7.1 evidence exists for ancestor commit `51923884e06969460d01f5eb90b940986e491403`: Parse, Boot, real viewport Selection, MOVE, Combat, Objective transitions and repeated Restart all passed with no SCRIPT ERROR / Parse Error / Invalid access observed.

This proves technical playability only. It does not prove the new M2 product design.

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

Frozen Battle01 essentials:
- BLUE: Recon x1, Infantry x2, IFV x1, Armor x1; all available from start;
- RED: Infantry x2, IFV x1, Armor x1; all physically present from initialization;
- one final RED Command Area; no Central->Industrial unlock chain;
- three authored hidden RED defensive plans using the same finite roster;
- symmetric limited information using UNSEEN / CONTACT / CONFIRMED / LAST_KNOWN principles;
- player commands: MOVE / ADVANCE / WITHDRAW / HOLD FIRE<->WEAPONS FREE;
- Recon starts HOLD FIRE;
- RED distinguishes probe vs major commitment using legitimate information;
- finite RED redeployment has commitment inertia;
- no Supply/Resupply or scripted reserve/reinforcement flow in M2;
- Victory/Defeat are deterministic and player-readable.

Exact combat tuning values remain M2 tuning variables unless separately frozen after play evidence.

---

## CURRENT_ART_DIRECTION

STATUS=RECOVERED_BUT_NOT_RECONFIRMED_FOR_3D_PRODUCTION

The eight-image Battle01 target package remains visual lineage/reference.

INTERNAL_FORMAL_TARGET_SET=YES
WINDOW_06_TARGET_PACKAGE_VALIDATED=YES
USER_EXPLICIT_PER_IMAGE_APPROVAL=NOT_RECOVERED
CURRENT_3D_PRODUCTION_AUTHORITY=NOT_YET_RECONFIRMED

M2 may use greybox/proxy presentation. Production-quality visual work is not required to prove the connected gameplay loop and must not block M2.

---

## CURRENT_IMPLEMENTATION

ENGINE=GODOT_4_7_1
CURRENT_ARCHITECTURE=2D_SIMULATION_TRUTH_PLUS_3D_PRESENTATION_INPUT_FOUNDATION

KEEP_FOR_M2=
- Camera3D foundation;
- 3D simulation/presentation adapter;
- GUI-first/unhandled 3D input routing;
- selection/multi-selection primitives;
- Formation movement/path base;
- Intel state model;
- core LOS;
- Objective ownership/capture/contest core;
- deterministic damage/ammo foundation where compatible.

REWORK_FOR_M2=
- battlefield layout into the new North/Central/South tactical sectors;
- command orchestration to the four frozen command semantics;
- PlayerWarFlow into a minimal mission/end-state controller;
- RED AI around the three defensive plans, symmetric information, pressure classification and commitment inertia;
- HUD to show the active M2 contract rather than historical progression systems.

REMOVE_FROM_M2_ACTIVE_FLOW=
- Supply/Resupply and Supply Truck;
- Reserve unlock/deployment;
- Pre-battle Staging gameplay phase;
- Central->Industrial progression;
- fixed-time and post-capture RED reinforcement activation;
- historical route/posture logic that conflicts with the new defensive plans;
- Artillery in Battle01.

Removal from M2 active flow does not authorize immediate source deletion.

---

## KNOWN_PRODUCT_BLOCKERS

1. The frozen M2 Battle01 has not yet been implemented.
2. The ten M2 playable hypotheses in `BATTLE01_CONNECTED_PLAYABLE_CONTRACT_V1.md` have not yet been proven by direct human play.
3. Exact tuning of movement/combat/detection/capture values remains to be adjusted during M2 without violating frozen role relationships.
4. Current representative 3D art direction remains unconfirmed and is intentionally deferred to M3.
5. There is no accepted Windows player build yet.

---

## KNOWN_TECHNICAL_BLOCKERS

1. GitHub `Frontline Core Verify` currently exhibits a `PROJECT_SYSTEM_BUG / CI_INFRASTRUCTURE` failure mode in which recent PR jobs end before any steps execute and provide no Godot logs.
2. Godot validation has generated untracked `.uid/.import` files whose repository policy remains HOLD pending a focused hygiene decision.
3. Legacy documents and source paths may contain obsolete Battle01 assumptions; they are not authority over the frozen M2 contract.

These blockers do not authorize feature expansion or rebuilding the old QA stack.

---

## CURRENT_BUILD

STATE_TRANSITION_BASE_MAIN_SHA=aa6810e84c595d80be9b01e274964ebf4fa5ce6d
ENGINE_BASELINE=Godot_4_7_1
REAL_RUNTIME_EVIDENCE_SHA=51923884e06969460d01f5eb90b940986e491403
REAL_RUNTIME_EVIDENCE_STATUS=TECHNICAL_PLAYABLE_CONFIRMED
ACCEPTED_WINDOWS_PLAYER_BUILD=NONE

---

## NEXT_DECISION

NEXT=DEFINE_M2_IMPLEMENTATION_SEQUENCE_AND_FIRST_SCOPED_TASK

The next action is not a repository-wide gap search. WINDOW_00 must decompose the frozen connected playable into the smallest coherent implementation sequence, then issue the first scoped M2 task with:
- player-facing problem;
- authorized change;
- explicit non-goals;
- reusable/rework components;
- completion evidence.

CODEX_GAMEPLAY_WORK=AUTHORIZED_ONLY_BY_SCOPED_M2_TASK
NO_OPEN_ENDED_CODEX_ROADMAP_AUTHORITY=YES
