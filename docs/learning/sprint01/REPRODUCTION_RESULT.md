# Sprint 01 Independent Complete RTS Reproduction Result

TASK_ID=COMPLETE_SPRINT01_RUNTIME_PLAYER_GATE_V1
IMPLEMENTATION_TASK_ID=BUILD_SPRINT01_INDEPENDENT_COMPLETE_REPRODUCTION_V1
REPRODUCTION_STATUS=PARTIALLY_REPRODUCED
SCENE=res://scenes/learning/sprint01/Sprint01Reproduction.tscn
IMPLEMENTATION_COMMIT=399b181fdf9b66bbd17ecded617ef7a124be8231
GODOT_VERSION=4.7.1_TARGET_NOT_FRESHLY_EXECUTED

PLAYER_INPUT=UNKNOWN_NOT_EXECUTED
COMMAND_ROUTE=UNKNOWN_NOT_EXECUTED
MOVEMENT=UNKNOWN_NOT_EXECUTED
CONTACT=UNKNOWN_NOT_EXECUTED
COMBAT=UNKNOWN_NOT_EXECUTED
VISIBLE_FEEDBACK=UNKNOWN_NOT_EXECUTED
OUTCOME=UNKNOWN_NOT_EXECUTED

REAL_ASSET_BINDING=PASS_AT_BRANCH_BLOB_BINDING_LEVEL_PENDING_FRESH_GODOT_LOAD
ABRAMS_PATH=res://assets/golden_scene/vehicles/mbt_abrams.glb
ABRAMS_GIT_BLOB=24a1410d82c4d21e361f0f15caf0a04271e172bd
IFV_PATH=res://assets/golden_scene/vehicles/ifv.glb
IFV_GIT_BLOB=ffe94b094a0d220a53671aa22f73cfe62b2401d7
ASSET_SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

ENVIRONMENT=NEW_ISOLATED_3D_REPRODUCTION_IMPLEMENTED_NOT_RUNTIME_VERIFIED
RUNTIME_EVIDENCE=NOT_PRODUCED
INPUT_INJECTION_EVIDENCE=NOT_PRODUCED
CHAIN_EXTRACT=NOT_PRODUCED
EXACT_ASSET_EVIDENCE=NOT_PRODUCED_BY_FRESH_RUNTIME_ROUTE
SCREENSHOT=NOT_PRODUCED
FIRE_SCREENSHOT=NOT_PRODUCED
VIDEO_OR_CAPTURE=NOT_PRODUCED
RUNTIME_BLOCKER_EVIDENCE=docs/learning/sprint01/REPRODUCTION_RUNTIME_BLOCKER.md
WORKFLOW_RUN=34879482970
LATEST_WORKFLOW_JOB=104408501025
LATEST_WORKFLOW_RESULT=FAILURE_BEFORE_RUNNER_STEP_1
SECONDARY_RUNTIME_ROUTE=BLOCKED_BEFORE_GODOT_PROCESS_START

REUSED=Godot 4.7.1 toolchain target; sanctioned retained real-asset blobs; generic capture/runtime infrastructure.
NEWLY_IMPLEMENTED=isolated player selection/input path; ATTACK_MOVE command state; movement/contact; authoritative ammo/HP combat; causal 3D muzzle/tracer/impact/death feedback; player-readable outcome; fresh evidence workflow.
TESTED_EDGE=NONE_AT_PLAYER_LAYER_BECAUSE_NO_FRESH_GODOT_PROCESS_EXECUTED

CODE_EXISTS=PASS
CODE_EXECUTES=UNKNOWN
STATE_CHANGED=UNKNOWN
VISIBLE_FEEDBACK=UNKNOWN
PLAYER_LAYER=UNKNOWN

FAILED_EDGE=INFRASTRUCTURE_BEFORE_RUNTIME_EXECUTION
UNKNOWN=EXACT_PLATFORM_REASON;GODOT_RUNTIME_RESULT;PLAYER_INPUT_CHAIN;COMMAND_CHAIN;MOVEMENT_CHAIN;COMBAT_CHAIN;VISIBLE_FEEDBACK_CHAIN;OUTCOME_CHAIN

The reproduction workflow has now been attempted four times. Attempt 4 job `104408501025` again completed with failure and no recorded steps, before checkout or any custom runtime work. This remains a pre-execution infrastructure result, not a gameplay-chain failure.

The direct runtime route was advanced without changing the reproduction. Xvfb, ffmpeg and Python X11/XTest are present. An official Godot 4.7.1 Linux release ZIP was successfully fetched server-side through a file relay and reported at 76,056,717 bytes, but the isolated execution container could not reach or mount the returned storage URL, so the binary could not be executed or version-verified locally. The private repository's exact Abrams/IFV Git blob identities remain verified, but the connector does not expose those binary bytes into the runtime container. No regenerated or visually similar asset was substituted.

No historical Golden Scene runtime, screenshot, node count, or static code inspection has been promoted to PLAYER evidence. Fresh player-layer runtime artifacts remain mandatory before changing REPRODUCTION_STATUS to REPRODUCED.

SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
