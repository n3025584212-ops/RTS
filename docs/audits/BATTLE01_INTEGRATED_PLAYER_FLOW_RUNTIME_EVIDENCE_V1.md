# BATTLE01 INTEGRATED PLAYER FLOW RUNTIME EVIDENCE V1

TASK_ID=MATERIALIZE_AND_RUN_BATTLE01_INTEGRATED_PLAYER_FLOW_EVIDENCE_V1  
OWNER=LOCAL_GODOT_EXECUTOR  
PROJECT=FRONTLINE  
SOURCE_OF_TRUTH=GITHUB_MAIN  
EVIDENCE_STATUS=INTEGRATED_RUNTIME_BLOCKER_FOUND

ENGINE=Godot 4.7.1.stable.official.a13da4feb  
START_COMMIT=ebc09cefb4491f309ab04dfa35c0530cb96ad356  
EVIDENCE_TEST_COMMIT=095ecac41772e05dafa621375d3255e5da71fcaa  
PRODUCT_GAMEPLAY_FILES_CHANGED=NO

## 1. Decision

The required normal-session Run A cannot pass the first mandatory progression hinge with the frozen runtime state. The integrated runner therefore stopped under the task's explicit product-blocker exit rule. It did not alter Formation values, damage, speed, capture time, objective radius, AI behavior, route geometry, FOW, Reserve, Victory, Defeat, or any other gameplay rule.

RESULT=INTEGRATED_RUNTIME_BLOCKER_FOUND  
BLOCKER=RUN_A_NORMAL_PLAYER_FLOW_LOSES_CAPTURE_CAPABLE_COMBAT_POWER_AT_THE_PRE_RESERVE_RED_ARMOR_GATE_BEFORE_THE_15S_CENTRAL_CAPTURE_CAN_COMPLETE  
NEXT_ACTION=RERUN_BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_GATE_V1  
NEXT_OWNER=WINDOW_07_INTEGRATION_QA_PERFORMANCE

This artifact is runtime evidence only. `docs/audits/BATTLE01_INTEGRATED_VERTICAL_SLICE_PLAYER_FLOW_QA_GATE_V1.md` remains unchanged and BLOCKED. No Visual Finalization authorization is created.

## 2. Real-Godot preflight

| Check | Command | Exit | Result |
|---|---|---:|---|
| Engine identity | `Godot_v4.7.1-stable_win64_console.exe --version` | 0 | `4.7.1.stable.official.a13da4feb` |
| Import | `Godot --headless --import --path .` | 0 | PASS |
| Editor load | `Godot --headless --editor --path . --quit` | 0 | PASS |
| Real Battle01 boot | `Godot --headless --path . --quit-after 30` | 0 | `FRONTLINE_BOOT_OK`, normal run seed 0, PRE-BATTLE STAGING and 3D input ready |

IMPORT=PASS  
EDITOR_LOAD=PASS  
REAL_BATTLE01_BOOT=PASS  
BLOCKING_RUNTIME_ERRORS=NO

## 3. Evidence harness authority

The runner is `tests/battle01_integrated_player_flow_evidence.gd`.

Formal player actions use `Input.parse_input_event()` with real mouse/key events. The observed routing is:

`SceneTree -> Window/Viewport -> Control GUI or Battle3DInput -> SelectionController -> PlayerWarFlow`.

The runner uses real LMB selection, Shift+LMB additive selection, formation drag placement, RMB MOVE, Shift+RMB ADVANCE, keyboard command input, HUD button clicks, START BATTLE, and RESTART. It reads runtime state only for evidence, conditions, timing, FOW checks, stability checks, and watchdog context.

The integrated invocation used no `--battle01-seed`, no environment seed, no test seed forcing, no objective forcing, no signal emission, no teleport, no HP mutation, no direct kill, no Reserve shortcut, no progression shortcut, no `Engine.time_scale`, and no frozen-value mutation.

INTEGRATED_COMMAND=`Godot --headless --path . --fixed-fps 60 -s res://tests/battle01_integrated_player_flow_evidence.gd`  
REAL_VIEWPORT_INPUT=PASS  
STAGING_FLOW=PASS  
NORMAL_SESSION_SEED_SELECTION=PASS_SEED_0_BRIDGE_LOCK  
FORBIDDEN_GAMEPLAY_SHORTCUTS_USED=NO

## 4. Formal Run A blocker evidence

RUN_A_RESULT=BLOCKED_PRE_RESERVE_CENTRAL_PROGRESSION  
RUN_A_POSTURE=BRIDGE_LOCK  
RUN_A_RESERVE=NOT_UNLOCKED  
RUN_A_VICTORY=NO  
RUN_A_ROUTE_PLAN=CENTRAL_TEMPO  
RUN_A_TERMINAL_RESULT=FRONTLINE_DEFEAT

The runner began in normal PRE-BATTLE STAGING, redeployed all four BLUE Formations using real formation drags, queued real initial MOVE and ADVANCE orders, and clicked the real START BATTLE button. Camera navigation to the east/Industrial area during staging did not reveal hidden RED truth.

The best retained formal trace separated the first progression problem into two phases:

1. BLUE used normal MOVE/ADVANCE commands and formation-aware navigation to clear both initial RED Infantry formations. No test damage or ownership shortcut was used.
2. At the start of the mandatory RED Armor phase, the live state was:

| Formation | Alive | HP | Ammo | Fire serial | Position |
|---|---|---:|---:|---:|---|
| BLUE RECON-01 | YES | 70/70 | 18/18 | 0 | `(540,500)` |
| BLUE IFV-01 | YES | 70/180 | 20/28 | 8 | `(820,700)` |
| BLUE INF-01 | YES | 100/100 | 24/24 | 0 | `(500,1220)` |
| BLUE SUPPLY-01 | YES | 120/120 | N/A | 0 | `(340,1220)` |
| RED INF-01 | NO | 0/100 | 16/24 | 8 | `(1203,780)` |
| RED INF-02 | NO | 0/100 | 21/24 | 3 | `(1414,700)` |
| RED ARMOR-01 | YES | 280/280 | 16/16 | 0 | `(1900,900)` |

The subsequent real-input fire rotation and movement-only disengagement reduced `RED ARMOR-01` only to `238/280`. BLUE then lost legal capture-capable combat power before Central could complete. The maximum Central progress observed across legal iterations was `0.301`; the bound final trace terminated with `owner=AI`, `contested=false`, `progress=0.089`, followed by the formal `FRONTLINE_DEFEAT` path.

The frozen combat relation explains the repeatability of the gate:

- BLUE continuous anti-heavy damage at the phase's best preserved composition is approximately `24.5 HP/s` before losses (`IFV 13/0.8s`, `Infantry 5/0.9s`, `Recon 2/0.75s`).
- A full-health `RED ARMOR-01` therefore needs approximately `11.4s` of uninterrupted combined fire.
- RED Armor resolves `61` damage per hit against IFV and `41` per hit against Infantry/Recon, at a `1.5s` interval.
- Central requires an uninterrupted `15s` legal capture, while surviving RED Armor can move from its `BRIDGE_LOCK` home at `(1900,900)` toward the `(1600,900)` objective and contest well before that interval completes.
- Reserve cannot be deployed until Central is first captured, so the required Run A Armor Reserve is unavailable at the blocking phase.

This is not a focused-subsystem failure. It is an integrated progression failure produced by the interaction of frozen combat, capture, AI emergency response, and Reserve unlock rules.

## 5. Run A timing and workload

RUN_A_STAGING_DURATION=0.05s  
RUN_A_TIME_TO_FIRST_CONTACT=5.75s  
RUN_A_TIME_TO_CENTRAL_CONTEST=NOT_REACHED  
RUN_A_TIME_TO_CENTRAL_CAPTURE=NOT_REACHED  
RUN_A_TIME_TO_COUNTERATTACK=NOT_REACHED  
RUN_A_TIME_TO_RESERVE_USE=NOT_REACHED  
RUN_A_TIME_TO_INDUSTRIAL_CONTACT=33.42s  
RUN_A_TOTAL_MATCH_DURATION=94.90s

RUN_A_ORDER_COUNT_MOVE=15  
RUN_A_ORDER_COUNT_ADVANCE=6  
RUN_A_ORDER_COUNT_HOLD_FIRE=0  
RUN_A_ORDER_COUNT_WEAPONS_FREE=0  
RUN_A_ORDER_COUNT_RESUPPLY=0  
RUN_A_ORDER_COUNT_WITHDRAW=0  
RUN_A_ORDER_COUNT_RESERVE=0  
RUN_A_TOTAL_COMMAND_COUNT=21

RUN_A_RECON_FIRE_DELTA=3  
RUN_A_INFANTRY_FIRE_DELTA=2  
RUN_A_IFV_FIRE_DELTA=10  
RUN_A_MOVE_FIRE_DELTA=0  
RUN_A_ADVANCE_FIRE_DELTA=10  
RUN_A_RED_SUPPLY_PLAYER_PRESSURE_OBSERVED=YES

## 6. Required sequence fields after blocker stop

The task requires stopping rather than changing product code when the integrated match cannot be completed. Consequently Run B, Run C, the fourth A posture confirmation, and the dedicated Defeat Control were not executed as formal evidence after Run A established the blocker.

RUN_B_RESULT=NOT_EXECUTED_STOP_ON_INTEGRATED_RUNTIME_BLOCKER  
RUN_B_POSTURE=NOT_CONSUMED  
RUN_B_RESERVE=NOT_REACHED  
RUN_B_VICTORY=NO  
RUN_B_TIMING_ALL=NOT_AVAILABLE

RUN_C_RESULT=NOT_EXECUTED_STOP_ON_INTEGRATED_RUNTIME_BLOCKER  
RUN_C_POSTURE=NOT_CONSUMED  
RUN_C_RESERVE=NOT_REACHED  
RUN_C_VICTORY=NO  
RUN_C_TIMING_ALL=NOT_AVAILABLE

RUN_D_POSTURE=NOT_CONSUMED  
POSTURE_SEQUENCE=BRIDGE_LOCK_ONLY_THEN_STOP  
POSTURE_SEQUENCE_PASS=NO_BLOCKED_AT_RUN_A  
DEFEAT_CONTROL_RESULT=NOT_EXECUTED_STOP_ON_INTEGRATED_RUNTIME_BLOCKER

## 7. Integrated requirement status

STAGING_FLOW=PASS  
REAL_VIEWPORT_INPUT=PASS  
FOW=PASS_IN_EXECUTED_SCOPE  
FORMATION_AWARE_MOBILITY=PASS_IN_EXECUTED_SCOPE  
MOVE_ADVANCE_DISTINCTION=PASS_IN_RUN_A  
HOLD_FIRE=NOT_EXECUTED_RUN_B_NOT_REACHED  
BLUE_RESUPPLY=NOT_REACHED  
RED_LOGISTICS=PASS_PLAYER_PRESSURE_OBSERVED_IN_RUN_A  
CENTRAL_OBJECTIVE=BLOCKED_BEFORE_FIRST_PLAYER_CAPTURE  
COUNTERATTACK=NOT_REACHED  
RESERVE=LOCK_CONFIRMED_COMMIT_NOT_REACHED  
INDUSTRIAL_FINAL=NOT_REACHED  
VICTORY=NO  
DEFEAT=PASS_AS_NATURAL_RUN_A_TERMINAL_RESULT_NOT_DEDICATED_CONTROL  
RESTART=NOT_EXECUTED_AFTER_STOP

CENTRAL_ROUTE_VALUE_VISIBLE=PARTIAL_APPROACH_AND_CONTACT_VALUE_VISIBLE_BUT_ROUTE_CANNOT_COMPLETE_PROGRESSION  
NORTH_ROUTE_VALUE_VISIBLE=NOT_FORMALLY_EVALUATED_RUN_B_NOT_REACHED  
SOUTH_ROUTE_VALUE_VISIBLE=NOT_FORMALLY_EVALUATED_RUN_C_NOT_REACHED

COMMANDER_FANTASY_OBSERVATION=BLOCKED_BECAUSE_THE_FIRST_DECISION_HINGE_CANNOT_REACH_RESERVE  
COMBINED_ARMS_OBSERVATION=RECON_INTEL_IFV_ANTI_INFANTRY_AND_INFANTRY_CAPTURE_PRESERVATION_ARE_VISIBLE_BUT_INSUFFICIENT_TO_CROSS_PRE_RESERVE_ARMOR_GATE  
BATTLE_TEMPO_OBSERVATION=CONTACT_AND_COMBAT_OCCUR_BUT_THE_MATCH_COLLAPSES_AT_94.90S_BEFORE_CENTRAL_CAPTURE

SOFTLOCK_FOUND=NO  
BLOCKING_RUNTIME_ERRORS=NO  
RUNTIME_STABILITY=PASS_IN_EXECUTED_SCOPE  
NODE_COUNT_START=260  
NODE_COUNT_END=278  
NODE_COUNT_OBSERVATION=TRANSIENT_RUNTIME_NODES_PRESENT_NO_SUSTAINED_GROWTH_SEQUENCE_AVAILABLE_AFTER_BLOCKER_STOP  
DUPLICATE_REINFORCEMENT=NO  
DUPLICATE_SIGNAL_SIDE_EFFECT=NO

## 8. Focused regression matrix

All requested focused regressions were rerun after the integrated blocker trace.

| Test | Exit | Result |
|---|---:|---|
| `battle01_pre_battle_staging_smoke.gd` | 0 | PASS |
| `battle01_tactical_overview_real_viewport_input_smoke.gd` | 0 | PASS |
| `battle01_staging_tactical_overview_camera3d_smoke.gd` | 0 | PASS |
| `battle01_3d_foundation_smoke.gd` | 0 | PASS |
| `battle01_route_identity_terrain_los_smoke.gd` | 0 | PASS |
| `battle01_seeded_red_defense_postures_smoke.gd` | 0 | PASS |
| `battle01_primary_ifv_move_advance_integration_smoke.gd` | 0 | PASS |
| `battle01_advance_hold_fire_commands_smoke.gd` | 0 | PASS |
| `battle01_resupply_red_logistics_smoke.gd` | 0 | PASS |
| `battle01_enemy_ai_final_objective_smoke.gd` | 0 | PASS |
| `battle01_role_capture_v2_smoke.gd` | 0 | PASS |
| `formal_combat_roster_smoke.gd` | 0 | PASS |
| `battle01_logistics_flow_smoke.gd` | 0 | PASS |

FOCUSED_REGRESSION_PASS=YES_13_OF_13  
FOCUSED_RUNTIME_ERROR_SCAN=0

The four current CLI smokes also pass:

| CLI smoke | Exit | Result |
|---|---:|---|
| `--battle01-ci-navigation-smoke` | 0 | PASS |
| `--battle01-ci-intel-combat-smoke` | 0 | PASS |
| `--battle01-ci-multi-command-smoke` | 0 | PASS |
| `--battle01-ci-enemy-ai-smoke` | 0 | PASS |

CI_SMOKE_PASS=YES_4_OF_4  
CI_RUNTIME_ERROR_SCAN=0

## 9. Handoff

PRODUCT_GAMEPLAY_FILES_CHANGED=NO  
UPSTREAM_GATE_FILE_CHANGED=NO  
READY_FOR_VISUAL_FINALIZATION=NO  
ACTIVE_PROJECT_STATE_EXPECTED_AFTER_FINAL_COMMIT=CLEAN

Window 07 should rerun the same integrated vertical-slice gate and route the pre-Reserve RED Armor/Central progression interaction to the owner authorized to decide gameplay/balance semantics. The local executor intentionally makes no such product change.
