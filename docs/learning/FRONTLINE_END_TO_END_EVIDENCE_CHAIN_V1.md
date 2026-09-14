# FRONTLINE END-TO-END EVIDENCE CHAIN V1

STATUS=ACTIVE_CORE_LEARNING_MAINLINE
PROJECT=FRONTLINE
OWNER_WINDOW=WINDOW_01_EVIDENCE_AND_LEARNING
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
ACTIVE_ISSUE=#39

## Purpose

Window 01 does not study maps, units, AI, materials, UI, camera, VFX, or combat as isolated topics.

Its core learning object is the complete causal chain from authored content and data through systems and behavior to player-visible output:

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

The goal is to build an evidence graph showing how a real RTS turns data and assets into behavior, state changes, feedback, and finally the war the player sees and hears.

External projects such as 0 A.D., BAR/Recoil, Warzone 2100, official engine documentation, and shipped commercial games are evidence sources and comparison references. They are not product templates and are not automatically transferable to FRONTLINE.

---

## Layer 01 — Map loading and battle-space construction

Trace:

`Main/Battle Scene -> Map Scene -> Terrain / Navigation / Buildings / Capture Points / Spawn Points`

Required questions:
- what instantiates the battle/map scene;
- terrain representation: TileMap, mesh, Node3D hierarchy, procedural generation, or mixed;
- how river, roads, high ground, buildings and tactical objects are represented;
- where navigation data is authored/generated;
- where spawn points, objectives and capture zones are defined;
- what is data, what is scene structure, and what is runtime generation.

Evidence output:

`map resource -> scene nodes -> navigation data -> playable battle space`

---

## Layer 02 — Unit data source of truth

Trace every unit from gameplay fact back to its authoritative data source.

Examples:

`UnitDefinition / Resource / template / data file`
`-> HP / Speed / Ammo / Damage / Range / Faction`
`-> model / animation / weapon / behavior references`

For FRONTLINE, determine whether current facts are stored in:
- `.tres` / `.res`;
- GDScript constants;
- JSON / CSV;
- scene-local exported values;
- hard-coded script logic;
- mixed sources.

Evidence output must identify the actual source of truth and duplication/conflict risk.

---

## Layer 03 — Model, material and reusable asset binding

Trace:

`unit type`
`-> unit scene/prefab`
`-> MeshInstance3D / renderer object`
`-> imported mesh`
`-> material`
`-> textures`
`-> shader`
`-> LOD / shadow / normal / roughness / other render settings`
`-> final GPU-visible result`

Learning question:

How does one high-quality asset become a reusable game asset family that can scale across the battlefield rather than exist only as a manually polished local showcase?

Evidence must separate asset quality, binding method, runtime reuse, LOD/readability, and scene placement.

---

## Layer 04 — Player unit selection

Trace:

`mouse / touch input`
`-> screen coordinates`
`-> camera ray or selection region`
`-> physics/query/filter`
`-> candidate units`
`-> SelectionManager / selected_units[]`
`-> selection marker and HUD synchronization`

Check:
- single select;
- box select;
- additive/shift select;
- formation/group select;
- ally/enemy filtering;
- selection ring/outline;
- UI synchronization.

---

## Layer 05 — Command routing

Trace one concrete player command from input to semantic command.

Example:

`right click`
`-> input controller`
`-> raycast/world hit`
`-> classify clicked object`
`-> issue command`

Possible branches:

`ground -> MOVE`
`enemy -> ATTACK`
`capture point -> CAPTURE / MOVE`
`friendly -> FOLLOW / context behavior / no-op`
`illegal area -> REJECT`

Evidence must reveal every important translation layer between the player's click and the command accepted by the simulation.

---

## Layer 06 — Pathfinding and movement execution

Trace:

`Move Command`
`-> destination`
`-> formation slot/position`
`-> navigation query / NavigationAgent3D or equivalent`
`-> navigation mesh/graph`
`-> path`
`-> next path position`
`-> steering / velocity`
`-> CharacterBody3D / movement component`
`-> transform update`

Check:
- river blocking;
- building avoidance;
- crowding / unit overlap;
- formation preservation;
- different locomotion classes;
- path failure and recovery;
- whether command intent remains stable during movement.

This layer is the translation from command intent to physical motion.

---

## Layer 07 — Detection and target selection

Separate:

A. player-designated target;
B. automatic unit/AI target acquisition.

Typical automatic chain:

`detection range`
`-> candidate entities`
`-> faction filter`
`-> LOS / visibility`
`-> target class legality`
`-> priority / distance / threat`
`-> valid target`
`-> current_target`

Do not equate "enemy in range" with "unit attacks enemy" without tracing all intermediate conditions.

---

## Layer 08 — Fire, hit, damage and death

Trace:

`target acquired`
`-> weapon ready`
`-> ammo valid`
`-> cooldown valid`
`-> range valid`
`-> LOS valid`
`-> fire decision`
`-> ammo consumption`
`-> hit resolution`
`-> damage`
`-> HP change`
`-> death/destruction state`

For current FRONTLINE historical combat rules, explicitly verify where deterministic hit, `Ammo -1 / shot`, fixed damage, HP mutation and death responsibility are implemented.

Required evidence questions:
- who authorizes fire;
- who consumes ammunition;
- who resolves the hit;
- who computes damage;
- who mutates health;
- who owns death/destruction transition.

---

## Layer 09 — AI command generation

AI should be traced as a producer of game commands, not assumed to be a separate hidden game.

Preferred conceptual chain to test against evidence:

`AI perception / game state`
`-> tactical/strategic decision`
`-> command selection`
`-> same command/execution system used by normal gameplay`
`-> unit behavior`

Direct state manipulation such as teleporting units or directly subtracting HP outside the normal command/combat path must be recorded as a separate mechanism, not silently described as normal command execution.

---

## Layer 10 — UI state acquisition

Trace:

`simulation/game state`
`-> signal / event / query / observer`
`-> HUD / world-space UI`
`-> player-visible display`

Examples:
- selected unit HP;
- ammo;
- capture progress;
- battle state;
- reinforcement state;
- victory state.

The audit question is whether UI expresses authoritative state or independently calculates/duplicates game truth.

---

## Layer 11 — Animation, VFX and audio feedback

Separate simulation fact from perceptual feedback.

Example shooting event:

`logical FIRE confirmed`
`-> animation`
`-> muzzle flash`
`-> projectile / tracer`
`-> impact effect`
`-> sound`
`-> camera feedback`
`-> HUD feedback`

A logical event existing in code does not prove the player perceives it clearly or with sufficient weight.

This layer is where a technically functioning battle may still feel dead.

---

## Layer 12 — Camera and render presentation

Treat camera as part of the render system, not only a navigation tool.

Trace/measure where possible:
- camera height;
- FOV;
- pitch/angle;
- unit screen size;
- terrain and object density;
- lighting direction;
- fog/atmospheric depth;
- LOD switching;
- shadow distance/quality;
- post-processing;
- readability at command scale.

The same assets can look radically different under different camera and render constraints.

---

## Layer 13 — Final player-visible result

All prior layers converge into:

`map`
`+ unit assets`
`+ materials`
`+ lighting`
`+ battle state`
`+ animation`
`+ VFX`
`+ UI`
`+ camera`
`+ audio`
`-> PLAYER EXPERIENCE`

The player does not directly see NavigationAgent3D, Resource objects, state machines, AI controllers, command queues or shader parameter tables.

The final acceptance questions are player-facing:
- after I click, does the force behave like a military formation rather than disconnected objects;
- do vehicles and infantry have credible weight/readability;
- does fire/combat have perceptible force;
- does the battlefield feel alive and causally organized;
- can the player understand what is happening at a glance;
- does the result look and feel like the war game the project intends to make.

---

## Required evidence graph

Window 01 must maintain the complete chain as linked evidence, not thirteen unrelated research notes:

`CONTENT`
`map / unit data / models / materials`
`-> WORLD`
`scene / navigation / tactical objects`
`-> INPUT`
`selection / commands`
`-> SIMULATION`
`movement / detection / targeting / combat`
`-> CONTROL`
`player command / AI command`
`-> STATE`
`HP / ammo / capture / victory / other authoritative state`
`-> PRESENTATION`
`animation / VFX / audio / UI`
`-> RENDER`
`lighting / camera / LOD / post-process`
`-> PLAYER`
`visible and audible war experience`

For every important edge, record:
- SOURCE;
- STATUS=`OBSERVED|REPRODUCED|INFERRED|HYPOTHESIS|UNKNOWN|REJECTED`;
- WHAT_THE_SOURCE_PROVES;
- WHAT_IT_DOES_NOT_PROVE;
- FRONTLINE_CURRENT_IMPLEMENTATION, if known;
- EXTERNAL_REFERENCE_IMPLEMENTATION, if inspected;
- GAP;
- REPRODUCTION_REQUIRED=`YES|NO`.

---

## Window interfaces

### Window 01 -> Window 02

Window 01 must hand off concrete broken or missing links, not generic advice such as "improve AI", "improve materials", or "make VFX stronger".

Window 02 should be able to see exactly which edge in the chain is unsupported, broken, duplicated, visually weak, or unverified.

### Window 01 -> Window 03

Window 03 audits whether:
- the source really supports the claimed edge;
- a source/version was misidentified;
- hidden implementation was guessed from a screenshot;
- one project's implementation was promoted to a universal RTS rule;
- competing explanations or counterexamples exist;
- a missing edge was disguised by fluent prose.

### Window 02 -> Window 03

Window 03 reviews the real artifact and asks whether the repaired/reproduced edge actually changes the end-to-end result, not merely whether code exists.

---

## Exit condition for the learning phase

The learning phase does not PASS because all thirteen headings contain text.

PASS requires:
1. at least one real playable chain has been traced end-to-end with source-backed links;
2. critical links have explicit unknowns rather than invented bridges;
3. one small complete chain has been independently reproduced;
4. the reproduction produces actual player-visible behavior and feedback;
5. the evidence graph can diagnose a poor result as an asset, world, input, simulation, control, state, presentation, render, or multi-layer integration problem;
6. only supported/reproduced methods are considered for FRONTLINE transfer.

CORE_PRINCIPLE=LEARN_CONNECTIONS_NOT_ISOLATED_MODULES
