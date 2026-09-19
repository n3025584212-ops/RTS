# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#41
ACTIVE_BRANCH=product/frontline-high-fidelity-slice-v1
CURRENT_GATE=MINIMUM_ARMORED_UNIT_INTEGRATION
ACTIVE_TASK=INTEGRATE_VALIDATED_CONTROLLABLE_ARMORED_UNIT_CHAIN_INTO_RIVER_TOWN
TASK_ARTIFACT=docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md

## Baseline reproduction result

STATUS=PASS
WORKFLOW=FRONTLINE River Town Visual Slice
RUN_NUMBER=7
RUN_ID=35325714573
HEAD_SHA=7032c91ccd9c58244ce36f944558fa3dd4727d01
CONCLUSION=SUCCESS
COMPLETED_AT=2026-09-18T08:49:23Z

The fresh River Town technical baseline is reproduced. This closes the reproduction gate and opens gameplay integration. It does not by itself count as final visual/product acceptance.

## One active construction route

WINDOW_02 is the only active implementation window.

Build directly on:
`res://scenes/production/RiverTownVisualSlice.tscn`

Base branch ancestry:
`dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`

Verified product-branch head at baseline pass:
`7032c91ccd9c58244ce36f944558fa3dd4727d01`

Local visual floor:
`artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png`

Canonical target:
`FRONTLINE_GOLDEN_FRAME_V1`

## Current implementation task

1. Integrate the minimum already-validated controllable armored-unit/runtime chain into River Town.
2. Keep River Town as the product mother scene; do not extend the Sprint01 learning scene into the product.
3. Preserve terrain, architecture, vegetation, PBR materials, lighting, atmosphere, water and camera systems.
4. Do not replace the battlefield with box/cylinder/color-block proxies.
5. Demonstrate the unit operating inside the real high-fidelity River Town runtime.
6. Capture fresh Godot 4.7.1 / Forward+ / 1920x1080 player-facing evidence.
7. Compare the fresh runtime against the retained River Town visual floor.
8. Record commit/workflow/media evidence in `docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md`.
9. Route the result to Window 03 only after fresh runtime evidence exists.

## Gate B PASS requirements

- import/runtime completes without fatal error;
- controllable armored unit is instantiated in River Town;
- validated control/movement chain works in runtime;
- fresh 1920x1080 screenshot or video exists;
- no protected River Town subsystem is replaced by test proxies;
- no unapproved visible regression below the retained River Town floor;
- evidence is traceable to a branch/commit/workflow run.

## Explicitly stopped route

Issue #39 / Sprint01 learning-test visual iteration is closed as an active product route.
`Sprint01WorldReproduction.tscn` is evidence only.
No more player-facing battlefield polishing on that learning scene unless the user explicitly reopens it.

## Hard constraints

NO_BOX_PROXY_BATTLEFIELD=YES
NO_CYLINDER_PROXY_BATTLEFIELD=YES
NO_COLOR_BLOCK_ENVIRONMENT=YES
NO_DEBUG_LABEL_DOMINATED_CAPTURE=YES
NO_LEARNING_SCENE_AS_PRODUCT_ANCESTOR=YES
RIVER_TOWN_VISUAL_FLOOR_PROTECTED=YES

## Window routing

WINDOW_00=ACTIVE_CONTROL
WINDOW_01=HOLD_LEARNING_EVIDENCE_ONLY
WINDOW_02=ACTIVE_MINIMUM_ARMORED_UNIT_INTEGRATION
WINDOW_03=HOLD_PENDING_FRESH_HIGH_FIDELITY_RUNTIME

PRODUCT_PRODUCTION_RESUME=YES_HIGH_FIDELITY_SLICE_ONLY
NEXT_REQUIRED_DELIVERABLE=FRESH_HIGH_FIDELITY_RIVER_TOWN_RUNTIME_WITH_CONTROLLABLE_ARMORED_UNIT
