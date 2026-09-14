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

This document is an edge graph, not a module catalogue. An adjacent pair of files is not an edge unless a call/data/runtime relation has been observed. `UNKNOWN` is retained only where evidence is still missing.

## Macro chain

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

## 13-layer coverage state

| Layer | 0 A.D. R28 selected player event | FRONTLINE main mapping |
|---|---|---|
| 1 Map / battle space | OBSERVED | OBSERVED |
| 2 Unit data | OBSERVED | OBSERVED |
| 3 Model/material binding | OBSERVED | OBSERVED GAP in active Battle01 path |
| 4 Player selection | OBSERVED | OBSERVED |
| 5 Command routing | OBSERVED | OBSERVED |
| 6 Pathfinding/movement | OBSERVED for selected attack | OBSERVED |
| 7 Detection/target | player target + automatic stance/range response OBSERVED; full global preference detail not exhausted | BLUE ADVANCE target logic OBSERVED; RED producer GAP |
| 8 Fire/hit/damage/death | OBSERVED | OBSERVED |
| 9 AI command generation | command injection OBSERVED; high-level strategy not part of selected player event | OBSERVED GAP: no active RED producer wired |
| 10 UI state | OBSERVED | OBSERVED |
| 11 Animation/VFX/audio | source hooks OBSERVED | transitional 2D FX OBSERVED; active 3D fire-feedback GAP |
| 12 Camera/render | actor->renderer submission OBSERVED | OBSERVED configuration |
| 13 Player result | UNKNOWN: no Sprint-01 runtime capture | UNKNOWN: no new Sprint-01 runtime capture |

---

# A. Release-28 first vertical event

## A0. Concrete event

The first event is intentionally small and real:

```text
Combat Demo loads
-> player has an Athenian elite marine archer
-> unit gameplay template binds its real actor assets
-> player selects the unit
-> contextual right-click resolves ATTACK on an enemy
-> typed attack command enters the engine/turn command queue
-> simulation dispatch calls UnitAI.Attack
-> UnitAI creates an Attack order
-> FSM chooses ATTACKING or APPROACHING
-> if needed, UnitMotion moves toward attack range through Pathfinder
-> FSM reaches COMBAT.ATTACKING
-> Attack.StartAttacking
-> ranged attack launches projectile and delayed hit
-> Damage reaches Health
-> HP/death state changes
-> UI/animation/projectile/audio/death presentation receives state/events
-> VisualActor reaches UnitRenderer/SceneCollector
-> actual player-visible runtime result [UNKNOWN IN THIS SPRINT]
```

The source path through renderer submission is now closed for the selected player-issued attack. The final PLAYER arrow remains UNKNOWN because this sprint has not yet produced its own Release-28 runtime interaction/capture.

---

# B. Upstream CONTENT -> WORLD

## B1. Map resource -> playable world

```text
Combat Demo scenario
    |
    | A-MAP-01 OBSERVED
    v
combat_demo.pmp + combat_demo.xml
    |
    v
CWorld / CMapReader
    |
    +--> terrain/environment/water/light/camera state
    |
    +--> simulation AddEntity(template, id)
              |
              +--> transform/orientation/owner
              v
        playable simulation entities
```

EDGE_ID=A-MAP-01
STATUS=OBSERVED
SOURCE=`maps/scenarios/combat_demo.xml`; `source/ps/World.cpp`; `source/graphics/MapReader.cpp`
EVIDENCE_REGISTER=E010

WHAT_IT_PROVES=An authored scenario resource becomes simulation entities plus render/world state through an explicit loader chain.
WHAT_IT_DOES_NOT_PROVE=All map families or a universal RTS map format.

## B2. Unit data -> gameplay component data

```text
Combat Demo entity template
units/athen/infantry_marine_archer_e
    |
    | A-DATA-01 OBSERVED
    v
leaf template
 -> parent/rank/civilization/mixins
 -> generic ranged archer template
 -> motion/attack/component data
```

EDGE_ID=A-DATA-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E011

## B3. Gameplay unit -> real production asset

```text
leaf VisualActor
    |
    | A-ASSET-01 OBSERVED
    v
athenian infantry actor XML
 -> skeletal .dae mesh
 -> head/bow/quiver/shield/arrow props
 -> base/spec/normal textures
 -> idle/ranged/death animations
 -> player_trans_norm_spec material
 -> model shader effect
```

EDGE_ID=A-ASSET-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E012

Boundary: this proves the selected R28 data/asset binding route. It does not make XML inheritance or this art pipeline a FRONTLINE design rule.

---

# C. INPUT -> COMMAND -> SIMULATION CONTROL

## C1. Selection

```text
mouse click
 -> Engine.PickEntityAtPoint
 -> selection add/remove/reset
 -> EntitySelection
 -> g_Selection entity IDs
```

EDGE_ID=A-SELECT-01
STATUS=OBSERVED
SOURCE=`gui/session/input.js`; `gui/session/selection.js`
EVIDENCE_REGISTER=E013

## C2. Contextual ATTACK command

```text
right click / contextual action
 -> determine/execute attack action
 -> g_Selection.toList() + target
 -> Engine.PostNetworkCommand({type:'attack', entities, target, ...})
```

EDGE_ID=A-CMD-01
STATUS=OBSERVED
SOURCE=`gui/session/input.js`; `gui/session/unit_actions.js`
EVIDENCE_REGISTER=E014

The action branch also requests the attack-order sound. That is command-feedback evidence, not hit/damage evidence.

## C3. GUI -> engine/turn -> simulation bridge

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
EVIDENCE_REGISTER=E015

## C4. Simulation dispatch -> UnitAI

```text
ProcessCommand(type='attack')
 -> controlled-entity filtering
 -> GuiInterface playercommand notification
 -> g_Commands.attack
 -> cmpUnitAI.Attack(target, allowCapture, queued, pushFront)
```

EDGE_ID=A-CMD-03
STATUS=OBSERVED
EVIDENCE_REGISTER=E016

---

# D. SIMULATION — exact selected attack chain

## D1. Former UnitAI middle UNKNOWN is closed

```text
cmpUnitAI.Attack(...)
 -> CanAttack / build forced player order
 -> AddOrder("Attack", order)
 -> ReplaceOrder / PushOrder
 -> UnitFsm.ProcessMessage("Order.Attack")
 -> GetBestAttackAgainst
 -> if already in range:
      INDIVIDUAL.COMBAT.ATTACKING
    else:
      INDIVIDUAL.COMBAT.APPROACHING
        -> MoveToTargetAttackRange
        -> UnitMotion.MoveToTargetRange
        -> MovementUpdate
        -> CheckTargetAttackRange
        -> ATTACKING
 -> COMBAT.ATTACKING.enter
 -> cmpAttack.StartAttacking(target, attackType, IID_UnitAI, force)
```

EDGE_ID=A-UNITAI-01
STATUS=OBSERVED
SOURCE=`simulation/components/UnitAI.js` pinned to v0.28.0 commit anchor
EVIDENCE_REGISTER=E017

The former wording `UnitAI.Attack -> ??? -> Attack.StartAttacking` is superseded and must not be reused.

WHAT_IT_DOES_NOT_PROVE=Formation-controller, packing/unpacking, hunting and failure-recovery branches are identical. The claim is limited to the selected player-issued attack path.

## D2. UnitMotion -> Pathfinder -> Position

```text
MoveToTargetAttackRange
 -> UnitMotion.MoveToTargetRange
 -> ComputePathToGoal / path request
 -> Pathfinder
 -> MT_PathResult
 -> movement update
 -> PerformMove
 -> Position.MoveAndTurnTo
 -> simulation transform changes
```

EDGE_ID=A-MOVE-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E018

## D3. Player target legality

```text
selected target ID
 -> GetBestAttackAgainst / CanAttack
 -> ownership/class/state checks
 -> attack-type legality
 -> range/height constraints
 -> valid attack type
```

EDGE_ID=A-TARGET-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E019

## D4. Automatic target response is a separate path

The same R28 UnitAI source shows that automatic response is not simply `enemy in range -> fire`:

```text
idle UnitAI
 -> active LOS/attack range query update
 -> LosAttackRangeUpdate
 -> stance.targetVisibleEnemies gate
 -> AttackEntitiesByPreference(...)
 -> attackability/preference filtering
 -> PushOrderFront("Attack", force=false)
 -> normal UnitAI combat path
```

Other stance behavior can react to being attacked, flee, hold ground or chase.

EDGE_ID=A-AUTOTARGET-01
STATUS=OBSERVED_FOR_RESPONSE_CHAIN
EVIDENCE_REGISTER=E027

UNKNOWN retained only for exhaustive global preference behavior across every state/formation; it is not a blocker for the selected player-issued event.

## D5. Attack launch -> projectile -> delayed hit

```text
Attack.StartAttacking
 -> attack timer + attack_<type> animation
 -> PerformAttack
 -> target prediction / spread / speed / gravity / travel time
 -> projectile presentation launch
 -> scheduled DelayedDamage payload
 -> DelayedDamage.Hit
```

EDGE_ID=A-FIRE-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E020

Negative evidence preserved:
- this selected 0 A.D. path does not establish `Ammo -1 / shot`;
- it does not establish deterministic hit;
- FRONTLINE's direct deterministic/ammo model remains project-specific evidence.

## D6. Hit -> effects -> Health -> death

```text
DelayedDamage.Hit
 -> AttackHelper.HandleAttackEffects
 -> Damage effect mapping
 -> IID_Health.TakeDamage
 -> Health reduction
 -> lethal state
 -> death/corpse behavior
```

EDGE_ID=A-DAMAGE-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E021

---

# E. STATE -> PRESENTATION -> RENDER

## E1. Health -> UI

```text
Health component
 -> GuiInterface.GetEntityState
 -> hitpoints / maxHitpoints
 -> selection_details.js
 -> visible selected-unit health display
```

EDGE_ID=A-UI-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E022

## E2. Combat facts -> perceptual feedback hooks

```text
attack command -> order_attack sound
actual attack  -> attack_<type> actor animation
ranged fire    -> projectile presentation
impact         -> impact sound/effect route
death          -> death sound + death/corpse presentation
```

EDGE_ID=A-PRESENT-01
STATUS=OBSERVED_AT_SOURCE_LEVEL
EVIDENCE_REGISTER=E023

This is not a perceptual-quality PASS. Source hooks do not prove weight/readability without runtime observation.

## E3. VisualActor -> renderer submission

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
EVIDENCE_REGISTER=E024

## E4. PLAYER boundary

```text
SceneCollector + GUI + map camera/environment + audio
   |
   | A-PLAYER-01 UNKNOWN in Sprint 01
   v
actual running Combat Demo event as seen/heard by player
```

EDGE_ID=A-PLAYER-01
STATUS=UNKNOWN
REASON=No independent Sprint-01 runtime capture/interaction artifact has yet been produced.
EVIDENCE_REGISTER=E025

The source trace cannot be promoted to `REPRODUCED` or learning PASS.

---

# F. AI side branch and counterexamples

## F1. 0 A.D. AI enters below human selection/UI

```text
AI high-level reasoning [not traced in this player slice]
 -> common-api entity.move/attack
 -> Engine.PostCommand
 -> CCmpAIManager command buffer
 -> PushCommands
 -> ICmpCommandQueue.PushLocalCommand
 -> ProcessCommand downstream
 -> same simulation handlers
```

EDGE_ID=A-AI-01
STATUS=OBSERVED_FOR_COMMAND_INJECTION
EVIDENCE_REGISTER=E026

0 A.D. therefore does not itself support the claim that AI must impersonate a mouse or use the player's `g_Selection` layer.

## F2. BAR/Recoil counterexample

BAR has enabled synced game logic whose boss/queen targeting code does:

```text
GameFrame
 -> find alive queen
 -> GetUnitsInSphere
 -> choose commander-class target
 -> Spring.GiveOrderToUnit(queen, CMD.STOP)
 -> Spring.GiveOrderToUnit(queen, CMD.ATTACK, target)
```

Recoil's synced engine control implements that boundary as:

```text
Spring.GiveOrderToUnit
 -> parse target unit / control permission
 -> LuaUtils::ParseCommand
 -> unit->commandAI->GiveCommand(...)
```

EDGE_ID=V-BAR-CMD-01
STATUS=OBSERVED
SOURCE=`BAR/luarules/gadgets/pve_boss_priority_targetting.lua`; `RecoilEngine/rts/Lua/LuaSyncedCtrl.cpp`
EVIDENCE_REGISTER=E039,E040

## F3. Warzone counterexample

Warzone Cobra skirmish AI does real tactical checks in JS:

```text
eventAttacked
 -> enemy/alliance checks
 -> local ally/enemy count
 -> retreat/reachability/distance/personality checks
 -> orderDroidObj(unit, DORDER_ATTACK, attacker)
    or orderDroidLoc(unit, DORDER_SCOUT/MOVE, x, y)
```

Native order code then accepts DROID_ORDER data and for attack orders transitions to attack directly when appropriate or moves toward the target first.

EDGE_ID=V-WZ-CMD-01
STATUS=OBSERVED
SOURCE=`Warzone2100/data/mp/multiplay/skirmish/cobra_includes/events.js`; `src/wzapi.cpp`; `src/order.cpp`
EVIDENCE_REGISTER=E041

## F4. What survives the counterexamples

Supported only as a narrow inference:

```text
AI / automated decision
 -> game-recognized command/order execution boundary
 -> normal unit execution machinery
```

But the location and implementation differ:

```text
0 A.D. : AI API -> AI manager buffer -> shared command queue -> ProcessCommand
BAR/Recoil: synced Lua -> Spring.GiveOrderToUnit -> per-unit commandAI
Warzone: JS AI -> orderDroid* API -> native DROID_ORDER/action machinery
```

EDGE_ID=V-CROSS-CMD-01
STATUS=INFERRED
EVIDENCE_REGISTER=E042

REJECTED_GENERALIZATION=`AI must pass through the exact same top-level human selection/input controller.`
REJECTED_GENERALIZATION=`Every RTS should use 0 A.D.'s turn command queue architecture.`

No engine/architecture transfer decision follows from this inference alone.

---

# G. FRONTLINE main mapping

Battle01 is valid E0 implementation evidence because it is current repository main, but V30 explicitly says it is not automatic product-design authority.

## G1. Boot / world

```text
project.godot
 -> res://scenes/battle01/Battle01.tscn
 -> World3D / BattleCamera3D / Presentation3D
 -> Navigation / Visibility / formations / HUD / Input3D

Battle3DWorld._ready
 -> lighting/environment
 -> primitive ground
 -> roads/river/bridge
 -> blocker geometry
 -> industrial/rear primitives
```

EDGE_ID=F-MAP-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E030,E031

## G2. Unit data

```text
resources/formations/*.tres
 -> FormationDefinition
 -> Battle01 formation.definition
 -> BattleFormation._apply_definition
 -> HP/speed/damage/range/fire interval/ammo/detection/etc.
```

EDGE_ID=F-DATA-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E032

## G3. Active unit visual binding — observed production gap

```text
formation role
 -> Battle3DPresentation._mesh_for_role
 -> CylinderMesh / BoxMesh
 -> runtime StandardMaterial3D
 -> MeshInstance3D proxy
```

EDGE_ID=F-ASSET-01
STATUS=OBSERVED_GAP
EVIDENCE_REGISTER=E031

GAP=The active Battle01 path has no production unit `imported mesh -> texture set -> material/shader -> animation` chain.

Boundary: this does not mean the repository contains no historical/imported assets; it describes the active current path only.

## G4. Player select -> MOVE -> navigation -> transform

```text
LMB 3D/projection pick
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

Correction retained: Core `NavigationService` really is connected. Code existence alone remains insufficient for other Core services.

## G5. BLUE ADVANCE -> target -> combat -> state

```text
player ADVANCE
 -> BLUE combat formation only
 -> known RED target list
 -> Intel == CONFIRMED
 -> live/faction/range/LOS checks
 -> nearest legal target
 -> formation.set_combat_target
 -> BattleFormation._update_combat
 -> hold-fire / attack / ammo / range / LOS / cooldown gates
 -> Ammo -1
 -> damage
 -> target.take_damage
 -> HP
 -> _die at zero
```

EDGE_ID=F-COMBAT-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E034

This direct synchronous model differs from R28's UnitAI/Attack/projectile/delayed-hit chain. Difference alone is not a quality verdict.

## G6. RED AI/control — now an observed source gap

Historical source exists:

```text
enemy_ai_controller.gd
 -> perception/decision
 -> set_combat_target / issue_move / stop
 -> BattleFormation execution
```

Current loaded scene/source instead shows:

```text
Battle01.tscn
 -> no EnemyAIController node/resource

FormalCombatRoster
 -> creates/positions RED formations
 -> no tactical move/target orders

PlayerWarFlow
 -> tracks RED for objective/counterattack/victory
 -> stops formations only at match finish

SelectionController
 -> selection / MOVE / ADVANCE restricted to BLUE
 -> RED entities only appear as targets

BattleFormation
 -> attacks only if _combat_target was assigned externally
 -> no autonomous enemy scan/target producer
```

EDGE_ID=F-AI-01
STATUS=OBSERVED_GAP
EVIDENCE_REGISTER=E035

GAP=Current main Battle01 has RED combat formations but no source-wired RED tactical decision/command producer in the active scene.

This conclusion is source-level. A new runtime capture is still required before claiming the exact visible runtime outcome.

## G7. State -> HUD

```text
selection/order/health/ammo/intel/death/victory state
 -> battle01 callbacks/signals
 -> BattleHUD setters/queries
 -> visible labels/panels
```

EDGE_ID=F-UI-01
STATUS=OBSERVED
EVIDENCE_REGISTER=E036

## G8. Logical FIRE -> presentation — the exact gap is now known

Logical combat contains transitional 2D feedback:

```text
BattleFormation._update_combat
 -> _shot_fx_target
 -> _shot_fx_remaining
 -> attack_fired

BattleFormation._draw_combat_fx
 -> tracer/glow line
 -> muzzle flash
 -> impact rings/debris
 -> under-fire arc

_die
 -> death FX timer
```

But the active 3D shell does this:

```text
Battle01 / Battle3DPresentation
 -> formation CanvasItem visually hidden (alpha 0)
 -> separate MeshInstance3D proxies are rendered

attack_fired
 -> battle01._on_attack_fired
 -> RED intel exposure + first-combat log
 -> NO call into Battle3DPresentation fire FX

Battle3DPresentation
 -> proxy bodies
 -> selection rings
 -> objective
 -> intel last-known markers
 -> smoke
 -> command markers
 -> NO attack_fired connection
 -> NO shot-state consumer
```

Therefore:

```text
Layer 8 logical fire
   |
   +--> transitional hidden 2D combat FX [OBSERVED]
   |
   X--> active 3D muzzle/tracer/projectile/impact feedback [OBSERVED GAP]
```

EDGE_ID=F-PRESENT-01
STATUS=OBSERVED_GAP
EVIDENCE_REGISTER=E037

Audio/camera fire feedback is not established in the active traced 3D path; the claim is deliberately scoped to the inspected current Battle01 source.

## G9. Camera/render shell

```text
Battle3DWorld
 -> DirectionalLight3D + WorldEnvironment + primitive scene
Battle3DPresentation
 -> MeshInstance3D proxies
BattleCamera3D
 -> current Camera3D
 -> FOV 49
 -> height / pan / wheel zoom
 -> oblique look-at
```

EDGE_ID=F-RENDER-01
STATUS=OBSERVED
SOURCE=`battle_3d_world.gd`; `battle_3d_presentation.gd`; `battle_camera_3d.gd`

## G10. FRONTLINE PLAYER boundary

```text
current main source chain
   |
   | F-PLAYER-01 UNKNOWN in Sprint 01
   v
actual current player-visible/operated Battle01 result
```

EDGE_ID=F-PLAYER-01
STATUS=UNKNOWN
REASON=No new Sprint-01 runtime capture/operation has verified the current end-to-end visible result.
EVIDENCE_REGISTER=E038

---

# H. What is genuinely learned now

Source-backed, bounded knowledge from this first trace:

1. A real authored scenario can be traced through loader code into simulation entities, render environment and camera state in R28.
2. A concrete unit can be traced from map template ID through inherited gameplay data into actor/mesh/material/texture/animation definitions.
3. Player selection and contextual ATTACK can be followed through GUI input into a semantic typed command.
4. GUI command transport is source-closed through the C++ command/turn boundary into `ProcessCommand`.
5. The exact selected `UnitAI.Attack` FSM bridge is now source-closed into range movement and `Attack.StartAttacking`.
6. Movement is connected through UnitMotion -> Pathfinder -> Position.
7. Ranged attack connects animation/timing -> projectile -> delayed hit -> effect receiver -> Health/death.
8. Health reaches selected-unit HUD state.
9. VisualActor reaches UnitRenderer/SceneCollector.
10. R28 automatic target response is stance/LOS/range-query mediated; it is not equivalent to simply detecting an enemy in range.
11. 0 A.D., BAR/Recoil and Warzone provide counterexamples to the claim that AI must use the human selection/input layer or one universal command-queue architecture.
12. The narrow cross-project commonality currently supported is an AI/automated-decision handoff into a game-recognized command/order execution boundary.
13. FRONTLINE current main has a real MOVE/navigation chain, BLUE ADVANCE/combat chain and HUD-state chain.
14. FRONTLINE current active Battle01 has three specific source-level gaps relevant to the player result: production asset binding, RED tactical command production, and logical-fire -> active 3D combat feedback.

None of these statements is yet a recommendation to copy 0 A.D., BAR/Recoil or Warzone architecture.

---

# I. Remaining critical UNKNOWN / work

## U-PLAYER-R28
Actual R28 Combat Demo selected-event player-visible runtime capture remains UNKNOWN.

## U-PLAYER-FRONTLINE
Actual current Battle01 player-visible result under a new Sprint-01 operation/capture remains UNKNOWN.

## U-R28-PREFERENCE-DETAIL
Exhaustive automatic target preference across every R28 state/formation is not fully traced. This is no longer required to close the selected player-issued event.

## U-ENGINE
Whether FRONTLINE should retain Godot remains UNKNOWN and must not be inferred from these source architectures.

## U-REPRODUCTION
Whether the learned bounded mechanisms can be independently reproduced by Window 02 on different content remains UNKNOWN until an actual runnable artifact exists.

---

# J. 01 -> 02 handoff gate

The selected player attack source chain is now concrete enough to construct a reproduction candidate packet without asking Window 02 to invent the former UnitAI middle bridge.

A handoff must contain:

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

Current control state:

```text
FIRST_REFERENCE_SELECTED_EVENT_SOURCE_CHAIN=CLOSED_THROUGH_RENDER_SUBMISSION
BAR_RECOIL_WARZONE_COUNTEREXAMPLE_PASS=OBSERVED
FRONTLINE_LAYER_3_ASSET_BINDING=OBSERVED_GAP
FRONTLINE_LAYER_9_RED_CONTROL=OBSERVED_GAP
FRONTLINE_LAYER_11_ACTIVE_3D_FIRE_FEEDBACK=OBSERVED_GAP
R28_PLAYER_RUNTIME=PENDING
FRONTLINE_PLAYER_RUNTIME=PENDING
WINDOW_03_AUDIT=PENDING
WINDOW_01_TO_02_HANDOFF_CANDIDATE=POSSIBLE
WINDOW_02_START=REQUIRES_PROJECT_CONTROL_ROUTING
PRODUCT_PRODUCTION_RESUME=NO
STATUS=CONTINUE_LEARNING
```

Window 01 does not self-authorize Sprint PASS or product transfer. Window 03 must still audit the new source claims and Window 00 retains routing/integration authority.
