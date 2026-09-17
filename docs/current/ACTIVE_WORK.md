# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
MODE=EVIDENCE_REPRODUCTION_BEFORE_PRODUCT_TRANSFER
CURRENT_GATE=SPRINT01_PLAYER_WORLD_DELIVERY_REAUDIT
ACTIVE_TASK=REAUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_V1
TASK_ARTIFACT=docs/audit/TASK_03_PLAYER_WORLD_DELIVERY_REAUDIT_V1.md

## One current task

WINDOW_03 is the only active task window.

TASK=Independently re-audit the repaired fresh PLAYER-facing world artifact produced by Window 02.

## Window 02 completed handoff

REPAIRED_RUNTIME_SOURCE_COMMIT=73224323dea523e43d773b539912a700d286ddec
REPAIRED_EVIDENCE_COMMIT=79e7b738816c1ba476f6b4a05505e97ab1b73491
RESULT_FILE=docs/learning/sprint01/WORLD_REPRODUCTION_RESULT.md

Fresh runtime evidence exists:
- world_initial.png
- world_fire_feedback.png
- world_final.png
- world_reproduction.mp4
- runtime.log
- world_chain_extract.txt
- input_injection.log
- exact_asset_binding.txt

Window 02 status fields:
`WORLD_REPRODUCTION_STATUS=RUNTIME_CAPTURED_AWAITING_WINDOW_03_AUDIT`
`PLAYER_VISIBLE_EVIDENCE=CAPTURED_NOT_SELF_ACCEPTED`
`WINDOW_02_SELF_ACCEPTANCE=FORBIDDEN`

## Window 03 re-audit scope

Re-audit the previous PLAYER blockers against actual fresh screenshots/video:

- `PLAYER_UNIT_READABILITY`
- `WORLD_LABEL_OCCLUSION`
- `REAL_ENOUGH_WORLD_DELIVERY`
- `PLAYER_WORLD_READABILITY`

Do not accept asset counts, provenance declarations or runtime assertions as substitutes for visual inspection.

Preserve already-proven causal/runtime semantics unless the repair introduced a regression.

## Required output

`docs/audit/AUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_REPAIR_V1.md`

If all PLAYER blockers PASS, return to Window 00 for Sprint 01 final transfer decision.
If any blocker FAIL, identify only the concrete remaining PLAYER boundary and route it back to Window 02.

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=HOLD_REPAIR_RUNTIME_COMPLETE
WINDOW_03=ACTIVE_PLAYER_WORLD_DELIVERY_REAUDIT

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
