# Battle01 Formal Combat Roster Runtime Audit V1

## Audit identity

```text
TASK_ID=PUBLISH_BATTLE01_FORMAL_COMBAT_ROSTER_RUNTIME_AUDIT_V1
REPOSITORY=n3025584212-ops/-
BRANCH=main
TESTED_COMMIT=d5c97d024ed17b7075c9f51b6e57b680cada9ca4
TEST_TIME=2026-08-24T06:38:25+08:00
ENGINE=4.7.1.stable.official.a13da4feb
RUNTIME_RESULT=PASS
MINIMUM_SUFFICIENT_EVIDENCE=YES
EVIDENCE_BY_PERSUASIVENESS_NOT_VOLUME=YES
```

The tests below were rerun with `HEAD` exactly equal to the tested commit. The three commits between the earlier roster fix (`f71cf1a547a2d8f0d4dc48db852ce18ecee921c4`) and the tested commit changed only project governance documentation; this audit nevertheless records fresh runtime output from the tested commit rather than carrying forward results from the earlier revision.

## Runtime and worktree identity

The official Windows console launcher from the same Godot 4.7.1 distribution was used so that headless stdout and exit codes could be captured:

```powershell
$Godot = 'C:\Users\念\FRONTLINE_RUNTIME_VERIFY\godot\Godot_v4.7.1-stable_win64_console.exe'
& $Godot --version
```

Raw output and exit code:

```text
4.7.1.stable.official.a13da4feb
EXIT_CODE=0
```

Immediately before validation, `git rev-parse HEAD` returned:

```text
d5c97d024ed17b7075c9f51b6e57b680cada9ca4
```

Both before and after validation, the tracked worktree diff and index diff were empty. `git status --porcelain=v1` reported only these 13 untracked Godot UID files, all already present before synchronization and validation:

```text
?? scripts/battle01/battle01.gd.uid
?? scripts/battle01/battle_camera.gd.uid
?? scripts/battle01/battle_navigation.gd.uid
?? scripts/battle01/battlefield.gd.uid
?? scripts/battle01/formal_combat_roster.gd.uid
?? scripts/battle01/formation.gd.uid
?? scripts/battle01/formation_definition.gd.uid
?? scripts/battle01/hud.gd.uid
?? scripts/battle01/intel_tracker.gd.uid
?? scripts/battle01/objective.gd.uid
?? scripts/battle01/selection_controller.gd.uid
?? scripts/battle01/visibility_field.gd.uid
?? tests/formal_combat_roster_smoke.gd.uid
```

No tracked game, scene, script, test, resource, combat-value, AI, or navigation file was modified during validation. The audit Markdown is the only tracked file added by this publication task.

## Commands and exit codes

All commands ran from the repository root.

| Check | Command | Exit code | Blocking error-pattern hits |
|---|---|---:|---:|
| Godot version | `& $Godot --version` | 0 | N/A |
| Project parse/import | `& $Godot --headless --editor --path . --quit` | 0 | 0 |
| Battle01 main scene boot | `& $Godot --headless --path . --quit-after 120` | 0 | 0 |
| Formal combat roster smoke | `& $Godot --headless --path . --script tests/formal_combat_roster_smoke.gd` | 0 | 0 |
| Recon/LOS/combat/objective/victory regression | `& $Godot --headless --path . --quit-after 3000 -- --battle01-ci-intel-combat-smoke` | 0 | 0 |
| Multi-formation command regression | `& $Godot --headless --path . --quit-after 3000 -- --battle01-ci-multi-command-smoke` | 0 | 0 |
| Navigation and recon LOS regression | `& $Godot --headless --path . --quit-after 3000 -- --battle01-ci-navigation-smoke` | 0 | 0 |

The blocking-pattern scan covered `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, `Cannot open file`, `Invalid call`, `Invalid access`, and `FORMAL_ROSTER_SMOKE_FAIL`.

## Key raw runtime evidence

Main-scene boot and the dedicated roster smoke independently emitted the ready line. The dedicated smoke then emitted its pass marker:

```text
FRONTLINE_BOOT_OK build=BATTLE01_NAVIGATION_ROUTE_MOVEMENT_V1
FRONTLINE_FORMAL_COMBAT_ROSTER_READY enemy_infantry=2 enemy_armor=1 enemy_supply_truck=1 reinforcement_infantry=1 reinforcement_armor=1
FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS
```

The recon/LOS/combat run completed the combat, objective, and victory path:

```text
FRONTLINE_RED_DESTROYED
FRONTLINE_OBJECTIVE_CAPTURED objective=CentralBridgehead
FRONTLINE_VICTORY
FRONTLINE_TERRAIN_LOS_SMOKE_PASS
FRONTLINE_COMBAT_SMOKE_PASS
```

The multi-formation command run emitted:

```text
FRONTLINE_BOX_MULTI_SELECTED count=2
FRONTLINE_GROUP_MOVE_ISSUED count=2
FRONTLINE_COMBAT_STARTED
FRONTLINE_RED_DESTROYED
FRONTLINE_OBJECTIVE_CAPTURED objective=CentralBridgehead
FRONTLINE_VICTORY
FRONTLINE_MULTI_FORMATION_COMMAND_SMOKE_PASS
```

The navigation run emitted all required route, blocker, multi-formation navigation, and recon LOS regression markers:

```text
FRONTLINE_CENTRAL_ROUTE_PASS length=1929.7
FRONTLINE_NORTH_ROUTE_PASS length=2244.5
FRONTLINE_SOUTH_ROUTE_PASS length=2894.2
FRONTLINE_RIVER_BLOCKING_PASS
FRONTLINE_FORMATION_PATH_AROUND_BLOCKER_PASS
FRONTLINE_MULTI_FORMATION_NAV_PASS
FRONTLINE_RECON_LOS_REGRESSION_PASS
FRONTLINE_NAVIGATION_SMOKE_PASS
```

## Audit conclusion

```text
VERSION_IDENTITY=PROVEN
EXECUTION_REALITY=PROVEN
FORMAL_COMBAT_ROSTER_RUNTIME=PASS
COMBAT_REGRESSION=PASS
MULTI_FORMATION_REGRESSION=PASS
NAVIGATION_REGRESSION=PASS
RECON_LOS_REGRESSION=PASS
BLOCKING_RUNTIME_ERRORS=NONE
GAME_FILES_MODIFIED_DURING_VALIDATION=NO
RESULT=PASS
```
