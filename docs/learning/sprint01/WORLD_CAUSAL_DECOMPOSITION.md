# FRONTLINE — Sprint 01 World Causal Decomposition V1

STATUS=READY_FOR_WINDOW_03_AUDIT
TASK_ID=LEARN_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1
WINDOW_ID=01
WINDOW_ROLE=EVIDENCE_AND_LEARNING
ACTIVE_ISSUE=#39
CONTROL_TASK=docs/learning/sprint01/TASK_01_WORLD_CAUSAL_DECOMPOSITION_V1.md

PRIMARY_REFERENCE=0_AD_ALPINE_VALLEY
PRIMARY_REFERENCE_MAP=binaries/data/mods/public/maps/random/alpine_valley.js
INSPECTED_SOURCE_STATE=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
COUNTEREXAMPLE_REFERENCE=WARZONE_2100
WARZONE_INSPECTED_COMMIT=b0288082c54536ae3634a6a71b0e03f0d82bb8f3

WORLD_CAUSAL_MODEL=BRANCHING_CONSTRAINT_GRAPH
LINEAR_OBJECT_CHECKLIST_MODEL=REJECTED
WORLD_METHOD_TRANSFER=NOT_APPROVED
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

---

## 0. Scope and evidence boundary

This document answers one narrow production-learning question:

> How does one inspectable mature RTS world route turn upstream terrain/content decisions into a playable, rendered battlefield, and which parts of that route are candidates for an isolated FRONTLINE reproduction?

The selected primary route is 0 A.D. `Alpine Valley` at inspected source state `a2cae4d...`.

### Version warning

The source facts below are direct observations of the inspected `a2cae4d...` tree. Existing Sprint-01 audit work did **not** authoritatively close:

`official R28 release -> exact official tag/tree/commit -> a2cae4d...`

Therefore the allowed version wording remains:

`INSPECTED_SOURCE_STATE=a2cae4d...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28`

The archived GitHub mirror is not being used as proof that `a2cae4d...` is the exact official packaged Release-28 tree.

### Why the world model is not a single line

The task contract gives a useful investigation order:

`terrain -> transport -> land-use -> settlement -> vegetation -> tactical space -> materials -> lighting -> camera -> player`

The inspected implementation is not one serial caller chain in that order. Several systems are parallel descendants of common upstream choices:

```text
map settings / biome / player placement
        |
        +--> elevation + mountain topology
        |      +--> slope / water / shore passability
        |      +--> movement corridors
        |
        +--> player-base anchor
        |      +--> city-patch road surface
        |      +--> civic/start entities
        |      +--> local resources / trees / decoratives
        |
        +--> tile classes + placement constraints
        |      +--> forests
        |      +--> hills
        |      +--> resources
        |      +--> dirt / grass patches
        |
        +--> biome palette
        |      +--> ground / cliff / forest / road / snow surface tags
        |      +--> vegetation / rock / fauna actor vocabulary
        |
        +--> sky / sun environment

height + terrain + water + obstructions
        -> passability grid
        -> pathfinding

height + terrain textures + entities + environment + camera data
        -> map export / world load
        -> terrain + simulation render submission
        -> scene renderer under runtime camera
        -> PLAYER [qualitative result still requires runtime observation]
```

The production lesson is therefore about **dependencies, constraints and shared state**, not about forcing every visible object into one decorative sequence.

---

# 1. TERRAIN — world topology is authored/generated before decoration

## W01 — Elevation is explicit world data, not a visual-only mesh effect

CLAIM=`Alpine Valley` builds a height-bearing `RandomMap`, then creates mountain ranges, hills and bumps by painting elevation as part of map generation.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen/RandomMap.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- `RandomMap` stores a height grid, terrain textures and entities that are later exported to the engine.
- `Alpine Valley` creates mountain ranges with `PathPlacer`, `SmoothElevationPainter` and hill tile-class painting.
- it separately creates bumps and hills;
- height bands are later used to paint cliff/snow surfaces.

WHAT_IT_DOES_NOT_PROVE=
- that every mature RTS should generate terrain procedurally;
- that this mountain topology is realistic geology;
- that the generated result is visually successful under FRONTLINE's target.

ALTERNATIVE_EXPLANATION=A fixed authored heightmap can provide the same downstream topology without runtime/procedural mountain generation. Warzone provides a concrete mature counterexample through fixed map formats containing tile height data.

FRONTLINE_TRANSFER_RELEVANCE=CANDIDATE_METHOD_ONLY. The transferable candidate is `topology/elevation as authoritative world data before decorative scatter`, not `copy 0 A.D. mountain generation`.

---

# 2. TRANSPORT / ROAD / CROSSING — distinguish local road surface from traversable corridor topology

## W02A — Player-base road surface is locally generated around the settlement anchor

CLAIM=`Alpine Valley` passes a `CityPatch` with `roadWild` and `road` terrain to `placePlayerBases`; `placePlayerBaseCityPatch` paints a constrained clump around each player position.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen-common/player.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=A road/city-surface material patch is causally attached to the player-base anchor instead of being an unrelated decorative decal.

WHAT_IT_DOES_NOT_PROVE=The selected map source does not source-close an authored long-distance road network connecting settlements. The `CityPatch` is not evidence of a map-wide transport graph.

ALTERNATIVE_EXPLANATION=Some maps/games can author road networks directly as fixed map content or splines instead of deriving local road surfaces from a player anchor.

FRONTLINE_TRANSFER_RELEVANCE=CANDIDATE_METHOD_ONLY: local built-surface treatment should be tied to a settlement/tactical anchor rather than scattered independently.

## W02B — Mountain topology deliberately preserves traversable passages

CLAIM=The selected map's `MountainRangeBuilder` rejects mountain-range edges that intersect, leave too little separation, exceed degree constraints, or create cycles that would completely enclose territory; its minimum spacing explicitly includes `passageWidth`.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=Terrain topology is generated with movement-space continuity in mind. The code comments explicitly state that cycles are ruled out to prevent territory from being enclosed by mountain ranges, and `minDistance = mountainWidth + passageWidth` protects gaps between ranges.

WHAT_IT_DOES_NOT_PROVE=
- that these gaps are roads;
- that every preserved gap is equally useful tactically;
- that the algorithm optimizes real military chokepoints or traffic flow.

ALTERNATIVE_EXPLANATION=The no-enclosure rule may primarily exist to prevent pathfinding/gameplay failure rather than to produce sophisticated tactical geography. That narrower interpretation is fully compatible with the source.

FRONTLINE_TRANSFER_RELEVANCE=CANDIDATE_METHOD_ONLY: explicit passable corridors/crossing widths are stronger production constraints than visually placing barriers first and hoping navigation remains coherent.

MAPWIDE_ROAD_NETWORK_IN_SELECTED_REFERENCE=UNKNOWN
MOVEMENT_CORRIDOR_TOPOLOGY=OBSERVED

---

# 3. PARCELS / LAND-USE / ZONING EQUIVALENT — spatial classes and exclusion rules

## W03 — The selected source uses functional spatial classes rather than a literal cadastral parcel system

CLAIM=`Alpine Valley` creates tile classes for players, hills, forests, dirt, rock, metal, food and base resources, then uses class-aware avoidance distances to constrain later placement.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen/library.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- world generation records semantic spatial regions/classes;
- subsequent generators query those classes through constraints such as `avoidClasses(...)`;
- forests, hills, player bases, resources and surface patches are therefore not independent random scatters.

WHAT_IT_DOES_NOT_PROVE=
- a realistic agricultural parcel system;
- urban zoning simulation;
- that tile classes are the best representation for FRONTLINE.

ALTERNATIVE_EXPLANATION=A hand-authored map can encode equivalent spatial organization directly in layers, splines, masks, prefabs or level-design volumes without runtime tile classes.

FRONTLINE_TRANSFER_RELEVANCE=STRONG_REPRODUCTION_CANDIDATE: reproduce the principle `named spatial constraints -> later content placement`, not the exact 0 A.D. tile-class API.

PARCEL_SYSTEM=NOT_OBSERVED
FUNCTIONAL_LAND_USE_ORGANIZATION=OBSERVED

---

# 4. SETTLEMENT / BUILT CONTENT — anchor first, associated content around it

## W04 — Starting built content is anchored to player position and local base structure

CLAIM=`placePlayerBase` places civilization starting entities at the player position, marks the civic-center area, then invokes base-generation functions including CityPatch, trees, mines, berries, animals and decoratives.
SOURCE=`binaries/data/mods/public/maps/random/rmgen-common/player.js`; `binaries/data/mods/public/maps/random/alpine_valley.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- a central settlement/gameplay anchor is established first;
- surrounding start content is placed relative to that anchor and base-resource constraints;
- the road/city patch shares the same upstream anchor.

WHAT_IT_DOES_NOT_PROVE=
- mature civilian town morphology;
- road-front parcel orientation;
- believable modern industrial/urban settlement generation;
- that FRONTLINE should organize its world around RTS starting bases.

ALTERNATIVE_EXPLANATION=In scenario-driven or modern tactical games, the primary anchors may instead be real transport junctions, terrain objectives, compounds, bridges or mission positions rather than player bases.

FRONTLINE_TRANSFER_RELEVANCE=CANDIDATE_METHOD_ONLY: built content should be generated/placed from explicit functional anchors and adjacency constraints, with FRONTLINE-specific anchors determined later.

---

# 5. VEGETATION / NATURAL COVER — clustered ecology-like structure, gameplay effect kept bounded

## W05 — Forests are coherent constrained areas, not independent tree scatter

CLAIM=`Alpine Valley` builds forests as areas using a forest-floor/terrain/tree palette, marks them with a forest tile class, keeps them away from player and hill regions, and later adds separate straggler trees under further spacing constraints.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmbiome/alpine/late_spring.json`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- vegetation is grouped with an associated forest-floor material;
- major forest patches and isolated trees are separate distribution modes;
- spatial exclusion rules prevent arbitrary overlap with several other world classes.

WHAT_IT_DOES_NOT_PROVE=
- ecological realism;
- a specific cover bonus;
- the complete LOS/concealment effect of these tree entities in the selected playable path.

ALTERNATIVE_EXPLANATION=The forest grouping may primarily serve resource distribution, visual coherence and collision spacing; a tactical-cover interpretation requires additional simulation tracing.

FRONTLINE_TRANSFER_RELEVANCE=STRONG_REPRODUCTION_CANDIDATE for `coherent vegetation patches + transition surface + constrained stragglers`; tactical cover/LOS behavior must remain a separate reproduction question.

VEGETATION_VISUAL_SPATIAL_RULE=OBSERVED
VEGETATION_COVER_LOS_EFFECT=UNKNOWN

---

# 6. TACTICAL SPACE / MOVEMENT — generated landform feeds actual passability

## W06 — Terrain height, water and slope are consumed by the pathfinder's passability grid

CLAIM=0 A.D.'s inspected pathfinder builds terrain passability from exact ground height, water level/depth, terrain slope and shore distance, then combines terrain data with obstruction rasterization before updating long-range/hierarchical pathfinding.
SOURCE=`source/simulation2/components/CCmpPathfinder.cpp`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- world topography is not merely visual;
- slope/depth/shore properties are tested against each passability class;
- obstructions are then added to the same grid used by the pathfinders;
- terrain changes trigger grid updates.

WHAT_IT_DOES_NOT_PROVE=
- that every Alpine mountain tile is impassable to every unit class;
- that preserved mountain gaps are deliberately tuned as combat chokepoints;
- infantry/vehicle-specific modern terrain behavior applicable to FRONTLINE.

ALTERNATIVE_EXPLANATION=The generator's corridor rules can be interpreted as broad playability safeguards rather than evidence of sophisticated tactical-space optimization.

FRONTLINE_TRANSFER_RELEVANCE=HIGH_VALUE_REPRODUCTION_CANDIDATE: world geometry/topology must be tested against the actual movement/navigation representation rather than approved from a screenshot alone.

## W06B — “terrain creates tactical funnels” is narrower than the source allows

CLAIM=The generated mountain graph plus passability system creates differentiated movement space.
STATUS=INFERRED
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE

WHAT_THE_SOURCE_ACTUALLY_PROVES=terrain topology and passability are causally linked, and generation protects passages.
WHAT_IT_DOES_NOT_PROVE=a designer-authored tactical intent for each resulting corridor, firing lane or chokepoint.
ALTERNATIVE_EXPLANATION=some tactical consequences emerge from general no-enclosure/playability rules rather than from explicit tactical scripting.
FRONTLINE_TRANSFER_RELEVANCE=Do not reproduce “chokepoints” as decorative shapes. Reproduce measurable route width, reachability, blocking and sight consequences where FRONTLINE needs them.

---

# 7. MATERIAL / SURFACE CONTENT PIPELINE — semantic landform selects a real surface vocabulary

## W07 — Biome data provides the surface/object vocabulary; map rules decide where it is used

CLAIM=The alpine late-spring biome maps semantic roles such as main ground, forest floor, cliff, rocky grass, snow, dirt, road, water and shore to concrete terrain asset tags; the map generator applies these roles according to height and constrained area generation.
SOURCE=`binaries/data/mods/public/maps/random/rmbiome/alpine/late_spring.json`; `binaries/data/mods/public/maps/random/alpine_valley.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- spatial/world semantics and render-surface identity are separated;
- the same generation logic can select a biome palette;
- cliffs/snow respond to height bands;
- forest floor is linked to forest generation rather than globally scattered;
- road/city terrain is linked to the base patch.

WHAT_IT_DOES_NOT_PROVE=PBR quality, photorealism, modern material layering, decals, macro/micro detail or FRONTLINE target fidelity.

ALTERNATIVE_EXPLANATION=A mature project can bind surface types through splat maps, landscape layers, material IDs or authored masks rather than named terrain texture tags.

FRONTLINE_TRANSFER_RELEVANCE=STRONG_REPRODUCTION_CANDIDATE: separate `where/why a surface occurs` from `which material asset renders it`, then test the real material result under the target camera.

## W07B — Terrain asset tags reach the engine's terrain texture system

CLAIM=The inspected engine terrain texture manager loads terrain definitions/assets from `art/terrains/`, resolves texture tags and maintains alpha-map blending resources; `GameView` initializes terrain-texture loading.
SOURCE=`source/graphics/TerrainTextureManager.cpp`; `source/graphics/GameView.cpp`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=the generator's texture names feed a concrete engine terrain-content route rather than being presentation-only prose labels.
WHAT_IT_DOES_NOT_PROVE=visual quality of the chosen textures or equivalent implementation requirements for Godot.
ALTERNATIVE_EXPLANATION=Godot/other engines can achieve the same semantic-to-material separation using very different terrain/shader tooling.
FRONTLINE_TRANSFER_RELEVANCE=TRANSFER_PRINCIPLE_CANDIDATE_ONLY, not engine API transfer.

---

# 8. LIGHTING / ENVIRONMENT — a separate branch joined at final world presentation

## W08 — The selected map explicitly chooses sky and sun state

CLAIM=At the end of `Alpine Valley` generation, the map selects a sky set, sun rotation and sun elevation; `RandomMap.MakeExportable()` includes `Environment` in the exported world data.
SOURCE=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen/RandomMap.js`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=lighting/environment is explicit world state connected to the exported map, not a screenshot-only inference.

WHAT_IT_DOES_NOT_PROVE=
- that the random sky/sun choices were tuned for maximum tactical readability;
- atmospheric depth quality;
- shadows/post-processing settings unique to this map;
- FRONTLINE-equivalent lighting values.

ALTERNATIVE_EXPLANATION=These environment values may primarily provide variation/theme rather than a carefully authored gameplay-lighting composition.

FRONTLINE_TRANSFER_RELEVANCE=CANDIDATE_METHOD_ONLY: lighting/environment must be part of the reproduction world state and evaluated with terrain/material/camera, but exact values require FRONTLINE-specific evidence.

---

# 9. CAMERA / SCALE / READABILITY — shared runtime camera, not a fake terrain-caused edge

## W09A — Runtime camera has an explicit command-scale configuration envelope

CLAIM=The inspected camera controller loads configurable scroll, pitch, zoom, near/far and FOV values; default configuration constrains pitch to 28–60 degrees with 35-degree default, zoom 50–200 with 120 default, and FOV 45 degrees.
SOURCE=`source/graphics/CameraController.cpp`; `binaries/data/config/default.cfg`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=the player views the world through a bounded/configurable RTS camera system rather than a fixed screenshot camera.

WHAT_IT_DOES_NOT_PROVE=
- that these values were designed specifically for Alpine Valley;
- that the map generator derives camera scale from mountain spacing;
- that these values are appropriate for FRONTLINE.

ALTERNATIVE_EXPLANATION=The camera is a game-wide interaction/presentation system shared across many maps; map world construction and camera configuration converge at runtime rather than forming a strict `terrain -> camera` caller chain.

FRONTLINE_TRANSFER_RELEVANCE=HIGH_VALUE_REPRODUCTION_CANDIDATE: test terrain, unit scale, roads, vegetation and material readability under the actual intended command camera. Do not judge the world from a free cinematic/editor view.

ALPINE_SPECIFIC_CAMERA_COMPOSITION=UNKNOWN

## W09B — Camera/frustum controls which terrain enters rendering

CLAIM=`GameView` assigns the runtime view/cull cameras to the scene renderer, tests terrain patch bounds against the camera frustum, submits visible terrain, then asks simulation components to render-submit their content.
SOURCE=`source/graphics/GameView.cpp`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=the authored/generated world and runtime camera meet in an actual render-submission path.
WHAT_IT_DOES_NOT_PROVE=human readability or composition quality.
ALTERNATIVE_EXPLANATION=frustum submission is rendering infrastructure, not evidence that the world was aesthetically composed for the camera.
FRONTLINE_TRANSFER_RELEVANCE=Use player-camera captures as acceptance evidence; renderer visibility alone is technical evidence only.

---

# 10. FINAL PLAYER-VISIBLE WORLD RESULT — source route closes to render submission, perception remains runtime evidence

## W10 — Generated world data reaches engine-visible world state

CLAIM=`RandomMap.MakeExportable()` exports entities, height, terrain texture data, camera and environment; engine-side `GameView` submits terrain and simulation visuals through the scene renderer under the runtime camera.
SOURCE=`binaries/data/mods/public/maps/random/rmgen/RandomMap.js`; `source/graphics/GameView.cpp`
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=there is a concrete source route from generated world representation to renderer submission.

WHAT_IT_DOES_NOT_PROVE=This task has not produced an independent running Alpine Valley capture demonstrating exact visual readability, spatial feel or player-quality result for the inspected source state.

ALTERNATIVE_EXPLANATION=Source-correct world generation can still yield visually weak, unreadable or aesthetically poor output. FRONTLINE's failed historical scenes are direct project evidence that technical connection is insufficient for player acceptance.

FRONTLINE_TRANSFER_RELEVANCE=MANDATORY_REPRODUCTION_BOUNDARY: the next reproduction must finish with player-camera runtime evidence, not stop at generated data, scene nodes or successful import.

ALPINE_VALLEY_SOURCE_TO_RENDER_SUBMISSION=OBSERVED
ALPINE_VALLEY_PLAYER_VISIBLE_QUALITY=UNKNOWN
ALPINE_VALLEY_STAGE4_RUNTIME_CAPTURE=UNKNOWN

---

# 11. Cross-project falsification — Warzone rejects “procedural rmgen is the RTS method”

## W11 — Warzone supports materially different fixed and generated map-content boundaries

CLAIM=At the pinned inspected Warzone state, `wzmaplib` supports mature fixed map formats where `game.map` stores tile texture, height and gateway information; `ttypes.ttp` maps terrain textures to simulation-affecting terrain types; separate files hold initial droids/features/structures. Warzone also supports newer script-generated maps using `game.js`.
SOURCE=`Warzone2100/warzone2100/lib/wzmaplib/README.md`
SOURCE_VERSION=Warzone2100@b0288082c54536ae3634a6a71b0e03f0d82bb8f3
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

WHAT_THE_SOURCE_ACTUALLY_PROVES=A mature RTS can use an authored/fixed map package or a script-generated map; 0 A.D.'s random-map generator structure is not a necessary RTS world-production architecture.

WHAT_IT_DOES_NOT_PROVE=
- that Warzone's map system is better for FRONTLINE;
- a full Warzone visual-render pipeline for one selected map;
- that every mature RTS stores gateways explicitly.

ALTERNATIVE_EXPLANATION=Different game age, engine constraints, map tooling and gameplay may explain the different representation. This difference is exactly why the implementation cannot be universalized.

FRONTLINE_TRANSFER_RELEVANCE=COUNTEREXAMPLE_ONLY. FRONTLINE may eventually use authored maps, procedural rules or a hybrid; the decision requires reproduction evidence.

## W12 — Narrow cross-project pattern that survives the counterexample

CLAIM=Across the inspected 0 A.D. and Warzone world representations, playable world content explicitly carries more than appearance: terrain/topology and content classification are represented in forms consumed by gameplay/runtime systems, while the exact authoring/storage mechanism differs.
SOURCE=W01-W10; W11
SOURCE_VERSION=versions stated above
STATUS=INFERRED
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN

WHAT_THE_SOURCE_ACTUALLY_PROVES=
- 0 A.D.: height/slope/water/obstructions feed passability while map generation exports terrain/entities/environment;
- Warzone: map data contains height/texture/gateways and terrain types that affect simulation behavior.

WHAT_IT_DOES_NOT_PROVE=one mandatory data schema, terrain engine, procedural method, road representation, gateway concept or art style for RTS games.

ALTERNATIVE_EXPLANATION=The shared pattern can arise simply because real-time games need some representation of where entities can exist and move; this is a broad functional requirement, not evidence for one design architecture.

FRONTLINE_TRANSFER_RELEVANCE=USEFUL_BOUNDARY: a FRONTLINE world reproduction should connect visible world construction to actual movement/tactical state instead of treating graphics and gameplay space as separate unrelated scenes.

REJECTED_GENERALIZATION=`A mature RTS should use 0 A.D.-style random map generation.`
REJECTED_GENERALIZATION=`Roads must be procedurally generated from player bases.`
REJECTED_GENERALIZATION=`Tile classes are the required land-use system for RTS.`

BAR_RECOIL_WORLD_AUTHORING_COUNTEREXAMPLE=NOT_REQUIRED_FOR_THIS_CLOSURE
BAR_RECOIL_COMPLETE_WORLD_PIPELINE_IN_THIS_TASK=UNKNOWN

---

# 12. What is genuinely learned from this world trace

The evidence supports the following bounded production knowledge:

1. **Topology is authoritative data.** In the selected 0 A.D. route, elevation is exported world data and is consumed by gameplay passability, not merely a render mesh.
2. **Movement continuity can be a generation constraint.** The selected mountain builder protects passage width and rejects enclosing cycles before decoration is complete.
3. **A local road surface can be causally tied to a settlement anchor.** This does not imply an observed map-wide road network.
4. **Spatial classes constrain later content.** Forests, hills, bases, resources and surface patches use exclusion/spacing rules rather than independent random scatter.
5. **Built content can be anchor-relative.** Starting structures and surrounding resources/content share a player-base anchor.
6. **Vegetation has grouped and straggler distributions with matching forest-floor surfaces.** Its full LOS/cover semantics remain untraced here.
7. **Material identity is data-driven separately from placement logic.** A biome maps semantic terrain roles to concrete texture/actor vocabulary.
8. **Lighting/environment is explicit exported world state but is a parallel presentation branch, not something terrain alone causes.**
9. **Camera is shared runtime infrastructure.** World and camera converge at rendering; the inspected evidence does not justify inventing a map-specific camera-design causality.
10. **A source-correct map is not automatically a player-quality map.** Source closure ends at renderer submission; player readability remains a runtime/visual evidence gate.
11. **Warzone falsifies procedural-rmgen necessity.** Fixed authored packages and script-generated maps can coexist in another mature RTS.

---

# 13. Candidate methods for the next isolated reproduction

These are **reproduction candidates**, not approved FRONTLINE product rules.

## CANDIDATE W-C1 — Topology before decoration

METHOD=Author real terrain/elevation and explicit traversable corridors/crossings before placing decorative world content.
EVIDENCE=W01,W02B,W06
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Verify route reachability, widths, blocking and movement against the actual navigation representation before visual acceptance.

## CANDIDATE W-C2 — Functional anchors drive local built content

METHOD=Choose explicit world/tactical anchors first; place local built surfaces, structures and associated content relative to those anchors instead of scattering assets independently.
EVIDENCE=W02A,W04
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Use FRONTLINE-appropriate anchors such as bridge/junction/compound/objective only after their purpose is defined; do not copy 0 A.D. base coordinates.

## CANDIDATE W-C3 — Constraint layers control content overlap

METHOD=Maintain named spatial masks/classes/volumes for terrain barriers, routes, settlements, vegetation and other content, then apply explicit spacing/avoidance rules.
EVIDENCE=W03,W05
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Demonstrate that generated/placed content obeys route clearance and avoids arbitrary overlaps in the isolated world.

## CANDIDATE W-C4 — Surface material follows landform/function

METHOD=Separate semantic surface role from material asset identity; bind cliff/ground/road/forest/transition surfaces according to terrain or functional context rather than one global flat material.
EVIDENCE=W07
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Use real provenance-recorded material/asset routes and inspect the result at the player camera.

## CANDIDATE W-C5 — Vegetation as coherent regions plus exceptions

METHOD=Build vegetation as constrained patches with transition surfaces, then add sparse stragglers separately.
EVIDENCE=W05
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Judge visual coherence and navigation/LOS separately; do not claim cover semantics unless implemented and reproduced.

## CANDIDATE W-C6 — Environment and command camera are acceptance inputs

METHOD=Freeze a reproduction camera envelope and lighting/environment state before judging world readability; evaluate terrain, units, materials and vegetation under that player view.
EVIDENCE=W08,W09,W10
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=Fresh Godot player-camera capture/video, not editor/free-camera screenshots.

## CANDIDATE W-C7 — Reuse sanctioned real assets, not old scene coordinates

METHOD=Use the already audited real asset/provenance pool where appropriate, but place it using the newly tested topology/anchor/constraint rules instead of restoring Golden Scene, River Town or Reference Region layouts.
EVIDENCE=existing Sprint-01 `ASSET_GATE.md` plus W-C1..W-C6
STATUS=INFERRED
TRANSFER_CLASS=DESIGN_RECOMMENDATION_CANDIDATE_FOR_REPRODUCTION_ONLY
TEST=No Box/Plane/color-block environment delivery; real world assets must participate in the causal placement/material route and remain player-readable.

---

# 14. Explicit UNKNOWN / limits

- `U-WORLD-VERSION-IDENTITY`: authoritative official R28 release/tag/tree/commit -> `a2cae4d...` exact identity remains unclosed.
- `U-WORLD-ROAD-NETWORK`: no explicit long-distance road/transport network is source-closed for the selected Alpine Valley generator; observed `CityPatch` road terrain is local.
- `U-WORLD-CROSSINGS`: no bridge/ford production chain is traced in this selected map; mountain passage preservation is the observed transport-topology edge.
- `U-WORLD-VEGETATION-LOS`: complete forest/tree effect on LOS/concealment/cover is not traced in this task.
- `U-WORLD-TACTICAL-INTENT`: source proves passage/playability constraints, not a unique designer intent for every chokepoint/firing lane.
- `U-WORLD-ALPINE-CAMERA`: map-specific Alpine Valley camera composition is not observed; inspected camera settings are game-wide runtime configuration.
- `U-WORLD-PLAYER-RESULT`: no independent Stage-4 runtime capture of the selected Alpine Valley source state was produced in this task; qualitative player readability remains UNKNOWN.
- `U-WORLD-WARZONE-RENDER`: Warzone is used here as an authoring/storage counterexample; one Warzone map has not been traced end-to-end through its renderer in this task.
- `U-WORLD-BAR-PIPELINE`: a complete BAR/Recoil world-authoring pipeline was not traced because it is not required to falsify the procedural-rmgen necessity claim.
- `U-WORLD-FRONTLINE-REPRODUCTION`: whether candidates W-C1..W-C7 improve the isolated FRONTLINE player result remains UNKNOWN until Window 02 reproduces them after Window 03 method audit.
- `U-WORLD-FRONTLINE-TRANSFER`: no world-production method is approved for product transfer by this document.

---

# 15. Window-01 completion gate

```text
WORLD_CAUSAL_DECOMPOSITION=READY_FOR_WINDOW_03_AUDIT
PRIMARY_REFERENCE_WORLD_CHAIN=SOURCE_TRACED_WITH_EXPLICIT_UNKNOWNS
PRIMARY_REFERENCE=0_AD_ALPINE_VALLEY
WORLD_MODEL=BRANCHING_CONSTRAINT_GRAPH
WARZONE_COUNTEREXAMPLE=OBSERVED
PROCEDURAL_RMGEN_NECESSITY=REJECTED
WORLD_REPRODUCTION_CANDIDATES=IDENTIFIED
WORLD_METHOD_TRANSFER=NOT_APPROVED
WINDOW_02=HOLD
WINDOW_03_AUDIT_INPUT=READY
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

Window 01 does not self-approve these methods. The required next route remains:

`01 WORLD CAUSAL DECOMPOSITION -> 03 WORLD METHOD AUDIT -> (only if PASS) 02 ISOLATED WORLD REPRODUCTION`
