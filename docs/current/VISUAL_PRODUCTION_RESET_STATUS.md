# FRONTLINE visual production — current checkpoint

Updated: 2026-09-09. **VISUAL ACCEPTANCE: FAILED / NOT READY.**

The objective remains the user-approved Golden Frame, rendered by real Godot 4.7.1 at 1920×1080. The screenshot below is work in progress and does not satisfy that objective. A successful import, a saved screenshot, asset counts and CI results do not grant visual approval.

## Evidence

- [Latest real runtime capture](../../artifacts/visual_reset/river_town_actual_1920x1080.png)
- [Runtime metadata](../../artifacts/visual_reset/runtime_metrics.json): Godot 4.7.1 stable, Forward+, Intel UHD Graphics, native viewport capture after `frame_post_draw`. The short 24-frame sample averaged 133.60 ms; it is not a performance acceptance test.
- [User-supplied approved reference](../visual_reference/approved_user_frame.png). SHA256 `7f2f462d34387d32109d4feb83f197f88adbc3ff0f54b26d0142172789f16e3d`. This is the user's subsequently supplied image; the older repository SHA256 refers to a different, missing binary. Neither identity is silently overwritten.
- [External asset attribution](../licenses/visual_slice/ATTRIBUTION.md) and [source/license records](../licenses/visual_slice/source_license_manifest.json).

![Actual Godot capture — not visually approved](../../artifacts/visual_reset/river_town_actual_1920x1080.png)

## What is implemented locally

A separate visual-only scene now combines a licensed Abrams model, authored dimensional houses, real source foliage/rocks/props, terrain, water, sky and native Godot effects. Its launch command is `scripts/production/run_river_town_slice.ps1`. The gameplay scene, Core logic and project startup configuration are unchanged. The source is an isolated snapshot of `dev/godot-golden-scene-v1` at `e909d17ac2d521b0fcef4720499a3578024ba129`.

The status and raw evidence are published in commit `2fc6dc3287e21b12cde0a4d5e14bf303f04f80da`. The runnable scene, scripts, self-contained GLBs, textures, attribution and evidence are published in commit `85a5181adc47f690787eae41a8b061626be622eb` on `dev/visual-production-reset`. The accepted product state is not advanced, and no visual PASS is claimed.

`scripts/production/verify_visual_checkpoint.py` checks evidence dimensions, real engine identity, runtime errors and frozen-file isolation. Its result separates **integrity PASS** from **visual FAIL_NOT_READY**. It does not award a visual score.

## Why the image still fails

1. The hero house is still a procedural layout asset. Its damage, roof structure, edges and surface history are much too regular and shallow for the reference.
2. The tank is recognizable and substantially more detailed than the old proxy, but paint, metal, attached equipment, mud and ground contact do not yet have the reference's physical credibility.
3. Mud ruts and puddles remain overly regular. Water looks like dark patches; the surrounding soil and grass do not form the dense, uneven foreground in the approved frame.
4. Repeated houses, scattered plants and distant foliage cards still read as placed assets. The river/bridge is poorly exposed and the reference's layered environment is not reproduced.
5. Illumination lacks the reference's warm directional highlights, cool soft shadows and coherent atmosphere. Repeated exposure changes have not solved the asset problems.

## Execution correction

The work drifted into rebuilding a pipeline and expanding the scene before the largest visible assets were convincing. Repository synchronization was also delayed. These are execution failures, not reasons to lower the goal.

Work is now restricted to one fixed frame and its camera-visible contents. The next visual decision must come from the house, tank and mud together at their final screen size. New pipeline work, broader battlefield scope and distant detail are secondary. The current generated house kit is not an accepted production route and may be replaced. Asset candidates are not accepted from marketplace previews; source license, actual model and actual Godot rendering must all be checked.

Every further repository checkpoint must link a real runtime image, state the remaining visible failures, and retain the exact source/license records. There is no completion percentage or promised acceptance date supported by the current evidence.
