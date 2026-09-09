# River Town Local High-Fidelity Visual Task

STATUS=ACTIVE
OWNER=CODEX_VISUAL_PRODUCTION
BASELINE_COMMIT=d42e6fc2bbe1bad928a16a19caace47dc6e57701
BASELINE_WORKFLOW=FRONTLINE River Town Visual Slice / Run #5
SCENE=res://scenes/production/RiverTownVisualSlice.tscn

## Scope

Continue improving the existing local high-fidelity Godot visual slice only.

Do not migrate this work into Battle01.
Do not rebuild the old greybox world.
Do not reduce asset fidelity, terrain detail, vegetation density, material quality, or lighting quality in order to make integration easier.
Do not treat CI success as visual acceptance.

## Visual floor

The Run #5 capture from BASELINE_COMMIT is the minimum acceptable visual floor.
Every new pass must preserve or improve:
- Abrams close-range material readability
- hero-house damage/material fidelity
- mud/rut/puddle realism
- vegetation density and ground contact
- Forward+ lighting, atmospheric depth, reflections, and ACES response

## Current priority

1. Hero house: richer surface history, edge damage, rubble integration.
2. Abrams: stronger material separation, optics/metal/rubber/mud readability.
3. Ground: deeper wet/dry mud hierarchy, rut geometry/readability, irregular puddles.
4. Vegetation: reduce repetition, improve natural clumping and verge transitions.
5. Lighting: only after material/asset improvements; do not chase exposure-only gains.

## Validation

Use real Godot 4.7.1 Forward+ runtime.
Produce a real 1920x1080 viewport capture as evidence.
The screenshot is evidence only; the actual deliverable is the Godot scene and its runtime assets/materials.
Visual acceptance remains manual and comparison-based.

## Forbidden regression

Any pass that looks worse than Run #5 is rejected even if:
- scripts compile,
- CI is green,
- FPS improves,
- the scene contains more nodes/assets.

## Latest local construction batch — 2026-09-09

Reusable physical house detail, route-local rut geometry, depth-bounded puddles,
and authored Abrams material separation are implemented. See
`docs/current/RIVER_TOWN_LOCAL_HIGH_FIDELITY_BATCH_01.md` for the exact deliverables,
reproduction commands, unchanged baseline controls, same-machine cost comparison,
and image evidence. The task remains ACTIVE; full-map performance and final manual
visual acceptance are not claimed.

USER_REVIEW_2026_09_09=NO_SUBSTANTIAL_VISUAL_IMPROVEMENT
BATCH_01_ACCEPTANCE=REJECTED_AS_QUALITY_UPGRADE

Do not promote batch 01 as the new visual floor. It is an implementation checkpoint
only. Prioritize the foreground building's source geometry, destruction structure
and coherent material quality before further small shader/noise changes. Require
an obvious improvement in the unchanged Run #5 camera before rolling out the kit.


## Batch 02 review — 2026-09-09

BATCH_02_ACCEPTANCE=REJECTED_AS_QUALITY_UPGRADE
BATCH_02_DELIVERY=ISOLATED_STUDY_ONLY

The user again reported no substantial visual improvement. Stop the current
same-angle detail iteration. Preserve the implementation in the opt-in
`res://scenes/production/RiverTownStructureStudy.tscn`; the production scene,
hero asset/materials and main preview remain at the pre-batch 1472a44 checkpoint.
Neither batch 01 nor batch 02 is an accepted replacement for the Run #5 floor.
See `docs/current/RIVER_TOWN_LOCAL_HIGH_FIDELITY_BATCH_02.md` for the rejected
study, actual evidence and measurement limitations. Overall task remains ACTIVE;
no claim of maximum quality or full-game scalability is made.


## Batch 03 ground construction — 2026-09-09

BATCH_03_ACCEPTANCE=REJECTED_AS_QUALITY_UPGRADE
TASK_STATUS=ACTIVE

A bounded terrain and groundcover batch addresses continuous deep-rut silhouettes
and uniform plant distribution. It uses shared deterministic cover data for geometry
placement and soil transitions. This is a limited improvement candidate, not a
claim that the foreground asset-quality problem is solved. See
`docs/current/RIVER_TOWN_LOCAL_HIGH_FIDELITY_BATCH_03.md` for implementation,
real runtime evidence and explicit replication/performance limits.

USER_REVIEW_BATCH_03=NO_MEANINGFUL_OVERALL_IMPROVEMENT
BATCH_03_COMMIT=USER_REQUESTED_IMPLEMENTATION_CHECKPOINT_ONLY
