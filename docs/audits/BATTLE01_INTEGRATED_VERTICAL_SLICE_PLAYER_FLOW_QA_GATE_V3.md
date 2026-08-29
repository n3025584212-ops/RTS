# BATTLE01 INTEGRATED VERTICAL SLICE PLAYER FLOW QA GATE V3

TASK_ID=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V2  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_RESULT=BLOCKED

START_MAIN_SHA=167162e46e7801f2662018658bf1f5ca260a201d  
VERIFIED_GAMEPLAY_COMMIT=439c415bebde407862838ccb7cc533186e86d014  
PREVIOUS_GATE=docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V2.md  
PROGRESSION_FIX_GATE=docs/audits/BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_RUNTIME_QA_GATE_V1.md

## 1. Independent Window 07 decision

The previously confirmed pre-Reserve Central progression blocker remains CLOSED. The new Option A Armor commitment gate is not reopened by this audit.

Bound real-Godot evidence at the verified gameplay commit demonstrates that the current build can complete three normal-session victory runs and one defeat-control run:

- Run A / BRIDGE_LOCK / Armor Reserve -> VICTORY
- Run B / VILLAGE_SCREEN / Infantry Reserve -> VICTORY
- Run C / SOUTH_SCREEN / Armor Reserve -> VICTORY
- Restart posture sequence A -> B -> C -> A -> PASS
- Natural defeat-control flow -> PASS

The evidence also preserves real Viewport input, normal staging, actual 15-second Central capture, real Reserve HUD commitment, FOW, resupply, objective progression, victory/defeat and restart behavior.

However, this is the final integrated product gate, not a focused mechanics gate. The current automated success strategy is insufficient evidence to certify Commander Fantasy, combined-arms value and route-identity player value as final product PASS.

QA_GATE_RESULT=BLOCKED

This is an evidence/product-flow qualification blocker, not a new runtime fault and not authorization to modify the Option A progression fix.

## 2. Git provenance

Current main at gate start is `167162e46e7801f2662018658bf1f5ca260a201d`.

The verified gameplay/test baseline is `439c415bebde407862838ccb7cc533186e86d014`.

The commits after the verified gameplay/test baseline are audit-only:

- `b1446ba0ceba080e535be0a004bc87cba8e72d37` — implementation audit
- `167162e46e7801f2662018658bf1f5ca260a201d` — progression-fix QA audit

POST_VALIDATION_GAMEPLAY_DRIFT=NO  
BOUND_RUNTIME_EVIDENCE_SHA_MATCH=PASS

Window 07 has no local Godot executable/worktree in this execution environment and does not claim a second engine execution.

INDEPENDENT_RUNTIME_REEXECUTION=UNAVAILABLE_IN_WINDOW_07

## 3. Integrated runtime facts that are accepted

From the bound exact-engine implementation evidence:

RUN_A_RESULT=VICTORY  
RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_CENTRAL_CAPTURE_PASS=PASS  
RUN_A_RESERVE_UNLOCK_PASS=PASS  
RUN_A_RESERVE_ARMOR_COMMIT_PASS=PASS  
RUN_A_COUNTERATTACK_REACHED_PASS=PASS

RUN_B_RESULT=VICTORY  
RUN_B_POSTURE=VILLAGE_SCREEN  
RUN_B_RESERVE=INFANTRY

RUN_C_RESULT=VICTORY  
RUN_C_POSTURE=SOUTH_SCREEN  
RUN_C_RESERVE=ARMOR

POSTURE_SEQUENCE_PASS=PASS_A_B_C_A  
DEFEAT_CONTROL_RESULT=PASS

STAGING_FLOW_PASS=PASS  
REAL_VIEWPORT_INPUT_PASS=PASS  
FOW_GLOBAL_PASS=PASS_IN_BOUND_AUTOMATED_EVIDENCE  
FIRST_CENTRAL_PROGRESSION_ROBUSTNESS=PASS_AT_STRUCTURAL_FIX_LEVEL  
COUNTERATTACK_PLAYER_PRESSURE_PASS=PASS_IN_BOUND_AUTOMATED_EVIDENCE  
ADVANCE_MOVE_DISTINCTION_PASS=PASS  
BLUE_RESUPPLY_PASS=PASS_IN_BOUND_AUTOMATED_EVIDENCE  
RED_LOGISTICS_PASS=PASS_PLAYER_PRESSURE_OBSERVED  
SOFTLOCK_FOUND=NO  
RUNTIME_STABILITY_PASS=PASS  
BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_EXACT_ENGINE_EVIDENCE

## 4. Run A strategy audit — final-gate concern

The successful integrated harness does not merely issue a small number of high-level Formation decisions after the progression fix.

Before the first Central capture, `_prepare_pre_capture_progression()` explicitly:

1. uses BLUE Logistics as a movement-only screen for the starting RED Armor;
2. sends Logistics deep east to approximately `(3020,1060)`;
3. moves Infantry and Recon beyond Central toward the locked Industrial side before Central ownership has transferred;
4. only after this pre-positioning sends the IFV to perform the real first Central capture.

The comments in the evidence harness explicitly describe Logistics as a screen for the initial Armor's local self-defense.

This is legal runtime behavior and uses no hidden test authority. It nevertheless does not prove that a normal player can recognize and execute the intended Battle01 opening without knowing the exact RED Armor behavioral contract and without using a support unit as an AI-displacement tool.

RUN_A_STRATEGY_HUMAN_REASONABLE=NOT_PROVEN

Window 07 therefore does not convert the narrow progression-fix Gate's `COMMANDER_FANTASY_PASS` into a final integrated Commander Fantasy PASS.

## 5. Micro-workload audit

The integrated combat driver contains repeated high-frequency reactive ordering:

- IFV infantry kiting alternates ADVANCE and retreat points in repeated exchange loops;
- isolated Infantry targets are re-engaged on a roughly 5-second cadence;
- post-Central counterattack handling issues damage-triggered 620-unit withdrawals and later re-entry orders;
- Industrial defense alternates Infantry/Recon defensive positions on approximately a 0.8-second cadence while the counterattack loop is active;
- assault groups are re-issued attack orders on a roughly 5-second cadence.

These are valid player commands, but this command pattern is materially closer to automated unit micromanagement than the frozen product fantasy of a battlefield commander making Formation-level decisions.

The evidence does not establish that these high-frequency loops are required by the game, but because this is the only complete success evidence currently bound to the final integrated gate, it cannot establish the opposite either.

COMMANDER_FANTASY_PASS=BLOCKED_BY_EVIDENCE_STRATEGY

## 6. Route Identity audit

### Central

Run A genuinely uses the Central opening and crosses the repaired first-Central progression hinge.

CENTRAL_ROUTE_VALUE_VISIBLE=YES

### North

The Run B evidence does not sufficiently demonstrate North route player value in an integrated combat flow. The harness computes North foot-link legality directly from:

- `get_north_foot_link_entry()`
- `get_north_foot_link_exit()`
- `find_path_for_mobility(...)`
- `path_uses_north_foot_link(...)`

This is valid navigation regression evidence, but it is not equivalent to a player actually using Recon/Infantry through the North corridor to gain information/LOS/positioning and then making a different battle decision.

NORTH_ROUTE_VALUE_VISIBLE=NOT_PROVEN_IN_COMPLETE_PLAYER_FLOW

### South

Run C physically moves IFV/Supply to the South corridor and verifies stable vehicle movement, but then pulls the force back west before entering the shared central-combat script. The evidence therefore proves South mobility but not enough of the intended different engagement angle / tempo tradeoff in the complete battle.

SOUTH_ROUTE_VALUE_VISIBLE=PARTIAL_MOVEMENT_VALUE_ONLY

ROUTES_FEEL_MEANINGFULLY_DIFFERENT=NOT_PROVEN_AT_PLAYER_FLOW_LEVEL  
ROUTE_IDENTITY_PLAYER_VALUE_PASS=BLOCKED

## 7. Combined Arms audit

The runtime supports distinct capabilities and the harness exercises multiple roles, but the final evidence distorts some intended role value:

- IFV carries a large share of initial combat through repeated kiting;
- Logistics is explicitly used as a pre-capture Armor screen / displacement tool rather than primarily as sustain support;
- Infantry/Recon can be pre-positioned deep toward Industrial before Central capture to support the scripted success path.

This does not prove the product's combined-arms design is invalid. It means the current complete-run evidence is not sufficient to prove that normal combined-arms role identities, rather than scripted AI manipulation, are what make the run succeed.

COMBINED_ARMS_VALUE_PASS=BLOCKED_BY_EVIDENCE_STRATEGY

## 8. Reserve / Hold Fire / tempo qualification

The bound evidence proves both Reserve types can be committed and that Hold Fire/Weapons Free semantics work through real input.

However, final product-value claims remain qualified:

RESERVE_DECISION_VALUE_PASS=PARTIAL_MECHANICAL_USE_PROVEN_STRATEGIC_VALUE_NOT_FINAL  
HOLD_FIRE_TACTICAL_VALUE_PASS=PARTIAL_BEHAVIORAL_USE_PROVEN

Recorded automated match durations are:

- Run A: 90.78 simulation seconds
- Run B: 94.38 simulation seconds
- Run C: 122.90 simulation seconds

These establish that the battle is not structurally stalled. They are not sufficient to certify human battle tempo because the driver uses deterministic automated input and high-frequency reactive commands.

BATTLE_TEMPO_COHERENCE=BLOCKED_FOR_FINAL_HUMAN_FLOW_JUDGMENT

## 9. Frozen contract preservation

The progression-fix QA Gate already independently closed the Option A semantic change and verified:

- Central first capture remains 15 seconds;
- Reserve unlock remains first completed PLAYER Central capture;
- RED Armor values remain unchanged;
- damage matrix remains unchanged;
- Staging, FOW, Route geometry, Supply, ADVANCE, HOLD FIRE, Victory/Defeat and seeded posture contracts remain unchanged except for the narrow pre-first-Central Armor commitment gate.

No later gameplay drift exists.

FROZEN_CONTRACT_PRESERVED=YES

## 10. Gate judgment

CONSTRUCTION_CORRECTNESS=PASS  
PRODUCT_CORRECTNESS=BLOCKED_FINAL_PLAYER_VALUE_NOT_PROVEN  
PLAYER_FLOW_CORRECTNESS=BLOCKED_FINAL_HUMAN_REASONABLENESS_NOT_PROVEN  
FIRST_CENTRAL_PROGRESSION_ROBUSTNESS=PASS  
BATTLE_TEMPO_COHERENCE=BLOCKED  
COMMANDER_FANTASY_PASS=BLOCKED  
COMBINED_ARMS_VALUE_PASS=BLOCKED  
ROUTE_IDENTITY_PLAYER_VALUE_PASS=BLOCKED  
RESERVE_DECISION_VALUE_PASS=PARTIAL  
SOFTLOCK_PASS=PASS  
RUNTIME_STABILITY_PASS=PASS  
EVIDENCE_SUFFICIENCY=FAIL_FOR_FINAL_PRODUCT_GATE

QA_GATE_RESULT=BLOCKED  
READY_FOR_VISUAL_FINALIZATION=NO

## 11. Required next evidence

The next action is NOT another gameplay redesign and NOT a rollback of Option A.

The missing evidence is a human-reasonable integrated player-flow validation using the existing frozen gameplay baseline.

The validation must demonstrate at least one complete A/B/C sequence without relying on:

- Logistics as a deliberate Armor aggro/screen exploit;
- pre-positioning units at exact future-objective coordinates using scripted hidden knowledge;
- sub-second or approximately one-second reactive order loops;
- raw RED object references to choose tactical targets before legal player intel would identify them;
- repeated automated damage-serial reactions that a normal Formation-level commander would not issue manually.

It must also prove North and South route value through actual player movement and battle decisions rather than path-query-only assertions.

NEXT_ACTION=MATERIALIZE_BATTLE01_HUMAN_REASONABLE_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1  
NEXT_OWNER=LOCAL_GODOT_EXECUTOR  
RETURN_TO=WINDOW_07_INTEGRATION_QA_PERFORMANCE

If a human-reasonable run cannot cross the current battle without the scripted techniques above, then that result becomes direct evidence for a real product-design rework and must be routed to Window 01. Until that experiment is executed, Window 07 must not infer that the frozen gameplay itself is necessarily defective.

BLOCKER=FINAL_INTEGRATED_PRODUCT_VALUE_CANNOT_BE_CERTIFIED_FROM_CURRENT_HIGH_FREQUENCY_SCRIPTED_AND_ROUTE_QUERY_HEAVY_AUTOMATED_SUCCESS_EVIDENCE  
ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
