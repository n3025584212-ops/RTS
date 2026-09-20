# FRONTLINE — VISUAL QUALITY BASELINE

STATUS=ACTIVE_VISUAL_BASELINE
PROJECT=FRONTLINE
CONTROL_AUTHORITY=main
DATE=2026-09-17
AMENDED=2026-09-20 (sole-baseline supersession, see bottom section)

## Purpose

Separate two concepts that must never be conflated again:

1. `CURRENT_TASK` = what the active Sprint/window is currently proving or repairing.
2. `VISUAL_QUALITY_BASELINE` = the strongest retained FRONTLINE visual target/reference that future product work must not silently forget or replace with a lower-quality learning/test scene.

A learning/runtime reproduction may be intentionally narrow or visually incomplete. It must never become the FRONTLINE visual baseline merely because it is the newest artifact.

## Canonical product visual target

`VISUAL_TARGET_AUTHORITY=docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md`
`VISUAL_TARGET_ID=FRONTLINE_GOLDEN_FRAME_V1`
`TARGET_RESOLUTION=1920x1080`
`USER_APPROVED=YES`

The Golden Frame contract remains the production visual gate for the first formal FRONTLINE scene. It requires, among other things, sculpted 3D terrain, river/bridge/town structure, roads/fields/forest, real vehicles/infantry, combat effects and usable tactical HUD. A scene that only proves navigation/combat logic is explicitly not Golden Scene PASS.

## Retained engine-rendered visual references

These are preserved as historical engine-output references and asset/tool evidence. They are not restored as product-direction authority, but they must remain visible to future windows so visual regressions cannot be hidden by the current learning artifact.

### River Town local high-fidelity reference

BRANCH=`dev/river-town-local-high-fidelity-v1`
HEAD=`dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`
ENGINE_SCREENSHOT=`artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png`
SCREENSHOT_BLOB=`f8cac4257ff3088d778cf19279400d6ad7baa084`

Role:
- retained engine-rendered visual comparison;
- terrain/material/composition/tooling evidence;
- not an automatic continuation point;
- not proof that its production method is correct.

### Golden Scene V1 engine reference

BRANCH=`dev/godot-golden-scene-v1`
HEAD=`ec8e49e27b278299ec5654b1094789c6a9d39f6e`
ENGINE_SCREENSHOT=`artifacts/golden_scene/golden_scene_v1_actual_1920x1080.png`
SCREENSHOT_BLOB=`c3d7aba9eca2f906f6d1331455f421ba8a265187`

Role:
- retained real-engine visual/material reference;
- retained legal/provenance asset evidence;
- not current product direction authority.

### Reference Region asset/tool pool

BRANCH=`dev/reference-region-v1`
HEAD=`5f2ff1c0e86553234490063e640cef8d0a2fb9f7`

Role:
- audited real asset pool;
- runtime-capture/tooling reference;
- historical implementation evidence;
- not current product direction authority.

## Learning artifact classification

The learning route is stopped; its current state is not declared here. Current route state lives in
`docs/current/CURRENT_STATE.md` (Learning route status); stopped routes are listed in
`docs/current/ACTIVE_WORK.md`. This section previously declared an active learning branch and a
current gate and drifted out of date.

CLASSIFIED_LEARNING_BRANCH=`learning/sprint01-end-to-end-rts-production`

`Sprint01WorldReproduction.tscn` and its PNG/MP4 evidence are classified as:

`LEARNING_AND_RUNTIME_EVIDENCE`

They are NOT classified as:

`FRONTLINE_CURRENT_BEST_VISUAL`
`FRONTLINE_PRODUCT_BASELINE`
`GOLDEN_SCENE_REPLACEMENT`

The current Sprint may only prove a transferable production method. Its latest screenshot must not replace the product visual target or retained higher-quality engine references by recency alone.

## Anti-regression rule

When a window reports or displays "latest result", it must distinguish:

- `LATEST_TASK_ARTIFACT`
- `LATEST_PLAYER_RUNTIME`
- `CURRENT_BEST_VISUAL_REFERENCE`
- `CANONICAL_PRODUCT_VISUAL_TARGET`

Do not answer "this is the latest product picture" when the artifact is only a learning/reproduction test.

After Sprint 01 passes, the first post-restart FRONTLINE product slice must:

1. use only methods transferred through the Sprint 01 decision;
2. reuse historical assets/tools only when compatible with those methods;
3. target the Golden Frame quality contract from the beginning;
4. compare actual engine screenshots against the retained visual references and Golden Frame;
5. reject any product-slice change that causes an unexplained visual regression below the strongest retained engine result in the dimension being worked on.

## Authority boundary

`OLD_VISUAL_BRANCH_AS_PRODUCT_DIRECTION_AUTHORITY=FORBIDDEN`
`OLD_VISUAL_ARTIFACT_AS_VISUAL_REFERENCE=ALLOWED`
`OLD_ASSET_TOOL_REUSE_AFTER_METHOD_VALIDATION=ALLOWED`
`LEARNING_SCENE_AS_PRODUCT_VISUAL_BASELINE=FORBIDDEN`

This file protects visual continuity without undoing the 2026-09-12 restart decision.

## 2026-09-20 — Sole visual baseline supersession

DECISION_ID=FRONTLINE_SOLE_VISUAL_BASELINE_V1
STATUS=ACCEPTED

`VISUAL_TARGET_AUTHORITY` moves from `docs/design/FRONTLINE_GOLDEN_FRAME_V1_SPEC.md` (Golden Frame V1) to the **River Town sole visual baseline** on `product/frontline-high-fidelity-slice-v1`, declared and evidenced in:

`product/frontline-high-fidelity-slice-v1 :: docs/visual_baseline/SOLE_BASELINE_2026-09-20.md`

with official captures under `docs/visual_baseline/river_town_sole_20260920/` (reference / hero / ground, 1920x1080, Godot 4.7.1 Forward+, Vulkan, capture-frame=16, no post-capture editing).

Consequences applied on 2026-09-20:

1. The sections above that name Golden Frame V1 as `VISUAL_TARGET_AUTHORITY` are superseded; they remain as history.
2. Non-kind asset baselines (FullBattlefield production line V1–V12 + TownProbeA–D, GoldenSceneV1, Quality material/test scenes, the `assets/golden_scene/` library, their evidence and CI workflows) were recycled from the product branch under safety tag `recycle/2026-09-20/pre-visual-baseline-rationalization`.
3. The retired "3 retained engine reference branches" (river-town-local-high-fidelity / golden-scene-v1 / reference-region) remain historical references only; their best lineage has been absorbed into the product branch sole baseline.
4. Same-kind River Town family scenes (HeroHouseHF, structure studies, HeroShotV2) are retained as part of the one baseline, not as competing baselines.
