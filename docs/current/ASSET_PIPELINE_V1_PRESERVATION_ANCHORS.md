# Asset Pipeline V1 Preservation Anchors

The following current high-fidelity asset families are preservation anchors. Asset Pipeline V1 must not delete, overwrite, down-res, or silently replace them:

- `assets/visual_slice/abrams.glb`
- `assets/visual_slice/hero_house_ruined.glb`
- `assets/visual_slice/hero_house_ruined_hf.glb`
- `assets/visual_slice/hero_v2/`
- `assets/golden_scene/vehicles/ifv.glb`
- `assets/golden_scene/buildings/`
- `assets/golden_scene/nature/`
- current Poly Haven-backed PBR surface families used by the visual slice and Golden Scene

Any derived asset must be written under `assets/generated/asset_pipeline_v1/` or another explicitly versioned derivative namespace.
