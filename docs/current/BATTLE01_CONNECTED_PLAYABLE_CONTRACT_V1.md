# BATTLE01 CONNECTED PLAYABLE CONTRACT V1

STATUS=FROZEN_CONNECTED_PLAYABLE_CONTRACT
PROJECT=FRONTLINE
MILESTONE=M1_GAME_DEFINITION
OWNER=WINDOW_00_GAME_DIRECTOR_PRODUCER
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V2.md
CURRENT_STATE=docs/current/CURRENT_STATE.md
ENGINE_BASELINE=GODOT_4_7_1
CONTRACT_ID=BATTLE01_CONNECTED_PLAYABLE_CONTRACT_V1

---

## 0. Purpose

This contract freezes the minimum Battle01 product design that M2 must implement as a coherent approximately 10-15 minute connected playable.

The purpose is not to preserve the historical Battle01 feature stack. The purpose is to prove FRONTLINE's core player experience:

OBSERVE
-> INTERPRET
-> COMMIT
-> WORLD_AND_ENEMY_RESPONSE
-> REASSESS
-> PRESERVE_OR_PRESS
-> COMMIT_AGAIN

M2 implementation must serve this chain. Existing code may be reused where it supports the contract, reworked where it conflicts, and excluded where it does not create necessary player judgment.

---

## 1. Battle promise

BATTLE01_WORKING_NAME=FIRST_CONTACT
TARGET_PLAY_TIME=APPROX_10_TO_15_MINUTES
HARD_MISSION_TIMER=NO

The player enters with incomplete knowledge of the RED deployment. The first problem is not to capture a scripted intermediate point. It is to determine where RED is strong, where it is weak, and when enough information exists to commit real combat power.

The battle must create at least two meaningful commitment decisions:

1. FIRST_COMMITMENT: where and with what force to apply serious pressure;
2. REASSESSMENT_COMMITMENT: whether to continue, withdraw, or shift after RED reacts and exposes a new weakness.

A reasonable bad first judgment should normally produce cost plus new information and a chance to adapt, not an immediate scripted defeat.

---

## 2. Frozen force roster

### 2.1 BLUE

BLUE_FORMATION_COUNT=5

- RECON x1
- INFANTRY x2
- IFV x1
- ARMOR x1

All five BLUE formations are available from battle start.

NO_BLUE_PURCHASE=YES
NO_BLUE_RESERVE_UNLOCK=YES
NO_BLUE_SCRIPTED_REINFORCEMENT=YES

The player may voluntarily hold Armor or any other formation back. Reserve behavior is a player decision, not a UI lock or unlock mechanic.

### 2.2 RED

RED_FORMATION_COUNT=4

- INFANTRY x2
- IFV x1
- ARMOR x1

All RED formations physically exist in the battle from initialization.

NO_RED_RUNTIME_SPAWN=YES
NO_RED_FIXED_TIME_REINFORCEMENT=YES
NO_RED_HIDDEN_EXTRA_FORCE=YES

RED may reposition only by normal movement using the same battlefield space and movement constraints that the player can observe when information permits.

---

## 3. Formation role boundaries

### RECON

PRIMARY_ROLE=INFORMATION
DEFAULT_FIRE_DISCIPLINE=HOLD_FIRE
DIRECT_COMBAT_ROLE=WEAK
CAN_CAPTURE=NO
CAN_CONTEST=NO

Recon must have the best information-gathering reach among BLUE formations and must not be the best direct combat solution.

### INFANTRY

PRIMARY_ROLE=COMPLEX_TERRAIN_AND_GENERAL_COMBAT
CAN_CAPTURE=YES
CAN_CONTEST=YES

Infantry should be the safest general-purpose formation for broken terrain but must not dominate open direct-fire engagements against Armor.

### IFV

PRIMARY_ROLE=MOBILE_FIRE_SUPPORT
CAN_CAPTURE=YES
CAN_CONTEST=YES

IFV should combine mobility and useful firepower without replacing Armor in decisive open combat or Recon in information gathering.

### ARMOR

PRIMARY_ROLE=DECISIVE_DIRECT_FIRE_COMMITMENT
CAN_CAPTURE=YES
CAN_CONTEST=YES

Armor is the strongest direct-fire commitment in favorable open conditions, but it must not be a universal answer. It has weaker information reach than Recon and should be less comfortable in the North broken-terrain sector.

M2 may tune HP, damage, range, detection, speed, fire interval and ammo values without reopening this contract so long as these role relationships remain true.

---

## 4. Battlefield structure

Battle01 uses one west-to-east battlefield divided by a river barrier and three tactical sectors. These are not three cosmetic lanes and do not need identical topology.

### 4.1 BLUE ASSEMBLY AREA

Located west of the river.

Purpose:
- initial command orientation;
- enough room to separate formations and choose probes;
- no purchase/deployment economy.

### 4.2 NORTH SECTOR — VILLAGE / WOODLINE / FORD

TACTICAL_IDENTITY=BROKEN_INFORMATION_AND_CLOSE_APPROACH

Required characteristics:
- broken LOS;
- multiple blockers or short sight lines;
- narrow or indirect vehicle approaches;
- Recon and Infantry can approach with lower long-range exposure;
- Armor cannot exploit its full direct-fire advantage as easily as in open terrain.

No arbitrary hidden percentage modifier is required. Geometry, LOS and pathing should create the tactical difference where possible.

### 4.3 CENTRAL SECTOR — ROAD BRIDGE

TACTICAL_IDENTITY=FASTEST_AND_MOST_EXPOSED_DIRECT_APPROACH

Required characteristics:
- shortest clear crossing;
- long sight lines;
- strong direct-fire opportunities;
- easiest sector for RED to visibly prepare;
- fastest route for heavy formations when not defended.

### 4.4 SOUTH SECTOR — INDUSTRIAL SERVICE CROSSING

TACTICAL_IDENTITY=MOBILE_BUT_EXPOSED_MANEUVER

Required characteristics:
- longer or less direct approach than Central;
- more space for vehicles after crossing;
- limited hard cover on at least part of the approach;
- a successful penetration can threaten the RED rear/Command Area quickly.

### 4.5 RED COMMAND AREA

One final Command Area exists east of the river.

NO_INTERMEDIATE_UNLOCK_OBJECTIVE=YES
NO_CENTRAL_TO_INDUSTRIAL_PROGRESSION=YES

The player may approach the Command Area from more than one sector. The final battlefield state must be a consequence of earlier reconnaissance, combat and RED redeployment rather than a fixed objective unlock sequence.

---

## 5. Information and fog-of-war

INFORMATION_MODEL=SYMMETRIC_LIMITED_INFORMATION

The existing conceptual states remain valid:

UNSEEN
CONTACT
CONFIRMED
LAST_KNOWN

### UNSEEN
No player-facing enemy position is provided.

### CONTACT
Indicates that an enemy presence or event has been detected, but does not expose a continuously updated exact hidden position.

### CONFIRMED
The observing side has sufficient current legitimate detection/LOS to identify and target the formation according to normal combat rules.

### LAST_KNOWN
Stores only the last legally known position/state. It must not update from hidden live truth.

Both BLUE and RED operate under this principle.

AI_FOW_CHEAT=PROHIBITED
PLAYER_PERFECT_INFORMATION=PROHIBITED

Information gathering is bilateral. A BLUE formation that pushes deep enough to observe RED may itself become CONTACT or CONFIRMED to RED if RED has legitimate detection/LOS.

No new probabilistic stealth, electronic warfare, camouflage-stat system or detection mini-game is required in M2.

---

## 6. Player command set

M2 freezes four player-facing command semantics.

### 6.1 MOVE

MOVEMENT_PRIORITY=YES
AUTO_ACQUIRE_NEW_TARGETS=NO

Issuing MOVE clears the formation's current offensive target and sends it to the destination. The formation does not stop merely to acquire a new enemy target while executing MOVE.

MOVE exists to reposition without accidentally turning every movement order into an attack order.

### 6.2 ADVANCE

MOVEMENT_PRIORITY=NO
AUTO_ENGAGE_LEGAL_CONFIRMED_THREATS=YES

The formation moves toward the destination but may engage legitimate CONFIRMED enemy formations encountered in LOS/range. When the relevant threat is destroyed or lost and the path remains valid, the formation may continue toward the ordered destination.

ADVANCE is the deliberate move-and-fight command.

### 6.3 WITHDRAW

SURVIVAL_AND_DISENGAGEMENT_PRIORITY=YES
CLEAR_OFFENSIVE_TARGET=YES
AUTO_ACQUIRE_NEW_TARGETS=NO
FIRE_WHILE_WITHDRAWING=NO

WITHDRAW sends the formation to a selected safe destination, clears its current offensive target, suppresses target acquisition and firing while the withdrawal order is active, and prioritizes leaving the engagement.

On arrival, the formation returns to normal idle/HOLD behavior while preserving its chosen fire-discipline toggle.

WITHDRAW exists so a wrong judgment can create loss and recovery rather than forcing every contact to continue until destruction.

### 6.4 HOLD FIRE / WEAPONS FREE

This is a persistent fire-discipline toggle.

HOLD_FIRE:
- prevents automatic firing;
- does not prevent movement or observation.

WEAPONS_FREE:
- permits firing when the current movement/order semantics allow it.

Recon starts in HOLD FIRE. Infantry, IFV and Armor start in WEAPONS FREE.

No larger command palette is authorized for M2 unless a direct playable blocker proves one of these four commands insufficient.

---

## 7. Authored hidden RED defensive plans

Each Battle01 run selects exactly one authored defensive plan at initialization.

DEFENSIVE_PLAN_COUNT=3
PLAYER_TOLD_PLAN_ID=NO
MID_BATTLE_PLAN_SWAP=NO
RUNTIME_RANDOM_UNIT_CREATION=NO

Development/debug builds may force a plan ID for testing. Normal player runs do not reveal the selected plan before reconnaissance.

All three plans use the same RED roster. Only initial deployment, local mission assignment and reserve position differ.

### PLAN_A — BRIDGE_LOCK

- RED INFANTRY A: Central primary defense;
- RED IFV: Central depth/support;
- RED INFANTRY B: North screen;
- RED ARMOR: east-central reserve position.

Expected player read:
Central appears genuinely strong. South offers a potential maneuver opportunity if the player confirms the gap and can accept exposure.

### PLAN_B — VILLAGE_WEIGHT

- RED INFANTRY A: North village/woodline primary defense;
- RED IFV: North depth/support;
- RED INFANTRY B: Central screen;
- RED ARMOR: central rear reserve position with access to North/Central.

Expected player read:
North can initially look like a screen but is actually the heavier forward defense. Central may become exploitable after RED support commits north.

### PLAN_C — SOUTHERN_TRAP

- RED INFANTRY A: Central visible screen;
- RED INFANTRY B: South industrial defense;
- RED IFV: South depth/support;
- RED ARMOR: south-rear reserve position, initially masked by terrain/LOS where practical.

Expected player read:
South may look attractive from limited early information, but a deep commitment can reveal stronger mobile resistance. North is comparatively light.

The plan system exists to preserve the value of reconnaissance across repeat runs. It must not become procedural random placement.

---

## 8. RED pressure interpretation

RED must distinguish a probe from a major commitment using only legitimate RED information and events experienced by RED formations.

BLUE_MAIN_COMBAT_FORMATIONS=INFANTRY,IFV,ARMOR
RECON_COUNTS_AS_MAIN_COMBAT=NO

### PROBE

Treat pressure as a probe when RED has only limited evidence, especially:
- only BLUE Recon is CONFIRMED in a sector; or
- only one BLUE formation is CONFIRMED in a sector and local defenders have not suffered substantial sustained damage.

A probe may trigger local alerting, facing/repositioning or local screening behavior. It must not automatically pull the RED Armor reserve across the battlefield.

### MAJOR COMMITMENT

RED may classify a sector as a major commitment when at least one of these legitimate conditions is true:

1. two or more distinct BLUE main combat formations are simultaneously CONFIRMED in the same sector; or
2. at least one BLUE main combat formation is CONFIRMED and a RED defender in that sector has lost approximately 25% or more of max HP during the current contact episode; or
3. BLUE is contesting the final Command Area.

A short loss-of-contact grace window may define the end of a contact episode. Initial M2 value may be 8 seconds and is a tuning parameter, not a product pillar.

The AI must not count hidden BLUE formations or use live hidden positions to satisfy these rules.

---

## 9. RED finite-force reaction

RED reaction must consume real formations and therefore create opportunity elsewhere.

### Local defense

A formation already assigned to a sector should respond locally before distant reserve forces are committed when practical.

### Mobile support

The RED IFV may support its assigned sector and may be retasked if the current defensive plan and observed pressure justify it.

### Armor reserve

RED Armor is the principal decisive reserve.

A Recon-only contact must not automatically commit it.
A credible major commitment may commit it.

### Commitment inertia

COMMITMENT_INERTIA=REQUIRED

When RED Armor or another mobile support formation is ordered to redeploy to a different sector because of a major commitment, that move occupies real time and space.

The formation must normally continue to its assigned support/sector anchor before strategic reassessment can reverse the commitment.

Immediate retasking is permitted only for a real emergency such as:
- the final Command Area becoming contested;
- the formation itself being forced into immediate self-defense;
- its current path becoming invalid or impossible.

The AI may not instantly reverse every redeployment merely because a new hidden or newly detected BLUE unit appears elsewhere.

This rule exists so the player can create and exploit a temporary weakness by presenting a credible threat.

---

## 10. Combat and preservation

M2 should reuse the existing deterministic combat foundation where practical.

RANDOM_HIT_CHANCE_REQUIRED=NO
CRITICAL_HIT_REQUIRED=NO
PENETRATION_SYSTEM_REQUIRED=NO
SUPPRESSION_SYSTEM_REQUIRED=NO
MORALE_SYSTEM_REQUIRED=NO

Damage persists for the battle.
Ammo remains finite for combat formations.

M2_RESUPPLY=NO

Running low on ammo or taking damage must affect the player's willingness to keep a formation committed. The first connected playable proves preservation through finite combat power and WITHDRAW before introducing a logistics loop.

Exact HP, damage, range, ammo and timing values remain M2 tuning parameters unless separately frozen later after play evidence.

---

## 11. Victory and defeat

### Victory

VICTORY requires both:

1. final RED Command Area ownership/control is PLAYER; and
2. no living RED combat formation remains inside the authored Command Area counterattack zone.

The counterattack zone must be explicit in level data and player-readable through battle context. It must be larger than the local capture footprint so a nearby RED Armor formation cannot be ignored while the player wins by standing on a small circle.

The existing objective-capture component may be reused. Its exact continuous capture duration is an M2 tuning value; retaining the current 15-second baseline is allowed initially and does not make the old Central/Industrial progression authoritative.

### Defeat

DEFEAT occurs when all four BLUE main combat formations are destroyed:

- INFANTRY x2
- IFV x1
- ARMOR x1

Recon alone cannot complete the mission and does not prevent defeat.

Loss of Recon, one route, one engagement, one formation, or the first attack does not independently trigger scripted defeat.

---

## 12. Required player-readable feedback

M2 may remain greybox, but the player must be able to understand the decision chain.

Minimum readable information:
- selected formation(s);
- current command/order;
- HP;
- ammo;
- fire discipline;
- legal CONTACT / CONFIRMED / LAST_KNOWN enemy information;
- Command Area ownership/contest state;
- Victory/Defeat state;
- enough formation identity to distinguish Recon / Infantry / IFV / Armor.

Old Supply, Reserve unlock and intermediate-objective UI must not remain visible as if those systems were still part of the active Battle01 contract.

A tactical overview/minimap may be retained if it obeys the same FOW legality. It is not allowed to reveal hidden RED truth.

---

## 13. Explicit M2 non-goals

The connected playable must not expand into the following:

- base building;
- economy or currency;
- purchase/deck/loadout flow;
- scripted reserve unlock;
- Supply Truck / resupply loop;
- artillery;
- aircraft;
- drones;
- electronic warfare system;
- morale;
- suppression;
- armor penetration simulation;
- strategic layer;
- campaign;
- procedural mission generation;
- additional maps;
- additional unit classes;
- production-quality final art;
- large command palette beyond the four frozen command semantics.

These are not permanently rejected for FRONTLINE. They are unauthorized for M2 because they are not required to prove the connected player decision loop.

---

## 14. Existing implementation disposition for M2

This section authorizes reuse/rework direction. It does not authorize blind deletion of historical source files.

### KEEP

- Godot 4.7.1 project foundation;
- Camera3D foundation;
- 3D simulation/presentation adapter;
- GUI-first / unhandled-input 3D routing;
- selection and multi-selection primitives;
- Formation movement/path execution base;
- current Intel state model;
- core LOS calculation;
- core Objective ownership/capture/contest behavior;
- deterministic basic damage/ammo foundation where compatible.

### REWORK

- Battle01 map/world layout to the new North/Central/South tactical-sector contract;
- command orchestration to exact MOVE / ADVANCE / WITHDRAW / fire-discipline semantics;
- PlayerWarFlow into a minimal Battle01 mission/end-state controller without old progression systems;
- Enemy AI around the three authored defensive plans, symmetric information, pressure classification, finite-force reaction and commitment inertia;
- HUD to represent the active contract rather than old Supply/Reserve/Industrial-unlock workflow;
- gameplay/presentation coupling only where it directly blocks the M2 playable.

### REMOVE_FROM_M2_ACTIVE_FLOW

- Supply / Resupply;
- Supply Truck as an active Battle01 formation;
- Reserve unlock/deployment system;
- Pre-battle staging as a gameplay phase;
- Central Bridgehead -> Industrial Objective unlock progression;
- fixed-time RED reinforcement activation;
- old post-capture reinforcement-delay progression;
- historical route/posture behavior that conflicts with the three new defensive plans;
- Artillery formation from Battle01.

REMOVE_FROM_M2_ACTIVE_FLOW does not mean immediate repository deletion. Source cleanup requires a separate dependency/provenance decision after the connected playable is stable.

### HOLD

- current historical visual target package as visual lineage/reference, not automatic M2 production authority;
- historical runtime art manifests;
- advanced logistics;
- campaign/strategic systems;
- final asset pipeline decisions.

---

## 15. M2 playable hypotheses to prove

M2 is complete only when direct play can evaluate the following product hypotheses, not merely when scripts pass:

1. The player cannot know which of the three RED defensive plans is active without observing the battlefield.
2. Recon changes the player's commitment decision and can gather useful information without automatically firing.
3. Recon-only probing does not automatically drag the RED Armor reserve away.
4. A credible multi-formation attack can cause a finite RED redeployment.
5. That RED redeployment creates a real temporary weakness somewhere else because forces cannot be in two sectors at once.
6. The player can recognize that change and choose to press, shift, or withdraw.
7. WITHDRAW allows at least some bad judgments to become recoverable losses rather than automatic destruction.
8. Armor is valuable enough to feel like a major commitment but not sufficient to solve every terrain/information problem alone.
9. Different defensive plans make a repeat run require renewed observation rather than memorized route choice.
10. Victory or defeat can be explained as a consequence of the player's battlefield judgments and preserved combat power.

Automated tests may protect technical behavior. Human play evidence is required to judge these hypotheses.

---

## 16. M1 closure / M2 authorization boundary

M1_CONNECTED_PLAYABLE_DESIGN=FROZEN
M1_GAME_DEFINITION=COMPLETE_AFTER_INTEGRATION_INTO_CURRENT_STATE

M2 may begin only from scoped implementation tasks derived from this contract.

Codex or another coding agent may not inspect the repository and decide what to build next. WINDOW_00 must issue each M2 construction task with:
- player-facing problem;
- authorized change;
- explicit non-goals;
- relevant existing components to reuse/rework;
- completion evidence.

No implementation task may silently reopen this contract. Product contradictions return to WINDOW_00 for explicit decision.
