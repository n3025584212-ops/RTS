# FRONTLINE — SPRINT 01 WINDOW 02 WORLD REPRODUCTION INDEPENDENT AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
SOURCE_COMMIT=edf8cede10cea24a6218beb73bcca14ef424f5c7
EVIDENCE_COMMIT=03a56be1b0abfaf2248f23b4f9766ebd60aec27e
PARENT_METHOD_AUDIT=docs/audit/AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1.md
PARENT_METHOD_AUDIT_COMMIT=7e6bf5636af83933b6e0b60269f33aafa8a7715f

WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY
RUNTIME_EXECUTION_VERDICT=PASS
WORLD_METHOD_CAUSAL_EXECUTION=PASS
PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
PLAYER_UNIT_READABILITY=FAIL
PLAYER_WORLD_READABILITY=FAIL
REAL_ENOUGH_WORLD_DELIVERY=FAIL
REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_WORLD_TO_PLAYER_DELIVERY_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_PLAYER_WORLD_DELIVERY_FIX
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This audit separates two facts that must not be collapsed:

1. Window 02 has now genuinely executed the audited world-production candidates and the already-proven player causal chain in fresh Godot 4.7.1 runtime.
2. The resulting PLAYER-facing world still fails the Sprint delivery boundary. Successful source/runtime causality does not make an unreadable or placeholder-like world a learning/product PASS.

---

# 1. Audited evidence identity

Fresh GitHub Actions run:

```text
WORKFLOW=Sprint01 World Causal Reproduction
RUN_ID=35090538247
JOB_ID=104775532507
HEAD_SHA=edf8cede10cea24a6218beb73bcca14ef424f5c7
RUN_CONCLUSION=success
GODOT_VERSION=4.7.1.stable.official.a13da4feb
```

Fresh Actions artifact:

```text
ARTIFACT_ID=10444385450
ARTIFACT_NAME=sprint01-world-reproduction-edf8cede10cea24a6218beb73bcca14ef424f5c7
ARTIFACT_SHA256=7e434915823f1f699eaf419ab4fd813408f72c26a432bebee3d2463efe29870f
```

Window 03 downloaded the artifact independently and recomputed the ZIP SHA256. It exactly matches the GitHub Actions artifact digest.

Independent file hashes:

```text
world_initial.png=89232d810933f95e863c5d93538a9b404eac51671af9ba958c698792db077f84
world_fire_feedback.png=13f4c00a07a1a3a39454b04712cb9d11d4edfb32cd6c41fa7d20b75cba2d66c9
world_final.png=bf95ff654bf45c3ae1040453d3f8fd0f3b3ca0d7ae11dd613a43d6e583ab2422
world_reproduction.mp4=33f454b1f4acb3a1d81c50dbdae06e20ef02edbe811274afaf4ab180da46b55e
runtime.log=8570cb8531e96e73ef92d165437bf370ab228d4aec74634d6760a8758f50801e
world_chain_extract.txt=c7debf28ede008f51a3c5dbcb795e204fbda49b8fa2b90fdd3ed3cecadca1194
input_injection.log=ce0bbc187b959b417b1deeaed4c91167ffe2d0082f043365126ae99b388f0254
exact_asset_binding.txt=313a425386c8df6f32d9442d3a707aeee3f97267c850e94ebb2b242c17f2eead
```

Video independently inspected:

```text
codec=h264
resolution=1600x900
fps=30
frames=686
duration=22.866667 s
```

EVIDENCE_IDENTITY=PASS
FRESHNESS=PASS
OLD_GOLDEN_SCREENSHOT_SUBSTITUTION=NO

---

# 2. Runtime infrastructure and code execution

## R01 — real hosted runner executed workflow steps

VERDICT=PASS

Unlike the earlier pre-runner failures, run `35090538247` has a real hosted Ubuntu runner and a populated successful step sequence including:

- checkout;
- capture-tool installation;
- Godot installation/cache restoration;
- SHA256 verification;
- exact vehicle blob verification;
- Godot import and parse;
- graphical X11 runtime;
- external xdotool keyboard input;
- PNG/video capture;
- runtime assertions;
- artifact upload;
- evidence commit.

The old infrastructure blocker is therefore not active for this gate.

RUNTIME_INFRASTRUCTURE=PASS
CODE_EXECUTES=PASS

## R02 — exact Godot build

VERDICT=PASS

The shared toolchain action verifies archive SHA256:

`c7ff14fd28472c8d4f193043de30278dcf7e5241a1dcf7566b02e27addaa33ba`

and reports:

`4.7.1.stable.official.a13da4feb`

GODOT_RUNTIME_IDENTITY=PASS

---

# 3. Exact combat asset identity

## A01 — Abrams and IFV

VERDICT=PASS

Runtime workflow checks exact repository blobs before launching:

```text
Abrams path=assets/golden_scene/vehicles/mbt_abrams.glb
Abrams blob=24a1410d82c4d21e361f0f15caf0a04271e172bd
Abrams SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9

IFV path=assets/golden_scene/vehicles/ifv.glb
IFV blob=ffe94b094a0d220a53671aa22f73cfe62b2401d7
IFV SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
```

The reproduction inherits the real-unit spawn path and instantiates these PackedScenes. No evidence was found of a Box/Cylinder fallback replacing either combat vehicle.

EXACT_VEHICLE_ASSET_BINDING=PASS

Important separation:

`EXACT_ASSET_PRESENT_AND_INSTANTIATED=YES`

does not imply:

`PLAYER_CAN_READ_ASSET_CORRECTLY=YES`.

The latter fails in Section 8.

---

# 4. World-method source execution

The fresh scene directly binds:

`res://scripts/learning/sprint01/sprint01_world_reproduction.gd`

which extends the already-audited player-chain script.

The override builds:

- explicit terrain height/surface mesh;
- main + branch transport ribbons;
- junction and defensive-objective anchors;
- blocker/route constraints;
- semantic surface-role material bindings;
- vegetation patches and stragglers;
- frozen lighting/environment;
- frozen command camera;
- movement passability gate.

This is not merely a document list: the methods are called by `_build_environment()` and their resulting state is consumed by `_verify_world_method()` and `_tick_movement()`.

WORLD_METHOD_SOURCE_PATH=PASS

---

# 5. W-C1..W-C7 independent verdicts

## W-C1 — corrected topology/passability boundary

VERDICT=PASS_CORRECTED_SCOPE

The implementation follows the Window-03 downgrade rather than the rejected strict ordering claim.

`_movement_point_passable()` requires movement to remain inside protected route space and outside authored blocker bounds. `_tick_movement()` evaluates every proposed movement point against that gate. Runtime reports:

```text
WORLD_TO_MOVEMENT=PASS
PLAYER_SAMPLES=33
AUTHORED_CORRIDORS_CLEAR=true
MOVEMENT_REPRESENTATION=DIRECT_KINEMATIC_WITH_WORLD_PASSABILITY_GATE
```

This reproduces the bounded causal claim:

`world topology/constraints -> movement acceptance`

without claiming Godot NavigationServer/navmesh equivalence.

## W-C2 — functional anchors

VERDICT=PASS_FOR_METHOD

Junction and defensive-objective anchors are explicit and content is placed relative to them. No evidence indicates restoration of old Golden Scene/River Town coordinates.

## W-C3 — constraint layers

VERDICT=PASS_FOR_METHOD

Route protection, blocker bounds, vegetation exclusions and sampled corridor clearance are real source/runtime state, not prose-only labels.

## W-C4 — semantic surface/material binding

VERDICT=PASS_CAUSAL_BINDING_ONLY
PLAYER_DELIVERY_QUALITY=FAIL

The source genuinely separates semantic roles such as meadow/forest/transition/road/shoulder/hardstand/earthwork and assigns distinct materials to the corresponding generated geometry.

However the material content itself is generated in the reproduction through 64x64 deterministic noise images and simple StandardMaterial3D values. Therefore the narrow causal method is reproduced, but this does not establish a real-world-quality material pipeline or player-quality terrain presentation.

Window 02's `W-C4=REPRODUCED` is accepted only in this narrow causal sense.

## W-C5 — vegetation patches + stragglers

VERDICT=PASS_DISTRIBUTION_METHOD_ONLY
PLAYER_DELIVERY_QUALITY=FAIL

Runtime confirms 42 patch trees and 7 stragglers and source applies route/anchor exclusions.

But each tree is constructed from a low-segment CylinderMesh trunk plus stacked cone-like CylinderMesh foliage. Rock detail is SphereMesh-based. Thus the distribution method is reproduced, while the resulting visual content remains prototype/semantic geometry rather than evidence of a mature real-world vegetation asset pipeline.

No LOS/cover claim is accepted.

## W-C6 — environment and camera acceptance inputs

VERDICT=PASS_EXECUTION_FAIL_ACCEPTANCE_RESULT

The camera/environment values are frozen and logged, and the screenshots/video are captured through that exact player command camera. This successfully tests the candidate.

The tested result is negative: the chosen camera + unit presentation + labels do not provide acceptable player readability.

## W-C7 — sanctioned real assets / no old coordinates

VERDICT=PASS_PROVENANCE_SCOPE_FAIL_PLAYER_READABILITY

The exact sanctioned Abrams/IFV assets are reused and no old scene-coordinate restoration was found. This governance/provenance part passes.

The player-readability part does not: the Abrams remains effectively unreadable in the delivered view.

Candidate summary:

```text
W-C1=PASS_CORRECTED_SCOPE
W-C2=PASS_FOR_METHOD
W-C3=PASS_FOR_METHOD
W-C4=PASS_CAUSAL_BINDING_ONLY_PLAYER_QUALITY_FAIL
W-C5=PASS_DISTRIBUTION_METHOD_ONLY_PLAYER_QUALITY_FAIL
W-C6=PASS_EXECUTION_FAIL_ACCEPTANCE_RESULT
W-C7=PASS_PROVENANCE_SCOPE_FAIL_PLAYER_READABILITY
```

WORLD_METHOD_CAUSAL_EXECUTION=PASS
WORLD_METHOD_PLAYER_ACCEPTANCE=FAIL

---

# 6. Player causal chain remains reproduced

Runtime independently records:

```text
INPUT_EVENT=KEY_1
SELECTED_ENTITY=BLUE_ABRAMS_01
INPUT_EVENT=KEY_M
COMMAND=ATTACK_MOVE
MOVEMENT_STARTED=YES
MOVEMENT_COMPLETED_OR_CONTACT=CONTACT
CONTACT=RED_IFV_01|RANGE=9.99
```

Four authoritative shots then mutate:

```text
ammo: 4 -> 3 -> 2 -> 1 -> 0
target HP: 100 -> 75 -> 50 -> 25 -> 0
```

Each shot logs same-event muzzle/tracer/impact feedback. Final state reports:

```text
OUTCOME=TARGET_DESTROYED
PLAYER_CHAIN_PASS=YES
WORLD_AND_PLAYER_CHAIN_PASS=YES
```

Window 03 directly inspected the video and final captures. Contact/fire/destruction feedback and the final HUD state are genuinely visible.

PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
FIRE_FEEDBACK_RUNTIME=PASS
OUTCOME_RUNTIME=PASS

This chain should not be redesigned merely to repair the following player-world defects.

---

# 7. Fresh capture timing

Window 02 states that an earlier successful run exposed screenshot timing lag under llvmpipe and was not accepted. The final workflow explicitly waits for the rendered frame to settle after runtime markers before capturing initial/fire/final PNGs.

Independent inspection confirms the final three screenshots now correspond to different intended states:

```text
initial: WAITING PLAYER SELECTION / ammo 4 / HP 100
fire: CONTACT-COMBAT / ammo 3 / HP 75 / feedback 1
final: OUTCOME COMPLETE / ammo 0 / HP 0 / TARGET DESTROYED
```

CAPTURE_STATE_ALIGNMENT=PASS

This fixes capture evidence timing only. It does not fix the player-readability defects below.

---

# 8. Blocking PLAYER-layer falsification

## B01 — Abrams remains visually unreadable

VERDICT=FAIL
BLOCKING=YES

Across `world_initial.png`, `world_fire_feedback.png`, `world_final.png`, and sampled MP4 gameplay frames, the BLUE Abrams remains an extremely small yellow mark/speck in the command view while the RED IFV is large and clearly legible.

This is the same substantive defect recorded in the previous Window-03 player audit. The new world reproduction changes the environment but does not override the inherited vehicle-fitting path responsible for the displayed Abrams presentation.

The base source requests target sizes (`Abrams=7.8`, `IFV=6.7`), but final visual evidence proves those nominal values do not result in comparable/readable player-facing vehicle scale. The exact root cause can involve imported hierarchy transforms/bounds/fitting semantics; this audit does not guess it.

```text
ABRAMS_EXACT_ASSET=YES
ABRAMS_RUNTIME_INSTANCE=YES
ABRAMS_PLAYER_READABLE_AS_MBT=NO
ABRAMS_PRESENTATION_ROOT_CAUSE=UNKNOWN
```

REQUIRED_FIX=Correct the actual player-visible world-space presentation of the same exact Abrams asset and rerun. Do not substitute a fake vehicle.

## B02 — diagnostic world labels still occlude the battle

VERDICT=FAIL
BLOCKING=YES

Large fixed-size world labels remain inherited/added in source, including:

- `ABRAMS • PLAYER`;
- `IFV • HOSTILE`;
- `JUNCTION ECHO`;
- `DEFENSIVE ANCHOR`;
- destruction/hit labels.

In the final 1600x900 player camera, several labels overlap one another and span a large part of the central battlefield. The MP4 shows this persists through the stable gameplay interval rather than being a transient screenshot artifact.

Diagnostic semantics are therefore obscuring the physical result being evaluated.

REQUIRED_FIX=Remove, shrink or reposition diagnostic world labels for the delivery capture. Keep evidence in HUD/logs where it does not cover the battlefield.

## B03 — world remains visually prototype/semantic geometry

VERDICT=FAIL
BLOCKING=YES

The new world is materially better structured than the earlier flat Plane/Box test scene: it contains real height variation, roads, anchor-relative content, forest patches and constraint-aware placement.

However the source and capture show that much of the delivered world is still intentionally synthesized from primitive/prototype content:

- terrain material textures: locally generated 64x64 hash-noise images;
- hardstands: `CylinderMesh`;
- earthworks: low-segment scaled `CylinderMesh`;
- rocks: scaled `SphereMesh`;
- tree trunks: `CylinderMesh`;
- tree crowns: stacked cone-like `CylinderMesh`;
- many world surfaces are simple generated ribbons/meshes with coarse procedural material vocabulary.

The resulting capture reads as a low-poly diagnostic world rather than a causally authored real-enough battlefield region. This fails the Sprint boundary that a source-correct/procedural world is not sufficient by itself and that semantic placeholder delivery cannot substitute for the PLAYER result.

This finding does **not** reject the underlying procedural world method. A procedural pipeline may be a valid production route. It rejects this specific current output as the final learning/player delivery because its content remains too placeholder-like to establish the required world-to-player result.

REQUIRED_FIX=Preserve the proven topology/anchor/constraint logic, but route it through sufficiently real/provenance-recorded terrain/material/vegetation/built-content assets or a content pipeline whose actual player-camera output is no longer semantic primitive presentation.

---

# 9. What 02 did succeed at

Window 02 should not be sent back to redesign already-proven logic.

Accepted results from this run:

```text
HOSTED_RUNTIME=PASS
GODOT_4_7_1=PASS
EXACT_VEHICLES=PASS
PLAYER_INPUT_TO_OUTCOME=PASS
WORLD_TO_MOVEMENT_CAUSAL_GATE=PASS
FUNCTIONAL_ANCHOR_METHOD=PASS
CONSTRAINT_METHOD=PASS
SEMANTIC_SURFACE_BINDING_METHOD=PASS_NARROW
VEGETATION_DISTRIBUTION_METHOD=PASS_NARROW
CAMERA_ENVIRONMENT_FREEZE=PASS
NO_OLD_SCENE_COORDINATE_COPY=PASS
CAPTURE_STATE_ALIGNMENT=PASS
```

The failure is downstream:

`causal world method -> actual player-readable world delivery`.

---

# 10. Reconciliation with Window-02 result file

The following Window-02 claims are accepted in their narrow runtime/method sense:

```text
CODE_EXECUTES=PASS
WORLD_TO_MOVEMENT=PASS
CONSTRAINT_LAYERS=PASS
SEMANTIC_SURFACE_BINDING=PASS
FUNCTIONAL_ANCHORS=PASS
VEGETATION_REGION_PLUS_STRAGGLERS=PASS
CAMERA_ENVIRONMENT_FREEZE=PASS
OLD_SCENE_COORDINATE_COPY=NO
PLAYER_CHAIN_RUNTIME=PASS
WORLD_AND_PLAYER_CHAIN_RUNTIME=PASS
```

The broad aggregate claim:

`WORLD_METHOD_RUNTIME=PASS`

is allowed only as:

`WORLD_METHOD_CAUSAL_EXECUTION=PASS`.

It must not be interpreted as:

`WORLD_METHOD_PLAYER_ACCEPTANCE=PASS`.

The per-candidate `REPRODUCED` labels likewise require the scope qualifications in Section 5.

---

# 11. Final verdict and routing

```text
WINDOW_03_WORLD_REPRODUCTION_AUDIT=FAIL_PLAYER_DELIVERY

EVIDENCE_INTEGRITY=PASS
RUNTIME_EXECUTION_VERDICT=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
WORLD_METHOD_SOURCE_PATH=PASS
WORLD_METHOD_CAUSAL_EXECUTION=PASS
PLAYER_CAUSAL_CHAIN_RUNTIME=PASS
CAPTURE_STATE_ALIGNMENT=PASS

PLAYER_UNIT_READABILITY=FAIL
WORLD_LABEL_OCCLUSION=FAIL
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=FAIL

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_WORLD_TO_PLAYER_DELIVERY_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_PLAYER_WORLD_DELIVERY_FIX
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

Window 02 should preserve:

- the current world topology and passability test semantics;
- anchor/constraint rules;
- the already-proven player/combat chain;
- exact Abrams and IFV identities;
- fresh player-camera capture process.

Window 02 should repair only the failed output boundary:

1. make the exact Abrams visibly coherent/readable at the same battlefield scale as the IFV;
2. remove/shrink/reposition occluding world labels;
3. replace or upgrade primitive semantic world content/material/vegetation presentation until the fresh player camera no longer reads as a diagnostic placeholder scene;
4. rerun the exact causal chain in Godot 4.7.1;
5. return fresh initial/fire/final screenshots + continuous video + runtime log to Window 03.

Window 03 does not authorize Sprint PASS or product production from this run.