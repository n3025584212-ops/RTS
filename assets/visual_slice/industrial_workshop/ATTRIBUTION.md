# River Town Repair Workshop

## Sources

- **Modular Factory Facade**, **James Ray Cock**, Poly Haven.
  Source: https://polyhaven.com/a/modular_factory_facade
  License: **CC0 1.0**, https://polyhaven.com/license
  Original 4K glTF kit: brick wall openings, inserts, garage doors, personnel door,
  windows, dado and cornice modules. Original UVs retained for these components.
  Exact download URLs, upstream MD5, SHA256 and byte sizes:
  `tools/industrial/manifests/factory.json` (repository root relative).
- **Corrugated Iron 03**, **Charlotte Baglioni**, Poly Haven.
  Source: https://polyhaven.com/a/corrugated_iron_03
  License: **CC0 1.0**, https://polyhaven.com/license
  Original 4K diffuse, OpenGL normal, ARM and displacement maps.
  Exact URLs and hashes: `tools/industrial/manifests/roof.json`.

## Project construction

Authored for FRONTLINE in this task: 12 x 12 m repair hall layout, cropped upper
masonry, gables, solid wall returns, piers, foundation and approach ramps; trusses,
purlins, corrugated overlapping roof sheets, folded ridge and barge flashing;
open gutters, downpipe offsets, ventilator rain hoods, personnel canopy, service
conduit, workbench, shelving and geometric lettering. These additions are released
under CC0 1.0 by this asset delivery, without changing any existing repository license.

The factory glass source normal binding is replaced with its actual OpenGL normal
map. Glass keeps the opaque dirty-window appearance carried by the source JPEG
atlas; no invented transparency or missing interior is hidden with a black plane.
Roof displacement is sampled from its matching height map; 2 m UV repeat is used.
Source brick/trim UVs are retained; custom solids use planar UVs.

The portable runtime asset consists of **all three GLBs plus `textures/`**. These
GLBs embed geometry and reference the same adjacent texture library, so copying
only one GLB is insufficient. All texture dimensions remain 4096 x 4096. JPEG
encoding uses quality 92 and 4:4:4 chroma; normal/ARM data undergo no color transform.
Processed texture hashes and dimensions are in `texture_processing.json`.

`source/repair_workshop_source.blend` packs the source geometry and images.
Its `.gdignore` prevents Godot from auto-converting authoring sources.
All reproducible construction code is in `tools/industrial/`.

Abrams, Urban Ruin and Hero House are not included in this asset's license grant
and retain their existing attribution and original files.
