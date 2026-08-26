# BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_CONTRACT_V1

TASK_ID=RESOLVE_BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_BLOCKER_V1  
OWNER_WINDOW=WINDOW_01_GAME_DESIGN  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
STATUS=FROZEN

START_MAIN_SHA=179d1e4bee2f7e15add5bd68e15403c15693a990

BLOCKER_ID=PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION

## 0. Authority and scope

This contract resolves exactly one integrated Battle01 progression blocker discovered by real Godot 4.7.1 player-flow evidence.

It inherits and preserves except where explicitly narrowed below:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md`
- `docs/BATTLE01_FORMATION_RULES_V2.md`
- `docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md`
- `docs/BATTLE01_PRE_BATTLE_STAGING_CONTRACT_V1.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V2.md`
- `docs/audits/BATTLE01_INTEGRATED_PLAYER_FLOW_RUNTIME_EVIDENCE_V1.md`

This is not a global rebalance and not a redesign of Battle01.

NO_NEW_UNIT=YES  
NO_NEW_WEAPON=YES  
NO_NEW_SKILL=YES  
NO_NEW_ROUTE=YES  
NO_NEW_ECONOMY=YES  
NO_NEW_OBJECTIVE=YES  
NO_SCOPE_EXPANSION=YES

## 1. Blocker confirmation

BLOCKER_CONFIRMED=YES

The integrated Run A evidence demonstrates that a normal Formation-level plan can:

- use real PRE-BATTLE STAGING;
- use MOVE and ADVANCE correctly;
- preserve Recon/FOW legality;
- use formation-aware movement;
- clear both initial RED Infantry;
- pressure RED logistics;
- preserve multiple living BLUE Formations;

and still fail before the first mandatory Central progression hinge.

The critical integrated state proves the issue is not a parser/runtime failure and not merely a single weak test script tactic. The surviving RED Armor is pulled into the first Central capture chain before the player has earned Reserve access, and can contest/kill the capture-capable BLUE required to unlock the next phase.

ROOT_CAUSE_CLASS=BATTLE_PHASE_ORDER_MISMATCH_PREMATURE_RED_ARMOR_OBJECTIVE_COMMITMENT

The current product arc says:

`CENTRAL COMMITMENT -> FIRST PLAYER CENTRAL CAPTURE -> RESERVE UNLOCK -> RED COUNTERATTACK PRESSURE`

but the current AI interaction produces:

`CENTRAL COMMITMENT -> RED ARMOR FULL OBJECTIVE DENIAL -> PLAYER RESERVE STILL LOCKED -> PROGRESSION COLLAPSE`

This is a phase-order contract mismatch.

## 2. Core design judgment

IS_RED_ARMOR_INTENDED_TO_BE_A_PRE_CAPTURE_CENTRAL_DENIAL_UNIT=NO

RED ARMOR-01 is intended to be:

- visible/credible heavy battlefield threat;
- local reserve firepower;
- breakthrough blocker;
- rear/support security responder when legitimately threatened;
- post-Central counterattack pressure.

It is **not** intended to function as a mandatory pre-Reserve Central ownership lock that the starting BLUE force must destroy before it can earn the Reserve that was specifically designed to answer the next escalation phase.

The first Central hinge should test whether the player can:

- read the defense;
- deal with the initial Infantry screen;
- choose a route/commitment;
- preserve a capture-capable Formation;
- create enough local space to establish the bridgehead.

The first Central hinge should not require destroying the full-health heavy reserve under the same no-Reserve condition unless the player voluntarily chooses to attack/penetrate that reserve early.

## 3. Candidate option evaluation

### OPTION A — RED ARMOR PRE-CENTRAL COMMITMENT

EVALUATION=BEST_FIT

Strengths:

- directly repairs the observed phase-order error;
- preserves all Formation values;
- preserves the damage matrix;
- preserves the 15-second Central capture rule;
- preserves Reserve unlock as a reward for first Central capture;
- preserves RED Armor as a meaningful heavy threat;
- strengthens the intended `capture -> counterattack -> Reserve/sustain decision` tempo;
- requires only a narrow Enemy AI behavior revision.

Risk:

- must not make RED Armor an inert target before Central capture;
- must prevent the player from freely deleting Armor without risk;
- requires exact pre/post first-capture commitment semantics.

Conclusion:

`SELECTED`.

### OPTION B — CENTRAL FIRST-CAPTURE RULE

EVALUATION=REJECTED

A shorter first capture would create a special-case capture timer while leaving the actual phase-order problem intact: RED Armor would still be treated as an objective-emergency responder before the player has earned the bridgehead.

It would also weaken the currently clear and readable 15-second ownership rule and could remain brittle if Armor contests immediately enough.

CAPTURE_DURATION_EXCEPTION_NOT_JUSTIFIED=YES

### OPTION C — RESERVE UNLOCK TIMING

EVALUATION=REJECTED

Unlocking Reserve before first Central capture would allow the player to solve the blocker with additional combat power, but would invert the intended reward structure.

Central is supposed to be the achievement that unlocks the irreversible Infantry-or-Armor Reserve decision and Industrial progression. Moving Reserve earlier would reduce the strategic meaning of that hinge and make first-Central planning less important.

RESERVE_REWARD_IDENTITY_PRESERVED_BY_REJECTING_C=YES

### OPTION D — ANTI-HEAVY / SURVIVABILITY

EVALUATION=REJECTED

Changing IFV/Infantry anti-heavy output, RED Armor HP/damage, or the damage matrix would affect:

- pre-Central combat;
- post-Central counterattack;
- Industrial combat;
- Reserve Armor relative value;
- ammunition pressure;
- future balance interpretation.

The integrated failure is primarily phase timing, not evidence that the heavy-unit combat model is globally invalid.

GLOBAL_COMBAT_REBALANCE_NOT_JUSTIFIED=YES

## 4. Primary fix

PRIMARY_FIX_OPTION=A

PRIMARY_FIX_SUMMARY=FREEZE_A_PRE_FIRST_PLAYER_CENTRAL_CAPTURE_COMMITMENT_GATE_FOR_RED_ARMOR_01_SO_IT_REMAINS_A_LOCAL_RESERVE_AND_SELF_DEFENSE_THREAT_BUT_DOES_NOT_ENTER_OR_ENFORCE_CENTRAL_OBJECTIVE_DENIAL_UNTIL_THE_FIRST_PLAYER_CENTRAL_CAPTURE_COMPLETES

No supporting B/C/D adjustment is authorized.

SUPPORTING_ADJUSTMENT=NONE

## 5. Phase flag

The behavior distinction is based on one product phase boundary:

`PRE_FIRST_PLAYER_CENTRAL_CAPTURE`

remains true until the first real:

`CentralBridgehead.capture_completed(new_owner=PLAYER)`

After that event:

`POST_FIRST_PLAYER_CENTRAL_CAPTURE=YES`

This is a gameplay phase condition, not a new strategic system.

The implementation may store this as a boolean or derive it from existing war-flow/objective state.

## 6. PRE_FIRST_CENTRAL_ARMOR_BEHAVIOR

PRE_FIRST_CENTRAL_ARMOR_BEHAVIOR=HOLD_LOCAL_RESERVE_WITH_BOUNDED_SELF_DEFENSE_AND_REAR_SECURITY_NO_CENTRAL_OBJECTIVE_DENIAL

While `PRE_FIRST_PLAYER_CENTRAL_CAPTURE=YES`, RED ARMOR-01 obeys all of the following.

### 6.1 Allowed behavior

RED Armor may:

1. `HOLD` at its current seeded-posture Armor reserve anchor.
2. Observe BLUE only through the existing legal RED FOW/intel model.
3. `ENGAGE_CONFIRMED` a legitimate BLUE threat when that threat is outside the Central objective core and the engagement is justified by local reserve/self-defense behavior.
4. Return fire against a BLUE Formation that directly attacks RED Armor, including if the attacker is attempting to provoke the reserve deliberately.
5. Respond to a legitimate CONFIRMED threat against RED Supply/rear security when no new hidden information is used.
6. Use existing bounded pursuit / LAST_KNOWN / RETURN rules for those legal non-Central engagements.
7. Be detected, targeted, damaged, destroyed, bypassed or deliberately attacked by the player normally.

Armor remains a real battlefield object and real threat before Central capture.

### 6.2 Forbidden pre-first-Central behavior

While `PRE_FIRST_PLAYER_CENTRAL_CAPTURE=YES`, the following do **not** authorize RED Armor commitment:

- Central entering `CAPTURING`;
- Central entering `CONTESTED`;
- a capture-capable BLUE Formation merely being inside Central capture radius;
- RED Infantry being engaged;
- RED Infantry being destroyed;
- a CONFIRMED BLUE Formation merely being inside the broad Central `DEFENSE_RADIUS`;
- Central capture progress increasing;
- the AI target-priority rule that normally assigns priority 1 to a capture-capable BLUE Formation inside Central.

Therefore, before the first PLAYER Central capture:

`CENTRAL_OBJECTIVE_EMERGENCY_DOES_NOT_OVERRIDE_RED_ARMOR_PRECAPTURE_COMMITMENT_GATE=YES`

and:

`RED_ARMOR_MOVE_TO_CENTRAL_OBJECTIVE_CORE=NO`

`RED_ARMOR_OBJECTIVE_CONTEST_MISSION=NO`

`RED_ARMOR_AUTO_TARGET_CAPTURE_CAPABLE_BLUE_IN_CENTRAL=NO`

### 6.3 Direct self-defense exception

The fix must not create a free Armor kill exploit.

If a BLUE Formation directly attacks RED Armor before first Central capture, RED Armor may legally return fire against that confirmed attacker under normal range/LOS/ammo rules.

However:

- this self-defense exception does not convert Central capture progress into a general objective emergency;
- RED Armor does not path into the Central objective core solely to contest ownership;
- RED Armor does not switch from the actual attacker to an unrelated capture-capable BLUE inside Central merely because that unit is capturing;
- if the attacker disengages beyond normal pursuit rules, Armor returns to its seeded reserve anchor.

This preserves player agency:

- the player may secure Central first and face the reserve as a counterattack;
- or the player may deliberately attack the heavy reserve early and accept the combat risk.

## 7. First Central capture rule

FIRST_CENTRAL_CAPTURE_RULE=UNCHANGED_15_SECONDS_CONTINUOUS_UNCONTESTED_CAPTURE_CAPABLE_BLUE_PRESENCE

CAPTURE_DURATION_CHANGED=NO

The Central Bridgehead remains governed by the current objective contract:

- Infantry and IFV can capture;
- Armor may contest once its post-capture mission is active;
- Recon/Logistics cannot capture or contest;
- ownership transfer duration remains 15.0 seconds;
- no first-capture exception is added.

The progression fix comes from enemy commitment timing, not from reducing the capture requirement.

## 8. Reserve unlock rule

RESERVE_UNLOCK_TRIGGER=FIRST_COMPLETED_PLAYER_CAPTURE_OF_CENTRAL_BRIDGEHEAD

RESERVE_TRIGGER_CHANGED=NO

The one irreversible:

`Infantry OR Armor`

Reserve choice remains locked until the first successful PLAYER Central capture.

Central continues to function as the strategic reward hinge.

## 9. POST_FIRST_CENTRAL_ARMOR_BEHAVIOR

POST_FIRST_CENTRAL_ARMOR_BEHAVIOR=RESTORE_FULL_EXISTING_LOCAL_COUNTERATTACK_RESERVE_AND_OBJECTIVE_EMERGENCY_BEHAVIOR

At the exact first real:

`CentralBridgehead.capture_completed(new_owner=PLAYER)`

RED Armor's pre-capture commitment gate ends permanently for that Battle01 run.

From the next normal AI decision opportunity, RED ARMOR-01 may again use the existing Battle01 Enemy AI V2 behavior, including:

- Central objective emergency response;
- objective-priority target selection;
- movement toward Central;
- entering/contesting Central objective core;
- bounded engagement of legitimate CONFIRMED targets;
- local counterattack behavior;
- RETURN after the local threat/mission resolves.

No post-capture grace period is introduced.

The existing AI decision cadence remains authoritative.

## 10. Counterattack timing

COUNTERATTACK_TIMING=IMMEDIATELY_AFTER_FIRST_PLAYER_CENTRAL_CAPTURE_ON_NEXT_NORMAL_AI_DECISION_BOUNDARY

The first PLAYER Central capture is the intended escalation boundary.

At that same progression hinge, existing downstream systems remain free to do what they already do:

- PLAYER Reserve unlocks;
- Industrial capture unlocks;
- RED objective-loss response becomes valid;
- existing dormant RED reinforcement trigger behavior remains unchanged;
- RED Armor becomes full objective counterattack pressure.

This deliberately creates the intended sequence:

`SECURE BRIDGEHEAD -> BOTH SIDES GAIN NEW OPTIONS/PRESSURE -> PLAYER MUST REASSESS`

## 11. Enemy AI contract revision scope

ENEMY_AI_CONTRACT_CHANGED=YES_NARROW_PRE_FIRST_CENTRAL_ARMOR_COMMITMENT_ONLY

This contract supersedes only the portions of `BATTLE01_ENEMY_AI_CONTRACT_V2` that currently allow RED ARMOR-01 to become a Central objective-emergency responder before the first PLAYER Central capture.

Specifically, for RED ARMOR-01 only and only during `PRE_FIRST_PLAYER_CENTRAL_CAPTURE`:

- `Central Bridgehead is under active player capture/contest` is NOT a valid Armor commit condition;
- `an infantry defender is engaged/destroyed + BLUE inside Central defense area` is NOT by itself a valid Armor commit condition;
- Central objective priority does NOT bypass the pre-capture Armor commitment gate.

After first PLAYER Central capture, the original V2 Armor-role/objective-emergency semantics resume.

Unchanged AI areas include:

- RED FOW / information restrictions;
- CONTACT / CONFIRMED / LAST_KNOWN;
- pursuit leash;
- investigation timeout;
- deterministic target tie-breaking;
- Infantry roles;
- Supply behavior;
- route selection;
- seeded posture anchors;
- final Industrial objective behavior;
- no-randomness requirement.

## 12. Formation / combat preservation

FORMATION_VALUES_CHANGED=NO  
DAMAGE_MATRIX_CHANGED=NO

No HP, damage, range, fire interval, ammo, movement speed, detection, capture/contest capability or role multiplier changes are authorized.

RED Armor remains:

- 280 HP;
- 45 base damage;
- 300 range;
- 1.50s fire interval;
- 16 ammo;
- HEAVY_ARMOR;
- contest-capable;
- not capture-capable.

The starting BLUE anti-heavy relation is not changed by this fix.

## 13. Other frozen systems preservation

STAGING_CHANGED=NO  
ROUTE_GEOMETRY_CHANGED=NO  
SEEDED_POSTURE_GEOMETRY_CHANGED=NO  
FOW_RULE_CHANGED=NO  
MOVE_RULE_CHANGED=NO  
ADVANCE_RULE_CHANGED=NO  
HOLD_FIRE_RULE_CHANGED=NO  
SUPPLY_RULE_CHANGED=NO  
INDUSTRIAL_FLOW_CHANGED=NO  
VICTORY_DEFEAT_DEFINITION_CHANGED=NO

Only the selected pre-first-Central RED Armor commitment semantic is revised.

## 14. Expected player flow after fix

PLAYER_EXPECTED_FLOW=

1. `RECON / CONTACT`
   - player uses Recon and route geometry to identify the actual seeded RED posture and initial Infantry screen.

2. `CLEAR / SUPPRESS INITIAL INFANTRY SCREEN`
   - IFV supplies primary mobile fire support;
   - Infantry preserves ground-control value;
   - Recon continues information work;
   - player may maneuver rather than frontal-rush.

3. `CENTRAL COMMITMENT`
   - surviving Infantry and/or IFV commits to the Bridgehead;
   - RED Armor remains a visible reserve/rear threat but does not automatically convert capture progress into pre-Reserve objective denial.

4. `SECURE CENTRAL WITH FORMATION-LEVEL COMBINED ARMS`
   - capture-capable BLUE holds the objective for the unchanged 15 seconds;
   - other BLUE Formations screen, observe, reposition, preserve combat power or prepare sustain;
   - player is not required to perform frame-perfect tank kiting or repeated aggro exploits.

5. `FIRST PLAYER CENTRAL CAPTURE`
   - Central ownership transfers normally.

6. `RESERVE / INDUSTRIAL UNLOCK`
   - the existing irreversible Infantry-or-Armor Reserve decision becomes available;
   - Industrial progression unlocks.

7. `RED ARMOR / REINFORCEMENT COUNTERATTACK PRESSURE`
   - RED Armor's full objective-emergency logic activates;
   - existing RED reinforcement logic may activate according to its unchanged trigger;
   - the player must now decide how to preserve, resupply and commit Reserve.

8. `RESUPPLY / PRESERVE / RESERVE DECISION -> INDUSTRIAL`
   - later Battle01 flow continues under existing contracts.

## 15. Commander fantasy rationale

COMMANDER_FANTASY_RESTORED_BY_DESIGN=YES

The intended solution to first Central should now be a Formation-level plan:

- scout;
- identify the Infantry screen;
- choose route/angle;
- use IFV fire support;
- preserve Infantry/IFV capture capability;
- commit to the bridgehead;
- prepare for the visible escalation after capture.

The intended solution is not:

- one-second IFV stutter-step loops;
- repeated Recon/Supply aggro abuse;
- frame-perfect capture-circle dancing;
- exploiting target-selection bugs;
- destroying RED Armor as a mandatory prerequisite before earning Reserve.

## 16. Combined-arms rationale

The first phase retains distinct roles:

- Recon = information / posture read;
- IFV = mobile direct-fire support and protection of the commitment;
- Infantry = ground-control/capture redundancy;
- Logistics = sustain preparation, not a front-line combat solution.

RED Armor remains tactically relevant because:

- it can still defend itself if attacked early;
- it can still answer legitimate rear/supply penetration;
- its posture location is still meaningful Recon information;
- after Central flips, it immediately becomes a major counterattack pressure source.

## 17. Failure possibility remains

PLAYER_AUTOWIN=NO

The fix does not guarantee first Central or match victory.

The player may still fail because of:

- poor Recon use;
- bad route commitment;
- excessive losses against the Infantry screen;
- voluntarily attacking RED Armor early and losing the exchange;
- losing all capture-capable BLUE before Central completion;
- poor Supply use;
- bad Reserve choice;
- failed post-Central counterattack response;
- failed Industrial push.

The contract removes a structural progression lock, not meaningful defeat.

## 18. QA acceptance contract

The implementation owner must not close this task with focused AI smoke alone.

The same integrated evidence harness must be rerun:

`tests/battle01_integrated_player_flow_evidence.gd`

The first required proof is the exact originally blocked normal-session Run A.

### 18.1 Run A minimum gate

Required:

RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_CENTRAL_CAPTURE=PASS  
RUN_A_RESERVE_UNLOCK=PASS  
RUN_A_RESERVE_ARMOR_COMMIT=PASS  
RUN_A_COUNTERATTACK_REACHED=PASS

Forbidden shortcuts remain:

NO_FORCE_OBJECTIVE=YES  
NO_FORCE_DAMAGE=YES  
NO_SEED_OVERRIDE=YES  
NO_TIME_SCALE=YES  
REAL_VIEWPORT_INPUT=YES

Run A must cross the original blocker with legal player-facing commands and normal progression.

The runner does not need to demonstrate perfect play, but it must not require frame-perfect kiting or exploit-specific command spam.

### 18.2 Armor pre-capture behavior proof

Runtime evidence must establish that before first PLAYER Central capture:

- RED Armor remains alive/active and can legally engage when attacked or legitimately rear-threatened;
- RED Armor does not move into Central merely because state becomes CAPTURING/CONTESTED;
- RED Armor does not automatically target unrelated capture-capable BLUE solely for being in Central;
- RED Armor does not contest Central before the first PLAYER capture under the normal capture plan;
- seeded Armor posture remains unchanged.

### 18.3 Post-capture counterattack proof

Runtime evidence must then establish that immediately after first PLAYER Central capture:

- the pre-capture gate is removed;
- RED Armor can move/respond toward Central under existing objective emergency rules;
- RED Armor can legally contest the objective;
- the player Reserve is simultaneously unlocked under the unchanged rule;
- post-capture pressure remains materially threatening.

### 18.4 Continue integrated gate only after Run A crosses blocker

Only after the above Run A fields pass should the integrated evidence proceed to:

- RUN B;
- RUN C;
- A -> B -> C -> A sequence validation;
- dedicated Defeat Control;
- full vertical-slice player-flow judgment.

Focused regressions should additionally cover the directly affected Enemy AI behavior and relevant existing systems, but focused PASS may not substitute for integrated Run A.

## 19. Implementation freedom

Window 04 may decide the engineering mechanism used to represent the phase gate, including:

- boolean storage;
- querying existing PlayerWarFlow state;
- reacting to Central capture signals;
- helper functions;
- target-filter helpers;
- objective-emergency branching;
- CI/test telemetry.

The implementation must preserve the observable behavior frozen here.

Window 04 must not use the fix as authorization for broader Enemy AI refactoring or combat changes.

## 20. Design gate

ROOT_CAUSE_IDENTIFIED=YES  
PRIMARY_FIX_SINGLE_AND_MINIMAL=YES  
COMMANDER_FANTASY_RESTORED_BY_DESIGN=YES  
FIRST_CENTRAL_ROBUSTNESS_EXPECTED=YES  
COUNTERATTACK_IDENTITY_PRESERVED=YES  
RESERVE_DECISION_VALUE_PRESERVED=YES  
NO_SCOPE_EXPANSION=YES

RESULT=PASS  
READY_FOR_IMPLEMENTATION=YES

## 21. Frozen summary fields

BLOCKER_ID=PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION  
ROOT_CAUSE_CLASS=BATTLE_PHASE_ORDER_MISMATCH_PREMATURE_RED_ARMOR_OBJECTIVE_COMMITMENT  
PRIMARY_FIX_OPTION=A  
PRIMARY_FIX_SUMMARY=PRE_FIRST_PLAYER_CENTRAL_CAPTURE_RED_ARMOR_COMMITMENT_GATE  
PRE_FIRST_CENTRAL_ARMOR_BEHAVIOR=HOLD_LOCAL_RESERVE_WITH_BOUNDED_SELF_DEFENSE_AND_REAR_SECURITY_NO_CENTRAL_OBJECTIVE_DENIAL  
FIRST_CENTRAL_CAPTURE_RULE=UNCHANGED_15S_CONTINUOUS_UNCONTESTED  
RESERVE_UNLOCK_TRIGGER=UNCHANGED_FIRST_COMPLETED_PLAYER_CENTRAL_CAPTURE  
POST_FIRST_CENTRAL_ARMOR_BEHAVIOR=RESTORE_FULL_EXISTING_LOCAL_COUNTERATTACK_RESERVE_AND_OBJECTIVE_EMERGENCY_BEHAVIOR  
COUNTERATTACK_TIMING=NEXT_NORMAL_AI_DECISION_AFTER_FIRST_PLAYER_CENTRAL_CAPTURE  
FORMATION_VALUES_CHANGED=NO  
DAMAGE_MATRIX_CHANGED=NO  
CAPTURE_DURATION_CHANGED=NO  
RESERVE_TRIGGER_CHANGED=NO  
ENEMY_AI_CONTRACT_CHANGED=YES_NARROW_PRE_FIRST_CENTRAL_ARMOR_COMMITMENT_ONLY

NEXT_ACTION=IMPLEMENT_BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_V1  
NEXT_OWNER=WINDOW_04_AI_COMMAND  
BLOCKER=NONE
