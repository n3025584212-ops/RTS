# FRONTLINE Asset Capability Map V1

Status: WORKING PRODUCTION MAP — NOT A VISUAL ACCEPTANCE CLAIM
Branch: dev/asset-pipeline-v2-multi-source
Engine: Godot 4.7.1

## Purpose

This document separates accepted production assets from historical experiments, mid/far assets, pending candidates, and rejected high-visibility assets. It prevents later work from silently replacing an accepted asset with a weaker one just because that asset is easier to script or import.

## Grades

- **A — Accepted Near/Mid:** proven in the current high-fidelity local visual language; protect from silent replacement.
- **B — Usable Mid:** usable in normal RTS camera distances, but not a Hero/Near anchor without a dedicated upgrade.
- **C — Far/HLOD:** useful for massing, distant settlements, background vegetation, or proxy LOD only.
- **P — Pending proof:** potentially useful, but requires a real Godot 4.7.1 viewport comparison before promotion.
- **X — Rejected for high visibility:** may remain as evidence/prototype, but must not be promoted into production Near/Mid use without a new proof.

## Current capability map

| Domain | Asset / family | Grade | Current interpretation |
|---|---|---:|---|
| Main battle tank | `assets/visual_slice/abrams.glb` | **A / FROZEN** | Run #5 armored visual baseline. Do not silently replace with Hero V2 Abrams or another easier asset. |
| IFV | `assets/golden_scene/vehicles/ifv.glb` | **B/P** | Legal usable source; keep, but do not inject into unrelated visual proofs. Needs its own material/LOD proof against Run #5. |
| Hero ruin | `assets/visual_slice/hero_v2/urban_ruin/urban_ruin.gltf` | **A** | Strong Poly Haven-backed architecture direction; valid source for close/mid ruined urban language. |
| Hero ruined house | `assets/visual_slice/hero_house_ruined_hf.glb` and production scene | **A** | Existing high-fidelity anchor; preserve. |
| Family House Collection | `assets/golden_scene/city_v20/family_house_00..05.glb` | **P / P0** | Six different CC0 houses already in the repository. Highest-priority residential-family proof before any new house generation/download. |
| Procedural rural-house prototype | Asset Pipeline V1 generated house | **X** | Technical pipeline proof only. Repeated grammar, weak silhouette, bad roof proportions; not a production residential family. |
| Church landmark | `assets/golden_scene/city_real/church_landmark.glb` | **P** | Source may be useful, but generic Blender V2 round-trip lost material appearance. Do not judge the source from the broken round-trip. |
| Ordinary House | `assets/golden_scene/city_hd/ordinary_house.glb` / `city_real/ordinary_house_textured.glb` | **P** | Historical material/white-model risk. Needs direct source proof, not generic re-export proof. |
| Buildings Pack 3 / signage-heavy shop/warehouse family | `city_hq3` and related historical assets | **X Near / C-B salvage** | Previously rejected for high-visibility use because signage/material language did not fit the approved scene. Geometry may be salvageable for background or re-authoring. |
| Buildings Pack 4 / photo-textured facades | `city_hq` and related assets | **P/B** | Candidate Mid/Near source. Requires current direct viewport proof before promotion. |
| Kenney City Kit | `assets/golden_scene/city/` | **C** | Useful settlement massing / Far/HLOD; not a Near quality target. |
| Kenney Building Kit | `assets/golden_scene/buildings/` | **C/B modular** | Useful modular background/support pieces; not a Hero architecture source by itself. |
| Pine Sapling Small optimized | `assets/golden_scene/nature_real/pine_sapling_small_lod.glb` | **A/B** | High-quality real vegetation path after oversized 17M-triangle tree was rejected. |
| Mid Poly Meadows | `assets/golden_scene/nature_hq/` | **B** | Mid-distance vegetation source. |
| Kenney Nature | `assets/golden_scene/nature/` | **C** | Far/HLOD fill only. |
| Poly Haven / current surface library | `assets/visual_slice/surfaces/`, `assets/golden_scene/pbr/` | **A** | Mud, asphalt, dirt, gravel, brick, concrete and related PBR families are a current strength, not the primary blocker. |
| Road / mud / rut / ground system | Run #5 production visual slice | **A local** | Proven local material/geometry language. World-scale road-network logic remains a separate future task. |
| Infantry | `assets/golden_scene/infantry/soldier.glb` | **B/P** | Suitable candidate for RTS distance; not yet a close-up quality anchor. |

## Production gaps, ordered by impact

### P0 — Residential asset family proof

Before creating or downloading another house, directly render all six existing CC0 V20 Family House models inside the exact Run #5 visual baseline. Grade each house individually A/B/C/X.

Required proof conditions:
- original `assets/visual_slice/abrams.glb` remains the only armored baseline vehicle;
- no IFV or alternate tank is injected;
- no procedural rural-house prototype is present;
- all six source houses are visible in one irregular village cluster;
- original source materials are preserved first; no fallback white-masking is allowed;
- screenshot is an actual Godot 4.7.1 Forward+ viewport, 1920x1080, no post-capture editing.

### P1 — Residential completion

If V20 yields enough B/A models, derive missing roles rather than restarting from zero:
- 1–2 damaged/burnt derivatives;
- 1–2 rural/farm outbuildings;
- LOD1/LOD2 and HLOD;
- material normalization only where visually necessary.

If V20 fails, then search legal external sources specifically for the missing residential roles.

### P2 — Industrial / utility family

Current high-visibility industrial coverage is weak or historically style-incompatible. Build a legal source-backed family for warehouse, repair hall, utility shed, light industrial facade, and rail/yard support structures.

### P3 — Bridge / road infrastructure family

The terrain/road surface language is strong, but reusable bridge, culvert, guardrail, sign, retaining wall, drainage and roadside infrastructure families are incomplete.

### P4 — Vehicle family completion

Do not replace the accepted Abrams. Add missing support/logistics vehicle roles and create controlled LOD/damaged/burnt derivatives for existing legal vehicle sources.

## Hard operating rules

1. **Accepted quality accumulates.** A new proof may add assets, but must not silently replace an accepted A-grade anchor.
2. **CI green is not visual acceptance.** Technical import/render PASS only proves the pipeline ran.
3. **One generic script is not the goal.** Use source-specific handling when that preserves visual quality better.
4. **Do not use a procedural example as an asset family.** Procedural generation is one source type, not the production architecture strategy.
5. **Reuse before acquisition.** Existing licensed assets are inspected first; only real capability gaps trigger external asset search.
6. **Near/Mid/Far are different jobs.** Kenney/low-poly assets can remain useful in Far/HLOD without being promoted to Near.
7. **No three-lane world logic is inferred from asset proofs.** Asset validation and battlefield spatial architecture remain separate layers.
