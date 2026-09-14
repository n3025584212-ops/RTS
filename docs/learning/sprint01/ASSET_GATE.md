# Learning Sprint 01 — Real Asset Gate

STATUS=READY_FOR_AUDIT
TASK_ID=RESOLVE_REPRODUCTION_REAL_ASSET_GATE_V1
DATE=2026-09-14
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7
TARGET=Window 02 isolated end-to-end reproduction asset availability

HARD_RULES:
- NO_BOX_PROXY=YES
- NO_CYLINDER_PROXY=YES
- NO_PLACEHOLDER_PASS=YES
- NO_LICENSE_ASSUMPTION=YES
- NO_IMPORT_ONLY_PASS=YES
- NO_UNUSED_ASSET_PASS=YES
- NO_FILE_EXISTS_EQUALS_RUNTIME=YES
- NO_VISUAL_GUESSING=YES

This gate answers only whether a real, legally evidenced, Godot-imported and actually runtime-used asset family exists for reproduction. It does **not** declare the old Golden Scene product-quality PASS and does not authorize Window 02 to start.

---

# 1. Selected combat-unit family

ASSET_FAMILY=GOLDEN_SCENE_REAL_COMBAT_UNITS
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7
STATUS=READY

Selected family:
- Abrams MBT
- tracked IFV/recon vehicle
- rigged modern soldier

The family is selected because the retained branch closes the chain beyond mere files/import metadata: real meshes are loaded and instantiated by Godot code, counted at runtime and present in a committed 1920x1080 runtime capture.

---

# 2. Abrams MBT

ASSET_FAMILY=ABRAMS_MBT
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

MESH_PATH=`assets/golden_scene/vehicles/mbt_abrams.glb`
MESH_BLOB_SHA=`24a1410d82c4d21e361f0f15caf0a04271e172bd`
GODOT_IMPORT_EVIDENCE=`assets/golden_scene/vehicles/mbt_abrams.glb.import`
IMPORT_BLOB_SHA=`62803b140ae14c860e26dcabbe393e82a443689f`

SOURCE_ORIGIN=Sketlux, “Abrams tank”, OpenGameArt
SOURCE_PAGE=`https://opengameart.org/content/abrams-tank`
LICENSE=CC0 1.0
LICENSE_EVIDENCE=`docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md` plus upstream asset page

TEXTURE_PATH=Authored source/model texture data exists upstream/inside the converted asset family; active Golden Scene unit rendering does not rely on those authored textures for acceptance.
MATERIAL_PATH=`scripts/production/golden/golden_units_v1.gd::_vehicle_camo_material`
MATERIAL_BINDING=Active runtime overrides vehicle mesh materials with a project-generated `ShaderMaterial` camouflage response.

SCENE_BINDING=`scenes/production/GoldenSceneV1.tscn`
SCRIPT_BINDING=`scripts/production/golden_scene_v1.gd` -> `GoldenUnitsV1.build()` -> `scripts/production/golden/golden_units_v1.gd`
RUNTIME_USAGE_EVIDENCE=`GoldenUnitsV1.MBT_PATH=.../mbt_abrams.glb`; `_spawn_model` calls `load`, `instantiate`, sizes/positions/materials the Node3D and `add_child`.
PLAYER_VISIBLE_EVIDENCE=`artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png`; runtime metrics include physical vehicles.

STATUS=READY
UNKNOWN=None for asset availability/license/import/runtime-use gate.
LIMITATIONS=Not bound into active Battle01 gameplay. Active Golden Scene material override means this gate does not claim authored source texture/material fidelity. Product visual/performance acceptance is separate.

---

# 3. IFV / tracked reconnaissance vehicle

ASSET_FAMILY=IFV_RECON
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

MESH_PATH=`assets/golden_scene/vehicles/ifv.glb`
MESH_BLOB_SHA=`ffe94b094a0d220a53671aa22f73cfe62b2401d7`
GODOT_IMPORT_EVIDENCE=`assets/golden_scene/vehicles/ifv.glb.import`
IMPORT_BLOB_SHA=`b59e93be305aa0eb5af0a67d4b4c07304e0e2ee6`

TEXTURE_PATHS:
- `assets/golden_scene/vehicles/ifv_BaseColor.png`
- `assets/golden_scene/vehicles/ifv_Normal.png`
- `assets/golden_scene/vehicles/ifv_Metallic-Roughness.png`
- `assets/golden_scene/vehicles/ifv_Emissive.png`

MATERIAL_PATH=`scripts/production/golden/golden_units_v1.gd::_vehicle_camo_material`
MATERIAL_BINDING=The active Golden Scene overrides vehicle mesh materials with project `ShaderMaterial`; the source texture files remain real asset evidence but are not claimed as the active final material route.

SOURCE_ORIGIN=Mophs “Recon Tank - Update”, based on original “Recon Tank” by MNDV.ecb, OpenGameArt
SOURCE_PAGE=`https://opengameart.org/content/recon-tank-update`
LICENSE=CC BY 4.0
LICENSE_EVIDENCE=`docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md`; the manifest retains Mophs/MNDV.ecb attribution and CC BY 4.0 notice.

SCENE_BINDING=`scenes/production/GoldenSceneV1.tscn`
SCRIPT_BINDING=`GoldenUnitsV1.IFV_PATH` + `_spawn_model`
RUNTIME_USAGE_EVIDENCE=Blue and RED IFV positions instantiate `IFV_PATH`; successful instances increment `physical_vehicle_count`.
PLAYER_VISIBLE_EVIDENCE=Committed Golden Scene runtime screenshot + runtime metrics.

STATUS=READY
UNKNOWN=None for asset availability/license/import/runtime-use gate.
LIMITATIONS=Same material-override and active-Battle01 binding limitations as Abrams.

---

# 4. Infantry / soldier

ASSET_FAMILY=MODERN_INFANTRY
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

MESH_PATH=`assets/golden_scene/infantry/soldier.glb`
MESH_BLOB_SHA=`eb620a0c8d9a03abdc384cf6346a19d4826f0b28`
GODOT_IMPORT_EVIDENCE=`assets/golden_scene/infantry/soldier.glb.import`
IMPORT_BLOB_SHA=`f82c5d1a3dfe8c3d1c51f853763525f39addd434`

SOURCE_ORIGIN=erik90mx “Low Poly Modern Soldier (rigged)”, OpenGameArt
SOURCE_PAGE=`https://opengameart.org/content/low-poly-modern-soldier-rigged`
LICENSE=CC0 1.0
LICENSE_EVIDENCE=`docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md` plus upstream asset page

TEXTURE_PATH=Source/converted GLB asset family; no separate active texture route is claimed here.
MATERIAL_PATH=`scripts/production/golden/golden_units_v1.gd::_infantry_material`
MATERIAL_BINDING=Active runtime applies project `StandardMaterial3D` to soldier meshes.

SCENE_BINDING=`scenes/production/GoldenSceneV1.tscn`
SCRIPT_BINDING=`GoldenUnitsV1.SOLDIER_PATH` + `_spawn_model`
RUNTIME_USAGE_EVIDENCE=Blue and RED infantry loops instantiate the real soldier GLB and increment `physical_infantry_count`.
PLAYER_VISIBLE_EVIDENCE=Committed Golden Scene runtime screenshot + runtime metrics.

STATUS=READY
UNKNOWN=None for asset availability/license/import/runtime-use gate.
LIMITATIONS=Rigged upstream origin does not by itself prove that the isolated Sprint-01 reproduction will use a specific skeletal animation set. Animation integration remains Window 02 implementation work if required by the selected reproduction behavior.

---

# 5. Runtime evidence closes “file exists != used”

RUNTIME_SCENE=`scenes/production/GoldenSceneV1.tscn`
RUNTIME_CONTROLLER=`scripts/production/golden_scene_v1.gd`
UNIT_BUILDER=`scripts/production/golden/golden_units_v1.gd`

The runtime controller calls:

```text
world.build()
units.build(world)
vfx.build(world)
hud.build()
```

The unit builder performs:

```text
load(real GLB)
 -> PackedScene.instantiate()
 -> Node3D
 -> fit/position/rotate
 -> material binding
 -> add_child(root)
```

Committed runtime evidence:

- `artifacts/golden_scene/runtime_evidence.md`
- `artifacts/golden_scene/runtime_metrics.json`
- `artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png`

Recorded facts:

- ENGINE=`4.7.1-stable (official)`
- RENDERER=`gl_compatibility`
- CAPTURE_RESOLUTION=`1920x1080`
- physical_real_asset_vehicles=`PASS`
- physical_real_asset_infantry=`PASS`
- physical_vehicles=`17`
- physical_infantry=`28`
- wrecks=`3`

Therefore:

NO_IMPORT_ONLY_PASS=SATISFIED
NO_UNUSED_ASSET_PASS=SATISFIED
NO_FILE_EXISTS_EQUALS_RUNTIME=SATISFIED
PLAYER_VISIBLE_ASSET_PRESENCE=OBSERVED

---

# 6. Environment availability

The same retained Golden Scene branch contains and runtime-uses real settlement/nature/world assets with license/provenance records in `GOLDEN_SCENE_V1_ASSET_MANIFEST.md`; runtime evidence marks coherent real-asset town, forest/treelines, roads/fields, bridge and shaded river present.

A separate retained Reference Region path also scene-binds `RepairWorkshop.tscn` through `reference_region_01_workshop.gd`, and industrial-workshop artifacts contain Godot import/runtime/capture validation. This packet does not need to rely on Repair Workshop alone to satisfy the reproduction environment gate because the selected Golden Scene environment already has a complete runtime asset route.

ENVIRONMENT_ASSET_FAMILY=READY
ENVIRONMENT_PRODUCT_PASS=NO

---

# 7. Hard limitations — READY is not a product PASS

The exact same committed runtime evidence states:

- `PRODUCT_PASS=NO`
- `AVG_FRAME_MS=134.889`
- `P95_FRAME_MS=140.443`
- `APPROX_FPS=7.4`

Additional limitations:

- Golden Scene is a retained/reference production branch, not the active Battle01 gameplay scene.
- Real units are already runnable/visible, but isolated Sprint-01 player input, command, movement, combat and outcome binding must be implemented/reproduced independently by Window 02.
- Active runtime material overrides mean presence of source textures must not be misreported as active authored-texture fidelity.
- This gate says the real asset family is available; it does not say the old Golden Scene met FRONTLINE final visual target.

---

# 8. Gate verdict

COMBAT_UNIT_ASSET_FAMILY=READY
ENVIRONMENT_ASSET_FAMILY=READY
REQUIRED_ASSETS=READY
02_REPRODUCTION_ASSET_GATE=READY_FOR_AUDIT
WINDOW_02_START=NOT_AUTHORIZED
WINDOW_03_AUDIT=FAIL_PENDING_REAUDIT

Reason: real licensed meshes + material route + Godot imports + scene/script binding + actual runtime instantiation + committed player-visible capture are all evidenced. The remaining work is reproduction/system integration, not finding another placeholder asset family.
