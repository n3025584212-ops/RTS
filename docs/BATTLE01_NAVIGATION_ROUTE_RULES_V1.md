# BATTLE01_NAVIGATION_ROUTE_RULES_V1

STATUS=IMPLEMENTED_FOR_VERTICAL_SLICE
ENGINE=Godot 4.7.1
TASK_ID=BUILD_BATTLE01_NAVIGATION_ROUTE_MOVEMENT_V1

## Navigation implementation

Battle01 uses Godot's built-in `AStarGrid2D` as a small deterministic navigation topology for the current fixed map. This is intentionally local to Battle01 and is not a new large manager framework.

- Formation MOVE resolves a legal grid path before movement begins.
- IFV and Recon follow path waypoints rather than traveling directly through blockers.
- Multi-formation MOVE retains the existing small target spacing; each formation resolves its own legal path to its offset destination.
- A blocked destination is clamped to the nearest walkable grid cell.

## Tactical topology

- Central Bridge is the only legal river crossing and is the shortest/direct route.
- North Village contains multiple building blockers with connected streets and a longer flank route.
- South Maneuver Corridor remains connected to the center/north network but creates the longest route.
- Industrial Area contains obstacle blocks with connected service lanes.
- The three route families are connected; they are not isolated route pipes.

No road speed multipliers, advanced formation steering, attack-move, AI route planning, economy, new units, or map expansion are introduced.

## Required CI markers

- `FRONTLINE_NAVIGATION_ROUTE_READY`
- `FRONTLINE_CENTRAL_ROUTE_PASS`
- `FRONTLINE_NORTH_ROUTE_PASS`
- `FRONTLINE_SOUTH_ROUTE_PASS`
- `FRONTLINE_NAVIGATION_SMOKE_PASS`
