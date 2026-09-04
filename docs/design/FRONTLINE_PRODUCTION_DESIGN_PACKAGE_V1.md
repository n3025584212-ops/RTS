# FRONTLINE PRODUCTION DESIGN PACKAGE V1

STATUS=PROPOSED_AWAITING_USER_APPROVAL
AUTHORITY=NONE_UNTIL_USER_APPROVES
DATE=2026-09-04
ENGINE_TARGET=Godot 4.7.1
DESIGN_ID=FRONTLINE_PRODUCTION_SLICE_RIVER_TOWN_V1

## 1. Visual target

A realistic modern-war tactical RTS viewed from an oblique command camera. The battlefield must read as a real place first and an information surface second.

NO_PIXEL_ART=YES
NO_FLAT_BOX_UNIT_DELIVERY=YES
NO_BILLBOARD_ONLY_WORLD=YES
REALISTIC_3D_TERRAIN_AND_UNITS=TARGET
TACTICAL_READABILITY_OVER_CINEMATIC_CLUTTER=YES

Primary battlefield composition:
- river crossing running north-south through the center-right;
- bridge and riverbank as natural movement constraints;
- dense village occupying the central crossing;
- wooded ridge in the northwest;
- open agricultural fields in the southwest;
- industrial/warehouse edge in the east;
- secondary dirt roads and hedgerows connecting sectors;
- smoke columns, burning wrecks, shell impacts and dust defining active combat zones.

## 2. Production slice objective

The first production slice is a combined-arms fight for a river-town crossing.

Player-facing battle:
- BLUE commands several formation-level groups rather than individual soldiers;
- RED defends and counter-commits based on battlefield state;
- player must allocate combat power across ridge, village/crossing and eastern approach;
- reserve timing, local suppression/ammunition state, intel confidence and limited fire support create continuing trade-offs.

This is a production slice, not the final campaign/map.

## 3. Camera target

DEFAULT_VIEW=OBLIQUE_COMMAND
DEFAULT_PITCH=48_DEG_APPROX
DEFAULT_YAW=FREE
NORMAL_GAMEPLAY_HEIGHT=COMMAND_MEDIUM_HIGH
NEAR_VIEW=UNIT_AND_COMBAT_READABILITY
FAR_VIEW=FORMATION_AND_SECTOR_READABILITY

Camera behavior:
- smooth pan/zoom/rotate;
- no forced cinematic camera during normal control;
- at medium zoom, vehicles retain clear silhouettes;
- at far zoom, unit markers take over without hiding terrain structure;
- player can zoom near enough to see muzzle flash, tracers, infantry dismount movement and vehicle damage.

## 4. Terrain / world element inventory

Required visible environment:
- sculpted terrain relief;
- paved primary road;
- secondary dirt road;
- bridge;
- river water and banks;
- village houses;
- church/landmark tower or equivalent orientation landmark;
- farm fields;
- hedgerows;
- forest blocks;
- ridge/high ground;
- industrial/warehouse structures;
- utility poles/fences/roadside detail where affordable;
- combat decals/scorch;
- destroyed vehicle wrecks;
- smoke/fire emitters.

## 5. Unit presentation target

BLUE/RED share realistic scale and silhouette rules.

Initial production families:
- MBT;
- IFV/APC;
- mechanized infantry;
- reconnaissance vehicle/team;
- self-propelled artillery or mortar support;
- logistics/resupply truck.

Important: exact final roster is not frozen by this design package. These are production-slice presentation families.

Each formation must expose:
- team identity;
- selected state;
- current task;
- health/combat effectiveness;
- suppression/cohesion state;
- ammo/endurance warning;
- reserve/committed state when relevant.

At near zoom, physical models carry identity.
At far zoom, concise tactical markers carry identity.

## 6. HUD target

Screen composition:
- TOP: mission status, battle timer/progress, support availability;
- LEFT/LOWER-LEFT: minimap/tactical map;
- BOTTOM: selected formation strip / formation cards;
- LOWER-RIGHT: selected formation detail and task/command panel;
- WORLD: objective markers, contacts, last-known markers, task arrows/areas, formation markers;
- ALERTS: compact event feed, never a large opaque text wall.

HUD must not cover the central battle.

## 7. Command language visible in UI

Initial command surfaces:
- MOVE / REPOSITION;
- ATTACK / ASSAULT AREA;
- HOLD / DEFEND;
- WITHDRAW / FALL BACK;
- COMMIT RESERVE;
- REQUEST FIRE SUPPORT;
- RESUPPLY where available.

Commands are formation-level. Individual-unit micro is not the primary interaction.

## 8. Combat visual package

Required for first production slice:
- muzzle flashes;
- tracers/projectile streaks;
- cannon/rocket/artillery firing;
- impact dust/sparks;
- HE explosion;
- smoke plume;
- vehicle hit reaction;
- damaged smoke state;
- destroyed wreck/fire state;
- infantry suppression cue;
- movement dust;
- artillery impact pattern.

Effects must communicate battle state, not just decorate it.

## 9. State-to-presentation contract

CONTACT_UNCONFIRMED
-> uncertain/last-known marker, no precise unit identity.

CONTACT_CONFIRMED
-> precise hostile marker + physical unit when in visual range.

SUPPRESSED
-> reduced movement/combat behavior + visible status marker + stronger impact/audio cues.

LOW_AMMO
-> formation card warning + unit/world icon + degraded sustained fire behavior.

DAMAGED
-> health/effectiveness change + vehicle smoke/damage cue.

WITHDRAWING
-> retreat task visualization + movement away from contact + status cue.

RESERVE
-> reserve badge/state in formation card and tactical map.

COMMITTED
-> reserve badge clears/changes and task route becomes visible.

FIRE_SUPPORT_ACTIVE
-> target area marker + incoming/impact sequence + cooldown/remaining-support UI.

## 10. Battlefield readability

At a glance the player must be able to answer:
- where are my formations?
- what is each formation doing?
- which direction is deteriorating?
- what enemy contacts are confirmed vs uncertain?
- where is my reserve?
- which formations are suppressed/damaged/low ammo?
- is fire support available?
- what terrain is controlling the fight?

The UI must not answer:
- which exact move is optimal;
- which sector the player must reinforce.

## 11. Technical implementation mapping

### Existing systems to reuse
- FormationState
- FormationTask
- FormationAgent2D / formation command semantics
- TaskCommandService
- FormationAutonomy concepts
- NavigationService concepts
- state-driven enemy commander work
- limited support concept
- battlefield trend concept

### Production work to create/integrate
- 3D battlefield scene matching the approved visual master;
- terrain mesh/material stack;
- realistic unit model assets;
- formation presenter for 3D units;
- world-space tactical marker layer;
- selection/command presentation;
- VFX package;
- production HUD;
- local formation-vs-formation engagement presentation;
- audio hooks;
- camera controller tuned to approved view.

Existing greybox scene/code may serve as logic lab. It is not the visual production scene.

## 12. Agent-executable work breakdown

AGENT_BATCH_A_WORLD:
Build river, bridge, village, ridge, farmland, forest, industrial edge, roads and lighting to match the approved master and technical layout.

AGENT_BATCH_B_UNITS:
Integrate MBT/IFV/infantry/recon/artillery/logistics visual families with team materials, LOD/readability and formation presentation.

AGENT_BATCH_C_HUD:
Implement the approved HUD regions, formation cards, tactical map, world markers, task feedback and support/intel states.

AGENT_BATCH_D_COMBAT_PRESENTATION:
Implement firing, tracers, impacts, explosions, smoke, suppression and damaged/destroyed states.

AGENT_BATCH_E_LOGIC_BINDING:
Bind existing formation/task/reserve/support/enemy logic to the production scene and state-to-presentation contract.

AGENT_BATCH_F_COMPLIANCE:
Capture fixed camera comparison frames and verify each approved visible element and state exists.

## 13. Approval / completion rule

Until the user explicitly approves this package:
IMPLEMENTATION_AUTHORITY=NO

After approval:
- this package and its visual master become the current production contract;
- deviations require explicit documented reason;
- missing approved elements remain incomplete;
- boxes/proxy art may exist only inside isolated technical tests;
- an integrated feature is not complete until both behavior and approved presentation exist.
