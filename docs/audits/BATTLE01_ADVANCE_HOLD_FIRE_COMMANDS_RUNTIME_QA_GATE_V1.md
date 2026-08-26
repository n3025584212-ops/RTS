# BATTLE01 ADVANCE / HOLD FIRE Commands Runtime QA Gate V1

TASK_ID=QA_BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_FAIL
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
START_MAIN_SHA=fc69019296f988f8ca762d48f77531a22dff76b2
VERIFIED_GAMEPLAY_COMMIT=9ca896dc4ac3b949ca65d2a3bcb58fa6fc2566d3
SOURCE_AUDIT=docs/audits/BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_IMPLEMENTATION_AUDIT_V1.md

## Independent QA conclusion

Window 07 independently reviewed the live player input chain, BattleFormation combat execution, SelectionController ADVANCE/HOLD FIRE implementation, IntelTracker gate ordering, direct-order cancellation, Logistics/Reserve integration, the focused command smoke, the implementation diff and the bound real Godot 4.7.1 evidence.

Most of the new command implementation is correctly constructed:

- live 3D RMB routes to MOVE and SHIFT+RMB routes to ADVANCE;
- ADVANCE uses formation-aware navigation;
- ADVANCE checks IntelTracker == CONFIRMED before reading RED target position for range/LOS/selection;
- ADVANCE target choice is deterministic nearest + lexical display-name tie break;
- ADVANCE does not chase targets that leave range/LOS or lose CONFIRMED;
- HOLD FIRE is a persistent per-Formation state and is the final veto at the top of BattleFormation._update_combat();
- MOVE/WITHDRAW/RESUPPLY remove ADVANCE intent through real order transitions;
- Logistics is excluded from ADVANCE while mixed combat selections still advance;
- dynamically deployed reserve Infantry is registered and can ADVANCE / HOLD FIRE;
- no frozen Formation values, damage matrix, route geometry, roster, Supply rules, Objective rules, seeded RED postures or Enemy AI states were changed by the implementation delta.

However the Gate FAILs because the live Battle01 still contains a legacy combat-target assignment that makes normal MOVE behave like ADVANCE for the primary BLUE IFV / primary RED target path.

## Blocking product/integration defect: legacy primary IFV auto-target bypasses MOVE/ADVANCE distinction

In `scripts/battle01/battle01.gd`, `_on_intel_state_changed()` still performs the legacy behavior:

`elif state == BattleIntelTracker.CONFIRMED:`
`    blue.set_combat_target(red)`

Here `blue` is the live `BLUE IFV-01` and `red` is the primary RED Formation.

`BattleFormation.issue_move()` does not clear the combat target. `BattleFormation._process()` executes `_update_combat()` every frame before `_update_movement(delta)`. Therefore, after the primary RED becomes CONFIRMED, a normal RMB MOVE issued to BLUE IFV-01 can continue firing at that target whenever range/LOS/ammo allow it.

For that live path, MOVE therefore already has the opportunistic-fire behavior that is supposed to distinguish ADVANCE.

This is not hidden-information leakage: the target becomes assigned only on CONFIRMED. It is a command-product integration defect because the player-facing semantic distinction is inconsistent across Formations.

## Why the focused smoke missed it

The focused `MOVE_ADVANCE_BEHAVIOR_DIFFERENCE_PASS` scenario uses BLUE Infantry, not the legacy `blue` IFV referenced by `_on_intel_state_changed()`. Infantry does not receive the legacy primary target assignment, so the smoke proves MOVE != ADVANCE only for that isolated Formation path.

The smoke therefore can pass while the live primary IFV still has MOVE ~= ADVANCE after primary RED confirmation.

A correction must add a runtime regression that uses the real BLUE IFV + primary RED IntelTracker callback path.

## ADVANCE construction review

ADVANCE_REAL_INPUT_PASS=PASS_BY_LIVE_3D_INPUT_CONSTRUCTION
MOVE_SEMANTICS_PRESERVED_PASS=FAIL_PRIMARY_IFV_LEGACY_AUTOFIRE_PATH
ADVANCE_CONFIRMED_ONLY_PASS=PASS
ADVANCE_LOS_GATE_PASS=PASS
ADVANCE_RANGE_GATE_PASS=PASS
ADVANCE_NO_CHASE_PASS=PASS
ADVANCE_TARGET_LOSS_CONTINUES_PASS=PASS
ADVANCE_DETERMINISTIC_TARGET_PASS=PASS
ADVANCE_FORMATION_AWARE_MOBILITY_PASS=PASS

FOW_LEAKAGE_AUDIT_PASS=PASS

The ADVANCE selector gates on IntelTracker CONFIRMED before reading target global_position for distance or LOS. UNSEEN / CONTACT / LAST_KNOWN are not used for ADVANCE target acquisition.

## HOLD FIRE review

HOLD_FIRE_FINAL_FIRE_VETO_PASS=PASS
HOLD_FIRE_MOVE_PASS=PASS
HOLD_FIRE_ADVANCE_PASS=PASS
HOLD_FIRE_WEAPONS_FREE_RESUME_PASS=PASS
HOLD_FIRE_TACTICAL_VALUE=MEANINGFUL

The final firing veto is inside BattleFormation._update_combat(), so even a target assigned by another system cannot fire while HOLD FIRE is active. Movement, ADVANCE and objective role fields remain available, and WEAPONS FREE restores normal fire without mutating frozen weapon statistics.

## Direct override / Logistics / Reserve

DIRECT_MOVE_OVERRIDE_PASS=PASS
WITHDRAW_OVERRIDE_PASS=PASS
RESUPPLY_OVERRIDE_PASS=PASS
LOGISTICS_ROLE_PRESERVED_PASS=PASS
RESERVE_COMPATIBILITY_PASS=PASS

Order-change cleanup removes stored ADVANCE intent and combat target when a Formation leaves ADVANCE. The focused smoke explicitly exercises MOVE, WITHDRAW and RESUPPLY overrides, mixed Logistics selection and dynamically deployed reserve Infantry.

## Player-facing product judgment

ADVANCE_MOVE_DISTINCTION=NOT_MEANINGFUL_CONSISTENTLY

For Infantry and the new command-controller path, MOVE and ADVANCE are distinct. For the live primary IFV after primary RED confirmation, legacy Battle01 target assignment allows MOVE to opportunistically fire, collapsing the intended distinction in an important active Formation.

HOLD_FIRE_TACTICAL_VALUE=MEANINGFUL

HOLD FIRE creates a real tactical choice: a Formation can move, ADVANCE, recon/capture/contest according to its existing role while withholding ammunition/fire exposure, then explicitly return to WEAPONS FREE.

PRODUCT_CORRECTNESS=FAIL

## Runtime evidence provenance

Window 07 did not execute the user's local Windows Godot binary in this QA turn. The implementation audit records real local official Godot 4.7.1 runtime verification against VERIFIED_GAMEPLAY_COMMIT, and GitHub comparison confirms the only delta from `9ca896dc4ac3b949ca65d2a3bcb58fa6fc2566d3` to `fc69019296f988f8ca762d48f77531a22dff76b2` is the implementation audit document.

PROJECT_IMPORT=PASS_BOUND_IMPLEMENTATION_EVIDENCE
PROJECT_PARSE=PASS_BOUND_IMPLEMENTATION_EVIDENCE
FOCUSED_SMOKE=PASS_BOUND_IMPLEMENTATION_EVIDENCE
RELEVANT_REGRESSION_PASS=PASS_BOUND_IMPLEMENTATION_EVIDENCE
BLOCKING_RUNTIME_ERRORS=NONE_IN_BOUND_IMPLEMENTATION_EVIDENCE

The inherited smoke/regression evidence is not relabeled as an independent Window 07 runtime execution.

## Regression / frozen protection

FROZEN_GAMEPLAY_REGRESSION_PASS=PASS_FOR_FROZEN_VALUES
FORMATION_VALUES_CHANGED=NO
DAMAGE_MATRIX_CHANGED=NO
ROUTE_GEOMETRY_CHANGED=NO
ROSTER_CHANGED=NO
SUPPLY_RULE_CHANGED=NO
OBJECTIVE_RULE_CHANGED=NO
SEEDED_POSTURE_CHANGED=NO
ENEMY_AI_STATE_CONTRACT_CHANGED=NO
PRE_BATTLE_STAGING_IMPLEMENTED=NO

The FAIL is limited to player command semantics/integration, not a frozen-value regression.

## Gate judgment

CONSTRUCTION_CORRECTNESS=FAIL
PRODUCT_CORRECTNESS=FAIL
EVIDENCE_SUFFICIENCY=FAIL
QA_GATE_RESULT=FAIL
READY_FOR_NEXT_STAGE=NO

BLOCKER=LEGACY_PRIMARY_IFV_AUTO_TARGET_ON_CONFIRMED_MAKES_NORMAL_MOVE_OPPORTUNISTICALLY_FIRE_AND_COLLAPSES_MOVE_ADVANCE_DISTINCTION

## Required correction boundary

RETURN_TO=WINDOW_04_AI_COMMAND

Required minimum correction:

1. Remove or constrain the legacy normal-runtime `blue.set_combat_target(red)` path so plain MOVE cannot gain ADVANCE-style opportunistic fire through the primary Intel callback. Preserve any legacy CI-only behavior only where actually required by existing regression tests.
2. Keep ADVANCE as the explicit moving opportunistic-fire command and keep HOLD FIRE as final veto.
3. Add a focused runtime case using the real BLUE IFV + primary RED + actual IntelTracker state transition: after CONFIRMED, plain MOVE must not fire/acquire through the legacy callback; SHIFT+RMB/ADVANCE must fire when CONFIRMED + range + LOS are legal.
4. Re-run the existing focused command smoke and all regressions already required by this Gate under real Godot 4.7.1.
5. Do not implement PRE-BATTLE STAGING or redesign HOLD/Enemy AI in this correction.

## Next action

NEXT_ACTION=FIX_BATTLE01_MOVE_ADVANCE_PRIMARY_TARGET_INTEGRATION_V1
NEXT_OWNER=WINDOW_04_AI_COMMAND

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
