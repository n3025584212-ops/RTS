# River Town Hero Shot V2 — work in progress

## Acceptance status

**NOT ACCEPTED.** The new local scene is a method-reset experiment, not a completed fidelity milestone. The first modular-building capture (`hero_v2_05`) has more legible architectural components than the rejected scan, but does not establish the requested overall quality leap over Run #5 / Batch 03. Its side-wall assembly offset was then corrected. Do not use asset counts, resolution, or successful engine execution as a visual acceptance result.

Comparison baseline remains commit `383966bc60b5f54b720a786bf60337c06d675668`; visual floor remains `d42e6fc2bbe1bad928a16a19caace47dc6e57701`. The original `RiverTownVisualSlice.tscn`, its main script, and its terrain/armor shaders are unchanged by this experiment.

## Product and reproduction

- Scene: `res://scenes/production/RiverTownHeroShotV2.tscn`.
- Run: `powershell -File scripts/production/run_hero_shot_v2.ps1 -Godot <Godot-4.7.1-console.exe> -Label hero_v2_review`.
- The runner imports, starts real Forward+ rendering, and saves a 1920×1080 viewport plus runtime metrics under `artifacts/visual_reset/<label>/`. It does not change the baseline screenshot aliases or edit captured pixels.
- The old script supplies the rendering/capture and environment machinery. The new subclass places its own primary building, tank, rubble, boundary and vegetation composition.
- Local assets are regular meshes with materials. They are not a target-image backdrop. There is no vehicle motion, turret aiming, track animation, destruction state transition or gameplay implementation in this visual experiment.

## New assets

`assets/visual_slice/hero_v2/urban_ruin/urban_ruin.gltf` assembles a 9×9 m, two-storey corner building from the Poly Haven Modular Urban Apartments Facade kit. Wall solids, original window/door modules, cornices, floor/ceiling boards, joists, a fractured corner and fallen beams form actual geometry. The kit retains its 4K color, normal and packed PBR maps. The separate glTF buffer and all adjacent textures are required at runtime.

`abrams_v2.glb` is derived from the existing Abrams asset, with small manufacturing bevels assigned to an exposed-steel surface. Runtime bindings distinguish the source material groups. This does not establish that the tank's final appearance meets the visual target.

Rubble uses a matched scanned surface set with displacement converted into actual mesh height. Separate brick, stone and timber fragments sit around the collapse apron; shoulder mud clods and a broken boundary have actual silhouettes.

## Rebuilding the architecture

Use Python 3.9+ and Blender 4.5.9:

```text
python scripts/production/fetch_hero_v2_sources.py <source-cache>
blender --background --python scripts/production/build_hero_v2_urban.py -- <source-cache>/modular_urban_apartments_facade.gltf
blender --background --python scripts/production/build_hero_v2_abrams.py
```

The fetcher verifies the exact source sizes and hashes in `urban_source_manifest.json`. Source downloads are only needed to rebuild; exported game assets should be committed with the scene. Attribution is in `assets/visual_slice/hero_v2/ATTRIBUTION.md`.

## Remaining work

The tank still reads too uniformly; the architecture needs a convincing damaged roof/interior and weathering treatment; the ground/vegetation/background relationship does not yet have the coherent density or material separation of the direction image. Whole-game performance and animated asset usability have not been validated. Keep the visual acceptance open.

## Latest evidence and repository checkpoint

The user explicitly requested this work-in-progress checkpoint be committed to GitHub. This synchronization is not visual approval.

- Latest capture: `artifacts/visual_reset/hero_v2_06/river_town_actual_1920x1080.png` (1920×1080, Godot 4.7.1 stable, Forward+, actual viewport).
- Side-wall placement was corrected and verified in this capture.
- Runtime exited successfully; the shutdown log still reports 7 leaked Texture RIDs. No script or shader compilation error was reported.
- Performance is not ready for whole-game deployment: 24 monotonic wall-clock samples averaged 958.90 ms, P95 1019.99 ms on Intel UHD Graphics with internal render scale 1.5. The legacy `average_frame_ms_short_capture` field reports a smaller clamped delta value and must not be used as actual FPS evidence.
- Rejected scan/farmhouse experiments and earlier V2 captures are not part of this checkpoint. The committed scene uses the modular urban ruin.
