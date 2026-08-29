# BATTLE01_POST_CAPTURE_COUNTERATTACK_ROBUSTNESS_FIX_CONTRACT_V1

TASK_ID=RESOLVE_BATTLE01_POST_CAPTURE_COUNTERATTACK_ROBUSTNESS_BLOCKER_V1  
OWNER_WINDOW=WINDOW_01_GAME_DESIGN  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
STATUS=FROZEN

START_MAIN_SHA=4c710b9b306f0f7a6655a46745748a6e8cfad969

BLOCKER_ID=POST_FIRST_PLAYER_CENTRAL_CAPTURE_COUNTERATTACK_ROBUSTNESS

## 0. Authority and scope

This contract resolves exactly one Battle01 product-flow blocker: the post-first-player-Central counterattack escalation currently arrives faster than a Formation-level player can make the newly unlocked Reserve tactically relevant.

It inherits and preserves except where this contract explicitly narrows reinforcement activation timing:

- `docs/FRONTLINE_PRODUCT_BASELINE_V1.md`
- `docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md`
- `docs/BATTLE01_FORMATION_RULES_V2.md`
- `docs/BATTLE01_ENEMY_AI_CONTRACT_V2.md`
- `docs/BATTLE01_PRE_BATTLE_STAGING_CONTRACT_V1.md`
- `docs/BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_CONTRACT_V1.md`
- `docs/FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1.md`
- `docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V4.md`
- `docs/audits/BATTLE01_HUMAN_REASONABLE_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1.md`

This contract does not reopen the successful pre-first-Central Option A fix.

FIRST_CENTRAL_RULE_CHANGED=NO  
PRE_CAPTURE_ARMOR_GATE_CHANGED=NO  
NO_NEW_UNIT=YES  
NO_NEW_WEAPON=YES  
NO_NEW_ROUTE=YES  
NO_NEW_ECONOMY=YES  
NO_NEW_OBJECTIVE=YES  
NO_SCOPE_EXPANSION=YES

## 1. Blocker confirmation

BLOCKER_CONFIRMED=YES

The current human-reasonable evidence demonstrates that all three seeded RED postures can cross the previously blocked hinge using low-frequency, Formation-level play:

`STAGING -> RECON / CONTACT -> INITIAL INFANTRY DEFENSE -> REAL 15s CENTRAL CAPTURE -> RESERVE UNLOCK`

Observed first Central captures:

- BRIDGE_LOCK: PASS at approximately 30.22s
- VILLAGE_SCREEN: PASS at approximately 29.10s
- SOUTH_SCREEN: PASS at approximately 38.77s

Therefore the first-Central progression fix is successful and is not reopened by this contract.

After first PLAYER Central capture, however, the current implementation produces the following force-arrival compression:

1. RED ARMOR-01 immediately regains the full post-capture Central counterattack permission frozen by the pre-Reserve fix.
2. The same Central ownership loss immediately activates both dormant RED reinforcement Formations.
3. RED REINFORCEMENT INF-01 and RED REINFORCEMENT ARMOR-01 already exist at the current reinforcement entry `(1380,900)`, close to Central.
4. The newly unlocked BLUE Reserve enters from `WEST_REAR_ENTRY=(320,900)` and must traverse the real map before it can materially contribute.

The result is a short interval in which the player can face the initial RED Armor plus reinforcement Armor plus reinforcement Infantry before the newly chosen Reserve has become a meaningful response asset.

The current evidence does not prove all legal strategies mathematically unwinnable. The correct product classification is:

CURRENT_FORMATION_LEVEL_PLAYER_FLOW_NOT_ROBUSTLY_SURVIVABLE=YES

ROOT_CAUSE_CLASS=POST_CAPTURE_FORCE_ARRIVAL_TIMING_COMPRESSION

More explicitly:

`FIRST CENTRAL SECURED -> INITIAL RED ARMOR COUNTERATTACK + IMMEDIATE FULL DORMANT REINFORCEMENT ARRIVAL -> BLUE RESERVE STILL IN TRANSIT -> FRONTLINE COLLAPSE/STALEMATE`

This violates the intended Battle01 phase rhythm:

`FIRST CENTRAL SECURED -> RECOGNIZE THREAT -> CHOOSE RESERVE / PRESERVE / WITHDRAW -> COUNTERATTACK FORMS -> RESERVE BECOMES RELEVANT -> RESOLVE COUNTERATTACK -> INDUSTRIAL`

## 2. Four-option evaluation

### OPTION A — REINFORCEMENT_ACTIVATION_TIMING

JUDGMENT=BEST_FIT

Advantages:

- directly addresses the observed phase-order / force-arrival compression;
- preserves every Formation value and the complete reinforcement roster;
- preserves the successful pre-first-Central Armor gate;
- allows RED ARMOR-01 to remain an immediate and credible post-capture threat;
- creates a readable second escalation rather than removing enemy pressure;
- gives both BLUE Reserve choices time to become tactically relevant through real movement;
- requires only reinforcement timing semantics inside the already-authorized Enemy AI / battle-flow domain.

Risk:

- excessive delay could create a dead period.

Mitigation:

- the starting RED Armor immediately counterattacks after first Central capture;
- any surviving initial RED combat Formation remains active;
- the delay is fixed and short: 15.0 seconds;
- dormant reinforcements then activate at full existing strength.

### OPTION B — REINFORCEMENT_COMPOSITION

JUDGMENT=REJECT_AS_PRIMARY

Changing the first wave to omit reinforcement Armor could also lower the peak, but the core problem is not that the reinforcement Armor should not exist. It is that the full second force appears at the exact moment the player's Reserve has only just been unlocked.

Removing or separately withholding one unit would alter force-composition semantics more than necessary and would make later reinforcement identity harder to read.

### OPTION C — RESERVE_RESPONSE_WINDOW / ENTRY

JUDGMENT=REJECT_AS_PRIMARY

Moving BLUE Reserve entry forward would make the choice relevant faster, but it would weaken the spatial meaning of `WEST_REAR_ENTRY`, could resemble a tactical teleport, and would reduce the value of real route/arrival planning.

The Reserve should remain a rear commitment that physically reaches the fight.

### OPTION D — COMBAT_BALANCE

JUDGMENT=REJECT

No current evidence proves Armor HP, damage, range, interval or the role-effectiveness matrix are individually wrong. Altering combat values would affect pre-Central combat, post-Central counterattack, Industrial, and Reserve Armor value simultaneously.

No combat-value change is authorized.

## 3. Primary fix decision

PRIMARY_FIX_OPTION=A

PRIMARY_FIX_SUMMARY=DELAY_DORMANT_RED_REINFORCEMENT_ACTIVATION_FOR_A_FULL_15S_RESPONSE_WINDOW_AFTER_FIRST_PLAYER_CENTRAL_CAPTURE_WHILE_INITIAL_RED_ARMOR_COUNTERATTACKS_IMMEDIATELY

SUPPORTING_ADJUSTMENT_REQUIRED=NO

The single changed semantic is dormant RED reinforcement activation timing after an early first PLAYER Central capture.

## 4. Frozen post-capture phase contract

### 4.1 First Central completion

Event:

`FIRST_PLAYER_CENTRAL_CAPTURE_COMPLETED`

At the exact completed ownership transfer:

- Central becomes PLAYER-owned under the existing Objective runtime.
- BLUE Reserve unlock remains immediate.
- Industrial unlock remains unchanged.
- the pre-first-Central RED ARMOR-01 gate is released exactly as currently accepted.
- RED ARMOR-01 may immediately use the existing post-capture counterattack / objective-emergency rules from the next normal AI decision.
- dormant RED reinforcement Infantry/Armor do NOT activate from objective loss on the same frame/decision.
- a deterministic post-capture reinforcement response window begins if the dormant reinforcements are not already active.

POST_CAPTURE_INITIAL_ARMOR_BEHAVIOR=IMMEDIATE_EXISTING_LOCAL_COUNTERATTACK_RESERVE_RESPONSE

The starting RED Armor is the first visible counterattack pressure. It is not delayed, weakened, hidden, made passive, or prevented from contesting Central after the first capture.

### 4.2 Response window

POST_CENTRAL_REINFORCEMENT_DELAY=15.0s

DELAY_START_EVENT=FIRST_COMPLETED_PLAYER_CENTRAL_CAPTURE

DELAY_END_EVENT=15.0_SECONDS_OF_NORMAL_BATTLE_TIME_AFTER_DELAY_START

RESERVE_RESPONSE_WINDOW=15.0s_FULL_WINDOW_IF_DORMANT_RED_REINFORCEMENTS_WERE_NOT_ALREADY_ACTIVE

Purpose:

- give the player time to recognize the counterattack;
- make the irreversible Reserve choice;
- issue a Formation-level HOLD / WITHDRAW / RESUPPLY / movement response;
- allow Reserve Infantry or Reserve Armor to begin physically closing from West Rear;
- keep pressure active through RED ARMOR-01 instead of creating an empty battlefield.

The response window is not invulnerability. Existing RED combat units fight normally.

### 4.3 Fixed-time reinforcement pressure

The existing 150-second fixed-time reinforcement pressure remains part of Battle01.

POST_CENTRAL_REINFORCEMENT_TRIGGER_RULE:

1. If dormant RED reinforcements activate from the existing `150.0s` fixed-time trigger BEFORE first PLAYER Central capture, they remain active; first Central capture does not despawn, pause, or rewind them.
2. If first PLAYER Central capture occurs while the dormant RED reinforcements are still inactive, start the frozen 15.0-second post-capture response window.
3. Once that response window starts, the fixed-time fallback may not pre-empt the window. Activation occurs at the end of the full 15.0-second window even if battle time crosses 150.0s during those 15 seconds.
4. Reinforcements activate only once.

This preserves deliberate long-match pressure: a player who has already allowed the battle to reach 150 seconds before securing Central does not receive a new artificial grace period against reinforcements that are already on the battlefield.

REINFORCEMENT_TRIGGER=FIXED_TIME_150S_IF_ALREADY_REACHED_BEFORE_FIRST_CENTRAL_OTHERWISE_FIRST_PLAYER_CENTRAL_CAPTURE_PLUS_15S

### 4.4 Reinforcement activation

At delay end, if the dormant reinforcements are still inactive:

REINFORCEMENT_INFANTRY_ACTIVATION=YES
REINFORCEMENT_ARMOR_ACTIVATION=YES

Both existing dormant Formations activate together.

REINFORCEMENT_ENTRY=UNCHANGED_(1380,900)

No new spawn, staging point or route is added.

Their existing role / objective / FOW / navigation rules apply immediately after activation.

## 5. Counterattack waves

This contract uses product-phase language for acceptance. It does not require a separate wave-manager architecture.

FIRST_COUNTERATTACK_WAVE=
- RED ARMOR-01 under restored post-first-Central counterattack permissions
- plus any surviving already-active initial RED combat Formation under its existing rules

The first wave begins immediately after first PLAYER Central capture.

SECOND_COUNTERATTACK_WAVE=
- RED REINFORCEMENT INF-01 x1
- RED REINFORCEMENT ARMOR-01 x1

The second wave begins at the frozen reinforcement activation time.

FIRST_COUNTERATTACK_WAVE_COMPOSITION_CHANGED=NO_NEW_OR_REMOVED_FORMATIONS
REINFORCEMENT_ROSTER_PRESERVED=YES
REINFORCEMENT_ROSTER_CHANGED=NO

This is not Option B. The roster and simultaneous dormant reinforcement pair are unchanged; only their post-capture activation timing changes.

## 6. Reserve rules

RESERVE_ENTRY_RULE=UNCHANGED_WEST_REAR_ENTRY_(320,900)

No forward spawn, teleport, temporary speed bonus or special counterattack-only Reserve movement is authorized.

Reserve remains:

- one irreversible choice;
- Infantry OR Armor;
- unlocked by first completed PLAYER Central capture;
- physically entering through existing navigation.

### Reserve Infantry product value

RESERVE_INFANTRY_VALUE_PRESERVED=YES

The 15-second response window allows Reserve Infantry's faster movement and capture capability to become relevant before the full dormant second wave is active.

Expected uses include:

- restoring/reinforcing capture-capable manpower;
- occupying foot-accessible ground;
- helping re-establish Central ownership after a withdrawal;
- supporting later Industrial ownership.

Reserve Infantry is not required to defeat heavy Armor by itself.

### Reserve Armor product value

RESERVE_ARMOR_VALUE_PRESERVED=YES

The 15-second response window gives Reserve Armor time to close physically from West Rear and become a meaningful heavy counter-counterattack asset.

Expected uses include:

- engaging RED Armor;
- contesting Central during counterattack;
- protecting surviving capture-capable Infantry/IFV;
- supporting Central/South/open Industrial firepower.

Neither Reserve choice is frozen as mandatory for victory.

## 7. Combat and objective preservation

COMBAT_VALUES_CHANGED=NO
DAMAGE_MATRIX_CHANGED=NO
FIRST_CENTRAL_CAPTURE_DURATION=15.0s_UNCHANGED
FIRST_CENTRAL_RULE_CHANGED=NO
PRE_CAPTURE_ARMOR_GATE_CHANGED=NO
RESERVE_UNLOCK_TRIGGER_CHANGED=NO
RESERVE_ENTRY_CHANGED=NO
ROUTE_GEOMETRY_CHANGED=NO
SEEDED_RED_POSTURES_CHANGED=NO
SUPPLY_RULE_CHANGED=NO
INDUSTRIAL_RULE_CHANGED=NO
VICTORY_DEFEAT_RULE_CHANGED=NO

Armor remains:

- HP=280
- Damage=45
- Range=300
- Fire interval=1.50s
- Ammo=16
- Capture=NO
- Contest=YES

No Formation resource or damage multiplier is changed by this contract.

## 8. Counterattack identity and danger

COUNTERATTACK_IDENTITY_PRESERVED=YES

The counterattack must remain dangerous because:

1. RED ARMOR-01 can counterattack immediately after first Central capture.
2. Surviving initial RED units remain active.
3. The player must make a real Reserve / hold / withdraw / resupply decision during the response window.
4. At 15 seconds the existing reinforcement Infantry + Armor activate at full current strength.
5. Poorly preserved BLUE forces can still be unable to withstand the second wave.

This contract does not require RED to wait passively for 15 seconds.

DEFEAT_STILL_POSSIBLE=YES

Expected natural defeat causes remain:

- the player ignores the initial Armor counterattack;
- the player does not commit or misuses Reserve;
- capture-capable units are lost;
- the player overextends instead of withdrawing/reforming;
- resupply/sustain is mishandled;
- the second wave arrives while BLUE is dispersed or depleted;
- Industrial is attempted before the counterattack is stabilized.

## 9. Expected player flow

EXPECTED_PLAYER_FLOW=

1. Central secured by real 15-second capture.
2. Reserve unlock and Industrial unlock occur as before.
3. RED ARMOR-01 visibly begins the first counterattack immediately.
4. Player recognizes the threat and makes an irreversible Reserve choice.
5. During the 15-second response window, Reserve begins a real physical approach while the player chooses HOLD / WITHDRAW / RESUPPLY / local counterattack posture.
6. RED dormant Infantry + Armor visibly enter as the second counterattack wave at delay end.
7. BLUE Reserve is now tactically relevant rather than still functionally absent.
8. Player resolves the counterattack through Formation-level concentration, preservation, withdrawal, sustain and role use.
9. Surviving BLUE force reforms and commits toward Industrial.
10. Industrial contest/capture produces the final Battle01 decision phase and possible VICTORY.

This flow does not guarantee victory and does not require holding Central continuously through the entire counterattack.

## 10. Expected failure flow

EXPECTED_FAILURE_FLOW=

`Central secured -> player ignores/underestimates initial RED Armor -> Reserve not committed or committed poorly -> BLUE remains overextended -> second wave arrives after 15s -> capture-capable force collapses -> natural DEFEAT`

or

`Central secured -> player survives first wave but fails to withdraw/resupply/re-form -> second wave overwhelms depleted force -> natural DEFEAT`

Failure remains a legitimate product outcome.

## 11. Why 15.0 seconds

The value is intentionally tied to the observed physical response problem rather than arbitrary easing.

Current BLUE Reserve spawns at approximately x=320 while Central is approximately x=1600. Ignoring detour/arrival tolerance, the direct-axis gap is about 1280 world units.

At current frozen move speeds:

- Reserve Infantry speed 115: direct travel magnitude is roughly 11 seconds;
- Reserve Armor speed 85: direct travel magnitude is roughly 15 seconds.

The map/navigation path may add some travel cost. A 15-second dormant-reinforcement delay therefore does not teleport the Reserve into combat; it simply gives either legal Reserve choice a realistic chance to become tactically relevant before the full second RED wave is released.

Meanwhile RED ARMOR-01 remains active immediately, so the same 15 seconds are not free ownership time.

## 12. Anti-exploit / boundary rules

- The delay starts from the authoritative completed first PLAYER Central capture event, not from partial capture progress.
- Repeated Central ownership flips do not restart or extend the delay.
- Player leaving Central does not pause the delay.
- RED recapturing Central during the response window does not cancel or restart the delay.
- No hidden BLUE position affects activation time.
- The delay is deterministic and frame-rate independent.
- No random reinforcement timing is allowed.
- Reinforcement spawn position remains hidden/visible only under normal FOW presentation rules.
- Dormant reinforcements remain inactive/non-participating until formal activation.
- No extra temporary armor protection, damage buff, speed buff or reserve invulnerability is authorized.

## 13. QA acceptance contract

The implementation must be revalidated with human-reasonable integrated evidence, not focused smoke alone.

### 13.1 Evidence-authority repairs required in the harness

Before that harness can serve as final evidence:

- CONTACT must not use precise current RED world truth as player decision authority.
- LAST_KNOWN must use `IntelTracker.get_last_known_position_for(target)` or the equivalent current authoritative stored last-known position.
- LAST_KNOWN must not use `red.global_position` while the target is hidden.
- The rear WITHDRAW path should use the same real player command/input authority required by the gate unless Window 07 explicitly accepts an equivalent bound interaction.
- diagnostic timeout/reload handling must not be presented as normal product Restart evidence.

These are evidence-quality corrections, not gameplay changes.

### 13.2 Required human-reasonable behavior results

Minimum formal acceptance after implementation:

RUN_A_FIRST_CENTRAL=PASS
RUN_A_POST_CAPTURE_SURVIVAL=PASS
RUN_A_COUNTERATTACK_RESOLVED=PASS

RUN_B_FIRST_CENTRAL=PASS
RUN_B_POST_CAPTURE_SURVIVAL=PASS

RUN_C_FIRST_CENTRAL=PASS
RUN_C_POST_CAPTURE_SURVIVAL=PASS

At least two real Reserve choices must be proven tactically usable across the accepted runs:

- at least one accepted run uses Reserve Infantry meaningfully;
- at least one accepted run uses Reserve Armor meaningfully.

The test does not require no-loss victories.

Allowed player behavior includes:

- one or more deliberate Formation-level WITHDRAW decisions;
- HOLD / ADVANCE / MOVE;
- normal Resupply;
- loss of non-essential units;
- temporary loss of Central followed by reorganization/recapture.

The accepted successful path must not depend on:

- high-frequency damage-reactive kiting;
- Logistics bait/screening as an Armor aggro exploit;
- hidden RED truth;
- pixel-perfect enemy coordinates;
- direct damage/HP manipulation;
- force-objective shortcuts;
- teleport;
- time-scale changes.

### 13.3 Full Vertical Slice goal

At least one human-reasonable accepted run must ultimately complete:

`Central -> Counterattack -> Industrial -> VICTORY`

before Window 07 may close the integrated player-flow gate.

A dedicated natural DEFEAT control must also continue to pass.

## 14. Implementation owner and freedom

NEXT_OWNER=WINDOW_04_AI_COMMAND

Window 04 / Codex may choose the engineering details required to implement the frozen timing contract, including:

- timer/state location;
- reuse or override of existing reinforcement trigger helpers;
- signal wiring from first Central capture;
- deterministic elapsed-time handling;
- telemetry;
- focused smoke helpers;
- Typed GDScript structure.

Implementation freedom may not alter:

- the 15.0-second delay semantics;
- fixed-time-before-capture behavior described above;
- reinforcement roster;
- reinforcement entry;
- pre-first-Central Armor gate;
- combat values;
- Reserve entry/unlock;
- route/FOW/objective semantics.

## 15. Design closure

ROOT_CAUSE_IDENTIFIED=YES
PRIMARY_FIX_SINGLE_AND_MINIMAL=YES
POST_CAPTURE_RESPONSE_WINDOW_RESTORED=YES
COUNTERATTACK_IDENTITY_PRESERVED=YES
RESERVE_DECISION_VALUE_EXPECTED=YES
DEFEAT_STILL_POSSIBLE=YES
FIRST_CENTRAL_FIX_PRESERVED=YES
NO_SCOPE_EXPANSION=YES

READY_FOR_IMPLEMENTATION=YES

NEXT_ACTION=IMPLEMENT_BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_V1
NEXT_OWNER=WINDOW_04_AI_COMMAND
BLOCKER=NONE
