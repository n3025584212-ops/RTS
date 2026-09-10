# FRONTLINE Window 02 Integrated Recovery State

STATUS=ACTIVE_INTEGRATED_RECOVERY
DATE=2026-09-11
PROJECT=FRONTLINE
ENGINE=Godot 4.7.1
LANGUAGE=Typed GDScript
BRANCH=dev/river-town-local-high-fidelity-v1

## Authority

Window 02 visual-quality/full-battlefield engineering is integrated into the current controlling conversation. There is no separate Window 02 continuation dependency for this branch.

The objective remains: propagate the accepted River Town local high-fidelity visual language into a real full battlefield without collapsing back into the old three-lane/one-screen composition and without silently reducing Near quality.

## Recovered production baseline

RECOVERY_WORKFLOW_RUN=FRONTLINE Full Battlefield V2 LOD Run #13
RECOVERY_RUN_ID=34497789033
RECOVERY_COMMIT=42016d3d0ef3c86ba3fdd4706845862c2b70b4de
RECOVERY_RESULT=SUCCESS
PRODUCTION_SCRIPT=res://scripts/production/full_battlefield_production_v2_lod_v5.gd
PRODUCTION_SCENE=res://scenes/production/FullBattlefieldProductionV2LOD.tscn
REAL_CAPTURE=1920x1080_FORWARD_PLUS_PASS
ENGINE_PROOF=4.7.1-stable
GPU_PROOF=llvmpipe_LLVM_20.1.2
GRASS_INSTANCES=99041
MID_BUILDINGS=22
MID_UNITS=10
MID_TREES=12
FAR_BUILDINGS=12
DRAW_CALLS=1799
RENDERED_PRIMITIVES=33907825
INTERNAL_3D_RENDER_SCALE=1.5
MSAA_3D=2
POST_CAPTURE_IMAGE_EDITING=false
VISUAL_ACCEPTANCE=NOT_CLAIMED

Run #13 re-proved the last successful Run #8 lineage in the current repository. Phase A is complete. The recovered screenshot is an engineering floor only: Near fidelity remains present, but the repeated mid-town mass, wall-like forest band and low battlefield activity are not accepted as final visual quality.

## Preserved post-Run-8 work

No Window 02 work is discarded.

- Run #9 / `6d6831059722de0f179c16f5e22651337f8b0c0a`: MID/FAR battle pressure; runtime render failure; preserved for bounded reintroduction.
- Run #10 / `f2dc52a46569dcbcd36a8c8b05268f4dd57562b5`: bounded mesh smoke replacement; runtime render failure; preserved for component recovery.
- Run #11 / `b1fe2f25927fc4d1127adba030f51c9485855ae2`: authored asymmetric town; runtime render failure; preserved as `FullBattlefieldProductionV2LOD_TownCandidate.tscn`, not production authority.

## Cost-isolation evidence

### Probe A — PASS
SCRIPT=res://scripts/production/full_battlefield_town_probe_a.gd
SCENE=res://scenes/production/FullBattlefieldTownProbeA.tscn
RUN_ID=34498846055
RESULT=REAL_GODOT_4_7_1_FORWARD_PLUS_1920X1080_PASS
PURPOSE=V7 asymmetric parcel layout + Run-8-proven houses + no V7 walls/rubble
CONCLUSION=ASYMMETRIC_LAYOUT_IS_NOT_THE_RUNTIME_REGRESSION
VISUAL_NOTE=layout is more natural than the stable grid but still too repetitive for final acceptance

### Probe B — PASS
SCRIPT=res://scripts/production/full_battlefield_town_probe_b.gd
SCENE=res://scenes/production/FullBattlefieldTownProbeB.tscn
RUN_ID=34499035044
RESULT=REAL_GODOT_4_7_1_FORWARD_PLUS_1920X1080_PASS
PURPOSE=V7 asymmetric parcel layout + original V7 house mix + no V7 walls/rubble
DRAW_CALLS=1807
RENDERED_PRIMITIVES=33834361
CONCLUSION=ORIGINAL_V7_HOUSE_ASSETS_AND_MATERIAL_MIX_ARE_NOT_THE_RUNTIME_REGRESSION
QUALITY_DECISION=DO_NOT_DOWNGRADE_THE_V7_HOUSE_MATERIALS

### Probe C — ACTIVE
SCRIPT=res://scripts/production/full_battlefield_town_probe_c.gd
SCENE=res://scenes/production/FullBattlefieldTownProbeC.tscn
PURPOSE=Probe B content + four original V7 parcel walls + no rubble
DECISION_VALUE=isolates wall layer from the 145-fragment destruction MultiMesh

## Recovery decisions

1. Production authority remains on the re-proven Run #13 / V5 lineage until a promoted candidate completes real 1920x1080 Godot 4.7.1 Forward+ capture.
2. The authored asymmetric layout and original V7 high-quality house mix are now proven-safe components and must be retained.
3. Near quality is not a performance-reduction target.
4. Do not reduce V7 house materials merely to obtain a faster CI result; Probe B proves they are within the current runtime envelope.
5. Run #9/#10 combat-pressure concepts remain recoverable after the town cost gate is closed.
6. Visual acceptance remains manual. CI PASS is necessary runtime evidence, not proof that the image is good enough.

## Execution phases

PHASE_A=RECOVER_STABLE_REAL_RENDER
RESULT=PASS

PHASE_B=ISOLATE_AUTHORED_TOWN_COST
STATUS=ACTIVE
- Probe A: PASS; asymmetric layout safe.
- Probe B: PASS; original V7 house/material mix safe.
- Probe C: active; isolate four wall blocks.
- If Probe C passes, create Probe D restoring the 145-fragment rubble MultiMesh.
- If Probe C fails, the wall layer is the isolated regression point and must be repaired without touching Near or the V7 house mix.

PHASE_C=REINTRODUCE_TOWN_IN_BOUNDED_CHUNKS
STATUS=PENDING
- promote only proven authored-town components onto production;
- preserve bridge corridor and Near floor;
- verify every meaningful promotion with real viewport capture.

PHASE_D=REINTRODUCE_BATTLE_PRESSURE
STATUS=PENDING
- recover Run #9/#10 concepts in bounded groups;
- avoid uncontrolled volumetric or full-scene duplicate cost;
- preserve battlefield activity without sacrificing the local-fidelity floor.

PHASE_E=VISUAL_ACCEPTANCE
STATUS=PENDING
- compare real Godot captures against the local high-fidelity target;
- reject technically green screenshots that remain repetitive, empty, flat, overly fogged, wall-like, or compositionally unrelated to the accepted local scene.

## Current gate

CURRENT_GATE=PHASE_B_PROBE_C_WALL_ISOLATION
DO_NOT_REDUCE_NEAR_QUALITY=YES
DO_NOT_DOWNGRADE_PROVEN_V7_HOUSE_MATERIALS=YES
PRODUCTION_RUNTIME_BASELINE_RECOVERED=YES
WINDOW_02_STATE=INTEGRATED
SEPARATE_WINDOW_02_REQUIRED=NO
