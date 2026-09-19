# FRONTLINE Sole Visual Baseline — 2026-09-20

STATUS=ACTIVE — THE single visual baseline of FRONTLINE
DECISION_ID=FRONTLINE_SOLE_VISUAL_BASELINE_V1
DECIDED=2026-09-20, user directive: 本资产作为唯一基线；其他资产基线同类保留归入本基线，非同类打入回收站。

## The sole baseline

**Product scene**: `res://scenes/production/RiverTownVisualSlice.tscn` → `scripts/production/river_town_visual_slice.gd`
**Asset graph**: `res://assets/visual_slice/` (self-contained since 2026-09-20; the church landmark now lives at `res://assets/visual_slice/landmarks/church_landmark.glb`)
**Branch**: `product/frontline-high-fidelity-slice-v1`
**Rendered at**: commit `7032c91` baseline + church migration commit (this commit)
**Protocol**: Godot 4.7.1-stable official, Forward+ (Vulkan), 1920×1080, `--capture --capture-frame=16`, no post-capture image editing

## Official baseline evidence (this directory)

| File | View |
|---|---|
| `river_town_sole_20260920/reference_view.png` | Reference framing (camera 9.0,6.4,20.5) |
| `river_town_sole_20260920/hero_view.png` | Hero shot — armored unit at ruined hero house |
| `river_town_sole_20260920/ground_view.png` | Low ground framing — mud road, puddle shader |
| `river_town_sole_20260920/runtime_metrics_reference.json` | Engine/renderer/frame metrics for the reference capture |

Capture environment: Intel(R) UHD Graphics, Vulkan 1.4.323, Forward+, average 134.3 ms/frame, 2129 draw calls.

## Same-kind assets retained under this baseline (not separate baselines)

- `scenes/production/RiverTownHeroHouseHF.tscn` + `local_fidelity_house.gd`
- `scenes/production/RiverTownHeroHouseStructureStudy.tscn` + `local_fidelity_house_structure_study.gd`
- `scenes/production/RiverTownHeroShotV2.tscn` + `river_town_hero_shot_v2.gd`
- `scenes/production/RiverTownStructureStudy.tscn` + `river_town_structure_study.gd`
- Family tooling: `local_fidelity_cover_field.gd`, `local_fidelity_road.gd`, `local_fidelity_road_surface.gd`, `verify_local_fidelity_instances.gd`, `verify_river_town_structure_study.gd`, `bake_foliage_cards.gd`
- Historical same-kind captures in `artifacts/visual_reset/` are working evidence of this same baseline lineage, not competing baselines.

## Recycled as non-kind (see docs/ops/VISUAL_BASELINE_RECYCLE_2026-09-20.md)

FullBattlefield production line (V1/V2/V2LOD/TownCandidate/V8–V12 + TownProbeA–D), GoldenSceneV1 spike, Quality material/test scenes, the golden_scene asset library, their scripts and CI workflows. Recoverable via tag `recycle/2026-09-20/pre-visual-baseline-rationalization`.

## Supersession note

This baseline supersedes Golden Frame V1 (docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md) as the visual authority. Any new visual work must compare against `river_town_sole_20260920/` captures under the protocol above.
