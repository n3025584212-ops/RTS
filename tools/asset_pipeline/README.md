# FRONTLINE Asset Pipeline V1

This toolchain converts authored or procedural source geometry into reusable GLB assets through Blender Python, then validates import in Godot 4.7.1.

The pipeline is additive. Existing high-fidelity assets under `assets/visual_slice` and `assets/golden_scene` are preservation anchors and are never modified in place.

Current proof target: rural masonry house family with intact/damaged variants and LOD0/1/2.
