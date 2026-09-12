# Learning Sprint 01 — Evidence Register

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-13
WINDOW_03_AUDIT_CONTRACT=docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md

## Status vocabulary

- `OBSERVED`: directly visible in inspected source/artifact/runtime.
- `REPRODUCED`: independently recreated and verified by us.
- `INFERRED`: supported by multiple observed facts but not directly proven.
- `HYPOTHESIS`: plausible claim requiring test.
- `UNKNOWN`: evidence currently insufficient.
- `REJECTED`: contradicted by inspected evidence or reproduction.

No item may be silently upgraded from INFERRED/HYPOTHESIS to fact.

## Window 03 required audit fields for new core claims

Every new core claim should add, where applicable:

PROJECT=
AUTHORITATIVE_SOURCE=
SOURCE_LOCATION=
SOURCE_TYPE=SOURCE_CODE|OFFICIAL_DOC|RUNTIME|SECONDARY
BRANCH_TAG_RELEASE=
COMMIT=
SOURCE_DATE=
RUNTIME_SEMANTICS=
HIDDEN_ASSUMPTIONS=
ALTERNATIVE_EXPLANATION=
COUNTEREXAMPLE_SEARCH=
COUNTEREXAMPLE_RESULT=
GENERALIZATION_LEVEL=SOURCE_FACT|PROJECT_SPECIFIC_INFERENCE|CROSS_PROJECT_PATTERN|DESIGN_RECOMMENDATION|UNSUPPORTED_GENERALIZATION
WINDOW_03_VERDICT=PENDING|PASS|DOWNGRADE|FIX|REJECT|UNKNOWN
ALLOWED_FINAL_WORDING=

The six mandatory Window 03 checks are:
1. PRIMARY_SOURCE_INTEGRITY
2. VERSION_IDENTITY
3. RUNTIME_SEMANTICS
4. GENERALIZATION_BOUNDARY
5. ALTERNATIVE_EXPLANATIONS
6. COUNTEREXAMPLE_SEARCH

## Active version warning

`0ad/0ad` on GitHub is archived and identifies itself as a deprecated Git mirror migrated to Wildfire Games Gitea on 2024-08-20.

Therefore:
- GitHub `master` evidence is historical unless exact version matching is proven;
- it must not be cited as current 2026 / Release-28 source by default;
- Release-28 source-code claims require version-matched authoritative source evidence;
- Window 03 must downgrade/fix/reject claims that blur historical mirror evidence with current implementation.

---

## E000 — FRONTLINE technical presence did not prove production quality

CLAIM=FRONTLINE can import assets, run Godot 4.7.1 and capture a 1920x1080 scene, while still failing user visual acceptance.
STATUS=OBSERVED
SOURCE=FRONTLINE repo historical Golden Scene evidence; former Issue #33 / PR #34 / CURRENT_STATE history.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The technical import/runtime/capture pipeline worked while the user rejected the visual result.
WHAT_IT_DOES_NOT_PROVE=Why the visual result failed technically, or which production method will fix it.

---

## E001 — 0 A.D. Release 28 exposes both build source and game data

CLAIM=The official 0 A.D. Release 28 source distribution provides both build-source and game-data archives needed to build the release from source.
STATUS=OBSERVED
SOURCE=https://play0ad.com/download/source/
SOURCE_TYPE=OFFICIAL_DOC
BRANCH_TAG_RELEASE=Release_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=Official source page instructs users to download both `unix-build` and `unix-data` tarballs for Release 28.
WHAT_IT_DOES_NOT_PROVE=How every game subsystem works internally or that the archived GitHub mirror exactly matches Release 28.
WINDOW_03_VERDICT=PENDING

---

## E002 — 0 A.D. engine/game/content responsibilities are split across code and data

CLAIM=0 A.D. officially describes a C++ engine (Pyrogenesis), JavaScript gameplay scripting, and data files for modifiable game logic/art/data.
STATUS=OBSERVED
SOURCE=https://play0ad.com/community/participate/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=Wildfire Games explicitly describes the engine language, scripting language and data-driven modification model.
WHAT_IT_DOES_NOT_PROVE=The detailed call path for a player command, the exact Release-28 runtime boundary, or the best architecture for FRONTLINE.
WINDOW_03_VERDICT=PENDING

---

## E003 — archived 0 A.D. GitHub mirror exposes integrated game-data surfaces

CLAIM=The archived `0ad/0ad` GitHub mirror contains art, audio, GUI, maps, shaders and simulation trees under its public game-data tree.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror tree visibly contains these production/content areas.
WHAT_IT_DOES_NOT_PROVE=That this exact tree is Release 28 or current 2026 source; that each directory maps one-to-one to a runtime subsystem; or the runtime interaction among them.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical archived 0 A.D. GitHub mirror contains these directories; do not call this current Release-28 source without version matching.

---

## E004 — archived 0 A.D. GitHub simulation tree contains AI/components/data/helpers/templates

CLAIM=The archived `0ad/0ad` GitHub mirror simulation tree contains AI, components, data, helpers and templates directories.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/simulation
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror tree contains these directories.
WHAT_IT_DOES_NOT_PROVE=Their runtime interaction; that this exact structure is unchanged in Release 28; or that any one directory defines the complete gameplay boundary.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical mirror evidence only until Release-28-matched source is traced.

---

## E005 — archived 0 A.D. GitHub map tree contains multiple map families

CLAIM=The archived `0ad/0ad` GitHub mirror map tree contains random maps, scenarios, scripts, skirmishes and tutorials.
STATUS=OBSERVED
SOURCE=https://github.com/0ad/0ad/tree/master/binaries/data/mods/public/maps
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=ARCHIVED_GITHUB_MASTER_UNMATCHED_TO_RELEASE_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical mirror supports multiple visible map/content authoring families.
WHAT_IT_DOES_NOT_PROVE=That the exact Release-28 layout is identical or how terrain, settlements and tactical spaces are authored/generated internally.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=DOWNGRADE
ALLOWED_FINAL_WORDING=Historical mirror map-family evidence only until Release-28-matched source/data is inspected.

---

## E006 — 0 A.D. Release 28 is a shipped release, not merely a tutorial sample

CLAIM=0 A.D. Release 28 “Boiorix” was released on 2026-02-18 and was announced as the project's first release without the Alpha label.
STATUS=OBSERVED
SOURCE=https://play0ad.com/
SOURCE_TYPE=OFFICIAL_DOC
BRANCH_TAG_RELEASE=Release_28
WHAT_THE_SOURCE_ACTUALLY_PROVES=The official project announcement describes the release and its status.
WHAT_IT_DOES_NOT_PROVE=That its visual quality, architecture or gameplay design should be copied by FRONTLINE.
WINDOW_03_VERDICT=PENDING

---

## E007 — Recoil is intentionally an RTS-scale engine with Lua game APIs

CLAIM=Recoil presents itself as a battle-tested open-source RTS engine with a Lua API and support for thousands of complex units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=This is the engine project's explicit stated scope/capability goal and API model.
WHAT_IT_DOES_NOT_PROVE=That Recoil is the right engine for FRONTLINE, or that a stated capability automatically matches our production requirements.
WINDOW_03_VERDICT=PENDING

---

## E008 — Recoil exposes unit definitions and unit command APIs at game layer

CLAIM=Recoil's documented game layer uses Lua unit definitions and exposes APIs for issuing orders to units/arrays/maps of units.
STATUS=OBSERVED
SOURCE=https://recoilengine.org/docs/guides/getting-started/unit-types-basics/ ; https://recoilengine.org/docs/lua-api/
SOURCE_TYPE=OFFICIAL_DOC
WHAT_THE_SOURCE_ACTUALLY_PROVES=Documented examples/API exist for unit defs and command issuing.
WHAT_IT_DOES_NOT_PROVE=BAR's exact high-level production chain or FRONTLINE's required command abstraction.
WINDOW_03_VERDICT=PENDING

---

## E009 — Beyond All Reason is a real game running on Recoil with separate game/engine/lobby boundaries

CLAIM=Beyond All Reason is game code running on the Recoil RTS Engine, while its development documentation also identifies a separate lobby/client component.
STATUS=OBSERVED
SOURCE=https://github.com/beyond-all-reason/Beyond-All-Reason ; https://github.com/beyond-all-reason/RecoilEngine
SOURCE_TYPE=SOURCE_CODE
WHAT_THE_SOURCE_ACTUALLY_PROVES=BAR explicitly identifies itself as game code on Recoil and documents a separate lobby component; Recoil identifies itself as the RTS engine.
WHAT_IT_DOES_NOT_PROVE=How every BAR gameplay/render/content feature is implemented, or that BAR's boundary is preferable for FRONTLINE.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING

---

## E010 — Warzone 2100 is a full open-source 3D RTS with a different script/native boundary

CLAIM=Warzone 2100 is a full open-source 3D RTS whose official scripting documentation uses JavaScript for AIs, campaigns and some game rules on top of its broader native/core implementation.
STATUS=OBSERVED
SOURCE=https://github.com/Warzone2100/warzone2100 ; https://github.com/Warzone2100/warzone2100/blob/master/doc/Scripting.md
SOURCE_TYPE=SOURCE_CODE
WHAT_THE_SOURCE_ACTUALLY_PROVES=The project and its scripting docs explicitly expose a different engine/game scripting boundary suitable as a counterexample pool.
WHAT_IT_DOES_NOT_PROVE=That its asset/render pipeline or architecture is appropriate for FRONTLINE.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING

---

## E011 — Primary-reference choice

CLAIM=0 A.D. Release 28 is a useful first reference for tracing one integrated RTS production chain among the currently inspected candidates.
STATUS=INFERRED
SOURCE=E001–E010.
WHAT_THE_SOURCE_ACTUALLY_PROVES=0 A.D. provides official Release-28 source/data distribution and official Release-28 component documentation, while BAR/Recoil and Warzone provide materially different cross-check architectures.
WHAT_IT_DOES_NOT_PROVE=That 0 A.D.'s architecture is universally superior, that the archived GitHub mirror is Release-28 source, or that its methods should be copied into FRONTLINE.
ALTERNATIVE_EXPLANATION=Another project may prove easier to trace end-to-end once authoritative Release-28 source availability is tested.
COUNTEREXAMPLE_SEARCH=BAR/Recoil and Warzone 2100.
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
WINDOW_03_VERDICT=FIX
ALLOWED_FINAL_WORDING=0 A.D. Release 28 remains the first candidate reference, conditional on obtaining authoritative version-matched source/data for the chain being traced.
TEST=Trace one actual playable action end-to-end through authoritative Release-28 source/data. If version-matched tracing is impractical or fragmented, reconsider the primary reference.

---

## E012 — Generated/design images are insufficient evidence of manufacturability

CLAIM=A visually coherent target image does not by itself establish an asset, level, material, lighting, VFX or runtime production path.
STATUS=OBSERVED
SOURCE=FRONTLINE historical sequence: approved visual targets / Golden Frame versus rejected actual Godot results.
WHAT_THE_SOURCE_ACTUALLY_PROVES=In this project, visual target generation and real-engine manufacturing capability diverged materially.
WHAT_IT_DOES_NOT_PROVE=That generated images are useless; they remain valid outcome proposals when clearly labelled and backed by later manufacturability work.
WINDOW_03_VERDICT=PENDING

---

## E013 — Release-28 source identity is now version anchored for inspected code

CLAIM=The first vertical trace is pinned to 0 A.D. Release 28 / v0.28.0 rather than the archived GitHub master branch.
CHAIN_LAYER=VERSION_IDENTITY / ALL
EDGE=RELEASE_IDENTITY -> INSPECTED_SOURCE
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=https://play0ad.com/download/source/
SOURCE_LOCATION=official `0ad-0.28.0-unix-build` and `0ad-0.28.0-unix-data` release archives; version-matched public pull mirror tag `v0.28.0`
SOURCE=https://play0ad.com/download/source/ ; https://git.phylogix.dev/gptbot/0ad/src/tag/v0.28.0/
SOURCE_VERSION=Release 28 / v0.28.0
SOURCE_TYPE=OFFICIAL_DOC + SOURCE_CODE_MIRROR
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The official release page names the 0.28.0 build/data archives, and the inspected mirror exposes a v0.28.0 source tag for file-level tracing.
WHAT_IT_DOES_NOT_PROVE=That every mirror byte is identical to the official release tarballs; byte-level archive equivalence has not yet been checked.
HIDDEN_ASSUMPTIONS=The public pull mirror represents the upstream v0.28.0 tag accurately.
ALTERNATIVE_EXPLANATION=Distribution packaging or mirror synchronization could contain a difference not visible from tag naming alone.
COUNTEREXAMPLE_SEARCH=Debian Sources package 0ad 0.28.0-3 and official Release-28 generated component documentation were checked as independent version anchors; Debian package patches shown by Debian are packaging/build/test oriented, not evidence of a different gameplay version.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=The inspected first-trace files are version-pinned to v0.28.0/Release 28; exact tarball-to-mirror byte identity remains unverified.
FRONTLINE_CURRENT_IMPLEMENTATION=Not applicable.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. Release 28 source/data.
GAP=Official release tarballs have not yet been locally hashed against the mirror tree.
REPRODUCTION_REQUIRED=NO

---

## E014 — Release-28 player selection stores entity IDs in the session Selection object

CLAIM=In the inspected Release-28 session GUI path, left-click selection resolves a clicked entity and updates `g_Selection`; `EntitySelection.addList` then stores accepted entity IDs and updates selection presentation state.
CHAIN_LAYER=4 PLAYER_SELECTION
EDGE=POINTER_INPUT -> PICKED_ENTITY -> g_Selection
PROJECT=0 A.D.
AUTHORITATIVE_SOURCE=version-matched v0.28.0 source
SOURCE_LOCATION=`binaries/data/mods/public/gui/session/input.js`; `binaries/data/mods/public/gui/session/selection.js`
SOURCE=https://git.phylogix.dev/gptbot/0ad/src/tag/v0.28.0/binaries/data/mods/public/gui/session/input.js ; https://git.phylogix.dev/gptbot/0ad/src/tag/v0.28.0/binaries/data/mods/public/gui/session/selection.js
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=`input.js` uses `Engine.PickEntityAtPoint`, builds the entity list, and calls `g_Selection.addList/removeList/reset`; `selection.js` updates the selected set and selection/highlight/status presentation.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The GUI input-to-selection edge and the concrete selection container/update calls exist in this version.
WHAT_IT_DOES_NOT_PROVE=That every selection mode follows identical branches or that FRONTLINE should copy this design.
HIDDEN_ASSUMPTIONS=No runtime hot-patch/mod replaces these functions in the chosen future reproduction.
ALTERNATIVE_EXPLANATION=Mods could alter GUI/session behavior; this record describes stock public Release-28 code.
COUNTEREXAMPLE_SEARCH=PENDING_BAR_WARZONE_FOR_GENERALIZATION_ONLY
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Stock 0 A.D. Release 28 routes session pointer selection through entity picking into `g_Selection`.
FRONTLINE_CURRENT_IMPLEMENTATION=`scripts/battle01/battle_3d_input.gd` projects selectable formation proxies to screen coordinates, then calls `BattleSelectionController.select_only/add_to_selection`; this is an existing historical/runtime implementation, not current product design authority.
EXTERNAL_REFERENCE_IMPLEMENTATION=Entity IDs are held by the session selection object and selection changes also drive visual/status feedback.
GAP=No claim yet that either project's selection architecture should be transferred.
REPRODUCTION_REQUIRED=YES

---

## E015 — Release-28 contextual attack action emits a typed network command

CLAIM=When the contextual action resolves to `attack`, Release-28 `unit_actions.js` emits an `Engine.PostNetworkCommand` with type `attack`, selected entity IDs and a target entity; it also requests the attack-order sound.
CHAIN_LAYER=5 COMMAND_ROUTING
EDGE=SELECTED_ENTITIES + TARGET -> ATTACK_COMMAND_POST
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/gui/session/input.js`; `binaries/data/mods/public/gui/session/unit_actions.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=Right mouse release calls `determineAction`/`doAction`; `handleUnitAction` uses `g_Selection.toList()`; the `attack.execute` action posts `{type:'attack', entities, target, queued, pushFront, allowCapture, formation...}` and requests `order_attack` sound.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The GUI-side translation from contextual attack action to a concrete typed command payload, plus immediate order-sound feedback.
WHAT_IT_DOES_NOT_PROVE=How `PostNetworkCommand` crosses the C++/turn/network boundary into simulation command processing.
ALTERNATIVE_EXPLANATION=Single-player and multiplayer may share or differ in engine-side transport details; that bridge must be traced rather than inferred.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release 28's stock GUI posts a typed `attack` network command containing selected entities and target; the engine bridge after posting is still separately audited.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 right-click path currently issues MOVE/ADVANCE via `BattleSelectionController`, not an observed equivalent typed ATTACK command envelope.
EXTERNAL_REFERENCE_IMPLEMENTATION=GUI action -> typed command payload.
GAP=`Engine.PostNetworkCommand -> simulation ProcessCommand` is not yet source-closed.
REPRODUCTION_REQUIRED=YES

---

## E016 — Release-28 simulation dispatches `attack` commands into UnitAI

CLAIM=Release-28 `ProcessCommand` filters command entities and dispatches known command types through `g_Commands`; `g_Commands.attack` invokes `cmpUnitAI.Attack` on the resolved unit AIs.
CHAIN_LAYER=5 COMMAND_ROUTING / 8 COMBAT_ENTRY
EDGE=SIMULATION_COMMAND -> g_Commands.attack -> UnitAI.Attack
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/simulation/helpers/Commands.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=`ProcessCommand(player, cmd)` filters entity control, pushes a `playercommand` notification to GuiInterface, triggers player-command notification, then dispatches `g_Commands[cmd.type]`; the attack handler calls `cmpUnitAI.Attack(cmd.target, cmd.allowCapture, cmd.queued, cmd.pushFront)`.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The simulation-side command-dispatch and UnitAI attack entry point.
WHAT_IT_DOES_NOT_PROVE=That the GUI command posted in E015 reaches this function by the assumed engine path; that bridge is not yet traced.
HIDDEN_ASSUMPTIONS=None required for the local function-to-function dispatch claim.
ALTERNATIVE_EXPLANATION=Other internal callers can invoke `ProcessCommand`; this record does not identify the engine caller for the player's posted command.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Once an `attack` command is in Release-28 simulation `ProcessCommand`, stock code dispatches it to `UnitAI.Attack`.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 selection/controller code calls formation methods directly for movement and targeting; it does not prove use of `scripts/core/command/task_command_service.gd` in the live Battle01 click path.
EXTERNAL_REFERENCE_IMPLEMENTATION=Simulation command table dispatch to UnitAI.
GAP=E015-to-E016 transport bridge remains UNKNOWN.
REPRODUCTION_REQUIRED=YES

---

## E017 — GUI `PostNetworkCommand` to simulation `ProcessCommand` is not yet closed

CLAIM=The exact Release-28 engine/turn/network call path connecting GUI `Engine.PostNetworkCommand` to simulation `ProcessCommand` has not yet been source-traced in this sprint.
CHAIN_LAYER=5 COMMAND_ROUTING
EDGE=Engine.PostNetworkCommand -> ProcessCommand
PROJECT=0 A.D.
SOURCE_VERSION=v0.28.0
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=E015 proves the GUI post; E016 proves the simulation consumer/dispatcher. No inspected source yet proves the intervening caller chain.
WHAT_IT_DOES_NOT_PROVE=That the two are disconnected; only that the edge is presently unverified.
ALTERNATIVE_EXPLANATION=The bridge may pass through local turn management, network turn management, or a shared command queue depending on runtime mode.
COUNTEREXAMPLE_SEARCH=Not applicable until the 0 A.D. edge itself is traced.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=UNKNOWN: GUI post and simulation consumer are both observed, but their exact Release-28 engine bridge has not yet been established.
FRONTLINE_CURRENT_IMPLEMENTATION=No direct mapping claimed.
EXTERNAL_REFERENCE_IMPLEMENTATION=UNKNOWN intervening bridge.
GAP=Critical missing edge in first vertical trace.
REPRODUCTION_REQUIRED=YES

---

## E018 — Release-28 UnitAI test executes real UnitAI against RangeManager, UnitMotion, Vision, Attack and Health interfaces

CLAIM=The Release-28 UnitAI component test loads the actual `UnitAI.js` and verifies combat-state transitions using mocked RangeManager/UnitMotion/Vision/Attack/Health dependencies.
CHAIN_LAYER=6 PATHFINDING_AND_MOVEMENT / 7 DETECTION_TARGET / 8 COMBAT
EDGE=UNIT_AI_STATE -> MOVEMENT/RANGE/ATTACK_DEPENDENCIES
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/simulation/components/tests/test_UnitAI.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE_TEST
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=The test loads actual UnitAI, supplies mocks including `MoveToTargetRange`, `StopMoving`, attack range/choice/timer/CanAttack/IsTargetInRange/StartAttacking, creates an active range query, and verifies transition to `INDIVIDUAL.COMBAT.ATTACKING` for a live enemy and return to idle after death.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Actual UnitAI is coupled to these interfaces and its tested combat FSM reacts to enemy/range/attack state.
WHAT_IT_DOES_NOT_PROVE=The exact runtime path from the player-issued `UnitAI.Attack` call through pathfinder/motion to `Attack.StartAttacking`, because dependencies are mocked in this test.
HIDDEN_ASSUMPTIONS=Component tests encode intended stock behavior but are not runtime capture.
ALTERNATIVE_EXPLANATION=Additional UnitAI branches/states can alter behavior in a real match.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 UnitAI tests prove interaction contracts and combat FSM behavior, not the entire live movement/fire call chain.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 combines movement/combat state in `BattleFormation._process` and calls BattleNavigation for explicit movement orders.
EXTERNAL_REFERENCE_IMPLEMENTATION=UnitAI state machine with movement/range/attack component interfaces.
GAP=Direct UnitAI source branch for the chosen player-issued attack event still requires extraction.
REPRODUCTION_REQUIRED=YES

---

## E019 — Release-28 Attack component owns attack eligibility/type/timing/effect data

CLAIM=Release-28 Attack component tests load the real Attack component and exercise target legality, attack selection, prepare/repeat timing, ranges, projectile parameters and damage-effect data.
CHAIN_LAYER=7 DETECTION_TARGET / 8 FIRE_HIT_DAMAGE
EDGE=TARGET + ATTACK_DATA -> ATTACK_ELIGIBILITY_AND_TIMING
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/simulation/components/tests/test_Attack.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE_TEST
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=The test loads actual Attack helper/component, configures melee/ranged/capture attacks, prepare/repeat times, ranges, projectile speed/spread/gravity and effects, and asserts `CanAttack`/best-attack behavior against ownership/classes.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Attack eligibility and timing/effect data are explicit component concerns in Release 28.
WHAT_IT_DOES_NOT_PROVE=That the chosen event has an ammunition system. No ammo consumption is evidenced in this traced 0 A.D. attack path.
ALTERNATIVE_EXPLANATION=Specific templates can expose attack types/options different from the test template.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release 28's Attack component has explicit range/timing/projectile/effect and target-legality logic; ammo is not asserted for this reference chain.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 `FormationDefinition` explicitly contains `ammo_capacity`, `fire_interval`, `attack_range`, `attack_damage` and detection data.
EXTERNAL_REFERENCE_IMPLEMENTATION=Attack component/data-driven timing and effects.
GAP=Attack.StartAttacking/PerformAttack to projectile/delayed-damage source edge remains to be closed for the chosen event.
REPRODUCTION_REQUIRED=YES

---

## E020 — Release-28 delayed hit applies attack effects and emits impact feedback

CLAIM=Release-28 `DelayedDamage.Hit` performs projectile/impact handling and invokes the Attack helper effect pipeline; the helper applies registered effect receivers and posts an attacked message.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE / 11 FEEDBACK
EDGE=PROJECTILE_OR_DELAYED_HIT -> ATTACK_EFFECTS -> RECEIVER + ATTACKED_EVENT
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/simulation/components/DelayedDamage.js`; `binaries/data/mods/public/simulation/helpers/Attack.js`; `simulation/components/tests/test_Attack.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=`DelayedDamage.Hit` can play impact sound, handle splash/collision and call `AttackHelper.HandleAttackEffects`; the helper applies effect data through registered receiver methods and posts the attacked message. The test receiver map binds Damage to `IID_Health.TakeDamage`.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The downstream hit/effect application edge and one explicit audio feedback edge.
WHAT_IT_DOES_NOT_PROVE=The upstream launch path from UnitAI/Attack into this delayed hit for the selected real event; nor the final on-screen projectile/VFX result.
ALTERNATIVE_EXPLANATION=Different attack types can bypass projectile collision or use splash/status/capture effects.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release 28's delayed-hit/effect pipeline can call Health damage receivers and impact audio; upstream launch and player-visible VFX remain separately unverified.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 resolves damage synchronously inside `BattleFormation._update_combat` after range/LOS/cooldown checks.
EXTERNAL_REFERENCE_IMPLEMENTATION=Delayed/projectile hit then effect receivers.
GAP=Chosen attack's launch-to-hit edge remains UNKNOWN.
REPRODUCTION_REQUIRED=YES

---

## E021 — Release-28 Health component tests verify HP reduction and death/corpse transition

CLAIM=Release-28 Health component tests load the real Health component and verify HP reduction to zero plus corpse creation behavior.
CHAIN_LAYER=8 FIRE_HIT_DAMAGE_DEATH / 10 STATE
EDGE=HEALTH_REDUCTION -> HP_STATE -> DEATH/CORPSE
PROJECT=0 A.D.
SOURCE_LOCATION=`binaries/data/mods/public/simulation/components/tests/test_Health.js`
SOURCE_VERSION=v0.28.0
SOURCE_TYPE=SOURCE_CODE_TEST
BRANCH_TAG_RELEASE=v0.28.0
COMMIT=a2cae4d69f
STATUS=OBSERVED
RUNTIME_SEMANTICS=Tests initialize Health at 50 HP, verify `Reduce(25)` yields 25 HP, and verify lethal reduction clamps to zero and creates a corpse entity according to death settings.
WHAT_THE_SOURCE_ACTUALLY_PROVES=HP mutation/death behavior of the actual component under test.
WHAT_IT_DOES_NOT_PROVE=The exact internal `Health.TakeDamage -> Reduce` implementation edge, which has not yet been directly inspected in the chosen version.
ALTERNATIVE_EXPLANATION=Some entities/templates can use different death types or additional death components/messages.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Release-28 Health tests prove real component HP reduction and lethal transition behavior; the `TakeDamage -> Reduce` internal call remains to be source-closed.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 `BattleFormation.take_damage` subtracts HP, emits `health_changed`, and calls `_die` at zero; `_die` clears movement/target, sets `DESTROYED`, starts a death-FX timer and emits `died`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Health component state/death transition.
GAP=Health receiver entry to Reduce internals not yet directly inspected.
REPRODUCTION_REQUIRED=YES

---

## E022 — Release-28 presentation evidence is only partially closed

CLAIM=The first trace currently proves attack-order audio, impact audio and simulation notifications, but not the complete animation/VFX/UI/camera/render path to the final player-visible result.
CHAIN_LAYER=10 UI / 11 ANIMATION_VFX_AUDIO / 12 CAMERA_RENDER / 13 PLAYER
EDGE=SIMULATION_EVENT -> PRESENTATION -> RENDER -> PLAYER
PROJECT=0 A.D.
SOURCE_VERSION=v0.28.0
STATUS=UNKNOWN
SOURCE=E014-E021 plus Release-28 component documentation.
WHAT_THE_SOURCE_ACTUALLY_PROVES=Selection code updates highlight/status state; attack action requests `order_attack` sound; delayed damage can play impact sound; `ProcessCommand` pushes a `playercommand` notification; AttackHelper posts an attacked message.
WHAT_IT_DOES_NOT_PROVE=Which exact GUI widgets consume these notifications, which actor animations/VFX are triggered for the chosen unit, how the camera/render pipeline presents them, or what the player actually sees in a captured run.
ALTERNATIVE_EXPLANATION=Some presentation may be driven from actor animation/event data rather than directly from the simulation messages already inspected.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Presentation is partially evidenced; final PLAYER layer remains UNKNOWN until actor/GUI/camera/render edges and runtime are inspected.
FRONTLINE_CURRENT_IMPLEMENTATION=Historical Battle01 has HUD signal bindings and a 3D presentation proxy system, but the visible combat-feedback edge is not yet proven by runtime evidence.
EXTERNAL_REFERENCE_IMPLEMENTATION=Partial only.
GAP=Critical end-of-chain gap.
REPRODUCTION_REQUIRED=YES

---

## E023 — FRONTLINE repository runtime entry still loads Battle01, but Battle01 is not current design authority

CLAIM=At main `06710c3d9e29d3400572bf25ed5e8fd96c73b472`, `project.godot` still sets `res://scenes/battle01/Battle01.tscn` as `run/main_scene`, and that scene binds world/input/selection/navigation/HUD/presentation resources; current governance simultaneously says old Battle01 artifacts are not automatically current design authority.
CHAIN_LAYER=1 MAP_LOADING / ALL FRONTLINE_MAPPING
EDGE=PROJECT_BOOT -> Battle01.tscn -> BATTLE_NODES
PROJECT=FRONTLINE
SOURCE=`project.godot`; `scenes/battle01/Battle01.tscn`; `START_HERE.md`; `docs/current/CURRENT_STATE.md`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE + PROJECT_GOVERNANCE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The repository's executable entrypoint and concrete scene wiring, plus the authority warning.
WHAT_IT_DOES_NOT_PROVE=That Battle01 defines the current/future product design or that its existing gameplay choices are approved for transfer.
HIDDEN_ASSUMPTIONS=None.
ALTERNATIVE_EXPLANATION=The runtime entry can remain as a technical/historical toolbox while product design is under reset.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Battle01 is the current repository runtime entry and inspectable E0 implementation, but not current product-design authority.
FRONTLINE_CURRENT_IMPLEMENTATION=`project.godot -> Battle01.tscn`, with `World3D`, `BattleCamera3D`, `Presentation3D`, `Navigation`, `SelectionController`, `Input3D`, `HUD` and formation nodes bound in the scene.
EXTERNAL_REFERENCE_IMPLEMENTATION=Not applicable.
GAP=Current product replacement architecture remains intentionally unresolved by this sprint.
REPRODUCTION_REQUIRED=NO

---

## E024 — FRONTLINE historical Battle01 unit gameplay data is Resource/.tres-driven

CLAIM=Battle01 formation stats are loaded from `FormationDefinition` `.tres` resources and copied into formation runtime state by `_apply_definition`.
CHAIN_LAYER=2 UNIT_DATA_SOURCE_OF_TRUTH
EDGE=.tres FormationDefinition -> BattleFormation runtime stats
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/formation_definition.gd`; `resources/formations/infantry.tres`; `scenes/battle01/Battle01.tscn`; `scripts/battle01/formation.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The inspected infantry resource contains move speed, HP, attack damage/range, fire interval, ammo, detection range and capture flags; scene nodes bind a definition; formation code copies definition fields into runtime properties.
WHAT_IT_DOES_NOT_PROVE=That all future FRONTLINE unit data should use this schema or that no duplicated stats exist elsewhere.
ALTERNATIVE_EXPLANATION=Other historical controllers may add or override behavior without changing the base FormationDefinition.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Historical Battle01's core formation stats are demonstrably `.tres` Resource-driven.
FRONTLINE_CURRENT_IMPLEMENTATION=Mixed scene wiring + `.tres` stats + script logic.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. uses entity/template/component data; exact chosen-unit template chain still pending.
GAP=No current product data schema has been frozen.
REPRODUCTION_REQUIRED=YES

---

## E025 — FRONTLINE historical 3D unit/world presentation is procedural primitive geometry, not a production asset binding chain

CLAIM=The inspected Battle01 3D presentation/world code creates BoxMesh/CylinderMesh/TorusMesh primitives and runtime `StandardMaterial3D` objects; the inspected unit-proxy path does not bind imported production meshes, texture sets or custom shaders.
CHAIN_LAYER=3 MODEL_MATERIAL_ASSET_BINDING / 12 RENDER
EDGE=FORMATION_ROLE/WORLD_RULES -> PRIMITIVE_MESH + RUNTIME_MATERIAL -> 3D_PROXY
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/battle_3d_presentation.gd`; `scripts/battle01/battle_3d_world.gd`; `scenes/battle01/Battle01.tscn`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
RUNTIME_SEMANTICS=`_mesh_for_role` creates CylinderMesh for infantry and BoxMesh for other roles; `_make_material` creates color/metallic/roughness StandardMaterial3D. World terrain/roads/buildings are likewise constructed from boxes/cylinders and runtime materials.
WHAT_THE_SOURCE_ACTUALLY_PROVES=The current repository Battle01 3D proxy/world path is a procedural primitive greybox-style presentation route.
WHAT_IT_DOES_NOT_PROVE=That no imported assets exist elsewhere in the repository, or that a future product pipeline must replace every procedural element.
HIDDEN_ASSUMPTIONS=None for the inspected path.
ALTERNATIVE_EXPLANATION=Imported assets may exist outside this active Battle01 proxy path; they are not evidenced as part of this path.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Battle01's inspected 3D formation/world path is primitive/procedural; a real unit model→material→texture→shader→LOD production chain is not present in this path.
FRONTLINE_CURRENT_IMPLEMENTATION=Primitive 3D proxies + runtime materials.
EXTERNAL_REFERENCE_IMPLEMENTATION=Release-28 entity docs expose a `VisualActor` actor binding system, but the chosen concrete unit→actor→mesh/material chain is still pending.
GAP=Major CONTENT→RENDER production-asset gap for any visually production-ready FRONTLINE slice.
REPRODUCTION_REQUIRED=YES

---

## E026 — FRONTLINE historical player MOVE chain is source-closed through navigation to transform updates

CLAIM=Battle01's 3D right-click MOVE path is directly traceable from input through selected formations into BattleNavigation/NavigationService and then into formation position updates.
CHAIN_LAYER=4 SELECTION / 5 COMMAND / 6 MOVEMENT
EDGE=RMB_WORLD_POINT -> SelectionController.issue_move -> BattleFormation.issue_move -> BattleNavigation.find_path_for_formation -> NavigationService.find_path -> BattleFormation._update_movement -> global_position
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/battle_3d_input.gd`; `selection_controller.gd`; `formation.gd`; `battle_navigation.gd`; `scripts/core/navigation/navigation_service.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The code-level movement chain exists and explicit formation mobility profiles reach the core navigation service; formation motion advances waypoint by waypoint and mutates `global_position`.
WHAT_IT_DOES_NOT_PROVE=Current runtime quality, crowd/formation realism, performance, or that this chain is current product design.
ALTERNATIVE_EXPLANATION=Runtime bugs or untested input conflicts can still prevent/alter the source-described behavior.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Historical Battle01 has a source-closed 3D player MOVE→path→position-update chain; runtime reproduction is still a separate claim.
FRONTLINE_CURRENT_IMPLEMENTATION=As stated in EDGE.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. movement chain not yet source-closed for the chosen event.
GAP=Player ATTACK command is not represented by this same Battle01 3D input path; combat targeting for ADVANCE is handled separately.
REPRODUCTION_REQUIRED=YES

---

## E027 — FRONTLINE historical target/combat/state chain is concentrated inside SelectionController + BattleFormation

CLAIM=For player ADVANCE in Battle01, confirmed intel/range/LOS gating in SelectionController can assign a combat target; `BattleFormation._update_combat` then enforces hold-fire, attack capability, ammo, target validity, range, LOS and cooldown before consuming one ammo, calculating damage, emitting fire/ammo events and calling target `take_damage`; lethal damage calls `_die`.
CHAIN_LAYER=7 TARGET / 8 COMBAT / 10 STATE
EDGE=ADVANCE_INTENT -> CONFIRMED_TARGET -> FIRE_GATES -> AMMO-1 -> DAMAGE -> HP -> DEATH
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/selection_controller.gd`; `scripts/battle01/formation.gd`; `scripts/battle01/visibility_field.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=The historical deterministic combat code path and explicit state mutation responsibilities.
WHAT_IT_DOES_NOT_PROVE=That this combat model is current product design, balanced, realistic, or player-accepted.
ALTERNATIVE_EXPLANATION=Enemy AI assigns targets through its own controller path rather than player ADVANCE target selection.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Historical Battle01 has an explicit ammo/cooldown/range/LOS/damage/HP/death source path; this is evidence of existing implementation only.
FRONTLINE_CURRENT_IMPLEMENTATION=Ammo capacity and weapon stats originate in FormationDefinition resources; combat execution is in `BattleFormation`.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. Release 28 uses separate UnitAI/Attack/DelayedDamage/Health responsibilities in the inspected reference evidence.
GAP=Architectural difference is observed; no transfer decision yet.
REPRODUCTION_REQUIRED=YES

---

## E028 — FRONTLINE historical simulation state is wired to HUD through signals/callbacks

CLAIM=Battle01 connects selection/order/health/ammo/intel/death/victory state changes to HUD update methods in `battle01.gd` rather than requiring the HUD to independently recompute all of those states.
CHAIN_LAYER=10 UI_STATE_ACQUISITION
EDGE=AUTHORITATIVE_FORMATION/INTEL/WAR_FLOW_STATE -> SIGNAL/CALLBACK -> HUD_METHOD
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/battle01.gd`; `scripts/battle01/hud.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=Concrete signal connections and callbacks exist for selection, orders, friendly health/ammo, enemy health, intel state and match outcomes.
WHAT_IT_DOES_NOT_PROVE=That every HUD field is authoritative or that the visual HUD presentation is production-quality.
ALTERNATIVE_EXPLANATION=Some HUD fields may still derive secondary presentation state internally; they require field-by-field audit if they become part of the reproduction target.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Historical Battle01 has explicit signal/callback state→HUD wiring for the inspected state set.
FRONTLINE_CURRENT_IMPLEMENTATION=Observed signal binding in `battle01.gd`.
EXTERNAL_REFERENCE_IMPLEMENTATION=Release-28 GUI consumption path remains incomplete in the first trace.
GAP=Player-visible correctness has not been runtime-verified in this sprint.
REPRODUCTION_REQUIRED=YES

---

## E029 — FRONTLINE historical enemy AI does not use the player's SelectionController command entry

CLAIM=The inspected Battle01 enemy AI chooses targets/missions itself and directly calls `BattleFormation.set_combat_target`, `stop`, and `issue_move`; its `_issue_move` routes through the same formation/navigation execution path but not through the player's SelectionController input/command entry.
CHAIN_LAYER=9 AI_COMMAND_GENERATION
EDGE=AI_DECISION -> DIRECT_FORMATION_METHODS -> SHARED_LOW_LEVEL_MOVEMENT/COMBAT_EXECUTION
PROJECT=FRONTLINE
SOURCE=`scripts/battle01/enemy_ai_controller.gd`; `scripts/battle01/formation.gd`; `scripts/battle01/battle_navigation.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=OBSERVED
WHAT_THE_SOURCE_ACTUALLY_PROVES=AI and player converge at lower-level BattleFormation/navigation/combat methods, not at the inspected player SelectionController command entry.
WHAT_IT_DOES_NOT_PROVE=That this architecture is wrong, or that `scripts/core/command/task_command_service.gd` is never used anywhere else.
HIDDEN_ASSUMPTIONS=None for the inspected controller call sites.
ALTERNATIVE_EXPLANATION=A shared command envelope may exist in another prototype/core path but is not evidenced as the Battle01 enemy AI entry shown here.
COUNTEREXAMPLE_SEARCH=0 A.D./BAR/Warzone cross-project AI command boundaries remain to be traced before generalization.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=Battle01 AI shares low-level formation execution with player-controlled units but bypasses the player's SelectionController entry.
FRONTLINE_CURRENT_IMPLEMENTATION=Direct AI calls into BattleFormation.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. AI command generation edge not yet closed.
GAP=No evidence yet that a common high-level command service is required for FRONTLINE.
REPRODUCTION_REQUIRED=YES

---

## E030 — FRONTLINE historical 3D combat presentation edge remains unproven

CLAIM=Source inspection proves logical combat feedback state exists in `BattleFormation`, while Battle01 scene/presentation hides the 2D formation nodes and renders separate 3D proxies; the first sprint has not yet proved a complete logical-fire→3D muzzle/projectile/impact/audio→camera/player-visible path.
CHAIN_LAYER=11 PRESENTATION / 12 RENDER / 13 PLAYER
EDGE=LOGICAL_FIRE -> 3D_COMBAT_FEEDBACK -> PLAYER
PROJECT=FRONTLINE
SOURCE=`scenes/battle01/Battle01.tscn`; `scripts/battle01/formation.gd`; `scripts/battle01/battle_3d_presentation.gd`; `scripts/battle01/battle01.gd`
SOURCE_VERSION=main@06710c3d9e29d3400572bf25ed5e8fd96c73b472
SOURCE_TYPE=SOURCE_CODE
STATUS=UNKNOWN
WHAT_THE_SOURCE_ACTUALLY_PROVES=Formation code maintains `_shot_fx_remaining`/death/under-fire visual state and 2D draw routines; Battle01 formation nodes are alpha-hidden and 3D presentation builds separate proxies. The inspected 3D presentation source shows selection/objective/smoke/command-marker visuals but does not by itself prove combat-shot rendering.
WHAT_IT_DOES_NOT_PROVE=That combat feedback is definitely absent at runtime; another source/runtime path could supply it.
ALTERNATIVE_EXPLANATION=Combat feedback may be implemented in an uninspected node/script or may be visible through a path not yet traced.
GENERALIZATION_LEVEL=SOURCE_FACT
WINDOW_03_VERDICT=PENDING
ALLOWED_FINAL_WORDING=UNKNOWN: logical combat is source-evidenced, but a complete Battle01 logical-fire→3D combat feedback→PLAYER edge has not been established.
FRONTLINE_CURRENT_IMPLEMENTATION=Partial source evidence only.
EXTERNAL_REFERENCE_IMPLEMENTATION=0 A.D. final presentation edge also remains partial.
GAP=Directly relevant candidate explanation for “technically working but visually dead”, but not yet a confirmed runtime diagnosis.
REPRODUCTION_REQUIRED=YES

---

## Open unknowns before reproduction

### U001
CLAIM=Which exact authoritative 0 A.D. Release 28 map/slice is the best minimal end-to-end trace target?
STATUS=UNKNOWN
NEXT=Inspect Release 28 source/data distribution and choose a slice with map/world data, selectable units, movement, combat and visible UI feedback.

### U002
CLAIM=Which 0 A.D. world-authoring rules are authored versus procedural versus engine-imposed in Release 28?
STATUS=UNKNOWN
NEXT=Inspect version-matched Release 28 scenario/skirmish/random map data/scripts and relevant official editor/source material.

### U003
CLAIM=Which production patterns learned from 0 A.D. remain useful under a Godot 4.7.1 implementation?
STATUS=UNKNOWN
NEXT=Do not answer until the chain is traced, cross-checked and independently reproduced.

### U004
CLAIM=Whether FRONTLINE should retain Godot after end-to-end learning.
STATUS=UNKNOWN
NEXT=Engine choice remains open; do not reopen it from theory alone. Evaluate only after reproduction exposes actual requirements and friction.

### U005
CLAIM=What exact Release-28 C++/turn-manager/network path connects GUI `Engine.PostNetworkCommand` to simulation `ProcessCommand`?
STATUS=UNKNOWN
NEXT=Trace the script binding, turn manager/command queue and simulation dispatch in version-matched `source/` files. Do not infer from matching payload names.

### U006
CLAIM=What exact Release-28 `UnitAI.Attack` branch converts the player-issued attack order into movement/range closure and then `Attack.StartAttacking`/actual launch?
STATUS=UNKNOWN
NEXT=Inspect the real v0.28.0 UnitAI state/command source, not only its tests.

### U007
CLAIM=What exact Release-28 launch path creates/schedules the projectile or delayed-damage event that later reaches `DelayedDamage.Hit`?
STATUS=UNKNOWN
NEXT=Inspect v0.28.0 Attack perform/start code and projectile manager/helper calls.

### U008
CLAIM=For the chosen real unit, what exact template inheritance chain binds gameplay data to `VisualActor`, actor definition, mesh/material/texture/animation?
STATUS=UNKNOWN
NEXT=Choose the first concrete unit only after the first map/slice is fixed; trace its leaf template through parents and actor files.

### U009
CLAIM=How does the chosen Release-28 map become the loaded playable battle space, including terrain/entity placement/pathfinder data?
STATUS=UNKNOWN
NEXT=Choose one version-matched scenario/skirmish map and trace loader/data/runtime edges.

### U010
CLAIM=How do Release-28 combat state/events reach the actual HUD, actor animation, VFX, camera and renderer for the chosen event?
STATUS=UNKNOWN
NEXT=Trace concrete GUI consumers, actor animation/event definitions, renderer/camera state and capture a runtime event.

### U011
CLAIM=How does Release-28 AI enter the command/execution chain, and does it converge with player commands at the same semantic level or only lower down?
STATUS=UNKNOWN
NEXT=Trace one stock AI order from AI API/manager to command processing and compare with E015-E016. BAR/Warzone will be used as counterexamples before generalizing.

### U012
CLAIM=Does the historical FRONTLINE Battle01 source-closed movement/combat chain produce the expected current runtime behavior and visible feedback on main?
STATUS=UNKNOWN
NEXT=Window 01 may inspect existing runtime evidence, but a new reproduction/acceptance run belongs under the sprint reproduction gate; do not upgrade source existence to runtime PASS.
