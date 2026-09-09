# River Town ground construction, batch 03

Status: implementation checkpoint, REJECTED_AS_QUALITY_UPGRADE by user review. The overall task remains ACTIVE. This commit records the work at the user's request; it is not an acceptance or completion milestone.
No maximum-quality or whole-game scalability claim is made.

## Concrete changes

The production scene uses a reusable road-surface resource: 10.5 cm maximum broad
rut depression, 2 cm tread impression and broken shoulders up to 3.5 cm. It retains
8 cm road mesh sampling and 16 cm surrounding terrain. Height-map sampling is now
bilinear, reducing abrupt steps caused by nearest-pixel lookup. Water basins still
have physical depressions and horizontal water surfaces.

A deterministic world-space cover field drives both bare-soil material blending
and placement of existing plant meshes. This is an actual instance-layout change,
not only a texture change. All six source meshes, their scale ranges and all 99,020
instances are retained. A separate random stream keeps unrelated trees, props and
background placement unchanged. Sparse plants remain between colonies.

Lighting, exposure, camera, hero building, armor materials and gameplay are unchanged
from the pre-batch checkpoint. The road-height change updates grounded object heights.

## Reuse and limits

- `assets/visual_slice/profiles/road_surface_v2.tres`: metre-based road parameters.
- `assets/visual_slice/profiles/groundcover_field.tres`: seed, patch scale and local coverage bounds.
- The same cover texture is sampled by the terrain and grass-placement code.
- The current integration covers this local slice. Streaming chunks, LOD and a
  whole-game performance budget have not been implemented or verified.
- Preserving the instance count does not by itself prove visual quality.

## Evidence and reproduction

Run the production scene with Godot 4.7.1 stable, Forward+:

```powershell
& D:/godot/Godot_v4.7.1-stable_win64_console.exe --path . --rendering-method forward_plus --audio-driver Dummy --resolution 1920x1080 res://scenes/production/RiverTownVisualSlice.tscn -- --capture --capture-frame=32 --capture-label=ground_v3_reference --view=reference
```

Final evidence is `artifacts/visual_reset/ground_v3_reference/`.
The first internal ground_v2 capture exposed overly bald colony gaps; it is not the
final result. The final integration retains sparse transition plants and uses the
existing dry-soil source on exposed areas. Run #5 remains the acceptance floor.

The earlier house-structure study remains isolated and rejected. A local inspection
of the previously cached scan house also found attached terrain and scan artifacts;
that asset has not been added to the production scene or this commit.

## Final review and runtime limits

The user reported no meaningful overall improvement versus the starting image.
The road and groundcover changes are recorded as a rejected quality-upgrade attempt.
They remain in the production implementation at the user's request to commit this
local work; Run #5 remains the visual floor and the overall task is incomplete.

The recorded final run used Godot 4.7.1 Forward+ on Intel UHD Graphics and saved a
1920x1080 viewport image. Its 24 monotonic frame samples measured 558.564 ms mean
and 578.220 ms p95. This short capture does not establish full-game scalability.
Import and runtime completed with exit code 0; no script/shader errors were logged.
The existing shutdown warning about 7 leaked Texture RIDs remains unresolved.
