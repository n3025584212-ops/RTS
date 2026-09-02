# BATTLE01_REVISED_PRODUCT_CONTRACT_V2

TASK_ID=REVISE_BATTLE01_PRODUCT_DESIGN_AFTER_PRESSURE_TEST_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=FROZEN_FOR_REVISED_IMPLEMENTATION
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
UPSTREAM=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md
DOWNSTREAM_GATE=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V2_RESULT.md
DESIGN_GATE_V2=PASS
CORE_DIRECTION=RETAIN
CURRENT_3D_FOUNDATION=RETAIN
NO_NEW_UNIT_TYPE=YES
NO_ECONOMY_EXPANSION=YES
NO_COMPLEX_DAMAGE_SIM=YES

## 1. Product intent

Battle01 remains a Formation/Platoon-level modern-war command game.

Recurring player loop:
OBSERVE -> FORM LOCAL INTENT -> COMMIT -> PAY COST -> ENEMY RESPONSE/NEW INFORMATION -> REASSESS.

The game must repeatedly create plausible alternatives whose value changes with battlefield state.

## 2. Force structure

Active BLUE:
- Recon x1
- Infantry x1
- IFV x1
- Logistics x1

Reserve: one irreversible commitment between Infantry x1 and Armor x1.

No new unit family is added.

## 3. Deterministic role effectiveness

No hit chance, crit, random penetration, suppression, morale, armor facings or component damage are added.

TARGET_CLASS:
- SOFT: Recon, Infantry
- LIGHT_ARMOR: IFV
- HEAVY_ARMOR: Armor
- LOGISTICS: Logistics

Fixed deterministic damage multipliers:

| Attacker | SOFT | LIGHT_ARMOR | HEAVY_ARMOR | LOGISTICS |
|---|---:|---:|---:|---:|
| Recon | 1.00 | 0.40 | 0.20 | 0.75 |
| Infantry | 1.00 | 0.70 | 0.35 | 1.00 |
| IFV | 1.25 | 1.00 | 0.55 | 1.00 |
| Armor | 0.90 | 1.35 | 1.00 | 1.00 |

Damage = BASE_DAMAGE x FIXED_ROLE_MULTIPLIER, rounded deterministically.

Intent:
- Recon gathers information and cannot solve armored threats.
- Infantry supplies ground control and works best in complex terrain, but needs support against heavy armor.
- IFV is mobile anti-soft/fire support and useful against light armor.
- Armor is heavy open-ground direct fire, not a universal ownership/capture solution.

## 4. Ammo pressure

Revised Battle01 ammo capacities:
- Recon 18
- Infantry 24
- IFV 28
- Armor 16

One attack consumes one ammo.

Active BLUE base theoretical damage budget becomes 1152 before role multipliers, versus approximately 860 total RED combat HP. This leaves room for an efficient no-resupply win while allowing poor target matching, counterattack attrition and extended fights to make finite supply matter.

Values remain runtime-tunable only if the intended logistics tradeoff is preserved.

## 5. Capture vs contest

| Role | Capture ownership | Contest/deny |
|---|---|---|
| Recon | NO | NO |
| Infantry | YES | YES |
| IFV | YES | YES |
| Armor | NO | YES |
| Logistics | NO | NO |

Ownership transfer remains 15 seconds of continuous uncontested capture-capable presence.

Armor can defend/deny but cannot establish ownership by itself. Recon cannot steal objectives by speed alone.

## 6. Route identities

Existing Central/North/South route families remain. No new map region is created.

CENTRAL:
- shortest route;
- best vehicle concentration and supply turnaround;
- strongest predictable bridge defense exposure.
- purpose: tempo/concentration.

NORTH / VILLAGE:
- broken LOS and dense blockers;
- authored narrow foot links for Recon/Infantry only;
- IFV/Armor remain on connected streets;
- lateral observation/access toward Central and northern Industrial approach.
- purpose: information and ground-control maneuver.

SOUTH / MANEUVER:
- longest initial route;
- broad vehicle movement and clearer long sight lines;
- best route for IFV/Armor to create a different firing/staging angle and later threaten RED rear/logistics/southern Industrial approach.
- purpose: vehicle maneuver/rear pressure at the cost of tempo.

Route identity must be real navigation/LOS/access geometry, not hidden stat buffs or painted scenery.

## 7. Seeded RED defense postures

Moment-to-moment RED AI remains deterministic and fog-limited. Only pre-match authored posture selection varies by reproducible seed.

POSTURE_A — BRIDGE_LOCK
- INF-01 Central anchor
- INF-02 North screen
- ARMOR deep Central reserve
- SUPPLY standard rear support

POSTURE_B — VILLAGE_SCREEN
- INF-01 west/central bridge defense
- INF-02 forward North village screen
- ARMOR south-offset reserve
- SUPPLY deeper rear slot

POSTURE_C — SOUTH_SCREEN
- INF-01 Central anchor
- INF-02 South screen
- ARMOR north/central reserve slot
- SUPPLY alternate rear slot

Same roster, same map, legal existing sectors only.

Recon remains valuable across repeat runs because the player learns the possible posture set but must still discover which posture is active.

## 8. Logistics

BLUE Supply:
- 2 charges;
- 50% max-ammo restore per completed charge;
- HP restore NO;
- 4 seconds uninterrupted vulnerable transfer.

RESUPPLY is a Formation-level intent rather than a parking minigame:
1. player chooses the depleted Formation to resupply;
2. living friendly Logistics with a charge is assigned;
3. both route toward a legal rendezvous using West Rear Rally or active Bridgehead Forward Rally;
4. transfer begins once positioned legally;
5. movement, damage, target firing, destruction, direct override or loss of range resets/cancels transfer;
6. direct player orders always override automation.

RED Supply now uses the same finite 2-charge/50%/4-second ammunition-transfer concept during legitimate local lulls.

RED resupply priority:
1. depleted Armor <=50% ammo;
2. otherwise most depleted living Infantry <=50% ammo;
3. stable Formation-id tie break.

RED Supply may not use hidden BLUE information. Destroying or forcing it away removes real enemy ammunition recovery capacity.

## 9. Reserve choice

Reserve unlock remains first PLAYER capture of Central Bridgehead.

Infantry is favored when:
- capture capability is lost/weak;
- Bridgehead or Industrial ownership must be established;
- North village/foot access matters;
- faster rear-to-front arrival matters.

Armor is favored when:
- at least one healthy capture-capable Infantry/IFV survives;
- RED heavy/open-ground resistance is the main problem;
- Central/South/open Industrial firepower matters more than ground-control redundancy.

Neither reserve is universally correct.

## 10. Commander-level orders

Frozen revised command set:
- MOVE
- ADVANCE
- HOLD
- HOLD FIRE
- WITHDRAW
- RESUPPLY
- STOP/CANCEL

MOVE: reach destination; no intentional chase away from task.

ADVANCE: progress toward destination, temporarily respond to legitimate CONFIRMED local contact, then resume when local threat ends; no infinite pursuit.

HOLD: locally defend ordered area using normal LOS/range rules.

HOLD FIRE: detection continues but no voluntary firing until released.

WITHDRAW: cancel aggressive/capture intent and disengage toward friendly rally/rear; no stat bonus.

RESUPPLY: execute automated rendezvous plus vulnerable transfer.

STOP/CANCEL: clear current intent and stop/return to local idle/hold behavior.

Player chooses intent. Formation execution handles waypoint following, spacing, destination stopping, local bounded engagement and rendezvous positioning. Direct player orders override automation.

## 11. Pre-battle staging

Battle01 uses fixed-roster DEPLOYMENT/STAGING, not a purchase economy.

Before combat:
- four active BLUE Formations may be positioned inside a bounded West staging area;
- one initial MOVE/ADVANCE/HOLD order may be queued per Formation;
- player starts battle explicitly;
- reserves remain locked until the bridgehead trigger.

No currency, production or deck system is added.

## 12. Revised phase flow

1. STAGING — choose grouping and first intent.
2. OPENING RECON — discover RED posture/route exposure.
3. COMMITMENT — Central tempo, North information/ground control, or South maneuver.
4. FIRST CONTACT — role matching and new information force continue/redirect/disengage decisions.
5. BRIDGEHEAD — Infantry/IFV establish ownership; Armor can contest/protect.
6. COUNTERATTACK — RED reinforcement/local response changes the problem.
7. PRESERVE / RESUPPLY / RESERVE — evaluate ammo, damage, surviving capture capability and tempo.
8. INDUSTRIAL APPROACH — at least two materially viable route solutions must remain.
9. FINAL CONTEST — both objectives matter for Victory.
10. WIN / LOSS / RESTART.

## 13. Superseded forward-design assumptions

For subsequent implementation, this contract supersedes:
- all combat formations capturing objectives;
- Armor capture capability;
- Recon capture capability;
- ammo capacities Recon40 / Infantry36 / IFV48 / Armor24;
- no target-class effectiveness layer;
- RED Supply having no required ammunition-transfer behavior;
- manual parking as required player Supply interaction;
- one fixed RED home-anchor layout as the only defense posture;
- North/Central/South differing mainly by path length/LOS;
- Battle01 purchase implication instead of fixed-roster staging.

Old runtime/code/docs remain temporary runtime dependencies only until revised implementation replaces them. They are not forward product authority.

## 14. Runtime acceptance requirements

Implementation must prove through actual play:
1. at least two RED postures produce materially different opening reads;
2. Recon discovers information the player cannot safely assume from memory;
3. Central/North/South have different real movement/combat tradeoffs;
4. reserve Infantry and reserve Armor are each better in at least one reproducible state;
5. at least one normal run creates a meaningful resupply decision and at least one efficient run can finish without mandatory supply;
6. destroying RED Supply materially reduces RED sustain;
7. RESUPPLY works without parking micro;
8. Armor contests but cannot capture by itself;
9. command workload remains Formation-level;
10. Victory, Defeat and Restart remain intact.

## 15. Current next step

DESIGN_GATE_V2=PASS
REVISED_GAMEPLAY_IMPLEMENTATION=AUTHORIZED
FULL_FINAL_ART_PRODUCTION=BLOCKED_PENDING_REVISED_RUNTIME_PLAYTEST

Next work is to implement this contract inside the existing real Battle01 3D-backed runtime, then run a player-facing product/decision gate before full final-art production resumes.
