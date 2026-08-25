# Battle01 Resupply RED Logistics Runtime Audit V1

## Audit identity

```text
TASK_ID=RUN_LOCAL_BATTLE01_RESUPPLY_RED_LOGISTICS_RUNTIME_AND_CLOSE_GAPS_V1
REPOSITORY=n3025584212-ops/-
BRANCH=main
TESTED_GAMEPLAY_COMMIT=5db464f931733c0d61025f9bbe602a0a68f69a04
IMPLEMENTATION_AUDIT_COMMIT=781a8e99959c2ee26097da5be268f02460441547
QA_GATE_COMMIT=03d8da9a6b5563dbbacce18eb13c52ce2a5b1cef
TEST_TIME=2026-08-25T18:32+08:00
ENGINE=4.7.1.stable.official.a13da4feb
RUNTIME_RESULT=PASS
EVIDENCE_BY_PERSUASIVENESS_NOT_VOLUME=YES
```

This audit does NOT overwrite `BATTLE01_RESUPPLY_RED_LOGISTICS_IMPLEMENTATION_AUDIT_V1.md`
(implementation audit) or `BATTLE01_RESUPPLY_RED_LOGISTICS_RUNTIME_QA_GATE_V1.md`
(Window 07 QA gate). It is a separate runtime evidence document.

## Runtime and worktree identity

The official Godot 4.7.1 Windows executable from the same distribution was used:

```powershell
$Godot = 'C:\Users\念\FRONTLINE_RUNTIME_VERIFY\godot\Godot_v4.7.1-stable_win64_console.exe'
& $Godot --version
```

```text
4.7.1.stable.official.a13da4feb
VERSION_EXIT_CODE=0
```

All runtime commands ran in a detached worktree pinned exactly to the gameplay commit:

```text
git worktree add "$RuntimeRoot\audit_worktrees\resupply_red_logistics_5db464f" 5db464f931733c0d61025f9bbe602a0a68f69a04
TESTED_GAMEPLAY_COMMIT=5db464f931733c0d61025f9bbe602a0a68f69a04
TRACKED_WORKTREE_BEFORE=CLEAN
```

The official `main` was synchronized first; the gameplay commit was proven to be an
ancestor of `HEAD` (`git merge-base --is-ancestor` = success), so
`GAMEPLAY_COMMIT_INCLUDED=YES`.

## Commands and exit codes

All commands ran from the pinned worktree root.

| Check | Command | Exit code | Blocking error-pattern hits |
|---|---|---:|---:|
| Godot version | `& $Godot --version` | 0 | N/A |
| Project parse/import | `& $Godot --headless --import --path .` | 0 | 0 |
| Editor parse | `& $Godot --headless --editor --path . --quit` | 0 | 0 |
| Battle01 real boot | `& $Godot --headless --path . --quit-after 300` | 0 | 0 |
| Focused smoke baseline (before QA extension) | `--script tests/battle01_resupply_red_logistics_smoke.gd` | 1 | 2 QA-harness failures (see below) |
| Focused smoke full (after QA extension) | `--script tests/battle01_resupply_red_logistics_smoke.gd` | 0 | 0 |
| Role capture v2 regression | `--script tests/battle01_role_capture_v2_smoke.gd` | 0 | 0 |
| Formal roster regression | `--script tests/formal_combat_roster_smoke.gd` | 0 | 0 |
| Logistics flow regression | `--script tests/battle01_logistics_flow_smoke.gd` | 0 | 0 |
| Enemy AI final objective regression | `--script tests/battle01_enemy_ai_final_objective_smoke.gd` | 0 | 0 |
| 3D foundation regression | `--script tests/battle01_3d_foundation_smoke.gd` | 0 | 0 |

Blocking-pattern scan covered `SCRIPT ERROR`, `Parse Error`, `Failed to load script`,
`Cannot open file`, `Invalid call`, `Invalid access` across import, editor, boot,
focused smoke and all five regression logs.

```text
BLOCKING_RUNTIME_ERRORS=NONE
```

## Baseline smoke finding (QA harness bug, not production)

The pre-extension baseline smoke failed exactly two assertions:
`BLUE_RESUPPLY_DAMAGE_INTERRUPT_PASS` and `BLUE_RESUPPLY_FIRE_INTERRUPT_PASS`.

Root cause: the QA harness placed the target and Logistics at the raw rally constant
`WEST_REAR_RALLY=(520,1080)`, while the real rendezvous is the clamped walkable grid
point `(540,1100)`. Distance ~28.3 exceeds `ARRIVAL_TOLERANCE=18.0`, so the transfer
never actually started; damage/fire were applied to a movement that had not begun and
`is_resupply_active()` stayed true.

Production interruption chain was verified complete in code: `_update_supply` checks
order != HOLD, range 140, `_damage_serial` and `_fire_serial`, then calls
`_cancel_supply` -> progress=0 with no charge consumption. This is a QA-only harness
fix, not a gameplay change.

## Battle01 real boot

```text
FRONTLINE_BOOT_OK build=BATTLE01_LOGISTICS_REINFORCEMENT_OBJECTIVE_FLOW_V1
FRONTLINE_RESUPPLY_CONTROLLER_READY
FRONTLINE_WAR_FLOW_READY active_blue=4 reserve_commitments=1 objectives=2
FRONTLINE_FORMAL_COMBAT_ROSTER_READY enemy_infantry=2 enemy_armor=1 enemy_supply_truck=1 reinforcement_infantry=1 reinforcement_armor=1
FRONTLINE_ENEMY_AI_READY states=7 combat=3 supply=1 dormant=2
FRONTLINE_3D_WORLD_READY map=32x18 river=YES bridge=YES village=YES industrial=YES
FRONTLINE_CAMERA3D_READY focus=(1050.0, 900.0) height=16.0
FRONTLINE_3D_PRESENTATION_READY bound=10 objectives=2
FRONTLINE_HUD (initialized via Battle01 scene)
FRONTLINE_3D_INPUT_READY
```

```text
PROJECT_PARSE=PASS
BATTLE01_REAL_RUNTIME=PASS
```

## Focused smoke: BLUE resupply evidence

```text
FRONTLINE_RESUPPLY_RED_LOGISTICS_SMOKE_BEGIN
FRONTLINE_RESUPPLY_INTENT target=BLUE INF-01 supplier=BLUE SUPPLY-01 rendezvous=WEST_REAR_RALLY point=(540.0, 1100.0)
BLUE_RESUPPLY_INTENT_WEST_RENDEZVOUS_PASS
FRONTLINE_RESUPPLY_RENDEZVOUS_ARRIVED target=BLUE INF-01 supplier=BLUE SUPPLY-01 rendezvous=WEST_REAR_RALLY
FRONTLINE_RESUPPLY_TRANSFER_BEGIN target=BLUE INF-01 charges=2
BLUE_RESUPPLY_TRANSFER_STARTED_PASS
FRONTLINE_SUPPLY_COMPLETE truck=BLUE SUPPLY-01 target=BLUE INF-01 ammo=0->12 restored=12 charges=1
BLUE_RESUPPLY_AMMO_50_PERCENT_CHARGE_PASS
BLUE_RESUPPLY_HP_RESTORE_DISABLED_PASS
BLUE_RESUPPLY_INTENT_COMPLETE_PASS
FRONTLINE_SUPPLY_INTERRUPTED reason=Direct MOVE override progress=1.00 charges=2
BLUE_RESUPPLY_DIRECT_MOVE_OVERRIDE_PASS
FRONTLINE_SUPPLY_INTERRUPTED reason=Target under fire progress=1.00 charges=2
BLUE_RESUPPLY_DAMAGE_INTERRUPT_PASS
FRONTLINE_SUPPLY_INTERRUPTED reason=Target fired progress=1.00 charges=2
BLUE_RESUPPLY_FIRE_INTERRUPT_PASS
FRONTLINE_RESUPPLY_REJECTED reason=No available Supply / no charges
BLUE_RESUPPLY_NO_CHARGE_REJECT_PASS
FRONTLINE_BLUE_SUPPLY_LOST charges=0
BLUE_RESUPPLY_SUPPLY_DESTROYED_PASS
FRONTLINE_RESUPPLY_INTENT target=BLUE INF-01 supplier=BLUE SUPPLY-01 rendezvous=BRIDGEHEAD_FORWARD_RALLY point=(1380.0, 1100.0)
BLUE_RESUPPLY_FORWARD_RALLY_PASS
```

## Focused smoke: RED resupply evidence

```text
FRONTLINE_RED_RESUPPLY_DECISION target=RED ARMOR-01 ammo=8/16 supplier=RED SUPPLY-01 charges=2
RED_RESUPPLY_ARMOR_PRIORITY_PASS
RED_RESUPPLY_REAR_RENDEZVOUS_PASS
FRONTLINE_RED_RESUPPLY_TRANSFER_BEGIN target=RED ARMOR-01 charges=2 duration=4.0
RED_RESUPPLY_ACTUAL_RENDEZVOUS_MOVEMENT_PASS
RED_RESUPPLY_ACTUAL_TRANSFER_PASS
FRONTLINE_RED_RESUPPLY_DECISION target=RED INF-02 ammo=4/24 supplier=RED SUPPLY-01 charges=1
RED_RESUPPLY_INFANTRY_MOST_DEPLETED_PASS
FRONTLINE_RED_RESUPPLY_DECISION target=RED INF-01 ammo=4/24 supplier=RED SUPPLY-01 charges=1
RED_RESUPPLY_STABLE_TIE_BREAK_PASS
FRONTLINE_RED_RESUPPLY_CANCELLED target=RED ARMOR-01 supplier=RED SUPPLY-01 reason=Confirmed threat near Supply progress=0.00 charges=1
FRONTLINE_AI_STATE unit=RED SUPPLY-01 state=EVADE
FRONTLINE_AI_MOVE unit=RED SUPPLY-01 state=EVADE route=central destination=(940.0, 1140.0)
RED_RESUPPLY_EVADE_OVERRIDE_PASS
FRONTLINE_AI_REINFORCEMENT_ACTIVATED reason=objective_loss infantry=1 armor=1
RED_RESUPPLY_SUPPLY_DESTROYED_FINITE_PASS
```

## New QA evidence gaps (Window 07 closure)

All five gaps are now asserted with real runtime scenarios in
`tests/battle01_resupply_red_logistics_smoke.gd`:

```text
FRONTLINE_WITHDRAW_ISSUED count=1 rally=WEST_REAR_RALLY
BLUE_RESUPPLY_DIRECT_WITHDRAW_OVERRIDE_PASS
BLUE_RESUPPLY_MOVEMENT_OR_RANGE_INTERRUPT_PASS
RED_RESUPPLY_DORMANT_REINFORCEMENT_EXCLUDED_PASS
RED_RESUPPLY_LOCAL_LULL_REQUIRED_PASS
RED_RESUPPLY_NO_HIDDEN_BLUE_INFO_PASS
```

1. `BLUE_RESUPPLY_DIRECT_WITHDRAW_OVERRIDE_PASS` - WITHDRAW issued during a live
   TRANSFERRING resupply cancels the automation (progress=0, charge unchanged) and the
   WITHDRAW order survives subsequent controller ticks (not re-grabbed).
2. `BLUE_RESUPPLY_MOVEMENT_OR_RANGE_INTERRUPT_PASS` - a normal transfer is cancelled
   and reset when the target moves (direct MOVE) or when the supplier is displaced
   beyond the legal 140 transfer range; progress=0 and no charge consumed in both
   sub-assertions.
3. `RED_RESUPPLY_DORMANT_REINFORCEMENT_EXCLUDED_PASS` - dormant reinforcements with
   ammo forced to 0 are still NOT candidates; only after formal activation
   (`_activate_reinforcements`) does the reinforcement enter ordinary candidate rules.
4. `RED_RESUPPLY_LOCAL_LULL_REQUIRED_PASS` - RED resupply does not start when the
   state is NOT a local lull: recent damage on candidate, active ENGAGE of a
   legitimately CONFIRMED BLUE, or objective emergency (CONTESTED) all reject startup
   (`target==null`, phase IDLE). This proves NOT_LOCAL_LULL -> RESUPPLY_NOT_STARTED,
   not just "cancelled after threat".
5. `RED_RESUPPLY_NO_HIDDEN_BLUE_INFO_PASS` - an UNSEEN (not CONFIRMED, outside RED
   legal knowledge) BLUE formation moved right next to the Supply truck changes
   nothing: candidate, rendezvous and startup decision stay identical. Only after the
   legal Intel pipeline raises it to CONFIRMED does RED cancel resupply and EVADE.
   RED never read the hidden BLUE global position.

## Regressions

```text
ROLE_CAPTURE_REGRESSION=PASS  (FRONTLINE_ROLE_CAPTURE_V2_SMOKE_PASS)
FORMAL_ROSTER_REGRESSION=PASS (FRONTLINE_FORMAL_COMBAT_ROSTER_SMOKE_PASS)
LOGISTICS_REGRESSION=PASS     (FRONTLINE_LOGISTICS_FLOW_SMOKE_PASS)
ENEMY_AI_REGRESSION=PASS      (FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_SMOKE_PASS)
3D_FOUNDATION_REGRESSION=PASS (FRONTLINE_3D_FOUNDATION_SMOKE_PASS)
```

## Frozen rules (verified unchanged)

```text
BLUE/RED Supply: CHARGES=2 RESTORE=50% MAX_AMMO TRANSFER=4.0s HP_RESTORE=NO
AMMO: Recon=18 Infantry=24 IFV=28 Armor=16
CAPTURE/CONTEST: Recon=NO/NO Infantry=YES/YES IFV=YES/YES Armor=NO/YES Logistics=NO/NO
CAPTURE_TIME=15s
RED roster: Infantry x2 + Armor x1 + Supply Truck x1; Dormant: Infantry x1 + Armor x1
```

No change to damage matrix, Enemy AI FOW principles, pursuit bounds, Reserve
semantics, objective rules or 3D foundation.

## Worktree integrity

```text
QA_ONLY_TEST_CHANGED=YES
PRODUCTION_GAMEPLAY_CHANGED_DURING_QA=NO
```

Only `tests/battle01_resupply_red_logistics_smoke.gd` was modified (+171 lines,
QA-only assertions and the QA-harness transfer-start fix). Godot-generated `.uid`,
`.import` and `.godot` artifacts were not committed.

## Audit conclusion

```text
BLUE_RESUPPLY=PASS
FORMATION_RENDEZVOUS=PASS
WEST_RALLY=PASS
FORWARD_RALLY=PASS
TRANSFER_4S=PASS
AMMO_RESTORE_50_PERCENT=PASS
HP_RESTORE_DISABLED=PASS
DIRECT_MOVE_OVERRIDE=PASS
DIRECT_WITHDRAW_OVERRIDE=PASS
MOVEMENT_RANGE_INTERRUPT_RESET=PASS
RED_RESUPPLY=PASS
RED_ARMOR_PRIORITY=PASS
RED_INFANTRY_PRIORITY=PASS
RED_STABLE_TIE_BREAK=PASS
RED_DORMANT_REINFORCEMENT_EXCLUDED=PASS
RED_LOCAL_LULL_REQUIRED=PASS
RED_EVADE_OVERRIDE=PASS
RED_FINITE_CHARGES=PASS
RED_SUPPLY_DESTRUCTION_EFFECT=PASS
RED_HIDDEN_INFO_VIOLATION=NONE
ROLE_CAPTURE_REGRESSION=PASS
FORMAL_ROSTER_REGRESSION=PASS
LOGISTICS_REGRESSION=PASS
ENEMY_AI_REGRESSION=PASS
3D_FOUNDATION_REGRESSION=PASS
BLOCKING_RUNTIME_ERRORS=NONE
PRODUCTION_GAMEPLAY_CHANGED_DURING_QA=NO
RESULT=PASS
```