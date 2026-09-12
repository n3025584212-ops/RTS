# LEARNING SPRINT 01 — END TO END CHAIN

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Macro chain

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

This file must describe actual evidenced edges, not an idealized architecture diagram.

## Required 13 layers

1. MAP_LOADING_AND_BATTLE_SPACE
2. UNIT_DATA_SOURCE_OF_TRUTH
3. MODEL_MATERIAL_ASSET_BINDING
4. PLAYER_SELECTION
5. COMMAND_ROUTING
6. PATHFINDING_AND_MOVEMENT
7. DETECTION_AND_TARGET_SELECTION
8. FIRE_HIT_DAMAGE_DEATH
9. AI_COMMAND_GENERATION
10. UI_STATE_ACQUISITION
11. ANIMATION_VFX_AUDIO_FEEDBACK
12. CAMERA_AND_RENDER_PRESENTATION
13. FINAL_PLAYER_VISIBLE_RESULT

## Edge record format

Every critical edge must record:

EDGE_ID=
FROM=
TO=
PROJECT=
AUTHORITATIVE_SOURCE=
SOURCE_LOCATION=
SOURCE_TYPE=
BRANCH_TAG_RELEASE=
COMMIT=
STATUS=OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED
RUNTIME_SEMANTICS=
WHAT_THE_SOURCE_ACTUALLY_PROVES=
WHAT_IT_DOES_NOT_PROVE=
HIDDEN_ASSUMPTIONS=
ALTERNATIVE_EXPLANATION=
COUNTEREXAMPLE_SEARCH=
COUNTEREXAMPLE_RESULT=
GENERALIZATION_LEVEL=SOURCE_FACT|PROJECT_SPECIFIC_INFERENCE|CROSS_PROJECT_PATTERN|DESIGN_RECOMMENDATION|UNSUPPORTED_GENERALIZATION
WINDOW_03_VERDICT=PENDING|PASS|DOWNGRADE|FIX|REJECT|UNKNOWN
ALLOWED_FINAL_WORDING=
FRONTLINE_MAPPING=
GAP=
REPRODUCTION_REQUIRED=YES|NO

## Audit rule

No arrow may exist merely because two symbols/components/directories exist.

For a critical `A -> B` edge, Window 01 must identify the source/data/runtime relation; Window 03 must check version identity, caller/data semantics, alternative explanations and counterexamples before the edge is treated as established.

## Current first-trace requirement

PRIMARY_REFERENCE=0_AD_RELEASE_28_CONDITIONAL

The archived `0ad/0ad` GitHub mirror is not accepted as current Release-28 source by default. Version-matched authoritative Release-28 source/data must be used for current implementation claims.

BAR/Recoil and Warzone 2100 are counterexample pools for architectural generalization.

## First vertical trace

TARGET_EVENT=PENDING_VERSION_CORRECT_SELECTION

Required event shape:

`PLAYER INPUT -> SELECTION -> COMMAND -> MOVEMENT -> TARGET -> COMBAT -> STATE CHANGE -> PRESENTATION -> RENDER -> PLAYER`

Upstream must also trace:

`MAP/WORLD + UNIT DATA + ASSET BINDING`

The first trace is not PASS until Window 03 has audited its critical edges and the chain contains explicit UNKNOWN where evidence is missing.
