# BATTLE01 Resupply / RED Logistics Runtime QA Gate V1

TASK_ID=RUN_AND_QA_BATTLE01_RESUPPLY_RED_LOGISTICS_GODOT_4_7_1_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=BLOCKED_REAL_GODOT_RUNTIME_REQUIRED
ENGINE_REQUIRED=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
VERIFIED_GAMEPLAY_COMMIT=5db464f931733c0d61025f9bbe602a0a68f69a04
SOURCE_IMPLEMENTATION_AUDIT=docs/audits/BATTLE01_RESUPPLY_RED_LOGISTICS_IMPLEMENTATION_AUDIT_V1.md
SOURCE_IMPLEMENTATION_AUDIT_COMMIT=781a8e99959c2ee26097da5be268f02460441547

## Independent QA preflight

Window 07 independently confirmed that the implementation commit is present and that current main at gate start is `781a8e99959c2ee26097da5be268f02460441547`, whose parent is the gameplay commit.

The implementation scope is narrow and appropriate for this feature: BLUE Formation-level RESUPPLY controller, RED logistics AI subclass, real Battle01 scene wiring, focused runtime smoke, and focused workflow. Static scope review does not show changes to frozen Formation values, role damage matrix, Objective implementation, formal RED roster, accepted Enemy AI base controller, or the accepted low-level BLUE supply primitive.

## Runtime execution status

Two GitHub Actions workflows associated with gameplay commit `5db464f931733c0d61025f9bbe602a0a68f69a04` were independently checked:

- generic `Godot 4.7.1 Runtime Verify` run `32830732711`;
- focused `Battle01 Resupply and RED Logistics Verify` run `32830732693`.

Both completed with failure before any workflow step executed. Their jobs report `steps=null`; there is no Checkout, no Godot version output, no parse/import output, no Battle01 boot output, and no smoke output. These are infrastructure non-executions, not evidence of gameplay failure and not acceptable as runtime PASS.

Window 07 in the current cloud session has no access to the user's Windows-local Godot executable or local FRONTLINE checkout, so the required real-local Godot 4.7.1 commands cannot be executed from this window.

## Focused smoke traceability preflight

`tests/battle01_resupply_red_logistics_smoke.gd` does instantiate the real `res://scenes/battle01/Battle01.tscn` and statically contains strong coverage for:

- BLUE single-Formation RESUPPLY intent and automatic Logistics assignment;
- West rally and Forward rally selection;
- actual movement to rendezvous;
- 4-second transfer, 50% max-ammo restoration, finite charge consumption, no HP restoration;
- direct MOVE override;
- damage and firing interruption with progress reset / no charge;
- zero-charge rejection and BLUE Supply destruction;
- RED Armor priority;
- most-depleted Infantry selection and stable tie-break;
- actual RED rendezvous movement and transfer;
- confirmed-threat cancellation into EVADE;
- RED Supply destruction removing future sustain.

However the current focused smoke source does not independently assert every acceptance item in this gate. Before PASS, real local QA must also explicitly prove, using the existing production behavior plus minimal QA-only assertions/telemetry if necessary:

1. BLUE direct WITHDRAW overrides active RESUPPLY;
2. a non-direct movement/range loss during transfer resets without charge consumption (the existing low-level logistics regression may be reused if it proves the same accepted primitive);
3. dormant RED reinforcement is excluded before activation;
4. RED resupply is prevented during a non-lull condition such as objective emergency / active ENGAGE / legitimate local threat;
5. RED resupply targeting does not react to hidden/unconfirmed BLUE information.

These are evidence gaps, not authorization to redesign gameplay. If a QA-only assertion is needed, it must instantiate the real Battle01 and must not modify frozen gameplay semantics.

## Gate judgment

PROJECT_PARSE=NOT_EXECUTED_LOCAL
BATTLE01_REAL_RUNTIME=NOT_EXECUTED_LOCAL
BLUE_RESUPPLY=NOT_EXECUTED_LOCAL
FORMATION_RENDEZVOUS=NOT_EXECUTED_LOCAL
WEST_RALLY=NOT_EXECUTED_LOCAL
FORWARD_RALLY=NOT_EXECUTED_LOCAL
TRANSFER_4S=NOT_EXECUTED_LOCAL
AMMO_RESTORE_50_PERCENT=NOT_EXECUTED_LOCAL
HP_RESTORE_DISABLED=NOT_EXECUTED_LOCAL
DIRECT_ORDER_OVERRIDE=NOT_EXECUTED_LOCAL
INTERRUPT_RESET=NOT_EXECUTED_LOCAL
RED_RESUPPLY=NOT_EXECUTED_LOCAL
RED_ARMOR_PRIORITY=NOT_EXECUTED_LOCAL
RED_INFANTRY_PRIORITY=NOT_EXECUTED_LOCAL
RED_LOCAL_LULL=NOT_EXECUTED_LOCAL
RED_EVADE_OVERRIDE=NOT_EXECUTED_LOCAL
RED_FINITE_CHARGES=NOT_EXECUTED_LOCAL
RED_SUPPLY_DESTRUCTION_EFFECT=NOT_EXECUTED_LOCAL
RED_HIDDEN_INFO_VIOLATION=UNVERIFIED
ROLE_CAPTURE_REGRESSION=NOT_EXECUTED_LOCAL
FORMAL_ROSTER_REGRESSION=NOT_EXECUTED_LOCAL
LOGISTICS_REGRESSION=NOT_EXECUTED_LOCAL
ENEMY_AI_REGRESSION=NOT_EXECUTED_LOCAL
3D_FOUNDATION_REGRESSION=NOT_EXECUTED_LOCAL
BLOCKING_RUNTIME_ERRORS=UNKNOWN_REAL_RUNTIME_NOT_EXECUTED

QA_GATE_RESULT=BLOCKED
READY_FOR_NEXT_STAGE=NO
BLOCKER=REAL_LOCAL_GODOT_4_7_1_RUNTIME_NOT_AVAILABLE_TO_WINDOW_07_AND_FOCUSED_EVIDENCE_GAPS_REMAIN

## Minimum action to close

Run against gameplay commit `5db464f931733c0d61025f9bbe602a0a68f69a04` (or a descendant proven to add QA/audit-only changes) using real local Godot 4.7.1:

1. `Godot --version`;
2. parse/import;
3. real Battle01 boot;
4. `tests/battle01_resupply_red_logistics_smoke.gd`;
5. `tests/battle01_role_capture_v2_smoke.gd`;
6. `tests/formal_combat_roster_smoke.gd`;
7. `tests/battle01_logistics_flow_smoke.gd`;
8. `tests/battle01_enemy_ai_final_objective_smoke.gd`;
9. `tests/battle01_3d_foundation_smoke.gd`;
10. explicit QA-only proof for the five evidence gaps listed above if the existing regression suite does not already prove them;
11. blocking-error scan and tracked-worktree integrity check.

If all pass, update this gate to `QA_GATE_RESULT=PASS`. If real Godot exposes a production blocker, perform only the task-authorized minimal runtime/wiring correction, rerun the full focused gate, and record the exact blocker if it still cannot close.

## Cleanup / active state

Window 07 made no gameplay change. No ZIP, duplicate project checkout, generated cache, large log bundle, screenshot bundle, or redundant evidence was retained by this cloud QA review. This gate document is the only durable output of the present review.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES_BLOCKED_STATE

## Next action

NEXT_ACTION=RUN_LOCAL_BATTLE01_RESUPPLY_RED_LOGISTICS_RUNTIME_AND_CLOSE_GAPS_V1
NEXT_OWNER=QODER_CN_IDE_OR_OTHER_AVAILABLE_LOCAL_GODOT_4_7_1_RUNNER
RETURN_TO=WINDOW_07_INTEGRATION_QA_PERFORMANCE
