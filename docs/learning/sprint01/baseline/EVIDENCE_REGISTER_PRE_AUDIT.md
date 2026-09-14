# Learning Sprint 01 — Evidence Register

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-13
PRIMARY_REFERENCE=0_AD_RELEASE_28
PRIMARY_REFERENCE_VERSION=v0.28.0
PRIMARY_REFERENCE_COMMIT_ANCHOR=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
FRONTLINE_MAIN_INSPECTED=06710c3d9e29d3400572bf25ed5e8fd96c73b472
BAR_INSPECTED_COMMIT=28e122237458f39cd89d254aa44bfc31448cc7f6
RECOIL_INSPECTED_COMMIT=05c054cbe2249feda3637cabfe122b75241113e9
WARZONE_INSPECTED_COMMIT=b0288082c54536ae3634a6a71b0e03f0d82bb8f3
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

This register is the current authoritative Sprint-01 evidence inventory. Earlier UNKNOWN statements explicitly superseded below must not be reused.

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
SOURCE=https://play0ad.com/download/source/ ; version-matched public pull mirror at the stated commit
SOURCE_VERSION=Release 28 / v0.28.0
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Source-file claims in section B are tied to the R28 source state rather than an unmatched archived branch.
WHAT_IT_DOES_NOT_PROVE=Byte-identical tarball-to-mirror equality.
FRONTLINE_CURRENT_IMPLEMENTATION=Not applicable.
EXTERNAL_REFERENCE_IMPLEMENTATION=Version-matched source/data inspection.
GAP=Byte-level archive/mirror identity not independently checked.
REPRODUCTION_REQUIRED=NO

## E003 — Validators are concrete counterexample sources

CLAIM=BAR/Recoil and Warzone expose materially different AI/order boundaries from 0 A.D. and therefore can falsify over-generalized architecture claims.
CHAIN_LAYER=CROSS_PROJECT_VALIDATION / 9 AI_COMMAND_GENERATION
EDGE=PRIMARY_REFERENCE_CLAIM -> COUNTEREXAMPLE_POOL
SOURCE=`Beyond-All-Reason/luarules/gadgets/pve_boss_priority_targetting.lua`; `RecoilEngine/rts/Lua/LuaSyncedCtrl.cpp`; `Warzone2100/data/mp/multiplay/skirmish/cobra_includes/events.js`; `Warzone2100/src/wzapi.cpp`; `Warzone2100/src/order.cpp`
SOURCE_VERSION=BAR@28e122237458f39cd89d254aa44bfc31448cc7f6; Recoil@05c054cbe2249feda3637cabfe122b75241113e9; Warzone@b0288082c54536ae3634a6a71b0e03f0d82bb8f3
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Real game-side AI/synced logic in BAR and Warzone can issue engine-recognized unit orders without traversing the human selection/UI layer; their downstream command mechanisms differ from 0 A.D.'s AI-manager/turn-command-queue route.
WHAT_IT_DOES_NOT_PROVE=That one common command architecture is mandatory for every RTS or that these validators are better architectures for FRONTLINE.
FRONTLINE_CURRENT_IMPLEMENTATION=No transfer decision.
EXTERNAL_REFERENCE_IMPLEMENTATION=Three distinct inspectable command-entry mechanisms.
GAP=Only a narrow cross-project inference is currently justified; broader transfer remains unproven.
REPRODUCTION_REQUIRED=NO

---

# B. First real Release-28 vertical slice — Combat Demo

SELECTED_SLICE=`binaries/data/mods/public/maps/scenarios/combat_demo`
SELECTED_PLAYER_UNIT=`units/athen/infantry_marine_archer_e`
SLICE_STATUS=SOURCE_TRACED_THROUGH_RENDER_SUBMISSION

## E010 — Combat Demo map content reaches world construction and simulation entity creation

CLAIM=Release-28 Combat Demo is a concrete scenario whose `.pmp/.xml` pair is loaded through `CWorld/CMapReader`, producing terrain/environment/camera state and simulation entities.
CHAIN_LAYER=1 MAP_LOADING_AND_BATTLE_SPACE
EDGE=COMBAT_DEMO_MAP_RESOURCE -> CWorld/CMapReader -> TERRAIN/ENVIRONMENT/CAMERA + SIM_ENTITIES
SOURCE=`binaries/data/mods/public/maps/scenarios/combat_demo.xml`; `source/ps/World.cpp`; `source/graphics/MapReader.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Combat Demo contains environment/camera/entity/template data; the loader creates simulation entities and applies transforms/owners plus environment/camera records.
WHAT_IT_DOES_NOT_PROVE=Every random/skirmish-map path or a universal map architecture.
FRONTLINE_CURRENT_IMPLEMENTATION=`project.godot -> Battle01.tscn -> Battle3DWorld`, currently generating battle-space geometry from script primitives/hard-coded geometry.
EXTERNAL_REFERENCE_IMPLEMENTATION=Authored scenario content is loaded into engine world/render state and simulation entities.
GAP=FRONTLINE has no current product-authoritative map-content pipeline frozen.
REPRODUCTION_REQUIRED=YES

## E011 — Combat Demo provides a concrete unit template inheritance chain

CLAIM=The selected Combat Demo elite Athenian marine archer is assembled through template inheritance/composition, not one monolithic unit-definition file.
CHAIN_LAYER=2 UNIT_DATA_SOURCE_OF_TRUTH
EDGE=MAP_ENTITY_TEMPLATE -> LEAF_TEMPLATE -> PARENT/MIXIN/GLOBAL_ARCHER_TEMPLATE -> SIMULATION_COMPONENT_DATA
SOURCE=`maps/scenarios/combat_demo.xml`; `simulation/templates/units/athen/infantry_marine_archer_e.xml`; parent/mixin templates including `template_unit_infantry_ranged_archer.xml`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The selected leaf template composes civilization/rank/general archer data and resolves concrete ranged attack and motion component parameters.
WHAT_IT_DOES_NOT_PROVE=That template inheritance is universally preferable.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 uses `FormationDefinition` `.tres` resources for base stats plus scene wiring/script behavior.
EXTERNAL_REFERENCE_IMPLEMENTATION=Composed template hierarchy resolves gameplay component data.
GAP=No transfer decision; data architecture differs materially.
REPRODUCTION_REQUIRED=YES

## E012 — Selected unit gameplay data binds to a real actor/material/animation asset chain

CLAIM=The selected archer template's `VisualActor` points to an actor definition that binds skeletal mesh, props, textures, animations and material/shader-effect configuration.
CHAIN_LAYER=3 MODEL_MATERIAL_ASSET_BINDING
EDGE=UNIT_TEMPLATE.VisualActor -> ACTOR_XML -> MESH/PROPS/TEXTURES/ANIMATIONS -> MATERIAL -> SHADER_EFFECT
SOURCE=`simulation/templates/units/athen/infantry_marine_archer_e.xml`; `art/actors/units/athenians/infantry_archer_e.xml`; referenced mesh/animation/texture files; `art/materials/player_trans_norm_spec.xml`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The selected gameplay entity has an explicit reusable production asset route including `.dae` mesh, props, base/spec/normal textures, ranged/death animations and material/effect binding.
WHAT_IT_DOES_NOT_PROVE=Runtime visual quality, performance, universal LOD policy or suitability for FRONTLINE's art target.
FRONTLINE_CURRENT_IMPLEMENTATION=Active Battle01 3D formation proxies use runtime `CylinderMesh/BoxMesh` plus `StandardMaterial3D` rather than imported unit mesh/texture/animation bindings.
EXTERNAL_REFERENCE_IMPLEMENTATION=Data-bound actor asset family.
GAP=Active Battle01 lacks an equivalent production unit model→material→texture→animation chain.
REPRODUCTION_REQUIRED=YES

## E013 — Release-28 player selection reaches `g_Selection`

CLAIM=Stock Release-28 session input resolves clicked entities and stores accepted entity IDs in `g_Selection`.
CHAIN_LAYER=4 PLAYER_SELECTION
EDGE=POINTER_INPUT -> ENTITY_PICK -> EntitySelection -> g_Selection
SOURCE=`gui/session/input.js`; `gui/session/selection.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=`Engine.PickEntityAtPoint` and selection add/remove/reset calls form the stock click-selection route.
WHAT_IT_DOES_NOT_PROVE=All selection modes or modded GUI behavior.
FRONTLINE_CURRENT_IMPLEMENTATION=`Battle3DInput` projects proxies to screen space and calls `BattleSelectionController.select_only/add_to_selection`.
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
WHAT_THE_SOURCE_ACTUALLY_PROVES=GUI input/action code constructs a semantic attack command and requests an attack-order sound.
WHAT_IT_DOES_NOT_PROVE=That every command uses identical semantics or that typed envelopes are mandatory for RTS games.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 sends MOVE/ADVANCE directly through `BattleSelectionController`; no equivalent player ATTACK envelope is evidenced in the traced path.
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
WHAT_THE_SOURCE_ACTUALLY_PROVES=The GUI-to-simulation transport edge has concrete engine-side calls; it is not inferred from matching payload names.
WHAT_IT_DOES_NOT_PROVE=Every multiplayer latency/failure behavior.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 player move path has no observed turn/network queue; it mutates local formation order through direct methods.
EXTERNAL_REFERENCE_IMPLEMENTATION=Command crosses a deterministic turn/command-queue boundary before dispatch.
GAP=None for this source edge.
REPRODUCTION_REQUIRED=YES

## E016 — Simulation attack command enters UnitAI

CLAIM=Release-28 `ProcessCommand` dispatches `type='attack'` through `g_Commands.attack`, which calls `cmpUnitAI.Attack(...)` for controlled entities.
CHAIN_LAYER=5 COMMAND_ROUTING / 7-8 SIMULATION_ENTRY
EDGE=ProcessCommand -> g_Commands.attack -> UnitAI.Attack
SOURCE=`simulation/helpers/Commands.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The semantic command reaches UnitAI through the stock dispatcher; `ProcessCommand` also pushes a `playercommand` GUI notification.
WHAT_IT_DOES_NOT_PROVE=Every stance/formation/special-order branch.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 player movement/ADVANCE routes through `SelectionController` and direct formation methods.
EXTERNAL_REFERENCE_IMPLEMENTATION=Simulation command table -> UnitAI.
GAP=None for the chosen command entry.
REPRODUCTION_REQUIRED=YES

## E017 — Chosen player attack is source-closed through UnitAI FSM into movement/range closure and `Attack.StartAttacking`

CLAIM=For the selected player-issued attack, Release-28 `UnitAI.Attack` creates an Attack order; the order enters UnitAI FSM, chooses ATTACKING immediately when already in range or COMBAT.APPROACHING otherwise; APPROACHING invokes `MoveToTargetAttackRange`; on range satisfaction the FSM enters COMBAT.ATTACKING and calls `cmpAttack.StartAttacking(...)`.
CHAIN_LAYER=6 PATHFINDING_AND_MOVEMENT / 7 TARGET / 8 FIRE
EDGE=UnitAI.Attack -> AddOrder("Attack") -> Push/ReplaceOrder -> UnitFsm.ProcessMessage("Order.Attack") -> COMBAT.APPROACHING/ATTACKING -> MoveToTargetAttackRange -> UnitMotion.MoveToTargetRange -> COMBAT.ATTACKING -> Attack.StartAttacking
SOURCE=`binaries/data/mods/public/simulation/components/UnitAI.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The former critical middle UNKNOWN is directly source-closed for the chosen player attack. `Attack()` records a forced player order; `Order.Attack` chooses combat state; COMBAT.APPROACHING moves toward attack range; movement update transitions to ATTACKING; ATTACKING invokes the Attack component.
WHAT_IT_DOES_NOT_PROVE=Every formation-controller, packing/unpacking, failed-path, hunting or auto-acquisition branch behaves identically.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 does not use this separation; BLUE ADVANCE target selection is external and movement/combat execute in `BattleFormation`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Order/FSM explicitly bridges command intent to movement/range closure and attack component.
GAP=Former U001 is resolved and superseded.
REPRODUCTION_REQUIRED=YES

## E018 — UnitMotion reaches Pathfinder and physical position updates

CLAIM=Release-28 UnitMotion requests paths asynchronously and ultimately applies movement through Position updates.
CHAIN_LAYER=6 PATHFINDING_AND_MOVEMENT
EDGE=UnitAI.MoveToTargetAttackRange -> UnitMotion.MoveToTargetRange -> ComputePathToGoal -> Pathfinder -> MT_PathResult -> PerformMove -> Position.MoveAndTurnTo
SOURCE=`simulation/components/UnitAI.js`; `source/simulation2/components/CCmpUnitMotion.h/.cpp`; Pathfinder/path-result interfaces
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=For the chosen out-of-range attack path, UnitAI calls the UnitMotion range movement route; the lower navigation chain is asynchronous and updates simulation position.
WHAT_IT_DOES_NOT_PROVE=Path quality or behavior under every obstruction/crowd case.
FRONTLINE_CURRENT_IMPLEMENTATION=`BattleNavigation -> NavigationService(AStarGrid2D) -> waypoint path -> BattleFormation._update_movement -> global_position`.
EXTERNAL_REFERENCE_IMPLEMENTATION=UnitAI -> UnitMotion -> Pathfinder -> Position.
GAP=None for the chosen source chain; runtime still requires reproduction.
REPRODUCTION_REQUIRED=YES

## E019 — Player-designated target legality is explicit

CLAIM=Release-28 Attack logic explicitly checks target existence/state/ownership/classes and attack range/height restrictions before an attack type is legal.
CHAIN_LAYER=7 DETECTION_AND_TARGET_SELECTION
EDGE=PLAYER_TARGET -> ATTACK_LEGALITY_FILTER -> VALID_ATTACK_TYPE
SOURCE=`simulation/components/Attack.js`; corresponding R28 Attack component tests; `UnitAI.js` `GetBestAttackAgainst/CheckTargetAttackRange`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Player-designated target legality is not equivalent to merely having an entity ID; component checks constrain attackability and range.
WHAT_IT_DOES_NOT_PROVE=The complete automatic target-priority policy for every stance/state.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 BLUE ADVANCE requires confirmed intel, live RED target, attack range and LOS, then chooses nearest with tie handling.
EXTERNAL_REFERENCE_IMPLEMENTATION=Attack component/UnitAI validate target and attack type.
GAP=Automatic acquisition remains a separate study edge.
REPRODUCTION_REQUIRED=YES

## E020 — Attack launch through delayed hit is source-closed

CLAIM=Release-28 `Attack.StartAttacking/PerformAttack` configures attack animation/timing and, for ranged attacks, computes projectile parameters and schedules delayed hit processing.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE_DEATH / 11 PRESENTATION
EDGE=ATTACK_START -> ATTACK_TIMER/ANIMATION -> PROJECTILE -> SCHEDULED_DELAYED_DAMAGE -> DelayedDamage.Hit
SOURCE=`simulation/components/Attack.js`; projectile/delayed-damage calls referenced by the same source
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Ranged launch computes prediction/spread/speed/gravity/travel delay, launches projectile presentation data and schedules hit handling; attack animation is selected by type.
WHAT_IT_DOES_NOT_PROVE=Deterministic hit or FRONTLINE-style ammunition consumption.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 resolves attacks synchronously after ammo/range/LOS/cooldown gates and directly applies damage; it explicitly consumes one ammo.
EXTERNAL_REFERENCE_IMPLEMENTATION=Ranged projectile/delayed-hit path.
GAP=Do not transplant FRONTLINE ammo/deterministic-hit rules into the 0 A.D. reference description.
REPRODUCTION_REQUIRED=YES

## E021 — Delayed hit applies effects to Health and drives death-state behavior

CLAIM=Release-28 delayed hit calls the attack-effect helper; Damage maps to `IID_Health.TakeDamage`; Health source/tests demonstrate HP reduction and lethal death/corpse behavior.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE_DEATH / STATE
EDGE=DelayedDamage.Hit -> AttackHelper.HandleAttackEffects -> Damage receiver -> Health -> HP/DEATH/CORPSE
SOURCE=`simulation/components/DelayedDamage.js`; `simulation/helpers/Attack.js`; `globalscripts/AttackEffects.js`; `simulation/data/attack_effects/damage.json`; `simulation/components/Health.js`; `simulation/components/tests/test_Health.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Damage receiver mapping and Health HP/death semantics are explicit.
WHAT_IT_DOES_NOT_PROVE=That every attack uses only Damage rather than capture/status/splash combinations.
FRONTLINE_CURRENT_IMPLEMENTATION=`BattleFormation.take_damage` subtracts HP and `_die` clears movement/target, sets DESTROYED and emits `died`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Effect receiver -> Health -> death/corpse transition.
GAP=None for the generic source edge; selected live runtime still not reproduced.
REPRODUCTION_REQUIRED=YES

## E022 — Authoritative Health state reaches selected-unit HUD

CLAIM=Release-28 Health state is exposed through `GuiInterface.GetEntityState`, and selection-details GUI reads hitpoints/maxHitpoints to render health information.
CHAIN_LAYER=10 UI_STATE_ACQUISITION
EDGE=SIMULATION Health -> GuiInterface entity state -> selection_details UI
SOURCE=`simulation/components/Health.js`; `simulation/components/GuiInterface.js`; `gui/session/selection_details.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=For inspected health fields, GUI presentation reads simulation-exposed entity state rather than independently recomputing combat damage.
WHAT_IT_DOES_NOT_PROVE=That every UI field follows the same route.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 connects selection/order/health/ammo/intel/death/victory state to HUD methods.
EXTERNAL_REFERENCE_IMPLEMENTATION=Simulation query/message -> GuiInterface -> session UI.
GAP=Runtime display quality remains a reproduction question.
REPRODUCTION_REQUIRED=YES

## E023 — Combat logic has explicit source-level animation/audio/projectile/death feedback paths

CLAIM=The selected Release-28 combat chain has source-backed attack animation, order sound, projectile presentation, impact sound and death presentation/audio paths.
CHAIN_LAYER=11 ANIMATION_VFX_AUDIO_FEEDBACK
EDGE=COMMAND/FIRE/HIT/DEATH -> ANIMATION + AUDIO + PROJECTILE/IMPACT + CORPSE/DEATH_FEEDBACK
SOURCE=`gui/session/unit_actions.js`; `simulation/components/Attack.js`; `simulation/components/DelayedDamage.js`; `simulation/components/Health.js`; selected archer actor/animation files
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Specific feedback-generating calls/data are connected to the attack/death chain at source level.
WHAT_IT_DOES_NOT_PROVE=Their final perceptual weight/readability in an actual run.
FRONTLINE_CURRENT_IMPLEMENTATION=BattleFormation has transitional 2D shot/under-fire/death drawing, while the active 3D proxy path hides the Formation draw and does not consume logical fire into equivalent active 3D combat feedback.
EXTERNAL_REFERENCE_IMPLEMENTATION=Logic-to-presentation hooks/data exist for the selected event.
GAP=PLAYER-layer qualitative result still requires runtime evidence.
REPRODUCTION_REQUIRED=YES

## E024 — Visual actor state reaches render submission

CLAIM=Release-28 `CCmpVisualActor` updates the rendered unit from interpolated simulation position and `CCmpUnitRenderer` submits unit models through the scene collector under render/frustum/LOS constraints.
CHAIN_LAYER=12 CAMERA_AND_RENDER_PRESENTATION
EDGE=SIMULATION_POSITION/VISUAL_ACTOR -> UnitRenderer -> SceneCollector
SOURCE=`source/simulation2/components/CCmpVisualActor.cpp`; `source/simulation2/components/CCmpUnitRenderer.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=There is a concrete simulation visual-actor to renderer submission path; map camera/environment data also reaches runtime view/managers through `CMapReader`.
WHAT_IT_DOES_NOT_PROVE=Final GPU frame quality, performance or actual Combat Demo player-visible capture.
FRONTLINE_CURRENT_IMPLEMENTATION=Battle01 uses proxy `MeshInstance3D`, `Battle3DWorld` light/environment and `BattleCamera3D`.
EXTERNAL_REFERENCE_IMPLEMENTATION=VisualActor -> UnitRenderer -> SceneCollector.
GAP=Final PLAYER result remains un-reproduced by this sprint.
REPRODUCTION_REQUIRED=YES

## E025 — Final Release-28 player-visible result is not yet reproduced

CLAIM=Source inspection connects the selected Combat Demo command/combat event through render submission, but Sprint 01 has not produced its own runtime capture/interaction proving the exact event as the player sees/hears it.
CHAIN_LAYER=13 FINAL_PLAYER_VISIBLE_RESULT
EDGE=SOURCE_CLOSED_SYSTEM_CHAIN -> ACTUAL_RUNTIME_PLAYER_RESULT
SOURCE=E010-E024; no independent Sprint-01 runtime artifact yet.
SOURCE_VERSION=v0.28.0
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Implementation/source causality is now source-closed for the selected player-issued attack through render submission.
WHAT_IT_DOES_NOT_PROVE=Actual player-visible timing, readability, feedback weight or quality under a real run.
FRONTLINE_CURRENT_IMPLEMENTATION=Current main source is inspectable but likewise lacks new Sprint-01 PLAYER-layer capture.
EXTERNAL_REFERENCE_IMPLEMENTATION=Source chain only; runtime evidence pending.
GAP=Critical evidence gate before a learning PASS.
REPRODUCTION_REQUIRED=YES

## E026 — R28 AI can inject typed orders into the same command-queue downstream path

CLAIM=Release-28 AI entity API posts typed commands through the AI manager, which later pushes them into `ICmpCommandQueue` for downstream simulation processing.
CHAIN_LAYER=9 AI_COMMAND_GENERATION
EDGE=AI ENTITY API -> Engine.PostCommand -> CCmpAIManager BUFFER -> PushLocalCommand -> ICmpCommandQueue -> ProcessCommand downstream
SOURCE=`simulation/ai/common-api/entity.js`; `source/simulation2/components/CCmpAIManager.cpp`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=AI move/attack API calls become typed command payloads and converge with command-queue downstream processing instead of directly mutating target HP/position in the inspected API.
WHAT_IT_DOES_NOT_PROVE=The high-level AI reasoning that selects a particular target/order or that every RTS must share this queue.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical AI source would call formation execution methods directly; current Battle01 does not attach it.
EXTERNAL_REFERENCE_IMPLEMENTATION=AI producer -> command queue -> simulation handlers.
GAP=High-level R28 strategic decision remains outside the first player-event trace.
REPRODUCTION_REQUIRED=YES

## E027 — R28 automatic target response is stance/range-query driven, but complete preference policy remains a separate edge

CLAIM=Idle UnitAI can react to `LosAttackRangeUpdate` for stances with `targetVisibleEnemies`, call `AttackEntitiesByPreference`, and push non-forced Attack orders; sight/attacked responses are also stance-dependent.
CHAIN_LAYER=7 DETECTION_AND_TARGET_SELECTION
EDGE=RANGE/LOS UPDATE + STANCE -> TARGET RESPONSE -> ATTACK ORDER
SOURCE=`simulation/components/UnitAI.js`
SOURCE_VERSION=v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Automatic reaction is not simply 'enemy in range => fire'; active range updates, stance flags, attackability and response functions mediate target response.
WHAT_IT_DOES_NOT_PROVE=The full global priority algorithm across every state/formation or the exact internal ordering of every candidate list.
FRONTLINE_CURRENT_IMPLEMENTATION=Current BLUE ADVANCE uses project-specific confirmed-intel/range/LOS/nearest-target logic; current RED has no active decision producer in the loaded scene.
EXTERNAL_REFERENCE_IMPLEMENTATION=Stance + LOS/range query events -> preference/response -> non-forced Attack order.
GAP=Detailed preference policy remains optional deeper study, but the existence of an automatic response chain is no longer UNKNOWN.
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
WHAT_THE_SOURCE_ACTUALLY_PROVES=Battle01 is the concrete current runtime entry and valid E0 implementation evidence.
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
WHAT_THE_SOURCE_ACTUALLY_PROVES=Ground/roads/river/building blocks and role proxies are currently primitive meshes plus simple runtime materials in this traced path.
WHAT_IT_DOES_NOT_PROVE=That imported assets do not exist elsewhere in repository history or cannot be integrated.
FRONTLINE_CURRENT_IMPLEMENTATION=Procedural greybox-style active presentation path.
EXTERNAL_REFERENCE_IMPLEMENTATION=Selected R28 entity binds imported skeletal mesh/props/textures/animations/material.
GAP=Production-asset binding gap at CONTENT→PRESENTATION/RENDER for current Battle01.
REPRODUCTION_REQUIRED=YES

## E032 — Battle01 base unit stats are `.tres` Resource driven

CLAIM=Battle01 formation base stats originate in `FormationDefinition` resources bound into formations and copied into runtime properties by `_apply_definition`.
CHAIN_LAYER=2 UNIT_DATA_SOURCE_OF_TRUTH
EDGE=.tres FormationDefinition -> BattleFormation runtime stats
SOURCE=`scripts/battle01/formation_definition.gd`; `resources/formations/*.tres`; `scenes/battle01/Battle01.tscn`; `scripts/battle01/formation.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Move speed, HP, damage/range, fire interval, ammo, detection and capture flags are data-bound for inspected formations.
WHAT_IT_DOES_NOT_PROVE=That all behavior is data-driven or that this schema is current product policy.
FRONTLINE_CURRENT_IMPLEMENTATION=Mixed `.tres` data + scene wiring + script behavior.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 uses template inheritance/components plus VisualActor references.
GAP=No current product data schema frozen.
REPRODUCTION_REQUIRED=YES

## E033 — Battle01 player MOVE is source-closed through Core NavigationService

CLAIM=Battle01's 3D right-click MOVE route reaches selected formations, pathfinding in shared Core `NavigationService`, and waypoint-driven `global_position` updates.
CHAIN_LAYER=4 PLAYER_SELECTION / 5 COMMAND / 6 PATHFINDING_AND_MOVEMENT
EDGE=RMB_SCREEN -> screen_to_sim -> SelectionController.issue_move -> Formation.issue_move -> BattleNavigation -> NavigationService(AStarGrid2D) -> Formation._update_movement -> global_position
SOURCE=`battle_3d_input.gd`; `selection_controller.gd`; `formation.gd`; `battle_navigation.gd`; `scripts/core/navigation/navigation_service.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=This active Battle01 movement chain really uses `NavigationService`; the broad claim that Core V1 merely exists but is not connected is false for navigation.
WHAT_IT_DOES_NOT_PROVE=Runtime quality, crowd realism or use of other Core services.
FRONTLINE_CURRENT_IMPLEMENTATION=Direct selection→formation order with BattleNavigation adapter into AStarGrid navigation.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 uses UnitAI→UnitMotion→Pathfinder→Position.
GAP=`TaskCommandService` is not evidenced in this player click path; do not generalize beyond it.
REPRODUCTION_REQUIRED=YES

## E034 — Battle01 ADVANCE target/combat/state path is explicit

CLAIM=Player ADVANCE can choose confirmed visible in-range RED targets; `BattleFormation` gates fire on hold-fire/ammo/range/LOS/cooldown, consumes one ammo, computes damage, directly applies it to target HP and dies at zero.
CHAIN_LAYER=7 DETECTION_TARGET / 8 FIRE_HIT_DAMAGE_DEATH / STATE
EDGE=ADVANCE -> CONFIRMED_TARGET -> FIRE_GATES -> AMMO-1 -> DIRECT_DAMAGE -> HP -> DEATH
SOURCE=`selection_controller.gd`; `formation.gd`; `visibility_field.gd`; formation `.tres` resources
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Current source responsibilities and explicit ammo/cooldown/range/LOS/damage/death implementation.
WHAT_IT_DOES_NOT_PROVE=Balance, realism, runtime correctness or product approval.
FRONTLINE_CURRENT_IMPLEMENTATION=Target choice external to formation; combat and HP/death concentrated in `BattleFormation`.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 separates UnitAI/Attack/DelayedDamage/Health and does not evidence FRONTLINE-style ammo consumption in the selected chain.
GAP=Architecture differs; no transfer conclusion.
REPRODUCTION_REQUIRED=YES

## E035 — Current Battle01 has no source-wired RED tactical command/target producer

CLAIM=Although historical enemy AI scripts remain in the repository, the currently loaded Battle01 scene and its active control scripts do not wire an EnemyAIController or another RED movement/target decision producer.
CHAIN_LAYER=9 AI_COMMAND_GENERATION
EDGE=CURRENT_BATTLE01_RUNTIME_NODES -> RED_DECISION -> RED_COMMAND/TARGET
SOURCE=`scenes/battle01/Battle01.tscn`; `scripts/battle01/battle01.gd`; `formal_combat_roster.gd`; `player_war_flow.gd`; `selection_controller.gd`; `formation.gd`; historical `enemy_ai_controller.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=`Battle01.tscn` has no EnemyAIController resource/node. `FormalCombatRoster` creates/positions RED formations but issues no tactical orders. `PlayerWarFlow` tracks RED for objective/victory and only stops formations at match end. `SelectionController` target/ADVANCE logic is explicitly restricted to selected BLUE formations. `BattleFormation` fires only when an external caller has assigned `_combat_target`; it does not scan for targets itself.
WHAT_IT_DOES_NOT_PROVE=An actual runtime capture of RED inactivity, or that a future/alternate scene cannot instantiate historical AI. It also does not erase historical AI implementation/tests.
FRONTLINE_CURRENT_IMPLEMENTATION=Active main scene has RED roster/state but no source-wired RED tactical decision producer.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28/BAR/Warzone all expose explicit AI/game-logic order producers in the inspected paths.
GAP=Layer 9 CONTROL is an observed current-scene gap, not merely an UNKNOWN caused by uninspected files.
REPRODUCTION_REQUIRED=YES

## E036 — Battle01 state reaches HUD through explicit callbacks/signals

CLAIM=Battle01 connects selection/order/health/ammo/intel/death/victory state changes to HUD update methods.
CHAIN_LAYER=10 UI_STATE_ACQUISITION
EDGE=FORMATION/INTEL/WAR_FLOW_STATE -> SIGNAL/CALLBACK -> HUD
SOURCE=`scripts/battle01/battle01.gd`; `scripts/battle01/hud.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Inspected HUD fields are fed from formation/intel/war-flow state rather than a separate combat calculation.
WHAT_IT_DOES_NOT_PROVE=Runtime display correctness or visual quality.
FRONTLINE_CURRENT_IMPLEMENTATION=Signal/callback propagation plus HUD queries.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 selected-unit Health reaches UI through GuiInterface entity state.
GAP=Runtime/player verification pending.
REPRODUCTION_REQUIRED=YES

## E037 — Logical combat has transitional 2D feedback, but active 3D combat-feedback edge is not wired

CLAIM=`BattleFormation` converts logical shots/under-fire/death into 2D draw effects, but current Battle01 hides Formation drawing for the 3D shell and `Battle3DPresentation` does not consume `attack_fired` or shot state into equivalent 3D muzzle/tracer/projectile/impact/audio/camera feedback.
CHAIN_LAYER=8 FIRE -> 11 ANIMATION_VFX_AUDIO_FEEDBACK -> 12 RENDER
EDGE=LOGICAL_FIRE -> ACTIVE_PLAYER_VISIBLE_3D_COMBAT_FEEDBACK
SOURCE=`scripts/battle01/formation.gd`; `battle01.gd`; `battle_3d_presentation.gd`; `scenes/battle01/Battle01.tscn`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=`_update_combat` sets `_shot_fx_target/_shot_fx_remaining`; `_draw_combat_fx` draws tracer/glow/muzzle/impact/under-fire 2D effects; death has a 2D timer. In the current 3D shell formations are alpha-hidden and presentation renders separate proxy meshes. `battle01.gd` consumes `attack_fired` only for RED intel exposure and first-combat logging. `Battle3DPresentation` connects smoke deployment and renders proxy/objective/marker/smoke/command visuals, but has no fire-signal/shot-state consumer.
WHAT_IT_DOES_NOT_PROVE=Absolute absence of every possible audio or external runtime hook outside the inspected current Battle01 path; it does prove the active traced 3D presentation path has no source-wired fire feedback consumer.
FRONTLINE_CURRENT_IMPLEMENTATION=Layer-8 logic and legacy/transitional 2D feedback exist; active Layer-11 3D combat feedback is missing from the traced shell.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 source connects attack animation/projectile/impact/death feedback before renderer submission.
GAP=Concrete Layer 8→11 integration gap; this supersedes the weaker prior `UNKNOWN` wording.
REPRODUCTION_REQUIRED=YES

## E038 — FRONTLINE current PLAYER result remains unverified in this sprint

CLAIM=The inspected current-main source exposes connected runtime chains and concrete gaps, but Sprint 01 has not produced a new player-operation capture proving present end-to-end behavior/quality.
CHAIN_LAYER=13 FINAL_PLAYER_VISIBLE_RESULT
EDGE=CURRENT_MAIN_SOURCE -> ACTUAL_PLAYER_VISIBLE_RESULT
SOURCE=E030-E037; no new Sprint-01 runtime artifact.
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Source connectivity and concrete asset/control/presentation gaps can be diagnosed.
WHAT_IT_DOES_NOT_PROVE=Current runtime PASS, visual quality, play feel or user acceptance.
FRONTLINE_CURRENT_IMPLEMENTATION=Source-inspected only in this stage.
EXTERNAL_REFERENCE_IMPLEMENTATION=R28 likewise still lacks this sprint's independent PLAYER capture.
GAP=PLAYER layer still requires runtime evidence.
REPRODUCTION_REQUIRED=YES

---

# D. Counterexample / falsification evidence

## E039 — BAR synced game logic can choose a target and issue ATTACK without human selection/input

CLAIM=BAR's enabled synced `pve_boss_priority_targetting.lua` periodically finds nearby commander-class targets for queen/boss units and issues `CMD.STOP` followed by `CMD.ATTACK` through `Spring.GiveOrderToUnit`.
CHAIN_LAYER=9 AI_COMMAND_GENERATION / CROSS_PROJECT_VALIDATION
EDGE=SYNCED_GAME_LOGIC_TARGET_DECISION -> Spring.GiveOrderToUnit(CMD.ATTACK)
SOURCE=`Beyond-All-Reason/luarules/gadgets/pve_boss_priority_targetting.lua`
SOURCE_VERSION=BAR@28e122237458f39cd89d254aa44bfc31448cc7f6
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=An actual BAR game-side synced controller can generate combat orders without going through player selection/UI.
WHAT_IT_DOES_NOT_PROVE=The whole BAR AI architecture or how every BAR bot issues orders.
FRONTLINE_CURRENT_IMPLEMENTATION=Current Battle01 has no comparable active RED producer in the loaded scene.
EXTERNAL_REFERENCE_IMPLEMENTATION=Synced Lua gadget -> engine order API.
GAP=This rejects any universal claim that AI must enter through the exact human top-level input/selection controller.
REPRODUCTION_REQUIRED=NO

## E040 — Recoil synced Lua order API enters unit command AI directly

CLAIM=Recoil's synced `Spring.GiveOrderToUnit` parses a Lua command and hands it to the target unit's `commandAI->GiveCommand` after control checks.
CHAIN_LAYER=9 AI/CONTROL -> SIMULATION
EDGE=Spring.GiveOrderToUnit -> ParseCommand -> unit.commandAI.GiveCommand
SOURCE=`RecoilEngine/rts/Lua/LuaSyncedCtrl.cpp`
SOURCE_VERSION=Recoil@05c054cbe2249feda3637cabfe122b75241113e9
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=BAR's synced `GiveOrderToUnit` call has a concrete engine-side command-execution boundary; it does not need 0 A.D.'s GUI network command or AI-manager turn-buffer route.
WHAT_IT_DOES_NOT_PROVE=That Recoil has no other command/network layers or that direct commandAI entry should be copied into FRONTLINE.
FRONTLINE_CURRENT_IMPLEMENTATION=Current player commands call formation methods; current RED producer is absent.
EXTERNAL_REFERENCE_IMPLEMENTATION=Lua synced control -> parsed engine Command -> per-unit command AI.
GAP=Architecture is a counterexample, not a transfer prescription.
REPRODUCTION_REQUIRED=NO

## E041 — Warzone skirmish AI issues native droid orders through script API

CLAIM=Warzone's Cobra skirmish AI evaluates events, local force balance, reachability and distance, then calls `orderDroidObj(...DORDER_ATTACK...)` or `orderDroidLoc(...)`; native order code accepts those droid orders and translates attack orders into attack/move actions according to range/state.
CHAIN_LAYER=9 AI_COMMAND_GENERATION -> 6/8 EXECUTION
EDGE=JS_SKIRMISH_DECISION -> orderDroidObj/orderDroidLoc -> DROID_ORDER -> actionDroid(ATTACK/MOVE)
SOURCE=`data/mp/multiplay/skirmish/cobra_includes/events.js`; `src/wzapi.cpp`; `src/order.cpp`; `src/order.h`
SOURCE_VERSION=Warzone@b0288082c54536ae3634a6a71b0e03f0d82bb8f3
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Another mature open RTS exposes an AI scripting boundary where JS logic produces native droid orders; attack execution then decides attack-versus-move-to-target according to droid/range/order state.
WHAT_IT_DOES_NOT_PROVE=That all Warzone AI behavior uses the exact Cobra path or that its order machinery is universally preferable.
FRONTLINE_CURRENT_IMPLEMENTATION=No active current RED producer; BLUE ADVANCE uses project-specific direct methods.
EXTERNAL_REFERENCE_IMPLEMENTATION=JS AI -> native order API -> droid order/action machinery.
GAP=This independently rejects a universal requirement for 0 A.D.-style AI command buffering.
REPRODUCTION_REQUIRED=NO

## E042 — Narrow cross-project command-boundary inference

CLAIM=Across the inspected 0 A.D., BAR/Recoil and Warzone paths, automated control converges on an engine/game-recognized command/order execution boundary, but the entry mechanism and location of that boundary differ materially.
CHAIN_LAYER=CROSS_PROJECT_VALIDATION / 9 CONTROL
EDGE=AI_DECISION -> GAME_RECOGNIZED_COMMAND_OR_ORDER_BOUNDARY -> UNIT_EXECUTION
SOURCE=E026; E039-E041
SOURCE_VERSION=versions stated above
STATUS=INFERRED
WHAT_THE_SOURCE_ACTUALLY_PROVES=0 A.D. uses AI manager/command queue; BAR/Recoil can use synced `GiveOrderToUnit` into per-unit command AI; Warzone JS uses native droid-order APIs. All three avoid describing high-level AI as directly subtracting target HP in the inspected paths.
WHAT_IT_DOES_NOT_PROVE=That all RTS must share one command object format, one queue, one network boundary, or one AI architecture; it also does not prove FRONTLINE should adopt any of the three.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical FRONTLINE AI called lower-level formation execution directly; active current Battle01 lacks the producer entirely.
EXTERNAL_REFERENCE_IMPLEMENTATION=Three distinct control-entry architectures.
GAP=Transfer requires 02 reproduction and 03 audit; only the narrow boundary concept is currently supported.
REPRODUCTION_REQUIRED=YES

---

# E. Current unresolved edges and superseded unknowns

## U002 — Detailed R28 automatic target preference policy
CLAIM=Full candidate ordering/priority behavior across all UnitAI states/formations beyond the now-observed stance/range-query automatic response chain.
STATUS=UNKNOWN
NEXT=Trace only if needed for the reproduction question; do not block the selected player-issued attack chain on it.

## U003 — Final R28 player-visible runtime result
CLAIM=Actual Combat Demo selected-event behavior/feedback/camera result under a running Release-28 build.
STATUS=UNKNOWN
NEXT=Independent runtime/reproduction artifact required.

## U007 — Engine decision
CLAIM=Whether FRONTLINE should retain Godot.
STATUS=UNKNOWN
NEXT=Do not decide from architecture prose; evaluate only after end-to-end reproduction exposes actual requirements/friction.

### Superseded unknowns — do not reuse

- U001 exact `UnitAI.Attack -> FSM -> movement/Attack.StartAttacking` → RESOLVED by E017-E018.
- U004 current FRONTLINE RED decision producer → RESOLVED at source level by E035: none is wired in current Battle01 active path.
- U005 current active 3D combat-feedback consumer → RESOLVED at source level by E037: 2D feedback exists, but no active 3D fire-feedback consumer is wired in the traced presentation shell.
- U006 first command/AI cross-project counterexample pass → RESOLVED by E039-E042; broad transfer/generalization remains unproven.
- GUI `PostNetworkCommand -> ProcessCommand` → OBSERVED in E015.
- ranged attack launch -> delayed hit → OBSERVED in E020.
- selected unit template -> actor/mesh/material/animation → OBSERVED in E011-E012.
- map resource -> world/entity load → OBSERVED in E010.
- selected-unit Health -> HUD → OBSERVED in E022.
- AI command API -> command queue → OBSERVED in E026.
- VisualActor -> UnitRenderer/SceneCollector → OBSERVED in E024.

---

# F. Current gate

FIRST_REFERENCE_SOURCE_CHAIN=SOURCE_CLOSED_FOR_SELECTED_PLAYER_ATTACK_THROUGH_RENDER_SUBMISSION
R28_AUTOMATIC_TARGET_RESPONSE=PARTIALLY_SOURCE_CLOSED_NOT_REQUIRED_FOR_SELECTED_EVENT
FRONTLINE_MAPPING=SOURCE_MAPPED_WITH_OBSERVED_LAYER_3_LAYER_9_LAYER_11_GAPS
PLAYER_RUNTIME_EVIDENCE=PENDING
BAR_RECOIL_WARZONE_COMMAND_COUNTEREXAMPLES=OBSERVED
WINDOW_03_AUDIT=PENDING
WINDOW_01_TO_02_HANDOFF_CANDIDATE=NOW_POSSIBLE_PENDING_CONTROL_REVIEW
WINDOW_02_REPRODUCTION=NOT_SELF_AUTHORIZED_BY_WINDOW_01
PRODUCT_PRODUCTION_RESUME=NO
STATUS=CONTINUE_LEARNING
