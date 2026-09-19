# FRONTLINE — HIGH FIDELITY PRODUCT SLICE V1

SUPERSEDED_BY=main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md (authoritative gate contract with Gate A/B/C structure)
GATE_B_EVIDENCE=docs/visual_baseline/gate_b_20260920/EVIDENCE_RECORD.md
GATE_B_STATUS=EVIDENCE_COMPLETE_PENDING_GATE_C

STATUS=ACTIVE
ISSUE=#41
BRANCH=product/frontline-high-fidelity-slice-v1
BASE=dev/river-town-local-high-fidelity-v1@dfc4b64e9bbc2a1c8f5d1032e92912195c575f07
PRIMARY_SCENE=res://scenes/production/RiverTownVisualSlice.tscn
BASELINE_SCREENSHOT=artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png
CANONICAL_TARGET=FRONTLINE_GOLDEN_FRAME_V1
ENGINE=Godot 4.7.1

## Direction

The Sprint01 learning/test scene is no longer an active product construction path.
Do not extend `Sprint01WorldReproduction.tscn` as a product scene.
Do not rebuild the battlefield from boxes, cylinders, flat color blocks, debug markers, or placeholder roads.

The product slice starts from the existing River Town high-fidelity engine scene and keeps its real terrain, PBR surfaces, architecture, vegetation, lighting, atmosphere, water, clutter, camera and 1920x1080 render pipeline.

Validated gameplay/runtime methods may be transferred into this scene. The visual scene is not to be degraded into the learning scene in order to make gameplay integration easier.

## First execution target

1. Reproduce the existing River Town baseline on this product branch with fresh Godot 4.7.1 runtime evidence.
2. Freeze that screenshot as the local visual floor for this branch.
3. Add one real controllable armored unit and the minimum validated selection/move/combat chain into the high-fidelity scene without reducing the existing visual result.
4. Remove any debug/test overlays from the player-facing capture.
5. Produce fresh 1920x1080 screenshots and continuous runtime video.
6. Compare the actual player frame against both the River Town baseline and `docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`.

## Hard visual constraints

NO_BOX_PROXY_BATTLEFIELD=YES
NO_CYLINDER_PROXY_BATTLEFIELD=YES
NO_COLOR_BLOCK_ENVIRONMENT=YES
NO_DEBUG_LABEL_DOMINATED_CAPTURE=YES
NO_LEARNING_SCENE_AS_PRODUCT_ANCESTOR=YES
RIVER_TOWN_BASELINE_MUST_NOT_SILENTLY_REGRESS=YES
GOLDEN_FRAME_REMAINS_TARGET=YES

## Asset policy

Reuse existing real assets and materials already present in the River Town / Golden Scene / Reference Region pools when provenance is known.
Do not replace existing high-quality content with semantic placeholders.
Do not delete retained high-quality assets merely because the active learning branch did not use them.

## Acceptance

A code or CI pass is not enough.
A product step is accepted only after fresh engine-rendered media is inspected at player layer.
If the visual result is worse than the retained River Town baseline in the dimension being changed, it is a regression unless explicitly justified and approved.

CURRENT_TASK=FRESH_BASELINE_REPRODUCTION_THEN_GAMEPLAY_INTEGRATION
PRODUCT_PRODUCTION_RESUME=YES_HIGH_FIDELITY_SLICE_ONLY
