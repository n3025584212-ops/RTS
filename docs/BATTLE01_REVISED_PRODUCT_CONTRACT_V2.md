# BATTLE01_REVISED_PRODUCT_CONTRACT_V2

TASK_ID=REVISE_BATTLE01_PRODUCT_DESIGN_AFTER_PRESSURE_TEST_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTROL_OWNER=WINDOW_00_CONTROL
STATUS=PROPOSED_REVISED_PRODUCT_AUTHORITY
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
UPSTREAM=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_RESULT_V1.md
CORE_DIRECTION=RETAIN
CURRENT_3D_FOUNDATION=RETAIN
NO_NEW_UNIT_TYPE=YES
NO_ECONOMY_EXPANSION=YES
NO_COMPLEX_DAMAGE_SIM=YES

## 1. Product intent

Battle01 remains a Formation/Platoon-level modern-war command game. The recurring player loop is:

OBSERVE -> FORM LOCAL INTENT -> COMMIT -> PAY COST -> ENEMY RESPONSE/NEW INFORMATION -> REASSESS.

The game should repeatedly ask the player to choose between plausible alternatives, not merely execute a solved sequence.

## 2. Revised active BLUE force and reserve

Active BLUE force remains:
- Recon x1
- Infantry x1
- IFV x1
- Logistics x1

Reserve remains one irreversible commitment between:
- Infantry x1
- Armor x1

No unit family is added.

## 3. Deterministic role effectiveness

Combat remains deterministic. No hit chance, crit, random penetration, suppression, morale, armor facings or component damage are added.

Each Formation has a TARGET_CLASS:
- SOFT: Recon, Infantry
- LIGHT_ARMOR: IFV
- HEAVY_ARMOR: Armor
- LOGISTICS: Logistics

Each attacking role applies one fixed deterministic damage multiplier by target class:

| Attacker | SOFT | LIGHT_ARMOR | HEAVY_ARMOR | LOGISTICS |
|---|---:|---:|---:|---:|
| Recon | 1.00 | 0.40 | 0.20 | 0.75 |
| Infantry | 1.00 | 0.70 | 0.35 | 1.00 |
| IFV | 1.25 | 1.00 | 0.55 | 1.00 |
| Armor | 0.90 | 1.35 | 1.00 | 1.00 |

Damage event remains:
BASE_DAMAGE x FIXED_ROLE_MULTIPLIER, rounded deterministically.

Purpose:
- Recon can finish/lightly fight SOFT targets but should not solve armored threats.
- Infantry remains useful against SOFT targets and ground-control problems but needs support against heavy armor.
- IFV is the best current active anti-infantry/mobile-fire-support Formation and remains useful against light armor.
- Armor is the strongest heavy direct-fire intervention against vehicles, but is not a universal ground-control answer.

## 4. Ammo pressure revision

Battle01 ammo capacities are revised for the next implementation target:

- Recon AMMO=18
- Infantry AMMO=24
- IFV AMMO=28
- Armor AMMO=16

One attack still consumes exactly one ammo.

Reasoning:
- active BLUE base theoretical damage budget becomes 1152 before target-role modifiers, rather than 1976;
- RED combat HP remains 860 before role interactions;
- inefficient target matching, counterattack attrition and route choice can therefore create a meaningful supply decision;
- a strong run can still finish without being forced into a scripted resupply stop.

These values are Battle01 balance values and require runtime tuning after implementation evidence.

## 5. Capture and contest responsibility

CAPTURE and CONTEST are separate capabilities.

| Role | Capture ownership | Contest/deny |
|---|---|---|
| Recon | NO | NO |
| Infantry | YES | YES |
| IFV | YES | YES |
| Armor | NO | YES |
| Logistics | NO | NO |

Artillery, if present only as a dormant/future definition, remains NO/NO for Battle01.

A full ownership transfer still requires 15 seconds continuous uncontested presence by at least one capture-capable Formation.

Armor can stop an enemy capture and defend a point, but Armor alone cannot establish ownership. Recon cannot win an objective simply by exploiting speed.

This makes reserve Infantry valuable when the player needs another ground-control Formation, while reserve Armor remains valuable when the problem is heavy firepower.

## 6. Route identities

The existing Central/North/South route families are retained. No new map region is created.

### CENTRAL — concentration route
- shortest path to Central Bridgehead;
- widest access for vehicles;
- easiest supply turnaround;
- highest probability of meeting the prepared main defense;
- river crossing remains the central choke.

Player reason to choose it: tempo and concentration.
Cost: predictable exposure and direct resistance.

### NORTH / VILLAGE — dismounted/observation route
- broken LOS and dense blockers;
- Recon and Infantry may use authored narrow foot-access links/shortcuts unavailable to IFV/Armor;
- IFV/Armor remain legal in connected streets but cannot cut through foot lanes;
- provides lateral observation/access toward Central and the northern Industrial approach.

Player reason to choose it: information, cover geometry and ground-control flexibility.
Cost: slower vehicle support and fragmented lines of fire.

### SOUTH / MANEUVER — vehicle/rear-pressure route
- longest initial route;
- broad vehicle movement and clearer long sight lines;
- best existing route for IFV/Armor to reposition toward RED rear/support and the southern Industrial approach after the bridgehead phase;
- weaker immediate capture tempo.

Player reason to choose it: preserve vehicle mobility, threaten logistics/rear response, create a different final approach.
Cost: time and temporary concentration loss.

Route identity must come from real navigation/LOS/access geometry, not painted scenery or arbitrary hidden buffs.

## 7. Authored RED pre-match defense postures

Moment-to-moment RED AI remains deterministic and fog-limited. No random tactical decisions are added.

At match initialization, one authored posture is selected from a seeded set. The seed is reproducible for QA.

### POSTURE_A — BRIDGE_LOCK
- INF-01: Central anchor
- INF-02: North screen
- ARMOR-01: deep Central reserve
- SUPPLY-01: standard rear support

### POSTURE_B — VILLAGE_SCREEN
- INF-01: west/central bridge defense
- INF-02: forward North village screen
- ARMOR-01: south-offset reserve
- SUPPLY-01: deeper rear slot

### POSTURE_C — SOUTH_SCREEN
- INF-01: Central anchor
- INF-02: South approach screen
- ARMOR-01: north/central reserve slot
- SUPPLY-01: alternate rear slot

All anchors remain inside existing legal Battle01 sectors and use the same roster.

Recon's replay value is to discover which posture is active and where the armor/support relationship currently sits. The AI may only react to BLUE using its legitimate information model after play begins.

## 8. Logistics becomes a real battlefield system

### BLUE Supply
- Supply charges remain 2.
- Each completed charge restores 50% of target maximum ammo, capped at max.
- HP restoration remains NO.
- Four uninterrupted seconds of vulnerable transfer remain.

Manual parking micro is removed from the product requirement.

RESUPPLY becomes a Formation-level intent:
1. player selects a depleted combat Formation and issues RESUPPLY;
2. the game assigns the living BLUE Logistics Formation if a charge exists;
3. combat Formation and Logistics route toward the nearest valid rendezvous using West Rear Rally or active Bridgehead Forward Rally as preferred safe geometry;
4. both stop when a legal transfer position is reached;
5. the same four-second uninterrupted transfer occurs;
6. movement, damage, target firing, destruction, direct override or loss of range cancels/reset transfer;
7. any direct player order overrides RESUPPLY immediately.

Player decision is which Formation deserves finite supply and whether conceding time/position is worth it, not how precisely to park two icons.

### RED Supply
RED SUPPLY-01 uses the same finite 2-charge/50%/4-second ammunition transfer contract during legitimate local lulls.

RED may resupply only a living depleted RED combat Formation that is not currently ENGAGE, is inside its support/rear mission area, and can be serviced without violating the Supply survival rules.

Priority:
1. depleted Armor if alive and <=50% ammo;
2. otherwise the most depleted living Infantry <=50% ammo;
3. stable Formation-id tie break.

RED Supply may not move toward hidden BLUE information to perform resupply.

Destroying or forcing away RED Supply therefore removes real enemy ammunition recovery capacity and becomes a genuine flank reward.

## 9. Reserve decision

Reserve unlock remains first PLAYER capture of Central Bridgehead and one irreversible commitment.

### Reserve Infantry is best when
- the player lost/critically damaged a ground-control Formation;
- Central Bridgehead must be recaptured or Industrial ownership must be secured;
- North village/foot-access geometry matters;
- faster rear-to-front movement matters more than heavy firepower.

### Reserve Armor is best when
- sufficient Infantry/IFV capture capability survives;
- the player expects heavy vehicle resistance in open Central/South/Industrial approaches;
- the immediate problem is stopping/defeating armored counterattack rather than establishing ownership.

No rule guarantees either choice is correct. The value depends on surviving force, RED posture, route and objective state.

## 10. Commander-level intent orders

The Battle01 command set is frozen for the revised product target as:

- MOVE
- ADVANCE
- HOLD
- HOLD FIRE
- WITHDRAW
- RESUPPLY
- STOP/CANCEL

### MOVE
Reach a destination using legal navigation. Do not intentionally chase new targets away from the movement task. Existing self-defense/direct-fire rules may still apply when a legitimate threat is already in range.

### ADVANCE
Move toward destination while responding to legitimate CONFIRMED contacts encountered along the route. After the local contact is destroyed/lost/bounded out, resume progress toward the original destination. No infinite pursuit.

### HOLD
Defend the current/local ordered area. Engage legitimate CONFIRMED targets under normal range/LOS rules and remain locally anchored.

### HOLD FIRE
Do not voluntarily fire until released by the player. Detection/observation continues. This preserves concealment/ambush value.

### WITHDRAW
Cancel aggressive/capture intent and disengage toward the selected friendly rally/rear destination. No speed, armor or healing bonus.

### RESUPPLY
Execute the rendezvous/transfer intent defined above.

### STOP/CANCEL
Cancel the current intent and stop/return to local idle/hold semantics as appropriate.

The player chooses intent. Formation execution handles normal waypoint following, spacing, destination stopping, local bounded engagement and rendezvous positioning. Direct orders always override automation.

## 11. Pre-battle staging

Battle01 uses fixed-roster DEPLOYMENT/STAGING, not a purchase economy.

Before combat starts:
- the four active BLUE Formations may be placed inside a bounded West staging area;
- the player may assign one initial MOVE/ADVANCE/HOLD order per Formation;
- the player starts the battle explicitly;
- reserve choices remain locked until the bridgehead trigger.

This creates an opening plan without adding currency, production or deck systems.

## 12. Revised phase flow

1. STAGING — choose initial grouping and first intent.
2. OPENING RECON — discover RED posture and route exposure.
3. COMMITMENT — choose Central tempo, North information/ground-control or South maneuver/rear pressure.
4. FIRST CONTACT — role matching and information determine whether to reinforce, redirect or disengage.
5. BRIDGEHEAD — capture requires Infantry/IFV ground-control presence; Armor can contest/protect but cannot take ownership alone.
6. COUNTERATTACK — RED reinforcement/local response creates a second problem; player evaluates ammo, surviving capture capability and route.
7. PRESERVE / RESUPPLY / RESERVE — choose tempo versus combat-power preservation and choose Infantry versus Armor based on actual state.
8. INDUSTRIAL APPROACH — at least two route solutions remain viable depending on force/posture/logistics state.
9. FINAL CONTEST — both objectives still matter for Victory.
10. WIN / LOSS / RESTART.

## 13. Superseded design rules for next implementation

This contract supersedes the following DESIGN assumptions for subsequent implementation work:
- all combat formations capturing objectives;
- Armor capture capability;
- Recon capture capability;
- original ammo capacities Recon 40 / Infantry 36 / IFV 48 / Armor 24;
- no target-class effectiveness layer;
- RED Supply having no required ammunition-transfer behavior;
- explicit manual parking as the required player Supply interaction;
- fixed single RED home-anchor layout as the only pre-match defense posture;
- North/Central/South differing mainly by path length/LOS;
- Battle01 purchase implication instead of fixed-roster staging.

Existing runtime/code/docs that implement the old rules remain temporary runtime dependencies until the revised implementation replaces them. They must not be treated as the forward product authority.

## 14. Acceptance questions for the next runtime implementation

The revised rules are implemented correctly only if actual play can demonstrate:

1. at least two different RED postures require materially different opening reads;
2. Recon can discover useful information that cannot be safely assumed from memory;
3. Central, North and South create different costs/rewards in real movement and combat;
4. Infantry and Armor reserve are each the better choice in at least one reproducible game state;
5. at least one normal run creates a meaningful resupply decision, while at least one strong run can finish without mandatory supply;
6. destroying RED Supply materially reduces RED ability to recover ammunition;
7. player can order resupply without manual parking micro;
8. Armor can defend/contest but cannot capture ownership by itself;
9. player Formation workload remains commander-level rather than repeated path/parking correction;
10. the revised Battle01 still supports Victory, Defeat and Restart without adding unrelated systems.

## 15. Next gate

NEXT=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V2

Only after this revised contract survives V2 pressure testing may implementation of the revised gameplay rules be authorized. Full final-art production remains blocked until the revised runtime itself proves playable and the product gate is rechecked.
