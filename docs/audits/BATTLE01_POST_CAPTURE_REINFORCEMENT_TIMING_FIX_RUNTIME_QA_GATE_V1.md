# BATTLE01 POST-CAPTURE REINFORCEMENT TIMING FIX RUNTIME QA GATE V1

TASK_ID=QA_BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_V1  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_RESULT=PASS

QA_START_MAIN_SHA=c556c9d861a65a037843b11922c211d3ee14901c  
VERIFIED_GAMEPLAY_COMMIT=7b95b16692cc935b924dba7fb0c4de636a204d51  
IMPLEMENTATION_AUDIT=docs/audits/BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_IMPLEMENTATION_AUDIT_V1.md  
DESIGN_CONTRACT=docs/BATTLE01_POST_CAPTURE_COUNTERATTACK_ROBUSTNESS_FIX_CONTRACT_V1.md  
PREVIOUS_INTEGRATED_GATE=docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V4.md

## 1. Independent Window 07 decision

Window 07 did not inherit the implementation-side PASS. The gate independently inspected:

- Git provenance from the previous integrated V4 gate through the verified gameplay commit and current main;
- the frozen Option-A post-capture timing contract;
- the live Enemy AI inheritance chain;
- `BattleEnemyAIPostCaptureReinforcementController` production behavior;
- the dedicated timing focused smoke and its separate boundary cases;
- the revised human-reasonable integrated harness, including the decision/public-intel boundary;
- current Battle01 scene objective timing;
- current Reserve unlock/entry runtime;
- current formal RED roster and reinforcement entry;
- current Armor resource and damage matrix;
- the implementation audit's exact-engine runtime/regression record.

The previously diagnosed post-first-Central force-arrival compression is closed at the focused product/runtime level.

POST_CAPTURE_RED_REINFORCEMENT_TIMING_BLOCKER=CLOSED  
HUMAN_REASONABLE_FULL_VERTICAL_SLICE_BLOCKER=CLOSED_FOR_FOCUSED_FIX_GATE

The repaired escalation is now:

`FIRST PLAYER CENTRAL -> Reserve/Industrial unlock immediately -> starting RED ARMOR-01 immediately regains normal counterattack permission -> dormant RED reinforcement pair remains dormant for a full 15.0s -> reinforcement Infantry + Armor activate together -> second-wave counterattack -> regroup/recover -> Industrial`

rather than:

`FIRST PLAYER CENTRAL -> starting Armor + both dormant reinforcements collapse onto the player immediately while Reserve is still entering from West Rear`.

This gate is intentionally followed by a fresh full Integrated Vertical Slice rerun. It does not by itself authorize visual finalization.

## 2. Git provenance and gameplay binding

Current main at QA start is exactly:

`c556c9d861a65a037843b11922c211d3ee14901c`

Its parent is the verified gameplay commit:

`7b95b16692cc935b924dba7fb0c4de636a204d51`

The only change from verified gameplay commit to QA-start main is:

- `docs/audits/BATTLE01_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_IMPLEMENTATION_AUDIT_V1.md`

Therefore:

POST_VALIDATION_GAMEPLAY_DRIFT=NO  
BOUND_RUNTIME_EVIDENCE_SHA_MATCH=PASS

From the previous integrated V4 gate baseline `4c710b9b306f0f7a6655a46745748a6e8cfad969` to verified gameplay `7b95b166...`, the only production changes are:

- add `scripts/battle01/enemy_ai_post_capture_reinforcement_controller.gd`;
- change `scripts/battle01/enemy_ai_route_mobility_controller.gd` to inherit `BattleEnemyAIPostCaptureReinforcementController`.

The other changes are the frozen design contract and test/evidence files. No Formation resource, scene objective value, Reserve runtime, formal roster, route geometry, FOW runtime, Supply runtime or damage-matrix file changed.

## 3. Live construction correctness

The live scene still binds:

`Battle01.tscn -> enemy_ai_route_mobility_controller.gd`

and the runtime inheritance chain is now:

`BattleEnemyAIRouteMobilityController -> BattleEnemyAIPostCaptureReinforcementController -> BattleEnemyAIPreReserveProgressionController -> BattleEnemyAILogisticsController -> base Enemy AI`.

The post-capture controller defines:

`POST_CAPTURE_REINFORCEMENT_DELAY = 15.0`

On the first completed PLAYER Central capture it first calls the inherited pre-reserve progression handler, which releases the starting Armor gate. If dormant reinforcements are not already active, it then records the current battle elapsed time and starts the 15.0s delay.

The controller suppresses only `fixed_time` reinforcement activation while that delay is active. It does not suppress normal RED intel, starting Armor decisions, objective logic, logistics or other AI processing.

At delay completion it deactivates the timer and invokes normal reinforcement activation with `post_capture_delay_complete`.

CONSTRUCTION_CORRECTNESS=PASS

## 4. T=0 / T=15 post-capture timing boundary

The dedicated focused smoke instantiates the real `Battle01.tscn` and obtains the live EnemyAIController subtype.

At a synthetic first PLAYER Central completion at elapsed 30.0 it verifies:

- first-player-capture flag completed;
- post-capture delay active;
- delay start time exactly 30.0;
- both dormant reinforcement agents remain inactive.

A normal AI decision tick immediately after capture verifies that starting `RED ARMOR-01` is no longer behind the pre-first-capture gate and enters ENGAGE or MOVE while both reinforcement agents remain dormant.

The focused boundary then checks:

- T=14.99 after capture: reinforcement Infantry inactive;
- T=14.99 after capture: reinforcement Armor inactive;
- T=15.0 after capture: both active;
- delay inactive after activation;
- reinforcement activation count exactly one.

POST_CAPTURE_DELAY_PASS=PASS  
INITIAL_RED_ARMOR_IMMEDIATE_COUNTERATTACK_PASS=PASS  
REINFORCEMENT_INFANTRY_DELAY_PASS=PASS  
REINFORCEMENT_ARMOR_DELAY_PASS=PASS

## 5. 150-second fallback and non-preemption

The focused timing smoke contains three distinct fallback cases.

### Case A — fixed time before first Central

The test advances from 149.9 to 150.1 before Central capture and verifies the dormant pair activates exactly once. A later PLAYER Central capture starts no delay and does not duplicate the pair.

### Case B — first Central starts a delay that crosses 150s

The test completes PLAYER Central at elapsed 149.0. When normal AI processing crosses elapsed 150.0, the fixed-time activation call is intercepted because the post-capture delay is already authoritative. Reinforcements remain inactive through capture+14.99 and activate exactly once at capture+15.0.

### Case C — no PLAYER Central

The test crosses 150.0 without a PLAYER Central capture and verifies normal fixed-time activation remains functional.

FIXED_TIME_150S_FALLBACK_PASS=PASS  
150S_CANNOT_PREEMPT_ACTIVE_DELAY_PASS=PASS  
NO_DUPLICATE_REINFORCEMENT_PASS=PASS

## 6. Frozen-contract protection

The current Battle01 scene still has:

`CentralBridgehead.capture_time = 15.0`

and Industrial capture time also remains 15.0.

Current PlayerWarFlow still unlocks Reserve and Industrial only on the first completed PLAYER Central capture and retains:

`WEST_REAR_ENTRY = (320,900)`.

Current FormalCombatRoster retains:

`REINFORCEMENT_ENTRY = (1380,900)`

with one dormant reinforcement Infantry and one dormant reinforcement Armor.

Current Armor remains:

- HP=280
- Damage=45
- Range=300
- Fire interval=1.50
- Ammo=16
- Capture=NO
- Contest=YES

Current damage matrix remains:

- Recon: SOFT 1.00 / LIGHT 0.40 / HEAVY 0.20 / LOGISTICS 0.75
- Infantry: 1.00 / 0.70 / 0.35 / 1.00
- IFV: 1.25 / 1.00 / 0.55 / 1.00
- Armor: 0.90 / 1.35 / 1.00 / 1.00

No relevant resource/runtime file changed in the gameplay diff other than the authorized AI timing controller and inheritance binding.

FIRST_CENTRAL_RULE_PRESERVED_PASS=PASS  
PRE_CAPTURE_ARMOR_GATE_PRESERVED_PASS=PASS  
RESERVE_ENTRY_PRESERVED_PASS=PASS  
FORMATION_VALUES_PRESERVED_PASS=PASS  
DAMAGE_MATRIX_PRESERVED_PASS=PASS  
REINFORCEMENT_ROSTER_PRESERVED_PASS=PASS

## 7. Human evidence authority audit

The previous V4 gate rejected the old human harness as a perfect public-information authority because CONTACT and LAST_KNOWN used live RED world position.

The current harness corrects that boundary in `_public_knowledge()`:

- CONFIRMED is the only state that receives `red.global_position`;
- LAST_KNOWN receives `IntelTracker.get_last_known_position_for(red)`;
- CONTACT receives no `pos` field at all.

Decision helpers requiring a point ignore entries without `pos`, so CONTACT can change the decision from "no contact" to "contact exists" without granting an exact target coordinate.

Record/observer-only code still reads RED truth for evidence timing and diagnostics; those values are not returned to the decision snapshot. This is permitted by the evidence contract.

HUMAN_CONTACT_AUTHORITY_PASS=PASS  
HUMAN_LAST_KNOWN_AUTHORITY_PASS=PASS  
FOW_LEAKAGE_AUDIT_PASS=PASS

## 8. Human-reasonable command discipline

The decision driver uses a 3.0s per-Formation command gate. Navigation orders already in progress are not reissued as no-op clicks. Combat decisions are made from public objective/intel state rather than AI state, damage-serial reactions or hidden posture truth.

The harness uses normal player-facing input for staging, selection, START, MOVE, ADVANCE, Hold Fire / Weapons Free, Resupply and Reserve HUD commitment.

One deliberate rear regroup uses:

`PlayerWarFlow.withdraw_selected(false)`

because the current X-key product path prefers the active forward rally after Central is secured. This is explicitly allowed in the QA contract and is classified as:

`PUBLIC_COMMAND_API_FALLBACK`

not a hidden progression shortcut or gameplay mutation.

No evidence path uses force-objective, forced damage, teleport, HP mutation, time-scale override, seed override, direct Reserve deployment shortcut, frame-perfect kite, damage-serial reactive micro or Logistics bait as the success dependency.

HUMAN_REASONABLE_COMMAND_DISCIPLINE=PASS

## 9. Formal human runtime evidence

The implementation audit binds a fresh exact-engine human rerun under:

`Godot 4.7.1.stable.official.a13da4feb`

with stderr empty and no script/parse/runtime blocker signatures.

Window 07 independently inspected the current harness rather than accepting its PASS marker blindly. The important final markers are derived from runtime state:

- first-Central markers require recorded real PLAYER Central ownership;
- post-capture-survival markers require the run to remain legally mission-capable beyond the full capture+15s boundary;
- Reserve Infantry real-flow requires the committed Infantry Reserve to provide Central/Industrial ground control or restore capture capability;
- Reserve Armor real-flow requires the committed Armor Reserve to actually fire;
- full-vertical-slice requires real Victory + first Central + Industrial capture + post-capture survival + counterattack-resolution state;
- counterattack resolution is only marked after the full second-wave boundary, transition to Industrial, active second wave and surviving mission-capable BLUE force.

Bound fresh runtime results are:

RUN_A_FIRST_CENTRAL_PASS=PASS  
RUN_A_POST_CAPTURE_SURVIVAL_PASS=PASS  
RUN_A_COUNTERATTACK_RESOLVED_PASS=PASS

RUN_B_FIRST_CENTRAL_PASS=PASS  
RUN_B_POST_CAPTURE_SURVIVAL_PASS=PASS

RUN_C_FIRST_CENTRAL_PASS=PASS  
RUN_C_POST_CAPTURE_SURVIVAL_PASS=PASS

RESERVE_INFANTRY_REAL_FLOW_PASS=PASS  
RESERVE_ARMOR_REAL_FLOW_PASS=PASS

FULL_VERTICAL_SLICE_VICTORY_PATH_PASS=PASS  
FULL_VERTICAL_SLICE_VICTORY_RUN=C

The implementation audit records Run C as:

- posture=SOUTH_SCREEN
- plan=SOUTH_MANEUVER
- first contact ≈4.56s
- first Central capture ≈33.79s
- Reserve use ≈34.77s
- dormant second-wave activation / counterattack timing ≈48.86s
- full Victory ≈111.04s

The approximately 15.07s difference between first Central capture and second-wave activation is consistent with the frozen 15.0s response window plus sampling/frame granularity. The starting RED Armor remains immediate pressure; the recorded `counterattack` field in this harness is tied to dormant reinforcement activation and therefore represents the second-wave boundary, not the first Armor's initial reaction.

The accepted Run C flow is therefore:

`SOUTH_MANEUVER -> FIRST CENTRAL -> Reserve Armor -> immediate starting RED Armor pressure -> full 15s response window -> dormant reinforcement Infantry+Armor second wave -> counterattack contained/resolved -> Industrial capture -> VICTORY`.

## 10. Reserve real value

The current harness does not classify Reserve value from spawn alone.

For Infantry Reserve, `reserve_real_flow` becomes true only when the live Reserve Infantry is capture-capable and materially supplies Central/Industrial ground control or restores mission capture capability after original capture formations are lost.

For Armor Reserve, `reserve_real_flow` becomes true only after the live Reserve Armor's fire serial increases.

The bound human rerun passes both conditions.

RESERVE_INFANTRY_REAL_FLOW_PASS=PASS  
RESERVE_ARMOR_REAL_FLOW_PASS=PASS

## 11. Defeat still exists

The human harness retains a dedicated normal defeat control using movement-only sacrificial orders through the live battle, then verifies:

- match terminates as defeat;
- DEFEAT result HUD is visible;
- post-result commands are frozen;
- Restart remains available.

The implementation audit records:

DEFEAT_CONTROL_RESULT=PASS

The timing fix therefore does not convert Battle01 into a free victory. Starting Armor remains active during the response window and the full dormant second wave still arrives at existing strength.

DEFEAT_CONTROL_PASS=PASS

## 12. Regression review

The implementation audit binds fresh exact-engine PASS results for:

PRE_RESERVE_FIX_REGRESSION_PASS=PASS  
ENEMY_AI_REGRESSION_PASS=PASS  
REINFORCEMENT_REGRESSION_PASS=PASS  
FOW_REGRESSION_PASS=PASS  
ROUTE_REGRESSION_PASS=PASS  
SEEDED_POSTURE_REGRESSION_PASS=PASS  
ADVANCE_HOLD_FIRE_REGRESSION_PASS=PASS  
RESUPPLY_REGRESSION_PASS=PASS  
OBJECTIVE_REGRESSION_PASS=PASS  
VICTORY_DEFEAT_REGRESSION_PASS=PASS  
RESTART_REGRESSION_PASS=PASS

The four existing CI smoke entry points are also recorded clean:

- `--battle01-ci-enemy-ai-smoke`
- `--battle01-ci-navigation-smoke`
- `--battle01-ci-intel-combat-smoke`
- `--battle01-ci-multi-command-smoke`

Additional formal-roster, primary-IFV Move/Advance and 3D foundation smokes are recorded clean as well.

Window 07 does not have a local Godot worktree/executable in this environment and therefore does not claim a second independent engine execution. The QA decision is based on independent source/provenance inspection plus the SHA-bound exact-engine implementation evidence.

INDEPENDENT_RUNTIME_REEXECUTION=UNAVAILABLE_IN_WINDOW_07  
BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_EXACT_ENGINE_EVIDENCE

## 13. Product judgment

The response window is now meaningful rather than empty: the player receives Reserve/Industrial unlock immediately, the starting RED Armor remains a visible immediate threat, and the dormant pair waits a full 15.0 seconds before adding the second wave. The human rerun demonstrates that a Formation-level player can use that window to withdraw/regroup, make the irreversible Reserve decision and continue into the second wave.

POST_CAPTURE_REACTION_WINDOW_MEANINGFUL=PASS

The counterattack retains identity and danger because no RED combat value or roster was reduced, the starting Armor is not delayed, and the second wave still contains the existing Armor+Infantry pair.

COUNTERATTACK_TEMPO_COHERENT=PASS

The current human driver no longer depends on the previous high-frequency damage-reactive kite / Logistics-screen success pattern. Major decisions are reconnaissance, route commitment, capture, Reserve choice, tactical withdrawal/regroup, second-wave response and Industrial push at Formation level.

COMMANDER_FANTASY_PASS=PASS

Distinct Formation contributions remain material: Recon/public intel, Infantry ownership/capture recovery, IFV mobile fire support, Logistics sustain, Infantry Reserve ground-control recovery and Armor Reserve heavy response are all represented in the current runtime/harness conditions.

COMBINED_ARMS_VALUE_PASS=PASS

A real full Vertical Slice Victory path now exists under the repaired timing baseline, while dedicated natural Defeat remains available.

FULL_VERTICAL_SLICE_PLAYABLE=PASS

## 14. Gate decision

CONSTRUCTION_CORRECTNESS=PASS  
PRODUCT_CORRECTNESS=PASS  
PLAYER_FLOW_CORRECTNESS=PASS  
EVIDENCE_SUFFICIENCY=PASS

QA_GATE_RESULT=PASS

POST_CAPTURE_RED_REINFORCEMENT_TIMING_BLOCKER=CLOSED  
HUMAN_REASONABLE_FULL_VERTICAL_SLICE_BLOCKER=CLOSED

READY_FOR_INTEGRATED_VERTICAL_SLICE_RERUN=YES

NEXT_ACTION=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V1  
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_PERFORMANCE

Do not return to Window 04. Do not proceed directly to visual finalization. The post-capture timing fix is closed, but the final complete integrated player-flow gate must now be rerun on verified gameplay commit `7b95b16692cc935b924dba7fb0c4de636a204d51`.

BLOCKER=NONE  
ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
