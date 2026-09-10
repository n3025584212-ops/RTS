# River Town Local High-Fidelity Visual Task

STATUS=ACTIVE
OWNER=INTEGRATED_VISUAL_PRODUCTION
BASELINE_COMMIT=d42e6fc2bbe1bad928a16a19caace47dc6e57701
BASELINE_WORKFLOW=FRONTLINE River Town Visual Slice / Run #5
SCENE=res://scenes/production/RiverTownVisualSlice.tscn

## Scope

Continue improving the existing local high-fidelity Godot visual slice and propagate its accepted visual language into a real full battlefield.

Do not migrate this work into the old Battle01 production path.
Do not rebuild the old greybox world.
Do not reduce asset fidelity, terrain detail, vegetation density, material quality, or lighting quality in order to make integration easier.
Do not treat CI success as visual acceptance.
Do not collapse the full battlefield into the rejected North/Central/South three-lane one-screen composition.

## Visual floor

The Run #5 local capture from BASELINE_COMMIT remains the minimum local visual floor.
Every new pass must preserve or improve:
- Abrams close-range material readability
- hero-house damage/material fidelity
- mud/rut/puddle realism
- vegetation density and ground contact
- Forward+ lighting, atmospheric depth, reflections, and ACES response

## Current priority

1. Recover a stable real full-battlefield render on the last proven Run #8 lineage.
2. Preserve and isolate the authored asymmetric town candidate rather than deleting it.
3. Reintroduce the town in bounded groups after identifying its runtime cost.
4. Reintroduce MID/FAR combat pressure only after the full-map budget margin is known.
5. Continue local asset/material improvements only where they materially improve the actual Godot frame.

## Validation

Use real Godot 4.7.1 Forward+ runtime.
Produce a real 1920x1080 viewport capture as evidence.
The screenshot is evidence only; the actual deliverable is the Godot scene and its runtime assets/materials.
Visual acceptance remains manual and comparison-based.

## Forbidden regression

Any pass that looks worse than the accepted visual floor is rejected even if:
- scripts compile,
- CI is green,
- FPS improves,
- the scene contains more nodes/assets.

## Historical local batches — 2026-09-09

Batch 01, Batch 02 and Batch 03 remain implementation checkpoints only. User review found no meaningful overall quality upgrade. They must not be promoted as accepted replacements for the Run #5 local visual floor.

The foreground building source geometry, destruction structure, coherent material quality, ground hierarchy and vegetation naturalness remain valid improvement areas, but small shader/noise iterations alone are not sufficient evidence of progress.

## Full battlefield propagation state — integrated 2026-09-10

WINDOW_02_STATE=INTEGRATED
INTEGRATION_STATE_DOC=docs/current/WINDOW_02_INTEGRATED_RECOVERY_STATE.md
SEPARATE_WINDOW_02_CONTINUATION_REQUIRED=NO

LAST_PROVEN_FULL_BATTLEFIELD_RUN=FRONTLINE Full Battlefield V2 LOD Run #8
LAST_PROVEN_FULL_BATTLEFIELD_COMMIT=a17254612f9b5876bd97b5d4dcea04bffb65cc33
LAST_PROVEN_FULL_BATTLEFIELD_RESULT=SUCCESS
STABLE_SCRIPT=res://scripts/production/full_battlefield_production_v2_lod_v5.gd
STABLE_SCENE=res://scenes/production/FullBattlefieldProductionV2LOD.tscn

POST_RUN8_WORK_PRESERVED=YES
RUN9_BATTLE_PRESSURE_COMMIT=6d6831059722de0f179c16f5e22651337f8b0c0a
RUN10_BOUNDED_SMOKE_COMMIT=f2dc52a46569dcbcd36a8c8b05268f4dd57562b5
RUN11_AUTHORED_TOWN_COMMIT=b1fe2f25927fc4d1127adba030f51c9485855ae2
AUTHORED_TOWN_SCRIPT=res://scripts/production/full_battlefield_production_v2_lod_v7.gd
AUTHORED_TOWN_ISOLATED_SCENE=res://scenes/production/FullBattlefieldProductionV2LOD_TownCandidate.tscn

CURRENT_GATE=RECOVER_STABLE_REAL_RENDER
DO_NOT_ADD_NEW_FULL_BATTLEFIELD_CONTENT_UNTIL_GATE_PASS=YES

The integration strategy is additive and reversible: the production scene uses the last proven runtime lineage while the newer authored-town and combat-pressure work remains preserved as candidates/history for bounded reintroduction. No accepted local fidelity is intentionally discarded.
