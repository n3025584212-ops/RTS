# FRONTLINE — SPRINT 01 PLAYER WORLD DELIVERY REPAIR RE-AUDIT V1

STATUS=FINAL
TASK_ID=REAUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
AUDITED_RUNTIME_SOURCE_COMMIT=73224323dea523e43d773b539912a700d286ddec
AUDITED_EVIDENCE_COMMIT=79e7b738816c1ba476f6b4a05505e97ab1b73491
PREVIOUS_FAILED_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_WORLD_REPRODUCTION_V1.md
PREVIOUS_FAILED_AUDIT_COMMIT=6dfe56da2c87b62fcb581c06b728c965d4e47bac

RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=PASS
CAPTURE_STATE_ALIGNMENT=FAIL
CAPTURE_STATE_ALIGNMENT_BLOCKING_TO_VISUAL_DECISION=NO

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_REAL_ENOUGH_WORLD_DELIVERY_ONLY
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This re-audit finds that Window 02 repaired two of the three concrete PLAYER defects from the previous audit: the exact Abrams is now visually readable and the oversized persistent world labels no longer occlude the battlefield. The repair also introduces provenance-recorded textures and real vegetation/rock/house GLBs into the live runtime.

However, the actual player camera still visibly reads as a diagnostic/tabletop prototype world rather than a sufficiently real battlefield delivery. The remaining failure is therefore narrow: **PLAYER-facing world construction/presentation quality**, not the already-proven gameplay chain, world-to-movement coupling, exact vehicle binding, or asset availability.

A separate evidence-packaging regression also exists: the named initial and fire-feedback PNG checkpoints are temporally misaligned. This does not prevent the present visual decision because the fresh continuous MP4 contains the full initial/contact/fire/outcome sequence, but the next rerun should repair the checkpoint capture logic.

---

# 1. Current control task and audit boundary

Current control state assigns Window 03 only one task:

`REAUDIT_SPRINT01_PLAYER_WORLD_DELIVERY_V1`

The required re-audit scope is limited to the four previous PLAYER blockers:

1. PLAYER_UNIT_READABILITY;
2. WORLD_LABEL_OCCLUSION;
3. REAL_ENOUGH_WORLD_DELIVERY;
4. PLAYER_WORLD_READABILITY.

Already-proven causal/runtime semantics are not reopened unless the repair introduced a regression.

The audit therefore does **not** ask whether the repaired scene is a permanent FRONTLINE product architecture and does not authorize production.

---

# 2. Fresh evidence identity

## 2.1 GitHub Actions run

Fresh audited run:

```text
WORKFLOW=Sprint01 World Causal Reproduction
RUN_ID=35113803358
HEAD_SHA=73224323dea523e43d773b539912a700d286ddec
RUN_CONCLUSION=success
EVENT=push
```

Fresh artifact:

```text
ARTIFACT_ID=10453641951
ARTIFACT_NAME=sprint01-world-reproduction-73224323dea523e43d773b539912a700d286ddec
GITHUB_ARTIFACT_SHA256=d74192087e8a19aadb58371695d5e71fc79fa3b7c9c4accebbb70ac3034b572f
```

Window 03 independently downloaded the artifact ZIP and recomputed its SHA256:

```text
INDEPENDENT_ZIP_SHA256=d74192087e8a19aadb58371695d5e71fc79fa3b7c9c4accebbb70ac3034b572f
```

The independently computed digest exactly matches GitHub Actions.

## 2.2 Independently recomputed evidence hashes

```text
exact_asset_binding.txt
313a425386c8df6f32d9442d3a707aeee3f97267c850e94ebb2b242c17f2eead

input_injection.log
331baef2e43ce65f2dbf99557a884737c565a7a7ddff70f8d7e0843eaf19cdf4

runtime.log
7f46369e6bdde59f88f29bfbc47841afeeeb1bf45d4189d6b686707f2753c716

world_chain_extract.txt
82ff49c8e92fa749098d4ec14f2422855e5e49543370da74e3b429ee778e130a

world_initial.png
2de4d35857f9fee6b921fb90027a3efc5870a9227996256f1e68fa10a02332db

world_fire_feedback.png
2801c3765c45822876850a73694ea96a5587d278a2607ec5d20ce01ba9f2a0e7

world_final.png
26de0174ac7bfb60379f0d4b42e1f9a1a67f0b2ae92142908ceb59fec2b8d3d3

world_reproduction.mp4
87b6665c5f5b8e118780216d83f6141d36ae9f5ddc97f32985fc0fc6d44dcafa
```

Independent video inspection reports:

```text
codec=h264
resolution=1600x900
fps=30
frames=1452
duration=48.400000 s
```

RUNTIME_EVIDENCE_IDENTITY=PASS
FRESH_RUNTIME=YES
HISTORICAL_GOLDEN_RIVER_REFERENCE_CAPTURE_SUBSTITUTION=NO

---

# 3. Repair layer is actually on the scene execution path

The audited scene:

`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn`

now directly binds:

`res://scripts/learning/sprint01/sprint01_world_delivery_repair.gd`

The repair script extends the previously audited world reproduction rather than replacing its causal system:

`delivery repair -> sprint01_world_reproduction.gd -> sprint01_reproduction.gd`

The repair `_build_environment()` calls `super._build_environment()` first and then adds/hides presentation content. The already-accepted world topology/passability, route constraints, functional anchors, movement gate and combat path therefore remain in the execution chain.

REPAIR_LAYER_EXECUTION_PATH=PASS
CAUSAL_SYSTEM_REPLACED=NO

---

# 4. Player causal chain preserved

Fresh runtime evidence still records real external X11 keyboard injection:

```text
INPUT_INJECTION=xdotool|KEY=1
INPUT_INJECTION=xdotool|KEY=m
```

and runtime reaches:

```text
INPUT_EVENT=KEY_1
SELECTED_ENTITY=BLUE_ABRAMS_01
INPUT_EVENT=KEY_M
COMMAND=ATTACK_MOVE
MOVEMENT_STARTED=YES
MOVEMENT_REPRESENTATION=DIRECT_KINEMATIC_WITH_WORLD_PASSABILITY_GATE
MOVEMENT_COMPLETED_OR_CONTACT=CONTACT
CONTACT=RED_IFV_01|RANGE=9.50
```

The accepted world/movement verification remains present:

```text
WORLD_TO_MOVEMENT=PASS
AUTHORED_CORRIDORS_CLEAR=true
CONSTRAINT_LAYERS=PASS
ROUTE_CLEARANCE=true
VEGETATION_CLEARANCE=true
```

Four authoritative combat events still mutate state:

```text
shot 1: ammo 4 -> 3; HP 100 -> 75
shot 2: ammo 3 -> 2; HP 75 -> 50
shot 3: ammo 2 -> 1; HP 50 -> 25
shot 4: ammo 1 -> 0; HP 25 -> 0
```

and terminate at:

```text
OUTCOME=TARGET_DESTROYED
PLAYER_CHAIN_PASS=YES
WORLD_AND_PLAYER_CHAIN_PASS=YES
```

Continuous video inspection confirms the gameplay sequence reaches contact, repeated visible hits and final destruction.

PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
WORLD_TO_MOVEMENT_REGRESSION=NO
COMBAT_REGRESSION=NO

---

# 5. Exact Abrams / IFV asset identity preserved

The fresh evidence retains the previously audited exact combat asset identities:

```text
ABRAMS_PATH=assets/golden_scene/vehicles/mbt_abrams.glb
ABRAMS_GIT_BLOB=24a1410d82c4d21e361f0f15caf0a04271e172bd
ABRAMS_SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9

IFV_PATH=assets/golden_scene/vehicles/ifv.glb
IFV_GIT_BLOB=ffe94b094a0d220a53671aa22f73cfe62b2401d7
IFV_SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
```

The repair does not substitute a fake player vehicle. It continues to call the real PackedScene spawn path and changes the Abrams fitting target only at presentation level.

EXACT_VEHICLE_ASSET_BINDING=PASS
FAKE_COMBAT_UNIT_SUBSTITUTION=NO

---

# 6. PLAYER_UNIT_READABILITY re-audit

PREVIOUS_VERDICT=FAIL
CURRENT_VERDICT=PASS

The previous fresh runtime showed the BLUE Abrams as an extremely small yellow speck while the RED IFV remained visually legible.

The repair now uses:

```text
ABRAMS_DELIVERY_TARGET_SIZE=54.0
IFV_DELIVERY_TARGET_SIZE=6.7
```

Window 03 does not treat these nominal source values as sufficient proof. The actual fresh video and gameplay frames were inspected.

Current result:

- the Abrams has a clear armored-vehicle/tank silhouette;
- hull and turret/gun form are visually readable;
- it is no longer a tiny marker disconnected from the physical asset;
- its on-screen battlefield prominence is now broadly comparable to the enemy vehicle for the purpose of command-view readability.

This is a **readability** PASS only. The large difference between nominal fitting target numbers should not be promoted into a physical-scale truth about the source assets; imported hierarchy/bounds semantics differ and no independent real-world scale fidelity claim is made here.

PLAYER_UNIT_READABILITY=PASS
PHYSICAL_REAL_WORLD_SCALE_FIDELITY=UNKNOWN_NOT_REQUIRED_FOR_THIS_GATE

---

# 7. WORLD_LABEL_OCCLUSION re-audit

PREVIOUS_VERDICT=FAIL
CURRENT_VERDICT=PASS

The old artifact contained persistent large fixed-size world labels such as:

- `ABRAMS • PLAYER`;
- `IFV • HOSTILE`;
- `JUNCTION ECHO`;
- `DEFENSIVE ANCHOR`.

The repair overrides `_add_world_label(...)` with a no-op. Independent fresh visual inspection confirms those persistent world labels are absent from the battlefield.

The remaining top-left status HUD and top-right outcome text are screen-space evidence UI. Temporary hit/outcome feedback remains associated with combat and is not the previous persistent world-label occlusion defect.

WORLD_LABEL_OCCLUSION=PASS
OLD_PERSISTENT_WORLD_LABELS_VISIBLE=NO

---

# 8. Real asset/material delivery improvement is genuine

The repair is not only a prose change.

It preflights and instantiates a new delivery asset pool under:

`res://assets/learning/sprint01/world_delivery/`

including real GLB content and source textures such as:

- fir sapling;
- shrub;
- moss rocks;
- intact house;
- damaged house;
- leafy grass diffuse;
- aerial mud diffuse;
- gravel ground diffuse;
- asphalt diffuse.

Runtime reports:

```text
PLAYER_WORLD_DELIVERY_ASSET_PREFLIGHT=PASS|COUNT=10
DELIVERY_BUILT_CONTENT=PASS|HOUSES=2|REAL_VEGETATION=18|REAL_ROCKS=6
PLAYER_WORLD_DELIVERY_REPAIR=READY|REAL_ASSET_INSTANCES=26|HIDDEN_PLACEHOLDERS=223
REAL_ENOUGH_WORLD_DELIVERY_PIPELINE=PROVENANCE_RECORDED_TEXTURES_AND_GLBS
```

Source inspection confirms semantic terrain roles are now bound to loaded delivery textures rather than the earlier locally generated 64x64 noise textures. It also confirms real vegetation, rocks and houses are instantiated into the live scene.

Therefore these statements are accepted:

```text
REAL_DELIVERY_ASSETS_PRESENT=PASS
REAL_DELIVERY_ASSETS_ON_RUNTIME_PATH=PASS
PROTOTYPE_NOISE_MATERIALS_REPLACED_FOR_DELIVERY=PASS
```

But asset presence and counts are not PLAYER acceptance. Section 9 controls the final world-delivery verdict.

---

# 9. REAL_ENOUGH_WORLD_DELIVERY re-audit

PREVIOUS_VERDICT=FAIL
CURRENT_VERDICT=FAIL
BLOCKING=YES

The repaired world is materially better than the previous artifact. It now visibly contains actual trees, shrubs, rocks and houses, and the terrain/road surfaces carry real texture content.

However, direct inspection of the fresh 1600x900 player camera and continuous MP4 still shows the world reading primarily as a diagnostic/tabletop construction:

1. The playable ground presents as a large, almost perfectly flat rectangular slab with a hard visible boundary against the gray background.
2. The main road is a broad straight rectangular visual slab and the branch is another strong rectangular slab. Their geometric construction is still immediately legible as authored overlay geometry rather than a road integrated into terrain.
3. Large circular hardstand/diagnostic areas remain visually dominant around the engagement area.
4. Real trees/houses/rocks are placed over this flat surface, but they do not remove the underlying board-like world silhouette.
5. Terrain relief and surface transitions are visually weak because the repair adds a flat delivery ground/road overlay on top of the parent world, masking much of the terrain character that the parent world method generated.
6. The result is therefore no longer a color-block-only test, but it still reads as a **textured diagnostic prototype battlefield**, not as a sufficiently real battlefield delivery.

The source explains why the visual result looks this way. `_add_delivery_ground_and_roads()` explicitly creates visual-only `BoxMesh` overlays for:

```text
DeliveryGround
DeliveryMainShoulder
DeliveryMainRoad
DeliveryBranchShoulder
DeliveryBranchRoad
```

and logs:

`DELIVERY_SURFACE_OVERLAY=PASS|TOPOLOGY_SOURCE=PARENT_WORLD_METHOD|VISUAL_ONLY=YES`

Using real textures on BoxMesh overlays is a valid temporary presentation experiment, but it does not satisfy the previous PLAYER gate merely because the textures have provenance.

This audit therefore rejects the implicit inference:

`real/provenance asset presence -> real-enough PLAYER world`

The correct result is:

```text
REAL_ASSET_PRESENCE=PASS
REAL_TEXTURE_BINDING=PASS
REAL_ENOUGH_WORLD_DELIVERY=FAIL
```

Required repair boundary is narrow:

- keep the existing topology/passability/anchor/constraint/gameplay semantics;
- replace or visually integrate the flat rectangular delivery ground/road overlays so the player camera no longer exposes a board/slab world boundary;
- preserve the new real asset pool;
- make road/terrain/hardstand transitions read as part of one physical world instead of diagnostic geometry;
- rerun the same causal chain and return fresh video/captures.

Do not restart Stage 4 and do not redesign combat.

---

# 10. PLAYER_WORLD_READABILITY re-audit

PREVIOUS_VERDICT=FAIL
CURRENT_VERDICT=PASS

This field is separated from `REAL_ENOUGH_WORLD_DELIVERY` rather than used as a duplicate quality score.

In the repaired continuous gameplay sequence, a viewer can now parse:

- the broad terrain surface;
- main transport route and branch route;
- friendly Abrams;
- enemy IFV;
- real vegetation and built content around the combat zone;
- combat contact;
- repeated hit/impact feedback;
- final destroyed state/outcome.

The old oversized labels no longer prevent reading the physical scene, and the Abrams is no longer a tiny speck.

The world is therefore **functionally readable as a battlefield diagram/gameplay view**, even though it still fails the stricter real-enough visual-delivery gate in Section 9.

PLAYER_WORLD_READABILITY=PASS
PLAYER_WORLD_PRESENTATION_QUALITY=FAIL_VIA_REAL_ENOUGH_WORLD_DELIVERY

---

# 11. New capture-state alignment regression

CAPTURE_STATE_ALIGNMENT=FAIL
CAPTURE_STATE_ALIGNMENT_BLOCKING_TO_VISUAL_DECISION=NO

The final evidence package contains a fresh checkpoint-timing defect:

## `world_initial.png`

The file is a Godot startup splash rather than the intended stable initial gameplay frame.

## `world_fire_feedback.png`

The file is a gameplay frame, but visible HUD state is still:

```text
STATE CONTACT • COMBAT
Ammo 4/4
Target HP 100/100
feedback = 0 event(s)
```

Therefore it is not actually a first-shot/fire-feedback frame despite its filename.

## `world_final.png`

The final frame is aligned correctly:

```text
STATE OUTCOME COMPLETE
Ammo 0/4
Target HP 0/100
feedback = 4 event(s)
TARGET DESTROYED
PLAYER CHAIN COMPLETE
```

The workflow currently waits a fixed 6.0 seconds after a runtime-ready log marker for the initial image and 1.50 seconds after `FIRE_EVENT=SHOT_01` for the fire image. On this llvmpipe + heavier delivery-asset run, runtime/log progress and presented-frame progress remain sufficiently decoupled that those fixed waits are not reliable.

This defect does not block the four PLAYER visual decisions in this audit because the independently inspected continuous 48.4-second MP4 contains:

```text
~15 s: stable gameplay/initial state
~20 s: contact/engaging
~25 s: first visible hit
~30 s: second visible hit
~35 s: third visible hit
~40 s: fourth hit/final outcome
```

Thus the missing visual states exist in the same fresh captured runtime rather than being inferred from logs.

Nevertheless the next 02 rerun should repair checkpoint capture by keying screenshots to visible/rendered state or by using a sufficiently robust render synchronization mechanism, not by assuming a fixed wall-clock sleep after a log line.

---

# 12. Four-blocker disposition

```text
PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=PASS
```

Two previous PLAYER failures are closed:

```text
TINY_ABRAMS_DEFECT=RESOLVED
PERSISTENT_WORLD_LABEL_OCCLUSION=RESOLVED
```

One prior PLAYER boundary remains:

```text
REAL_ENOUGH_WORLD_DELIVERY=UNRESOLVED
```

A new nonblocking evidence-packaging defect is recorded:

```text
CAPTURE_STATE_ALIGNMENT=FAIL_NONBLOCKING_TO_CURRENT_VISUAL_DECISION
```

---

# 13. Final verdict and routing

```text
RUNTIME_EVIDENCE_IDENTITY=PASS
PLAYER_CAUSAL_CHAIN_PRESERVED=PASS
EXACT_VEHICLE_ASSET_BINDING=PASS

PLAYER_UNIT_READABILITY=PASS
WORLD_LABEL_OCCLUSION=PASS
REAL_ENOUGH_WORLD_DELIVERY=FAIL
PLAYER_WORLD_READABILITY=PASS

CAPTURE_STATE_ALIGNMENT=FAIL
CAPTURE_STATE_ALIGNMENT_BLOCKING_TO_VISUAL_DECISION=NO

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_REAL_ENOUGH_WORLD_DELIVERY_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_REAL_ENOUGH_WORLD_DELIVERY_ONLY
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

Window 02 should **not** revisit the already-proven player input, command, movement gate, contact, combat, exact asset binding, functional anchors or route-constraint semantics.

The next repair should only close the remaining PLAYER-facing physical-world presentation boundary: remove the flat board/slab reading by integrating terrain, roads and defensive/hardstand surfaces into one coherent physical world while retaining the real delivery asset pool. The rerun should also fix the two misaligned checkpoint PNG captures.

Window 03 does not authorize production and does not return `READY_FOR_WINDOW_00_DECISION` while `REAL_ENOUGH_WORLD_DELIVERY` remains failed.
