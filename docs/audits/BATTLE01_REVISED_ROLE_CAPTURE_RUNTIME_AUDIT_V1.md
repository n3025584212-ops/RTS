# BATTLE01 Revised Role Capture — Godot 4.7.1 Runtime Audit V1

| Field | Value |
|---|---|
| TASK_ID | RUN_AND_PUBLISH_REVISED_ROLE_CAPTURE_GODOT_4_7_1_RUNTIME_EVIDENCE_V1 |
| TESTED_GAMEPLAY_COMMIT | 88a50429a8e7b5d7a56cde2eb291925b32470ed0 |
| GODOT_VERSION | 4.7.1.stable.official.a13da4feb |
| TEST_TIME | 2026-08-25 |
| RESULT | **FAIL** |

---

## 实际执行命令与 EXIT_CODE

### 1. 仓库同步

```
git remote -v
  origin  https://github.com/n3025584212-ops/-.git (fetch/push)
git fetch --all  →  EXIT_CODE=0
```

### 2. 工作树创建

```
git worktree add .../role_capture_88a5042 88a50429a8e7b5d7a56cde2eb291925b32470ed0
  HEAD=88a50429a8e7b5d7a56cde2eb291925b32470ed0
  TRACKED_WORKTREE_BEFORE=CLEAN
```

### 3. Godot 版本确认

```
Godot --version → 4.7.1.stable.official.a13da4feb  EXIT_CODE=0
```

### 4. 项目 Parse / Boot

```
--headless --editor --path . --quit  →  EXIT_CODE=0 (process started, scripts had errors)
--headless --import --path .         →  EXIT_CODE=0 (import done, script compilation FAILED)
--headless --path . --quit-after 300 →  EXIT_CODE=0 (engine exited, Battle01 never loaded)
```

### 5-9. Smoke 测试

全部未能执行。所有 smoke 脚本依赖 FormationDefinition → BattleFormation 脚本链，该链因编译错误无法加载。

| 测试 | 结果 |
|---|---|
| battle01_role_capture_v2_smoke.gd | BLOCKED |
| formal_combat_roster_smoke.gd | BLOCKED |
| battle01_logistics_flow_smoke.gd | BLOCKED |
| battle01_enemy_ai_final_objective_smoke.gd | BLOCKED |
| battle01_3d_foundation_smoke.gd | BLOCKED |
| 最低真实玩家流程 | BLOCKED |

---

## 阻塞错误详情

### BLOCKER: formation_definition.gd 编译失败

```
SCRIPT ERROR: Parse Error: Assigned value for constant "VALID_TARGET_CLASSES" isn't a constant expression.
   at: GDScript::reload (res://scripts/battle01/formation_definition.gd:4)
```

**文件**: scripts/battle01/formation_definition.gd
**行号**: 4
**问题代码**:

```gdscript
const VALID_TARGET_CLASSES := PackedStringArray([
    "SOFT",
    "LIGHT_ARMOR",
    "HEAVY_ARMOR",
    "LOGISTICS",
])
```

**原因**: Godot 4.7.1 不允许将 PackedStringArray([...]) 构造函数调用作为 const 的值。PackedStringArray() 构造不是编译期常量表达式。

**级联影响**:

1. FormationDefinition 编译失败
2. BattleFormation (依赖 FormationDefinition) 编译失败
3. battle01.gd (依赖 BattleFormation 等 13+ 个类) 编译失败
4. Battle01.tscn 无法实例化
5. 所有测试脚本无法运行
6. 整个 Battle01 runtime 完全不可用

**同时存在于 main HEAD**: 当前 main (8012389) 的 formation_definition.gd 包含完全相同的错误代码。main 也无法启动 Battle01。

---

## 汇总

| 检查项 | 结果 |
|---|---|
| BATTLE01_BOOT | FAIL |
| 3D_FOUNDATION_BOOT | BLOCKED |
| ROLE_DAMAGE_RUNTIME | BLOCKED |
| OBJECTIVE_CAPTURE_CONTEST_RUNTIME | BLOCKED |
| SOFTLOCK_REGRESSION | BLOCKED |
| FORMAL_ROSTER_REGRESSION | BLOCKED |
| LOGISTICS_REGRESSION | BLOCKED |
| ENEMY_AI_REGRESSION | BLOCKED |
| 3D_FOUNDATION_REGRESSION | BLOCKED |
| REAL_PLAYER_FLOW | BLOCKED |

| 字段 | 值 |
|---|---|
| BLOCKING_RUNTIME_ERRORS | SCRIPT ERROR: formation_definition.gd:4 const PackedStringArray not constant expr |
| TRACKED_GAME_FILES_CHANGED_DURING_VALIDATION | NO |
| QA_ONLY_TEST_FILE_ADDED | NO |
| PRODUCTION_GAMEPLAY_FILES_CHANGED | NO |

---

## Cleanup

- 临时 worktree role_capture_88a5042 待删除
- 未生成完整日志包、截图包或中间产物
- 无 gameplay 文件被修改

---

## NEXT

```
NEXT_ACTION=FIX_REVISED_ROLE_CAPTURE_RUNTIME_BLOCKERS_V1
NEXT_OWNER=根据实际失败代码所属窗口
BLOCKER=formation_definition.gd:4 const PackedStringArray([...]) is not a constant expression in Godot 4.7.1
```
