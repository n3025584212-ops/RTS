# BATTLE01 Revised Role / Capture Runtime QA Gate V1

TASK_ID=RERUN_REVISED_ROLE_CAPTURE_RUNTIME_GATE_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=BLOCKED_RUNTIME_EXECUTION_UNAVAILABLE_AFTER_FIX
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ENGINE_REQUIRED=Godot 4.7.1
TARGET_COMMIT=8d9014472892912230f5b2137f15eefb05d58573
SOURCE_OF_TRUTH=GITHUB_MAIN
UPSTREAM=FIX_REVISED_ROLE_CAPTURE_RUNTIME_BLOCKERS_V1=BLOCKED_RUNTIME_NOT_EXECUTED
PRIOR_FAILED_GAMEPLAY_SHA=88a50429a8e7b5d7a56cde2eb291925b32470ed0
PRIOR_RUNTIME_AUDIT=docs/audits/BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_AUDIT_V1.md
PRIOR_RUNTIME_AUDIT_COMMIT=4cdd057c1cbf8112f31f3d3a5cd944ccb7a0b747

## Independent QA summary

Window 07 independently verified that `8d9014472892912230f5b2137f15eefb05d58573` is the current `main` head at the start of this rerun gate.

The fix commit changes exactly one production file:

- `scripts/battle01/formation_definition.gd`

The change is limited to replacing the Godot-4.7.1-invalid constant construction:

```gdscript
const VALID_TARGET_CLASSES := PackedStringArray([...])
```

with typed static runtime data:

```gdscript
static var VALID_TARGET_CLASSES: PackedStringArray = PackedStringArray([...])
```

No ammo, damage matrix, capture/contest rule, reserve rule, Enemy AI behavior, 3D foundation, or RESUPPLY implementation is changed by the fix commit.

## Runtime execution attempt

The exact target commit automatically triggered:

- workflow: `Godot 4.7.1 Runtime Verify`
- run id: `32826486427`
- head SHA: `8d9014472892912230f5b2137f15eefb05d58573`
- initial conclusion: `failure`

Window 07 then explicitly re-ran the failed job for this exact run/commit.

The rerun was accepted by GitHub, but the replacement job again completed with:

- job name: `Headless parse and runtime smoke`
- job steps: empty / none
- no executed Godot command
- no Godot version output
- no parse/import output
- no Battle01 boot output
- no smoke-test output

Therefore the rerun still did not execute Godot. This is non-diagnostic for the repaired game code: it is not evidence that the repair failed, but it also cannot satisfy a runtime QA gate.

## Static scope / semantics preflight

CHANGE_SCOPE=PASS
FROZEN_GAMEPLAY_PRESERVED_STATICALLY=PASS
TARGET_COMMIT_IS_CURRENT_MAIN_AT_GATE_START=YES

Frozen semantics remain the requested authority:

- Ammo: Recon 18 / Infantry 24 / IFV 28 / Armor 16
- Representative damage: Recon->Heavy 2; Infantry->Heavy 5; IFV->Soft 30; IFV->Heavy 13; Armor->Light 61
- Capture/Contest: Recon NO/NO; Infantry YES/YES; IFV YES/YES; Armor NO/YES; Logistics NO/NO
- Capture time: 15 seconds

Static inspection cannot replace the required Godot execution.

## Gate judgment

PROJECT_PARSE=NOT_EXECUTED
BATTLE01_BOOT=NOT_EXECUTED
ROLE_DAMAGE_RUNTIME=NOT_EXECUTED
OBJECTIVE_CAPTURE_CONTEST_RUNTIME=NOT_EXECUTED
SOFTLOCK_REGRESSION=NOT_EXECUTED
FORMAL_ROSTER_REGRESSION=NOT_EXECUTED
LOGISTICS_REGRESSION=NOT_EXECUTED
ENEMY_AI_REGRESSION=NOT_EXECUTED
3D_FOUNDATION_REGRESSION=NOT_EXECUTED
BLOCKING_RUNTIME_ERRORS=UNKNOWN_RUNTIME_NOT_EXECUTED

QA_GATE_RESULT=BLOCKED
READY_FOR_NEXT_STAGE=NO
BLOCKER=NO_REAL_GODOT_4_7_1_EXECUTION_OCCURRED_FOR_8d9014472892912230f5b2137f15eefb05d58573

## What is required to close

Use any available real Godot 4.7.1 runner against the exact target commit (or a descendant proven to contain only QA documentation changes) and execute:

1. `Godot --version`
2. `Godot --headless --editor --path . --quit`
3. `Godot --headless --path . --quit-after 300`
4. `tests/battle01_role_capture_v2_smoke.gd`
5. `tests/formal_combat_roster_smoke.gd`
6. `tests/battle01_logistics_flow_smoke.gd`
7. `tests/battle01_enemy_ai_final_objective_smoke.gd`
8. `tests/battle01_3d_foundation_smoke.gd`

Only if all required runtime checks pass may this gate become PASS.

## Cleanup / active state

Window 07 did not modify gameplay code. No project ZIP, duplicate checkout, generated cache, screenshot bundle, or large duplicate log package was retained. This gate document is the only durable output of this rerun review.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Next action

NEXT_ACTION=RUN_FIXED_REVISED_ROLE_CAPTURE_GODOT_4_7_1_RUNTIME_V1
NEXT_OWNER=AVAILABLE_GODOT_4_7_1_RUNNER
RETURN_TO=WINDOW_07_INTEGRATION_QA_PERFORMANCE

If that real run passes, Window 07 may close this gate and route to `IMPLEMENT_BATTLE01_RESUPPLY_AND_RED_LOGISTICS_V1` / `WINDOW_05_RESOURCES_WAR`.
If that real run exposes another production blocker, Window 07 will return the smallest blocker-fix task to the responsible implementation window.
