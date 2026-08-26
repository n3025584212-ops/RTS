# BATTLE01 ADVANCE / HOLD FIRE Commands Runtime QA Gate V2

TASK_ID=RERUN_QA_BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_PASS
ENGINE=Godot 4.7.1.stable.official.a13da4feb
SOURCE_OF_TRUTH=GITHUB_MAIN
START_MAIN_SHA=ee4d16e681fcb951d4ce50a3d8da4b41223e2ce3
VERIFIED_GAMEPLAY_COMMIT=d50dc96b4ef1420eabb1a1e559217398b8a294bc
PREVIOUS_QA_GATE=docs/audits/BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_RUNTIME_QA_GATE_V1.md
PREVIOUS_QA_BLOCKER=LEGACY_PRIMARY_IFV_AUTO_TARGET_ON_CONFIRMED
FIX_AUDIT=docs/audits/BATTLE01_MOVE_ADVANCE_PRIMARY_TARGET_INTEGRATION_FIX_AUDIT_V1.md

## Independent QA conclusion

Window 07 independently reviewed the gameplay delta, current live Battle01 primary Intel callback, SelectionController MOVE/ADVANCE target handling, BattleFormation final fire execution, the new primary-IFV integration smoke, the existing ADVANCE/HOLD FIRE focused smoke, regression evidence provenance, and current-main identity.

The V1 blocker is closed.

LEGACY_PRIMARY_IFV_AUTO_TARGET_BLOCKER_CLOSED=YES

Normal player runtime no longer assigns `BLUE IFV-01` a combat target merely because the primary RED target becomes CONFIRMED. The only retained legacy primary-IFV target assignment is explicitly gated by `_ci_los_smoke || _ci_multi_command_smoke` from the MOVE callback and is unreachable in an ordinary player run where these CI flags are false.

Player `SelectionController.issue_move()` also clears any stale player-side combat target before issuing MOVE. This creates a real cleanup boundary after ADVANCE or any historical player target state.

## MOVE / ADVANCE player semantics

RMB MOVE remains movement-only.

SHIFT+RMB ADVANCE remains movement plus legal opportunistic fire against targets that are:
- alive and RED;
- currently IntelTracker `CONFIRMED`;
- inside the issuing Formation's attack range;
- on a legal terrain/smoke LOS;
- compatible with HOLD FIRE being disabled.

The live 3D input path continues to route RMB to MOVE and SHIFT+RMB to ADVANCE. The integration correction did not add or redesign any command mode.

MOVE_SEMANTICS_PRESERVED=PASS
ADVANCE_MOVE_DISTINCTION=MEANINGFUL

## Primary IFV blocker regression

The new focused smoke instantiates the real `res://scenes/battle01/Battle01.tscn` and uses the actual scene `BlueFormation`, `RedFormation`, `SelectionController`, and `IntelTracker` pair wired by `battle01.gd`.

It verifies:
- primary RED CONFIRMED plus plain MOVE does not consume ammo, increment fire serial, or damage RED;
- the same primary pair under ADVANCE legally fires;
- a LAST_KNOWN -> CONFIRMED transition while plain MOVE is active does not resurrect the legacy auto-target;
- ADVANCE remains able to acquire a legally CONFIRMED primary target and fire;
- ADVANCE -> MOVE clears advance intent, advance destination and stale combat target state.

PRIMARY_IFV_PLAIN_MOVE_NO_AUTO_FIRE_PASS=YES
PRIMARY_IFV_ADVANCE_OPPORTUNISTIC_FIRE_PASS=YES
PRIMARY_IFV_MOVE_ADVANCE_DISTINCTION_PASS=YES
PRIMARY_IFV_MOVE_RECONFIRM_NO_AUTO_FIRE_PASS=YES
PRIMARY_IFV_ADVANCE_RECONFIRM_FIRE_PASS=YES
ADVANCE_TO_MOVE_FIRE_STATE_CLEAN_PASS=YES

### Evidence-quality note: ADVANCE reconfirm temporal isolation

The dedicated primary-IFV smoke marker named `PRIMARY_IFV_ADVANCE_RECONFIRM_FIRE_PASS` issues ADVANCE after the immediately preceding MOVE-reconfirm scenario has already left the target CONFIRMED; it does not by itself perform a fresh LAST_KNOWN -> CONFIRMED transition after ADVANCE is issued.

Window 07 therefore did not rely on the marker name alone. The behavior is independently established by the production construction plus component runtime evidence:
- ADVANCE target selection is reevaluated on a fixed 0.15s cadence;
- target selection reads the current IntelTracker state on each decision;
- non-CONFIRMED state yields no target and clears the ADVANCE combat target;
- the target remains in the known target set across state changes;
- subsequent CONFIRMED state therefore re-enters the same range/LOS/deterministic acquisition path;
- existing runtime evidence separately proves ADVANCE target loss continues movement and CONFIRMED legal acquisition/fire.

ADVANCE_RECONFIRM_BEHAVIOR=PASS_BY_CONSTRUCTION_PLUS_BOUND_COMPONENT_RUNTIME
DEDICATED_RECONFIRM_MARKER_TEMPORAL_ISOLATION=IMPERFECT_NON_BLOCKING

## ADVANCE construction preservation

The existing accepted ADVANCE implementation remains unchanged by the blocker correction except for player MOVE target cleanup and the legacy callback narrowing.

ADVANCE_CONFIRMED_ONLY_PASS=YES
ADVANCE_LOS_GATE_PASS=YES
ADVANCE_RANGE_GATE_PASS=YES
ADVANCE_NO_CHASE_PASS=YES
ADVANCE_TARGET_LOSS_CONTINUES_PASS=YES
ADVANCE_DETERMINISTIC_TARGET_PASS=YES
ADVANCE_FORMATION_AWARE_MOBILITY_PASS=YES

FOW_LEAKAGE_AUDIT_PASS=YES

`SelectionController._choose_advance_target()` checks IntelTracker state == CONFIRMED before reading RED target position for distance or LOS. UNSEEN / CONTACT / LAST_KNOWN are not used for ADVANCE target acquisition.

## HOLD FIRE preservation

`BattleFormation._update_combat()` retains HOLD FIRE as the final execution veto before ammo consumption, fire-serial increment or damage application.

HOLD_FIRE_FINAL_FIRE_VETO_PASS=YES
HOLD_FIRE_MOVE_PASS=YES
HOLD_FIRE_ADVANCE_PASS=YES
HOLD_FIRE_WEAPONS_FREE_RESUME_PASS=YES
HOLD_FIRE_TACTICAL_VALUE=MEANINGFUL

The blocker fix does not mutate weapon definitions, ammo, damage, fire interval or capture/contest roles.

## Direct override / Logistics / Reserve

DIRECT_MOVE_OVERRIDE_PASS=YES
WITHDRAW_OVERRIDE_PASS=YES
RESUPPLY_OVERRIDE_PASS=YES
LOGISTICS_ROLE_PRESERVED_PASS=YES
RESERVE_COMPATIBILITY_PASS=YES

MOVE now strengthens the previously accepted direct override by clearing stale combat target state before the move request. Order-change cleanup continues to erase ADVANCE intents when a Formation leaves ADVANCE.

## Runtime evidence provenance

INDEPENDENT_RUNTIME_REEXECUTION=UNAVAILABLE_IN_WINDOW_07

Window 07 did not claim to execute the user's local Windows Godot binary in this turn. The exact gameplay-bound runtime evidence in the fix audit was independently reviewed and accepted:

- gameplay SHA = `d50dc96b4ef1420eabb1a1e559217398b8a294bc`;
- current main before this Gate = `ee4d16e681fcb951d4ce50a3d8da4b41223e2ce3`;
- comparison from gameplay SHA to current main contains exactly one added file: `docs/audits/BATTLE01_MOVE_ADVANCE_PRIMARY_TARGET_INTEGRATION_FIX_AUDIT_V1.md`;
- no production or test gameplay drift exists between the verified gameplay SHA and the audit commit.

The bound audit records real Godot `4.7.1.stable.official.a13da4feb`, project import PASS, editor parse PASS, real Battle01 boot PASS, the primary IFV integration smoke PASS, the ADVANCE/HOLD FIRE focused smoke PASS, all required listed regressions PASS, all four requested legacy CI smoke paths PASS, and `BLOCKING_RUNTIME_ERRORS=NONE`.

PROJECT_IMPORT=PASS_BOUND_RUNTIME_EVIDENCE
PROJECT_PARSE=PASS_BOUND_RUNTIME_EVIDENCE
REAL_BATTLE01_BOOT=PASS_BOUND_RUNTIME_EVIDENCE
BLOCKING_RUNTIME_ERRORS=NONE

## Relevant regression status

PRIMARY_IFV_INTEGRATION_SMOKE=PASS
ADVANCE_HOLD_FIRE_COMMANDS_SMOKE=PASS
ROUTE_IDENTITY_REGRESSION=PASS
SEEDED_POSTURE_REGRESSION=PASS
RESUPPLY_RED_LOGISTICS_REGRESSION=PASS
ENEMY_AI_FINAL_OBJECTIVE_REGRESSION=PASS
ROLE_CAPTURE_REGRESSION=PASS
FORMAL_ROSTER_REGRESSION=PASS
LOGISTICS_FLOW_REGRESSION=PASS
3D_FOUNDATION_REGRESSION=PASS
ENEMY_AI_CORE_REGRESSION=PASS
NAVIGATION_REGRESSION=PASS
RECON_TERRAIN_LOS_COMBAT_REGRESSION=PASS
MULTI_FORMATION_COMMAND_REGRESSION=PASS
RELEVANT_REGRESSION_PASS=YES

## Frozen gameplay protection

The correction delta from the V1 FAIL Gate to the verified gameplay commit changes only:
- `scripts/battle01/selection_controller.gd` player MOVE target cleanup;
- `scripts/battle01/battle01.gd` normal/CI-only primary target integration;
- `tests/battle01_primary_ifv_move_advance_integration_smoke.gd`.

It does not change Formation resources, damage matrix, route geometry, formal roster, seeded RED postures, Supply rules, capture/contest rules, Objective timings, victory/defeat rules, Enemy AI states, Enemy AI FOW, or reinforcement semantics.

FROZEN_GAMEPLAY_REGRESSION_PASS=YES
FORMATION_VALUES_PRESERVED=YES
DAMAGE_MATRIX_PRESERVED=YES
ROUTE_IDENTITY_PRESERVED=YES
FORMATION_AWARE_MOBILITY_PRESERVED=YES
SEEDED_RED_POSTURES_PRESERVED=YES
RED_BLUE_LOGISTICS_PRESERVED=YES
CAPTURE_CONTEST_OBJECTIVE_PRESERVED=YES
VICTORY_DEFEAT_PRESERVED=YES
FORMAL_ROSTER_PRESERVED=YES
ENEMY_AI_PRESERVED=YES
PRE_BATTLE_STAGING_IMPLEMENTED=NO

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS
PRODUCT_CORRECTNESS=PASS
EVIDENCE_SUFFICIENCY=PASS
QA_GATE_RESULT=PASS
READY_FOR_NEXT_STAGE=YES
BLOCKER=NONE

The product distinction is now coherent across the real primary IFV path:
- RMB MOVE = movement-only;
- SHIFT+RMB ADVANCE = movement plus legal CONFIRMED/range/LOS opportunistic fire;
- HOLD FIRE remains the final fire-discipline veto.

## Scope boundary

This Gate closes the Battle01 ADVANCE / HOLD FIRE commander-intent slice. Do not reopen it unless a later change plausibly regresses player MOVE target cleanup, primary Intel callback integration, ADVANCE FOW/LOS/range/no-chase logic, HOLD FIRE final veto, or formation-aware route mobility.

Still downstream:
- pre-battle staging contract and implementation;
- integrated revised Battle01 playtest / pressure-test;
- final art / VFX after gameplay closure.

## Cleanup / active state

Window 07 made no production gameplay change. The only durable output is this V2 QA Gate. Historical V1 FAIL remains preserved.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Next action

NEXT_ACTION=DESIGN_AND_FREEZE_BATTLE01_PRE_BATTLE_STAGING_CONTRACT_V1
NEXT_OWNER=WINDOW_01_GAME_DESIGN
