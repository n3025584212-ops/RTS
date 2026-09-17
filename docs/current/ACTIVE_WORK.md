# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#39
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
CURRENT_GATE=SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_REAUDIT_V2
ACTIVE_TASK=AUDIT_SPRINT01_TRANSPORT_TERRAIN_INTEGRATION_V2
TASK_ARTIFACT=docs/audit/TASK_03_TRANSPORT_TERRAIN_REAUDIT_V1.md
HANDOFF_ARTIFACT=docs/learning/sprint01/HANDOFF_02_TRANSPORT_TERRAIN_TO_03_V1.md

WINDOW_03 is now the only active review window.

Fresh audit input:
- source `7eb34267d6fbbebd856001a7c17390c341835e59`
- run `35204480034`
- job `105146808996`
- artifact `10488929099`
- SHA256 `183e43456c951c8908c239c189f6f2cf12bbc865598c836b73146256656da500`
- Godot `4.7.1.stable.official.a13da4feb`

Observed runtime remains PASS for:
- world method execution;
- player causal chain;
- exact vehicle binding;
- external input;
- movement/contact/combat/outcome;
- capture-state alignment.

03 must directly inspect the fresh PNG/MP4 and return:
`REAL_ENOUGH_WORLD_DELIVERY=PASS | FAIL`
for the remaining boundary:
`PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION`.

The Sprint01 scene is learning/runtime evidence only and must not replace the protected FRONTLINE visual-quality baseline.

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_STAGE4_COMPLETE
WINDOW_02=HOLD_RUNTIME_CAPTURE_COMPLETE
WINDOW_03=ACTIVE_TRANSPORT_TERRAIN_REAUDIT

If PASS: `03 -> 00 Sprint01 final transfer decision`.
If FAIL: `03 -> 02 concrete remaining PLAYER-visible defects only`.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
