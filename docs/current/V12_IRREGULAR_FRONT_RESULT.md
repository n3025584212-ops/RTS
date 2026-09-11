# V12 Irregular Front Result

DATE=2026-09-11
BRANCH=dev/river-town-local-high-fidelity-v1
RUN_ID=34573271308
HEAD_SHA=a7f26792ab76ed8e7e34d6438d0e1e438cfd8209
ARTIFACT_ID=10188939951

## Technical gate

STATUS=PASS
ENGINE=Godot 4.7.1 stable
RENDERER=Forward+
VIEWPORT=1920x1080
GPU=llvmpipe
POST_CAPTURE_IMAGE_EDITING=false
GRASS_INSTANCES=99041
MID_BUILDINGS=22
MID_UNITS=14
FAR_BUILDINGS=8
DRAW_CALLS=1853
RENDERED_PRIMITIVES=31837611
NEAR_QUALITY_SOURCE=RiverTownHeroShotV2 exact inherited composition

## Spatial objective

FIXED_THREE_LANES=REMOVED
OLD_SYMMETRIC_BRIDGEHEAD_FORCE=REPLACED
CONTACT_TOPOLOGY=CONTINUOUS_IRREGULAR_FRONT
BRIDGE_AXIS=OPEN
UNIT_PLACEMENT=terrain-driven / nonuniform X-Z / opposed headings

## Visual review

VISUAL_ACCEPTANCE=REJECTED_FOR_BATTLEFIELD_PRESSURE

The real screenshot confirms that V12 no longer reads as a left/mid/right three-lane deployment. However, too many of the 14 real vehicle instances land outside the useful camera footprint, behind foreground occluders, or too deep behind the settlement. Only a small number are clearly readable in the frame, so the scene still reads as a high-fidelity foreground plus quiet landscape rather than an active large battlefield.

This is not a topology failure and must not be repaired by restoring lanes or evenly filling three sectors.

## Next bounded action

V12_READABLE_CONTACT_BELT:
- keep V11 Near, town, bridge, woodland masses and FAR skyline unchanged;
- keep fixed_lanes=none;
- use only already-rendered real Abrams/IFV assets for this pass;
- increase visible battlefield pressure from 14 to 18 vehicles while staying below the previously proven Run13 primitive envelope;
- reposition near-side vehicles into the actual camera footprint instead of off-screen negative-X space;
- move far-side contacts into visible settlement/field gaps and increase only their bounded MID scale;
- no smoke, fire, transparent effects, generated infantry proxies, new gameplay system or camera-quality regression in the same pass;
- require a new real 1920x1080 Forward+ screenshot before any production promotion.

PRODUCTION_PROMOTION=NO
