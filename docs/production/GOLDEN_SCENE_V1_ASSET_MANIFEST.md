# FRONTLINE Golden Scene V1 — Asset / License Manifest

TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1
DESIGN_AUTHORITY=FRONTLINE_GOLDEN_FRAME_V1
TARGET_RESOLUTION=1920x1080
ENGINE=Godot 4.7.1
STATUS=ACTIVE_G0_VISUAL_SPIKE

This manifest is part of the implementation evidence for Issue #33. Assets marked **VENDORED** may be committed because their license permits redistribution. The acquisition script records the exact downloaded source and preserves upstream license metadata in this document.

| Family | Source | URL | License | Commercial use | Source redistribution | Original format | Godot import | Modification / use |
|---|---|---|---|---|---|---|---|---|
| High-detail town geometry V4 | drummyfish `Ordinary House` + Mixazzz `Residential building (apartment block)` | https://opengameart.org/content/ordinary-house ; https://opengameart.org/content/residential-building-lowpoly-apartment-block | CC0 1.0 | YES | YES | OBJ + ZIP model archive | Blender headless export to GLB | V4 inserts these real-world residential silhouettes into one third of the river-town and uses the apartment family for the landmark |\n| Town / urban buildings | Kenney City Kit (Commercial), OpenGameArt mirror | https://opengameart.org/content/city-kit-commercial | CC0 1.0 | YES | YES | ZIP containing glTF/FBX/OBJ | glTF/GLB imported by Godot | Selected complete building meshes instanced into river-town; deterministic scale/rotation/layout |
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
