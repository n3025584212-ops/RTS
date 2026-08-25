# BATTLE01 Revised Role / Capture Runtime QA Gate V1

TASK_ID=RUNTIME_VERIFY_REVISED_ROLE_CAPTURE_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=BLOCKED_RUNTIME_EXECUTION_UNAVAILABLE
GOVERNANCE=FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1
ENGINE_REQUIRED=Godot 4.7.1
VERIFIED_TARGET_SHA=88a50429a8e7b5d7a56cde2eb291925b32470ed0
UPSTREAM=IMPLEMENT_BATTLE01_REVISED_ROLE_CAPTURE_RUNTIME_V1=IMPLEMENTED_RUNTIME_VERIFICATION_BLOCKED

## Independent QA summary

Window 07 independently bound the requested gate to `88a50429a8e7b5d7a56cde2eb291925b32470ed0`, which was the exact `main` head when this gate began.

The frozen revised product contract and Formation V2 rules match the requested semantics:

- Recon ammo 18; Infantry 24; IFV 28; Armor 16.
- Target-class deterministic damage includes Recon -> Heavy Armor 2, Infantry -> Heavy Armor 5, IFV -> Soft 30, IFV -> Heavy Armor 13, Armor -> Light Armor 61.
- Capture/contest semantics are Recon NO/NO, Infantry YES/YES, IFV YES/YES, Armor NO/YES, Logistics NO/NO.
- Ownership transfer remains 15 seconds of continuous uncontested capture-capable presence.

The focused role/capture smoke is correctly wired to the real `res://scenes/battle01/Battle01.tscn` rather than a detached demo. Static preflight confirms it is designed to execute a real `BattleFormation` combat update and assert target-class final damage plus ammo consumption, and to exercise Recon non-capture, Infantry 15-second ownership transfer, Armor deny-without-capture, Armor contest, and both soft-lock scenarios.

The formal roster, logistics flow, and final-objective Enemy AI smoke scripts likewise load the real Battle01 scene and cover the requested directly affected regression domains.

`project.godot` still points to the real Battle01 main scene and retains Forward+; `Battle01.tscn` still contains the Node3D world foundation, Camera3D, Presentation3D, 3D input, real simulation nodes, objectives, AI, war flow, and HUD wiring.

The implementation blast-radius compare from `a7ed25c6dadc725e2fa750d3e9b3070f8958b00a` to the verified target changes the intended Formation resources/rules, combat resolution, objective logic, player war-flow viability, formal roster binding, focused tests, workflow and current/superseded documentation. It does not change `Battle01.tscn`, the 3D-world scripts, Camera3D script, HUD script, or Enemy AI controller.

## Runtime execution status

The GitHub Actions run associated with the exact verified target SHA is:

- workflow: `Godot 4.7.1 Runtime Verify`
- run id: `32822875157`
- head SHA: `88a50429a8e7b5d7a56cde2eb291925b32470ed0`
- conclusion: `failure`
- job: `Headless parse and runtime smoke`
- job steps: empty (`[]`)
- runner id: `0`
- runner name: empty

Therefore no Godot command was executed by that run. This is non-diagnostic for the game implementation: it is not evidence of a gameplay/code failure and cannot be counted as runtime PASS.

Window 07's current execution environment does not provide a Godot 4.7.1 executable, does not contain a runnable checkout of the private FRONTLINE project, and cannot invoke the user's Windows-local Godot runner. No alternate real Godot execution channel is available to this window in the present task execution.

Under `FRONTLINE_PROJECT_EXECUTION_GOVERNANCE_V1`, runtime requirements cannot be accepted solely from static inspection. Consequently the requested real-Battle01 runtime claims remain unverified.

## Gate judgment

CONSTRUCTION_CORRECTNESS=STATIC_PREFLIGHT_PASS_RUNTIME_UNVERIFIED
VERSION_IDENTITY=PASS
CHANGE_SCOPE=PASS
TEST_WIRING_RELEVANCE=PASS
BATTLE01_REAL_RUNTIME=NOT_EXECUTED
ROLE_DAMAGE_RUNTIME=NOT_EXECUTED
OBJECTIVE_CAPTURE_CONTEST_RUNTIME=NOT_EXECUTED
SOFTLOCK_REGRESSION=NOT_EXECUTED
FORMAL_ROSTER_REGRESSION=NOT_EXECUTED
LOGISTICS_REGRESSION=NOT_EXECUTED
ENEMY_AI_REGRESSION=NOT_EXECUTED
3D_FOUNDATION_REGRESSION=NOT_EXECUTED
REAL_PLAYER_FLOW=NOT_EXECUTED
QA_GATE_RESULT=BLOCKED
BLOCKER=NO_REAL_GODOT_4_7_1_EXECUTION_CHANNEL_AVAILABLE_TO_WINDOW_07

## Minimum evidence required to close this gate

Do not redesign the feature and do not create a full-project evidence bundle. The gate only needs one version-bound real Godot 4.7.1 run at the verified gameplay revision (or a descendant proven to contain no gameplay changes) that records:

1. `git rev-parse HEAD` and `Godot --version`;
2. project parse/import and actual Battle01 main-scene launch with no blocking parse/runtime errors;
3. execution and exit codes for:
   - `tests/battle01_role_capture_v2_smoke.gd`;
   - `tests/formal_combat_roster_smoke.gd`;
   - `tests/battle01_logistics_flow_smoke.gd`;
   - `tests/battle01_enemy_ai_final_objective_smoke.gd`;
4. a real Battle01 minimum-flow check proving selection, movement, combat, objective interaction, HUD presence, Victory/Defeat path, and 3D foundation/Camera3D boot;
5. tracked worktree state before/after validation.

No full project ZIP, long duplicate logs, beauty screenshots, or unrelated regression suite is required.

## Cleanup / active state

No gameplay file was modified by Window 07 in this blocked gate. No temporary project copy, ZIP, generated cache, large log bundle, screenshot bundle, or redundant evidence was retained. This QA-gate document is the only intended durable output of the present review.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Remaining downstream work (not part of this gate)

Even after this role/capture slice eventually receives runtime PASS, Battle01 still has revised-product work not implemented by this slice, including:

- Formation-level RESUPPLY rendezvous;
- real RED ammunition resupply;
- seeded RED pre-match defense postures (three authored openings);
- real North/Central/South route-identity terrain/LOS/access differences;
- ADVANCE / HOLD FIRE / revised commander-intent closure;
- pre-battle staging;
- downstream final-art/VFX production after revised runtime playtest gates.

## Next unblock action

NEXT_ACTION=RUN_AND_PUBLISH_REVISED_ROLE_CAPTURE_GODOT_4_7_1_RUNTIME_EVIDENCE_V1
NEXT_OWNER=AVAILABLE_GODOT_4_7_1_RUNNER
RETURN_TO=WINDOW_07_INTEGRATION_QA_PERFORMANCE

This is a runtime-evidence recovery action, not a gameplay redesign or blocker-fix task. If the real run reveals an implementation failure, Window 07 will then issue `FIX_REVISED_ROLE_CAPTURE_RUNTIME_BLOCKERS_V1` to the appropriate implementation owner. If the real run passes, Window 07 may close this gate and route to `IMPLEMENT_BATTLE01_RESUPPLY_AND_RED_LOGISTICS_V1` / Window 05.