# FRONTLINE Archive Manifest — 2026-09-20

STATUS=EXECUTED
SOURCE=Full repository sweep on 2026-09-20 + user-approved cleanup decision (see DECISION_LOG 2026-09-20)
BASELINE_TAG=`archive/pre-cleanup-2026-09-20` (points at `7deaa2e`, the last commit carrying these files in their original paths)

## Scope

Scripts and smoke tests of the old Battle01 contract era whose wiring was removed from
`scenes/battle01/Battle01.tscn` during the M2 runtime-shell rebuild and the 2026-09-12 restart
(`docs/current/RESTART_DECISION.md`). They were unreachable from the live scene and unreferenced
by all retained code, but their test contracts still assert the pre-restart behavior.

## Moved to `archive/m2-legacy-contract/` (original subpaths preserved)

| Original path | Archived path | class_name | Reason |
|---|---|---|---|
| `scripts/battle01/enemy_ai_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/enemy_ai_controller.gd` | `BattleEnemyAIController` | Node `EnemyAIController` removed from Battle01.tscn; zero references from retained code |
| `scripts/battle01/enemy_ai_logistics_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/enemy_ai_logistics_controller.gd` | `BattleEnemyAILogisticsController` | Inherits archived `BattleEnemyAIController`; unreachable |
| `scripts/battle01/enemy_ai_pre_reserve_progression_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/enemy_ai_pre_reserve_progression_controller.gd` | `BattleEnemyAIPreReserveProgressionController` | Inherits archived chain; unreachable |
| `scripts/battle01/enemy_ai_post_capture_reinforcement_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/enemy_ai_post_capture_reinforcement_controller.gd` | `BattleEnemyAIPostCaptureReinforcementController` | Inherits archived chain; unreachable |
| `scripts/battle01/enemy_ai_route_mobility_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/enemy_ai_route_mobility_controller.gd` | `BattleEnemyAIRouteMobilityController` | Inherits archived chain; unreachable |
| `scripts/battle01/pre_battle_staging_runtime_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/pre_battle_staging_runtime_controller.gd` | `BattlePreBattleStagingRuntimeController` | Runtime subclass of retained `BattlePreBattleStagingController`; only referenced by archived tests |
| `scripts/battle01/staging_player_war_flow.gd` | `archive/m2-legacy-contract/scripts/battle01/staging_player_war_flow.gd` | `BattleStagingPlayerWarFlow` | Zero references; staging flow variant unused by live scene |
| `scripts/battle01/staging_selection_controller.gd` | `archive/m2-legacy-contract/scripts/battle01/staging_selection_controller.gd` | `BattleStagingSelectionController` | Zero references; staging selection variant unused by live scene |
| `scripts/battle01/battle_minimap.gd` | `archive/m2-legacy-contract/scripts/battle01/battle_minimap.gd` | `BattleMinimap` | Zero references anywhere in the repository |
| `tests/formal_combat_roster_smoke.gd` | `archive/m2-legacy-contract/tests/formal_combat_roster_smoke.gd` | — | Expired: expects 1 supply + 2 reinforcement units that `formal_combat_roster.gd:282-286` no longer returns |
| `tests/battle01_3d_foundation_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_3d_foundation_smoke.gd` | — | Expired: references scene nodes (`EnemyAIController`, `CentralBridgehead`, `IndustrialObjective`) no longer present in Battle01.tscn |
| `tests/battle01_role_capture_v2_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_role_capture_v2_smoke.gd` | — | Expired: references removed nodes; contradicts `tank.tres` (`can_capture=true`) |
| `tests/battle01_logistics_flow_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_logistics_flow_smoke.gd` | — | Expired: depends on removed supply runtime (`player_war_flow.gd` compat shell now returns false) |
| `tests/battle01_pre_battle_staging_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_pre_battle_staging_smoke.gd` | — | Expired: scene has no `PreBattleStaging` node; test aborts with STAGING_CONTROLLER_MISSING |
| `tests/battle01_route_identity_terrain_los_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_route_identity_terrain_los_smoke.gd` | — | Expired: depends on removed nodes (`BlueSupply` etc.) |
| `tests/battle01_seeded_red_defense_postures_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_seeded_red_defense_postures_smoke.gd` | — | Expired: expects posture names `VILLAGE_SCREEN`/`SOUTH_SCREEN`; code has `VILLAGE_WEIGHT`/`SOUTHERN_TRAP` |
| `tests/battle01_enemy_ai_final_objective_smoke.gd` | `archive/m2-legacy-contract/tests/battle01_enemy_ai_final_objective_smoke.gd` | — | Expired: depends on archived enemy-AI runtime and removed scene nodes |

## Deliberately retained (not archived)

| Path | class_name | Retention reason |
|---|---|---|
| `scripts/battle01/battle01_resupply_controller.gd` | `BattleResupplyController` | Type-referenced by retained code: `selection_controller.gd:28,52,181-182`. All call sites are null-guarded and the node is absent from the scene, so it is inert. Candidate for a follow-up decoupling commit, then archive. |
| `scripts/battle01/pre_battle_staging_controller.gd` | `BattlePreBattleStagingController` | Type-referenced by retained code: `battle_3d_input.gd:12,29` plus guarded staging hooks (`:44,67,77,81,92,108,110`). Inert at runtime. Same follow-up decoupling candidate. |

## Verification performed before the move

1. `Battle01.tscn` ext-resource script list and `PrototypeB_CommandBattle.tscn` contain none of the moved files.
2. Filename and `class_name` greps across all retained `.gd`/`.tscn`/`.tres`/`project.godot`: zero references to any moved file or class.
3. CI workflows reference only the three retained gates (`core_v1_batch1`, `core_v1_battle_navigation_compat`, `prototype_b_core_integration`); no workflow references the archived tests.
4. The two retained legacy controllers were excluded precisely because retained code type-declares their classes; moving them would have broken parsing.

## Restoration

Any archived file can be restored with:
`git checkout archive/pre-cleanup-2026-09-20 -- <original-path>`
