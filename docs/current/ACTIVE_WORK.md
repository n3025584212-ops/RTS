# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_REAUDIT
ACTIVE_TASK=REAUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/audit/TASK_03_PLAYER_WORLD_DELIVERY_REAUDIT_V1.md

## One current task

WINDOW_03 is the only active task window for this round.

TASK=Independently re-audit the repaired fresh PLAYER-facing world artifact produced by Window 02.

## Fresh Window 02 handoff

REPAIRED_RUNTIME_SOURCE_COMMIT=73224323dea523e43d773b539912a700d286ddec
REPAIRED_EVIDENCE_COMMIT=79e7b738816c1ba476f6b4a05505e97ab1b73491
RESULT_FILE=docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md

Fresh evidence:
- `artifacts/learning/sprint01/world_reproduction/world_initial.png`
- `artifacts/learning/sprint01/world_reproduction/world_fire_feedback.png`
- `artifacts/learning/sprint01/world_reproduction/world_final.png`
- `artifacts/learning/sprint01/world_reproduction/world_reproduction.mp4`
- `artifacts/learning/sprint01/world_reproduction/runtime.log`
- `artifacts/learning/sprint01/world_reproduction/world_chain_extract.txt`
- `artifacts/learning/sprint01/world_reproduction/input_injection.log`
- `artifacts/learning/sprint01/world_reproduction/exact_asset_binding.txt`

Window 02 reports runtime completion and explicitly does not self-accept PLAYER quality:

`WORLD_REPRODUCTION_STATUS=RUNTIME_CAPTURED_AWAITING_WINDOW_03_AUDIT`
`PLAYER_VISIBLE_EVIDENCE=CAPTURED_NOT_SELF_ACCEPTED`
`WINDOW_02_SELF_ACCEPTANCE=FORBIDDEN`

## What 03 must decide

Re-audit the four previous blockers against the actual fresh screenshots/video:

1. `PLAYER_UNIT_READABILITY`
2. `WORLD_LABEL_OCCLUSION`
3. `REAL_ENOUGH_WORLD_DELIVERY`
4. `PLAYER_WORLD_READABILITY`

Do not accept asset counts or runtime assertions as a substitute for visual inspection.

## Preserve unless regression exists

Already-proven facts should not be reopened without evidence of regression:
- player input -> command -> movement -> contact -> combat -> visible feedback -> outcome;
- world topology/passability coupling;
- functional anchors and constraints;
- world-method causal execution;
- exact Abrams/IFV binding;
- Godot 4.7.1 runtime path.

03 must still verify that the repair did not bypass these paths.

## Required 03 output

`docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md`

Required route:

- if all PLAYER blockers PASS -> `00 SPRINT01 FINAL TRANSFER DECISION`;
- if any blocker FAIL -> `02 fix only the remaining concrete PLAYER boundary`.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=HOLD_REPAIR_RUNTIME_COMPLETE
WINDOW_03=ACTIVE_PLAYER_WORLD_DELIVERY_REAUDIT

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
