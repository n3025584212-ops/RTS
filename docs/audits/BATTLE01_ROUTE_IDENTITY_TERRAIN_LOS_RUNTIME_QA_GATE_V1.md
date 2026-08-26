# BATTLE01 Route Identity / Terrain / LOS Runtime QA Gate V1

TASK_ID=QA_BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_FAIL
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
START_MAIN_SHA=3b5a0d1af81393a016c02be70444ed3d0919738e
VERIFIED_GAMEPLAY_COMMIT=e319c0a5fa164ee57acd3b3ab70135cbe6b501f7
SOURCE_AUDIT=docs/audits/BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_IMPLEMENTATION_AUDIT_V1.md

## Independent QA conclusion

Window 07 independently inspected the final route-terrain gameplay code, shared terrain authority, Navigation mobility implementation, Visibility LOS binding, 3D blockout binding, focused route-identity smoke, Formation movement call path, Enemy AI navigation call path, and the frozen product contracts.

The authored route geometry is materially differentiated and is not merely three differently colored path labels:

- Central is the shortest named route and has a wide/direct road and clear bridge exposure lane.
- North has dense Village hard blockers, broken LOS, a narrow visible foot-only link and a longer vehicle street detour.
- South is the longest route, has visibly wider vehicle lanes, a long clear LOS corridor and a legal rear-pressure continuation.
- Navigation / terrain LOS / 3D hard-blocker semantics are sourced from shared `BattleRouteTerrain` geometry.

However the gate FAILs because the production Formation movement path does not reliably bind mobility to the Formation issuing the order.

## Blocking construction defect: mobility is inferred from nearby formations, not the mover

`BattleNavigation` provides the correct formation-aware API:

`find_path_for_formation(formation, to_world)`

but `BattleFormation._issue_navigation_order()` still calls:

`_navigation.find_path(global_position, world_target)`

The generic `find_path()` then calls `_resolve_mobility_for_origin(from_world)`, recursively scans every node with `get_role()` within `FORMATION_ORIGIN_TOLERANCE=3.0`, and returns VEHICLE mobility if any nearby matched Formation is a vehicle.

Therefore a Recon or Infantry Formation that is colocated or nearly colocated with IFV / Armor / Logistics can be classified as VEHICLE for that move request. In that state its North foot-only path can disappear or become the vehicle detour even though the issuing Formation itself is a FOOT role.

This violates the frozen route-identity requirement that real Formation runtime pathing must know which Formation is moving and must preserve FOOT access independently of nearby vehicle positions.

The issue is particularly relevant to an RTS because Formations may converge, overlap at rally/command points, or temporarily occupy nearly identical coordinates. Mobility access must be an intrinsic property of the mover, not a property inferred from neighboring formations.

## Focused smoke evidence gap

The current focused route smoke proves isolated movement cases by placing Recon, Infantry and IFV at the North foot-link entry one at a time and issuing moves separately. It does not test mixed-mobility overlap / near-overlap.

As a result the smoke can print:

- `FORMATION_RECON_FOOT_MOVEMENT_PASS`
- `FORMATION_INFANTRY_FOOT_MOVEMENT_PASS`
- `FORMATION_IFV_NORTH_STREET_MOVEMENT_PASS`

while the production ambiguity above still exists.

The implementation audit statement that real `BattleFormation.issue_move` resolves mobility per Formation role is therefore too strong for the current call path.

## Route product judgment

### Central

CENTRAL_GEOMETRY_DIFFERENCE=PASS
CENTRAL_SHORTEST=PASS_BY_CODE_AND_BOUND_RUNTIME_EVIDENCE
CENTRAL_ALL_MOBILITY_ACCESS=PASS_BY_EXISTING_EVIDENCE
CENTRAL_EXPOSURE_LOS=PASS_BY_CODE_AND_BOUND_RUNTIME_EVIDENCE
CENTRAL_PLAYER_VALUE=PASS

The direct/wide Central lane and clear bridge exposure support FAST / CONCENTRATED / PREDICTABLE / EXPOSED play.

### North

NORTH_GEOMETRY_DIFFERENCE=PASS
NORTH_BROKEN_LOS=PASS
NORTH_VISIBLE_FOOT_LINK=PASS
NORTH_VEHICLE_STREET_DETOUR=PASS
NORTH_FOOT_ACCESS_CONSTRUCTION=FAIL_UNRELIABLE_MOVER_IDENTITY
NORTH_PLAYER_VALUE=FAIL_UNTIL_FOOT_ACCESS_IS_INTRINSIC_TO_ISSUING_FORMATION

The authored geometry supports INFORMATION / BROKEN_LOS / GROUND_CONTROL / FOOT_MANEUVER, but the production move call can silently collapse FOOT access to VEHICLE access when a vehicle is colocated with the foot Formation.

### South

SOUTH_GEOMETRY_DIFFERENCE=PASS
SOUTH_LONGEST=PASS_BY_CODE_AND_BOUND_RUNTIME_EVIDENCE
SOUTH_WIDE_VEHICLE_LANE=PASS
SOUTH_LONG_LOS=PASS
SOUTH_REAR_PRESSURE_ACCESS=PASS
SOUTH_PLAYER_VALUE=PASS

South provides a real longer/open vehicle maneuver identity rather than only a length difference.

## Shared geometry / presentation

ROUTE_TERRAIN_NAV_LOS_SYNC=PASS_BY_CONSTRUCTION
VISIBLE_3D_BLOCKOUT_SYNC=PASS_BY_CONSTRUCTION
RIVER_ONLY_BRIDGE_RULE=PASS_BY_CONSTRUCTION_AND_BOUND_EVIDENCE

`BattleRouteTerrain` is shared by Navigation and Visibility, and Battle3DWorld builds the authoritative hard blockers and North foot-link visual from the same geometry source.

## Independent runtime requirement

This Window 07 environment does not have direct execution access to the user's local Windows Godot executable / local verification worktree, so Window 07 did not independently re-run Godot 4.7.1 in this QA turn. The Window 02 implementation audit records real local Godot 4.7.1 execution, but those results are treated as upstream evidence only and are not relabeled as Window 07's own runtime run.

Because a deterministic production construction defect already exists, the gate is FAIL regardless; no PASS can be issued from inherited runtime evidence.

PROJECT_IMPORT=NOT_INDEPENDENTLY_REEXECUTED_BY_WINDOW_07
PROJECT_PARSE=NOT_INDEPENDENTLY_REEXECUTED_BY_WINDOW_07
REAL_BATTLE01_BOOT=NOT_INDEPENDENTLY_REEXECUTED_BY_WINDOW_07
BLOCKING_RUNTIME_ERRORS=UNVERIFIED_BY_WINDOW_07_INDEPENDENT_RUN

## Frozen protection

No evidence was found that this route implementation changed frozen Formation values, damage matrix, roster, seeded posture anchors, Supply rules or Objective rules.

FORMATION_VALUES_CHANGED=NO
DAMAGE_MATRIX_CHANGED=NO
ROSTER_CHANGED=NO
SEEDED_POSTURE_ANCHORS_CHANGED=NO
SUPPLY_RULE_CHANGED=NO
OBJECTIVE_RULE_CHANGED=NO

## Gate judgment

CONSTRUCTION_CORRECTNESS=FAIL
PRODUCT_CORRECTNESS=FAIL
PLAYER_FACING_ROUTE_DIFFERENCE=FAIL
EVIDENCE_SUFFICIENCY=FAIL
QA_GATE_RESULT=FAIL
READY_FOR_NEXT_STAGE=NO

BLOCKER=FORMATION_MOVE_MOBILITY_IS_INFERRED_FROM_NEARBY_ORIGIN_FORMATIONS_INSTEAD_OF_THE_ISSUING_FORMATION

## Required correction boundary

RETURN_TO=WINDOW_02_TECH_ARCHITECTURE

Required minimum correction:

1. Make real `BattleFormation` navigation orders call a formation-aware mobility path API using the issuing Formation identity, e.g. `find_path_for_formation(self, world_target)` or an equivalent explicit mobility profile. Do not infer the mover's mobility from nearby formations.
2. Review any gameplay-critical path-cost / route-selection calls that must be role-aware and make them explicit where the current generic origin inference could affect FOOT vs VEHICLE semantics.
3. Add a focused runtime case where Recon/Infantry is colocated or within the existing origin tolerance of a vehicle and still uses the North foot-only link, while the vehicle still takes the street detour.
4. Re-run real Godot 4.7.1: import, parse, Battle01 boot, route identity smoke and all regressions required by this gate.

Do not redesign Central/North/South geometry unless the minimal correction reveals a genuine geometry bug. Do not implement ADVANCE, HOLD FIRE, staging, new units, new map regions, cover, road bonuses or final VFX.

## Next action

NEXT_ACTION=FIX_BATTLE01_FORMATION_AWARE_ROUTE_MOBILITY_V1
NEXT_OWNER=WINDOW_02_TECH_ARCHITECTURE

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES
