# FRONTLINE Golden Scene V1 — Visual Compliance Record

TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1  
ISSUE=#33  
DESIGN_AUTHORITY=APPROVED_GOLDEN_FRAME_V1  
RESULT=PARTIAL_PASS  
PRODUCT_PASS=NO  
MERGE=NO

## 1. Evidence identity

- Scene: `res://scenes/production/GoldenSceneV1.tscn`
- Engine: Godot 4.7.1 stable official
- Actual runtime capture: `artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png`
- Actual screenshot Git blob SHA: `a4342339555935e9db9d1ec0ed408cff464f0d1c`
- Capture resolution: 1920×1080
- Golden visual workflow: `FRONTLINE Golden Scene V1 Visual Spike`
- Accepted visual run: #23 / run id `33941250681`
- Run source head: `b2cdc874e6fe1d0dd0626aabc1dfdcbbf3c38ca5`
- Evidence-vendoring branch head after run: `a37e3e6931782d2a2f518f5d9951f1388251fd5a`
- Approved Golden Frame recorded SHA256: `6c9305b89a5bb1839721f12c2ae8c2507fae4fc7d4fdbbdf130f6f1ecc113362`
- Asset/license manifest: `docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md`

### Reference-image limitation

The approved Golden Frame binary itself is not currently vendored in this repository. Its authority is recorded by the approved specification and SHA256 above. No replacement or regenerated image has been fabricated.

This compliance record therefore compares the actual runtime frame against the canonical requirements in `docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`. A literal binary side-by-side comparison remains an evidence improvement to add when the exact approved reference binary is placed in the repository.

## 2. Runtime evidence

| Metric | Actual |
|---|---:|
| Town real-asset instances | 31 |
| Forest / treeline instances | 112 |
| Bridge members | 31 |
| Road segments | 16 |
| Physical vehicles / wrecks | 17 / 3 |
| Physical infantry | 28 |
| Smoke columns | 4 |
| Explosions | 3 |
| Short tracer / shell streak segments | 20 |
| HUD regions | 6 |
| Average frame time | 133.66 ms |
| P95 frame time | 144.628 ms |
| Approx. FPS | 7.5 |

Performance was measured in GitHub Actions using Mesa llvmpipe software OpenGL Compatibility rendering. It is valid evidence that the scene rendered and captured, but it is **not representative GPU performance** and must not be treated as a production hardware FPS result.

## 3. Golden Frame vs actual — element compliance

| Golden Frame requirement | Status | Actual-frame assessment |
|---|---|---|
| Oblique high tactical 16:9 camera | PASS | BLUE foreground, bridge/river center and RED/town depth read in one 1920×1080 frame. |
| Terrain visually dominant | PARTIAL | Sculpted valley is visible and grounded, but the current single PBR terrain treatment lacks the approved reference's surface richness and local terrain detail. |
| Meaningful 3D relief | PASS | Ridge/rolling valley geometry is actual 3D and affects the frame silhouette. |
| Broad river with banks and water shading | PASS | Real shaded water, channel and banks are visible; bank detail remains simplified. |
| Real bridge geometry | PASS | 31-member deck/pier/truss bridge is visible and spatially coherent; modeling fidelity remains below production target. |
| Dense river-town | PARTIAL | 31 real building instances form a readable town beyond the bridge, but the current CC0 low-poly family still reads more like a stylized city kit than the approved realistic river-town target. |
| Varied buildings + tall landmark | PARTIAL | Multiple building shapes/material colors and one tall landmark exist, but architectural variation and realism remain insufficient for PASS. |
| Roads / intersections | PASS | Multiple paved/dirt approaches and crossing routes are visible. |
| Agricultural fields | PARTIAL | Field blocks and crop-row language exist, but texture/material detail remains simplified. |
| Hedgerows / treelines / forest blocks | PASS | 112 real vegetation instances define ridge/field edges and distant blocks. |
| Populated distant terrain | PARTIAL | Expanded valley removes the empty map edge and maintains terrain/vegetation depth, but far-field density is still below reference quality. |
| Real 3D MBT / IFV silhouettes | PARTIAL | Actual external vehicle meshes are clearly visible, especially BLUE foreground armor; model fidelity is still low-poly compared with approved target. |
| Physical infantry | PARTIAL | 28 physical soldier models are present, but at the approved command height they remain small and lack high-fidelity squad motion/presentation. |
| Coherent world scale | PASS | Vehicles, roads, bridge and buildings are now spatially coherent enough to read as one battlefield. |
| Friendly / hostile tactical overlays | PASS | Reduced formation-level overlays aid identification without replacing physical units. |
| Muzzle flash | PASS | Visible combat muzzle flashes are present. |
| Tracers / projectile flight | PASS | Full wire-like trajectories were removed; short bright projectile streaks now read as combat fire. |
| Artillery / shell trajectory | PASS | Short high-arc shell streaks are present without covering the scene. |
| Impact dust / debris cue | PASS | Distributed impact-dust cues exist. |
| Smoke columns | PARTIAL | Four smoke columns create battle history, but the current procedural puff construction still lacks production-quality volumetric detail. |
| Fire / explosion | PARTIAL | Fires and explosion cores are visible and distributed, but remain stylized/procedural rather than production VFX quality. |
| Damaged / wreck state | PASS | Three physical darkened vehicle wrecks and associated fire/smoke establish battle history. |
| Lighting / atmosphere | PARTIAL | Directional warm sun, cool fill and restrained fog now reveal the battlefield; atmospheric depth/shadow/material response remain below Golden Frame. |
| Tactical map | PASS | Lower-left map is present and readable. |
| Formation cards | PASS | Lower-center formation strip is present without covering central battle. |
| Selected formation + commands | PASS | Lower-right selected unit/status/command panel is present. |
| Mission/status/alerts | PASS | Top-left mission, top-center battle state and top-right alerts are present. |
| HUD edge-weighted / central battle readable | PASS | HUD has been compressed and the battle remains visible through the center. |
| No cube/box substitutes for buildings/vehicles | PASS | Buildings and combat units are external physical 3D assets, not delivery cubes/boxes. |
| No icon-only unit delivery | PASS | Tactical markers supplement, rather than replace, physical vehicles/infantry. |
| Overall first impression: modern-war RTS, not technical graybox | PARTIAL_PASS | The frame now reads as a real tactical RTS scene, but still visibly below the approved Golden Frame's realistic production fidelity. |

## 4. Major visual gaps remaining

1. **Asset fidelity** — MBT/IFV, infantry, vegetation and buildings remain visibly low-poly compared with the approved realistic target.
2. **River-town realism** — current town density works compositionally, but architecture/material detail does not yet read as a convincing modern river settlement.
3. **Terrain surface richness** — terrain needs multi-material ground treatment, local road shoulders, dirt/grass transitions, decals and smaller-scale surface variation.
4. **Bridge / river-bank finishing** — geometry is real and readable, but bridge surfacing, rail detail, abutments, banks and shoreline transitions remain simplified.
5. **Lighting / shadows / atmosphere** — current Compatibility/llvmpipe proof has limited shadow and atmospheric richness; approved frame expects stronger depth and material separation.
6. **Combat VFX fidelity** — smoke/fire/explosion effects communicate battle state, but remain procedural and visibly below production volumetric/particle quality.
7. **Battle damage** — wrecks exist, but building damage, scorch/decal language and richer vehicle damage states remain insufficient.
8. **Infantry presentation** — physical soldiers exist, but near/medium-zoom readability, posing/animation and suppression presentation need further production work.
9. **Literal reference comparison** — exact approved Golden Frame binary is not stored in the repo, so literal pixel/side-by-side evidence has not yet been produced.

## 5. Decision

`RESULT=PARTIAL_PASS`

Reason: the actual Godot 4.7.1 1920×1080 frame now satisfies the minimum structural intent of a recognizable modern-war tactical RTS scene using real assets, real physical units, world geometry, battle VFX and HUD in one frame. It does **not** yet reproduce the approved Golden Frame's realistic production fidelity closely enough for PASS.

`PRODUCT_PASS=NO`  
`ENGINE_LOCK=NO`  
`MERGE=NO`

## 6. Next correction direction

Continue from this scene rather than rebuilding the engine or returning to graybox:

1. upgrade the highest-visibility MBT/IFV + building/vegetation families to higher-fidelity legally usable assets;
2. add terrain blend/detail materials, road shoulders and shoreline transitions;
3. replace procedural smoke/explosion primitives with production particle/volumetric VFX;
4. improve real-time lighting/shadow quality on a representative GPU renderer;
5. add visible building/ground damage and richer wreck states;
6. place the exact approved Golden Frame binary under controlled evidence storage and generate the literal side-by-side comparison.

