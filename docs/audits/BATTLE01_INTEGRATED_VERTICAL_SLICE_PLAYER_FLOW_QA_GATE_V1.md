# BATTLE01 INTEGRATED VERTICAL SLICE PLAYER FLOW QA GATE V1

TASK_ID=RUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V1  
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE  
PROJECT=FRONTLINE  
ENGINE_REQUIRED=Godot 4.7.1.stable.official.a13da4feb  
SOURCE_OF_TRUTH=GITHUB_MAIN  
START_MAIN_SHA=52b6a479b81d55b0550ca7e36b02594cb4311503  
QA_GATE_RESULT=BLOCKED

## 1. Gate purpose

This gate evaluates whether the already-frozen Battle01 subsystems form one complete playable vertical slice rather than a collection of individually passing focused systems.

The required evidence contract explicitly requires real Battle01 player-flow execution covering at least three normal-session runs (A/B/C seeded RED posture sequence), normal STAGING and START BATTLE, route-specific plans, real combat/objective progression, Reserve, resupply, Industrial final objective, Victory, a separate Defeat control run, Restart, battle-tempo observations, command workload, route value and combined-arms player value.

Focused subsystem smokes are regressions only and are not sufficient substitutes for this evidence.

## 2. Independent repository preflight

WINDOW_07 independently inspected current main and did not inherit a PASS from prior subsystem gates.

CURRENT_MAIN_AT_GATE_START=52b6a479b81d55b0550ca7e36b02594cb4311503  
PRE_BATTLE_STAGING_GATE=PASS  
ADVANCE_HOLD_FIRE_GATE=PASS  
ROUTE_IDENTITY_GATE=PASS  
SEEDED_RED_POSTURE_GATE=PASS  
RESUPPLY_RED_LOGISTICS_GATE=PASS  
ENEMY_AI_GATE=PASS  
ROLE_CAPTURE_GATE=PASS

No repository artifact matching a complete integrated RUN_A / RUN_B / RUN_C player-flow result was present at gate start. Existing `tests/` assets are focused subsystem/regression smokes and behavior evidence, not the required complete-playthrough evidence.

INTEGRATED_PLAYER_FLOW_HARNESS_PRESENT=NO  
RUN_A_COMPLETE_RUNTIME_EVIDENCE=ABSENT  
RUN_B_COMPLETE_RUNTIME_EVIDENCE=ABSENT  
RUN_C_COMPLETE_RUNTIME_EVIDENCE=ABSENT  
DEFEAT_CONTROL_COMPLETE_RUNTIME_EVIDENCE=ABSENT  
BATTLE_TEMPO_THREE_RUN_DATA=ABSENT  
COMMAND_WORKLOAD_THREE_RUN_DATA=ABSENT

## 3. Static reachability preflight

Static inspection does not reveal a new mandatory design/runtime blocker that would make the integrated flow impossible by construction.

### Seeded posture / Restart

`BattleFormalCombatRoster` keeps a static normal-player session run index. A real current Battle01 scene consumes the sequence with seed `run_index % 3`, then increments modulo 3. The formal posture mapping is:

- seed 0 -> BRIDGE_LOCK
- seed 1 -> VILLAGE_SCREEN
- seed 2 -> SOUTH_SCREEN

`Battle01._on_restart_requested()` reloads the current scene, so a normal session is structurally capable of A -> B -> C -> A across restarts.

POSTURE_SEQUENCE_STATIC_REACHABILITY=PASS

### Central -> Reserve / Industrial

On the first PLAYER capture of Central Bridgehead, `BattlePlayerWarFlow` sets first-capture state, unlocks the one reserve commitment, and unlocks PLAYER capture of Industrial Objective.

CENTRAL_TO_RESERVE_STATIC_REACHABILITY=PASS  
CENTRAL_TO_INDUSTRIAL_STATIC_REACHABILITY=PASS

### Victory / Defeat

Victory requires both Central and Industrial owned by PLAYER and uncontested. Defeat occurs when no living friendly capture-capable formation remains, except that an unlocked/uncommitted reserve preserves recoverability because Infantry remains available as the one reserve choice.

VICTORY_STATIC_REACHABILITY=PASS  
DEFEAT_STATIC_REACHABILITY=PASS

These checks establish only code-path reachability. They do not establish real player-flow correctness, tempo, route value, combined-arms value, absence of emergent softlocks, or runtime stability during complete matches.

## 4. Required real-runtime evidence is unavailable in this Window 07 execution

The active Window 07 execution environment has no local Godot binary and no local RTS worktree capable of running the required complete Battle01 matches. Repository inspection also found no already-materialized complete-playthrough evidence satisfying this gate.

WINDOW_07_REAL_GODOT_REEXECUTION=UNAVAILABLE  
BOUND_COMPLETE_PLAYTHROUGH_EVIDENCE=NONE

The previous real-Godot subsystem evidence cannot be composed into an integrated-player-flow PASS because this gate explicitly requires the interactions among those systems to be observed in the same complete matches.

## 5. Gate fields

RUN_A_RESULT=NOT_EXECUTED_EVIDENCE_UNAVAILABLE  
RUN_A_POSTURE=UNVERIFIED_RUNTIME  
RUN_A_ROUTE_PLAN=CENTRAL_TEMPO_REQUIRED  
RUN_A_RESERVE=UNVERIFIED_RUNTIME  
RUN_A_VICTORY_DEFEAT=UNVERIFIED_RUNTIME

RUN_B_RESULT=NOT_EXECUTED_EVIDENCE_UNAVAILABLE  
RUN_B_POSTURE=UNVERIFIED_RUNTIME  
RUN_B_ROUTE_PLAN=NORTH_INFORMATION_REQUIRED  
RUN_B_RESERVE=UNVERIFIED_RUNTIME  
RUN_B_VICTORY_DEFEAT=UNVERIFIED_RUNTIME

RUN_C_RESULT=NOT_EXECUTED_EVIDENCE_UNAVAILABLE  
RUN_C_POSTURE=UNVERIFIED_RUNTIME  
RUN_C_ROUTE_PLAN=SOUTH_MANEUVER_REQUIRED  
RUN_C_RESERVE=UNVERIFIED_RUNTIME  
RUN_C_VICTORY_DEFEAT=UNVERIFIED_RUNTIME

DEFEAT_CONTROL_RESULT=NOT_EXECUTED_EVIDENCE_UNAVAILABLE

POSTURE_SEQUENCE_PASS=UNVERIFIED_RUNTIME  
STAGING_FLOW_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
REAL_VIEWPORT_INPUT_PASS=PASS_IN_FOCUSED_GATE_NOT_YET_VERIFIED_IN_COMPLETE_MATCH  
FOW_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
ROUTE_IDENTITY_PASS=UNVERIFIED_PLAYER_VALUE  
FORMATION_AWARE_MOBILITY_PASS=PASS_IN_FOCUSED_GATE_NOT_YET_VERIFIED_IN_COMPLETE_MATCH  
ADVANCE_MOVE_DISTINCTION_PASS=PASS_IN_FOCUSED_GATE_NOT_YET_VERIFIED_IN_COMPLETE_MATCH  
HOLD_FIRE_PASS=UNVERIFIED_TACTICAL_VALUE_IN_COMPLETE_MATCH  
BLUE_RESUPPLY_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
RED_LOGISTICS_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
ENEMY_AI_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
CENTRAL_OBJECTIVE_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
COUNTERATTACK_PASS=UNVERIFIED_PLAYER_PRESSURE  
RESERVE_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
INDUSTRIAL_FINAL_PASS=UNVERIFIED_IN_COMPLETE_MATCH  
VICTORY_PASS=UNVERIFIED_NORMAL_PLAYER_FLOW  
DEFEAT_PASS=UNVERIFIED_NORMAL_PLAYER_FLOW  
RESTART_PASS=UNVERIFIED_COMPLETE_MATCH_SEQUENCE

CENTRAL_ROUTE_VALUE_VISIBLE=UNVERIFIED  
NORTH_ROUTE_VALUE_VISIBLE=UNVERIFIED  
SOUTH_ROUTE_VALUE_VISIBLE=UNVERIFIED

SOFTLOCK_FOUND=UNDETERMINED_NO_COMPLETE_RUN  
BLOCKING_RUNTIME_ERRORS=UNDETERMINED_NO_COMPLETE_RUN

CONSTRUCTION_CORRECTNESS=PASS_STATIC_PREFLIGHT_ONLY  
PRODUCT_CORRECTNESS=BLOCKED  
PLAYER_FLOW_CORRECTNESS=BLOCKED  
BATTLE_TEMPO_COHERENCE=BLOCKED  
COMMANDER_FANTASY_PASS=BLOCKED  
COMBINED_ARMS_VALUE_PASS=BLOCKED  
ROUTE_IDENTITY_PLAYER_VALUE_PASS=BLOCKED  
SOFTLOCK_PASS=BLOCKED  
RUNTIME_STABILITY_PASS=BLOCKED  
EVIDENCE_SUFFICIENCY=FAIL

## 6. Decision

QA_GATE_RESULT=BLOCKED  
READY_FOR_VISUAL_FINALIZATION=NO

BLOCKER=REAL_GODOT_4_7_1_COMPLETE_INTEGRATED_PLAYER_FLOW_EVIDENCE_REQUIRED_FOR_RUN_A_RUN_B_RUN_C_AND_DEFEAT_CONTROL

No gameplay semantic change is authorized by this result. The correct next action is to materialize and execute a real-Godot integrated player-flow evidence run against the exact current gameplay state, then return the evidence to Window 07 for the same gate to be rerun.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES  
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
