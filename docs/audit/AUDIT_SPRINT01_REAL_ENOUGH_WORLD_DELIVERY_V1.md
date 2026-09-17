# FRONTLINE — SPRINT 01 REAL-ENOUGH WORLD DELIVERY RE-AUDIT V1

STATUS=FINAL
TASK_ID=REAUDIT_SPRINT01_REAL_ENOUGH_WORLD_DELIVERY_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production

AUDITED_RUNTIME_SOURCE_COMMIT=b0fe6d8b1de747606138a9ce1b28b3541b8c464a
AUDITED_WORKFLOW_RUN_ID=35185311167
AUDITED_WORKFLOW_JOB_ID=105086008221
AUDITED_ARTIFACT_ID=10481469643
AUDITED_ARTIFACT_SHA256=a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f

RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
PLAYER_WORLD_READABILITY=PASS

REAL_ENOUGH_WORLD_DELIVERY=FAIL
CAPTURE_STATE_ALIGNMENT=PASS

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_STILL_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_TRANSPORT_TERRAIN_INTEGRATION_ONLY
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

## 1. Scope

This audit follows `docs/audit/TASK_03_REAL_ENOUGH_WORLD_DELIVERY_REAUDIT_V1.md` and is intentionally narrow.

The previous Window 03 audit already accepted the player causal chain, exact Abrams/IFV binding, unit readability, removal of the old persistent world labels, and functional PLAYER readability. Those fields remain accepted because this repair does not show a regression in them.

The two active questions are:

1. whether the fresh PLAYER camera now delivers a sufficiently real battlefield world rather than a diagnostic/tabletop construction;
2. whether initial/fire/final capture checkpoints correspond to their claimed runtime states.

## 2. Evidence identity

GitHub Actions artifact metadata:

```text
RUN_ID=35185311167
JOB_ID=105086008221
HEAD_SHA=b0fe6d8b1de747606138a9ce1b28b3541b8c464a
ARTIFACT_ID=10481469643
ARTIFACT_NAME=sprint01-world-reproduction-b0fe6d8b1de747606138a9ce1b28b3541b8c464a
GITHUB_ARTIFACT_SHA256=a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f
```

Window 03 independently downloaded the artifact and recomputed:

```text
INDEPENDENT_ARTIFACT_SHA256=a5d3f9e9d8551e4ebb5875971e67c9fd769ccd33f5ca71a0b037b2d01c27104f
```

The digest matches exactly.

The workflow job itself is red only because the final git-push step failed after the branch advanced concurrently. Steps for checkout, Godot installation, exact vehicle verification, import/parse, runtime execution, capture, result generation, and artifact upload all completed successfully.

Fresh artifact file hashes independently recomputed by Window 03:

```text
exact_asset_binding.txt  313a425386c8df6f32d9442d3a707aeee3f97267c850e94ebb2b242c17f2eead
input_injection.log      331baef2e43ce65f2dbf99557a884737c565a7a7ddff70f8d7e0843eaf19cdf4
runtime.log              e36c2632ccd9049d130b4892cedd24b9c03e0e226fb6e70aad389dc7ac296a0c
world_chain_extract.txt  b2d8ab9f926d05c819a1ed48c8fae28335bf372ab3e50dabb04572937b60eb05
world_initial.png        4308a12bac915526456c61a1bfac2ab40c83cc1bc9e38d041c1b22f73c0967cd
world_fire_feedback.png  00c5dd2e5d2e60b4019427089b948a6f12c2df423879098d3ab02f17b8c79b98
world_final.png          3d53290bdafb5244d28343c68521b174cc44db7de4e55eee7a761df28584cedc
world_reproduction.mp4   eb5cbd1e9748dbe4821d2514dedbef693e6e1deffde03fcdf72f468ca570f7c6
```

Video inspection:

```text
codec=h264
resolution=1600x900
fps=30
frames=1748
duration=58.266667 s
```

RUNTIME_EVIDENCE_IDENTITY=PASS
HISTORICAL_CAPTURE_SUBSTITUTION=NO

## 3. Runtime semantics remain preserved

Fresh runtime still records:

```text
INPUT_INJECTION=xdotool|KEY=1
INPUT_INJECTION=xdotool|KEY=m
INPUT_EVENT=KEY_1
SELECTED_ENTITY=BLUE_ABRAMS_01
INPUT_EVENT=KEY_M
COMMAND=ATTACK_MOVE
MOVEMENT_STARTED=YES
MOVEMENT_COMPLETED_OR_CONTACT=CONTACT
CONTACT=RED_IFV_01|RANGE=9.61
```

Combat still reaches four authoritative shots and final destruction:

```text
shot 1: ammo 4 -> 3; target HP 100 -> 75
shot 2: ammo 3 -> 2; target HP 75 -> 50
shot 3: ammo 2 -> 1; target HP 50 -> 25
shot 4: ammo 1 -> 0; target HP 25 -> 0
OUTCOME=TARGET_DESTROYED
PLAYER_CHAIN_PASS=YES
WORLD_AND_PLAYER_CHAIN_PASS=YES
```

World constraints also remain present:

```text
WORLD_TO_MOVEMENT=PASS
CONSTRAINT_LAYERS=PASS
SURFACE_BINDING=PASS
VEGETATION_WORLD_CHECK=PASS
ANCHOR_WORLD_CHECK=PASS
OLD_SCENE_COORDINATE_COPY=NO
WORLD_REPRODUCTION_METHOD_PASS=YES
```

PLAYER_CAUSAL_CHAIN_PRESERVED=PASS

## 4. Exact vehicle identity remains intact

The artifact still binds the previously audited combat assets:

```text
ABRAMS_PATH=assets/golden_scene/vehicles/mbt_abrams.glb
ABRAMS_GIT_BLOB=24a1410d82c4d21e361f0f15caf0a04271e172bd
ABRAMS_SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9

IFV_PATH=assets/golden_scene/vehicles/ifv.glb
IFV_GIT_BLOB=ffe94b094a0d220a53671aa22f73cfe62b2401d7
IFV_SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
```

No fake combat-unit fallback was found.

EXACT_VEHICLE_ASSET_BINDING=PASS

## 5. Capture-state alignment is repaired

The previous audit found checkpoint timing wrong. This run replaces fixed wall-clock assumptions with post-draw readiness markers.

Runtime markers:

```text
PLAYER_VISIBLE_INITIAL_FRAME_READY=YES|STATE=WAITING_PLAYER_SELECTION
PLAYER_VISIBLE_FIRE_FRAME_READY=SHOT_01|AMMO=3|TARGET_HP=75|FEEDBACK_EVENTS=1
PLAYER_VISIBLE_FINAL_FRAME_READY=YES|AMMO=0|TARGET_HP=0|OUTCOME=TARGET_DESTROYED
```

Independent inspection of the PNGs confirms:

- `world_initial.png`: actual gameplay frame, `WAITING PLAYER SELECTION`, Ammo 4/4, Target HP 100/100, feedback 0;
- `world_fire_feedback.png`: `CONTACT • COMBAT`, Ammo 3/4, Target HP 75/100, feedback 1, visible muzzle/tracer/impact and `HIT 1`;
- `world_final.png`: `OUTCOME COMPLETE`, Ammo 0/4, Target HP 0/100, `TARGET DESTROYED`, `PLAYER CHAIN COMPLETE`.

The continuous MP4 contains the same progression in order.

CAPTURE_STATE_ALIGNMENT=PASS

## 6. Real-enough world delivery — independent visual falsification

### 6.1 What is genuinely fixed

The repair is materially better than the previous artifact:

- the prior hard rectangular **world boundary** is no longer visible in the player camera;
- the old separate flat-board overlay function is removed;
- the base terrain is now one continuous generated mesh;
- the road and branch are generated as terrain-fitted ribbons rather than BoxMesh road slabs;
- hardstands are terrain-fitted patches rather than CylinderMesh discs;
- real provenance-recorded fir/shrub/rock/house assets remain in the live scene;
- the exact Abrams remains readable;
- the oversized old persistent diagnostic world labels remain absent.

These are real repairs and are not downgraded.

### 6.2 Remaining failure at the PLAYER boundary

Despite those implementation changes, the actual 1600×900 player view still reads primarily as a prototype/test battlefield rather than a sufficiently real world.

The decisive evidence is the fresh PNG/MP4 itself:

1. **The transport surface still visually dominates as a broad, straight-edged, near-rectangular asphalt strip spanning most of the frame.**
   The implementation is now technically a ribbon mesh, but the player-facing result retains the visual language of a giant rectangular test slab. The vertical branch joins it at a hard near-right-angle and reinforces that reading.

2. **The junction/objective hardstand still reads as a large circular/oval decal-like patch.**
   Replacing a CylinderMesh with a terrain-fitted radial patch fixes implementation shape type, but not the visible diagnostic geometry. Player acceptance is based on the rendered result, not primitive class names.

3. **Surface transitions remain abrupt and artificial.**
   Grass-to-road, grass-to-mud/forest-floor, and hardstand transitions are sharply segmented. The broad tan/gray patches around vegetation read as placed semantic zones rather than naturally integrated terrain wear, verges, drainage, shoulders, or disturbed ground.

4. **Terrain relief and scale cues are still too weak in the dominant combat area.**
   The continuous base removes the exposed tabletop edge, but the central playable corridor remains visually very flat. The battlefield lacks enough terrain shaping, verge variation, embankment/cut, ditching, erosion, roadside breakup, or clustered built context to stop reading as an RTS test board.

5. **Real assets are present but not yet integrated strongly enough to carry the scene.**
   Houses, trees and rocks exist, but they remain sparse islands around a large clean transport slab. Their presence proves asset delivery; it does not by itself make the world physically coherent.

6. **The continuous video confirms this is persistent, not a single-frame accident.**
   Across movement, contact, fire and outcome, the same broad slab-like road, orthogonal branch, radial hardstand and patch-based surface segmentation remain the dominant world composition.

Therefore the prior blocker has narrowed but is not closed.

The failed claim is **not** “the code still uses BoxMesh roads” — it does not. The failed claim is that the PLAYER-visible world has crossed from diagnostic/prototype construction into a sufficiently real battlefield delivery.

REAL_ENOUGH_WORLD_DELIVERY=FAIL

## 7. Preserved prior passes

No regression evidence was found for:

```text
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
PLAYER_WORLD_READABILITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
```

Functional readability remains adequate: the player can parse the route, friendly Abrams, enemy IFV, vegetation/built content, impact events and outcome.

The stricter physical-world delivery gate is separate and remains failed.

## 8. Required next repair — narrow only

Return only the physical transport/terrain presentation boundary to Window 02.

Required repair target:

```text
FAILED_BOUNDARY=PLAYER_VISIBLE_TRANSPORT_TERRAIN_INTEGRATION
```

Window 02 should preserve all accepted gameplay and evidence semantics and address only the visible world construction, specifically:

- stop the main road from reading as one broad clean rectangular slab;
- introduce natural edge breakup / shoulder transitions / verge variation while keeping the authoritative corridor unchanged;
- make the branch/junction connection visually graded and less orthogonal/test-layout-like;
- replace obvious radial hardstand/decal reading with contextually shaped disturbed/compacted ground;
- increase terrain relief and roadside physical cues without changing movement/passability semantics;
- integrate houses/vegetation/rocks with the road and terrain rather than placing them as sparse islands around it;
- retain the now-correct capture-state marker logic.

Do not reopen input, command, movement, contact, combat, exact vehicle binding, Stage 4 decomposition, or already-proven world-to-movement logic unless new regression evidence appears.

## 9. Formal verdict

```text
RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
REAL_ENOUGH_WORLD_DELIVERY=FAIL
CAPTURE_STATE_ALIGNMENT=PASS

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_STILL_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_TRANSPORT_TERRAIN_INTEGRATION_ONLY
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

Window 03 does not authorize product production.