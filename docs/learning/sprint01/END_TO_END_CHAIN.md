# LEARNING SPRINT 01 — END TO END CHAIN

STATUS=CONTINUE_LEARNING
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
EVIDENCE_REGISTER=docs/learning/sprint01/EVIDENCE_REGISTER.md
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md
PRIMARY_REFERENCE=0_AD_RELEASE_28
PRIMARY_REFERENCE_VERSION=v0.28.0
PRIMARY_REFERENCE_COMMIT_ANCHOR=a2cae4d69f
FRONTLINE_MAIN_INSPECTED=06710c3d9e29d3400572bf25ed5e8fd96c73b472

## Macro chain

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

This file is an edge graph. It does not treat directory/file presence as proof of a call relation.

## Required 13 layers

1. MAP_LOADING_AND_BATTLE_SPACE
2. UNIT_DATA_SOURCE_OF_TRUTH
3. MODEL_MATERIAL_ASSET_BINDING
4. PLAYER_SELECTION
5. COMMAND_ROUTING
6. PATHFINDING_AND_MOVEMENT
7. DETECTION_AND_TARGET_SELECTION
8. FIRE_HIT_DAMAGE_DEATH
9. AI_COMMAND_GENERATION
10. UI_STATE_ACQUISITION
11. ANIMATION_VFX_AUDIO_FEEDBACK
12. CAMERA_AND_RENDER_PRESENTATION
13. FINAL_PLAYER_VISIBLE_RESULT

## Evidence rule

For each arrow below, `OBSERVED` means the specific relation is visible in the inspected versioned source/artifact. `UNKNOWN` means the adjacent endpoints may both exist, but the relation between them has not yet been proved. Tests prove only the behavior/interface exercised by the test; they do not automatically prove a live-match caller chain.

---

# A. First Release-28 vertical trace — current state

## A0. Version identity

Official Release-28 source distribution:

- https://play0ad.com/download/source/
- `0ad-0.28.0-unix-build.*`
- `0ad-0.28.0-unix-data.*`

Version-matched inspected source tag:

- `v0.28.0`
- public pull mirror path: `https://git.phylogix.dev/gptbot/0ad/src/tag/v0.28.0/`
- commit anchor: `a2cae4d69f`

The archived GitHub `0ad/0ad` master is not used as Release-28 implementation evidence.

## A1. Current edge graph

```text
UPSTREAM CONTENT / WORLD

specific Release-28 map
  --[A-MAP-01 UNKNOWN]-->
loaded battle space / terrain / placed entities / pathfinder world

specific chosen unit template
  --[A-DATA-01 UNKNOWN]-->
template inheritance + simulation components

specific chosen unit template
  --[A-ASSET-01 UNKNOWN]-->
VisualActor -> actor definition -> mesh/material/texture/animation


PLAYER INPUT

mouse left click
  --[A-IN-01 OBSERVED: input.js Engine.PickEntityAtPoint + selection calls]-->
picked entity id(s)
  --[A-IN-02 OBSERVED: selection.js EntitySelection.addList]-->
g_Selection.selected

right click / contextual action
  --[A-CMD-01 OBSERVED: input.js determineAction/doAction/handleUnitAction]-->
attack action + selected entity list + target
  --[A-CMD-02 OBSERVED: unit_actions.js attack.execute]-->
Engine.PostNetworkCommand({type:'attack', entities, target, ...})

Engine.PostNetworkCommand
  --[A-CMD-03 UNKNOWN]-->
engine / turn / network command transport
  --[A-CMD-04 UNKNOWN]-->
ProcessCommand(player, cmd)

ProcessCommand(type='attack')
  --[A-CMD-05 OBSERVED: simulation/helpers/Commands.js]-->
g_Commands.attack
  --[A-CMD-06 OBSERVED: Commands.js]-->
cmpUnitAI.Attack(target, allowCapture, queued, pushFront)


SIMULATION / MOVEMENT / TARGET

cmpUnitAI.Attack(...)
  --[A-AI-01 UNKNOWN for chosen event]-->
UnitAI order/FSM branch
  --[A-MOVE-01 UNKNOWN for chosen event]-->
UnitMotion / target-range closure / Pathfinder

RangeManager + Vision + Attack + UnitMotion + Health interfaces
  --[A-TEST-01 OBSERVED IN COMPONENT TEST ONLY: test_UnitAI.js]-->
UnitAI tested transition to INDIVIDUAL.COMBAT.ATTACKING for a live enemy

UnitAI attacking state
  --[A-ATK-01 UNKNOWN for chosen event]-->
Attack.StartAttacking / actual attack launch

Attack component data + target
  --[A-ATK-02 OBSERVED IN COMPONENT TEST: test_Attack.js]-->
CanAttack / best attack / range / prepare-repeat timing / projectile-effect data

actual attack launch
  --[A-ATK-03 UNKNOWN]-->
projectile or scheduled DelayedDamage payload
  --[A-ATK-04 OBSERVED downstream: DelayedDamage.js]-->
DelayedDamage.Hit
  --[A-DMG-01 OBSERVED: DelayedDamage.js + helpers/Attack.js]-->
AttackHelper.HandleAttackEffects
  --[A-DMG-02 PARTIAL: receiver mapping observed in test_Attack.js]-->
Damage receiver / Health.TakeDamage

Health component reduction
  --[A-STATE-01 OBSERVED IN COMPONENT TEST: test_Health.js]-->
HP reduction -> zero HP -> death/corpse behavior

Health.TakeDamage
  --[A-STATE-02 UNKNOWN internal edge]-->
Health.Reduce for the chosen runtime event


PRESENTATION / RENDER / PLAYER

attack action execute
  --[A-PRES-01 OBSERVED: unit_actions.js]-->
order_attack sound request

DelayedDamage.Hit
  --[A-PRES-02 OBSERVED: DelayedDamage.js]-->
attack impact sound request

ProcessCommand
  --[A-UI-01 OBSERVED: Commands.js]-->
GuiInterface playercommand notification

AttackHelper.HandleAttackEffects
  --[A-PRES-03 OBSERVED: helpers/Attack.js]-->
MT_Attacked simulation message

selection state
  --[A-PRES-04 OBSERVED: selection.js]-->
highlight/status-bar/selection feedback state

combat state/messages
  --[A-PRES-05 UNKNOWN]-->
chosen unit actor animation + projectile/VFX + actual HUD widget changes
  --[A-RENDER-01 UNKNOWN]-->
camera/renderer composition
  --[A-PLAYER-01 UNKNOWN]-->
runtime player-visible combat result
```

## A2. Critical Release-28 edge records

### A-IN-01 / A-IN-02

EDGE_ID=A-IN-01,A-IN-02
FROM=mouse left click
TO=`g_Selection` selected entity IDs
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 source
SOURCE_LOCATION=`binaries/data/mods/public/gui/session/input.js`; `gui/session/selection.js`
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=`input.js` uses `Engine.PickEntityAtPoint`; click selection calls selection add/remove/reset; `EntitySelection.addList` stores accepted IDs and updates selection presentation state.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The stock session GUI input-to-selection relation.
WHAT_IT_DOES_NOT_PROVE=Every selection mode or any universal RTS rule.
HIDDEN_ASSUMPTIONS=No mod replaces stock GUI code during the future reproduction.
ALTERNATIVE_EXPLANATION=Modded GUI can alter behavior.
COUNTEREXAMPLE_SEARCH=PENDING_BAR_WARZONE
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Stock 0 A.D. Release 28 routes session pointer selection through entity picking into `g_Selection`.
FRONTLINE_MAPPING=Historical Battle01 uses projected 3D proxy positions and `BattleSelectionController.select_only/add_to_selection`.
GAP=No transfer decision.
REPRODUCTION_REQUIRED=YES

### A-CMD-01 / A-CMD-02

EDGE_ID=A-CMD-01,A-CMD-02
FROM=contextual right-click attack action
TO=`Engine.PostNetworkCommand` attack payload
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 source
SOURCE_LOCATION=`gui/session/input.js`; `gui/session/unit_actions.js`
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=Right mouse release calls action determination/execution; `handleUnitAction` supplies `g_Selection.toList()`; attack action posts a typed attack payload and requests order-attack audio.
WHAT_THE_SOURCE_ACTUALLY_PROVES=GUI-side action-to-command construction.
WHAT_IT_DOES_NOT_PROVE=Engine/network/turn transport after the post.
HIDDEN_ASSUMPTIONS=None for the local function relation.
ALTERNATIVE_EXPLANATION=Different action type branches can be chosen by contextual checks.
COUNTEREXAMPLE_SEARCH=PENDING_BAR_WARZONE
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 stock GUI builds and posts a typed attack command containing the selected entities and target.
FRONTLINE_MAPPING=Historical Battle01 right-click path currently issues MOVE/ADVANCE directly through SelectionController; no equivalent typed player ATTACK envelope is evidenced there.
GAP=Next transport edge is UNKNOWN.
REPRODUCTION_REQUIRED=YES

### A-CMD-03 / A-CMD-04

EDGE_ID=A-CMD-03,A-CMD-04
FROM=`Engine.PostNetworkCommand`
TO=`ProcessCommand(player, cmd)`
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=PENDING
SOURCE_LOCATION=Release-28 `source/` script binding / turn manager / command transport — not yet identified
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=UNKNOWN
RUNTIME_SEMANTICS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Only the two endpoints are observed in separate inspected files.
WHAT_IT_DOES_NOT_PROVE=That a direct call exists or which turn/network components intervene.
HIDDEN_ASSUMPTIONS=Matching command names/payloads are insufficient to establish the arrow.
ALTERNATIVE_EXPLANATION=Single-player/local and multiplayer paths may share or split transport internals.
COUNTEREXAMPLE_SEARCH=NOT_YET_APPLICABLE
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=UNKNOWN: the GUI post and simulation consumer are both observed, but their exact Release-28 bridge is not yet established.
FRONTLINE_MAPPING=No mapping asserted.
GAP=CRITICAL_FIRST_TRACE_BREAK
REPRODUCTION_REQUIRED=YES

### A-CMD-05 / A-CMD-06

EDGE_ID=A-CMD-05,A-CMD-06
FROM=`ProcessCommand` with `type='attack'`
TO=`cmpUnitAI.Attack(...)`
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 source
SOURCE_LOCATION=`binaries/data/mods/public/simulation/helpers/Commands.js`
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=`ProcessCommand` filters controlled entities and dispatches `g_Commands[cmd.type]`; attack handler resolves formation/unit AIs and invokes `cmpUnitAI.Attack`.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Simulation-side typed-command dispatch into UnitAI.
WHAT_IT_DOES_NOT_PROVE=How the player GUI command reached ProcessCommand.
HIDDEN_ASSUMPTIONS=None for this local dispatch relation.
ALTERNATIVE_EXPLANATION=ProcessCommand can have callers other than the player's GUI transport.
COUNTEREXAMPLE_SEARCH=PENDING_BAR_WARZONE
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Once an attack command is inside Release-28 `ProcessCommand`, it is dispatched to `UnitAI.Attack`.
FRONTLINE_MAPPING=Battle01 player path does not evidence this same command-table layer.
GAP=Transport before this edge and UnitAI execution after this edge remain incomplete.
REPRODUCTION_REQUIRED=YES

### A-TEST-01

EDGE_ID=A-TEST-01
FROM=RangeManager/UnitMotion/Vision/Attack/Health test interfaces
TO=real UnitAI component combat FSM behavior
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 component test
SOURCE_LOCATION=`simulation/components/tests/test_UnitAI.js`
SOURCE_TYPE=SOURCE_CODE_TEST
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=The test loads real `UnitAI.js`, mocks its collaborating interfaces, establishes an attack-range query and verifies an attacking FSM state with a live enemy and return to idle after target death.
WHAT_THE_SOURCE_ACTUALLY_PROVES=UnitAI's tested interaction contracts and state behavior.
WHAT_IT_DOES_NOT_PROVE=The chosen live event's exact UnitAI command branch, pathfinder execution or attack-launch call chain.
HIDDEN_ASSUMPTIONS=Tests describe intended component behavior but are not a rendered live match.
ALTERNATIVE_EXPLANATION=Other UnitAI states/stances/formation paths can take different branches.
COUNTEREXAMPLE_SEARCH=PENDING
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 UnitAI tests prove component interaction contracts, not the full live player-order chain.
FRONTLINE_MAPPING=Battle01 combines order/movement/combat state inside `BattleFormation` plus external selection/AI controllers.
GAP=CRITICAL_UNITAI_SOURCE_BRANCH_PENDING
REPRODUCTION_REQUIRED=YES

### A-ATK-04 / A-DMG-01

EDGE_ID=A-ATK-04,A-DMG-01
FROM=`DelayedDamage.Hit`
TO=`AttackHelper.HandleAttackEffects`
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 source
SOURCE_LOCATION=`simulation/components/DelayedDamage.js`; `simulation/helpers/Attack.js`
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=Delayed hit handles impact/splash/collision and invokes effect application; helper computes/applies registered effects and posts the attacked message.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Downstream hit-to-effect application.
WHAT_IT_DOES_NOT_PROVE=How the chosen attack launch produced the delayed hit.
HIDDEN_ASSUMPTIONS=None for local calls.
ALTERNATIVE_EXPLANATION=Different attack/effect types can follow capture/status/splash branches.
COUNTEREXAMPLE_SEARCH=PENDING
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 delayed-hit code feeds the attack-effect helper; the launch-to-hit edge remains separately unknown.
FRONTLINE_MAPPING=Battle01 historical combat resolves damage synchronously inside `BattleFormation._update_combat` rather than an observed projectile-delay pipeline.
GAP=ATTACK_LAUNCH_TO_DELAYED_HIT_UNKNOWN
REPRODUCTION_REQUIRED=YES

### A-STATE-01

EDGE_ID=A-STATE-01
FROM=Health reduction
TO=HP/death/corpse state
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 component test
SOURCE_LOCATION=`simulation/components/tests/test_Health.js`
SOURCE_TYPE=SOURCE_CODE_TEST
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=Real Health component is instantiated; nonlethal reduction changes HP; lethal reduction reaches zero and creates corpse behavior under the test template.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Actual Health component reduction/death semantics under test.
WHAT_IT_DOES_NOT_PROVE=The uninspected `Health.TakeDamage -> Reduce` internal edge for the chosen live event.
HIDDEN_ASSUMPTIONS=None beyond test scope.
ALTERNATIVE_EXPLANATION=Other death types/components/templates may differ.
COUNTEREXAMPLE_SEARCH=PENDING
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 Health tests demonstrate HP reduction and lethal transition behavior; receiver-to-reduction entry remains to be traced.
FRONTLINE_MAPPING=Battle01 `take_damage` subtracts HP, emits state, then `_die` at zero.
GAP=DAMAGE_RECEIVER_TO_HEALTH_REDUCTION_NOT_FULLY_CLOSED
REPRODUCTION_REQUIRED=YES

### A-PRES-05 / A-RENDER-01 / A-PLAYER-01

EDGE_ID=A-PRES-05,A-RENDER-01,A-PLAYER-01
FROM=combat state/events
TO=final visible combat result
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=PENDING
SOURCE_LOCATION=chosen unit actor/animation/VFX + GUI consumers + camera/renderer + runtime capture
SOURCE_TYPE=SOURCE_CODE + DATA + RUNTIME
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=UNKNOWN
RUNTIME_SEMANTICS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Only partial feedback edges are currently observed: selection highlight/status state, order-attack audio, impact audio, playercommand notification and attacked message.
WHAT_IT_DOES_NOT_PROVE=Actual chosen-unit animation/projectile/VFX/HUD/camera/render composition or the final player-visible result.
HIDDEN_ASSUMPTIONS=Do not infer visual behavior from simulation event names.
ALTERNATIVE_EXPLANATION=Presentation may be driven by actor event data, renderer systems or GUI polling paths not yet inspected.
COUNTEREXAMPLE_SEARCH=PENDING
COUNTEREXAMPLE_RESULT=PENDING
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=UNKNOWN: the Release-28 trace has not yet reached a verified PLAYER-visible combat result.
FRONTLINE_MAPPING=Historical Battle01 also has an unclosed logical-fire→3D-combat-feedback→PLAYER edge.
GAP=CRITICAL_END_OF_CHAIN_BREAK
REPRODUCTION_REQUIRED=YES

---

# B. FRONTLINE current repository mapping — evidence, not design authority

`project.godot` currently boots `Battle01.tscn`, so Battle01 can be inspected as E0 repository/runtime implementation. `START_HERE.md` / current governance warns that old Battle01/Prototype/Golden Scene artifacts do not automatically define current product design. The mapping below therefore says what code exists, not what FRONTLINE should become.

## B1. Source-closed historical Battle01 chain

```text
project.godot run/main_scene
  --[F-MAP-01 OBSERVED]-->
scenes/battle01/Battle01.tscn
  --[F-MAP-02 OBSERVED]-->
World3D + Camera3D + Presentation3D + Navigation + SelectionController + Input3D + HUD + formation nodes

FormationDefinition .tres
  --[F-DATA-01 OBSERVED: scene definition binding + Formation._apply_definition]-->
BattleFormation runtime stats

Formation role + world construction rules
  --[F-ASSET-01 OBSERVED]-->
procedural CylinderMesh/BoxMesh/TorusMesh + runtime StandardMaterial3D
  --[F-ASSET-02 GAP]-->
production unit mesh/material/texture/shader/LOD asset chain

3D LMB screen position
  --[F-IN-01 OBSERVED: Battle3DInput._pick_formation_at_screen]-->
BattleFormation proxy
  --[F-IN-02 OBSERVED]-->
BattleSelectionController selected array

3D RMB ground
  --[F-CMD-01 OBSERVED]-->
SelectionController.issue_move
  --[F-MOVE-01 OBSERVED]-->
BattleFormation.issue_move
  --[F-MOVE-02 OBSERVED]-->
BattleNavigation.find_path_for_formation
  --[F-MOVE-03 OBSERVED]-->
NavigationService.find_path
  --[F-MOVE-04 OBSERVED]-->
BattleFormation._move_path
  --[F-MOVE-05 OBSERVED]-->
_update_movement -> global_position

player ADVANCE intent
  --[F-TARGET-01 OBSERVED]-->
confirmed intel + range + LOS target selection
  --[F-TARGET-02 OBSERVED]-->
BattleFormation.set_combat_target

combat target
  --[F-COMBAT-01 OBSERVED]-->
hold-fire / can_attack / ammo / range / LOS / cooldown gates
  --[F-COMBAT-02 OBSERVED]-->
ammo - 1 + attack_fired + calculated damage
  --[F-STATE-01 OBSERVED]-->
target.take_damage -> HP -> _die -> DESTROYED + died signal

selection/order/health/ammo/intel/death/victory signals
  --[F-UI-01 OBSERVED: battle01.gd callbacks]-->
HUD setters / command feedback

Enemy AI decision
  --[F-AI-01 OBSERVED: enemy_ai_controller.gd]-->
set_combat_target / issue_move / stop directly on BattleFormation
  --[F-AI-02 OBSERVED]-->
shared low-level movement/combat execution

logical fire / death state
  --[F-PRES-01 UNKNOWN to current 3D combat presentation]-->
3D muzzle/projectile/impact/death feedback
  --[F-RENDER-01 UNKNOWN by runtime in this sprint]-->
Camera/Forward+ rendered frame
  --[F-PLAYER-01 UNKNOWN]-->
actual current player-visible combat experience
```

## B2. FRONTLINE layer diagnosis from current source

| Layer | Current inspected evidence | Status | Concrete gap / caution |
|---|---|---|---|
| 1 Map/world | `project.godot -> Battle01.tscn`; `Battle3DWorld` procedurally constructs ground/roads/river/bridge/blockers/lighting | OBSERVED | This is an inspectable historical runtime, not current product-design authority. |
| 2 Unit data | `FormationDefinition` Resource + `.tres`; `Formation._apply_definition` | OBSERVED | Future product schema not frozen. |
| 3 Asset binding | `Battle3DPresentation._mesh_for_role` creates primitives; runtime StandardMaterial3D | OBSERVED | No production unit model→material→texture→shader→LOD chain in this path. |
| 4 Selection | 3D projection/picking -> SelectionController | OBSERVED | Runtime usability not reproduced in this sprint. |
| 5 Command | Player MOVE/ADVANCE enters SelectionController then formation methods | OBSERVED | Core `TaskCommandService` file existence does not prove this Battle01 path uses it. |
| 6 Movement | formation -> BattleNavigation -> NavigationService -> waypoint updates | OBSERVED | Runtime movement quality/performance not established by source alone. |
| 7 Target | ADVANCE uses confirmed intel + range + LOS + deterministic tie handling | OBSERVED | Player explicit ATTACK-click route is not the same as this ADVANCE target path. |
| 8 Combat | Formation performs ammo/cooldown/range/LOS/damage/HP/death | OBSERVED | This is historical implementation, not universal or current frozen design. |
| 9 AI | EnemyAI chooses target/mission and calls formation methods directly | OBSERVED | AI converges with player at lower-level execution, not the same SelectionController entry. Do not call that inherently wrong. |
| 10 UI | battle01.gd signal/callback wiring to HUD | OBSERVED | Runtime visual correctness not yet reproduced. |
| 11 Feedback | logical 2D presentation state exists; 3D proxy presentation exists | UNKNOWN for complete combat feedback | Need prove fire/death event -> 3D visible VFX/audio path. |
| 12 Camera/render | Camera3D node + Forward Plus configured | OBSERVED endpoints, UNKNOWN full edge | Source presence does not prove desired composition/quality. |
| 13 Player | no new Sprint-01 runtime capture yet | UNKNOWN | Cannot call current player-visible chain PASS. |

## B3. Important negative finding

`TaskCommandService`, `NavigationService` and `CombatResolver` exist under `scripts/core/`. Only `NavigationService` is directly evidenced in the inspected Battle01 MOVE chain through `BattleNavigation._service`.

Therefore it is **not allowed** to write:

`Battle01 input -> TaskCommandService -> CombatResolver`

unless direct call evidence is later found. File existence is not an edge.

---

# C. Upstream CONTENT gaps still blocking a real 0 A.D. event

The current Release-28 trace is version-correct but still event-generic at the content layer. A real complete event requires fixing one specific playable map and one specific combat unit.

Required next upstream trace:

```text
Release-28 map file/script
  -> map loader
  -> terrain/entity placement
  -> pathfinder world
  -> selected concrete unit entity

chosen unit leaf template
  -> parent template inheritance
  -> UnitAI / UnitMotion / Vision / Attack / Health component data
  -> VisualActor
  -> actor XML
  -> mesh
  -> material
  -> textures
  -> animations
```

Until those edges are recorded, layers 1–3 of the external reference remain `UNKNOWN` for the chosen event.

---

# D. What is ready for Window 03 audit now

Window 03 can already audit these claims independently:

1. Version identity: Release 28 / v0.28.0, not archived GitHub master.
2. `input.js -> g_Selection` selection edge.
3. `unit_actions.js -> Engine.PostNetworkCommand(type='attack')` edge.
4. `ProcessCommand -> g_Commands.attack -> UnitAI.Attack` edge.
5. The deliberate UNKNOWN between `PostNetworkCommand` and `ProcessCommand`.
6. UnitAI component-test scope versus live-runtime overclaim risk.
7. `DelayedDamage.Hit -> AttackHelper.HandleAttackEffects` downstream damage edge.
8. Health test scope and the still-unclosed receiver-to-reduction edge.
9. FRONTLINE Battle01 `.tres` data binding.
10. FRONTLINE MOVE -> navigation -> position-update chain.
11. FRONTLINE deterministic historical combat state path.
12. FRONTLINE AI direct formation-method path versus player SelectionController path.
13. FRONTLINE primitive/procedural 3D presentation path and unproven combat-feedback edge.

BAR/Recoil and Warzone counterexample work is still pending for claims that might otherwise be generalized beyond source-specific facts.

---

# E. Reproduction gate

WINDOW_02_HANDOFF=NOT_READY

Reason:

- external map/unit/asset upstream chain not fixed;
- GUI post -> simulation command bridge still UNKNOWN;
- UnitAI player-order -> movement/attack-launch edge still UNKNOWN;
- attack launch -> delayed hit still UNKNOWN;
- final animation/VFX/UI/camera/render/PLAYER edge still UNKNOWN;
- no concrete chosen map+unit runtime event has been captured;
- Window 03 has not yet audited the new critical edges.

A future Window-02 handoff must include exactly:

```text
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
```

No reproduction handoff is authorized while a critical edge above is still being silently assumed.

---

# F. Current status

STATUS=CONTINUE_LEARNING

CURRENT_PROVEN_VERTICAL_SPAN=
`0 A.D. INPUT -> SELECTION -> GUI ATTACK COMMAND` and separately `SIMULATION ATTACK COMMAND -> UnitAI entry`, plus downstream `DelayedDamage hit -> effect application` and `Health reduction/death test semantics`.

CURRENT_FRONTLINE_DIAGNOSTIC_SPAN=
`Battle01 boot -> .tres unit data -> 3D input/selection -> MOVE -> navigation -> transform` and `ADVANCE target -> deterministic combat -> HP/death -> HUD signals`, with primitive 3D presentation and the combat-feedback-to-PLAYER edge still unproven.

FIRST_COMPLETE_REAL_RTS_EVENT=NOT_YET_ESTABLISHED
WINDOW_03_AUDIT=PENDING
WINDOW_02_REPRODUCTION=BLOCKED
PRODUCT_PRODUCTION_RESUME=NO
