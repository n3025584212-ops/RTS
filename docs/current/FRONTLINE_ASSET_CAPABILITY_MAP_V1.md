# FRONTLINE Asset Capability Map V1

Status: WORKING PRODUCTION MAP — NOT A GLOBAL VISUAL ACCEPTANCE CLAIM  
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
| Family House Collection | `assets/golden_scene/city_v20/family_house_00..05.glb` | **B family** | Normalized direct-source Run #5 proof completed. Useful Mid residential family; no member currently reaches A/Near. Details below. |
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

## V20 Family House direct-source result

Proof run: **GitHub Actions 34667643620**  
Artifact: `frontline-v20-family-house-proof`  
Runtime: Godot **4.7.1 Forward+**, 1920×1080, no post-capture edit.  
Protected baseline: original Run #5 Abrams retained; extra vehicle count = 0; old background houses disabled; Hero House HF retained as an in-frame quality ruler.

The first V20 proof exposed an old export-unit problem: the six houses arrived at only roughly 1.6–2.1 m total height. The family was therefore re-proved with one uniform **3.0× source-unit conversion**, preserving authored relative proportions. The corrected world-space heights are roughly **4.74–6.38 m**, with widths roughly **7.12–13.34 m**.

Review mapping in the normalized proof: front row left→right = 00/01/02; rear row left→right = 03/04/05.

| House | Grade | Production use |
|---|---:|---|
| `family_house_00.glb` | **B** | Good Mid rural/edge-of-village filler. Broad roof mass and side extension break repetition. Not a Near anchor. |
| `family_house_01.glb` | **B** | Stronger central roof/dormer silhouette; usable Mid. Facade/material depth still below Hero quality. |
| `family_house_02.glb` | **B** | Distinct low roof + dormer profile; usable Mid. Needs material/edge-depth pass before Near use. |
| `family_house_03.glb` | **B** | Small gabled cottage with chimney reads clearly at Mid distance; simple enough that close inspection exposes low detail. |
| `family_house_04.glb` | **B** | Best irregular/weathered small-house read in this family; useful Mid and a candidate for a damaged derivative. Still below A/Near. |
| `family_house_05.glb` | **C** | Plain box/facade and weak silhouette. Keep for Far/HLOD/background settlement density rather than normal Mid foreground. |

**Family verdict:** the repository already contains enough residential variety to stop generating replacement houses. The gap is now **Near residential quality and damage/LOD derivatives**, not basic house count.

## Production gaps, ordered by impact

### P0 — Residential asset family proof — COMPLETE

The six existing CC0 V20 Family House models were directly rendered in the Run #5 baseline and individually graded. Result: **5×B + 1×C, 0×A, 0×X** after correcting the common source-unit scale.

Consequences:
- do not generate another generic rural-house family;
- use V20 houses for Mid settlement composition;
- retain Hero House HF / Urban Ruin as Near-quality references;
- spend new work on missing roles and infrastructure rather than duplicating solved Mid housing.

### P1 — Residential completion

Use the existing family as source material rather than restarting from zero:
- derive one damaged/burnt version from `family_house_04` or another B-grade source;
- add one farm/outbuilding role if no existing asset passes direct proof;
- produce LOD1/LOD2/HLOD variants;
- normalize materials only where the Run #5 comparison proves it necessary.

### P2 — Bridge / road / river-edge infrastructure family — ACTIVE NEXT BLOCKER

Run #5 proves local road/mud/water material language, but the bridge is still authored in-scene from primitive blocks/rods and there is no verified reusable family for:
- bridge deck / abutment / pier / rail or parapet;
- culvert / drainage;
- guardrail / roadside barrier;
- retaining wall / embankment transition;
- river-bank / road-edge transition modules.

This is the next production blocker for a credible 500×500 m–1×1 km world slice. Roads must read as infrastructure embedded in terrain, not as gameplay lanes.

### P3 — Industrial / utility family

Current high-visibility industrial coverage is weak or historically style-incompatible. Build or prove a legal source-backed family for warehouse, repair hall, utility shed, light industrial facade, and rail/yard support structures.

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
