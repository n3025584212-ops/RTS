# BATTLE01 INTEGRATED VERTICAL SLICE PLAYER FLOW QA GATE V2

TASK_ID=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V1  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
QA_GATE_RESULT=REWORK_REQUIRED

START_MAIN_SHA=723d223bacfee1bf4783f164f5df30239171619f  
BOUND_RUNTIME_EVIDENCE=docs/audits/BATTLE01_INTEGRATED_PLAYER_FLOW_RUNTIME_EVIDENCE_V1.md  
EVIDENCE_TEST_COMMIT=095ecac41772e05dafa621375d3255e5da71fcaa  
EVIDENCE_FINAL_COMMIT=723d223bacfee1bf4783f164f5df30239171619f

## 1. Independent Window 07 decision

Window 07 independently reviewed the integrated runtime evidence, evidence harness, current Enemy AI decision rules, objective/Reserve progression rules, and GitHub provenance. The local executor's `INTEGRATED_RUNTIME_BLOCKER_FOUND` result is not inherited as a QA decision; this V2 gate independently classifies the observed behavior.

The previous V1 gate remains historically valid as `BLOCKED` because complete-playthrough evidence did not yet exist. V2 does not overwrite V1. New real-Godot evidence now exists and proves a product progression blocker before the first Central capture.

## 2. Evidence provenance

GitHub compare from the previous Gate commit `ebc09cefb4491f309ab04dfa35c0530cb96ad356` to evidence final commit `723d223bacfee1bf4783f164f5df30239171619f` changes only:

1. `tests/battle01_integrated_player_flow_evidence.gd`
2. `docs/audits/BATTLE01_INTEGRATED_PLAYER_FLOW_RUNTIME_EVIDENCE_V1.md`

PRODUCT_GAMEPLAY_FILES_CHANGED=NO  
EVIDENCE_PROVENANCE_PASS=YES

The evidence was executed with real `Godot 4.7.1.stable.official.a13da4feb`, normal session seed selection, real Viewport input through `Input.parse_input_event()`, no seed forcing, no objective forcing, no HP mutation, no teleport, no time-scale change, and no frozen-value mutation.

REAL_GODOT_EVIDENCE_PASS=YES  
FORBIDDEN_GAMEPLAY_SHORTCUTS_USED=NO

## 3. Run A result

RUN_A_RESULT=FAIL_PRODUCT_PROGRESSION  
RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_ROUTE_PLAN=CENTRAL_TEMPO  
RUN_A_VICTORY=NO  
RUN_A_TERMINAL_RESULT=FRONTLINE_DEFEAT

The real-input run successfully established:

- PRE-BATTLE STAGING and explicit START BATTLE
- real Viewport input
- FOW protection in the executed scope
- formation-aware movement
- MOVE versus ADVANCE distinction
- destruction of both initial RED Infantry formations
- player pressure on RED Logistics

At the pre-Reserve RED Armor gate, the preserved BLUE state was:

- BLUE IFV-01 = 70/180 HP, 20/28 ammo
- BLUE INF-01 = 100/100 HP, 24/24 ammo
- BLUE RECON-01 = 70/70 HP, 18/18 ammo
- BLUE SUPPLY-01 = 120/120 HP
- RED ARMOR-01 = 280/280 HP

Repeated legal real-input engagement reduced RED Armor only to 238/280 before BLUE lost mission-progressing capture-capable combat power. Maximum legal Central progress observed was 0.301. The formal Defeat path then triggered.

CENTRAL_OBJECTIVE_FIRST_PLAYER_CAPTURE=NOT_REACHED  
RESERVE_UNLOCK=NOT_REACHED  
INDUSTRIAL_UNLOCK=NOT_REACHED

## 4. Why this is not classified as a simple harness-strategy defect

The integrated runner did not merely execute one frontal attack. Its authored legal strategies include:

- IFV ADVANCE/fire and movement-only displacement against initial RED Infantry
- per-Formation damage-triggered withdrawal and later legal re-entry against RED Armor
- combined legal ADVANCE pressure from surviving combat Formations
- a legal Recon/Supply eastward lure attempt intended to displace RED Armor away from Central
- objective capture with only living capture-capable Formations

The production Enemy AI creates a structural defense interaction during Central progression:

- `CAPTURING`, `CONTESTED`, or `CAPTURED` Central is `objective_emergency`
- during objective emergency, combat units select objective-priority targets or move to Central
- capture-capable BLUE inside Central has priority 1
- RED Armor's normal commit restriction is bypassed by objective emergency
- RED Armor itself can contest Central

Therefore a surviving RED Armor is structurally pulled back into the first Central capture hinge and can directly suppress the capture-capable BLUE required to unlock the player's Reserve.

This evidence does not prove mathematically that no human strategy can ever win. It is sufficient, however, to prove the current required Central-first normal-player flow is not robustly playable under the frozen interaction: a reasonable combined-arms, kite/displacement-capable real-input run collapses before the first mandatory progression hinge despite no runtime fault.

HARNESS_ONLY_DEFECT_FOUND=NO  
PRODUCT_PROGRESSION_ROBUSTNESS_FAIL=YES

## 5. Cross-contract nature of the blocker

The blocker is produced by the interaction of multiple frozen authorities:

- Combat values / damage relationships
- RED Armor `LOCAL_COUNTERATTACK_RESERVE` commitment behavior
- Central 15s capture requirement and Armor contest authority
- Player Reserve unlock only after first PLAYER Central capture

Window 07 must not choose one semantic lever itself.

The correct next owner is Window 01 Game Design, which must select and freeze the minimum product change that restores a robust first Central progression hinge while preserving Battle01 scope.

Potential semantic levers that Window 01 may evaluate, but which are NOT authorized by this QA gate, include:

- RED Armor pre-Central commitment timing/mission constraint
- Central first-capture timing/contest interaction
- Player Reserve unlock timing
- frozen anti-heavy / survivability relation

No lever is preselected by Window 07.

## 6. Gate fields

RUN_A_RESULT=FAIL_PRODUCT_PROGRESSION  
RUN_B_RESULT=NOT_EXECUTED_STOP_ON_RUNTIME_BLOCKER  
RUN_C_RESULT=NOT_EXECUTED_STOP_ON_RUNTIME_BLOCKER  
DEFEAT_CONTROL_RESULT=NOT_EXECUTED_AS_DEDICATED_CONTROL

POSTURE_SEQUENCE_PASS=NO_BLOCKED_AT_RUN_A

STAGING_FLOW_PASS=PASS_IN_RUN_A  
REAL_VIEWPORT_INPUT_PASS=PASS_IN_RUN_A  
FOW_PASS=PASS_IN_EXECUTED_SCOPE  
FORMATION_AWARE_MOBILITY_PASS=PASS_IN_EXECUTED_SCOPE  
ADVANCE_MOVE_DISTINCTION_PASS=PASS  
HOLD_FIRE_PASS=NOT_REACHED  
BLUE_RESUPPLY_PASS=NOT_REACHED  
RED_LOGISTICS_PASS=PASS_PLAYER_PRESSURE_OBSERVED  
CENTRAL_OBJECTIVE_PASS=FAIL_PRE_FIRST_CAPTURE  
COUNTERATTACK_PASS=NOT_REACHED  
RESERVE_PASS=FAIL_UNLOCK_HINGE_NOT_REACHED  
INDUSTRIAL_FINAL_PASS=NOT_REACHED  
VICTORY_PASS=FAIL_NOT_REACHED  
DEFEAT_PASS=PASS_NATURAL_RUN_A_TERMINAL_PATH  
RESTART_PASS=NOT_REACHED_AFTER_BLOCKER_STOP

CENTRAL_ROUTE_VALUE_VISIBLE=PARTIAL_BUT_PROGRESSION_FAILS  
NORTH_ROUTE_VALUE_VISIBLE=NOT_EVALUATED  
SOUTH_ROUTE_VALUE_VISIBLE=NOT_EVALUATED

SOFTLOCK_FOUND=NO  
BLOCKING_RUNTIME_ERRORS=NONE  
RUNTIME_STABILITY_PASS=PASS_IN_EXECUTED_SCOPE

CONSTRUCTION_CORRECTNESS=PASS  
PRODUCT_CORRECTNESS=FAIL  
PLAYER_FLOW_CORRECTNESS=FAIL  
BATTLE_TEMPO_COHERENCE=FAIL_PRE_FIRST_HINGE  
COMMANDER_FANTASY_PASS=FAIL_FIRST_DECISION_HINGE_NOT_ROBUSTLY_REACHABLE  
COMBINED_ARMS_VALUE_PASS=FAIL_CURRENT_COMBINED_ARMS_CANNOT_ROBUSTLY_CROSS_PRE_RESERVE_ARMOR_GATE  
ROUTE_IDENTITY_PLAYER_VALUE_PASS=UNASSESSED_FULL_GATE_BLOCKED  
SOFTLOCK_PASS=PASS_NO_SOFTLOCK_FOUND  
EVIDENCE_SUFFICIENCY=PASS_FOR_REWORK_CLASSIFICATION

QA_GATE_RESULT=REWORK_REQUIRED  
READY_FOR_VISUAL_FINALIZATION=NO

## 7. Required next action

NEXT_ACTION=RESOLVE_BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_BLOCKER_V1  
NEXT_OWNER=WINDOW_01_GAME_DESIGN

Window 01 must not broadly rebalance the game. It must review this exact integrated failure and freeze one minimum semantic correction, identify the downstream implementation owner, and require the same integrated Run A evidence to be rerun before Runs B/C and Visual Finalization resume.

BLOCKER=PRE_RESERVE_RED_ARMOR_CENTRAL_PROGRESSION_INTERACTION_PREVENTS_ROBUST_FIRST_PLAYER_CENTRAL_CAPTURE_AND_THEREFORE_BLOCKS_RESERVE_AND_INDUSTRIAL_PROGRESSION  
ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
