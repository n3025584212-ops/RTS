# Learning Sprint 01 — Evidence Register

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-13
PRIMARY_REFERENCE=0_AD_RELEASE_28
PRIMARY_REFERENCE_VERSION=v0.28.0
PRIMARY_REFERENCE_COMMIT_ANCHOR=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
FRONTLINE_MAIN_INSPECTED=06710c3d9e29d3400572bf25ed5e8fd96c73b472
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

This register is the current authoritative Sprint-01 evidence inventory. Earlier UNKNOWN statements that are explicitly superseded below must not be reused.

## Status vocabulary

- `OBSERVED`: directly visible in inspected source/artifact/runtime.
- `REPRODUCED`: independently recreated and verified.
- `INFERRED`: reasoned from evidence but not directly proved.
- `HYPOTHESIS`: plausible claim awaiting evidence.
- `UNKNOWN`: evidence is insufficient.
- `REJECTED`: contradicted by inspected evidence or reproduction.

`GAP` is not a status. It describes a missing/broken/unsupported project link while the claim about that gap can itself be OBSERVED.

## Evidence policy

For every major edge:

CLAIM=
CHAIN_LAYER=
EDGE=
SOURCE=
SOURCE_VERSION=
STATUS=
WHAT_THE_SOURCE_ACTUALLY_PROVES=
WHAT_IT_DOES_NOT_PROVE=
FRONTLINE_CURRENT_IMPLEMENTATION=
EXTERNAL_REFERENCE_IMPLEMENTATION=
GAP=
REPRODUCTION_REQUIRED=YES|NO

Window 03 additionally audits primary-source integrity, version identity, runtime semantics, generalization boundary, alternative explanations and counterexamples.

## Version warning

The archived GitHub `0ad/0ad` `master` branch is historical and is not used as Release-28 implementation evidence. Release-28 implementation claims below are pinned to `v0.28.0` / commit `a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d` using the official Release-28 distribution as identity anchor and a version-matched source pull mirror for file inspection.

Exact byte-for-byte identity between the official release tarballs and the inspected public pull mirror has not been independently hashed. That remains a version-provenance caveat, not permission to substitute archived `master`.

---

# A. Reference-selection and provenance evidence

## E000 — FRONTLINE technical success did not imply product-quality success

CLAIM=FRONTLINE previously imported assets, ran Godot and captured scenes while still failing user visual acceptance.
CHAIN_LAYER=ALL / PLAYER
EDGE=TECHNICAL_PIPELINE_PRESENT -> PLAYER_ACCEPTANCE
SOURCE=FRONTLINE historical Golden Scene evidence and current project state history.
SOURCE_VERSION=FRONTLINE history before CURRENT_STATE V30
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Technical runtime/capture capability and visual acceptance diverged in this project.
WHAT_IT_DOES_NOT_PROVE=The exact technical cause of each rejected visual result or the correct replacement method.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical evidence only; current product production remains paused.
EXTERNAL_REFERENCE_IMPLEMENTATION=Not applicable.
GAP=Past work cannot be treated as manufacturability proof.
REPRODUCTION_REQUIRED=NO

## E001 — Release 28 provides source and game-data distribution

CLAIM=The official 0 A.D. Release-28 source page provides separate build-source and game-data archives for 0.28.0.
CHAIN_LAYER=PROVENANCE / ALL
EDGE=RELEASE_IDENTITY -> BUILD_SOURCE + GAME_DATA
SOURCE=https://play0ad.com/download/source/
SOURCE_VERSION=Release 28 / 0.28.0
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Release 28 is inspectable as source plus game data, not merely a binary/tutorial sample.
WHAT_IT_DOES_NOT_PROVE=Any individual runtime call path.
FRONTLINE_CURRENT_IMPLEMENTATION=Not applicable.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. separates engine/build source and game data in its release distribution.
GAP=None for release availability.
REPRODUCTION_REQUIRED=NO

## E002 — Release-28 inspected implementation is version anchored

CLAIM=The first vertical trace is pinned to `v0.28.0` / commit `a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d`, not archived GitHub `master`.
CHAIN_LAYER=PROVENANCE / ALL
EDGE=RELEASE_28 -> VERSION_MATCHED_INSPECTED_FILES
SOURCE=https://play0ad.com/download/source/ ; version-matched public pull mirror tag `v0.28.0`
SOURCE_VERSION=Release 28 / v0.28.0
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=All source-file claims in section B are tied to the R28 tag rather than an unmatched branch.
WHAT_IT_DOES_NOT_PROVE=Byte-identical tarball-to-mirror equality.
FRONTLINE_CURRENT_IMPLEMENTATION=Not applicable.
EXTERNAL_REFERENCE_IMPLEMENTATION=Version-matched source/data inspection.
GAP=Byte-level archive/mirror identity not independently checked.
REPRODUCTION_REQUIRED=NO

## E003 — BAR/Recoil and Warzone remain validators, not replacements for the primary trace

CLAIM=BAR/Recoil and Warzone expose materially different engine/game scripting boundaries and are suitable counterexample sources.
CHAIN_LAYER=CROSS_PROJECT_VALIDATION
EDGE=PRIMARY_REFERENCE_CLAIM -> COUNTEREXAMPLE_POOL
SOURCE=https://recoilengine.org/ ; https://github.com/beyond-all-reason/Beyond-All-Reason ; https://github.com/Warzone2100/warzone2100
SOURCE_VERSION=inspected current public project/documentation surfaces on 2026-09-13
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The selected validators are real inspectable RTS ecosystems with different public APIs/repository boundaries.
WHAT_IT_DOES_NOT_PROVE=That any specific 0 A.D. mechanism is a cross-project RTS rule.
FRONTLINE_CURRENT_IMPLEMENTATION=No transfer decision.
EXTERNAL_REFERENCE_IMPLEMENTATION=Validator pool only at this stage.
GAP=Concrete edge-level counterexample inspection is still incomplete.
REPRODUCTION_REQUIRED=NO

---

# B. First real Release-28 vertical slice — Combat Demo

SELECTED_SLICE=`binaries/data/mods/public/maps/scenarios/combat_demo`
SELECTED_PLAYER_UNIT=`units/athen/infantry_marine_archer_e`
SLICE_STATUS=SELECTED_AND_SOURCE_TRACED

## E010 — Combat Demo map content reaches world construction and simulation entity creation

CLAIM=Release-28 Combat Demo is a concrete scenario whose `.pmp/.xml` pair is loaded through `CWorld/CMapReader`, producing terrain/environment/camera state and simulation entities.
CHAIN_LAYER=1 MAP_LOADING_AND_BATTLE_SPACE
EDGE=COMBAT_DEMO_MAP_RESOURCE -> CWorld/CMapReader -> TERRAIN/ENVIRONMENT/CAMERA + SIM_ENTITIES
SOURCE=`binaries/data/mods/public/maps/scenarios/combat_demo.xml`; `source/ps/World.cpp`; `source/graphics/MapReader.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Combat Demo contains environment/camera/entity/template data; `CWorld::RegisterInit` creates/uses `CMapReader`; map loading resolves `.pmp` plus matching `.xml`; entity template records are passed to simulation entity creation and transforms/owners are applied; environment/camera records are applied to their runtime managers/view.
WHAT_IT_DOES_NOT_PROVE=Every random/skirmish-map path, every terrain-editor authoring rule, or that FRONTLINE should use paired binary/XML maps.
FRONTLINE_CURRENT_IMPLEMENTATION=`project.godot -> Battle01.tscn -> Battle3DWorld`, where the current traced battle space is generated procedurally from script primitives/hard-coded geometry.
EXTERNAL_REFERENCE_IMPLEMENTATION=Authored scenario content is loaded into engine world/render state and simulation entities.
GAP=FRONTLINE has no current product-authoritative map-content pipeline frozen.
REPRODUCTION_REQUIRED=YES

## E011 — Combat Demo provides a concrete unit template inheritance chain

CLAIM=The selected Combat Demo elite Athenian marine archer is assembled through template inheritance/composition, not one monolithic unit-definition file.
CHAIN_LAYER=2 UNIT_DATA_SOURCE_OF_TRUTH
EDGE=MAP_ENTITY_TEMPLATE -> LEAF_TEMPLATE -> PARENT/MIXIN/GLOBAL_ARCHER_TEMPLATE -> SIMULATION_COMPONENT_DATA
SOURCE=`maps/scenarios/combat_demo.xml`; `simulation/templates/units/athen/infantry_marine_archer_e.xml`; `_a.xml`; `_b.xml`; `simulation/templates/template_unit_infantry_ranged_archer.xml` and parents/mixins referenced there.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The selected leaf template inherits/combines rank/civilization/mercenary/general archer data; the generic ranged-archer chain supplies concrete ranged attack timing/range/projectile/effect parameters and motion modifications.
WHAT_IT_DOES_NOT_PROVE=That one physical XML is the entire final unit truth or that template inheritance is universally preferable.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 uses `FormationDefinition` `.tres` resources for base stats plus scene wiring/script behavior.
EXTERNAL_REFERENCE_IMPLEMENTATION=Composed template hierarchy resolves gameplay component data.
GAP=No transfer decision; data architecture differs materially.
REPRODUCTION_REQUIRED=YES

## E012 — Selected unit gameplay data binds to a real actor/material/animation asset chain

CLAIM=The selected archer template's `VisualActor` points to an actor definition that binds concrete skeletal mesh, props, textures, animations and a material/shader-effect configuration.
CHAIN_LAYER=3 MODEL_MATERIAL_ASSET_BINDING
EDGE=UNIT_TEMPLATE.VisualActor -> ACTOR_XML -> MESH/PROPS/TEXTURES/ANIMATIONS -> MATERIAL -> SHADER_EFFECT
SOURCE=`simulation/templates/units/athen/infantry_marine_archer_e.xml`; `art/actors/units/athenians/infantry_archer_e.xml`; referenced actor/animation/mesh files; `art/materials/player_trans_norm_spec.xml`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The selected gameplay entity has an explicit production asset binding route including `.dae` mesh, actor props, base/spec/normal textures, ranged/death animations, player-color material and `model` shader effect.
WHAT_IT_DOES_NOT_PROVE=Runtime visual quality, LOD policy for every asset, GPU cost, or suitability for FRONTLINE's modern military art target.
FRONTLINE_CURRENT_IMPLEMENTATION=Current Battle01 3D formation proxies use runtime `CylinderMesh/BoxMesh` plus `StandardMaterial3D` colors instead of imported unit mesh/texture/animation bindings in this active path.
EXTERNAL_REFERENCE_IMPLEMENTATION=Data-bound reusable actor asset family.
GAP=FRONTLINE active Battle01 path lacks an equivalent real unit model→material→texture→animation production chain.
REPRODUCTION_REQUIRED=YES

## E013 — Release-28 player selection reaches `g_Selection`

CLAIM=Stock Release-28 session input resolves clicked entities and stores accepted entity IDs in `g_Selection`.
CHAIN_LAYER=4 PLAYER_SELECTION
EDGE=POINTER_INPUT -> ENTITY_PICK -> EntitySelection -> g_Selection
SOURCE=`binaries/data/mods/public/gui/session/input.js`; `gui/session/selection.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=`Engine.PickEntityAtPoint` and selection add/remove/reset calls form the stock click-selection route; selection state also drives highlight/status presentation updates.
WHAT_IT_DOES_NOT_PROVE=All selection modes or modded GUI behavior.
FRONTLINE_CURRENT_IMPLEMENTATION=`Battle3DInput` projects 3D proxies to screen space and calls `BattleSelectionController.select_only/add_to_selection`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Entity-ID selection container at GUI/session layer.
GAP=No transfer decision.
REPRODUCTION_REQUIRED=YES

## E014 — Contextual attack builds a typed command payload

CLAIM=When the stock contextual action resolves to attack, Release-28 posts a typed attack command containing selected entity IDs and target.
CHAIN_LAYER=5 COMMAND_ROUTING
EDGE=g_Selection + CLICKED_TARGET -> `Engine.PostNetworkCommand({type:'attack', ...})`
SOURCE=`gui/session/input.js`; `gui/session/unit_actions.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=GUI input/action code constructs a semantic attack command and also requests an attack-order sound.
WHAT_IT_DOES_NOT_PROVE=That every command uses identical semantics or that typed command envelopes are mandatory for RTS games.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 right-click sends MOVE/ADVANCE directly through `BattleSelectionController` to selected formations; no equivalent player ATTACK envelope is evidenced in this traced path.
EXTERNAL_REFERENCE_IMPLEMENTATION=GUI action translated to typed simulation command payload.
GAP=Architecture differs; transfer not decided.
REPRODUCTION_REQUIRED=YES

## E015 — GUI `PostNetworkCommand` to simulation `ProcessCommand` bridge is source-closed

CLAIM=Release-28 GUI `Engine.PostNetworkCommand` crosses the C++ simulation interface and command queue/turn manager before `CCmpCommandQueue::FlushTurn` invokes JS `ProcessCommand`.
CHAIN_LAYER=5 COMMAND_ROUTING
EDGE=GUI_POST -> JSInterface_Simulation::PostNetworkCommand -> ICmpCommandQueue.PostNetworkCommand -> TURN_MANAGER -> CCmpCommandQueue::FlushTurn -> ProcessCommand
SOURCE=`source/simulation2/scripting/JSInterface_Simulation.cpp`; `source/simulation2/components/CCmpCommandQueue.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The previously missing GUI-to-simulation transport edge has concrete engine-side source calls; it is not inferred from matching payload names.
WHAT_IT_DOES_NOT_PROVE=Network transport behavior under every multiplayer failure/latency case.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 player move path has no equivalent observed turn/network command queue; it mutates the local formation order through direct method calls.
EXTERNAL_REFERENCE_IMPLEMENTATION=Command passes a deterministic turn/command-queue boundary before simulation dispatch.
GAP=None for this R28 source edge; old UNKNOWN E017 is superseded.
REPRODUCTION_REQUIRED=YES

## E016 — Simulation attack command enters UnitAI

CLAIM=Release-28 `ProcessCommand` dispatches `type='attack'` through `g_Commands.attack`, which calls `cmpUnitAI.Attack(...)` for controlled entities.
CHAIN_LAYER=5 COMMAND_ROUTING / 7-8 SIMULATION_ENTRY
EDGE=ProcessCommand -> g_Commands.attack -> UnitAI.Attack
SOURCE=`binaries/data/mods/public/simulation/helpers/Commands.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The semantic command reaches UnitAI through the stock simulation dispatcher; `ProcessCommand` also pushes a `playercommand` GUI notification.
WHAT_IT_DOES_NOT_PROVE=The exact internal UnitAI FSM branch taken by every stance/formation case.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 player movement/ADVANCE routes through `SelectionController` and direct formation methods.
EXTERNAL_REFERENCE_IMPLEMENTATION=Simulation command table -> UnitAI.
GAP=The chosen event's exact `UnitAI.Attack -> movement/range closure -> Attack.StartAttacking` branch remains not directly source-closed.
REPRODUCTION_REQUIRED=YES

## E017 — Exact UnitAI order-to-fire middle branch remains unresolved

CLAIM=The first trace has not yet directly source-closed the exact `UnitAI.Attack` FSM path for the selected player-issued attack into `UnitMotion.MoveToTargetRange` and `Attack.StartAttacking`.
CHAIN_LAYER=6 PATHFINDING_AND_MOVEMENT / 7 DETECTION_TARGET / 8 FIRE
EDGE=UnitAI.Attack -> UNITAI_FSM -> UnitMotion/Attack
SOURCE=`simulation/components/tests/test_UnitAI.js` plus inspected component interfaces; direct chosen branch still pending.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=The real UnitAI test demonstrates dependencies and combat-state behavior against mocked RangeManager/UnitMotion/Vision/Attack/Health interfaces.
WHAT_IT_DOES_NOT_PROVE=The exact live source path taken from this selected command through every UnitAI state transition.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 does not have this same separation; player ADVANCE target choice is external and formation movement/combat execute in `BattleFormation`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Endpoints/contracts observed; chosen middle FSM branch not yet established.
GAP=Only remaining critical source break inside the player command→fire simulation chain.
REPRODUCTION_REQUIRED=YES

## E018 — UnitMotion reaches Pathfinder and physical position updates

CLAIM=Release-28 UnitMotion requests paths asynchronously and ultimately applies movement through Position updates.
CHAIN_LAYER=6 PATHFINDING_AND_MOVEMENT
EDGE=UnitMotion MoveTo* -> ComputePathToGoal -> Pathfinder -> MT_PathResult -> PerformMove -> Position.MoveAndTurnTo
SOURCE=`source/simulation2/components/CCmpUnitMotion.h/.cpp`; Pathfinder/path-result interfaces and movement-update source inspected at v0.28.0.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The lower movement/navigation execution chain is concrete and asynchronous; movement updates simulation position and feeds visual actor movement state.
WHAT_IT_DOES_NOT_PROVE=That the unresolved E017 UnitAI branch invokes exactly this route in every attack case.
FRONTLINE_CURRENT_IMPLEMENTATION=`BattleNavigation -> NavigationService(AStarGrid2D) -> waypoint path -> BattleFormation._update_movement -> global_position`.
EXTERNAL_REFERENCE_IMPLEMENTATION=UnitMotion/pathfinder/position component chain.
GAP=Connection from the selected `UnitAI.Attack` branch into this lower movement route remains E017 UNKNOWN.
REPRODUCTION_REQUIRED=YES

## E019 — Player-designated target legality is explicit

CLAIM=Release-28 Attack logic explicitly checks target existence/state/ownership/classes and attack range/height restrictions before an attack type is legal.
CHAIN_LAYER=7 DETECTION_AND_TARGET_SELECTION
EDGE=PLAYER_TARGET -> ATTACK_LEGALITY_FILTER -> VALID_ATTACK_TYPE
SOURCE=`binaries/data/mods/public/simulation/components/Attack.js`; corresponding Release-28 Attack component tests.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Player-designated target legality is not equivalent to merely having an entity ID; component checks constrain attackability and range.
WHAT_IT_DOES_NOT_PROVE=Automatic UnitAI target acquisition/priority for all stances.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 ADVANCE target selection requires confirmed intel, live RED target, attack range and LOS, then chooses nearest with tie handling.
EXTERNAL_REFERENCE_IMPLEMENTATION=Attack component validates target/attack type; automatic acquisition remains separate.
GAP=Automatic R28 target-acquisition/priority branch is not yet traced for this slice.
REPRODUCTION_REQUIRED=YES

## E020 — Attack launch through delayed hit is source-closed

CLAIM=Release-28 `Attack.StartAttacking/PerformAttack` configures attack animation/timing and, for ranged attacks, computes projectile parameters and schedules delayed hit processing.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE_DEATH / 11 PRESENTATION
EDGE=ATTACK_START -> ATTACK_TIMER/ANIMATION -> PROJECTILE -> SCHEDULED_DELAYED_DAMAGE -> DelayedDamage.Hit
SOURCE=`simulation/components/Attack.js`; projectile/delayed-damage calls referenced by the same v0.28.0 source.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The old launch-to-hit UNKNOWN is closed at source level: ranged launch computes target prediction/spread/speed/gravity/travel delay, launches projectile presentation data and schedules hit handling; the attack animation is selected by attack type.
WHAT_IT_DOES_NOT_PROVE=Deterministic hit or ammunition consumption. Neither is established for this reference path.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 resolves attacks synchronously after ammo/range/LOS/cooldown gates and directly applies damage; it has explicit `Ammo-1`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Ranged projectile/delayed-hit path with spread/collision behavior.
GAP=Do not transplant FRONTLINE ammo/deterministic-hit rules into the 0 A.D. reference description.
REPRODUCTION_REQUIRED=YES

## E021 — Delayed hit applies effects to Health and drives death-state behavior

CLAIM=Release-28 delayed hit calls the attack-effect helper; Damage is mapped to `IID_Health.TakeDamage`; Health source/tests demonstrate HP reduction and lethal death/corpse behavior.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE_DEATH / 10 STATE
EDGE=DelayedDamage.Hit -> AttackHelper.HandleAttackEffects -> Damage receiver -> Health -> HP/DEATH/CORPSE
SOURCE=`simulation/components/DelayedDamage.js`; `simulation/helpers/Attack.js`; `globalscripts/AttackEffects.js`; `simulation/data/attack_effects/damage.json`; `simulation/components/Health.js`; `simulation/components/tests/test_Health.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Damage effect receiver mapping and Health HP/death semantics are explicit; lethal state can create corpse/death behavior according to entity death settings.
WHAT_IT_DOES_NOT_PROVE=That every attack uses Damage rather than capture/status/splash combinations or identical death types.
FRONTLINE_CURRENT_IMPLEMENTATION=`BattleFormation.take_damage` subtracts HP and `_die` clears movement/target, changes order to DESTROYED and emits `died`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Effect receiver -> Health component -> death/corpse transition.
GAP=None for the generic Damage→Health/death source edge; selected live runtime still not reproduced.
REPRODUCTION_REQUIRED=YES

## E022 — Authoritative Health state reaches selected-unit HUD

CLAIM=Release-28 Health state is exposed through `GuiInterface.GetEntityState`, and selection-details GUI reads hitpoints/maxHitpoints to render health information.
CHAIN_LAYER=10 UI_STATE_ACQUISITION
EDGE=SIMULATION Health -> GuiInterface entity state -> selection_details UI
SOURCE=`simulation/components/Health.js`; `simulation/components/GuiInterface.js`; `gui/session/selection_details.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=For inspected health fields, GUI presentation reads simulation-exposed entity state rather than independently recomputing combat damage; Health also posts health-change messages.
WHAT_IT_DOES_NOT_PROVE=That every UI field in the game follows the same data route.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 connects selection/order/health/ammo/intel/death/victory signals/callbacks to HUD methods; HUD reads formation state for displayed HP/ammo/order values.
EXTERNAL_REFERENCE_IMPLEMENTATION=Simulation query/message -> GuiInterface -> session UI.
GAP=Runtime display correctness/quality remains a reproduction question.
REPRODUCTION_REQUIRED=YES

## E023 — Combat logic has explicit source-level animation/audio/projectile/death feedback paths

CLAIM=The selected Release-28 combat chain has source-backed attack animation, order sound, projectile presentation, impact sound and death presentation/audio paths.
CHAIN_LAYER=11 ANIMATION_VFX_AUDIO_FEEDBACK
EDGE=COMMAND/FIRE/HIT/DEATH -> ANIMATION + AUDIO + PROJECTILE/IMPACT + CORPSE/DEATH_FEEDBACK
SOURCE=`gui/session/unit_actions.js`; `simulation/components/Attack.js`; `simulation/components/DelayedDamage.js`; `simulation/components/Health.js`; selected archer actor/animation files.
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Specific feedback-generating calls/data are connected to the attack/death chain at source level.
WHAT_IT_DOES_NOT_PROVE=Their final perceptual weight, timing quality or player readability in an actual run.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 has logical shot/death timers in `BattleFormation`, but the active 3D proxy presentation path has not been shown to consume logical fire into muzzle/projectile/impact/audio feedback.
EXTERNAL_REFERENCE_IMPLEMENTATION=Logic-to-presentation hooks/data exist for selected combat event.
GAP=PLAYER-layer qualitative result still requires runtime evidence.
REPRODUCTION_REQUIRED=YES

## E024 — Visual actor state reaches render submission

CLAIM=Release-28 `CCmpVisualActor` updates the rendered unit from interpolated simulation position and `CCmpUnitRenderer` submits unit models through the scene collector under render/frustum/LOS constraints.
CHAIN_LAYER=12 CAMERA_AND_RENDER_PRESENTATION
EDGE=SIMULATION_POSITION/VISUAL_ACTOR -> UnitRenderer -> SceneCollector
SOURCE=`source/simulation2/components/CCmpVisualActor.cpp`; `source/simulation2/components/CCmpUnitRenderer.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=There is a concrete simulation visual-actor to renderer submission path; selected map camera/environment data also reaches the runtime view/managers through `CMapReader`.
WHAT_IT_DOES_NOT_PROVE=The final GPU frame quality, exact performance cost or actual Combat Demo player-visible capture.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 uses `Battle3DPresentation` proxy MeshInstance3D nodes, `Battle3DWorld` light/environment, and `BattleCamera3D` with FOV/height/pan/zoom parameters.
EXTERNAL_REFERENCE_IMPLEMENTATION=Visual actor -> renderer scene submission.
GAP=Final PLAYER result remains un-reproduced by this sprint.
REPRODUCTION_REQUIRED=YES

## E025 — Final Release-28 player-visible result is not yet reproduced by Window 01/02

CLAIM=Source inspection now connects most of the Combat Demo chain through render submission, but this sprint has not produced its own runtime capture/interaction proving the exact selected event as the player sees/hears it.
CHAIN_LAYER=13 FINAL_PLAYER_VISIBLE_RESULT
EDGE=SOURCE_CLOSED_SYSTEM_CHAIN -> ACTUAL_RUNTIME_PLAYER_RESULT
SOURCE=E010-E024; no independent Sprint-01 runtime artifact yet.
SOURCE_VERSION=v0.28.0
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Implementation/source causality is substantially traced.
WHAT_IT_DOES_NOT_PROVE=Actual player-visible behavior, feedback timing, readability or quality under a real run.
FRONTLINE_CURRENT_IMPLEMENTATION=Likewise, current main source is inspectable but no new Sprint-01 runtime capture has upgraded it to a PLAYER-layer PASS.
EXTERNAL_REFERENCE_IMPLEMENTATION=Source chain only; runtime evidence pending.
GAP=Critical learning gate before PASS.
REPRODUCTION_REQUIRED=YES

## E026 — R28 AI can inject typed orders into the same command-queue downstream path

CLAIM=Release-28 AI entity API posts typed commands through the AI manager, which later pushes them into `ICmpCommandQueue` for downstream simulation processing.
CHAIN_LAYER=9 AI_COMMAND_GENERATION
EDGE=AI ENTITY API -> Engine.PostCommand -> CCmpAIManager BUFFER -> PushLocalCommand -> ICmpCommandQueue -> ProcessCommand downstream
SOURCE=`simulation/ai/common-api/entity.js`; `source/simulation2/components/CCmpAIManager.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=AI move/attack API calls are translated to typed command payloads and converge with the command-queue downstream path rather than directly mutating target HP/position in the inspected command API.
WHAT_IT_DOES_NOT_PROVE=The high-level AI reasoning that selects a specific target/order, or that every AI/system command enters at exactly the same semantic level.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical `enemy_ai_controller.gd` would call `BattleFormation.issue_move/set_combat_target` directly, but current `Battle01.tscn` does not attach that controller.
EXTERNAL_REFERENCE_IMPLEMENTATION=AI command producer -> shared command queue.
GAP=High-level R28 AI decision logic remains outside the first chosen player-event trace; cross-project generalization prohibited.
REPRODUCTION_REQUIRED=YES

---

# C. FRONTLINE main mapping — E0 source reality, not product authority

## E030 — Current repository boot enters Battle01

CLAIM=At inspected main, `project.godot` launches `Battle01.tscn`, which binds World3D, camera, presentation, navigation, visibility, selection, input, HUD and formation nodes.
CHAIN_LAYER=1 MAP_LOADING_AND_BATTLE_SPACE / ALL
EDGE=PROJECT_BOOT -> Battle01.tscn -> CURRENT_RUNTIME_NODES
SOURCE=`project.godot`; `scenes/battle01/Battle01.tscn`; `docs/current/CURRENT_STATE.md`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Battle01 is the repository's concrete current runtime entry and therefore valid E0 implementation evidence.
WHAT_IT_DOES_NOT_PROVE=That Battle01 is current/future product-design authority; V30 explicitly revokes that assumption.
FRONTLINE_CURRENT_IMPLEMENTATION=`project.godot -> Battle01.tscn`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Combat Demo uses authored map resource loading rather than this scene/script route.
GAP=Future product map architecture intentionally unresolved.
REPRODUCTION_REQUIRED=NO

## E031 — Battle01 world and active 3D unit presentation are procedural primitives

CLAIM=The active Battle01 3D world and unit-proxy path constructs primitive meshes and runtime StandardMaterial3D instances instead of binding production unit/environment mesh-texture-animation asset families.
CHAIN_LAYER=1 WORLD / 3 MODEL_MATERIAL_ASSET_BINDING / 12 RENDER
EDGE=WORLD/FORMATION_ROLE -> PROCEDURAL_PRIMITIVE_MESH + RUNTIME_COLOR_MATERIAL -> 3D_PROXY_FRAME
SOURCE=`scripts/battle01/battle_3d_world.gd`; `scripts/battle01/battle_3d_presentation.gd`; `scenes/battle01/Battle01.tscn`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Ground/roads/river/building blocks and role proxies are currently BoxMesh/CylinderMesh/TorusMesh plus simple runtime materials in this traced path.
WHAT_IT_DOES_NOT_PROVE=That imported assets do not exist elsewhere in repository history or cannot be integrated.
FRONTLINE_CURRENT_IMPLEMENTATION=Procedural greybox-style active presentation path.
EXTERNAL_REFERENCE_IMPLEMENTATION=Selected R28 entity binds concrete imported skeletal mesh/props/textures/animations/material.
GAP=Direct production-asset binding gap at CONTENT→PRESENTATION/RENDER for current Battle01 path.
REPRODUCTION_REQUIRED=YES

## E032 — Battle01 base unit stats are `.tres` Resource driven

CLAIM=Battle01 formation base stats originate in `FormationDefinition` resources bound into formations and copied into runtime properties by `_apply_definition`.
CHAIN_LAYER=2 UNIT_DATA_SOURCE_OF_TRUTH
EDGE=.tres FormationDefinition -> BattleFormation runtime stats
SOURCE=`scripts/battle01/formation_definition.gd`; `resources/formations/infantry.tres`; `scenes/battle01/Battle01.tscn`; `scripts/battle01/formation.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Move speed, HP, attack damage/range, fire interval, ammo, detection and capture flags are data-bound for the inspected formations.
WHAT_IT_DOES_NOT_PROVE=That all behavior is data-driven or that this schema is current product policy.
FRONTLINE_CURRENT_IMPLEMENTATION=Mixed `.tres` data + scene wiring + script behavior.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 uses template inheritance/components plus VisualActor references.
GAP=No current product data schema frozen.
REPRODUCTION_REQUIRED=YES

## E033 — Battle01 player MOVE is source-closed through Core NavigationService

CLAIM=Battle01's 3D right-click MOVE route reaches selected formations, pathfinding in the shared Core `NavigationService`, and waypoint-driven `global_position` updates.
CHAIN_LAYER=4 PLAYER_SELECTION / 5 COMMAND / 6 PATHFINDING_AND_MOVEMENT
EDGE=RMB_SCREEN -> screen_to_sim -> SelectionController.issue_move -> Formation.issue_move -> BattleNavigation -> NavigationService(AStarGrid2D) -> Formation._update_movement -> global_position
SOURCE=`battle_3d_input.gd`; `selection_controller.gd`; `formation.gd`; `battle_navigation.gd`; `scripts/core/navigation/navigation_service.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=This active Battle01 movement chain actually uses `NavigationService`; the earlier broad notion that Core V1 merely exists but is not connected is false for navigation.
WHAT_IT_DOES_NOT_PROVE=Runtime quality, formation/crowd realism or use of other Core services.
FRONTLINE_CURRENT_IMPLEMENTATION=Direct selection→formation order; BattleNavigation adapts terrain/mobility into Core AStarGrid navigation.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 uses UnitMotion/Pathfinder/Position components with an unresolved UnitAI middle branch for the chosen attack event.
GAP=`TaskCommandService` is not evidenced in this player click path; do not generalize that no caller exists elsewhere.
REPRODUCTION_REQUIRED=YES

## E034 — Battle01 ADVANCE target/combat/state path is explicit and deterministic in source

CLAIM=Player ADVANCE can choose confirmed visible in-range RED targets; `BattleFormation` then gates fire on hold-fire/ammo/range/LOS/cooldown, consumes one ammo, computes damage, directly applies it to target HP and dies at zero.
CHAIN_LAYER=7 DETECTION_TARGET / 8 FIRE_HIT_DAMAGE_DEATH / STATE
EDGE=ADVANCE -> CONFIRMED_TARGET -> FIRE_GATES -> AMMO-1 -> DIRECT_DAMAGE -> HP -> DEATH
SOURCE=`selection_controller.gd`; `formation.gd`; `visibility_field.gd`; formation `.tres` resources
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Current source responsibilities and the explicit historical ammo/cooldown/range/LOS/damage/death implementation.
WHAT_IT_DOES_NOT_PROVE=Balance, realism, runtime correctness or current product approval.
FRONTLINE_CURRENT_IMPLEMENTATION=Target selection external to formation; combat and HP/death concentrated in `BattleFormation`.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 separates UnitAI/Attack/DelayedDamage/Health and does not evidence FRONTLINE-style ammo consumption in the selected chain.
GAP=Architecture differs; no transfer conclusion.
REPRODUCTION_REQUIRED=YES

## E035 — Historical enemy AI implementation exists, but current Battle01 scene does not attach it

CLAIM=`enemy_ai_controller.gd` contains perception/decision/target/move logic that would call lower-level formation methods, but inspected `Battle01.tscn` has no EnemyAIController node/resource and its current M2 roster/objective structure is incompatible with dependencies expected by that historical controller.
CHAIN_LAYER=9 AI_COMMAND_GENERATION
EDGE=CURRENT_BATTLE01_SCENE -> AI_CONTROLLER_WIRING
SOURCE=`scenes/battle01/Battle01.tscn`; `scripts/battle01/enemy_ai_controller.gd`; `scripts/battle01/formal_combat_roster.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=AI source code existence must not be equated with active current scene wiring. The current scene lacks that controller; M2 roster explicitly has no supply/reinforcement units while the historical controller expects older objective/roster dependencies.
WHAT_IT_DOES_NOT_PROVE=That no other current node produces RED decisions or that the historical controller could not be adapted.
FRONTLINE_CURRENT_IMPLEMENTATION=No active EnemyAIController wiring is evidenced in current `Battle01.tscn`; active AI-command generation for current main is therefore unsupported by this controller.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 AI command API feeds a shared command queue.
GAP=CURRENT_BATTLE01_AI_COMMAND_GENERATION is a concrete scene-level gap/unknown, despite historical AI code existing.
REPRODUCTION_REQUIRED=YES

## E036 — Battle01 state reaches HUD through explicit callbacks/signals

CLAIM=Battle01 connects selection/order/health/ammo/intel/death/victory state changes to HUD update methods.
CHAIN_LAYER=10 UI_STATE_ACQUISITION
EDGE=FORMATION/INTEL/WAR_FLOW_STATE -> SIGNAL/CALLBACK -> HUD
SOURCE=`scripts/battle01/battle01.gd`; `scripts/battle01/hud.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The inspected HUD fields are fed from live formation/intel/war-flow state rather than a separate combat calculation.
WHAT_IT_DOES_NOT_PROVE=All UI fields, runtime display correctness or product visual quality.
FRONTLINE_CURRENT_IMPLEMENTATION=Signal/callback state propagation plus HUD queries of formation fields.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 selected-unit Health reaches UI through GuiInterface entity state.
GAP=Runtime/player verification pending.
REPRODUCTION_REQUIRED=YES

## E037 — Battle01 camera/render configuration is explicit but combat-feedback integration is incomplete

CLAIM=Battle01 has an explicit 3D camera/light/environment/proxy render path, but the inspected 3D presentation does not establish a logical-fire→muzzle/projectile/impact/audio path for the active proxy units.
CHAIN_LAYER=11 ANIMATION_VFX_AUDIO / 12 CAMERA_RENDER
EDGE=SIMULATION_STATE -> 3D_PRESENTATION -> CAMERA/FRAME
SOURCE=`battle_camera_3d.gd`; `battle_3d_world.gd`; `battle_3d_presentation.gd`; `formation.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Camera uses FOV 49, configurable height/pan/zoom and oblique focus; world creates light/environment; presentation renders separate 3D proxies, selection/objective/smoke/command-marker visuals. Formation has logical shot/death visual timers in its 2D drawing path, while scene formations are visually hidden for 3D proxy rendering.
WHAT_IT_DOES_NOT_PROVE=That combat feedback is absolutely absent at runtime; an uninspected path could still supply it.
FRONTLINE_CURRENT_IMPLEMENTATION=Camera/render shell exists; complete 3D combat feedback edge is not established.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 source has explicit attack animation/projectile/impact/death hooks and actor→renderer submission.
GAP=Candidate explanation for a technically active but visually dead battle: Layer 8 event is not yet evidenced as connected to Layer 11 active 3D combat feedback.
REPRODUCTION_REQUIRED=YES

## E038 — FRONTLINE current PLAYER result remains unverified in this sprint

CLAIM=The inspected current-main source exposes several connected runtime chains but Sprint 01 has not produced a new player-operation capture proving the present end-to-end behavior/quality.
CHAIN_LAYER=13 FINAL_PLAYER_VISIBLE_RESULT
EDGE=CURRENT_MAIN_SOURCE -> ACTUAL_PLAYER_VISIBLE_RESULT
SOURCE=E030-E037; no new Sprint-01 runtime artifact.
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Source connectivity and concrete asset/presentation gaps can be diagnosed.
WHAT_IT_DOES_NOT_PROVE=Current runtime PASS, visual quality, play feel or user acceptance.
FRONTLINE_CURRENT_IMPLEMENTATION=Source-inspected only in this stage.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 likewise still lacks this sprint's independent runtime PLAYER capture.
GAP=PLAYER layer must be reached through reproduction/runtime evidence.
REPRODUCTION_REQUIRED=YES

---

# D. Current unresolved edges and superseded unknowns

## U001 — UnitAI exact player-attack middle branch
CLAIM=Exact `UnitAI.Attack -> FSM -> UnitMotion.MoveToTargetRange / Attack.StartAttacking` branch for the chosen event.
STATUS=UNKNOWN
NEXT=Inspect the exact v0.28.0 UnitAI command/state branch; do not substitute component tests for the caller chain.

## U002 — R28 automatic target acquisition/priority
CLAIM=How stock UnitAI automatically discovers/prioritizes targets outside the player-designated target path.
STATUS=UNKNOWN
NEXT=Trace separately; it is not required to pretend the player-designated target path is automatic acquisition.

## U003 — Final R28 player-visible runtime result
CLAIM=Actual Combat Demo selected-event behavior/feedback/camera result under a running Release-28 build.
STATUS=UNKNOWN
NEXT=Independent runtime/reproduction artifact required.

## U004 — Current FRONTLINE active AI producer
CLAIM=What currently produces RED decisions in main Battle01, if anything, after the historical EnemyAIController was not wired into the M2 scene.
STATUS=UNKNOWN
NEXT=Runtime/source call search focused on current scene only; do not infer from historical controller files.

## U005 — Current FRONTLINE 3D combat-feedback consumer
CLAIM=Whether any active source/runtime path converts `BattleFormation.attack_fired` or shot state into 3D muzzle/projectile/impact/audio feedback.
STATUS=UNKNOWN
NEXT=Exhaustive focused call/search plus runtime verification.

## U006 — Cross-project generalization
CLAIM=Which R28 patterns survive BAR/Recoil and Warzone counterexample inspection and are useful under Godot 4.7.1.
STATUS=UNKNOWN
NEXT=Trace the same critical command/AI/asset/presentation boundaries in validators before issuing design recommendations.

## U007 — Engine decision
CLAIM=Whether FRONTLINE should retain Godot.
STATUS=UNKNOWN
NEXT=Do not decide from architecture prose; evaluate only after end-to-end reproduction exposes actual requirements/friction.

### Superseded unknowns

The following earlier Sprint-01 unknowns are now resolved by E010-E026 and must not be repeated as current gaps:

- which first map/slice to trace → `Combat Demo` selected;
- GUI `PostNetworkCommand -> ProcessCommand` bridge → OBSERVED in E015;
- ranged attack launch -> delayed hit → OBSERVED in E020;
- selected unit template -> actor/mesh/material/animation → OBSERVED in E011-E012;
- map resource -> world/entity load → OBSERVED in E010;
- selected-unit Health -> HUD → OBSERVED in E022;
- AI command API -> command queue → OBSERVED in E026;
- VisualActor -> UnitRenderer/SceneCollector → OBSERVED in E024.

---

# E. Current gate

FIRST_REFERENCE_SOURCE_CHAIN=PARTIALLY_CLOSED_WITH_ONE_CRITICAL_SIMULATION_MIDDLE_UNKNOWN
FRONTLINE_MAPPING=SOURCE_MAPPED_WITH_CONCRETE_LAYER_3_LAYER_9_LAYER_11_GAPS
PLAYER_RUNTIME_EVIDENCE=PENDING
BAR_WARZONE_EDGE_COUNTEREXAMPLES=PENDING
WINDOW_03_AUDIT=PENDING
WINDOW_02_REPRODUCTION=BLOCKED
PRODUCT_PRODUCTION_RESUME=NO
STATUS=CONTINUE_LEARNING
