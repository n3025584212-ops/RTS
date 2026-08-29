# Battle01 Pre-Reserve Central Progression Fix — Implementation Audit V1

TASK_ID=IMPLEMENT_BATTLE01_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_V1

ENGINE=Godot 4.7.1.stable.official.a13da4feb

START_COMMIT=40aad161aab899a2ecdf9c0bb23e901d454937c9

SYNCED_IMPLEMENTATION_CANDIDATE=a3b7be4e4dc786e619e870fd604fe076a2131dc9

FINAL_GAMEPLAY_COMMIT=439c415bebde407862838ccb7cc533186e86d014

FILES_CHANGED=tests/battle01_integrated_player_flow_evidence.gd,tests/battle01_pre_reserve_central_progression_fix_smoke.gd

PRIMARY_FIX_OPTION=A

PRE_FIRST_CAPTURE_ARMOR_GATE_IMPLEMENTED=YES
OBJECTIVE_EMERGENCY_BYPASS_CLOSED=YES
INFANTRY_DEAD_COMMIT_BYPASS_CLOSED=YES

ARMOR_LOCAL_SELF_DEFENSE_PASS=PASS
ARMOR_REAR_SECURITY_PASS=PASS
PURSUIT_LEASH_PASS=PASS

FIRST_CENTRAL_15S_PRESERVED=YES
RESERVE_TRIGGER_PRESERVED=YES
FORMATION_VALUES_PRESERVED=YES
DAMAGE_MATRIX_PRESERVED=YES

POST_FIRST_CAPTURE_COUNTERATTACK_PASS=PASS

RUN_A_POSTURE=BRIDGE_LOCK
RUN_A_CENTRAL_CAPTURE=PASS
RUN_A_RESERVE_UNLOCK=PASS
RUN_A_RESERVE_ARMOR_COMMIT=PASS
RUN_A_COUNTERATTACK_REACHED=PASS
INTEGRATED_RUN_A_PASS=PASS

RUN_B=VICTORY
RUN_C=VICTORY
POSTURE_SEQUENCE=A_B_C_A_PASS
DEFEAT_CONTROL=PASS

ENEMY_AI_REGRESSION=PASS
FOW_REGRESSION=PASS
ROUTE_REGRESSION=PASS
SEEDED_POSTURE_REGRESSION=PASS
ADVANCE_HOLD_FIRE_REGRESSION=PASS
RESUPPLY_REGRESSION=PASS
OBJECTIVE_REGRESSION=PASS
VICTORY_DEFEAT_REGRESSION=PASS

BLOCKING_RUNTIME_ERRORS=NONE

KNOWN_LIMITATIONS=NONE

RESULT=PASS
READY_FOR_WINDOW_07=YES
BLOCKER=NONE

## Scope and classification

The production implementation was already present at the synced candidate. The original integrated harness still required destruction of the intact pre-capture RED Armor before attempting Central, which contradicted the frozen Option A progression. The failure was classified as `TEST_STRATEGY_STALE_AFTER_FROZEN_PRODUCT_FIX`. The evidence strategy was updated without changing production AI, formation values, objective timings, or balance.

The focused smoke had one parse-only test defect: `pass` was used as a local identifier under Godot 4.7.1. It was renamed to `scenario_pass`; scenario semantics were unchanged.

## Real runtime evidence

- Godot version: `4.7.1.stable.official.a13da4feb`.
- Headless import, editor parse, and Battle01 boot preflights exited 0 with no blocking runtime errors.
- Focused command: `Godot --headless --path . --script res://tests/battle01_pre_reserve_central_progression_fix_smoke.gd`.
- Focused result: exit 0; all nine required progression, self-defense, rear-security, pursuit-leash, post-capture counterattack, and final PASS markers present.
- Integrated command: `Godot --headless --path . --fixed-fps 60 --script res://tests/battle01_integrated_player_flow_evidence.gd`.
- Integrated result: exit 0; formal log `C:\Users\念\FRONTLINE_RUNTIME_VERIFY\integrated_formal28.stdout.log`; stderr empty.
- Integrated Run A: `BRIDGE_LOCK`, Central capture PASS, reserve unlock PASS, real Armor HUD commit PASS, counterattack reached PASS, victory at 90.78 simulation seconds.
- Integrated Run B: `VILLAGE_SCREEN`, Infantry reserve, victory at 94.38 simulation seconds.
- Integrated Run C: `SOUTH_SCREEN`, Armor reserve, victory at 122.90 simulation seconds.
- Restart sequence: `A -> B -> C -> A` PASS.
- Defeat control: normal defeat flow PASS.
- Real viewport input was retained for staging, selection, orders, Hold Fire / Weapons Free, resupply, reserve-button commitment, objective progression, and restart flow. No force-objective, forced damage, teleport, HP mutation, capture-time mutation, time-scale override, seed override, direct kill, or direct signal shortcut was added.

## Frozen-value audit

- `scenes/battle01/Battle01.tscn`: Central `capture_time = 15.0`.
- `scripts/battle01/player_war_flow.gd`: reserve unlock remains guarded by the first completed player `CentralBridgehead.capture_completed` event.
- `resources/formations/tank.tres`: HP 280, damage 45, range 300, fire interval 1.50, ammo 16, capture false, contest true.
- `scripts/battle01/formation.gd`: damage multipliers are unchanged from the task start commit.
- The four frozen files above have no diff between `40aad161aab899a2ecdf9c0bb23e901d454937c9` and `a3b7be4e4dc786e619e870fd604fe076a2131dc9`, and this closure commit changes test files only.

## Regression evidence

The following standalone Godot scripts all exited 0 without blocker signatures:

- `battle01_seeded_red_defense_postures_smoke.gd`
- `battle01_route_identity_terrain_los_smoke.gd`
- `battle01_advance_hold_fire_commands_smoke.gd`
- `battle01_primary_ifv_move_advance_integration_smoke.gd`
- `battle01_resupply_red_logistics_smoke.gd`
- `battle01_enemy_ai_final_objective_smoke.gd`
- `battle01_role_capture_v2_smoke.gd`
- `formal_combat_roster_smoke.gd`
- `battle01_logistics_flow_smoke.gd`
- `battle01_3d_foundation_smoke.gd`
- `battle01_pre_battle_staging_smoke.gd`

The existing `--battle01-ci-enemy-ai-smoke`, `--battle01-ci-navigation-smoke`, `--battle01-ci-intel-combat-smoke`, and `--battle01-ci-multi-command-smoke` entry points also exited 0 without blocker signatures.
