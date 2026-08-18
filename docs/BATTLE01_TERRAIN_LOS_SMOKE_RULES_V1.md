# BATTLE01_TERRAIN_LOS_SMOKE_RULES_V1

STATUS=IMPLEMENTED_FOR_VERTICAL_SLICE
ENGINE=Godot 4.7.1

## Scope

This V1 adds spatial visibility to the existing Recon / Contact system without expanding into full fog-of-war rendering.

- Detection requires both detection range and a clear line of sight.
- Terrain blocker rectangles can break LOS.
- Smoke circles temporarily break LOS.
- Losing LOS from CONTACT or CONFIRMED produces LAST_KNOWN.
- Flanking around the blocker can reacquire CONTACT and then CONFIRMED.
- CONFIRMED is still required before BLUE can receive a direct combat target.
- Direct fire also checks the same LOS field, so terrain/smoke cannot be shot through by direct-fire formations.
- Enemy firing reveal remains part of Recon Contact V1.

## Current vertical-slice limitations

- Terrain blockers are visibility blockers only; movement collision/pathfinding around them is not yet implemented.
- Smoke deployment is currently exercised by the automated slice harness; player-facing smoke command UI is a later task.
- This is not yet a full map-wide fog texture, LOS cone tool, elevation model, concealment modifier, or AI knowledge model.

## CI acceptance chain

`CONFIRMED -> terrain blocks LOS -> LAST_KNOWN -> flank reacquires -> smoke blocks LOS -> LAST_KNOWN -> smoke expires -> reacquire -> combat -> objective -> victory`

Required runtime marker: `FRONTLINE_TERRAIN_LOS_SMOKE_PASS`.
