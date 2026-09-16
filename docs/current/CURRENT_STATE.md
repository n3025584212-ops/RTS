# FRONTLINE CURRENT PRODUCT STATE

STATUS=ACCEPTED_CURRENT_PRODUCT_STATE
PROJECT=FRONTLINE
STATE_VERSION=V32
SOURCE_OF_TRUTH=THIS_FILE_FOR_CONTROL_AND_ROUTING
CONTROL_SYNC_DATE=2026-09-16

START_HERE=START_HERE.md
ACTIVE_WORK=docs/current/ACTIVE_WORK.md
WINDOW_RECOVERY_INDEX=docs/current/WINDOW_RECOVERY_INDEX.md
RESTART_DECISION=docs/current/RESTART_DECISION.md
REPOSITORY_MAP=docs/ops/REPOSITORY_MAP_V3.md
GOVERNING_CHARTER=docs/FRONTLINE_PROJECT_CHARTER_V3.md
GOVERNING_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V3.md
LEARNING_SYSTEM=docs/FRONTLINE_LEARNING_SYSTEM_V1.md
GPT_FOUR_WINDOW_SYSTEM=docs/GPT_FOUR_WINDOW_SYSTEM_V5.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Branch authority

MAIN_BRANCH=main
MAIN_ROLE=CONTROL_STATE_AND_ROUTING
ACTIVE_BRANCH=learning/sprint01-end-to-end-rts-production
ACTIVE_BRANCH_ROLE=SPRINT01_EVIDENCE_BUILD_RUNTIME_ARTIFACTS
LATEST_KNOWN_ACTIVE_BRANCH_HEAD=66717fbfd8bb2e890e1296e38f7afb6f6ba4da41

IMPORTANT=main does not duplicate every learning-branch artifact. A window recovering state MUST read this file and then refresh ACTIVE_BRANCH HEAD plus the branch artifacts listed in WINDOW_RECOVERY_INDEX.md.

If control and active-branch facts appear different:
- branch-local implementation/evidence facts come from the active branch;
- task authority, routing, product-resume authority and conflict resolution come from Window 00 / main;
- no window may silently overwrite one with the other.

## Current phase

ACTIVE_ISSUE=#39
ACTIVE_SPRINT=LEARNING_SPRINT_01_END_TO_END_RTS_PRODUCTION
CURRENT_GATE=SPRINT01_WORLD_REPRODUCTION_RUNTIME_GATE
PRODUCT_PRODUCTION_RESUME=NO
SPRINT_PASS=NO

The restart remains active. Old Battle01, Prototype B, Golden Scene, River Town, Reference Region and local-high-fidelity branches are historical evidence/tool pools, not current product-direction authority.

## What has already passed

PLAYER_CAUSAL_CHAIN_PREVIOUS_RUNTIME=PASS
CHAIN=`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

WORLD_CAUSAL_DECOMPOSITION=COMPLETED_BY_WINDOW_01
WORLD_CAUSAL_DECOMPOSITION_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
WORLD_CAUSAL_MODEL=BRANCHING_CONSTRAINT_GRAPH
WORLD_METHOD_TRANSFER=NOT_PRODUCT_APPROVED

WINDOW_03_WORLD_METHOD_AUDIT=PASS_WITH_DOWNGRADES
WORLD_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f
BLOCKING_DEFECTS=0
WINDOW_02_ROUTING=APPROVED_FOR_ISOLATED_WORLD_REPRODUCTION

## Current Window 02 implementation

WORLD_REPRODUCTION_TASK=BUILD_SPRINT01_WORLD_CAUSAL_REPRODUCTION_V1
SCENE=res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn
SCRIPT=res://scripts/learning/sprint01/sprint01_world_reproduction.gd
IMPLEMENTATION_DOC=docs/learning/sprint01/WORLD_REPRODUCTION_IMPLEMENTATION.md
WORKFLOW=.github/workflows/learning-sprint01-world-reproduction.yml

WORLD_REPRODUCTION_SCRIPT_FIX_COMMIT=202cc6a8d282d3ec5c8d40932cf740b5e664cfe9
WORLD_REPRODUCTION_SCENE_COMMIT=5df520722d32d4173fa9ea4c2307c95bed1daca5
WORLD_REPRODUCTION_IMPLEMENTATION_DOC_COMMIT=e5eff694f58144a162e411aae6fd50ecad299be2
WORLD_REPRODUCTION_WORKFLOW_COMMIT=7dd7c78160ec8952bf857fd8f2edd368e19de004

Implementation intent:
- preserve the already-proven player causal chain;
- test the audited world-production candidates W-C1(corrected) through W-C7;
- do not restore old scene coordinates;
- do not claim permanent FRONTLINE architecture;
- do not use Plane/Box/color-block semantic placeholders as the delivered world.

## Current blocker

BLOCKER_COMMIT=7a0f24d0ef82f6afcf1666610bd3eb520a94d3de
LATEST_BLOCKER_DOC=docs/learning/sprint01/WORLD_REPRODUCTION_RUNTIME_BLOCKER.md
HOSTED_RUN_ID=35004033644
HOSTED_JOB_ID=104499190425
HOSTED_RESULT=FAILURE_BEFORE_RUNNER
RUNNER_ID=0
JOB_STEPS=[]

CODE_EXISTS=PASS
CODE_EXECUTES=UNKNOWN
WORLD_METHOD_RUNTIME=UNKNOWN
PLAYER_CHAIN_RUNTIME_ON_NEW_WORLD=UNKNOWN
PLAYER_VISIBLE_WORLD_EVIDENCE=NOT_PRODUCED
FAILED_EDGE=RUNTIME_EXECUTION_INFRASTRUCTURE_BEFORE_GODOT

Do not convert this blocker into either a gameplay failure or a reproduction PASS.

## Current four-window allocation

WINDOW_00_STATUS=ACTIVE_CONTROL
WINDOW_00_TASK=Maintain one shared state, repair repository clarity, and route only evidence-backed work.

WINDOW_01_STATUS=HOLD
WINDOW_01_TASK=Stage-4 world causal decomposition is complete; do not extend theory unless a later audit finds a specific evidence gap.

WINDOW_02_STATUS=ACTIVE_RUNTIME_GATE
WINDOW_02_TASK=Execute the existing Sprint01WorldReproduction in fresh Godot 4.7.1 with the exact sanctioned asset bytes and produce fresh logs/screenshots/video. Do not redesign the proven causal semantics merely to bypass the runtime gate.

WINDOW_03_STATUS=HOLD_PENDING_RUNTIME_EVIDENCE
WINDOW_03_TASK=When fresh world-reproduction runtime evidence exists, independently audit method execution, player-visible world quality, exact assets, and the preserved player chain.

## Next route

NEXT=WINDOW_02_COMPLETE_FRESH_WORLD_REPRODUCTION_RUNTIME
NEXT_AFTER_RUNTIME=WINDOW_03_INDEPENDENT_WORLD_ARTIFACT_AUDIT
NEXT_AFTER_AUDIT=WINDOW_00_SPRINT01_TRANSFER_OR_REPAIR_DECISION
NEXT_AFTER_SPRINT_PASS=FIRST_POST_RESTART_FRONTLINE_PRODUCT_SLICE

## Hard boundaries

TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
CI_NOT_VISUAL_ACCEPTANCE=YES
CODE_EXISTS_NOT_RUNTIME_PROOF=YES
SCREENSHOT_NOT_HIDDEN_CAUSAL_PROOF=YES
GREYBOX_AS_PRODUCTION_DELIVERY=FORBIDDEN
OLD_VISUAL_BRANCH_AS_CURRENT_AUTHORITY=FORBIDDEN
UNKNOWN_ALLOWED=YES
VERSION_IDENTITY_REQUIRED=YES
COUNTEREXAMPLE_SEARCH_REQUIRED_FOR_GENERALIZATION=YES
PLAYER_LAYER_MUST_BE_REACHED=YES
