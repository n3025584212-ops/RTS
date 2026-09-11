# FRONTLINE Asset Pipeline V1

Status: ACTIVE_PROTOTYPE
Branch: `dev/asset-pipeline-v1`
Engine target: Godot 4.7.1
Authoring tool: Blender Python (`bpy`) -> GLB -> Godot

## Hard constraints

1. Existing high-quality assets are protected. This pipeline is additive only.
2. Do not delete, overwrite, down-res, or replace the current `assets/visual_slice/hero_v2`, Abrams, IFV, Hero House, Poly Haven PBR surfaces, or Golden Scene source assets.
3. No game-ripped or provenance-ambiguous assets.
4. Source license and attribution must be recorded before an asset can enter the production set.
5. Godot runtime code is not the primary modeling tool for hero architecture or vehicles. Runtime procedural geometry remains appropriate for terrain, road strips, rubble scatter, vegetation scatter, field rows, mud clods, and other repeated environmental structure.
6. Generated assets must be reproducible from source + script.

## Protected high-fidelity families

The following existing families are preservation anchors and remain available to all later work:

- `assets/visual_slice/abrams.glb`
- `assets/visual_slice/hero_house_ruined.glb`
- `assets/visual_slice/hero_house_ruined_hf.glb`
- `assets/visual_slice/hero_v2/`
  - `abrams_v2.glb`
  - `urban_ruin/urban_ruin.gltf`
  - Poly Haven stone/rubble/wood source textures
  - attribution and source manifests
- `assets/golden_scene/vehicles/ifv.glb`
- `assets/golden_scene/vehicles/` existing legal vehicle family
- `assets/golden_scene/buildings/` existing building library
- `assets/golden_scene/nature/` existing nature library
- Poly Haven-backed project PBR surfaces already used by the visual slice / Golden Scene.

These assets are inputs and references. Asset Pipeline V1 may create derived outputs next to them, but never modifies the originals in-place.

## Pipeline roles

### A. Source acquisition

Accept only sources with clear commercial-use and redistribution terms. Record:

- source URL
- author
- license
- original archive/model checksum
- whether the source is original or derivative

### B. Blender Python technical-art pass

Use `bpy` for operations that belong in an offline DCC pipeline:

- object cleanup and naming
- origin and scale normalization
- modular assembly
- wall thickness / solidify
- bevels and normal cleanup
- material-slot normalization
- UV sanity checks
- generated intact / damaged variants
- LOD generation
- deterministic GLB export

### C. Godot integration

Godot 4.7.1 handles:

- final scene composition
- terrain / water / road runtime systems
- PBR material binding where project-specific overrides are needed
- LOD/HLOD switching
- navigation, LOS, cover, gameplay and destruction state

## First prototype

The first prototype is intentionally narrow: prove that we can create a reusable **European rural masonry building family** without replacing any current hero asset.

Required outputs:

- intact LOD0
- damaged LOD0
- LOD1
- LOD2
- stable object/material naming
- deterministic GLB export
- manifest describing source modules and generated derivatives

The prototype may use project-authored procedural structural geometry plus legal CC0 texture/material sources. It is not allowed to masquerade primitive Godot geometry as a final high-quality building.

## Acceptance gate

The pipeline is only considered proven after:

1. Blender headless build succeeds.
2. GLBs import in Godot 4.7.1.
3. Existing protected assets are byte-for-byte untouched on the source branch.
4. A real Godot capture shows the generated asset beside existing high-quality assets without obvious scale/material-language mismatch.
5. Runtime and triangle counts are recorded.

No world-scale expansion begins before this gate is passed.
