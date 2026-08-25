# BATTLE01 REVISED ROLE CAPTURE RUNTIME RERUN AUDIT V1

TASK_ID=RUN_FIXED_REVISED_ROLE_CAPTURE_GODOT_4_7_1_RUNTIME_V1
TESTED_GAMEPLAY_COMMIT=8d9014472892912230f5b2137f15eefb05d58573
GODOT_VERSION=4.7.1.stable.official.a13da4feb
RESULT=PASS

## 背景

上一轮 FAIL 审计（BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_AUDIT_V1.md）发现生产 blocker：
`scripts/battle01/formation_definition.gd` 中的
`const VALID_TARGET_CLASSES := PackedStringArray(...)` 在 Godot 4.7.1 下非法
（"isn't a constant expression"）。

该 blocker 已在 commit 8d9014472892912230f5b2137f15eefb05d58573
修复为 Godot 4.7.1 合法的 typed static runtime data。
本轮仅重新执行真实 Godot 4.7.1 Runtime QA，不修改任何 gameplay。

## 执行环境

- 仓库: https://github.com/n3025584212-ops/-.git
- 引擎: Godot_v4.7.1-stable_win64_console.exe（4.7.1.stable.official.a13da4feb）
- Worktree: role_capture_fixed_8d90144（detached HEAD = 8d90144）
- 测试前 `git status --porcelain=v1` = CLEAN

## 判定结果

| 项目 | 结果 |
|---|---|
| PROJECT_PARSE | PASS |
| BATTLE01_BOOT | PASS |
| ROLE_DAMAGE_RUNTIME | PASS |
| OBJECTIVE_CAPTURE_CONTEST_RUNTIME | PASS |
| SOFTLOCK_REGRESSION | PASS |
| FORMAL_ROSTER_REGRESSION | PASS |
| LOGISTICS_REGRESSION | PASS |
| ENEMY_AI_REGRESSION | PASS |
| 3D_FOUNDATION_REGRESSION | PASS |
| BLOCKING_RUNTIME_ERRORS | NONE |
| TRACKED_GAME_FILES_CHANGED_DURING_VALIDATION | NO |

## 实际命令与结果

### 1. Parse / Import

```
& $Godot --headless --import --path .   => EXIT=0
& $Godot --headless --editor --path . --quit => EXIT=0
```

- 全局类注册 25 项全部成功（含 FormationDefinition）。
- 输出无 Parse Error / SCRIPT ERROR / Failed to load script /
  Invalid call / Invalid access / Cannot open file。
- `VALID_TARGET_CLASSES isn't a constant expression` 已完全消失。

PROJECT_PARSE=PASS

### 2. Battle01 真实 Boot

```
& $Godot --headless --path . --quit-after 300   => EXIT=0
```

- 使用 project.godot 真实主场景 `res://scenes/battle01/Battle01.tscn`（非独立 Demo）。
- 场景树包含并成功初始化：World3D、BattleCamera3D、Presentation3D、Input3D、
  HUD、SelectionController、PlayerWarFlow、EnemyAIController、
  CentralBridgehead、IndustrialObjective。
- 核心 marker：
  - FRONTLINE_3D_WORLD_READY map=32x18
  - FRONTLINE_3D_PRESENTATION_READY bound=10 objectives=2
  - FRONTLINE_3D_INPUT_READY
  - FRONTLINE_WAR_FLOW_READY active_blue=4 reserve_commitments=1 objectives=2
  - FRONTLINE_ENEMY_AI_READY states=7
  - FRONTLINE_OBJECTIVE_TRACKING_READY blue=4 red=6
  - FRONTLINE_FORMATION_DEFINITIONS_READY count=6
  - FRONTLINE_BOOT_OK build=BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_V1

BATTLE01_BOOT=PASS

### 3. Role / Capture V2 Runtime

```
& $Godot --headless --path . --script res://tests/battle01_role_capture_v2_smoke.gd
=> EXIT=0
=> FRONTLINE_ROLE_CAPTURE_V2_SMOKE_PASS
```

关键 marker 全部出现：

- RECON_AMMO_18_PASS / INFANTRY_AMMO_24_PASS / IFV_AMMO_28_PASS / ARMOR_AMMO_16_PASS
- RECON_NO_CAPTURE_NO_CONTEST_PASS / INFANTRY_CAPTURE_CONTEST_PASS /
  IFV_CAPTURE_CONTEST_PASS / ARMOR_CONTEST_ONLY_PASS / LOGISTICS_NO_CAPTURE_NO_CONTEST_PASS
- RECON_VS_HEAVY_DAMAGE_PASS / INFANTRY_VS_HEAVY_DAMAGE_PASS /
  IFV_VS_SOFT_DAMAGE_PASS / IFV_VS_HEAVY_DAMAGE_PASS / ARMOR_VS_LIGHT_DAMAGE_PASS
- LIVE_ROLE_DAMAGE_APPLIED_PASS / LIVE_ROLE_DAMAGE_AMMO_COST_PASS
- RECON_CANNOT_STEAL_OBJECTIVE_PASS / INFANTRY_CAPTURE_OWNERSHIP_PASS /
  ARMOR_CANNOT_CAPTURE_OWNERSHIP_PASS / ARMOR_DENIES_ENEMY_CAPTURE_PASS
- UNUSED_INFANTRY_OPTION_PREVENTS_GROUND_CONTROL_DEFEAT_PASS /
  RESERVE_ARMOR_CONTEST_ONLY_PASS / NO_GROUND_CONTROL_SOFTLOCK_DEFEAT_PASS

ROLE_DAMAGE_RUNTIME=PASS
OBJECTIVE_CAPTURE_CONTEST_RUNTIME=PASS
SOFTLOCK_REGRESSION=PASS

### 4. Formal Combat Roster

```
& $Godot --headless --path . --script res://tests/formal_combat_roster_smoke.gd
=> EXIT=0
=> FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS
```

- 敌军数量无变化：Enemy Infantry ×2 / Enemy Armor ×1 / Enemy Supply Truck ×1 /
  Reinforcement Infantry ×1 / Reinforcement Armor ×1
  （FRONTLINE_FORMAL_COMBAT_ROSTER_READY enemy_infantry=2 enemy_armor=1
  enemy_supply_truck=1 reinforcement_infantry=1 reinforcement_armor=1）。
- Armor: can_capture=false, can_contest=true（资源 tank.tres + smoke 内部断言）。
- Supply Truck: can_attack=false, can_capture=false, can_contest=false（logistics.tres）。

FORMAL_ROSTER_REGRESSION=PASS

### 5. Logistics Regression

```
& $Godot --headless --path . --script res://tests/battle01_logistics_flow_smoke.gd
=> EXIT=0
=> FRONTLINE_LOGISTICS_FLOW_SMOKE_PASS
```

- SUPPLY_SUCCESS_PASS / SUPPLY_MOVEMENT_INTERRUPT_PASS / SUPPLY_CHARGES_PASS /
  WITHDRAW_SUPPLY_REENTER_PASS
- BRIDGEHEAD_15S_CAPTURE_PASS / INDUSTRIAL_15S_CONTEST_PASS / DUAL_OBJECTIVE_VICTORY_PASS
- UNUSED_RESERVE_PREVENTS_DEFEAT_PASS / RESERVE_EXHAUSTED_COLLAPSE_DEFEAT_PASS

LOGISTICS_REGRESSION=PASS

### 6. Enemy AI Regression

```
& $Godot --headless --path . --script res://tests/battle01_enemy_ai_final_objective_smoke.gd
=> EXIT=0
=> FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_SMOKE_PASS
```

- AI_FINAL_OBJECTIVE_NO_PREMATURE_REACTION_PASS
- AI_FINAL_OBJECTIVE_PRESSURE_RESPONSE_PASS
- AI_FINAL_OBJECTIVE_NO_HIDDEN_BLUE_TRACKING_PASS
- AI_FINAL_OBJECTIVE_CENTRAL_DEFENSE_PRESERVED_PASS
- AI_FINAL_OBJECTIVE_COMBAT_RESPONDER_PASS
- AI_FINAL_OBJECTIVE_SUPPLY_EXCLUDED_PASS
- AI_FINAL_OBJECTIVE_REINFORCEMENT_ELIGIBLE_PASS
- AI_FINAL_OBJECTIVE_RETURN_OR_RECENTER_PASS
- AI_FINAL_OBJECTIVE_DETERMINISTIC_PASS

ENEMY_AI_REGRESSION=PASS

### 7. 3D Foundation Regression

```
& $Godot --headless --path . --script res://tests/battle01_3d_foundation_smoke.gd
=> EXIT=0
=> FRONTLINE_3D_FOUNDATION_SMOKE_PASS
```

- WORLD_3D_READY_PASS / CAMERA_3D_READY_PASS / HUD_2D_PRESERVED_PASS /
  SIM_TO_3D_ADAPTER_PASS / FORMATION_3D_BINDING_PASS / SELECTION_COMMAND_3D_MOVE_PASS /
  GAMEPLAY_SYSTEMS_REACHABLE_PASS / LEGACY_2D_WORLD_REPLACED_PASS /
  LEGACY_2D_FORMATION_PRESENTATION_HIDDEN_PASS

3D_FOUNDATION_REGRESSION=PASS

### 8. Blocking Error Scan

对全部真实运行输出（import / editor / boot / role_capture / roster / logistics /
enemy_ai / 3d_foundation）扫描：

```
SCRIPT ERROR / Parse Error / Failed to load script / Cannot open file /
Invalid call / Invalid access / isn't a constant expression
```

结果：0 命中。

BLOCKING_RUNTIME_ERRORS=NONE

### 9. 冻结玩法验证（未修改）

- AMMO: Recon=18, Infantry=24, IFV=28, Armor=16
  （recon/infantry/ifv/tank.tres ammo_capacity 实测一致）
- DAMAGE（base × multiplier）: Recon→Heavy=8×0.20→2, Infantry→Heavy=14×0.35→5,
  IFV→Soft=24×1.25→30, IFV→Heavy=24×0.55→13, Armor→Light=45×1.35→61
- CAPTURE / CONTEST: Recon=NO/NO, Infantry=YES/YES, IFV=YES/YES,
  Armor=NO/YES, Logistics=NO/NO
- CAPTURE_TIME=15.0s（objective.gd capture_time=15.0）

以上值均未修改，与冻结玩法一致。

### 10. 工作树完整性

测试结束后 `git status --porcelain=v1` 仅出现 Godot 生成的未跟踪缓存
（`*.uid`、`*.import`），无任何 tracked gameplay 文件被修改。

TRACKED_GAME_FILES_CHANGED_DURING_VALIDATION=NO

## 结论

上一轮 FAIL 的 Godot 4.7.1 解析 blocker 已修复并验证：
- 生产代码可完整 Parse / Import。
- Battle01 真实主场景可启动。
- Role/Capture V2 全流程、Formal Roster、Logistics、Enemy AI、3D Foundation
  全部回归通过。
- 无阻塞运行时错误，冻结玩法无漂移。

RESULT=PASS
