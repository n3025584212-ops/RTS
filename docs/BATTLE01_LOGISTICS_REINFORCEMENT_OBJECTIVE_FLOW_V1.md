# BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_V1

TASK_ID=DESIGN_AND_FREEZE_BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_V1  
OWNER_WINDOW=WINDOW_05_RESOURCES_WAR  
STATUS=FROZEN_FOR_IMPLEMENTATION  
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
SOURCE_QA_GATE_COMMIT=ff4a7f3ef67a51ea8d589649ee145bb5854d4709  
NO_NEW_UNIT_TYPE=YES  
NO_LONG_TERM_ECONOMY=YES  
NO_TECH_TREE=YES  
NO_MORALE_SYSTEM=YES  
NO_FUEL_LOGISTICS=YES  
NO_COMPLEX_INVENTORY=YES  
NO_ENEMY_AI_CORE_REDESIGN=YES

## 0. Authority, intent, and scope

This document freezes the minimum Battle01 war-flow contract required to connect the already accepted Recon, Navigation, Combat, Enemy AI and Central Bridgehead work into a complete playable vertical slice.

It inherits and must be read with:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/BATTLE01_VERTICAL_SLICE_SPEC_V1.md`
- `docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md`
- `docs/audits/BATTLE01_ENEMY_AI_RUNTIME_QA_GATE_V1.md`
- the current Battle01 implementation at `SOURCE_QA_GATE_COMMIT`

This is a product-behavior contract. It does not prescribe a required Godot node architecture or concrete function names.

The intended player experience is:

Opening Recon / Maneuver  
-> First Contact  
-> Combined-Arms Fight  
-> Central Bridgehead  
-> Enemy Counterattack  
-> Loss / Ammo / Position Pressure  
-> Resupply / Withdraw / Reinforce Decision  
-> Final Push  
-> Win / Loss

The player must face at least one real decision between continuing pressure and preserving combat power.

## 1. Frozen upstream rules preserved

The following rules are not changed by this contract:

- existing deterministic Combat behavior and already-frozen combat values;
- existing Formation roles;
- existing Recon / FOW / LOS product rules;
- existing Navigation and route families;
- existing Enemy AI seven-state behavior, perception, pursuit, role logic and deterministic decision rules;
- RED reinforcement activation: earliest of `150.0s` from combat start or the first confirmed player capture/loss of Central Bridgehead;
- Supply Truck: `MAX_HP=120`, `CAN_ATTACK=FALSE`, `CAN_CAPTURE=FALSE`, `CHARGES=2`, `SUPPLY_DURATION=4.0s`;
- Objective ownership values: `NEUTRAL`, `PLAYER`, `AI`;
- `CONTESTED` is a state, not an ownership value;
- Infantry and Armor are capture-capable;
- Supply Truck is not capture-capable and does not contest;
- a complete objective ownership transfer requires `15.0s` continuous control.

This contract does not create mining, workers, a tech tree, strategic-map resources, fuel logistics, morale, repair parts, a persistent economy, new unit types or new weapon families.

## 2. Current implementation delta that the next implementation stage must close

At `SOURCE_QA_GATE_COMMIT`, the accepted repository still contains legacy walking-skeleton lifecycle pieces that are valid regression history but are not the final Battle01 war-flow contract:

- the current BLUE scene force is only `BLUE IFV-01` and `BLUE RECON-01`;
- the existing Supply definition exposes capacity/charges but there is no player supply-transfer behavior;
- the current Objective prototype uses legacy `NEUTRAL / CONTESTED / CAPTURING / CAPTURED` state semantics and a `3.0s` capture time;
- the current battle lifecycle can end in Victory immediately after Central Bridgehead capture;
- the current defeat path is still tied to the legacy primary BLUE formation death;
- no Final Industrial Objective currently exists as a formal match objective;
- no formal BLUE reserve/reinforcement flow currently exists.

These are implementation gaps to be closed by the next authorized implementation task. They are not reasons to change the already accepted Enemy AI core or redo Recon, Navigation or Combat.

## 3. Battle01 minimum player force

### 3.1 Active force at combat start

PLAYER_ACTIVE_FORMATION_COUNT=4

The minimum active BLUE force is:

1. `BLUE RECON-01` — preserve the current accepted Recon Formation.
2. `BLUE IFV-01` — preserve the current accepted maneuver/combat Formation.
3. `BLUE INF-01` — use the already-authorized Infantry definition; no new unit type.
4. `BLUE SUPPLY-01` — use the already-authorized Supply Truck / Logistics definition with two charges.

The addition of BLUE Infantry and BLUE Supply is necessary to complete the already-defined Battle01 combined-arms, objective and logistics loop. It is not a new unit family.

No new combat constants are defined here. Each Formation uses the currently frozen values for its existing definition.

### 3.2 Player reserve pool

PLAYER_RESERVE_POOL:

- `BLUE RESERVE INF-01` x1
- `BLUE RESERVE ARMOR-01` x1

PLAYER_RESERVE_COMMITMENTS=1

The player may deploy exactly one of these two reserve Formations during the match. Choosing one permanently makes the other unavailable for that Battle01 run.

There is no purchase currency, income tick, mining loop or long-term economy.

The cost is the irreversible use of the single pre-allocated reserve commitment.

This produces a concrete choice:

- Infantry is the faster-moving reinforcement for an urgent bridgehead stabilization problem.
- Armor is slower to arrive from the same friendly rear entry but brings the already-frozen heavy direct-fire role for the Final Push.

The design does not alter either Formation's movement or combat values to manufacture this difference.

## 4. SUPPLY CONTRACT

SUPPLY_RESOURCE=AMMO_ONLY  
SUPPLY_RANGE=140_WORLD_UNITS  
SUPPLY_DURATION=4.0s_CONTINUOUS  
SUPPLY_CHARGES_INITIAL=2  
SUPPLY_CHARGE_AMMO_RESTORE=50_PERCENT_OF_TARGET_MAX_AMMO  
HP_RESTORE=NO

### 4.1 Legal target selection

Supply is an explicit player command, not an automatic nearest-unit behavior.

To begin Supply, the player selects a living friendly Supply Truck and explicitly targets one living friendly Formation.

A legal target must:

- belong to the same faction;
- be alive;
- have `ammo_capacity > 0`;
- have `current_ammo < ammo_capacity`;
- not be a Supply Truck supplying another Supply Truck;
- be within Supply range when the transfer begins;
- be able to remain stationary for the transfer.

Only one target may be serviced by one Supply Truck at a time.

Invalid target attempts must be rejected with a readable player-facing reason rather than silently consuming a charge.

### 4.2 Start conditions

A Supply transfer may start only when all are true:

- Supply Truck is alive;
- target is alive;
- Supply Truck has at least one remaining charge;
- distance between truck and target is `<= 140` world units;
- both truck and target are stationary / not executing movement;
- target has an ammo deficit;
- neither side of the transfer is currently in an interrupted state from movement, damage or active firing.

The Supply Truck does not need to be inside a special base zone. Field resupply is allowed if the player accepts the tactical risk.

### 4.3 Four-second duration and interruption

The `4.0s` duration is continuous and non-cumulative.

Progress starts at zero and reaches completion only after four uninterrupted seconds.

Any of the following interrupts the transfer and resets progress to zero:

- truck begins moving or receives a movement/withdraw order;
- target begins moving or receives a movement/withdraw order;
- truck or target leaves the `140` world-unit range;
- truck takes damage;
- target takes damage;
- target fires a weapon;
- truck dies;
- target dies;
- target becomes full before completion for any legitimate external reason.

An interrupted transfer consumes no charge because no supply payload has completed.

The player may restart the transfer from zero when the start conditions are legal again.

This intentionally prevents a Supply Truck from functioning as a front-line infinite-ammo aura while formations remain actively fighting.

### 4.4 What one Charge restores

On successful completion of one uninterrupted transfer:

- consume exactly one Supply charge;
- restore ammo equal to `50%` of the target Formation's maximum ammo capacity, rounded by the implementation in a deterministic way;
- cap the result at the target's maximum ammo.

Examples of product behavior:

- an empty Formation may require both charges to return from 0% to 100%;
- two different depleted Formations may each receive one half-capacity refill;
- using a charge on a nearly full Formation may waste part of the potential refill.

This is intentional. The player is deciding how to allocate two finite battlefield supply actions.

### 4.5 Why Supply does not restore HP

HP_RESTORE=NO is frozen for Battle01.

HP represents accumulated combat attrition and damage that cannot be erased by a four-second ammunition transfer.

Allowing the truck to restore HP would make it a universal repair/reconstitution vehicle, weaken the meaning of casualties and encourage repetitive front-line healing loops.

Battle01 preservation therefore means:

- keep a damaged Formation alive;
- disengage it from lethal pressure;
- restore ammunition if useful;
- reuse the surviving Formation for reconnaissance, fire, screening, capture, contest or final support according to its existing role.

Damage remains meaningful for the rest of the match.

### 4.6 Zero-ammo behavior

A living Formation at `0` ammo:

- CAN_MOVE=YES
- CAN_CAPTURE=YES_IF_EXISTING_FORMATION_RULE_ALLOWS
- CAN_WITHDRAW=YES
- CAN_RECEIVE_SUPPLY=YES
- CAN_ATTACK=NO_UNTIL_AMMO_RESTORED

No morale, surrender or immobilization penalty is added for zero ammo.

### 4.7 Supply Truck destruction

If `BLUE SUPPLY-01` is destroyed:

- all remaining charges on that truck are permanently lost;
- any active transfer immediately fails;
- no automatic replacement truck appears;
- there is no base recharge or passive ammunition regeneration;
- the player must finish Battle01 using remaining Formation ammunition and any reserve Formation's starting ammunition.

Supply Truck destruction is not itself an immediate Defeat condition.

For RED, the existing Enemy AI Supply survival contract remains unchanged. This document does not require RED to begin automatic resupply behavior; a later Window 04 implementation may invoke the same transfer behavior only if explicitly needed without changing RED support/survival rules.

### 4.8 Player-visible Supply feedback

The implementation must make Supply state readable without requiring debug logs.

Minimum player-visible feedback:

- Supply Truck shows remaining charges, e.g. `2/2`, `1/2`, `0/2`;
- a legal target shows current/max ammo and the expected post-transfer ammo result;
- active transfer shows a visible world/HUD progress indicator from `0` to `4.0s`;
- active transfer visibly links or highlights truck and target;
- interruption immediately clears/reset progress and shows a concise reason such as movement, under fire, target fired or out of range;
- successful completion shows ammo increase and decremented charge count.

Exact widget layout, animation and wording are implementation/UI freedom.

## 5. WITHDRAW / PRESERVE COMBAT POWER

WITHDRAW_IS_TACTICAL_MOVEMENT=YES  
WITHDRAW_GRANTS_STAT_BONUS=NO  
WITHDRAW_HEALS=NO

### 5.1 Why a damaged Formation is worth preserving

A low-HP or low-ammo Formation is not disposable merely because it is weakened.

If it survives, it still preserves whichever existing capabilities remain valid:

- movement and route control;
- reconnaissance/detection if its role supports it;
- capture/contest capability if allowed by its Formation definition;
- remaining direct fire if it has ammunition;
- the ability to be resupplied and reintroduced;
- continued contribution to avoiding an irrecoverable force-collapse Defeat.

Because HP cannot be restored, preserving a damaged Formation is itself the reward.

### 5.2 Friendly rear rally

A fixed `WEST_REAR_RALLY` exists in the friendly rear area using the existing West topology.

It is:

- the default safe regroup destination;
- the player reinforcement entry area;
- a natural Supply rendezvous area;
- not an invulnerability zone;
- not a healing zone;
- not an ammo generator.

Its practical safety comes from battlefield distance, terrain and the already-frozen RED bounded pursuit behavior, not from artificial immunity.

### 5.3 Forward bridgehead rally

When Central Bridgehead is owned by PLAYER and is not CONTESTED, a `BRIDGEHEAD_FORWARD_RALLY` becomes active on the friendly/west shoulder of the bridgehead.

It is a rally/assembly destination only.

It does not:

- create Supply charges;
- restore HP;
- spawn reinforcements at the front;
- grant combat bonuses.

Its value is reduced turnaround distance between the front, the Supply Truck and a regrouping Formation.

If Central Bridgehead becomes CONTESTED or is lost, this forward rally is unavailable until PLAYER again owns the objective uncontested.

### 5.4 WITHDRAW / REVERSE command meaning

Battle01 does not need a new retreat simulation or morale state.

`WITHDRAW / REVERSE` is a player-issued movement intent toward a selected friendly rally/rear destination using the existing navigation topology.

Minimum semantic difference from a generic MOVE:

- it clearly labels the player's intent as disengagement/preservation;
- it cancels the current aggressive/capture movement intent;
- it prioritizes reaching the withdrawal destination rather than continuing an advance;
- it does not grant speed, armor, evasion or healing bonuses.

The implementation may represent this as a specialized existing movement order rather than a new movement system.

## 6. PLAYER RESERVE / REINFORCEMENT CONTRACT

### 6.1 Reserve locked state

At battle start:

- one Infantry reserve and one Armor reserve are visible in Reserve HUD as `LOCKED`;
- `PLAYER_RESERVE_COMMITMENTS=1` exists but cannot be spent before the bridgehead phase is reached;
- no reserve Formation is physically active on the battlefield.

### 6.2 Unlock condition

PLAYER_RESERVE_UNLOCK=FIRST_PLAYER_CAPTURE_OF_CENTRAL_BRIDGEHEAD

The first complete ownership transfer of Central Bridgehead to PLAYER permanently unlocks the one reserve commitment for that Battle01 run.

If Central Bridgehead is later lost, an unused already-unlocked reserve does not relock.

### 6.3 Player choice and cost

After unlock, the player may choose exactly one:

- deploy `BLUE RESERVE INF-01`; or
- deploy `BLUE RESERVE ARMOR-01`.

Deployment consumes the single reserve commitment immediately and permanently disables the other choice for that run.

There is no refund if the chosen reinforcement is later destroyed.

This is the Battle01 reserve economy. No currency layer is added.

### 6.4 Ground entry

The chosen reinforcement enters from a fixed `WEST_REAR_ENTRY` inside the friendly rear area.

It must never appear at Central Bridgehead or Industrial Objective.

After spawning, it is a normal player-controlled Formation using existing movement/navigation/combat rules and must physically travel to the fight.

This makes reinforcement timing and route selection visible and tactically relevant.

### 6.5 Reserve decision intent

The system should create this real choice after the bridgehead is taken and the RED counterattack begins:

- spend the reserve commitment immediately on faster Infantry to help stabilize the bridgehead;
- or preserve the commitment for Armor to strengthen the Final Industrial Push.

The contract does not force either answer to be correct in every run.

## 7. OBJECTIVE PROGRESSION

OBJECTIVE_COUNT=2

No third or fourth capture point is added.

### Objective A — Central Bridgehead

OBJECTIVE_ID=CENTRAL_BRIDGEHEAD  
ROLE=INTERMEDIATE_TACTICAL_OBJECTIVE  
INITIAL_OWNER=AI  
CAPTURE_TIME=15.0s  
CAPTURE_RADIUS=150_WORLD_UNITS

Central Bridgehead is not the final Victory objective.

It is the tactical hinge between the opening fight and the endgame.

### Objective B — Industrial Objective

OBJECTIVE_ID=INDUSTRIAL_OBJECTIVE  
ROLE=FINAL_DECISIVE_OBJECTIVE  
LOCATION=EAST_INDUSTRIAL_AREA_WITHIN_EXISTING_BATTLE01_TOPOLOGY  
INITIAL_OWNER=AI  
INITIAL_STATE=LOCKED_FOR_PLAYER_CAPTURE  
CAPTURE_TIME=15.0s  
CAPTURE_RADIUS=150_WORLD_UNITS

The exact node coordinate may be selected during implementation inside the existing East industrial walkable area. The map must not be expanded to place it.

## 8. Formal objective ownership / capture / contest behavior

### 8.1 Ownership and contested state

Each Objective stores ownership separately from contest state.

OWNER is exactly one of:

- `NEUTRAL`
- `PLAYER`
- `AI`

`CONTESTED` is a separate temporary state when eligible opposing capture-capable Formations are simultaneously present in the objective area.

Supply Trucks never contribute to capture or contest presence.

At minimum, the already-frozen Infantry and Armor roles remain capture-capable. This contract does not silently alter other already-existing Formation capture flags; implementation must preserve the current frozen Formation role contract while guaranteeing Infantry/Armor YES and Supply Truck NO.

### 8.2 Fifteen-second transfer

A full transfer to a different owner requires `15.0s` of continuous uncontested eligible presence by the capturing faction.

Capture progress:

- advances only while one non-owner faction has eligible capture presence and the other faction has no eligible contesting presence;
- resets to zero if the capturing faction leaves the radius;
- resets to zero if the objective becomes CONTESTED;
- resets to zero if the active capturing faction changes;
- never changes ownership until the full 15 seconds completes.

The current owner may remain `AI` or `PLAYER` while an opponent is partway through capture.

This replaces the legacy prototype assumption that killing one defender unlocks a short one-sided capture sequence.

## 9. CENTRAL BRIDGEHEAD tactical value

Central Bridgehead produces the minimum set of consequences needed to connect the war loop. It is not a score-only color change.

On the first completed transfer to PLAYER:

1. `INDUSTRIAL_OBJECTIVE` becomes permanently unlocked for player capture.
2. the player Reserve commitment becomes permanently available.
3. the already-frozen RED reinforcement rule is naturally triggered by objective loss/capture, creating the Counterattack phase.

While Central Bridgehead is currently owned by PLAYER and not CONTESTED:

4. `BRIDGEHEAD_FORWARD_RALLY` is active, reducing the practical regroup/resupply turnaround distance.

No additional resource income, combat buff, passive healing, teleport reinforcement or road-speed bonus is created.

This is the required real battlefield consequence of controlling the bridgehead.

## 10. Enemy Counterattack to recovery decision

The first PLAYER capture of Central Bridgehead is the deliberate Battle01 pressure hinge.

Because the frozen Enemy AI contract already activates RED reinforcements at objective loss, the expected phase is:

- player completes bridgehead capture;
- RED dormant Infantry/Armor activate under the existing one-shot rule;
- RED available defenders/counterattack reserve apply local pressure under the existing AI contract;
- the player's surviving force now has accumulated HP loss, ammo loss and positional exposure;
- player decides whether to continue east, hold, withdraw to a rally, spend Supply charges and/or commit the one BLUE reserve.

No new scripted damage, morale penalty or artificial resource drain is added to force the choice.

The choice must come from the real state generated by combat, ammunition, finite Supply, the counterattack and distance to the final objective.

## 11. FINAL INDUSTRIAL OBJECTIVE

### 11.1 Unlock and role

Industrial Objective is visible from battle start as the final mission destination but is not capturable until the first PLAYER capture of Central Bridgehead.

After unlock, it remains unlocked even if Central Bridgehead is later lost.

This avoids confusing re-lock behavior while preserving the requirement to re-secure the bridgehead for final Victory.

### 11.2 Capture and contest

Industrial Objective uses the same formal ownership, contest and continuous `15.0s` capture rules as Central Bridgehead.

Enemy Infantry/Armor may defend, contest or recapture it under their existing capability rules.

Supply Trucks do not contest it.

### 11.3 Enemy AI interface — no core redesign

This contract does not add a new Enemy AI state, perception model, pursuit rule, role or reinforcement trigger.

Window 04 may perform only the minimum objective-interface adaptation needed for Final Contest:

- after Industrial Objective is unlocked, its ownership/contest/capture-pressure events may be exposed to the existing objective-defense/final-contest behavior;
- RED may always know the state of an objective it is defending, just as the existing contract allows for Central Bridgehead;
- an available RED combat Formation may receive an existing MOVE/HOLD/ENGAGE/RETURN-style objective mission toward Industrial Objective when legitimate final-objective pressure exists;
- existing role priority, FOW-limited enemy knowledge, pursuit leash, deterministic target selection and Supply survival rules remain unchanged;
- the existing RED reinforcement activation and initial bridgehead-response contract remains unchanged;
- no RED unit may use Industrial Objective as a reason to home toward an unseen BLUE position.

The intent is to reuse existing objective-defense/final-contest capability, not redesign Enemy AI.

## 12. Victory contract

VICTORY requires all of the following simultaneously:

- Central Bridgehead `OWNER=PLAYER`;
- Central Bridgehead `CONTESTED=NO`;
- Industrial Objective `OWNER=PLAYER`;
- Industrial Objective `CONTESTED=NO`.

Destroying all RED units is not required for Victory.

Capturing Central Bridgehead alone never ends the match.

Capturing Industrial Objective while the bridgehead has been lost does not end the match until the player also restores uncontested PLAYER control of Central Bridgehead.

On Victory, normal match-end lifecycle stops further tactical orders/AI activity and exposes Restart through the existing product lifecycle.

## 13. Defeat contract

Battle01 must have a real, reproducible Defeat state without score arithmetic or a complex failure system.

DEFEAT occurs when both are true:

1. there is no living BLUE Formation, excluding Supply-only logistics, that can still materially progress the mission through existing attack or capture capability; and
2. there is no legally deployable unused BLUE reserve Formation remaining.

Practical consequences:

- a surviving Supply Truck alone does not prevent Defeat;
- a living low-HP combat/capture Formation does prevent Defeat because preserving it still matters;
- a zero-ammo Formation that still has valid capture capability is not automatically defeated;
- if a usable Supply Truck can restore ammo to a surviving combat Formation, the mission remains recoverable;
- if the reserve has unlocked and remains unused, the match remains recoverable until that reserve opportunity is exhausted or no longer capable of producing a mission-capable Formation;
- losing Central Bridgehead is not itself Defeat;
- losing the Supply Truck is not itself Defeat;
- there is no arbitrary mission timer Defeat in this contract.

The implementation must determine this from actual Formation state and reserve availability, not from the legacy `BLUE IFV-01 died` shortcut.

## 14. Player decisions created by system state

### Decision A — continue pressure vs withdraw and resupply

SYSTEM STATE:
- surviving formation has HP/ammo attrition;
- RED counterattack/reinforcements are active;
- Supply charges are finite and require four uninterrupted seconds.

CHOICE:
- continue east immediately to exploit tempo;
- or withdraw to Bridgehead/West rally, spend time and possibly Supply charges, then re-enter.

TRADEOFF:
- tempo and positional opportunity versus preserved combat power and ammunition.

### Decision B — reserve Infantry now vs reserve Armor for Final Push

SYSTEM STATE:
- bridgehead capture unlocks one irreversible reserve commitment;
- exactly one of reserve Infantry/Armor can be deployed;
- reinforcement must physically travel from West rear using its frozen movement speed.

CHOICE:
- faster Infantry for urgent stabilization;
- or heavier Armor for the later decisive assault.

TRADEOFF:
- immediate bridgehead security versus stronger final offensive power.

### Decision C — concentrate Supply vs distribute Supply

SYSTEM STATE:
- exactly two charges;
- one charge restores only 50% of target maximum ammo.

CHOICE:
- spend both charges to fully recover one empty/high-value Formation;
- or distribute one charge each across two depleted Formations.

TRADEOFF:
- depth in one Formation versus breadth across the force.

### Decision D — direct Industrial push vs North/South maneuver

SYSTEM STATE:
- Industrial Objective is east;
- current Central/North/South navigation remains connected;
- RED FOW-limited reaction and local role allocation remain frozen;
- Supply Truck is vulnerable and rear support matters.

CHOICE:
- direct central/east pressure with shortest turnaround;
- or use North/South maneuver to shift defenders, threaten support or approach the final objective from a different angle.

TRADEOFF:
- speed and concentration versus positional advantage and logistics exposure.

These decisions are caused by live battlefield state, not dialogue text or scripted choice menus.

## 15. Battle01 phase contract

These are product phases, not required code-state names.

### PHASE 1 — Opening Recon / Maneuver

- Active BLUE force enters from West.
- Central Bridgehead is AI-owned and active.
- Industrial Objective is visible but locked.
- Player Reserve is visible but locked.
- Player reads Central/North/South approach and enemy disposition.

### PHASE 2 — First Contact / Combined-Arms Fight

- existing Combat, Recon and Enemy AI produce the opening engagement;
- finite ammo begins to matter;
- player maneuvers toward Central Bridgehead.

### PHASE 3 — Central Bridgehead capture

- player contests/captures under formal 15s rules;
- first PLAYER ownership unlocks Industrial Objective, player Reserve and Bridgehead Forward Rally;
- frozen RED reinforcement trigger activates.

### PHASE 4 — Counterattack / Preserve Combat Power

- RED applies its existing local counterattack/reinforcement behavior;
- player evaluates HP, ammo, Supply charges, reserve timing and position;
- player may hold, withdraw, resupply and/or reinforce.

### PHASE 5 — Final Push

- player advances to the East Industrial Objective through the existing connected route topology;
- surviving RED defenders use the minimum existing final-objective interface to contest;
- bridgehead ownership remains strategically relevant because Victory requires both objectives.

### PHASE 6 — Win / Loss

- Victory on simultaneous uncontested PLAYER ownership of both objectives;
- Defeat on irrecoverable BLUE combat/capture force collapse with no usable reserve;
- Restart remains available after match end.

## 16. IMPLEMENTATION_FREEDOM

Within this frozen behavior contract, Window 02 / Window 03 / Window 05 / Codex may choose implementation details including:

- Node structure and ownership;
- signals and event routing;
- timers and update loops;
- Typed GDScript organization;
- helper classes/resources;
- supply-progress storage;
- deterministic rounding for the 50% ammo refill;
- reserve-state storage and spawn helper organization;
- objective ownership/contest linkage;
- rally-anchor representation;
- final-objective scene placement inside the existing East topology;
- UI event interfaces and feedback presentation;
- QA telemetry and focused test hooks;
- initialization ordering;
- safe local path-arrival/numerical tolerances;
- how match-end queries gather Formation/reserve state.

Implementation freedom may not be used to:

- alter frozen Combat values;
- add new unit types;
- add money income, mining, workers, tech trees or a persistent economy;
- add morale, suppression, armor penetration, fuel or repair-parts simulation;
- make Supply restore HP;
- give Supply more than two charges without a new design freeze;
- make Supply an automatic aura;
- teleport player reinforcements to the front;
- add new map regions or route families;
- change the frozen RED AI knowledge/pursuit/role/reinforcement core;
- make Central Bridgehead an instant Victory condition;
- change the 15s complete objective transfer rule;
- remove a real Defeat state.

The implementation owner should implement the simplest coherent architecture that produces the frozen observable behavior.

## 17. ACCEPTANCE_CONTRACT

Acceptance must be judged from player-visible runtime behavior. Internal assertions/telemetry may support the result but cannot replace the visible scenario where player experience is material.

### A. Supply succeeds

SCENARIO:
- Move BLUE SUPPLY-01 within 140 world units of a depleted living friendly Formation.
- Keep both stationary and out of active fire for four continuous seconds.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Supply progress visibly reaches four seconds.
- one charge is consumed on completion.
- target ammo visibly increases by 50% of its maximum capacity, capped at max.
- HP does not increase.

### B. Supply is interrupted by movement

SCENARIO:
- Begin Supply, then move either the truck or target before four seconds completes.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Supply progress immediately resets/cancels.
- no ammo is transferred.
- no charge is consumed.
- player receives clear interruption feedback.

### C. Charges are consumed correctly

SCENARIO:
- Complete two valid Supply transfers from a fresh BLUE SUPPLY-01.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- charge display changes `2/2 -> 1/2 -> 0/2` only on successful completions.
- a third Supply attempt is rejected as no charges remaining.
- interrupted attempts do not consume charges.

### D. Ammo is genuinely restored

SCENARIO:
- Deplete a combat Formation to low/zero ammo, record its visible ammo, then complete Supply.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- the actual combat ammo count increases by the frozen refill amount.
- the Formation can resume firing only because real ammo was restored, not because of a UI-only number.

### E. Supply Truck is destroyed

SCENARIO:
- Destroy BLUE SUPPLY-01 while it still has at least one charge, including a case during active Supply.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- active Supply cancels.
- remaining charges disappear with the truck.
- no replacement or passive ammo regeneration appears.
- the battle continues unless the general Defeat contract is also met.

### F. Low-resource Formation withdraws and returns

SCENARIO:
- Put a surviving combat/capture Formation at low HP and low ammo after the bridgehead fight.
- use WITHDRAW toward Bridgehead Forward Rally or West Rear Rally.
- resupply it if Supply is available, then return it to the fight.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Formation physically disengages using existing navigation.
- HP remains damaged.
- ammo can be restored through the finite Supply contract.
- the same surviving Formation can later re-enter and contribute again.

### G. Player Reserve is committed

SCENARIO:
- capture Central Bridgehead for the first time, then choose one of the two Reserve options.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Reserve becomes available only after the objective trigger.
- chosen Infantry or Armor appears at West Rear Entry and physically travels forward.
- exactly one reserve commitment is consumed.
- the unchosen reserve option becomes permanently unavailable for that run.
- no unit appears at the front line by teleportation.

### H. Bridgehead control changes the battle phase

SCENARIO:
- complete the first PLAYER capture of Central Bridgehead.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Central Bridgehead does not end the match.
- Industrial Objective becomes capturable.
- BLUE Reserve becomes available.
- Bridgehead Forward Rally becomes active while the point is PLAYER-owned and uncontested.
- frozen RED reinforcement/counterattack activation occurs through the already-accepted AI rule.

### I. Counterattack creates recovery/continue choice

SCENARIO:
- reach first bridgehead capture with at least one BLUE Formation damaged or ammo-depleted and allow the RED counterattack/reinforcement pressure to develop.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- the player can either continue east under current attrition or disengage/regroup/resupply/reinforce.
- no scripted modal forces a single answer.
- both actions are supported by actual game systems and position.

### J. Final Industrial Objective unlocks

SCENARIO:
- before Central Bridgehead capture, attempt to capture Industrial Objective; then capture Central Bridgehead and return to Industrial Objective.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Industrial Objective is visible but cannot transfer ownership before unlock.
- after first Bridgehead PLAYER ownership, Industrial Objective remains permanently unlocked for the run.
- its capture uses the same 15s formal rule.

### K. Final Objective contest

SCENARIO:
- begin PLAYER capture of Industrial Objective while a capture-capable RED Formation enters the objective radius.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- objective becomes CONTESTED without changing the owner immediately.
- capture progress resets under the frozen continuous-control rule.
- Supply Trucks do not create contest.
- RED response obeys existing AI knowledge/role/pursuit behavior rather than tracking hidden BLUE positions.

### L. Victory

SCENARIO:
- obtain uncontested PLAYER ownership of both Central Bridgehead and Industrial Objective in the same match.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Victory triggers only when both objectives are PLAYER-owned and uncontested.
- Central Bridgehead capture alone never produces Victory.
- match-end state stops normal tactical progression and exposes Restart.

### M. Defeat

SCENARIO:
- destroy/remove every BLUE non-logistics Formation that can still materially attack or capture, and exhaust or make unavailable the player Reserve.

EXPECTED_PLAYER_VISIBLE_BEHAVIOR:
- Defeat triggers while a surviving Supply Truck alone cannot keep the mission alive.
- no kill-score arithmetic or arbitrary timer is required.
- a surviving mission-capable Formation or usable undeployed reserve prevents premature Defeat.
- match-end state exposes Restart.

## 18. Product correctness judgment

PRODUCT_FLOW_TARGET:

Recon  
-> Route Choice  
-> Contact  
-> Combat Loss/Ammo Expenditure  
-> Central Bridgehead Capture  
-> Enemy Counterattack  
-> Logistics/Withdraw/Reserve Decision  
-> Reorganization  
-> Final Industrial Push  
-> Victory/Defeat

PRODUCT_CORRECTNESS_INTENT=PASS_IF_RUNTIME_PROVES_THIS_FLOW

Each included rule has a direct product purpose:

- two Supply charges make ammunition a finite tactical resource without building an economy;
- no HP restoration keeps combat attrition meaningful;
- withdrawal preserves surviving capability instead of creating a healing minigame;
- one irreversible Reserve commitment creates a real timing/composition decision;
- Central Bridgehead unlocks the final phase and shortens regroup distance rather than acting as a color-only point;
- exactly one Final Industrial Objective gives the battle an endgame without objective spam;
- objective-based Victory and force-collapse Defeat allow both required final outcomes;
- no new strategic layer is introduced.

If implementation adds a mechanic that does not strengthen this loop, it should be removed rather than retained for system count.

## 19. Freeze result

SUPPLY_CONTRACT_DEFINED=YES  
WITHDRAW_PRESERVE_DEFINED=YES  
PLAYER_RESERVE_DEFINED=YES  
REINFORCEMENT_DEFINED=YES  
BRIDGEHEAD_VALUE_DEFINED=YES  
FINAL_OBJECTIVE_DEFINED=YES  
VICTORY_DEFINED=YES  
DEFEAT_DEFINED=YES  
PLAYER_DECISIONS_DEFINED=YES  
IMPLEMENTATION_FREEDOM_DEFINED=YES  
ACCEPTANCE_CONTRACT_DEFINED=YES  
READY_FOR_IMPLEMENTATION=YES  
BLOCKER=NONE
