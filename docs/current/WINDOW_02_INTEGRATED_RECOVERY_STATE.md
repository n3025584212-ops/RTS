# FRONTLINE Window 02 Integrated Recovery State

STATUS=ACTIVE_INTEGRATED_RECOVERY
DATE=2026-09-10
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

The stable lineage contains:
- inherited River Town high-fidelity Near layer;
- battlefield-scale terrain and tiered LOD structure;
- wide strategic river;
- readable strategic bridge;
- three exact high-fidelity town-front anchors;
- preserved Near terrain/detail budgets;
- real runtime capture evidence.

## Preserved post-Run-8 work

No Window 02 work is discarded.

### Run #9 lineage
COMMIT=6d6831059722de0f179c16f5e22651337f8b0c0a
INTENT=add MID/FAR battle pressure
RESULT=RUNTIME_RENDER_FAILURE
STATUS=PRESERVED_IN_GIT_HISTORY_FOR_BOUNDED_REINTRODUCTION

### Run #10 lineage
COMMIT=f2dc52a46569dcbcd36a8c8b05268f4dd57562b5
INTENT=replace MID/FAR volumetric smoke with bounded mesh plumes
RESULT=RUNTIME_RENDER_FAILURE
STATUS=PRESERVED_IN_GIT_HISTORY_FOR_COMPONENT_RECOVERY

### Run #11 lineage
COMMIT=b1fe2f25927fc4d1127adba030f51c9485855ae2
INTENT=rebase on Run #8 and replace procedural grid town with authored asymmetric town
RESULT=RUNTIME_RENDER_FAILURE
SCRIPT=res://scripts/production/full_battlefield_production_v2_lod_v7.gd
ISOLATED_SCENE=res://scenes/production/FullBattlefieldProductionV2LOD_TownCandidate.tscn
STATUS=PRESERVED_AS_ACTIVE_CANDIDATE_NOT_PRODUCTION_AUTHORITY

## Active cost-isolation probes

### Probe A
SCRIPT=res://scripts/production/full_battlefield_town_probe_a.gd
SCENE=res://scenes/production/FullBattlefieldTownProbeA.tscn
PURPOSE=keep V7 asymmetric parcel layout, use only Run-8-proven house assets, remove V7 walls and rubble
DECISION_VALUE=tests whether asymmetric spatial composition itself is safe

### Probe B
SCRIPT=res://scripts/production/full_battlefield_town_probe_b.gd
SCENE=res://scenes/production/FullBattlefieldTownProbeB.tscn
PURPOSE=keep V7 asymmetric parcel layout and original V7 house mix, remove V7 walls and rubble
DECISION_VALUE=isolates imported-house/material cost from destruction-detail cost

## Recovery decisions

1. Production authority remains on the re-proven Run #13 / V5 lineage until a candidate completes real 1920x1080 Godot 4.7.1 Forward+ capture.
2. The authored asymmetric town remains intact and must not be replaced by a lower-quality grid merely to obtain a green build.
3. Run #9/#10 combat-pressure concepts remain recoverable and will be reintroduced after town/full-map runtime margin is understood.
4. Near quality is not a performance-reduction target.
5. Reduce only MID/FAR cost that is actually proven unnecessary or excessive.
6. Visual acceptance remains manual. CI PASS is necessary runtime evidence, not proof that the image is good enough.

## Execution phases

PHASE_A=RECOVER_STABLE_REAL_RENDER
RESULT=PASS

PHASE_B=ISOLATE_AUTHORED_TOWN_COST
STATUS=ACTIVE
- finish Probe A and Probe B;
- if A passes and B fails, isolate ordinary_house_textured vs hero_house_ruined;
- if A and B pass, isolate walls and rubble separately;
- if A fails, investigate authored visibility/culling/layout interaction before changing assets.

PHASE_C=REINTRODUCE_TOWN_IN_BOUNDED_CHUNKS
STATUS=PENDING
- promote only proven authored-town components onto production;
- preserve bridge corridor and Near floor;
- verify every meaningful promotion with real viewport capture.

PHASE_D=REINTRODUCE_BATTLE_PRESSURE
STATUS=PENDING
- recover Run #9/#10 concepts in bounded groups;
- avoid uncontrolled volumetric or full-scene duplicate cost;
- preserve visual battlefield activity without sacrificing the local-fidelity floor.

PHASE_E=VISUAL_ACCEPTANCE
STATUS=PENDING
- compare real Godot captures against the local high-fidelity target;
- reject technically green screenshots that remain repetitive, empty, flat, overly fogged, wall-like, or compositionally unrelated to the accepted local scene.

## Current gate

CURRENT_GATE=PHASE_B_ISOLATE_AUTHORED_TOWN_COST
DO_NOT_REDUCE_NEAR_QUALITY=YES
PRODUCTION_RUNTIME_BASELINE_RECOVERED=YES
WINDOW_02_STATE=INTEGRATED
SEPARATE_WINDOW_02_REQUIRED=NO
