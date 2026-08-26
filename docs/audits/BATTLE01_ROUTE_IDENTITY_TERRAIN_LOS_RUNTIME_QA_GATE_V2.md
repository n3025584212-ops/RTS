# BATTLE01 Route Identity / Terrain / LOS Runtime QA Gate V2

TASK_ID=RERUN_QA_BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_V1
OWNER_WINDOW=WINDOW_07_INTEGRATION_QA_PERFORMANCE
PROJECT=FRONTLINE
STATUS=FROZEN_QA_GATE_PASS
ENGINE=Godot 4.7.1.stable.official.a13da4feb
SOURCE_OF_TRUTH=GITHUB_MAIN
START_MAIN_SHA=2ab6cec005043422b05ba052d633605aee803de7
ORIGINAL_ROUTE_GAMEPLAY_COMMIT=e319c0a5fa164ee57acd3b3ab70135cbe6b501f7
FORMATION_AWARE_GAMEPLAY_COMMIT=d831eadd1c6c26ebd381a49efbfea5ad8d7c1dc8
FAILED_QA_GATE=docs/audits/BATTLE01_ROUTE_IDENTITY_TERRAIN_LOS_RUNTIME_QA_GATE_V1.md
FIX_AUDIT=docs/audits/BATTLE01_FORMATION_AWARE_ROUTE_MOBILITY_FIX_AUDIT_V1.md

## Independent QA conclusion

Window 07 independently re-reviewed the production Formation movement call path, BattleNavigation mobility API, live Enemy AI controller binding, RED logistics inheritance path, mixed-mobility focused smoke, route geometry authority, frozen product contracts, and the bound local Godot 4.7.1 runtime evidence.

The sole blocker from V1 is closed.

ORIGINAL_BLOCKER=FORMATION_MOVE_MOBILITY_IS_INFERRED_FROM_NEARBY_ORIGIN_FORMATIONS_INSTEAD_OF_THE_ISSUING_FORMATION
ORIGINAL_BLOCKER_CLOSED=YES

## Formation-aware mobility correction

`BattleFormation._issue_navigation_order()` now calls `BattleNavigation.find_path_for_formation(self, world_target)` directly. Therefore real MOVE and WITHDRAW requests bind mobility to the issuing Formation itself rather than scanning nearby Formations at the origin.

FORMATION_MOVE_USES_SELF_IDENTITY=PASS
FOOT_MOBILITY_INTRINSIC=PASS
VEHICLE_MOBILITY_INTRINSIC=PASS
GENERIC_ORIGIN_INFERENCE_USED_BY_REAL_FORMATION_MOVE=NO

Role mapping remains:
- Recon = FOOT
- Infantry = FOOT
- IFV = VEHICLE
- Armor = VEHICLE
- Logistics = VEHICLE

## Mixed-mobility overlap proof

The focused runtime smoke now exercises real `formation.issue_move()` under the exact ambiguity that defeated V1:

- Recon and IFV exact overlap at the North foot-link entry: Recon uses the foot-only link; IFV uses a legal vehicle street detour.
- Infantry and Armor are separated by only 2 world units, inside the old 3-unit origin-inference tolerance: Infantry uses the foot-only link; Armor uses the vehicle detour.
- Logistics and Recon exact overlap: Logistics remains VEHICLE and cannot use the foot-only link.

RECON_IFV_OVERLAP=PASS
INFANTRY_ARMOR_NEAR_OVERLAP=PASS
LOGISTICS_RECON_OVERLAP=PASS
FORMATION_AWARE_MOBILITY_BINDING=PASS

Required runtime markers accepted from the bound real Godot 4.7.1 evidence:
- FORMATION_RECON_FOOT_ACCESS_WITH_VEHICLE_OVERLAP_PASS
- FORMATION_IFV_VEHICLE_ACCESS_WITH_FOOT_OVERLAP_PASS
- FORMATION_INFANTRY_FOOT_ACCESS_NEAR_ARMOR_PASS
- FORMATION_ARMOR_VEHICLE_ACCESS_NEAR_INFANTRY_PASS
- FORMATION_LOGISTICS_VEHICLE_ACCESS_WITH_RECON_OVERLAP_PASS
- FORMATION_AWARE_MOBILITY_BINDING_PASS

## Enemy AI / RED logistics path review

The live Battle01 scene now binds `BattleEnemyAIRouteMobilityController`, a thin subclass of the already accepted RED logistics controller. It does not replace the frozen Enemy AI state machine. It only makes gameplay-critical navigation role-aware.

The live subclass uses the actual unit identity for:
- combat/final-objective path distance;
- named-route cost;
- destination clamp;
- reachability;
- actual AI move issuance.

Inherited RED logistics calls `_can_reach()` for rendezvous viability and `_issue_move()` for target / truck movement; dynamic dispatch therefore uses the formation-aware live overrides. RETURN, ENGAGE, INVESTIGATE, SUPPORT/EVADE, reinforcement movement and RED resupply movement remain on the existing AI semantics while respecting the mover's intrinsic mobility.

AI_PATH_QUERY_REVIEWED=PASS
AI_ROLE_AWARE_FIX_IMPLEMENTED=PASS
RED_RESUPPLY_REACHABILITY_FORMATION_AWARE=PASS
ENEMY_AI_CORE_REWRITTEN=NO

## Route identity product judgment

### Central

CENTRAL_ROUTE=PASS
CENTRAL_PLAYER_VALUE=PASS

Central remains the shortest route, supports all mobility classes, retains the broad/direct main road and clear bridge exposure lane, and therefore produces FAST / CONCENTRATED / PREDICTABLE / EXPOSED play rather than only a lower path-length number.

### North / Village

NORTH_ROUTE=PASS
NORTH_PLAYER_VALUE=PASS

North retains dense hard terrain and broken LOS, a visible true FOOT-only link, and a longer connected vehicle street detour. The V1 ambiguity is removed: Recon / Infantry access is now intrinsic to those Formations even when overlapping vehicles, while IFV / Armor / Logistics remain VEHICLE. North therefore produces INFORMATION / BROKEN_LOS / GROUND_CONTROL / FOOT_MANEUVER / VEHICLE_DETOUR play.

### South / Maneuver

SOUTH_ROUTE=PASS
SOUTH_PLAYER_VALUE=PASS

South remains the longest initial route, visibly wider and more open than the North street network, with long LOS, stable IFV/Armor/Logistics access and a legal continuation toward RED rear / southern Industrial pressure. It therefore produces VEHICLE_MANEUVER / OPEN_SIGHT / ANGLE / REAR_PRESSURE at a real TEMPO_COST.

PLAYER_FACING_ROUTE_DIFFERENCE=PASS
PRODUCT_CORRECTNESS=PASS

## Route / terrain / LOS / 3D preservation

The route geometry was not modified by the formation-aware blocker fix.

ROUTE_GEOMETRY_CHANGED=NO
BATTLE_ROUTE_TERRAIN_CHANGED=NO
VISIBILITY_GEOMETRY_CHANGED=NO
3D_BLOCKOUT_GEOMETRY_CHANGED=NO

The previously accepted shared `BattleRouteTerrain` authority remains the source for Navigation hard blockers, terrain LOS and visible 3D hard-blocker layout.

ROUTE_TERRAIN_NAV_LOS_SYNC=PASS
RIVER_ONLY_BRIDGE_CROSSING=PASS
SEEDED_POSTURE_ANCHORS_ROUTE_GEOMETRY=PASS
REAL_FORMATION_MOVEMENT=PASS

## Runtime evidence handling

INDEPENDENT_RUNTIME_REEXECUTION=UNAVAILABLE_IN_WINDOW_07

Window 07 did not claim to execute the user's local Windows Godot binary in this turn. The fix audit's real local Godot 4.7.1 evidence is accepted as bound runtime evidence after independent provenance review:

- gameplay commit = `d831eadd1c6c26ebd381a49efbfea5ad8d7c1dc8`;
- runtime validation commit = `5432f94a1db9b25ab0c674c8f8bff85474435033`;
- the only delta from gameplay commit to runtime validation commit is the pending audit document;
- no production or test gameplay delta exists between those SHAs.

The audit records exact engine `4.7.1.stable.official.a13da4feb`, import PASS, parse PASS, real Battle01 boot PASS, route identity smoke PASS, all required overlap markers PASS, all required regressions PASS and `BLOCKING_RUNTIME_ERRORS=NONE`.

PROJECT_IMPORT=PASS_BOUND_RUNTIME_EVIDENCE
PROJECT_PARSE=PASS_BOUND_RUNTIME_EVIDENCE
REAL_BATTLE01_BOOT=PASS_BOUND_RUNTIME_EVIDENCE
BLOCKING_RUNTIME_ERRORS=NONE

## Relevant regression status

ROUTE_IDENTITY_SMOKE=PASS
SEEDED_POSTURE_REGRESSION=PASS
RESUPPLY_RED_LOGISTICS_REGRESSION=PASS
ENEMY_AI_REGRESSION=PASS
ROLE_CAPTURE_REGRESSION=PASS
FORMAL_ROSTER_REGRESSION=PASS
LOGISTICS_REGRESSION=PASS
3D_FOUNDATION_REGRESSION=PASS
LEGACY_NAVIGATION_REGRESSION=PASS
RECON_TERRAIN_LOS_COMBAT_REGRESSION=PASS

## Frozen protection

The correction delta changes only Formation path binding, a thin live AI route-mobility adapter, the Battle01 controller script binding and QA smoke coverage. It does not change route geometry or frozen gameplay values.

FORMATION_VALUES_PRESERVED=YES
DAMAGE_MATRIX_PRESERVED=YES
POSTURE_ANCHORS_PRESERVED=YES
ROSTER_PRESERVED=YES
SUPPLY_RULE_PRESERVED=YES
OBJECTIVE_RULE_PRESERVED=YES
ENEMY_AI_FOW_PRESERVED=YES
REINFORCEMENT_SEMANTICS_PRESERVED=YES

## Gate judgment

CONSTRUCTION_CORRECTNESS=PASS
PRODUCT_CORRECTNESS=PASS
PLAYER_FACING_ROUTE_DIFFERENCE=PASS
EVIDENCE_SUFFICIENCY=PASS
FORMATION_AWARE_MOBILITY_BINDING=PASS
QA_GATE_RESULT=PASS
READY_FOR_NEXT_STAGE=YES
BLOCKER=NONE

## Scope boundary

This V2 PASS closes the Battle01 route-identity / terrain / LOS / access slice, including the formation-aware mobility regression that blocked V1.

It does not claim the revised Battle01 is complete. Still downstream:
- ADVANCE / HOLD FIRE command closure;
- pre-battle staging;
- integrated revised Battle01 playtest / pressure-test gates;
- final art / VFX after gameplay closure.

Do not reopen this gate unless a downstream change plausibly regresses route geometry, LOS, mobility access or Formation path binding.

## Cleanup / active state

Window 07 made no production gameplay change. The only durable output of this rerun is this V2 QA Gate. No ZIP, cache, local runtime log bundle or duplicate checkout was added.

ACTIVE_PROJECT_STATE_IS_CLEAN=YES
TASK_RESULT_IS_CREDIBLY_AUDITED=YES

## Next action

NEXT_ACTION=IMPLEMENT_BATTLE01_ADVANCE_HOLD_FIRE_COMMANDS_V1
NEXT_OWNER=WINDOW_04_AI_COMMAND
