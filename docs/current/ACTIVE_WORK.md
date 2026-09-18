# FRONTLINE — ACTIVE WORK

STATUS=ACTIVE
ACTIVE_ISSUE=#41
ACTIVE_BRANCH=product/frontline-high-fidelity-slice-v1
CURRENT_GATE=HIGH_FIDELITY_PRODUCT_BASELINE_REPRODUCTION
ACTIVE_TASK=REPRODUCE_RIVER_TOWN_BASELINE_THEN_INTEGRATE_VALIDATED_GAMEPLAY
TASK_ARTIFACT=docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md

## One active construction route

WINDOW_02 is the only active implementation window.

Build directly on:
`res://scenes/production/RiverTownVisualSlice.tscn`

Base branch ancestry:
`dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`

Local visual floor:
`artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png`

Canonical target:
`FRONTLINE_GOLDEN_FRAME_V1`

## Explicitly stopped route

Issue #39 / Sprint01 learning-test visual iteration is closed as an active product route.
`Sprint01WorldReproduction.tscn` is evidence only.
No more V1/V2/V3 player-facing battlefield polishing on that learning scene unless the user explicitly reopens it.

## First product step

1. Freshly reproduce River Town at Godot 4.7.1 / Forward+ / 1920x1080.
2. Confirm retained assets and high-quality pipeline still render.
3. Freeze that fresh image as product-branch visual floor.
4. Integrate the minimum validated controllable armored-unit chain into the high-quality scene.
5. Do not replace terrain, architecture, vegetation, PBR materials, lighting or camera with test proxies.
6. Capture fresh player-facing screenshots/video.
7. Route to Window 03 for independent visual/gameplay regression audit.

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
WINDOW_02=ACTIVE_HIGH_FIDELITY_PRODUCT_BUILD
WINDOW_03=HOLD_PENDING_HIGH_FIDELITY_RUNTIME

PRODUCT_PRODUCTION_RESUME=YES_HIGH_FIDELITY_SLICE_ONLY
