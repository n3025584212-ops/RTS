# River Town Visual Slice — attribution and transformations

This work is based on **Abrams M1A2 SEPv3** by **dannzjs**:
https://sketchfab.com/3d-models/abrams-m1a2-sepv3-eb6f5560198740269507e9948376414c
Author: https://sketchfab.com/dannzjs
License: Creative Commons Attribution 4.0 International — https://creativecommons.org/licenses/by/4.0/

Changes: texture resolution limited to 1536 pixels, embedded GLB packaging, runtime paint/roughness adaptation and mud/dust weathering. The original geometry and material texture sources are retained. No author endorsement is implied. Preserve this attribution when sharing the scene or its rendered screenshots.

Poly Haven models, textures and sky are CC0 1.0. Asset pages, source URLs, publisher MD5 values and downloaded-file SHA256 values are in `source_license_manifest.json`; original API responses and the publisher license page are retained alongside it. These cover fir saplings, island tree, shrubs, Bermuda and medium grass, mossy rocks, barrel, military crate, plaster, roof tiles and the sky. Grass uses the publisher's separate Alpha PNG maps, verified against the primary files API, because the source color JPEGs have no transparency. Terrain textures reused from the source repository retain the source provenance documented in its asset manifest.

The distant foliage textures are conventional impostors baked from the licensed 3D assets by `bake_foliage_cards.gd` in Godot 4.7.1. The final evidence PNG is captured from the complete live Godot viewport, including those runtime assets. No generated image or post-edited composite replaces runtime evidence.

The distant church is the repository's existing derivative of Daniel Andersson's CC0 Medieval Church, as documented in `docs/production/GOLDEN_SCENE_V1_ASSET_MANIFEST.md`. Native architecture, terrain, shaders, composition and asset preparation scripts are authored for this project. The sky shader limits the solar disk's radiance in background and reflection passes; the downloaded HDR file remains unchanged. The DirectionalLight3D supplies direct sunlight. The 1920×1080 viewport uses Godot's internal 1.5× 3D sampling; no screenshot pixels are altered after capture.
