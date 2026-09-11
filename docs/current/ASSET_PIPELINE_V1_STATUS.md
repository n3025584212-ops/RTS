# Asset Pipeline V1 Status

Current branch: `dev/asset-pipeline-v1`

This branch is additive and intentionally separated from `dev/river-town-local-high-fidelity-v1`.

Protected existing high-fidelity assets are not modified in place. The branch adds:

- `docs/current/FRONTLINE_ASSET_PIPELINE_V1.md`
- `tools/asset_pipeline/build_rural_house_family.py`
- `tools/asset_pipeline/validate_generated_glbs.py`
- `.github/workflows/asset-pipeline-v1.yml`
- `assets/generated/asset_pipeline_v1/` output namespace

Runtime acceptance remains pending until Blender export and Godot 4.7.1 import validation pass in CI.
