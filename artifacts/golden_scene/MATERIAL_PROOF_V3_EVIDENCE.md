# FRONTLINE Material Proof V3 Evidence

STATUS=VISUAL_PASS
PROJECT=FRONTLINE
TASK=QUALITY_MATERIAL_PROOF_V1 / MATERIAL_PROOF_V3
ENGINE=Godot 4.7.1
RENDERER=Forward+
RESOLUTION=1920x1080
BRANCH=dev/godot-golden-scene-v1
NO_IMAGE_GENERATION_AS_PROOF=YES
NO_CI_SUCCESS_AS_VISUAL_PASS=YES
NO_PR_CREATED=YES

## Final accepted run

WORKFLOW=FRONTLINE Quality Material Proof V1
RUN_NUMBER=24
RUN_ID=34107266613
HEAD=cc610b7fdcd34e3d1857a8c51062a3e91a380332
RESULT=SUCCESS
ARTIFACT_ID=10013005133
ARTIFACT_NAME=frontline-quality-material-proof-v1
ARTIFACT_DIGEST=sha256:a8d017a129262f5399650efc4dbb1207980fe4dc242853ebab2ee57591e6aea5

Technical gates:
- Forward+ import = PASS
- Godot runtime = PASS
- three real 1920x1080 PNGs = PASS
- artifact upload = PASS
- Abrams wheel-grounding = PASS (34 matched wheel meshes)

## Visual verdict

### HOUSE MATERIAL PROOF = PASS

PNG=house_material_proof_v2_1920x1080.png
SHA256=a66067c820d5022438448717d543988603980ad090d94fb240885c2e06121dd6

Accepted because:
- original roof / wall / window / door separation remains readable;
- no whole-building global material override is used as the final treatment;
- brick, concrete, roof and openings read as distinct materials;
- surface normal / roughness response is visible;
- grime does not dominate as a flat black overlay;
- ground contact is visually established.

### ABRAMS MATERIAL PROOF = PASS

PNG=abrams_material_proof_v2_1920x1080.png
SHA256=26f8d74e5affc804ae50d22f7399726c811c9f1a5db420a347ed733e79aa04ae

The earlier source asset was rejected after real viewport review because its geometry was not a credible M1 Abrams. The accepted proof uses the deterministic Blender hard-surface Abrams V4 builder instead of treating the mislabeled/low-quality source as production truth.

Accepted because:
- vehicle silhouette and major M1A2/Abrams cues are now credible for the material proof;
- hull/turret, segmented side skirts, tracks, wheels/rubber, gun/barrel, exhaust and optics are independently classified;
- tracks use a mud/metal PBR treatment rather than a single black/green override;
- side skirts and lower armor carry stronger dirt/mud and roughness variation;
- barrel, exhaust and optics have distinct material response;
- wheel-grounding/contact is correct;
- the result is no longer a single-green plastic vehicle.

This is a MATERIAL-PROOF acceptance, not a claim that the vehicle is a final production art asset or that it already matches the approved Golden Frame at final-shot quality.

### GROUND MATERIAL PROOF = PASS

PNG=ground_material_proof_v2_1920x1080.png
SHA256=932b9297dd2a58c7de4b2a8eaddfae3cee1e82ab09a79178a2e85ed4fb385268

Accepted because:
- Macro grass / dirt / mud regions are readable;
- ruts/churn are geometry/material variation rather than black rectangular overlays;
- wetness uses roughness/specular variation rather than a flat puddle decal;
- real grass/weed instances and PBR stones provide micro clutter;
- micro assets are grounded;
- the surface no longer reads as a single terrain texture plane.

## Workflow conclusion

HOUSE=PASS
ABRAMS=PASS
GROUND=PASS
MATERIAL_PROOF_V3=PASS
RETURN_TO_1_6_BATTLEFIELD_SLICE=ALLOWED
FULL_GOLDEN_SCENE_VISUAL_PASS=NOT_IMPLIED
PRODUCT_VISUAL_PASS=NOT_IMPLIED

The next visual step may integrate only these proven material principles back into the 1/6 battlefield slice. Integration must still be judged from new real Godot 4.7.1 Forward+ 1920x1080 viewport captures.
