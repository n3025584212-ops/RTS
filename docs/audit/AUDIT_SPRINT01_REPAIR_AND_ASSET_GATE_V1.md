# FRONTLINE — SPRINT 01 REPAIR + REAL ASSET GATE RE-AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_SPRINT01_REPAIR_AND_ASSET_GATE_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
AUDIT_DATE=2026-09-14
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
TARGET_REPAIR_COMMIT=078f39bad65f25ad1705fd13d8ffcc6eef31fcef
PARENT_AUDIT=docs/audit/AUDIT_SPRINT01_SYSTEM_CAUSAL_CHAIN_V1.md
PARENT_AUDIT_COMMIT=fe3975355c16a8e665d54c0b62008e124de792ac
ASSET_SOURCE_BRANCH=dev/reference-region-v1
ASSET_SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7

WINDOW_03_REAUDIT=PASS
BLOCKING_AUDIT_DEFECTS=0
WINDOW_02_ROUTING=READY_FOR_WINDOW_00_DECISION
WINDOW_02_SELF_AUTHORIZATION=NO
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This PASS is narrow. It means Window 01 repaired the two blocking epistemic defects from the prior 03 audit and demonstrated that a real asset family is available/importable/instantiable for Window 02. It does **not** mean the Sprint is complete, the old Golden Scene is accepted, or PLAYER-layer reproduction exists.

---

# 1. Prior blocker re-audit

## B01 — Release-28 version identity

PRIOR_VERDICT=FIX
CURRENT_VERDICT=PASS

Window 01 now records:

- `ZERO_AD_INSPECTED_SOURCE_STATE=a2cae4d69f...`
- `ZERO_AD_RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28`
- `VERSION_IDENTITY=VERSION_IDENTITY_PENDING`
- exact official R28 release/tag/tree/commit identity remains UNKNOWN.

This exactly repairs the former overclaim. Direct semantic statements are now statements about the inspected `a2ca...` source state first; the R28 relation is qualified as inferred.

ALLOWED_WORDING=`inspected a2cae4d... source state believed/version-matched to R28`
FORBIDDEN_WORDING=`a2cae4d... is proven to be the exact authoritative official R28 source tree`

B01_VERSION_IDENTITY_REPAIR=PASS
U_R28_VERSION_IDENTITY=REMAINS_UNKNOWN

## B02 — event-to-render causal stitch

PRIOR_VERDICT=FIX
CURRENT_VERDICT=PASS

The repaired packet explicitly rejects the old serial model and uses a branching causal DAG:

- simulation/state attack branch = OBSERVED for the selected inspected path;
- attack-animation -> IID_Visual -> VisualActor -> UnitRenderer -> SceneCollector = OBSERVED/source-closed branch;
- projectile render suffix = UNKNOWN;
- impact render suffix = UNKNOWN;
- death/corpse render suffix = UNKNOWN;
- audio backend/output suffix = UNKNOWN;
- persistent unit render loop is explicitly parallel and no longer used as proof that all event branches converge through VisualActor.

This satisfies the prior 03 requirement not to infer causal continuity from adjacency.

B02_BRANCHING_DAG_REPAIR=PASS
LINEAR_ATTACK_TO_RENDER_CHAIN=REJECTED_CORRECTLY

---

# 2. Prior non-blocking repair re-audit

N01_REVISION_TRACEABILITY=PASS
The repaired learning packet now includes the audit contract and core learning governance files that were absent from the earlier branch revision; the pre-audit files are preserved under `docs/learning/sprint01/baseline/`.

N02_FACT_VS_INFERENCE=PASS
The current packet separates the source fact (`Battle3DPresentation` uses primitive role proxies in the inspected active path) from the Sprint-specific inference (that those proxies alone do not satisfy Issue #39's real-enough reproduction-asset requirement).

N03_DETERMINISM_WORDING=PASS
The packet now describes the inspected 0 A.D. mechanism as a turn/command-queue transport boundary without inferring a unique design motive or guaranteed deterministic property from that structure alone.

---

# 3. Real combat asset gate — independent source inspection

TARGET=Whether Window 02 has a real, provenance-recorded, Godot-imported and actually instantiable combat asset family available for an isolated reproduction.

## A01 — Exact retained asset blobs exist

VERDICT=PASS

At `dev/reference-region-v1@5f2ff1c0...` the exact declared Git blobs exist:

- Abrams MBT: `assets/golden_scene/vehicles/mbt_abrams.glb` -> `24a1410d82c4d21e361f0f15caf0a04271e172bd`
- IFV: `assets/golden_scene/vehicles/ifv.glb` -> `ffe94b094a0d220a53671aa22f73cfe62b2401d7`
- soldier: `assets/golden_scene/infantry/soldier.glb` -> `eb620a0c8d9a03abdc384cf6346a19d4826f0b28`

FILE_EXISTS_ONLY_PASS=NO
These blobs are only the first evidence step.

## A02 — Godot import metadata exists for the exact selected assets

VERDICT=PASS

The `.import` records for MBT, IFV and soldier use Godot's `scene` importer, resolve to `PackedScene` imported `.scn` resources and have animation import enabled.

Verified import blob identities:

- MBT import: `62803b140ae14c860e26dcabbe393e82a443689f`
- IFV import: `b59e93be305aa0eb5af0a67d4b4c07304e0e2ee6`
- soldier import: `f82c5d1a3dfe8c3d1c51f853763525f39addd434`

IMPORT_ONLY_PASS=NO
Import metadata is not treated as runtime proof.

## A03 — Actual source wiring instantiates the exact selected assets

VERDICT=PASS

`scripts/production/golden/golden_units_v1.gd` binds:

```text
MBT_PATH     -> mbt_abrams.glb
IFV_PATH     -> ifv.glb
SOLDIER_PATH -> soldier.glb
```

Its `_spawn_model` performs:

```text
load(path) as PackedScene
 -> instantiate
 -> validate Node3D
 -> fit / position / rotate
 -> material override
 -> add_child(root)
```

The builder increments physical counts only when the returned instance is non-null. The source-defined placements imply 17 vehicle instances (including 3 wrecks) and 28 infantry instances, matching the committed runtime metrics.

RUNTIME_INSTANTIATION_SOURCE_PATH=PASS

## A04 — Scene/controller execution chain reaches the unit builder

VERDICT=PASS

`GoldenSceneV1.tscn` binds the root controller, the `Units` node to `golden_units_v1.gd`, and the current world node to `golden_world_v17.gd`.

The root `_ready()` executes:

```text
world.build()
units.build(world)
vfx.build(world)
hud.build()
```

Therefore the selected unit builder is part of the retained scene's actual execution path, not an unused helper file.

UNUSED_ASSET_PATH=REJECTED

## A05 — Runtime metrics artifact is consistent with the source build counts

VERDICT=PASS_AS_RUNTIME_RECORD

The committed runtime record reports:

- Godot `4.7.1-stable (official)`
- `gl_compatibility`
- 1920x1080 capture artifact
- physical vehicles = 17
- physical infantry = 28
- wrecks = 3
- `PRODUCT_PASS=false`
- approx FPS = 7.4 in that capture environment.

The source-side spawn counts independently match the recorded 17 / 28 totals. This supports that the retained Golden Scene run instantiated the selected asset family.

It does not prove product quality, acceptable performance, or the new Sprint reproduction.

---

# 4. Asset provenance/license audit

VERDICT=PASS_FOR_REPRODUCTION_AVAILABILITY

The repository manifest records and preserves the selected family as:

- Abrams tank — Sketlux / OpenGameArt — CC0 1.0;
- Recon Tank Update — Mophs, based on MNDV.ecb — CC BY 4.0, with attribution chain retained;
- Low Poly Modern Soldier (rigged) — erik90mx / OpenGameArt — CC0 1.0.

The license/provenance evidence is specific enough for the learning reproduction gate. Window 03 does not infer broader legal advice or asset suitability beyond the recorded licenses and attribution requirements.

COMBAT_ASSET_PROVENANCE_GATE=PASS

---

# 5. Environment asset availability

VERDICT=PASS_WITH_SOURCE_CORRECTION

The retained Golden Scene has a real environment/content route suitable as an available reproduction source family. However one source citation needs precision:

`GoldenSceneV1.tscn` does **not** directly bind `golden_world_v1.gd`; it binds `golden_world_v17.gd`.

`GoldenWorldV17` extends `GoldenWorldV1` and:

- retains base material/environment/terrain/field/camera behavior through `super` where used;
- replaces/extends town construction through `GoldenWorldV20TownCore` / `GoldenWorldV20TownStreets`;
- replaces forest construction through `GoldenWorldV17Forest`;
- applies later material/terrain modules.

Therefore `golden_world_v1.gd` remains a base implementation, not the complete active scene wiring by itself.

REQUIRED_CORRECTION=When claiming current Golden Scene environment runtime wiring, cite `GoldenSceneV1.tscn -> golden_world_v17.gd -> inherited/extension modules`, not `golden_world_v1.gd` alone.

ENVIRONMENT_ASSET_AVAILABILITY=PASS

---

# 6. Falsification findings that must NOT be promoted to PASS

## F01 — Old Golden Scene PLAYER-visible asset presence

WINDOW_01_WORDING=`PLAYER_VISIBLE_ASSET_PRESENCE=OBSERVED`
VERDICT=DOWNGRADE_TO_UNKNOWN
BLOCKING_FOR_ASSET_AVAILABILITY=NO
BLOCKING_FOR_PLAYER_LAYER=YES

Reason:

The old Golden Scene controller's runtime checks for `physical_real_asset_vehicles` and `physical_real_asset_infantry` are driven by instance counters, not image-object verification. Its image metrics test nonblank/chromatic central-world pixels but do not identify the selected MBT/IFV/soldier instances in the captured frame.

A committed PNG exists, but in this independent audit path the private-repository binary could not be decoded/visually inspected through the connected GitHub source interface. Therefore the evidence independently proves:

```text
asset exists
-> imports
-> source loads/instantiates
-> runtime count record exists
-> screenshot file exists
```

It does **not**, by these machine-readable facts alone, prove:

```text
specific MBT/IFV/soldier asset is visibly present/readable in the screenshot
```

ALLOWED_WORDING=`retained Golden Scene source and runtime records support real asset instantiation; a committed capture exists`
FORBIDDEN_WORDING=`Window 03 independently verified the selected assets as visibly readable in the old capture`

Most importantly, the old Golden Scene capture may not be reused as Window 02's PLAYER-layer reproduction evidence. Window 02 must create a fresh artifact/capture for the isolated causal chain.

## F02 — Golden Scene preflight exact MBT path mismatch

VERDICT=FIX_NONBLOCKING

`golden_scene_v1.gd::_preflight_assets()` checks legacy:

`res://assets/golden_scene/vehicles/mbt.glb`

but `GoldenUnitsV1.MBT_PATH` actually uses:

`res://assets/golden_scene/vehicles/mbt_abrams.glb`

The legacy `mbt.glb` also exists, so the current preflight could pass even if the actual Abrams resource were missing. This does not falsify the retained run because `GoldenUnitsV1` separately `_require_model(MBT_PATH)` and `_spawn_model(MBT_PATH)` and the Abrams blob exists; nevertheless preflight is not an exact guard for the active MBT resource.

REQUIRED_02_BEHAVIOR=Do not reuse this legacy preflight as proof. The isolated reproduction should validate exactly the asset paths it actually loads.

---

# 7. Current gate after re-audit

```text
B01_VERSION_IDENTITY_REPAIR=PASS
U_R28_VERSION_IDENTITY=UNKNOWN_RETAINED

B02_BRANCHING_DAG_REPAIR=PASS
PROJECTILE_RENDER_BRANCH=UNKNOWN_RETAINED
IMPACT_RENDER_BRANCH=UNKNOWN_RETAINED
DEATH_CORPSE_RENDER_BRANCH=UNKNOWN_RETAINED
AUDIO_OUTPUT_BRANCH=UNKNOWN_RETAINED

N01_REVISION_TRACEABILITY=PASS
N02_FACT_VS_INFERENCE=PASS
N03_DETERMINISM_WORDING=PASS

COMBAT_ASSET_BLOBS=PASS
GODOT_IMPORT_ROUTE=PASS
SOURCE_RUNTIME_INSTANTIATION_ROUTE=PASS
ASSET_PROVENANCE_LICENSE_GATE=PASS
ENVIRONMENT_ASSET_AVAILABILITY=PASS_WITH_SOURCE_CORRECTION

OLD_GOLDEN_PLAYER_VISIBLE_ASSET_PRESENCE=UNKNOWN
OLD_GOLDEN_PRODUCT_PASS=NO
OLD_GOLDEN_PERFORMANCE_ACCEPTANCE=NO
GOLDEN_PREFLIGHT_ACTIVE_MBT_PATH=FIX_NONBLOCKING

02_REPRODUCTION_ASSET_GATE=PASS
WINDOW_01_AUDIT_BLOCKER_RESPONSE=PASS
WINDOW_03_REAUDIT=PASS
WINDOW_02_ROUTING=READY_FOR_WINDOW_00_DECISION
WINDOW_02_START=NOT_SELF_AUTHORIZED
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

---

# 8. Mandatory requirements if Window 00 routes work to Window 02

Window 02 must independently produce a new isolated running artifact that proves the requested causal chain:

`PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT/COMBAT -> VISIBLE FEEDBACK -> OUTCOME`

Required evidence:

1. exact scene / commit / Godot version;
2. exact selected real asset paths actually loaded by the reproduction;
3. player input evidence that changes game state through the intended command path;
4. movement/path/contact evidence;
5. combat state mutation and outcome evidence;
6. visible presentation feedback causally connected to those state changes;
7. fresh screenshot/video/runtime logs from the reproduction itself;
8. explicit failure localization by evidence-graph edge if any link breaks;
9. no use of the old Golden Scene screenshot, object counts or product prose as substitute for the reproduction's PLAYER evidence;
10. no claim that source existence, CI, node counts or a single screenshot proves hidden implementation semantics.

WINDOW_03_NEXT_TASK=FALSIFY_WINDOW_02_REAL_REPRODUCTION_AFTER_00_ROUTING
