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

