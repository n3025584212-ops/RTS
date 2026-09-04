# FRONTLINE VISUAL PRODUCTION RESET V1

STATUS=ACTIVE_USER_DECISION
AUTHORITY=USER_EXPLICIT_DECISION
DATE=2026-09-04

## Decision

All previously generated or previously approved FRONTLINE visual target / design images are deprecated as implementation authority.

This includes the prior visual-target series historically referred to as:
- P0-01 HUD
- P0-02 production/deployment
- P0-03 command feedback
- P0-04 terrain/objective layer
- P0-05 high-intensity engagement
- P1-06 unit-recognition zoom
- P1-07 building/objective state
- FINAL-01 final battle presentation
and any earlier derived visual-target images, composites, exports, or references based on them.

DEPRECATED does not mean deleted. Preserve them only as historical evidence. They must not be used as current production specifications, visual authority, or a basis for claiming implementation completion.

## New production rule

A new design image must be produced before corresponding production implementation begins.

Once the user explicitly approves a new design image:
- visible game elements in that image are implementation targets, not loose inspiration;
- implementation may not silently replace approved terrain, units, effects, camera language, HUD structure, or battle presentation with boxes, placeholders, or unrelated proxy art;
- isolated greybox tests are allowed only as internal technical tests and may not be presented as delivery of the approved visual design;
- logic and visible presentation are built together on the approved production scene.

## Current transition

The existing Godot/Core/Prototype B code remains reusable gameplay-lab and technical material.
The visual production direction is reset.
No previous design image remains active.
The next visual authority is the first newly generated design image explicitly approved by the user after this reset.

SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
