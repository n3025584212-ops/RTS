# FRONTLINE — SPRINT 01 SYSTEM CAUSAL CHAIN INDEPENDENT AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_SPRINT01_SYSTEM_CAUSAL_CHAIN_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_EVIDENCE_AUDIT
AUDIT_DATE=2026-09-14
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
AUDITED_EVIDENCE_REGISTER_COMMIT=0c47af91abe5dcc44e8291628e7c30ca9474efb7
AUDITED_END_TO_END_CHAIN_COMMIT=a8040c20047b7b46f4f727a4fdfd57152d92d235
FRONTLINE_SOURCE_COMMIT=06710c3d9e29d3400572bf25ed5e8fd96c73b472
ZERO_AD_INSPECTED_COMMIT=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
BAR_INSPECTED_COMMIT=28e122237458f39cd89d254aa44bfc31448cc7f6
RECOIL_INSPECTED_COMMIT=05c054cbe2249feda3637cabfe122b75241113e9
WARZONE_INSPECTED_COMMIT=b0288082c54536ae3634a6a71b0e03f0d82bb8f3

WINDOW_03_AUDIT=FAIL

BLOCKERS:
- B01_VERSION_IDENTITY: The official 0 A.D. Release-28 source page proves that the official release artifacts are the `0ad-0.28.0-unix-build` and `0ad-0.28.0-unix-data` archives, but the audited evidence does not contain an authoritative official tag->commit or archive/hash proof that those artifacts are exactly the inspected `a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d` source state. A public third-party pull mirror independently maps `v0.28.0` to `a2cae4d69f`, which makes the identity plausible, but that is corroboration rather than authoritative release identity. E002 therefore overstates `STATUS=OBSERVED`.
- B02_EVENT_TO_RENDER_CAUSAL_STITCH: The selected player attack simulation chain is strongly source-traced, and the selected entity's VisualActor->UnitRenderer->SceneCollector path is independently source-traced. However the documents join presentation branches (attack animation, projectile, impact/death/audio) and the persistent unit-render loop into one serial statement `selected player attack ... closed through renderer submission`. The inspected source proves an event-specific attack-animation branch into `IID_Visual.SelectAnimation`, and proves generic VisualActor model submission, but E023/E024 do not yet source-close every attack-event presentation branch (especially ProjectileManager / impact / death presentation) to its renderer submission. The current wording is stronger than the demonstrated caller/data-flow graph.

NON_BLOCKING_FIXES:
- N01_AUDIT_CONTRACT_REVISION_TRACEABILITY: `EVIDENCE_REGISTER.md@0c47af91...` names `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`, but that file is not present at the audited `a8040c20...` branch revision. It exists on current `main`. This does not invalidate the source facts, but the evidence packet is not revision-self-contained.
- N02_PRODUCTION_ASSET_WORDING: The source fact is that active Battle01 3D units are primitive `CylinderMesh/BoxMesh` proxies with runtime `StandardMaterial3D`, and no imported mesh/texture/animation unit chain is wired there. Calling that automatically a `production gap` is a FRONTLINE-specific product judgement, not a pure source fact. It should be labeled `PROJECT_SPECIFIC_INFERENCE` unless an explicit product requirement is cited.
- N03_DETERMINISM_WORDING: E015 source-closes the turn/command-queue transport. The adjective `deterministic` should not be used as a design motive or guaranteed property unless separately sourced; the audited files prove the queue path, not the unique reason it exists.

## 1. Six hard audit contract results

PRIMARY_SOURCE_INTEGRITY=PASS
- No secondary article/blog/forum/Reddit summary was found masquerading as implementation proof in the core E010-E042 claims.
- Core mechanics cite source files at pinned source states.
- The 0 A.D. release-identity bridge is a VERSION_IDENTITY defect, not evidence that 01 substituted a prose article for code.

VERSION_IDENTITY=FIX
- BAR/Recoil/Warzone commit identities were independently resolved at the stated SHAs.
- FRONTLINE claims were independently checked at `06710c3d...`.
- The 0 A.D. inspected SHA contains a coherent 2026 Release-28-era source state and is independently mirrored as `v0.28.0`, but the authoritative official release artifact/tag-to-SHA identity is not closed inside the evidence packet.

RUNTIME_SEMANTICS=FIX
- UnitAI middle semantics, FRONTLINE RED control absence, FRONTLINE logical FIRE, hidden 2D FX and missing active 3D fire consumer all survive caller/state inspection.
- The renderer claim is partly over-stitched: persistent unit rendering and all event-specific presentation branches are not one single serial caller chain as currently drawn.
- Final player-visible runtime remains correctly `UNKNOWN`; code existence was not promoted to runtime reproduction there.

GENERALIZATION_BOUNDARY=DOWNGRADE
- 01 correctly rejects `AI must use human Selection/Input` and `every RTS should use 0 A.D.'s command queue`.
- It also explicitly refuses architecture transfer to FRONTLINE.
- The main remaining scope problem is the label `production asset binding gap`; the underlying source observation is valid, while the production-value conclusion needs FRONTLINE-specific criteria.

ALTERNATIVE_EXPLANATIONS=PASS
- The audited documents generally avoid claiming unique design motives from code structure.
- They explicitly state that architectural difference alone is not a quality verdict and that current Battle01 is not product-design authority.
- The audit nevertheless records that 0 A.D.'s turn queue may reflect project-specific networking/determinism/history/tooling constraints, and Battle01 primitives may reflect an intentional transitional shell; neither alternative changes the observed source edges.

COUNTEREXAMPLE_SEARCH=PASS
- BAR/Recoil and Warzone contain concrete, version-pinned counterexamples.
- They are sufficient to falsify necessity claims about human-selection entry and 0 A.D.-specific command-queue architecture.

---

# 2. Claim audit records

## C01 — 0 A.D. Release-28 version identity

ORIGINAL_CLAIM=The first vertical trace is pinned to `v0.28.0 / a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d`, not archived GitHub master.
PRIMARY_SOURCE=Official `https://play0ad.com/download/source/` Release-28 source distribution; inspected source snapshot at `a2cae4d69...`; repository source files.
VERSION_IDENTITY=Official page proves Release 28 uses `0ad-0.28.0-unix-build` and `0ad-0.28.0-unix-data`. The audit could not obtain an authoritative Wildfire Games Gitea tag->SHA response. A third-party Gitea pull mirror maps `v0.28.0` to `a2cae4d69f`, which is corroborating but not authoritative identity proof.
RUNTIME_SEMANTICS=Not applicable to the version mapping itself.
HIDDEN_ASSUMPTIONS=That the public pull mirror tag is exactly the official release tag/tree; that no post-tag packaging/data delta exists; that source/data archives and the inspected combined tree are byte-equivalent where claims are made.
ALTERNATIVE_EXPLANATION=`a2ca...` could be a release-branch/final-candidate state that is functionally near-identical to the release without being proven to be the exact official packaged release tree.
COUNTEREXAMPLE=The archived `0ad/0ad` GitHub `master` explicitly cannot establish 2026 R28 identity by itself; this is already acknowledged by 01.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=FIX
REQUIRED_FIX=Attach one authoritative identity proof: official Gitea `v0.28.0` tag->commit/tree; or official release archive hashes plus per-file/tree equivalence for all files used in E010-E027; or an official release manifest binding the inspected SHA/tree to 0.28.0. Until then change E002 from `OBSERVED` to `INFERRED/identity pending` and phrase all R28 source claims as `inspected a2ca source state, believed/version-matched to R28`.

## C02 — First selected player attack is closed through renderer submission

ORIGINAL_CLAIM=`FIRST_REFERENCE_SOURCE_CHAIN=SOURCE_CLOSED_FOR_SELECTED_PLAYER_ATTACK_THROUGH_RENDER_SUBMISSION` and the macro chain serially reaches `VisualActor -> UnitRenderer/SceneCollector` after combat/presentation.
PRIMARY_SOURCE=`UnitAI.js`; `Attack.js`; `DelayedDamage.js`; attack-effect/Health sources; `CCmpVisualActor.cpp`; `CCmpUnitRenderer.cpp` at inspected `a2ca...`.
VERSION_IDENTITY=Inspected files are internally consistent at `a2ca...`; Release-28 label inherits C01 caveat.
RUNTIME_SEMANTICS=The audit independently confirmed: `UnitAI.Attack -> AddOrder -> FSM Order.Attack -> APPROACHING/ATTACKING -> Attack.StartAttacking`; `Attack.StartAttacking` selects `attack_<type>` through `IID_Visual`; `PerformAttack` launches through `IID_ProjectileManager` and schedules delayed damage; `CCmpVisualActor` receives interpolated-position changes, registers its model with `ICmpUnitRenderer`, and updates renderer position; `CCmpUnitRenderer::RenderSubmit` applies visibility/frustum guards and calls `collector.SubmitRecursive(&unitModel)`. These are real source paths. What is not established as one serial edge is `all attack presentation branches -> VisualActor -> one renderer submission`. Projectile, impact, death/corpse and audio are separate branches/systems.
HIDDEN_ASSUMPTIONS=That because the persistent attacking unit actor is submitted, every selected attack presentation consequence has thereby been traced to render submission; that adjacency of E023 and E024 is equivalent to caller/data-flow causality.
ALTERNATIVE_EXPLANATION=The unit would be submitted by the render loop even if no attack occurred. The attack changes animation/projectile/state branches while the unit-render submission is an ongoing presentation process, so the correct model is a branching DAG rather than one linear attack-caused chain.
COUNTEREXAMPLE=The same inspected `Attack.js` already provides an internal counterexample to single-path convergence: projectile presentation is sent to `IID_ProjectileManager`, not to `CCmpVisualActor`.
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
VERDICT=FIX
REQUIRED_FIX=Rewrite the end-to-end graph as branches: (A) control/simulation attack chain through damage/Health; (B) attack-animation -> IID_Visual/VisualActor -> UnitRenderer -> SceneCollector; (C) projectile -> ProjectileManager -> [trace its render submission separately]; (D) hit/impact/death/audio -> their concrete presentation consumers -> [trace renderer/audio submission separately]. Only claim `source-closed through renderer submission` for the branch actually source-closed. Do not join independent paths with a serial arrow.

## C03 — Former U-01 UnitAI middle gap

ORIGINAL_CLAIM=`UnitAI.Attack -> AddOrder("Attack") -> Replace/Push -> UnitFsm.ProcessMessage("Order.Attack") -> COMBAT.APPROACHING/ATTACKING -> MoveToTargetAttackRange -> UnitMotion.MoveToTargetRange -> COMBAT.ATTACKING -> Attack.StartAttacking` is source-closed for the chosen player-issued attack.
PRIMARY_SOURCE=`binaries/data/mods/public/simulation/components/UnitAI.js` at `a2ca...`.
VERSION_IDENTITY=Exact inspected SHA fixed; R28 naming inherits C01 caveat.
RUNTIME_SEMANTICS=PASS at source level. `Attack()` builds a forced player order and calls `AddOrder`; `AddOrder` selects Replace/Push behavior; `Order.Attack` checks best attack/range and chooses ATTACKING or APPROACHING subject to packing/stance/mobility guards; ATTACKING calls `cmpAttack.StartAttacking`. The out-of-range branch is conditional, not universal, and 01 preserves those guards/limitations.
HIDDEN_ASSUMPTIONS=Only that the selected entity actually reaches the chosen branch at runtime; 01 does not claim every attack/formation/packing/hunting branch is identical.
ALTERNATIVE_EXPLANATION=Formation-controller, packing/unpacking, stand-ground, inability-to-move and failed-target branches can alter the path. 01 explicitly excludes these from the universal claim.
COUNTEREXAMPLE=Internal UnitAI branches themselves are counterexamples to a single universal attack path, and 01 correctly scopes around them.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
REQUIRED_FIX=No semantic repair for U-01. Apply C01 version-language repair to the R28 label.

## C04 — FRONTLINE current Battle01 RED AI/control gap

ORIGINAL_CLAIM=Current Battle01 has RED combat formations but no source-wired RED tactical decision/command/target producer in the active scene.
PRIMARY_SOURCE=`Battle01.tscn`; `battle01.gd`; `formal_combat_roster.gd`; `player_war_flow.gd`; `selection_controller.gd`; `formation.gd` at `06710c3d...`; historical `enemy_ai_controller.gd` used only as historical contrast.
VERSION_IDENTITY=main source state pinned to `06710c3d...` in the audited evidence.
RUNTIME_SEMANTICS=PASS. `Battle01.tscn` has no EnemyAIController resource/node. `battle01.gd` binds RED formations to navigation/visibility and health/fire/death signals but instantiates no tactical producer. `SelectionController` restricts direct selectable/ADVANCE control to BLUE and treats RED as targets. `BattleFormation._update_combat` requires an externally assigned `_combat_target` and has no autonomous target scan.
HIDDEN_ASSUMPTIONS=That no dynamically instantiated RED producer exists outside the inspected active boot/control path. 01 avoids absolute repository-wide absence wording and explicitly preserves historical AI.
ALTERNATIVE_EXPLANATION=The gap can be intentional: the current Battle01 runtime shell may deliberately omit legacy RED AI while retaining historical scripts/tests. This changes design interpretation, not the current-scene wiring fact.
COUNTEREXAMPLE=Historical `enemy_ai_controller.gd` proves AI implementation exists elsewhere/history, which is exactly why wording must remain `current active Battle01 wiring gap`, not `FRONTLINE has no AI`.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
REQUIRED_FIX=Keep current narrow wording; do not upgrade to repository-wide/project-wide AI absence or runtime inactivity without runtime evidence.

## C05 — FRONTLINE logical FIRE -> current 3D Presentation break

ORIGINAL_CLAIM=Logical combat fires and transitional 2D FX exist, but the active 3D proxy presentation does not consume `attack_fired` / shot state into 3D muzzle/tracer/projectile/impact feedback.
PRIMARY_SOURCE=`formation.gd`; `battle01.gd`; `battle_3d_presentation.gd`; `Battle01.tscn` at `06710c3d...`.
VERSION_IDENTITY=Pinned FRONTLINE source state.
RUNTIME_SEMANTICS=PASS. `_update_combat` decrements ammo, emits `attack_fired`, applies damage and stores shot FX state. `_draw_combat_fx` draws 2D tracer/glow/muzzle/impact feedback. Active Battle01 hides the formation CanvasItem while `Battle3DPresentation` renders separate MeshInstance3D proxies. `battle01.gd::_on_attack_fired` uses the signal for RED intel/first-combat bookkeeping; `Battle3DPresentation` has no `attack_fired` connection or shot-state consumer.
HIDDEN_ASSUMPTIONS=Only if wording expands to `no possible feedback anywhere`. 01 explicitly avoids that absolute claim.
ALTERNATIVE_EXPLANATION=An external audio/camera/global hook could exist outside the inspected path. That possibility does not repair the specifically audited `logic FIRE -> active Battle3DPresentation combat visual feedback` edge.
COUNTEREXAMPLE=The hidden/transitional 2D path is itself evidence that logic-to-feedback exists in one presentation layer while the 3D proxy layer lacks the equivalent consumer.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
REQUIRED_FIX=None for the scoped source claim. Runtime player-visible confirmation is still required before claiming exact visible outcome.

## C06 — Old/transitional 2D tracer/muzzle/impact is not current 3D feedback

ORIGINAL_CLAIM=2D tracer/muzzle/impact/death feedback exists historically/transitionally, but is not evidence that current 3D feedback is connected.
PRIMARY_SOURCE=`formation.gd`; `Battle01.tscn`; `battle_3d_presentation.gd` at `06710c3d...`.
VERSION_IDENTITY=Pinned FRONTLINE source state.
RUNTIME_SEMANTICS=The 2D code is live source but its CanvasItem presentation is alpha-hidden by the 3D shell; the 3D presentation uses independent MeshInstance3D proxies and does not consume the shot state.
HIDDEN_ASSUMPTIONS=None material in 01 wording.
ALTERNATIVE_EXPLANATION=The 2D effects can still be useful as legacy/transitional implementation evidence; that does not make them visible/current 3D feedback.
COUNTEREXAMPLE=Not required; this is a current project wiring fact.
GENERALIZATION_LEVEL=SOURCE_FACT
VERDICT=PASS
REQUIRED_FIX=Continue using `historical/transitional/hidden 2D feedback exists` and `active 3D fire-feedback edge is missing`; never collapse them into `combat feedback already connected`.

## C07 — AI need not traverse human Selection/Input

ORIGINAL_CLAIM=BAR/Recoil and Warzone provide concrete counterexamples to a universal claim that AI must pass through the exact human selection/input layer.
PRIMARY_SOURCE=BAR `luarules/gadgets/pve_boss_priority_targetting.lua` at `28e122...`; Recoil `rts/Lua/LuaSyncedCtrl.cpp` at `05c054...`; Warzone Cobra `events.js` + `wzapi.cpp` at `b028808...`.
VERSION_IDENTITY=All three pinned commits independently resolved.
RUNTIME_SEMANTICS=PASS at source level. BAR's enabled synced gadget selects queen/boss targets in `GameFrame` and calls `Spring.GiveOrderToUnit(CMD.ATTACK)` directly. Pinned Recoil source registers `GiveOrderToUnit` and hands parsed/validated commands to `unit->commandAI->GiveCommand`. Warzone Cobra `eventAttacked` makes tactical decisions and calls `orderDroidObj/orderDroidLoc`; native `wzapi::orderDroidObj` forwards into native droid order machinery.
HIDDEN_ASSUMPTIONS=These examples do not characterize every bot/AI path in those projects.
ALTERNATIVE_EXPLANATION=Some other AI systems may optionally reuse player-command abstractions; existence of one non-human-selection path is still sufficient to falsify a universal necessity claim.
COUNTEREXAMPLE=BAR/Recoil and Warzone are the counterexamples.
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN
VERDICT=PASS
REQUIRED_FIX=None. Preserve existential/falsification wording: `AI does not have to traverse the exact human Selection/Input layer`; do not turn this into `AI should always bypass shared command infrastructure`.

## C08 — RTS need not adopt 0 A.D.-style command queue

ORIGINAL_CLAIM=BAR/Recoil and Warzone reject a universal requirement for 0 A.D.'s AI-manager/turn-command-queue architecture.
PRIMARY_SOURCE=0 A.D. E026 source path; BAR/Recoil pinned gadget+engine source; Warzone pinned JS/native order source.
VERSION_IDENTITY=BAR/Recoil/Warzone identities pass; 0 A.D. R28 label inherits C01 provenance caveat.
RUNTIME_SEMANTICS=PASS for architectural difference. Recoil synced Lua can enter per-unit `commandAI->GiveCommand`; Warzone JS enters native droid order APIs; neither inspected path is the same `AI API -> CCmpAIManager buffer -> ICmpCommandQueue -> ProcessCommand` architecture.
HIDDEN_ASSUMPTIONS=Different entry boundaries do not prove absence of all queues, network synchronization, buffering or deterministic sequencing elsewhere in BAR/Recoil/Warzone.
ALTERNATIVE_EXPLANATION=All three engines may still use queues internally for different concerns. That does not rescue the stronger universal claim that the 0 A.D.-specific queue architecture is required.
COUNTEREXAMPLE=BAR/Recoil and Warzone.
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN
VERDICT=PASS
REQUIRED_FIX=Keep wording exactly at architecture non-necessity. Do not write `RTS do not need command queues` or `direct commandAI entry is better`.

## C09 — Narrow common AI/order boundary pattern

ORIGINAL_CLAIM=Across inspected 0 A.D., BAR/Recoil and Warzone paths, automated control hands off into a game/engine-recognized command/order execution boundary, while the location/mechanism differs.
PRIMARY_SOURCE=E026 + E039-E041 source files.
VERSION_IDENTITY=As above.
RUNTIME_SEMANTICS=Supported for the inspected paths only.
HIDDEN_ASSUMPTIONS=Three projects are not the entire RTS design space; highly specialized RTS-like simulations could couple policy and execution differently.
ALTERNATIVE_EXPLANATION=The observed separation may result from networking, modding API boundaries, legacy architecture, engine/game separation, maintainability or testability rather than one universal design principle.
COUNTEREXAMPLE=No counterexample was found among the three inspected projects, but absence from this small sample cannot establish necessity.
GENERALIZATION_LEVEL=CROSS_PROJECT_PATTERN
VERDICT=PASS
REQUIRED_FIX=Retain `inspected cross-project pattern`, never upgrade to `RTS rule` or `FRONTLINE must implement a command object/queue` without FRONTLINE-specific reproduction and constraints.

## C10 — Active primitive 3D unit path is a production gap

ORIGINAL_CLAIM=Current Battle01's primitive unit proxy path constitutes an observed production asset-binding gap.
PRIMARY_SOURCE=`battle_3d_presentation.gd`; `Battle01.tscn` at `06710c3d...`.
VERSION_IDENTITY=PASS.
RUNTIME_SEMANTICS=Source fact: active proxies are runtime primitives/materials and no imported unit mesh/texture/animation binding is present in that path.
HIDDEN_ASSUMPTIONS=That a production-quality FRONTLINE unit necessarily requires imported mesh/texture/animation assets rather than procedural/generated/other production-quality representations.
ALTERNATIVE_EXPLANATION=The primitive path can be an intentional greybox/transitional presentation shell; procedural generation itself is not synonymous with non-production quality.
COUNTEREXAMPLE=Many production games use procedural or runtime-generated geometry/materials for some assets; therefore `primitive/procedural` alone does not establish failure.
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
VERDICT=DOWNGRADE
REQUIRED_FIX=Split wording: `SOURCE_FACT=current active path uses primitive proxy meshes and runtime materials and lacks imported unit mesh/texture/animation binding`; `PROJECT_SPECIFIC_INFERENCE=this is inadequate for the currently targeted FRONTLINE visual/product standard`, with that target/acceptance evidence cited separately.

---

# 3. Specific requested findings

REQUEST_1_R28_ATTACK_CHAIN_TO_RENDER=FIX
- Simulation/control middle is strong and source-backed.
- Unit actor rendering is source-backed.
- Attack animation -> IID_Visual -> VisualActor model path is source-backed.
- The document must not represent all projectile/impact/death/audio branches as if they serially flow through VisualActor/UnitRenderer. Event-specific render branches need their own trace.

REQUEST_2_U01_UNITAI_MIDDLE=PASS
- Former U001 is genuinely source-closed at the inspected source state for the bounded chosen player-issued attack path.

REQUEST_3_FRONTLINE_RED_AI_OBSERVED_GAP=PASS
- Correctly scoped to current active Battle01 source wiring, not repository-wide AI nonexistence.

REQUEST_4_FRONTLINE_FIRE_TO_CURRENT_3D_PRESENTATION_BREAK=PASS
- A concrete missing consumer is visible in source.

REQUEST_5_OLD_2D_FX_SCOPE=PASS
- 01 accurately labels them transitional/hidden 2D feedback and does not promote them to current 3D feedback.

REQUEST_6_BAR_RECOIL_WARZONE_COUNTEREXAMPLES=PASS
- They falsify the two stated universal architecture claims.
- No evidence supports upgrading the surviving narrow pattern into an RTS law.

---

# 4. Required repairs before Window 03 can PASS this chain

1. Close authoritative R28 identity.
   - Preferred: official Wildfire Games Gitea `v0.28.0` tag -> exact commit/tree proof.
   - Acceptable alternative: official Release-28 build/data archive hashes plus exact equivalence evidence for every cited source/data file.
   - A third-party mirror tag is corroboration only.

2. Replace the serial `attack -> all presentation -> VisualActor -> renderer` drawing with a branching causal graph.
   - Source-close the projectile branch through ProjectileManager to renderer, or leave its render-submission edge UNKNOWN.
   - Source-close impact/death presentation to their concrete renderer/audio consumers, or leave those final edges UNKNOWN.
   - Keep `attack animation -> IID_Visual -> CCmpVisualActor -> UnitRenderer -> SceneCollector` as a separately proven branch.

3. Downgrade `production asset-binding gap` from pure observed fact to a FRONTLINE-specific inference unless a frozen product requirement establishes imported/animated production unit assets as mandatory.

4. Make the audit packet revision-self-contained: either add the audit-contract file to the audited learning branch or record the exact main commit containing it.

5. Preserve current UNKNOWNs.
   - R28 actual player-visible runtime result remains UNKNOWN.
   - FRONTLINE actual current player-visible result remains UNKNOWN.
   - No Window 02 reproduction may convert these to PASS without a real runtime artifact.

---

# 5. Allowed handoff wording to Window 00

WINDOW_03_AUDIT=FAIL
AUDIT_FAILURE_TYPE=REPAIRABLE_EVIDENCE_AND_CAUSAL_SCOPE_FAILURE
UNITAI_U01_SOURCE_SEMANTICS=PASS_AT_INSPECTED_SHA
FRONTLINE_RED_AI_CURRENT_SCENE_GAP=PASS
FRONTLINE_FIRE_TO_ACTIVE_3D_FEEDBACK_GAP=PASS
OLD_2D_FX_SCOPE=PASS
BAR_RECOIL_WARZONE_COUNTEREXAMPLES=PASS
ZERO_AD_RELEASE28_AUTHORITATIVE_VERSION_IDENTITY=FIX
ZERO_AD_SELECTED_ATTACK_SOURCE_CHAIN_THROUGH_ALL_EVENT_PRESENTATION_RENDER_BRANCHES=FIX
FRONTLINE_PRODUCTION_ASSET_GAP_WORDING=DOWNGRADE
R28_PLAYER_RUNTIME=UNKNOWN
FRONTLINE_PLAYER_RUNTIME=UNKNOWN
WINDOW_02_MUST_NOT_TREAT_WINDOW_01_CHAIN_AS_AUDITED_PASS=YES

Window 03 does not reject the useful source work in Window 01. It rejects the current overall PASS-equivalent wording because two core links remain stronger than their independent evidence: authoritative R28 version identity and the serial stitching of event-specific presentation into generic renderer submission.
