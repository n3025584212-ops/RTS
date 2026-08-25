# BATTLE01 Revised Role / Capture Runtime QA Gate V1

TASK_ID=RUNTIME_VERIFY_REVISED_ROLE_CAPTURE_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_FAIL
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ENGINE=4.7.1.stable.official.a13da4feb
VERIFIED_TARGET_SHA=88a50429a8e7b5d7a56cde2eb291925b32470ed0
SOURCE_RUNTIME_AUDIT=docs/audits/BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_AUDIT_V1.md
SOURCE_RUNTIME_AUDIT_COMMIT=4cdd057c1cbf8112f31f3d3a5cd944ccb7a0b747
UPSTREAM=IMPLEMENT_BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_V1=IMPLEMENTED_RUNTIME_VERIFICATION_BLOCKED

## Independent QA conclusion

Window 07 independently reviewed the version-bound Godot 4.7.1 runtime audit produced against the exact gameplay commit `88a50429a8e7b5d7a56cde2eb291925b32470ed0`.

The runtime evidence is sufficient to establish a real production-code blocker before Battle01 scene startup:

```text
SCRIPT ERROR: Parse Error: Assigned value for constant "VALID_TARGET_CLASSES" isn't a constant expression.
at: GDScript::reload (res://scripts/battle01/formation_definition.gd:4)
```

The blocking source is:

```gdscript
const VALID_TARGET_CLASSES := PackedStringArray([
    "SOFT",
    "LIGHT_ARMOR",
    "HEAVY_ARMOR",
    "LOGISTICS",
])
```

Godot 4.7.1 does not accept this constructor call as a constant expression. `FormationDefinition` therefore fails to compile and the dependent BattleFormation / Battle01 script chain cannot load.

Window 07 also confirmed that the same invalid declaration remains present on current `main` after publication of the audit, so the defect is still active and is not limited to the detached verification worktree.

The source runtime-audit commit adds only the audit Markdown file; it does not modify production gameplay code.

## Gate judgment

VERSION_IDENTITY=PASS
REAL_GODOT_EXECUTION=PASS
GODOT_VERSION=4.7.1.stable.official.a13da4feb
CONSTRUCTION_CORRECTNESS=FAIL

BATTLE01_REAL_RUNTIME=FAIL
ROLE_DAMAGE_RUNTIME=BLOCKED_BY_PARSE_FAILURE
OBJECTIVE_CAPTURE_CONTEST_RUNTIME=BLOCKED_BY_PARSE_FAILURE
SOFTLOCK_REGRESSION=BLOCKED_BY_PARSE_FAILURE
FORMAL_ROSTER_REGRESSION=BLOCKED_BY_PARSE_FAILURE
LOGISTICS_REGRESSION=BLOCKED_BY_PARSE_FAILURE
ENEMY_AI_REGRESSION=BLOCKED_BY_PARSE_FAILURE
3D_FOUNDATION_REGRESSION=BLOCKED_BY_PARSE_FAILURE
REAL_PLAYER_FLOW=BLOCKED_BY_PARSE_FAILURE

BLOCKING_RUNTIME_ERRORS=FORMATION_DEFINITION_CONST_PARSE_ERROR
QA_GATE_RESULT=FAIL
READY_FOR_NEXT_STAGE=NO
BLOCKER=FORMATION_DEFINITION_GD_LINE_4_PACKEDSTRINGARRAY_CONST_NOT_VALID_IN_GODOT_4_7_1

## Failure ownership and correction boundary

The defect is inside `scripts/battle01/formation_definition.gd`, part of the revised Formation / role-capture implementation domain.

NEXT_ACTION=FIX_REVISED_ROLE_CAPTURE_RUNTIME_BLOCKERS_V1
NEXT_OWNER=WINDOW_03_COMBAT_FORMATIONS

The correction task is authorized only to remove the Godot 4.7.1 parse/runtime blocker and any directly exposed wiring errors required to make the frozen V2 behavior executable.

The correction must not redesign or change:

- Recon / Infantry / IFV / Armor ammo values 18 / 24 / 28 / 16;
- target-class damage matrix or deterministic rounding semantics;
- Capture / Contest semantics;
- 15-second ownership transfer;
- Reserve choice semantics;
- Enemy AI product behavior;
- 3D visual foundation.

After the minimal correction lands, the same focused Godot 4.7.1 runtime gate must be rerun. Do not advance to RESUPPLY / RED logistics implementation until this QA gate passes.

## Cleanup / active state

The runtime verifier removed its temporary worktree and did not retain redundant ZIPs, large logs, screenshot bundles, or generated build artifacts. Window 07 modified only this QA gate record and did not alter production gameplay code.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
