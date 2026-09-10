# FRONTLINE Window 02 Integrated Recovery State

STATUS=ACTIVE_INTEGRATED_RECOVERY
DATE=2026-09-10
PROJECT=FRONTLINE
ENGINE=Godot 4.7.1
LANGUAGE=Typed GDScript
BRANCH=dev/river-town-local-high-fidelity-v1

## Authority

Window 02 visual-quality/full-battlefield engineering is now integrated into the current controlling conversation. There is no separate Window 02 continuation dependency for this branch.

The objective remains: propagate the accepted River Town local high-fidelity visual language into a real full battlefield without collapsing back into the old three-lane/one-screen composition and without silently reducing Near quality.

## Stable production baseline

LAST_PROVEN_WORKFLOW_RUN=FRONTLINE Full Battlefield V2 LOD Run #8
LAST_PROVEN_COMMIT=a17254612f9b5876bd97b5d4dcea04bffb65cc33
LAST_PROVEN_RESULT=SUCCESS
PRODUCTION_SCRIPT=res://scripts/production/full_battlefield_production_v2_lod_v5.gd
PRODUCTION_SCENE=res://scenes/production/FullBattlefieldProductionV2LOD.tscn

Run #8 is the current runtime floor because it completed the real Godot 4.7.1 Forward+ 1920x1080 capture and artifact verification.

The stable lineage already contains:
- inherited River Town high-fidelity Near layer;
- battlefield-scale terrain and LOD structure;
- wide strategic river;
- visually dominant strategic bridge;
- three exact high-fidelity town-front anchors;
- preserved Near camera/terrain/detail budgets;
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

## Recovery decisions

1. Production authority is restored to the last proven Run #8 lineage before any further visual expansion.
2. The authored asymmetric town remains intact as an isolated candidate scene and is not deleted or rewritten into a lower-fidelity substitute.
3. Run #9/#10 combat-pressure work remains recoverable from Git history and will be reintroduced only after component-level budget proof.
4. A failed candidate may not replace the stable production scene merely because it imports or compiles.
5. Each material/full-battlefield expansion must again reach a real 1920x1080 Godot 4.7.1 Forward+ completed capture before becoming the new production baseline.
6. Visual acceptance remains manual. CI PASS is necessary runtime evidence, not proof that the image quality is good enough.

## Immediate execution order

PHASE_A=RECOVER_STABLE_REAL_RENDER
- verify the production scene on the Run #8 lineage with the current repository;
- require real Forward+ 1920x1080 capture and runtime metrics;
- do not add new world content during this recovery gate.

PHASE_B=ISOLATE_AUTHORED_TOWN_COST
- run the V7 authored-town candidate independently;
- identify whether the regression is caused by imported house cost, shadows, rubble MultiMesh, material load, or aggregate MID complexity;
- preserve the authored asymmetric spatial composition while reducing only proven waste.

PHASE_C=REINTRODUCE_TOWN_IN_BOUNDED_CHUNKS
- restore authored parcels in bounded groups on top of the proven production lineage;
- verify after each meaningful group;
- retain the strategic bridge corridor and Near visual floor.

PHASE_D=REINTRODUCE_BATTLE_PRESSURE
- recover Run #9/#10 concepts from Git history;
- use bounded mesh/instance effects rather than uncontrolled volumetric cost;
- add combat activity only after the town/full-map runtime margin is known.

PHASE_E=VISUAL_ACCEPTANCE
- compare real Godot captures against the accepted local high-fidelity floor;
- reject technically green passes that visually dilute material quality, terrain readability, vegetation density, atmospheric depth, or battlefield composition.

## Current gate

CURRENT_GATE=PHASE_A_RECOVER_STABLE_REAL_RENDER
DO_NOT_EXPAND_CONTENT_UNTIL_GATE_PASS=YES
WINDOW_02_STATE=INTEGRATED
SEPARATE_WINDOW_02_REQUIRED=NO
