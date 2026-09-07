# FRONTLINE Material Proof V3 Evidence

STATUS=REOPENED_VISUAL_FAIL_AGAINST_APPROVED_GOLDEN_FRAME
PROJECT=FRONTLINE
TASK=QUALITY_MATERIAL_PROOF_V1 / MATERIAL_PROOF_V3
ENGINE=Godot 4.7.1
RENDERER=Forward+
RESOLUTION=1920x1080
BRANCH=dev/godot-golden-scene-v1
NO_IMAGE_GENERATION_AS_PROOF=YES
NO_CI_SUCCESS_AS_VISUAL_PASS=YES
NO_PR_CREATED=YES

## Latest technical run

WORKFLOW=FRONTLINE Quality Material Proof V1
RUN_NUMBER=24
RUN_ID=34107266613
HEAD=cc610b7fdcd34e3d1857a8c51062a3e91a380332
RESULT=TECHNICAL_SUCCESS
ARTIFACT_ID=10013005133
ARTIFACT_NAME=frontline-quality-material-proof-v1
ARTIFACT_DIGEST=sha256:a8d017a129262f5399650efc4dbb1207980fe4dc242853ebab2ee57591e6aea5

Technical gates:
- Forward+ import = PASS
- Godot runtime = PASS
- three real 1920x1080 PNGs = PASS
- artifact upload = PASS
- Abrams wheel-grounding = PASS (34 matched wheel meshes)

## User visual ruling

USER_RULING_DATE=2026-09-07
USER_RULING=NOT_UP_TO_DESIGN_IMAGE_STANDARD
AUTHORITY=USER_EXPLICIT_DECISION
RESULT=VISUAL_FAIL

The previous entry incorrectly treated local material-readability improvements as sufficient for MATERIAL_PROOF_V3 visual acceptance. That conclusion is superseded by the user ruling and by the approved Golden Frame contract.

The approved Golden Frame remains the governing quality target. "Better than previous proof" is not an acceptance criterion.

## Current object verdicts against design-image standard

### HOUSE = FAIL_AGAINST_GOLDEN_FRAME_STANDARD

PNG=house_material_proof_v2_1920x1080.png
SHA256=a66067c820d5022438448717d543988603980ad090d94fb240885c2e06121dd6

Current image has distinct brick/concrete/roof/opening materials and correct grounding, but still lacks the authored high-frequency surface depth, trim/detail richness, weathering integration, lighting response and production-scene environmental context needed to visually approach the approved design image.

### ABRAMS V4 = FAIL_AGAINST_GOLDEN_FRAME_STANDARD

PNG=abrams_material_proof_v2_1920x1080.png
SHA256=26f8d74e5affc804ae50d22f7399726c811c9f1a5db420a347ed733e79aa04ae

The V4 rebuild fixes the incorrect/low-quality prior vehicle source and establishes an Abrams-like hard-surface structure. It also separates hull, side skirts, tracks, wheels/rubber, barrel, exhaust and optics. However, the rendered result still lacks production-grade asset fidelity, realistic edge/normal detail, authored coating wear, dirt accumulation, decals/markings, track/wheel microdetail, physically rich material breakup and design-frame-level lighting integration.

### GROUND = FAIL_AGAINST_GOLDEN_FRAME_STANDARD

PNG=ground_material_proof_v2_1920x1080.png
SHA256=932b9297dd2a58c7de4b2a8eaddfae3cee1e82ab09a79178a2e85ed4fb385268

The proof establishes separate grass/dirt/mud/wet/rut layers and grounded micro assets, but still lacks the dense meso/micro structure, natural vegetation massing, terrain relief, soil displacement, debris integration, wheel interaction and production lighting needed to approach the approved design image.

## Workflow conclusion

HOUSE=FAIL_AGAINST_DESIGN_STANDARD
ABRAMS=FAIL_AGAINST_DESIGN_STANDARD
GROUND=FAIL_AGAINST_DESIGN_STANDARD
MATERIAL_PROOF_V3=REOPENED
RETURN_TO_1_6_BATTLEFIELD_SLICE=BLOCKED
FULL_GOLDEN_SCENE_VISUAL_PASS=NO
PRODUCT_VISUAL_PASS=NO

Next work must target visible convergence toward the approved Golden Frame, not only technical material separation. New acceptance requires real Godot 4.7.1 Forward+ 1920x1080 captures that visibly approach the approved design-image quality bar.
