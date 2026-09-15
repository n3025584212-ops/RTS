# FRONTLINE — SPRINT 01 WINDOW 02 REPRODUCTION INDEPENDENT AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_WINDOW02_REPRODUCTION_AND_RUNTIME_BLOCKER_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
AUDIT_DATE=2026-09-15
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
PRE_AUDIT_HEAD=c1182a5e7fe837f9374db940cbc1a9348976c9bd
IMPLEMENTATION_COMMIT=399b181fdf9b66bbd17ecded617ef7a124be8231
PRIOR_AUDIT=docs/audit/AUDIT_SPRINT01_REPAIR_AND_ASSET_GATE_V1.md

IMPLEMENTATION_AUDIT=PASS
REPRODUCTION_AUDIT=BLOCKED
WINDOW_03_ARTIFACT_AUDIT=PASS_SOURCE_IMPLEMENTATION_ONLY
RUNTIME_BLOCKER_VERDICT=SUPPORTED_PRE_EXECUTION_INFRASTRUCTURE_BLOCKER_EXACT_ROOT_CAUSE_UNKNOWN
PLAYER_LAYER_VERDICT=UNKNOWN_NO_FRESH_RUNTIME
SPRINT01_CURRENT_VERDICT=BLOCKED_NOT_COMPLETE
NEXT_ROUTE=RETURN_TO_02_WHEN_RUNTIME_AVAILABLE
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This PASS is deliberately narrow. It means the Window 02 implementation contains a coherent source/callable path for the requested isolated chain and uses the exact audited combat assets. It does not mean the code has executed successfully, game state has changed at runtime, feedback has been rendered, or the PLAYER layer has passed.

---

# 1. Audit boundary

The audit separates five different claims:

```text
CODE_EXISTS
CALLABLE_PATH_EXISTS
CODE_EXECUTES
STATE_CHANGED
PLAYER_VISIBLE_RESULT
```

Only the first two are source-auditable without a fresh runtime. No later state is inferred from static code.

Current result:

```text
CODE_EXISTS=PASS
CALLABLE_PATH_EXISTS=PASS
CODE_EXECUTES=UNKNOWN
STATE_CHANGED=UNKNOWN
VISIBLE_FEEDBACK_RUNTIME=UNKNOWN
PLAYER_VISIBLE_RESULT=UNKNOWN
```

---

# 2. Scene entry and implementation ownership

## C01 — isolated scene actually reaches the reproduction script

VERDICT=PASS

`scenes/learning/sprint01/Sprint01Reproduction.tscn` contains a Node3D root whose script is:

`res://scripts/learning/sprint01/sprint01_reproduction.gd`

The script therefore is not an unreferenced helper file. The scene is the exact scene named by the reproduction workflow.

SOURCE_PATH=PASS
RUNTIME_EXECUTION=UNKNOWN

---

# 3. Requested causal chain — source audit

## C02 — PLAYER INPUT -> selection

SOURCE_PATH=PASS

The engine callback `_unhandled_input(event)` accepts pressed non-echo `InputEventKey` events and routes:

```text
KEY_1
 -> _select_player()
 -> selected=true
 -> selection_ring.visible=true
 -> phase WAITING_SELECTION -> WAITING_COMMAND
```

The workflow intends to send this from an external X11 window event using `xdotool`, rather than directly invoking `_select_player()` from test code.

CALLABLE_PATH_EXISTS=PASS
CODE_EXECUTES=UNKNOWN
PLAYER_INPUT_RUNTIME=UNKNOWN

## C03 — selection -> ATTACK_MOVE command state

SOURCE_PATH=PASS

```text
KEY_M
 -> _issue_attack_move()
 -> requires phase=WAITING_COMMAND and selected=true
 -> command_issued=true
 -> movement_start_position=current player position
 -> phase=MOVING
```

The implementation logs `COMMAND=ATTACK_MOVE`, command target and before/after command state.

CALLABLE_PATH_EXISTS=PASS
COMMAND_RUNTIME=UNKNOWN

## C04 — command -> movement -> contact

SOURCE_PATH=PASS

`_process(delta)` calls `_tick_movement(delta)` while phase is MOVING. `_tick_movement` moves the player model toward the fixed command target and tests distance to the hostile IFV. Contact is entered through `_begin_contact()` when distance is <= `CONTACT_RANGE`.

Static geometry/state constants are internally compatible with contact before the command destination terminates the chain:

- player start x=-18;
- command target x=8;
- target x=14;
- contact range=10.5.

Thus the authored path has a reachable contact transition in source semantics.

CALLABLE_PATH_EXISTS=PASS
MOVEMENT_RUNTIME=UNKNOWN
CONTACT_RUNTIME=UNKNOWN

## C05 — contact -> fire -> ammo / HP -> outcome

SOURCE_PATH=PASS

```text
_begin_contact()
 -> phase=COMBAT
 -> _process(delta)
 -> _tick_combat(delta)
 -> _fire_authoritative_shot()
```

Each authoritative shot:

```text
shot_index += 1
ammo -= 1
target_hp = max(0, target_hp - 25)
```

With starting ammo=4 and target HP=100, the selected source path is authored to reach HP=0 on the fourth shot if the runtime repeatedly enters the shot path.

When HP <= 0:

```text
target_destroyed=true
 -> _apply_destroyed_feedback()
 -> OUTCOME=TARGET_DESTROYED
 -> phase=COMPLETE
 -> _verify_player_chain()
```

SOURCE_PATH=PASS
COMBAT_RUNTIME=UNKNOWN
STATE_CHANGED=UNKNOWN
OUTCOME_RUNTIME=UNKNOWN

---

# 4. Fire/state -> visible-feedback causal source path

## C06 — logical fire and visual nodes share the same authoritative shot call

SOURCE_PATH=PASS

`_fire_authoritative_shot()` first mutates ammo/HP and then directly calls `_spawn_fire_feedback(shot_index)` for the same shot. That function authors:

- a muzzle-flash sphere;
- a tracer beam;
- an impact sphere;
- an impact light;
- a hit world marker.

After HP reaches zero, the same source path calls `_apply_destroyed_feedback()`, which changes the target material/tilt and authors destruction smoke plus a `TARGET DESTROYED` world label.

Therefore this is not two unrelated demonstration systems that merely happen to coexist in the file. The source call graph couples logical shot/state mutation to the feedback authoring path.

LOGICAL_FIRE_TO_FEEDBACK_SOURCE_PATH=PASS
RUNTIME_RENDER_EXECUTION=UNKNOWN
PLAYER_VISIBLE_FEEDBACK=UNKNOWN

Important limitation: the workflow's future log checks and non-empty PNG checks do not by themselves prove that the authored effects are legible to the player in the captured frame. Window 03 must inspect the fresh screenshot/video after a successful run before PLAYER-visible feedback can PASS.

AUTOMATED_VISIBLE_ASSERTION_ALONE_SUFFICIENT_FOR_PLAYER_PASS=NO

---

# 5. Exact real-asset audit

## C07 — exact branch blobs

VERDICT=PASS

At implementation commit `399b181...`:

```text
res://assets/golden_scene/vehicles/mbt_abrams.glb
Git blob=24a1410d82c4d21e361f0f15caf0a04271e172bd

res://assets/golden_scene/vehicles/ifv.glb
Git blob=ffe94b094a0d220a53671aa22f73cfe62b2401d7
```

These exactly match the asset identities previously admitted by the Window 03 asset-gate audit.

EXACT_ASSET_BLOB_BINDING=PASS

## C08 — Godot import and runtime source binding

VERDICT=PASS_AT_SOURCE_LEVEL

Both selected GLBs have Godot `scene` importer metadata resolving them as `PackedScene` resources.

The reproduction script binds the exact constants:

```text
ABRAMS_PATH=res://assets/golden_scene/vehicles/mbt_abrams.glb
IFV_PATH=res://assets/golden_scene/vehicles/ifv.glb
```

`_preflight_exact_assets()` uses `ResourceLoader.exists()` and `load(path)` and requires `PackedScene`.

`_build_units()` calls `_spawn_real_model()` for the Abrams and IFV. `_spawn_real_model()` performs:

```text
load(path) as PackedScene
 -> instantiate() as Node3D
 -> fit real mesh instance to size
 -> position / rotate
 -> add_child(root)
```

There is no BoxMesh/CylinderMesh combat-unit fallback on asset failure. The failure path requests tree exit and returns an empty Node3D only to satisfy control flow; it does not substitute a semantic unit proxy.

REAL_UNIT_PROXY_FALLBACK=NO
REAL_ASSET_SOURCE_PATH=PASS
FRESH_GODOT_LOAD=UNKNOWN

## C09 — old Golden Scene evidence was not substituted

VERDICT=PASS

Current `REPRODUCTION_RESULT.md` explicitly records that no fresh runtime artifacts were produced and retains PLAYER state as UNKNOWN. The branch currently contains no committed `artifacts/learning/sprint01` runtime-evidence directory from this attempted reproduction.

The result does not promote the old Golden Scene screenshot/object counts into the current PLAYER proof.

HISTORICAL_GOLDEN_SCENE_SUBSTITUTION=NO

---

# 6. Workflow implementation audit

## C10 — Godot version/tool acquisition path is syntactically grounded

VERDICT=PASS_AT_SOURCE_LEVEL

The workflow downloads official Godot tag `4.7.1-stable` asset:

`Godot_v4.7.1-stable_linux.x86_64.zip`

Window 03 independently verified that the official Godot GitHub release for `4.7.1-stable` currently contains that exact asset name.

The workflow also verifies `Godot --version` begins with 4.7.1 before continuing.

## C11 — exact asset identity is rechecked in the fresh run

VERDICT=PASS_AT_SOURCE_LEVEL

Before Godot import/runtime, the workflow performs `git hash-object` checks against the audited Abrams/IFV Git blob IDs and writes an `exact_asset_binding.txt` artifact.

This repairs the earlier Golden Scene preflight weakness where a different legacy MBT path could satisfy preflight.

## C12 — workflow is designed to test external input rather than call gameplay functions directly

VERDICT=PASS_AT_SOURCE_LEVEL

The workflow launches the scene under Xvfb, locates the visible `FRONTLINE` window, sends keys `1` and `m` with xdotool, and then requires runtime log evidence for input, selection, command, movement, contact, ammo/HP mutation, feedback event and final outcome.

`project.godot` defines `config/name="FRONTLINE"`, so the window-search string is at least consistent with project configuration.

The workflow also records a video and two screenshots if execution reaches those steps.

CODE_EXECUTES=UNKNOWN

---

# 7. Runtime blocker independent audit

## B01 — attempt 1

VERDICT=SUPPORTED_FAILURE_BEFORE_RUNNER_STEP

Run `34879482970`, attempt 1, job `104094906732`:

```text
conclusion=failure
steps=[]
runner_id=0
runner_name=""
```

No checkout or custom workflow step is recorded.

## B02 — attempt 2

VERDICT=SUPPORTED_FAILURE_BEFORE_RUNNER_STEP

Attempt 2, job `104095477657`:

```text
conclusion=failure
steps=[]
runner_id=0
runner_name=""
```

## B03 — attempt 3

VERDICT=SUPPORTED_FAILURE_BEFORE_RUNNER_STEP

Attempt 3, job `104107122134`:

```text
conclusion=failure
steps=[]
runner_id=0
runner_name=""
```

The latest job exposes no step records. A log download also returned a missing-blob response. The workflow run has no uploaded artifacts.

Therefore the evidence supports:

```text
CHECKOUT_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
DEPENDENCY_INSTALL_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
ASSET_VERIFICATION_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
GODOT_IMPORT_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
GODOT_RUNTIME_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
X11_INPUT_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
CAPTURE_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
RUNTIME_ASSERTIONS_EXECUTED=NO_EVIDENCE_AND_JOB_STEPS_EMPTY
```

## B04 — cross-workflow control

VERDICT=SUPPORTS_INFRASTRUCTURE_CLASSIFICATION

Control run `34689681247` attempt 1 previously completed successfully on the same repository with a real hosted runner and a populated step list, including checkout, Godot 4.7.1 install/import/render and artifact upload.

The later re-run of that historical workflow/commit, attempt 2 job `104095614374`, failed with:

```text
steps=[]
runner_id=0
runner_name=""
```

This materially weakens the hypothesis that the new Sprint 01 scene/script itself caused the observed pre-step failure, because an unrelated previously successful workflow exhibited the same pre-runner failure form when re-run in the same later period.

## B05 — what the blocker evidence does and does not prove

SUPPORTED:

- the observed workflow failures occurred before any recorded workflow step;
- no reproduction Godot process was reached by these GitHub attempts;
- the observed failures are reasonably classified as execution-infrastructure / pre-runner blockers;
- these failures are not evidence of a gameplay-chain failure.

NOT_SUPPORTED:

- a specific quota cause;
- billing cause;
- GitHub-wide outage;
- account policy cause;
- hosted-runner scheduling cause;
- any other exact platform root cause.

Also NOT SUPPORTED:

- that Window 02 code is runtime-correct merely because the runner never executed it.

The evidence neither attributes the failure to the implementation nor excludes latent parse/runtime/input/render defects inside the implementation. Those remain untested.

RUNTIME_BLOCKER_VERDICT=SUPPORTED_PRE_EXECUTION_INFRASTRUCTURE_BLOCKER_EXACT_ROOT_CAUSE_UNKNOWN
EXACT_PLATFORM_ROOT_CAUSE=UNKNOWN
IMPLEMENTATION_CAUSED_OBSERVED_FAILURE=NO_EVIDENCE
IMPLEMENTATION_RUNTIME_CORRECTNESS=UNKNOWN

---

# 8. Secondary execution route audit

Window 03 independently checked the currently available execution container and observed the same key capability pattern reported by Window 02:

```text
Xvfb=/usr/bin/Xvfb
ffmpeg=/usr/bin/ffmpeg
Python Xlib=present
Python X11 XTest=present
Godot command=absent
RTS private checkout=absent
mbt_abrams.glb / ifv.glb local files=absent
shell DNS lookup for github.com=failed
```

This is sufficient to support the narrow operational conclusion:

`SECONDARY_ROUTE_RESULT=NO_GODOT_PROCESS_STARTED`

Window 03 does not independently rely on the reported external-import `credits exceeded` detail; it is unnecessary to establish the blocker because exact Godot + private checkout + exact asset bytes were already unavailable in the alternate environment.

Stopping rather than rebuilding visually similar Abrams/IFV assets is correct under the exact-asset audit gate. A lookalike would create a different artifact and would not prove execution of the audited branch-bound asset path.

SECONDARY_ROUTE_EXACT_ASSET_SUBSTITUTION_REJECTED=PASS

---

# 9. Stage-5 visual/environment boundary

The reproduction source does create an isolated battlefield context: ground, approach road, berms, defensive barriers, hostile contact zone, lighting, camera and HUD. It uses real audited Abrams/IFV models for the combatants.

However, several environment and VFX geometry elements are authored with PlaneMesh / BoxMesh / SphereMesh primitives. Static source inspection cannot establish that the eventual delivered frame satisfies the Sprint contract's requirement for a causally reasonable real environment and its prohibition on a box/color-block delivery image.

This is not treated as a pre-runtime implementation blocker because the combat delivery assets are real and the primitive elements have concrete world/VFX roles rather than serving as hidden unit substitutes. The final visual-contract question must be judged from the fresh runtime capture.

DELIVERY_VISUAL_CONTRACT=UNKNOWN_PENDING_FRESH_CAPTURE

---

# 10. Final two-part verdict

## A — Window 02 implementation quality

```text
IMPLEMENTATION_AUDIT=PASS
CODE_EXISTS=PASS
CALLABLE_PATH_EXISTS=PASS
SOURCE_PATH=PASS
EXACT_REAL_ASSET_BINDING=PASS
NO_UNIT_PROXY_FALLBACK=PASS
WORKFLOW_TEST_PATH=PASS_AT_SOURCE_LEVEL
CODE_EXECUTES=UNKNOWN
```

No source-level defect found in this audit requires returning to Window 02 for implementation repair before attempting runtime again.

## B — complete Sprint reproduction

```text
REPRODUCTION_AUDIT=BLOCKED
CODE_EXECUTES=UNKNOWN
STATE_CHANGED=UNKNOWN
VISIBLE_FEEDBACK=UNKNOWN
PLAYER_LAYER=UNKNOWN
FRESH_RUNTIME_ARTIFACTS=ABSENT
```

A source-complete/callable chain is not a reproduced PLAYER chain.

---

# 11. Required next route for Window 00

```text
WINDOW_03_ARTIFACT_AUDIT=PASS_SOURCE_IMPLEMENTATION_ONLY
RUNTIME_BLOCKER_VERDICT=SUPPORTED_PRE_EXECUTION_INFRASTRUCTURE_BLOCKER_EXACT_ROOT_CAUSE_UNKNOWN
PLAYER_LAYER_VERDICT=UNKNOWN_NO_FRESH_RUNTIME
SPRINT01_CURRENT_VERDICT=BLOCKED_NOT_COMPLETE
NEXT_ROUTE=RETURN_TO_02_WHEN_RUNTIME_AVAILABLE
```

Window 00 should not route this back for speculative gameplay rewriting. When an execution route with Godot 4.7.1, the exact branch checkout and exact audited assets becomes available, Window 02 should run the existing reproduction first.

Required fresh evidence remains:

1. exact scene / commit / Godot version;
2. exact Abrams/IFV blob verification from the executing checkout;
3. external input injection log;
4. runtime log proving input -> selection -> command -> movement -> contact -> fire -> ammo/HP mutation -> outcome;
5. fire feedback screenshot;
6. final screenshot;
7. continuous video/capture;
8. Window 03 visual and causal review of those fresh artifacts.

Only if that runtime reveals a source/runtime defect should the route change to `RETURN_TO_02_FOR_IMPLEMENTATION_FIX`.

Until then:

```text
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```
