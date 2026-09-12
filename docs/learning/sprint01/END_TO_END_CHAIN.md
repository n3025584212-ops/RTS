# LEARNING SPRINT 01 — END TO END CHAIN

STATUS=CONTINUE_LEARNING
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
EVIDENCE_REGISTER=docs/learning/sprint01/EVIDENCE_REGISTER.md
PRIMARY_REFERENCE=0_AD_RELEASE_28
PRIMARY_REFERENCE_VERSION=v0.28.0
PRIMARY_REFERENCE_COMMIT_ANCHOR=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
SELECTED_SLICE=Combat_Demo
SELECTED_UNIT=units/athen/infantry_marine_archer_e
FRONTLINE_MAIN_INSPECTED=06710c3d9e29d3400572bf25ed5e8fd96c73b472

This document is an edge graph, not a module catalogue. An adjacent pair of files is not an edge unless a call/data/runtime relation has been observed. `UNKNOWN` is retained when that relation is still missing.

## Macro chain

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

## 13-layer coverage state

| Layer | 0 A.D. R28 first slice | FRONTLINE main mapping |
|---|---|---|
| 1 Map / battle space | OBSERVED | OBSERVED |
| 2 Unit data | OBSERVED | OBSERVED |
| 3 Model/material binding | OBSERVED | OBSERVED GAP in active Battle01 path |
| 4 Player selection | OBSERVED | OBSERVED |
| 5 Command routing | OBSERVED | OBSERVED |
| 6 Pathfinding/movement | PARTIAL: lower chain OBSERVED, UnitAI entry bridge UNKNOWN | OBSERVED |
| 7 Detection/target | player-designated legality OBSERVED; auto acquisition UNKNOWN | ADVANCE targeting OBSERVED |
| 8 Fire/hit/damage/death | OBSERVED except UnitAI→Attack middle bridge | OBSERVED |
| 9 AI command generation | command injection OBSERVED; high-level decision not traced | historical source OBSERVED, current scene wiring GAP |
| 10 UI state | selected-unit Health path OBSERVED | OBSERVED |
| 11 Animation/VFX/audio | source hooks OBSERVED | active 3D combat feedback UNKNOWN/GAP |
| 12 Camera/render | actor→renderer submission OBSERVED | OBSERVED configuration |
| 13 Player result | UNKNOWN: no Sprint-01 runtime capture | UNKNOWN: no new Sprint-01 runtime capture |

---

# A. Release-28 first vertical event

## A0. Concrete event

The first event is intentionally small and real:

`Combat Demo loads`
`-> player has an Athenian elite marine archer`
`-> player selects the unit`
`-> contextual right-click resolves ATTACK on an enemy`
`-> typed attack command enters the turn/simulation command queue`
`-> UnitAI accepts the attack order`
`-> movement/range closure occurs when required`
`-> ranged attack starts`
`-> projectile/delayed hit is generated`
`-> Damage reaches Health`
`-> HP/death state changes`
`-> UI/animation/projectile/audio/death presentation receives state/events`
`-> actor is submitted to renderer`
`-> player-visible runtime result`

The final arrow is intentionally still UNKNOWN because this sprint has not yet produced its own runtime capture.

## A1. Upstream CONTENT -> WORLD

```text
Combat Demo scenario path
    |
    | A-MAP-01 OBSERVED
    | source: maps/scenarios/combat_demo.xml + CWorld + CMapReader
    v
.pmp + matching .xml
    |
    +--> terrain/environment/water/light/camera managers
    |
    +--> simulation AddEntity(template, id)
              |
              +--> position/orientation/owner
              v
        playable simulation entities
```

`Combat Demo` is not an invented reproduction map. Its scenario file identifies the demo, defines environment/camera/player/entity data, and includes the chosen archer template. `CWorld::RegisterInit` constructs/uses `CMapReader`; `CMapReader` resolves the `.pmp` plus matching `.xml`, builds entities from template identifiers and applies entity/world/view data.

EDGE_ID=A-MAP-01
STATUS=OBSERVED
SOURCE=`binaries/data/mods/public/maps/scenarios/combat_demo.xml`; `source/ps/World.cpp`; `source/graphics/MapReader.cpp`
WHAT_IT_PROVES=An authored map resource becomes simulation/render world state through an explicit loader chain.
WHAT_IT_DOES_NOT_PROVE=All random-map authoring rules or a universal map architecture.
EVIDENCE_REGISTER=E010

## A2. Unit data -> production asset

```text
Combat Demo entity template
units/athen/infantry_marine_archer_e
    |
    | A-DATA-01 OBSERVED
    v
elite template
 -> parent _a
 -> parent _b / civ + merc mixins
 -> template_unit_infantry_ranged_archer
 -> attack/motion/component data

leaf VisualActor
    |
    | A-ASSET-01 OBSERVED
    v
art/actors/units/athenians/infantry_archer_e.xml
 -> skeletal .dae mesh
 -> actor props (head/bow/quiver/shield/arrow)
 -> base/spec/normal textures
 -> ranged/death/idle animations
 -> player_trans_norm_spec material
 -> model shader effect
```

EDGE_ID=A-DATA-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E011

EDGE_ID=A-ASSET-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E012

Important boundary: this proves a concrete R28 data/asset binding route. It does not prove this hierarchy is the correct architecture for FRONTLINE.

---

# B. INPUT -> COMMAND -> SIMULATION

## B1. Selection

```text
mouse click
  -> Engine.PickEntityAtPoint
  -> selection add/remove/reset
  -> EntitySelection
  -> g_Selection selected entity IDs
```

EDGE_ID=A-SELECT-01
STATUS=OBSERVED
SOURCE=`gui/session/input.js`; `gui/session/selection.js`
EVIDENCE_REGISTER=E013

## B2. Contextual attack command construction

```text
right-click / action resolution
  -> determineAction / doAction / handleUnitAction
  -> attack.execute
  -> g_Selection.toList() + target
  -> Engine.PostNetworkCommand({ type:'attack', entities, target, ... })
```

The same GUI branch requests the attack-order sound; that immediate sound request is presentation evidence, not simulation hit evidence.

EDGE_ID=A-CMD-01
STATUS=OBSERVED
SOURCE=`gui/session/input.js`; `gui/session/unit_actions.js`
EVIDENCE_REGISTER=E014

## B3. Engine/turn bridge — previously UNKNOWN, now closed

```text
Engine.PostNetworkCommand
  -> JSInterface_Simulation::PostNetworkCommand
  -> ICmpCommandQueue.PostNetworkCommand
  -> TurnManager.PostCommand
  -> CCmpCommandQueue::FlushTurn
  -> global JS ProcessCommand(player, cmd)
```

EDGE_ID=A-CMD-02
STATUS=OBSERVED
SOURCE=`source/simulation2/scripting/JSInterface_Simulation.cpp`; `source/simulation2/components/CCmpCommandQueue.cpp`
EVIDENCE_REGISTER=E015

This edge may no longer be described as UNKNOWN. Matching command names were insufficient evidence earlier; the C++ bridge is now directly inspected.

## B4. Simulation dispatcher

```text
ProcessCommand(type='attack')
  -> controlled-entity filtering
  -> GuiInterface playercommand notification
  -> g_Commands.attack
  -> cmpUnitAI.Attack(target, allowCapture, queued, pushFront)
```

EDGE_ID=A-CMD-03
STATUS=OBSERVED
SOURCE=`simulation/helpers/Commands.js`
EVIDENCE_REGISTER=E016

---

# C. SIMULATION: movement, target, fire, damage

## C1. One critical middle edge is still UNKNOWN

```text
cmpUnitAI.Attack(...)
   |
   | A-UNITAI-01 UNKNOWN
   v
specific UnitAI order/FSM branch
   |
   +--> UnitMotion.MoveToTargetRange when range closure is required
   |
   +--> Attack.StartAttacking when attack begins
```

The actual Release-28 UnitAI component tests prove that real UnitAI interacts with RangeManager, UnitMotion, Vision, Attack and Health interfaces and reaches combat attacking states under tested conditions. They do **not** prove the exact caller path for this chosen player-issued order.

EDGE_ID=A-UNITAI-01
STATUS=UNKNOWN
SOURCE=`simulation/components/tests/test_UnitAI.js` plus component interfaces
EVIDENCE_REGISTER=E017
NEXT=Directly extract the chosen v0.28.0 UnitAI command/state branch.

## C2. Lower movement route is observed

```text
UnitMotion MoveTo* request
  -> ComputePathToGoal
  -> async Pathfinder request
  -> MT_PathResult
  -> motion update
  -> PerformMove
  -> Position.MoveAndTurnTo
  -> simulation transform changes
```

EDGE_ID=A-MOVE-01
STATUS=OBSERVED
SOURCE=Release-28 `CCmpUnitMotion` + Pathfinder/path-result/Position call path
EVIDENCE_REGISTER=E018

This lower route cannot silently fill A-UNITAI-01. It only proves what happens once UnitMotion is invoked.

## C3. Player-designated target legality

```text
selected target entity
  -> Attack target legality / ownership / class / health checks
  -> range / height / attack-type constraints
  -> legal attack type
```

EDGE_ID=A-TARGET-01
STATUS=OBSERVED
SOURCE=`simulation/components/Attack.js` and tests
EVIDENCE_REGISTER=E019

Automatic target discovery/priority is a separate unresolved question; it is not being inferred from this player-designated target path.

## C4. Attack launch -> projectile -> delayed hit

```text
Attack.StartAttacking
  -> prepare/repeat timer + attack_<type> animation
  -> PerformAttack
  -> target prediction + projectile spread/speed/gravity/travel time
  -> projectile presentation launch
  -> scheduled DelayedDamage payload
  -> DelayedDamage.Hit
```

EDGE_ID=A-FIRE-01
STATUS=OBSERVED
SOURCE=`simulation/components/Attack.js`; delayed/projectile calls reached by the same source
EVIDENCE_REGISTER=E020

Important negative evidence:
- this traced 0 A.D. attack path does **not** establish FRONTLINE-style `Ammo -1 / shot`;
- it does **not** establish deterministic hit;
- FRONTLINE's historical ammo/deterministic-direct-damage implementation must stay project-specific.

## C5. Hit -> effects -> Health -> death

```text
DelayedDamage.Hit
  -> AttackHelper.HandleAttackEffects
  -> Damage effect mapping
  -> IID_Health.TakeDamage receiver
  -> Health HP reduction
  -> lethal state
  -> death/corpse behavior
```

EDGE_ID=A-DAMAGE-01
STATUS=OBSERVED
SOURCE=`DelayedDamage.js`; `simulation/helpers/Attack.js`; `globalscripts/AttackEffects.js`; `damage.json`; `Health.js`; `test_Health.js`
EVIDENCE_REGISTER=E021

---

# D. STATE -> UI / PRESENTATION -> RENDER

## D1. Health state -> UI

```text
Health component state
  -> GuiInterface.GetEntityState
  -> hitpoints / maxHitpoints
  -> selection_details.js
  -> health bar / health number presentation
```

Health also posts health-change simulation messages. This record only claims the inspected Health UI route; it does not claim every UI field follows the same mechanism.

EDGE_ID=A-UI-01
STATUS=OBSERVED
SOURCE=`Health.js`; `GuiInterface.js`; `gui/session/selection_details.js`
EVIDENCE_REGISTER=E022

## D2. Logic -> feedback

```text
attack order       -> order_attack sound request
actual attack      -> attack_<type> actor animation
ranged fire         -> projectile presentation
impact              -> impact sound/effects route
death               -> death sound + death/corpse presentation
```

EDGE_ID=A-PRESENT-01
STATUS=OBSERVED_AT_SOURCE_LEVEL
SOURCE=`unit_actions.js`; `Attack.js`; `DelayedDamage.js`; `Health.js`; chosen archer actor/animation files
EVIDENCE_REGISTER=E023

This is not a perceptual-quality PASS. Source calls/data do not prove that the player experiences good weight/readability.

## D3. Visual actor -> renderer

```text
simulation/interpolated Position
  -> CCmpVisualActor
  -> ICmpUnitRenderer.UpdateUnitPos / model state
  -> CCmpUnitRenderer RenderSubmit
  -> LOS/frustum checks
  -> SceneCollector.SubmitRecursive(unit model)
```

EDGE_ID=A-RENDER-01
STATUS=OBSERVED
SOURCE=`source/simulation2/components/CCmpVisualActor.cpp`; `CCmpUnitRenderer.cpp`
EVIDENCE_REGISTER=E024

Map camera/environment data is separately applied during `CMapReader` world load.

## D4. PLAYER boundary

```text
SceneCollector + GUI + camera + audio
   |
   | A-PLAYER-01 UNKNOWN in this sprint
   v
actual running Combat Demo event as seen/heard by player
```

EDGE_ID=A-PLAYER-01
STATUS=UNKNOWN
REASON=No independent Sprint-01 runtime capture/interaction artifact has yet been produced.
EVIDENCE_REGISTER=E025

This source trace cannot be promoted to `REPRODUCED` or PASS.

---

# E. AI side branch into the same simulation

R28 AI is not assumed to be “the same as player input”. The observed convergence point is lower:

```text
AI high-level reasoning                [not traced here]
  -> common-api entity.move/attack
  -> Engine.PostCommand
  -> CCmpAIManager AI command buffer
  -> PushCommands
  -> ICmpCommandQueue.PushLocalCommand
  -> downstream command queue / ProcessCommand
  -> same simulation command handlers
```

EDGE_ID=A-AI-01
STATUS=OBSERVED_FOR_COMMAND_INJECTION
SOURCE=`simulation/ai/common-api/entity.js`; `source/simulation2/components/CCmpAIManager.cpp`
EVIDENCE_REGISTER=E026

UNKNOWN remains: the high-level AI reasoning that chose the particular target/order.

This evidence also prevents a false universal claim: “AI must call the exact same top-level selection/controller API as a human player” is **not** supported. R28 converges through the command queue; FRONTLINE historical AI source, when attached, converges even lower at formation execution methods.

---

# F. FRONTLINE main mapping

Battle01 is valid E0 implementation evidence because it is the current repository main scene, but V30 explicitly says it is not automatic product-design authority.

## F1. Boot / world

```text
project.godot
  -> res://scenes/battle01/Battle01.tscn
  -> World3D / BattleCamera3D / Presentation3D
  -> Navigation / Visibility / formations / HUD / Input3D

Battle3DWorld._ready
  -> build lighting
  -> build primitive ground
  -> build roads/river/bridge
  -> build blocker geometry
  -> build industrial/rear primitives
```

EDGE_ID=F-MAP-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E030,E031

This is script-authored procedural greybox world construction, not the same production route as R28's selected authored scenario + actor assets.

## F2. Unit data

```text
resources/formations/*.tres
  -> FormationDefinition
  -> Battle01 formation.definition
  -> BattleFormation._apply_definition
  -> runtime HP/speed/damage/range/fire interval/ammo/detection/etc.
```

EDGE_ID=F-DATA-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E032

## F3. Active unit visual binding — concrete gap

```text
BattleFormation role
  -> Battle3DPresentation._mesh_for_role
  -> infantry CylinderMesh / vehicles BoxMesh
  -> runtime StandardMaterial3D color/metallic/roughness
  -> MeshInstance3D proxy
```

EDGE_ID=F-ASSET-01
STATUS=OBSERVED
GAP=No imported production unit mesh -> texture set -> material/shader -> animation chain is present in this active Battle01 proxy route.
EVIDENCE_REGISTER=E031

Do not expand this claim to “FRONTLINE repository has no real assets”. The evidence concerns the active traced Battle01 presentation path only.

## F4. Player select -> MOVE -> navigation -> transform

```text
LMB projection-based pick
  -> BattleSelectionController selection

RMB
  -> Battle3DInput.screen_to_sim
  -> SelectionController.issue_move
  -> BattleFormation.issue_move
  -> BattleNavigation.find_path_for_formation
  -> NavigationService.find_path
  -> AStarGrid2D point path
  -> BattleFormation._update_movement
  -> global_position
  -> Battle3DPresentation proxy position
```

EDGE_ID=F-MOVE-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E033

Correction preserved: Core `NavigationService` is truly connected here. The fact that other Core services exist does not prove they are connected.

## F5. ADVANCE -> target -> combat -> state

```text
ADVANCE intent
  -> known RED target list
  -> Intel == CONFIRMED
  -> alive/faction/range/LOS checks
  -> nearest legal target
  -> formation.set_combat_target
  -> BattleFormation._update_combat
  -> hold-fire / can-attack / Ammo / range / LOS / cooldown gates
  -> Ammo -1
  -> calculated damage
  -> target.take_damage
  -> HP
  -> _die at zero
```

EDGE_ID=F-COMBAT-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E034

This is a direct synchronous combat model in the traced historical implementation. It differs from R28's projectile/delayed-hit pipeline. Difference alone does not prove which is better.

## F6. AI — code existence is not live scene wiring

Historical source:

```text
BattleEnemyAIController perception/intel/decision
  -> set_combat_target / issue_move / stop
  -> BattleFormation
  -> shared lower movement/combat execution
```

But current scene:

```text
Battle01.tscn
  - no EnemyAIController node/resource
  - M2 FormalCombatRoster explicitly: no supply / no reinforcements

historical enemy_ai_controller.gd
  - expects older objective/roster dependencies including supply/reinforcements
```

EDGE_ID=F-AI-01
STATUS=OBSERVED_GAP
GAP=Current main Battle01 does not evidence this historical controller as an active AI command producer.
EVIDENCE_REGISTER=E035

This directly implements the rule “file A and file B both exist does not prove A calls B.”

## F7. State -> HUD

```text
selection/order/health/ammo/intel/death/victory signals/state
  -> battle01.gd callbacks
  -> BattleHUD setters
  -> visible labels/panels
```

EDGE_ID=F-UI-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E036

## F8. Logic -> active 3D combat feedback — unresolved/gap

Observed logic side:
- `BattleFormation` maintains shot/death/under-fire state and 2D draw effects.
- `attack_fired`, `ammo_changed`, `health_changed`, `died` signals exist.

Observed active 3D side:
- scene formation nodes are alpha-hidden for 3D presentation;
- `Battle3DPresentation` renders separate proxy bodies/rings, objectives, last-known markers, smoke and command markers.

Not established:

```text
BattleFormation logical FIRE
  -> active 3D muzzle flash
  -> active 3D projectile/tracer
  -> active 3D impact effect
  -> active fire/impact audio
  -> camera feedback
```

EDGE_ID=F-PRESENT-01
STATUS=UNKNOWN
GAP=Layer-8 combat event to Layer-11 active 3D combat presentation is not source-closed.
EVIDENCE_REGISTER=E037

This is a concrete candidate explanation for “technically functioning but visually dead”, not yet a runtime diagnosis.

## F9. Camera/render shell

```text
Battle3DWorld
  -> DirectionalLight3D + WorldEnvironment + primitive scene
Battle3DPresentation
  -> MeshInstance3D proxies
BattleCamera3D
  -> current Camera3D
  -> FOV 49
  -> height 16 (8.5..27 zoom range)
  -> oblique look-at
  -> WASD pan / wheel zoom
```

EDGE_ID=F-RENDER-01
STATUS=OBSERVED
SOURCE=`battle_3d_world.gd`; `battle_3d_presentation.gd`; `battle_camera_3d.gd`

## F10. Current PLAYER boundary

```text
current main source chain
   |
   | F-PLAYER-01 UNKNOWN in Sprint 01
   v
actual current player-visible/operated Battle01 result
```

EDGE_ID=F-PLAYER-01
STATUS=UNKNOWN
REASON=No new Sprint-01 runtime capture/operation has been used to verify current end-to-end behavior/quality.
EVIDENCE_REGISTER=E038

---

# G. What is now genuinely learned vs still unknown

## Source-backed production knowledge from the first trace

1. A real authored map can be traced through loader code into simulation entities, render environment and camera state in R28.
2. A concrete unit can be traced from map template ID through inherited gameplay data and into actor/mesh/material/texture/animation definitions.
3. Player selection and attack action can be followed through GUI input into a typed command.
4. The previously missing GUI→turn command→`ProcessCommand` bridge is now directly source-backed.
5. Lower movement is explicitly UnitMotion→Pathfinder→Position.
6. Ranged attack source explicitly connects attack timer/animation→projectile parameters→delayed damage→effect receiver→Health/death.
7. Simulation Health can be followed into selected-unit HUD state.
8. VisualActor can be followed into UnitRenderer/SceneCollector.
9. R28 AI can produce typed commands that converge on the command queue without pretending AI is a mouse/selection controller.
10. FRONTLINE main has a source-closed MOVE/navigation chain, explicit historical combat chain and HUD-state chain, but its active visual-asset and 3D-combat-feedback links are substantially weaker than its simulation links.

These are source facts about inspected projects, not yet transfer recommendations.

## Remaining critical UNKNOWN / GAP

- `U-01`: exact v0.28.0 `UnitAI.Attack` command/FSM branch into movement and `Attack.StartAttacking` for the chosen player event.
- `U-02`: R28 automatic target acquisition/priority path, distinct from player-designated target legality.
- `U-03`: actual R28 player-visible runtime result for the chosen Combat Demo event.
- `U-04`: what currently produces RED AI decisions in current Battle01, if anything.
- `U-05`: whether an active Battle01 path consumes logical fire into 3D muzzle/projectile/impact/audio feedback.
- `U-06`: which apparent patterns survive concrete BAR/Recoil and Warzone counterexamples.
- `U-07`: whether these methods reproduce successfully under the independent 02 slice.

---

# H. 01 -> 02 gate state

A future 02 handoff must eventually include:

SOURCE=
MECHANISM=
INPUT=
PROCESS=
OUTPUT=
REQUIRED_ASSETS=
EXPECTED_RUNTIME_BEHAVIOR=
VISIBLE_RESULT=
KNOWN_LIMITS=
UNKNOWN=
REPRODUCTION_TEST=

Current decision:

`WINDOW_02_REPRODUCTION=BLOCKED`

Reason:
- the selected reference chain is substantially source-closed but still contains one critical UnitAI middle edge;
- final R28 PLAYER-layer runtime evidence is absent;
- the concrete BAR/Warzone falsification pass has not yet been performed;
- sending 02 now would force it to guess at least part of the production chain.

WINDOW_03_AUDIT=PENDING
PRODUCT_PRODUCTION_RESUME=NO
STATUS=CONTINUE_LEARNING
