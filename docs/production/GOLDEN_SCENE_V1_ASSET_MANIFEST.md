# FRONTLINE Golden Scene V1 — Asset / License Manifest

TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
DESIGN_AUTHORITY=FRONTLINE_GOLDEN_FRAME_V1
TARGET_RESOLUTION=1920x1080
ENGINE=Godot 4.7.1
STATUS=ACTIVE_G0_VISUAL_SPIKE

This manifest is part of the implementation evidence for Issue #33. Assets marked **VENDORED** may be committed because their license permits redistribution. The acquisition script records the exact downloaded source and preserves upstream license metadata in this document.

| Family | Source | URL | License | Commercial use | Source redistribution | Original format | Godot import | Modification / use |
|---|---|---|---|---|---|---|---|---|
| HQ urban source V10 | DREAM_SEARCH_REPEAT `Buildings pack 3` | https://opengameart.org/content/buildings-pack-3 | CC0 1.0 | YES | YES | Blender 3.3.1 .blend, photo-derived urban textures + modified normals | Blender headless split to up to 8 centered GLBs | V10 assets remain licensed/vendored, but V11 removes them from the active high-visibility core after runtime review showed signage/material language inconsistent with the approved frame |\n| HQ urban source V5/V6 | DREAM_SEARCH_REPEAT `Buildings pack 4` | https://opengameart.org/content/buildings-pack-4 | CC0 1.0 | YES | YES | Blender 3.3.1 .blend, photo-derived textures + normals | Blender headless export to GLB | V6 splits the source .blend into independent centered GLBs; each structure keeps its authored photo-derived material and is placed at street scale |\n| HQ vegetation V5 | EmacEArt `Free Mid Poly Meadows` | https://opengameart.org/content/free-remastered-free-mid-poly-meadows | CC0 1.0 | YES | YES | glTF package | Native Godot glTF import | V7 filters to complete EA01_Env_Tree_* models only (excluding detached crowns/roots/fragments) and preserves their authored materials |\n| High-detail town geometry V4 | drummyfish `Ordinary House` + GGBotNet `Soviet Panel Apartment House 3D` | https://opengameart.org/content/ordinary-house ; https://opengameart.org/content/soviet-panel-apartment-house-3d | CC0 1.0 | YES | YES | OBJ + ZIP model archive | Blender headless export to GLB | V11 tested explicit PBR overrides; V12 supersedes the active use by re-exporting the original Ordinary House ZIP with its authored textures |\n| Town / urban buildings | Kenney City Kit (Commercial), OpenGameArt mirror | https://opengameart.org/content/city-kit-commercial | CC0 1.0 | YES | YES | ZIP containing glTF/FBX/OBJ | glTF/GLB imported by Godot | Selected complete building meshes instanced into river-town; deterministic scale/rotation/layout |
| Modular building detail | Kenney Building Kit, OpenGameArt mirror | https://opengameart.org/content/building-kit | CC0 1.0 | YES | YES | ZIP containing glTF/FBX/OBJ | glTF/GLB imported by Godot | Building/roof/window/detail meshes available for settlement enrichment |
| Trees / rocks / hedges | Kenney Nature Kit | https://kenney.nl/assets/nature-kit | CC0 1.0 | YES | YES | ZIP containing 3D model formats | glTF/GLB imported by Godot | Tree and vegetation instances used for treelines, forest blocks, hedges, river banks |
| Main battle tank (active V2) | Sketlux “Abrams tank”, OpenGameArt | https://opengameart.org/content/abrams-tank | CC0 1.0 | YES | YES | Blender .blend | Blender headless export to `mbt_abrams.glb`; Godot GLB import | Active Golden Scene MBT silhouette; project-applied olive three-tone PBR/camouflage response |\n| Main battle tank (legacy fallback) | Heathal “Tank”, OpenGameArt | https://opengameart.org/content/tank-3 | CC0 1.0 | YES | YES | Blender .blend | Blender headless export to GLB; Godot GLB import | Retained as historical fallback; no longer active Golden Scene MBT |
| IFV / APC visual family | Mophs “Recon Tank - Update”, based on MNDV.ecb | https://opengameart.org/content/recon-tank-update | CC BY 4.0 | YES | YES with attribution/license notice | ZIP, rigged/textured model | Source FBX/Blend converted to GLB; Godot GLB import | Scaled as tracked reconnaissance/IFV visual family; original creator chain retained |
| Physical infantry | erik90mx “Low Poly Modern Soldier (rigged)”, OpenGameArt | https://opengameart.org/content/low-poly-modern-soldier-rigged | CC0 1.0 | YES | YES | ZIP / Blender model | Blender headless export to GLB; Godot GLB import | Physical soldier meshes deployed in squads; no icon-only substitution |
| Terrain / water / bridge / roads / fields | FRONTLINE geometry + Poly Haven CC0 PBR surfaces (`leafy_grass`, `grass_path_3`, `dirt_aerial_03`, `aerial_mud_1`, `asphalt_02`, `gravel_ground_01`) | https://polyhaven.com/ | CC0 1.0 | YES | YES | 1K PNG diffuse/normal/ARM + native geometry | Godot Texture2D / ShaderMaterial / StandardMaterial3D | Multi-surface terrain blend, mud banks, asphalt roads, gravel shoulders, field/river integration |\n| Building surface upgrade | Poly Haven `brick_wall_005` + `t_concrete_wall_002` | https://polyhaven.com/a/brick_wall_005 ; https://polyhaven.com/a/t_concrete_wall_002 | CC0 1.0 | YES | YES | 1K PNG diffuse/normal/ARM | Godot StandardMaterial3D | Weathered brick/concrete surface families applied across real building meshes and bridge concrete |\n| Environment HDRI (active V3) | Poly Haven `Hochsal Field` | https://polyhaven.com/a/hochsal_field | CC0 1.0 | YES | YES | 1K HDR | Godot PanoramaSkyMaterial | Clear green-field outdoor sky/reflection source for stronger daylight and horizon readability |\n| Environment HDRI (V2 fallback) | Poly Haven `Kloppenheim 05` | https://polyhaven.com/a/kloppenheim_05 | CC0 1.0 | YES | YES | 1K HDR | Godot PanoramaSkyMaterial | Retained fallback |
| Combat VFX / HUD | FRONTLINE project-authored scene presentation | repository source | Project source | YES | YES under repository terms | Native Godot nodes/materials/UI | Native Godot | Smoke/fire/explosion/tracer/impact/wreck presentation and edge-weighted tactical HUD |

## Redistribution policy

- CC0 families may be vendored directly in this repository for a reproducible visual spike.
- The CC BY 4.0 Recon Tank derivative/source may be redistributed when attribution and license terms are preserved. This manifest provides the attribution chain and source URL.
- No paid, marketplace-restricted, or no-redistribution source asset is accepted into this branch.
- The bootstrap script does **not** silently substitute primitive delivery assets when an external download fails; it exits non-zero.

## Required attribution retained for CC BY 4.0 family

**Recon Tank - Update**
- Updated/textured/rigged work: Mophs.
- Based on original “Recon Tank” by MNDV.ecb.
- Source page: https://opengameart.org/content/recon-tank-update
- License: Creative Commons Attribution 4.0 International — https://creativecommons.org/licenses/by/4.0/

## Approved-frame identity

Golden Frame authority is the user-approved FRONTLINE Golden Frame V1 recorded in `docs/current/CURRENT_STATE.md` and `docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`.

Recorded approved-frame SHA256:
`6c9305b89a5bb1839721f12c2ae8c2507fae4fc7d4fdbbdf130f6f1ecc113362`

The Golden Scene implementation must be judged visually against the approved river-town bridge battle composition; this manifest is not a substitute for the runtime screenshot.


## Runtime visual iteration V8
- Removed the 36-instance legacy near-camera hedge wall after visual review.
- HQ vegetation is restricted to complete EA01 tree variants 01c/02a/03a/04a/05d/06d; detached crowns, roots, old-tree fragments and palm-like outliers are excluded from the active frame.
- Friendly armored formation is moved into the visible midground; smoke alpha/color and tracer thickness are tuned from actual 1920x1080 review rather than content-count gates.


## Runtime visual iteration V9
- Mid Poly Meadows geometry remains active, but its upstream material graph is overridden in Compatibility rendering because the actual V8 capture rendered the vegetation white.
- Active foliage count is reduced and pushed to peripheral/distant roles so armored combat, river, bridge and town remain the primary hierarchy.
- Smoke opacity was reduced after actual-frame review showed alpha stacking still reading as black blur.


## Runtime visual iteration V10
- Extended sculpted terrain to a larger battlefield envelope and added a distant ridge/eastern hill behind the river-town.
- Added distance tint for atmospheric perspective without re-enabling the Compatibility-render Sky/Fog chain that previously produced a black horizon.
- Buildings Pack 3 is CC0 and is split into a bounded set of independent full-building GLBs; six are placed in the high-visibility town core.
- Legacy blocky town instances are reduced from 25 to 16; bridge, river, Abrams/IFV/infantry, combat VFX and HUD hierarchy are preserved.


## Runtime visual iteration V11
- Runtime review of #61 rejected the Pack 3 shop/signage language as a visible asset-patchwork cue; those assets remain licensed/vendored but are removed from active high-visibility placement.
- ordinary_house.glb and apartment_block.glb now provide ten real residential structures plus the vertical landmark, all with explicit Poly Haven-backed brick/concrete PBR overrides.
- Legacy Kenney town massing is reduced from 16 to 8 instances; photo shopfront accents are reduced from five to three.
- Camera is lowered and tightened to put BLUE armor in the foreground, the bridge near center, and the defended town in the right-hand visual field.
- Ambient fill is reduced and sun contrast increased; distant terrain tint is stronger while the safe Compatibility BG_COLOR environment remains in use.


## Runtime visual iteration V12
- Re-downloads the CC0 Ordinary House source ZIP and exports it through Blender with its source MTL/texture context, instead of painting the whole mesh with one project material.
- Adds Daniel Andersson's CC0 Medieval Church as the town's single vertical landmark.
- Removes the oversized V11 apartment blocks from active placement; active town massing is low-rise textured housing, six small legacy background buildings, two photo-shop accents, and one church landmark.
- Distant treeline is extended behind the town to reduce the bare-hill/tabletop read.
