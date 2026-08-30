# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
INTEGRATION_AUTHORITY=WINDOW_00_GAME_DIRECTOR_PRODUCER
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V2.md
STATE_VERSION=V1

This file is the single accepted current state required by `FRONTLINE_PROJECT_CHARTER_V2`.
It records current truth, not every historical decision. Historical documents, specialist receipts, tests, and implementation notes do not override this file unless their result is explicitly integrated here or the user explicitly changes direction.

---

## CURRENT_MILESTONE

M1_GAME_DEFINITION

M0_PROJECT_RECOVERY=CLOSED
M1_GAME_DEFINITION=ACTIVE
M2_CONNECTED_PLAYABLE=NOT_STARTED
M3_REPRESENTATIVE_VISUAL_SLICE=NOT_STARTED
M4_PLAYER_BUILD=NOT_STARTED
M5_BATTLE01_VERTICAL_SLICE=NOT_STARTED

Current M1 position:
- project charter V2 frozen;
- core product promise and four product pillars accepted at project level;
- Battle01 candidate experience designed and pressure-tested;
- M1-04 Connected Playable Contract not yet frozen.

---

## CURRENT_PLAYABLE

STATUS=TECHNICAL_PLAYABLE_PROTOTYPE
PRODUCT_VERTICAL_SLICE_STATUS=NOT_ACCEPTED
PRODUCT_STATUS=REWORK_REQUIRED

The existing Battle01 can boot and execute the technical player chain, but it is not the accepted product design for the new Battle01.

Real Godot 4.7.1 runtime evidence exists for repository ancestor commit `51923884e06969460d01f5eb90b940986e491403`:
- Parse PASS;
- Boot PASS;
- real viewport Formation selection PASS;
- RMB MOVE and actual movement PASS;
- combat HP/ammo change PASS;
- Central and Industrial AI->PLAYER objective transitions PASS;
- Victory/Defeat HUD restart PASS, repeated three times;
- no SCRIPT ERROR / Parse Error / Invalid access observed.

The full historical integrated product gate still concluded `PRODUCT_REWORK_REQUIRED`. Technical playability therefore does not imply product acceptance.

---

## CURRENT_GAME_DESIGN

### Accepted project-level design

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

### Battle01 design status

BATTLE01_NEW_DESIGN_STATUS=CANDIDATE_NOT_FROZEN

The current M1 candidate centers on:
- probing an incompletely known enemy deployment;
- committing finite combat power based on imperfect information;
- a finite-force enemy reacting using legitimate information;
- enemy redeployment creating weakness elsewhere;
- reassessment, withdrawal, force preservation, and a later commitment;
- approximately 10-15 minutes for the connected playable target.

Pressure-test revisions to be resolved/frozen in M1-04 include:
- multiple authored hidden enemy defensive plans;
- bilateral information exposure;
- Probe vs Major Commitment recognition;
- enemy commitment inertia;
- Armor as decisive but non-universal combat power;
- WITHDRAW as a required core action;
- Recon default HOLD FIRE candidate behavior;
- objective Victory/Defeat conditions that are deterministic and player-readable.

These Battle01 details are CANDIDATE requirements until M1-04 is accepted.

---

## CURRENT_ART_DIRECTION

STATUS=RECOVERED_BUT_NOT_RECONFIRMED_FOR_3D_PRODUCTION

An internal formal eight-image Battle01 target package exists in `docs/visual_targets/battle01/`.

Current authority distinction:
- INTERNAL_FORMAL_TARGET_SET=YES;
- WINDOW_06_TARGET_PACKAGE_VALIDATED=YES;
- USER_EXPLICIT_PER_IMAGE_APPROVAL=NOT_RECOVERED;
- CURRENT_3D_PRODUCTION_AUTHORITY=NOT_YET_RECONFIRMED.

The historical runtime 2D art pack / manifest is retained as lineage and implementation reference, but its later visual review status was `REWORK_REQUIRED` and it is not an approved 3D production BOM.

The actual current Godot 3D presentation remains a technical proxy/greybox foundation using procedural/simple meshes and materials rather than a representative final art asset set.

No new production art is authorized during M1 before the connected playable contract is frozen.

---

## CURRENT_IMPLEMENTATION

ENGINE=GODOT_4_7_1
ARCHITECTURE=2D_SIMULATION_TRUTH_PLUS_3D_PRESENTATION_INPUT_FOUNDATION

### Strong keep candidates
- Camera3D foundation;
- 3D simulation/presentation adapter;
- core GUI-first / unhandled 3D input routing;
- selection primitives;
- Formation movement/path execution base;
- Intel state model;
- core LOS logic;
- core Objective ownership/capture/contest model.

### Rework candidates
- selection command orchestration;
- PlayerWarFlow / mission progression god-object responsibilities;
- Enemy AI architecture tightly coupled to historical Battle01 rules and CI compatibility;
- separation of gameplay state from 2D/proxy presentation;
- logical terrain/LOS representation when representative 3D terrain becomes authoritative.

### Hold pending M1-04
- Supply / Resupply;
- Reserve unlock/deployment model;
- Pre-battle Staging;
- exact route identities;
- historical seeded RED postures;
- exact historical combat roles, roster, and balance values.

No existing implementation rule is allowed to force a candidate M1 design decision merely because code or tests already exist.

---

## KNOWN_PRODUCT_BLOCKERS

1. `M1-04 CONNECTED PLAYABLE CONTRACT` is not yet frozen.
2. The new Battle01 core loop has been designed and pressure-tested conceptually but has not yet been implemented and proven by direct play.
3. Exact BLUE/RED roster, map tactical layout, defensive-plan definitions, command semantics, AI response boundaries, and end-state rules remain to be frozen in M1-04.
4. Current historical Supply, Reserve, Staging, route and progression mechanics do not automatically carry into the new Battle01.
5. Current 3D visual production direction has not yet been reconfirmed from the recovered visual lineage.
6. Product vertical slice remains not accepted even though the technical prototype runs.

---

## KNOWN_TECHNICAL_BLOCKERS

1. GitHub `Frontline Core Verify` currently has a CI infrastructure/project-system failure mode: recent PR runs failed before any job steps executed and produced no usable Godot logs. This is `PROJECT_SYSTEM_BUG / CI_INFRASTRUCTURE`, not evidence of a gameplay/runtime failure.
2. Current remote main has not itself been subjected to a fresh full local runtime replay after documentation/cleanup commits; however, the commits after the real executed runtime ancestor have not introduced an identified production-runtime drift requiring M0 reopening.
3. Local Godot validation generated untracked `.uid/.import` files. Their repository policy remains HOLD pending a dedicated project-hygiene decision; they must not be mass-deleted merely because they are untracked.
4. Some legacy active-design documents contain outdated or broken historical references. Under Charter V2 they are not current product authority unless integrated into this state.

None of these technical blockers authorizes reopening feature-scale QA or adding new gameplay during M1.

---

## CURRENT_BUILD

REMOTE_MAIN_SHA=bd1a1974e9abcb6d405ed61bfb11b5670909cdeb
REMOTE_MAIN_ROLE=STABLE_CURRENT_REPOSITORY_BASELINE
ENGINE_BASELINE=Godot_4_7_1

REAL_RUNTIME_EVIDENCE_SHA=51923884e06969460d01f5eb90b940986e491403
REAL_RUNTIME_EVIDENCE_STATUS=TECHNICAL_PLAYABLE_CONFIRMED
PRODUCT_ACCEPTANCE_FROM_RUNTIME=NO

There is no accepted packaged Windows player build yet.

---

## NEXT_DECISION

NEXT=M1_04_FREEZE_CONNECTED_PLAYABLE_CONTRACT

M1-04 must convert the pressure-tested Battle01 candidate into one implementable connected-playable contract, including at minimum:
- tactical map structure;
- BLUE and RED Formation roster;
- authored hidden defensive plans;
- information/FOW rules;
- MOVE / ADVANCE / WITHDRAW / HOLD FIRE command semantics if retained;
- Probe vs Major Commitment logic;
- enemy finite-force reaction and commitment inertia;
- Armor role boundary;
- deterministic Victory / Defeat conditions;
- explicit non-goals;
- implementation disposition: KEEP / REWORK / REMOVE / HOLD.

M2 implementation is not authorized until M1-04 is accepted.

---

## CURRENT AUTHORITY SUMMARY

PROJECT_CHARTER=FROZEN
CURRENT_STATE=THIS_FILE
CURRENT_MILESTONE=M1_GAME_DEFINITION
CURRENT_PLAYABLE=TECHNICAL_PLAYABLE_PROTOTYPE
CURRENT_BATTLE01_PRODUCT_DESIGN=CANDIDATE_NOT_FROZEN
CURRENT_3D_ART_DIRECTION=NOT_YET_RECONFIRMED
CODEX_GAMEPLAY_WORK=NOT_AUTHORIZED
NEXT_DECISION=M1_04_CONNECTED_PLAYABLE_CONTRACT
