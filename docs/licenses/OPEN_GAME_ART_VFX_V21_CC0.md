# FRONTLINE Golden Scene V21 external VFX assets

## Smoke Vapor Particles
- SOURCE: OpenGameArt — Smoke Vapor Particles
- URL: https://opengameart.org/content/smoke-vapor-particles
- AUTHOR: Fupi
- LICENSE: CC0
- COMMERCIAL_USE: YES
- REDISTRIBUTION: YES
- ORIGINAL_FORMAT: PNG
- GODOT_FORMAT: PNG / Texture2D
- MODIFICATION: runtime tint, billboard scaling, layered placement; source pixels otherwise unchanged
- FILES: smoke1.png, smoke2.png, smoke3.png, smoke4.png

## Explosion particles sprite atlas
- SOURCE: OpenGameArt — Explosion particles sprite atlas
- URL: https://opengameart.org/content/explosion-particles-sprite-atlas
- AUTHOR: TheJosh; derived from Kenney smoke-particle work as stated by the source page
- LICENSE: CC0
- COMMERCIAL_USE: YES
- REDISTRIBUTION: YES
- ORIGINAL_FORMAT: PNG atlas
- GODOT_FORMAT: PNG / AtlasTexture
- MODIFICATION: atlas-cell selection, emissive material, layered billboard placement
- FILE: explosion_atlas_512x512.png

## High-fidelity Abrams V21
- SOURCE: deterministic project hard-surface production asset built by `scripts/production/quality/material/build_quality_abrams_v4.py`
- INPUT_REFERENCE: existing legally vendored FRONTLINE Abrams source and the project quality-material proof lane
- OUTPUT: `assets/golden_scene/quality_material_v3/mbt_abrams_static.glb`
- LICENSE/REDISTRIBUTION: governed by the existing Abrams provenance record already carried by the Golden Scene asset manifest; no new third-party source is introduced by this V21 build step
- MODIFICATION: actual Blender mesh construction adds faceted armor, segmented tracks, road wheels, optics, smoke launchers, CROWS, stowage, antennas, fasteners, tow cables and mud geometry
