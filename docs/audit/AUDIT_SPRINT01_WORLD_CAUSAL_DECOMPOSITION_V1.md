# FRONTLINE — SPRINT 01 WORLD CAUSAL DECOMPOSITION INDEPENDENT AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_SPRINT01_WORLD_CAUSAL_DECOMPOSITION_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
AUDITED_WINDOW01_COMMIT=dcd891d7947e0ec6b97257681f258ecf6432c037
ROUTING_TASK_COMMIT=17f1b1a6dc3f43fd208adbf909aa554e34f547ea
INPUT_ARTIFACT=docs/learning/sprint01/WORLD_CAUSAL_DECOMPOSITION.md
AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

WINDOW_03_WORLD_METHOD_AUDIT=PASS_WITH_DOWNGRADES
BLOCKING_DEFECTS=0
NONBLOCKING_DEFECTS=2
VERSION_IDENTITY_VERDICT=PASS_EXACT_R28_IDENTITY_UNKNOWN_RETAINED
WORLD_CAUSAL_MODEL_VERDICT=PASS_WITH_W10_LOADER_BRIDGE_NOT_SOURCE_CLOSED
REPRODUCTION_CANDIDATES_VERDICT=PASS_WITH_W-C1_DOWNGRADE
WINDOW_02_ROUTING=READY_FOR_02_WORLD_REPRODUCTION
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This audit does not approve a FRONTLINE product world-production architecture. It approves a bounded set of methods for one more isolated learning reproduction after narrowing two claims whose wording exceeds the independently verified evidence.

---

# 1. Audit contract result

```text
PRIMARY_SOURCE_INTEGRITY=PASS
VERSION_IDENTITY=PASS_WITH_EXPLICIT_UNKNOWN
RUNTIME_SEMANTICS=PASS_WITH_W10_DOWNGRADE
GENERALIZATION_BOUNDARY=PASS_WITH_W-C1_DOWNGRADE
ALTERNATIVE_EXPLANATIONS=PASS
COUNTEREXAMPLE_SEARCH=PASS
```

No secondary article was found masquerading as source-code evidence in the audited world-method artifact. The core 0 A.D. claims cite exact source paths at an exact inspected commit, and the Warzone counterexample cites a pinned source revision.

The exact authoritative relation:

```text
official 0 A.D. Release 28 package/tag/tree -> a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
```

remains unclosed. Window 01 correctly records only:

```text
INSPECTED_SOURCE_STATE=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
```

and does not use archived GitHub `master` as proof of current or exact packaged R28 source.

---

# 2. Version identity

## V01 — inspected 0 A.D. source state

ORIGINAL_CLAIM=The audited world facts are observations of 0 A.D. source state `a2cae4d...`, with only an inferred relation to Release 28.
CHAIN_LAYER_OR_EDGE=SOURCE_VERSION_IDENTITY
SOURCE_FACT=Commit `a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d` exists and contains 0.28.0/Release-28 metadata, but its commit message is `Update appdata for next RC`.
SOURCE_LOCATION=0ad/0ad commit a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=Not applicable to version identity.
WINDOW_01_CONCLUSION=RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
HIDDEN_ASSUMPTIONS=None required if the exact Release-28 identity remains explicitly unproven.
ALTERNATIVE_EXPLANATION=The inspected state can be an RC-adjacent/cherry-picked state that is extremely close to Release 28 without being the exact authoritative packaged/tagged release tree.
COUNTEREXAMPLE_SEARCH=Not applicable.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=All source facts are facts about the inspected `a2cae4d...` state. Exact authoritative R28 identity remains UNKNOWN.

VERSION_IDENTITY_VERDICT=PASS_EXACT_R28_IDENTITY_UNKNOWN_RETAINED

---

# 3. Terrain and movement topology

## W01 — elevation is authoritative world data

ORIGINAL_CLAIM=Alpine Valley builds a height-bearing RandomMap and changes elevation through mountain, hill and bump generation.
CHAIN_LAYER_OR_EDGE=TERRAIN -> WORLD_DATA
SOURCE_FACT=`RandomMap` explicitly owns a height grid, texture grid and entity data; `Alpine Valley` creates a `RandomMap`, paints mountain/hill elevation, and later paints surfaces from height bands.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/rmgen/RandomMap.js`; `binaries/data/mods/public/maps/random/alpine_valley.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=Height is exported by `RandomMap.MakeExportable()` as terrain data rather than existing only as presentation geometry.
WINDOW_01_CONCLUSION=Topology/elevation is authoritative world data, not only a visual mesh effect.
HIDDEN_ASSUMPTIONS=No assumption is needed for the project-specific fact. Transfer to FRONTLINE still requires reproduction.
ALTERNATIVE_EXPLANATION=A fixed authored heightmap can provide the same authoritative topology without procedural mountain generation.
COUNTEREXAMPLE_SEARCH=Warzone fixed map formats.
COUNTEREXAMPLE_RESULT=Warzone demonstrates that procedural rmgen is not necessary for authoritative height/topology data.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=In the inspected 0 A.D. route, terrain elevation is exported world data and participates in gameplay-relevant terrain state. This does not require procedural generation in FRONTLINE.

## W02 — passage preservation

ORIGINAL_CLAIM=MountainRangeBuilder protects gaps and avoids mountain cycles that completely enclose territory.
CHAIN_LAYER_OR_EDGE=TERRAIN_TO_MOVEMENT_CONTINUITY
SOURCE_FACT=`minDistance = mountainWidth + passageWidth`; invalid candidate edges are removed when they intersect or leave insufficient geometric distance; cycle checking is explicitly documented as preventing territory enclosed by mountain ranges.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/alpine_valley.js`, `MountainRangeBuilder`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=This is generation-time topology logic. It does not itself prove that every protected geometric gap is pathfinder-passable for every unit class or tactically desirable.
WINDOW_01_CONCLUSION=Movement-space continuity is an explicit generation constraint; tactical intent for each passage remains unproven.
HIDDEN_ASSUMPTIONS=Treating `passageWidth` as a designed combat chokepoint width would require evidence not present here.
ALTERNATIVE_EXPLANATION=The rule can primarily be a playability/failure-prevention constraint rather than deliberate tactical optimization.
COUNTEREXAMPLE_SEARCH=Warzone fixed authored maps can preserve movement continuity without this graph algorithm.
COUNTEREXAMPLE_RESULT=The exact algorithm is project-specific; preserving usable movement topology can be achieved differently.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=The inspected generator explicitly protects geometric passage space and avoids fully enclosing mountain cycles. Do not call those gaps roads or intentional combat chokepoints without additional evidence.

MAPWIDE_ROAD_NETWORK_IN_SELECTED_REFERENCE=UNKNOWN_RETAINED
BRIDGE_FORD_PRODUCTION_CHAIN=UNKNOWN_RETAINED
TACTICAL_INTENT_FOR_EVERY_PASSAGE=UNKNOWN_RETAINED

---

# 4. Local road surface and functional anchors

## W03 — CityPatch is local, not a map-wide road-network proof

ORIGINAL_CLAIM=Alpine Valley's CityPatch attaches road/city terrain to player-base placement.
CHAIN_LAYER_OR_EDGE=FUNCTIONAL_ANCHOR -> LOCAL_BUILT_SURFACE
SOURCE_FACT=`placePlayerBases` receives `CityPatch` with `roadWild` and `road`; `placePlayerBaseCityPatch()` paints a clump centered on `playerPosition`.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen-common/player.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The road/city surface is placed by a base-generation function around a local anchor. No cited caller produces a long-distance inter-settlement transport network.
WINDOW_01_CONCLUSION=The source proves local anchor-relative surface treatment, not a map-wide road graph.
HIDDEN_ASSUMPTIONS=Calling this a road network would conflate a local material patch with connectivity/transport structure.
ALTERNATIVE_EXPLANATION=Another project can author roads with splines, masks or fixed map content independent of player-base generation.
COUNTEREXAMPLE_SEARCH=Warzone fixed map package provides a materially different authoring boundary.
COUNTEREXAMPLE_RESULT=No universal CityPatch/base-derived-road rule survives.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=Alpine Valley attaches a local road/city material patch to player-base placement. Map-wide road-network causality remains UNKNOWN.

## W04 — built content shares an anchor

ORIGINAL_CLAIM=Starting entities and several resource/decorative placement functions share the player-base anchor.
CHAIN_LAYER_OR_EDGE=ANCHOR -> BUILT_CONTENT_AND_LOCAL_RESOURCES
SOURCE_FACT=`placePlayerBase()` places starting entities at `playerPosition`, marks the civic-center area, forms resource constraints, then dispatches configured CityPatch/Trees/Mines/Berries/StartingAnimal/Decoratives functions with the same upstream player position.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/rmgen-common/player.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The anchor is a generation-time data dependency; it is not evidence that modern tactical worlds should use player starts as their primary anchors.
WINDOW_01_CONCLUSION=Explicit functional anchors are a reproduction candidate, with FRONTLINE-specific anchor types left open.
HIDDEN_ASSUMPTIONS=The same anchoring principle may not imply the same anchor semantics, morphology or placement sequence in FRONTLINE.
ALTERNATIVE_EXPLANATION=Modern tactical maps may use roads, bridges, compounds, terrain objectives or mission positions as anchors rather than bases.
COUNTEREXAMPLE_SEARCH=Warzone and fixed-authored maps demonstrate different map organization mechanisms.
COUNTEREXAMPLE_RESULT=Anchor-relative placement remains a candidate pattern, not a required RTS architecture.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=The selected 0 A.D. base route uses a functional anchor for related local content. A FRONTLINE reproduction may test an equivalent principle using a FRONTLINE-appropriate anchor without copying player-base structure.

---

# 5. Constraint layers and vegetation

## W05 — semantic spatial constraints

ORIGINAL_CLAIM=Alpine Valley uses tile classes and explicit avoidance distances to constrain later content placement.
CHAIN_LAYER_OR_EDGE=SEMANTIC_SPATIAL_STATE -> CONTENT_PLACEMENT
SOURCE_FACT=The map creates classes for players, hills, forest, dirt, rock, metal, food and base resources, and later passes those classes to `avoidClasses(...)` and TileClass painters.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/alpine_valley.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=These are generation constraints and metadata used by later placement calls. They do not establish a universal land-use representation.
WINDOW_01_CONCLUSION=Named spatial constraints are a reproduction candidate; exact tile-class API is not transferred.
HIDDEN_ASSUMPTIONS=Equating tile classes with realistic parcels/zoning would exceed the source.
ALTERNATIVE_EXPLANATION=Equivalent organization can be encoded as masks, layers, splines, prefabs, navigation volumes or hand-authored level-design data.
COUNTEREXAMPLE_SEARCH=Warzone fixed map representation.
COUNTEREXAMPLE_RESULT=Different mature representations exist; exact tile-class architecture is not necessary.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=The selected map uses named spatial classes and avoidance constraints to prevent independent arbitrary scatter. The reproduction may test equivalent named constraints without adopting the same API.

## W06 — vegetation patches and stragglers

ORIGINAL_CLAIM=Alpine Valley builds forest areas with associated forest-floor terrain and separately adds straggler trees under constraints.
CHAIN_LAYER_OR_EDGE=VEGETATION_REGION -> SURFACE_AND_OBJECT_DISTRIBUTION
SOURCE_FACT=Forest areas use layered forest-floor/tree terrain and `clForest`; later `createStragglerTrees` runs under a separate avoidance constraint.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmbiome/alpine/late_spring.json`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The source proves distribution and placement structure, not complete LOS/concealment/cover semantics.
WINDOW_01_CONCLUSION=Coherent vegetation region + transition/ground surface + sparse stragglers is a reproduction candidate; tactical cover remains separate.
HIDDEN_ASSUMPTIONS=Visual grouping cannot be promoted to a specific cover/LOS mechanic without tracing entity obstruction/range semantics.
ALTERNATIVE_EXPLANATION=The distribution can primarily serve resources, collision spacing and visual coherence rather than tactical concealment.
COUNTEREXAMPLE_SEARCH=No stronger counterexample is needed because no necessity claim is made.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=Vegetation distribution structure is source-observed. LOS/concealment/cover effects remain UNKNOWN until separately traced or reproduced.

VEGETATION_LOS_CONCEALMENT_SEMANTICS=UNKNOWN_RETAINED

---

# 6. Topology -> passability runtime semantics

## W07 — actual pathfinder consumption of terrain state

ORIGINAL_CLAIM=Terrain height, water/depth, slope and shore distance feed 0 A.D. terrain passability; obstruction data is then combined into the pathfinding grid.
CHAIN_LAYER_OR_EDGE=WORLD_TO_SIMULATION_PASSABILITY
SOURCE_FACT=`CCmpPathfinder::TerrainUpdateHelper()` samples exact ground height, water, depth, slope and shore distance for navcells and calls `PathfinderPassability::IsPassable`; `UpdateGrid()` copies the terrain grid, rasterizes obstructions and updates long-range/hierarchical pathfinders.
SOURCE_LOCATION=`source/simulation2/components/CCmpPathfinder.cpp`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=This is a direct engine data-flow path from terrain/world properties to the pathfinding representation. It does not prove Alpine-specific per-unit results without passability-class/runtime inspection.
WINDOW_01_CONCLUSION=World geometry/topology must be tested against the movement/navigation representation rather than judged from a screenshot.
HIDDEN_ASSUMPTIONS=Turning this into a universal engine architecture would be unsupported; the reproduction recommendation is a test boundary, not a source fact about all RTS games.
ALTERNATIVE_EXPLANATION=Other engines may bake navmeshes, use layered movement graphs or authored cost fields instead of 0 A.D.'s navcell grid.
COUNTEREXAMPLE_SEARCH=Warzone already demonstrates materially different world representation; no claim requires identical pathfinder internals.
COUNTEREXAMPLE_RESULT=The functional relation survives as a reproduction concern, not as an API/architecture rule.
GENERALIZATION_LEVEL=DESIGN_RECOMMENDATION
VERDICT=PASS
ALLOWED_FINAL_WORDING=For the isolated FRONTLINE reproduction, verify that authored world topology produces the intended movement/reachability consequences in the actual Godot navigation/movement representation; do not infer this from appearance alone.

---

# 7. Surface/material content route

## W08 — semantic terrain roles -> concrete terrain tags

ORIGINAL_CLAIM=The alpine biome maps semantic surface roles to concrete terrain/actor tags and the map uses those roles contextually.
CHAIN_LAYER_OR_EDGE=WORLD_SEMANTICS -> MATERIAL_ASSET_IDENTITY
SOURCE_FACT=`late_spring.json` defines concrete tags for mainTerrain, forestFloor, cliff, tier2Terrain, halfSnow, snowLimited, dirt, road, water and shore, plus Gaia/decorative actor identities. Alpine Valley applies these through height and constrained-area logic.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/rmbiome/alpine/late_spring.json`; `binaries/data/mods/public/maps/random/alpine_valley.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The tags are stored in exported terrain texture data; this does not establish FRONTLINE PBR/material-layering quality.
WINDOW_01_CONCLUSION=Separate where/why a surface occurs from which material asset represents it; reproduce the relation, not the exact 0 A.D. API.
HIDDEN_ASSUMPTIONS=Semantic tags alone do not guarantee visual quality, scale, blending quality or photorealism.
ALTERNATIVE_EXPLANATION=Other engines can encode the same separation through splat maps, landscape layers, material IDs, virtual textures or authored masks.
COUNTEREXAMPLE_SEARCH=Warzone uses map texture/terrain-type files under a different authoring/storage system.
COUNTEREXAMPLE_RESULT=Exact representation is not universal.
GENERALIZATION_LEVEL=DESIGN_RECOMMENDATION
VERDICT=PASS
ALLOWED_FINAL_WORDING=Test context-sensitive surface roles with real provenance-recorded Godot materials/assets. Do not treat 0 A.D.'s terrain-tag mechanism as a required implementation.

## W09 — terrain tags have an engine texture route

ORIGINAL_CLAIM=0 A.D.'s terrain texture manager loads terrain assets and resolves texture tags; GameView initiates terrain-texture loading.
CHAIN_LAYER_OR_EDGE=MATERIAL_IDENTITY -> ENGINE_TEXTURE_CONTENT
SOURCE_FACT=`CTerrainTextureManager` loads from `art/terrains/`, resolves tags through `FindTexture`, loads XML terrain data and alpha-map blending resources; `CGameView::RegisterInit()` starts and polls terrain texture loading.
SOURCE_LOCATION=`source/graphics/TerrainTextureManager.cpp`; `source/graphics/GameView.cpp`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=This proves an engine content route for terrain texture identities. It does not prove chosen texture quality or direct Godot equivalence.
WINDOW_01_CONCLUSION=Surface names are not prose-only labels; they participate in an engine terrain-content route.
HIDDEN_ASSUMPTIONS=None for that narrow statement.
ALTERNATIVE_EXPLANATION=Different engines resolve terrain material identities through different systems.
COUNTEREXAMPLE_SEARCH=Not required for the narrow source fact.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=The inspected project resolves generated terrain texture identities through an actual engine terrain-texture manager. The reproduction should validate its own Godot material route independently.

---

# 8. Environment and camera

## W10 — environment is explicit exported state

ORIGINAL_CLAIM=Alpine Valley explicitly sets sky/sun values and RandomMap exports Environment.
CHAIN_LAYER_OR_EDGE=WORLD_GENERATION -> ENVIRONMENT_PRESENTATION_STATE
SOURCE_FACT=Alpine Valley calls `setSkySet`, `setSunRotation` and `setSunElevation`; `RandomMap.MakeExportable()` includes `Environment: g_Environment`.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/alpine_valley.js`; `binaries/data/mods/public/maps/random/rmgen/RandomMap.js`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The source proves map-exported environment state, not that the random choices were optimized for tactical readability.
WINDOW_01_CONCLUSION=Environment/lighting should be included in reproduction acceptance, while exact FRONTLINE values remain unapproved.
HIDDEN_ASSUMPTIONS=Assuming the source values are deliberate readability optimization would be unsupported.
ALTERNATIVE_EXPLANATION=The environment variation may primarily provide theme/variation.
COUNTEREXAMPLE_SEARCH=No necessity claim about exact lighting system is made.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=DESIGN_RECOMMENDATION
VERDICT=PASS
ALLOWED_FINAL_WORDING=Treat lighting/environment as part of the reproduction state to be judged with materials and camera. Do not copy 0 A.D. values as a FRONTLINE rule.

## W11 — global camera envelope

ORIGINAL_CLAIM=The inspected runtime camera is bounded/configurable and the cited values are game-wide rather than Alpine-specific.
CHAIN_LAYER_OR_EDGE=CAMERA -> RENDER_ACCEPTANCE
SOURCE_FACT=`CameraController::LoadConfig()` reads camera movement/pitch/zoom/near/far/FOV configuration; `default.cfg` defines rotate.x 28–60 degrees with 35 default, zoom 50–200 with 120 default, near 2, far 4096 and FOV 45.
SOURCE_LOCATION=`source/graphics/CameraController.cpp`; `binaries/data/config/default.cfg`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=These settings define game-wide camera behavior. They are not generated from Alpine Valley and do not prove a map-specific composition.
WINDOW_01_CONCLUSION=Judge the reproduction through an intended command-camera envelope rather than a free cinematic/editor view.
HIDDEN_ASSUMPTIONS=Freezing a reproduction acceptance camera is a Window-01 recommendation, not a source-coded 0 A.D. production law.
ALTERNATIVE_EXPLANATION=Camera limits can be interaction/usability infrastructure shared by all maps rather than an authoring dependency of one map.
COUNTEREXAMPLE_SEARCH=No universal exact-camera claim is made.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=DESIGN_RECOMMENDATION
VERDICT=PASS
ALLOWED_FINAL_WORDING=For the isolated reproduction, define an intended player command-camera envelope and use it for acceptance captures. This is a reproduction test method, not an observed Alpine Valley authoring sequence.

ALPINE_SPECIFIC_CAMERA_COMPOSITION=UNKNOWN_RETAINED

---

# 9. Render boundary and the unclosed loader bridge

## W12 — GameView render submission endpoint

ORIGINAL_CLAIM=GameView assigns runtime view/cull cameras, frustum-tests terrain patches, submits visible terrain and asks simulation components to render-submit their content.
CHAIN_LAYER_OR_EDGE=RUNTIME_WORLD -> RENDER_SUBMISSION
SOURCE_FACT=`CGameView::BeginFrame()` sets scene cameras; `EnumerateObjects()` reads `World()->GetTerrain()`, frustum-tests patch bounds and submits patches, then calls simulation `RenderSubmit`.
SOURCE_LOCATION=`source/graphics/GameView.cpp`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=This is a genuine renderer-submission endpoint from already-loaded runtime terrain and simulation state.
WINDOW_01_CONCLUSION=World and camera meet a concrete render-submission path.
HIDDEN_ASSUMPTIONS=None for the endpoint itself.
ALTERNATIVE_EXPLANATION=Renderer submission establishes technical visibility eligibility, not player readability or aesthetic quality.
COUNTEREXAMPLE_SEARCH=Not required for endpoint fact.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
ALLOWED_FINAL_WORDING=The inspected runtime world has a concrete terrain/simulation render-submission endpoint under the runtime camera. Player readability remains a separate runtime visual gate.

## W13 — exported random-map data -> loaded runtime world -> renderer

ORIGINAL_CLAIM=`RandomMap.MakeExportable()` plus engine-side `GameView` establish a concrete source route from generated world representation all the way to renderer submission.
CHAIN_LAYER_OR_EDGE=GENERATED_WORLD_EXPORT -> ENGINE_WORLD_LOAD -> RENDER_SUBMISSION
SOURCE_FACT=The audit independently confirmed both endpoints: RandomMap exports entities/height/terrain texture data/Camera/Environment; GameView renders already-loaded `CTerrain` and simulation state.
SOURCE_LOCATION=`binaries/data/mods/public/maps/random/rmgen/RandomMap.js`; `source/graphics/GameView.cpp`
PROJECT=0_A.D.
VERSION_TAG_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The cited Window-01 evidence does not trace the intermediate loader/data-flow bridge that consumes the generated export and creates/populates the runtime `CWorld`/`CTerrain`/simulation state later read by GameView.
WINDOW_01_CONCLUSION=ALPINE_VALLEY_SOURCE_TO_RENDER_SUBMISSION=OBSERVED
HIDDEN_ASSUMPTIONS=That endpoint A's exported representation is necessarily the exact caller/data source that populates endpoint B's runtime objects through an untraced loader chain.
ALTERNATIVE_EXPLANATION=Additional serialization, conversion, map-loader, cache, scenario or engine initialization paths may mediate/transform the exported representation before runtime render submission.
COUNTEREXAMPLE_SEARCH=Not required to establish this missing internal bridge.
COUNTEREXAMPLE_RESULT=NONE_REQUIRED
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=The random-map export endpoint and runtime render-submission endpoint are independently source-observed. The exact generated-export -> engine-world-loader -> runtime terrain/simulation bridge is not source-closed in this Stage-4 trace and remains UNKNOWN.

RANDOM_MAP_EXPORT_ENDPOINT=PASS
RUNTIME_WORLD_RENDER_SUBMISSION_ENDPOINT=PASS
EXPORT_TO_RUNTIME_WORLD_LOADER_BRIDGE=UNKNOWN
ALPINE_VALLEY_PLAYER_VISIBLE_QUALITY=UNKNOWN_RETAINED

This downgrade is nonblocking for the next isolated world reproduction because Window 02 does not need to copy 0 A.D.'s loader architecture. It must not, however, cite Stage 4 as a fully caller/data-flow-closed 0 A.D. export-to-render chain.

---

# 10. Warzone counterexample

## W14 — fixed maps and script-generated maps coexist

ORIGINAL_CLAIM=Warzone 2100 materially falsifies the necessity of 0 A.D.-style procedural rmgen for mature RTS world production.
CHAIN_LAYER_OR_EDGE=CROSS_PROJECT_WORLD_AUTHORING_COUNTEREXAMPLE
SOURCE_FACT=At pinned Warzone commit `b0288082...`, `lib/wzmaplib/README.md` documents classic/fixed map packages where `game.map` contains tile texture, height and gateway information, `ttypes.ttp` maps textures to simulation-affecting terrain types, and separate files hold initial map entities; it also documents WZ 4.0+ script-generated maps using `game.js`.
SOURCE_LOCATION=`Warzone2100/warzone2100/lib/wzmaplib/README.md`
PROJECT=WARZONE_2100
VERSION_TAG_COMMIT=b0288082c54536ae3634a6a71b0e03f0d82bb8f3
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=This primary repository documentation describes supported map-loading formats and their gameplay-relevant data. It is sufficient to falsify necessity of one procedural authoring boundary, though it does not close one Warzone map's renderer chain.
WINDOW_01_CONCLUSION=0 A.D.-style procedural rmgen is not a necessary mature-RTS world-production architecture.
HIDDEN_ASSUMPTIONS=None beyond treating supported mature map formats as an architecture counterexample.
ALTERNATIVE_EXPLANATION=Differences can arise from engine age, tools and gameplay. Those differences reinforce rather than weaken the conclusion that the 0 A.D. method is not universal.
COUNTEREXAMPLE_SEARCH=Warzone 2100
COUNTEREXAMPLE_RESULT=MATERIAL_COUNTEREXAMPLE_FOUND
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN
VERDICT=PASS
ALLOWED_FINAL_WORDING=Warzone supports mature fixed/authored map packages as well as script-generated maps, so 0 A.D.-style rmgen is not required for mature RTS world production.

WARZONE_COMPLETE_RENDERER_TRACE=UNKNOWN_RETAINED
BAR_RECOIL_COMPLETE_WORLD_PIPELINE=UNKNOWN_RETAINED
BAR_RECOIL_ADDITIONAL_COUNTEREXAMPLE_REQUIRED=NO_FOR_CURRENT_NECESSITY_CLAIM

---

# 11. Narrow cross-project pattern

## W15 — playable world data carries gameplay consequences

ORIGINAL_CLAIM=Across inspected 0 A.D. and Warzone representations, world content carries more than appearance while exact storage/authoring mechanisms differ.
CHAIN_LAYER_OR_EDGE=WORLD_DATA -> GAMEPLAY_CONSEQUENCE
SOURCE_FACT=0 A.D. terrain height/water/slope/obstruction state is consumed by pathfinding; Warzone map formats explicitly carry height/gateway information and terrain-type mapping that its repository documentation says affects simulation behavior.
SOURCE_LOCATION=0 A.D. sources above; Warzone `lib/wzmaplib/README.md`
PROJECT=0_A.D.; WARZONE_2100
VERSION_TAG_COMMIT=a2cae4d69f...; b0288082...
SOURCE_TYPE=SOURCE_CODE
RUNTIME_SEMANTICS=The functional pattern is present across materially different representations. It does not establish one required schema or authoring pipeline.
WINDOW_01_CONCLUSION=FRONTLINE reproduction should connect visible world construction to actual movement/tactical state rather than maintain unrelated gameplay and visual spaces.
HIDDEN_ASSUMPTIONS=The reproduction recommendation still needs Godot-specific testing and does not become a product law from two projects alone.
ALTERNATIVE_EXPLANATION=This broad pattern may arise from the basic requirement that real-time games represent where entities can exist and move.
COUNTEREXAMPLE_SEARCH=Warzone materially differs in authoring/storage mechanism.
COUNTEREXAMPLE_RESULT=Pattern survives at functional level while architecture-specific claims fail.
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN
VERDICT=PASS
ALLOWED_FINAL_WORDING=Multiple mature implementations show gameplay-relevant world data under different storage/authoring systems. For the learning reproduction, visual world and movement/tactical representation should be tested as one causal system.

---

# 12. Reproduction candidate audit W-C1..W-C7

## W-C1 — Topology before decoration

WINDOW_01_METHOD=Author real terrain/elevation and explicit traversable corridors/crossings before placing decorative world content.
VERDICT=DOWNGRADE

Independent counterevidence:

`Alpine Valley.generateMap()` calls `placePlayerBases()` before constructing `MountainRangeBuilder`. `placePlayerBases()` can already place starting entities, CityPatch, trees, mines, berries and decoratives. Therefore the selected source does not prove a strict execution/authoring rule that all topology precedes all decorative or built content.

The useful underlying evidence survives:

- terrain/elevation is authoritative world data;
- passage preservation is explicit generation logic;
- terrain/world properties feed actual passability;
- route reachability/clearance must be tested rather than inferred visually.

ALLOWED_METHOD_FOR_02=`Authoritative topology/passability and intended corridor clearance must be explicit and verified against the movement representation before final world/visual acceptance. Do not interpret this as a requirement that every terrain/topology operation execute before every built/decorative placement.`

## W-C2 — Functional anchors drive local built content

WINDOW_01_METHOD=Choose functional/tactical anchors and place related local built content/surfaces relative to them.
VERDICT=PASS_FOR_REPRODUCTION

Evidence is sufficient as a bounded candidate. Window 02 must use an independently justified FRONTLINE-appropriate anchor such as a junction, bridge, compound or objective; it must not copy 0 A.D. player-base semantics or coordinates.

## W-C3 — Constraint layers control overlap

WINDOW_01_METHOD=Use named spatial masks/classes/volumes and explicit spacing/avoidance rules for routes, barriers, settlements and vegetation.
VERDICT=PASS_FOR_REPRODUCTION

The principle is directly grounded in 0 A.D. source and does not require adopting its tile-class implementation. Window 02 must demonstrate route clearance and absence of arbitrary content overlap in the resulting runtime world.

## W-C4 — Surface material follows landform/function

WINDOW_01_METHOD=Separate semantic surface role from material asset identity and bind real material/content according to terrain/function.
VERDICT=PASS_FOR_REPRODUCTION

The 0 A.D. source supports semantic terrain roles feeding real texture identities. Window 02 must use provenance-recorded Godot material/content routes and evaluate the player result; no claim is made that the 0 A.D. material system itself transfers.

## W-C5 — Vegetation regions plus stragglers

WINDOW_01_METHOD=Use coherent constrained vegetation patches with associated/transition surfaces, plus separate sparse stragglers.
VERDICT=PASS_FOR_REPRODUCTION

The distribution structure is source-supported. Navigation, LOS and cover must be measured/observed separately; the candidate does not import unproven tactical-cover semantics.

## W-C6 — Environment and command camera are acceptance inputs

WINDOW_01_METHOD=Define/freeze a reproduction camera envelope and lighting/environment state before judging player readability.
VERDICT=PASS_FOR_REPRODUCTION

This is accepted as a reproduction acceptance methodology, not as an observed Alpine Valley authoring rule or universal RTS law. The actual Godot camera/environment values remain a Window-02 reproduction choice subject to player-layer evidence.

## W-C7 — Reuse sanctioned real assets, not old coordinates

WINDOW_01_METHOD=Use the already-audited real asset/provenance pool where appropriate, while placing it through newly tested world rules rather than restoring Golden Scene/River Town/Reference Region coordinates.
VERDICT=PASS_FOR_REPRODUCTION

This candidate is principally a FRONTLINE evidence/governance constraint backed by the existing Sprint-01 asset gate, not a 0 A.D./Warzone source fact. It is valid for the isolated reproduction because it preserves exact real-asset provenance while preventing old-scene coordinate restoration from masquerading as learned world production.

Candidate summary:

```text
W-C1=DOWNGRADE
W-C2=PASS_FOR_REPRODUCTION
W-C3=PASS_FOR_REPRODUCTION
W-C4=PASS_FOR_REPRODUCTION
W-C5=PASS_FOR_REPRODUCTION
W-C6=PASS_FOR_REPRODUCTION
W-C7=PASS_FOR_REPRODUCTION
```

REPRODUCTION_CANDIDATES_VERDICT=PASS_WITH_W-C1_DOWNGRADE

---

# 13. Preserved UNKNOWN set

The following must remain UNKNOWN after this audit:

```text
U-WORLD-VERSION-IDENTITY=UNKNOWN
U-WORLD-ROAD-NETWORK=UNKNOWN
U-WORLD-CROSSINGS=UNKNOWN
U-WORLD-VEGETATION-LOS=UNKNOWN
U-WORLD-TACTICAL-INTENT=UNKNOWN
U-WORLD-ALPINE-CAMERA=UNKNOWN
U-WORLD-PLAYER-RESULT=UNKNOWN
U-WORLD-WARZONE-RENDER=UNKNOWN
U-WORLD-BAR-PIPELINE=UNKNOWN
U-WORLD-EXPORT-TO-RUNTIME-LOADER-BRIDGE=UNKNOWN
U-WORLD-FRONTLINE-REPRODUCTION=UNKNOWN_UNTIL_WINDOW02_RUNTIME
U-WORLD-FRONTLINE-TRANSFER=UNKNOWN_NOT_APPROVED
```

Window 02 must not fill these unknowns with plausible prose or reuse old Golden Scene evidence.

---

# 14. Required Window-02 reproduction boundary

WINDOW_02_ROUTING=READY_FOR_02_WORLD_REPRODUCTION

This routing authorizes only an isolated learning reproduction. It does not authorize product production and does not approve any candidate as a permanent FRONTLINE architecture.

Window 02 must:

1. preserve the already proven player/gameplay causal semantics rather than redesign combat;
2. apply the corrected W-C1 wording: authoritative topology/passability + route-clearance verification before final acceptance, not a false strict source ordering;
3. choose explicit functional anchors without copying Alpine Valley player-base coordinates;
4. use explicit constraint layers/masks/volumes to protect routes and prevent arbitrary overlaps;
5. use real provenance-recorded world/material/vegetation assets or content pipelines; no Box/Plane/color-block environment as final delivery;
6. bind surfaces according to landform/function rather than one global flat material;
7. create vegetation regions plus sparse exceptions while testing navigation/LOS separately;
8. define the Godot player command-camera and environment state used for acceptance;
9. reuse sanctioned real assets without restoring old Golden Scene/River Town/Reference Region coordinates;
10. test actual reachability, route clearance, blocking, unit/world scale, material coherence, vegetation readability and player-camera presentation in fresh Godot 4.7.1 runtime;
11. return fresh screenshots/video/runtime evidence to Window 03;
12. not claim that Stage 4 closed the 0 A.D. export-to-runtime loader bridge; that bridge remains UNKNOWN.

Required player-layer evidence remains the deciding gate. A source-correct or procedurally generated world is not sufficient by itself.

---

# 15. Final verdict

```text
WINDOW_03_WORLD_METHOD_AUDIT=PASS_WITH_DOWNGRADES
BLOCKING_DEFECTS=0
NONBLOCKING_DEFECTS=2

PRIMARY_SOURCE_INTEGRITY=PASS
VERSION_IDENTITY_VERDICT=PASS_EXACT_R28_IDENTITY_UNKNOWN_RETAINED
RUNTIME_SEMANTICS=PASS_WITH_W10_DOWNGRADE
GENERALIZATION_BOUNDARY=PASS_WITH_W-C1_DOWNGRADE
ALTERNATIVE_EXPLANATIONS=PASS
COUNTEREXAMPLE_SEARCH=PASS

WORLD_CAUSAL_MODEL_VERDICT=PASS_WITH_W10_LOADER_BRIDGE_NOT_SOURCE_CLOSED
REPRODUCTION_CANDIDATES_VERDICT=PASS_WITH_W-C1_DOWNGRADE

W-C1=DOWNGRADE
W-C2=PASS_FOR_REPRODUCTION
W-C3=PASS_FOR_REPRODUCTION
W-C4=PASS_FOR_REPRODUCTION
W-C5=PASS_FOR_REPRODUCTION
W-C6=PASS_FOR_REPRODUCTION
W-C7=PASS_FOR_REPRODUCTION

WINDOW_02_ROUTING=READY_FOR_02_WORLD_REPRODUCTION
WINDOW_01=HOLD
WINDOW_03=HOLD_AFTER_AUDIT
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

The Stage-4 method is sufficiently grounded to test in Window 02 after the two downgrades above. Its success in FRONTLINE remains UNKNOWN until a fresh isolated world reproduction is run and independently falsified at the PLAYER layer.
