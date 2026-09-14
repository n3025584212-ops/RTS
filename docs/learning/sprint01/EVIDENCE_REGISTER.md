# Learning Sprint 01 — Evidence Register

STATUS=ACTIVE
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
DATE=2026-09-14
ACTIVE_ISSUE=#39
AUDIT_RESPONSE_TO=docs/audit/AUDIT_SPRINT01_SYSTEM_CAUSAL_CHAIN_V1.md
WINDOW_01_AUDIT_BLOCKER_RESPONSE=READY_FOR_REAUDIT
WINDOW_03_AUDIT=FAIL_PENDING_REAUDIT

PRIMARY_REFERENCE=0_AD_RELEASE_28
ZERO_AD_INSPECTED_SOURCE_STATE=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
ZERO_AD_RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
VERSION_IDENTITY=VERSION_IDENTITY_PENDING
FRONTLINE_MAIN_INSPECTED=06710c3d9e29d3400572bf25ed5e8fd96c73b472
BAR_INSPECTED_COMMIT=28e122237458f39cd89d254aa44bfc31448cc7f6
RECOIL_INSPECTED_COMMIT=05c054cbe2249feda3637cabfe122b75241113e9
WARZONE_INSPECTED_COMMIT=b0288082c54536ae3634a6a71b0e03f0d82bb8f3

This revision is Window 01's response to the independent Window 03 audit at `fe3975355c16a8e665d54c0b62008e124de792ac`. It does not change that audit to PASS. Window 03 must re-audit this packet independently.

## 0. Revision traceability

The pre-audit detailed evidence remains preserved verbatim at:

- `docs/learning/sprint01/baseline/EVIDENCE_REGISTER_PRE_AUDIT.md`
- `docs/learning/sprint01/baseline/END_TO_END_CHAIN_PRE_AUDIT.md`

The current learning revision also contains the governing files that were missing from the audited packet:

- `docs/GPT_FOUR_WINDOW_SYSTEM_V5.md`
- `docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md`
- `docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`

N01_AUDIT_CONTRACT_REVISION_TRACEABILITY=REPAIRED_IN_PACKET

## 1. Evidence/status vocabulary

Allowed epistemic statuses are only:

- `OBSERVED`
- `REPRODUCED`
- `INFERRED`
- `HYPOTHESIS`
- `UNKNOWN`
- `REJECTED`

Allowed conclusion classes are:

- `SOURCE_FACT`
- `PROJECT_SPECIFIC_INFERENCE`
- `CROSS_PROJECT_PATTERN`
- `DESIGN_RECOMMENDATION`
- `UNSUPPORTED_GENERALIZATION`

`UNKNOWN` is not failure. An unproved edge must remain UNKNOWN rather than being completed by adjacency or plausible prose.

---

# A. B01 — Release-28 version identity repair

## E001 — Official Release 28 artifacts exist

CLAIM=The official 0 A.D. Release-28 distribution exposes 0.28.0 source/game-data release artifacts.
CHAIN_LAYER=PROVENANCE
SOURCE=Official 0 A.D. Release-28 download/source distribution referenced by the audited evidence packet.
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
WHAT_THE_SOURCE_ACTUALLY_PROVES=Release 28 / 0.28.0 has official release artifacts suitable for source inspection.
WHAT_IT_DOES_NOT_PROVE=That the inspected source state `a2cae4d69f...` is the exact authoritative tree/commit of those official artifacts.

## E002 — Inspected a2ca source state is believed/version-matched to R28, not authoritatively identity-closed

CLAIM=The inspected source state `a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d` is strongly corroborated as corresponding to 0.28.0 / R28, but this evidence packet does not contain an authoritative official release-artifact/tag/tree-to-commit binding proving exact identity.
CHAIN_LAYER=PROVENANCE
EDGE=OFFICIAL_R28_RELEASE -> EXACT_AUTHORITATIVE_SOURCE_STATE
SOURCE=Official Release-28 distribution plus the version-matched inspected source state and third-party mirror corroboration described by Window 03.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
STATUS=INFERRED
GENERALIZATION_LEVEL=SOURCE_FACT
WHAT_THE_SOURCE_ACTUALLY_PROVES=The inspected files form a coherent source state independently matched/corroborated to v0.28.0 and are not taken from the archived GitHub `master` as a substitute.
WHAT_IT_DOES_NOT_PROVE=Official exact tag/tree/commit identity, byte-identical release archive equality, or absence of packaging/post-tag deltas.
GAP=Authoritative official R28 -> exact tag/tree/commit -> a2cae4d... identity remains unclosed.
REPRODUCTION_REQUIRED=NO

B01_VERSION_IDENTITY=DOWNGRADED_TO_INFERRED
VERSION_IDENTITY=VERSION_IDENTITY_PENDING
ALLOWED_WORDING=`inspected a2cae4d... source state believed/version-matched to R28`
FORBIDDEN_WORDING=`R28 exact source fact at a2cae4d...`
ARCHIVED_GITHUB_MASTER_USED_AS_IDENTITY_PROOF=NO

### Version-language rule for E010-E027

All source-code semantics previously traced in E010-E027 remain direct observations of the inspected `a2cae4d...` source state. Their version label is now interpreted as:

`SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28`

This preserves the source facts while removing the unsupported exact-release identity claim.

---

# B. B02 — attack event is a branching causal DAG, not a single renderer chain

CAUSAL_MODEL=BRANCHING_CAUSAL_DAG
LINEAR_ATTACK_TO_RENDER_CHAIN=REJECTED

## E020A — Simulation/state branch

CLAIM=The selected player attack source state has a source-traced simulation/state path through UnitAI, attack execution, ranged delayed damage and Health/death state.
CHAIN_LAYER=INPUT / CONTROL / SIMULATION / STATE
EDGE=PLAYER_ATTACK -> UnitAI -> Attack -> Projectile/DelayedDamage -> Damage -> Health/Death
SOURCE=The inspected `UnitAI.js`, `Attack.js`, `DelayedDamage.js`, attack-effect and Health sources recorded in the pre-audit register.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
WHAT_THE_SOURCE_ACTUALLY_PROVES=For the selected source path, attack order processing reaches Attack; ranged attack schedules delayed damage; damage reaches Health/death semantics.
WHAT_IT_DOES_NOT_PROVE=Any presentation/render/audio branch beyond the specific calls separately traced below.

## E023A — Attack-animation branch is event-specific and source-closed into the unit renderer path

CLAIM=`Attack.StartAttacking` selects the attack animation through `IID_Visual`; the selected unit's `VisualActor`/renderer path is source-traced into `UnitRenderer -> SceneCollector`.
CHAIN_LAYER=PRESENTATION / RENDER
EDGE=Attack.StartAttacking -> IID_Visual.SelectAnimation -> VisualActor -> UnitRenderer -> SceneCollector
SOURCE=Inspected Attack/VisualActor/UnitRenderer sources recorded by the audit.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE_CLOSED=YES
WHAT_THE_SOURCE_ACTUALLY_PROVES=The attack-animation branch changes the unit visual state and the unit actor has a concrete renderer submission path.
WHAT_IT_DOES_NOT_PROVE=That projectile, impact, death/corpse, or audio presentation flows through this same branch.

## E023B — Projectile-presentation branch

CLAIM=Ranged `PerformAttack` sends projectile presentation data to the projectile manager.
CHAIN_LAYER=PRESENTATION / RENDER
EDGE=PerformAttack -> ProjectileManager -> projectile presentation -> renderer submission
SOURCE=Inspected `Attack.js` and projectile-manager call cited by the audit.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=UNKNOWN
GENERALIZATION_LEVEL=SOURCE_FACT
OBSERVED_PREFIX=PerformAttack -> ProjectileManager
UNKNOWN_SUFFIX=ProjectileManager -> concrete projectile render submission path
SOURCE_CLOSED=NO

## E023C — Impact/hit-presentation branch

CLAIM=Hit/damage processing can trigger impact presentation, but this packet has not independently source-closed the complete impact consumer -> renderer submission path.
CHAIN_LAYER=PRESENTATION / RENDER
EDGE=damage/hit event -> impact consumer/effect -> renderer submission
SOURCE=Inspected delayed-damage/feedback hooks in the pre-audit evidence.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=UNKNOWN
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE_CLOSED=NO

## E023D — Death/corpse-presentation branch

CLAIM=Health/death state has death/corpse presentation hooks, but this packet has not independently source-closed the complete death/corpse visual replacement/animation -> renderer submission path.
CHAIN_LAYER=STATE / PRESENTATION / RENDER
EDGE=Health/Death -> death state -> corpse/animation/replacement -> renderer submission
SOURCE=Inspected Health/death source hooks in the pre-audit evidence.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=UNKNOWN
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE_CLOSED=NO

## E023E — Audio branch

CLAIM=Attack/order/impact/death source hooks request audio events, but the complete event -> audio system/backend -> audible player output chain has not been source-closed in this packet.
CHAIN_LAYER=PRESENTATION / PLAYER
EDGE=attack/impact/death -> audio event/system -> audible output
SOURCE=Inspected GUI/action/attack/death audio hooks in the pre-audit evidence.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=UNKNOWN
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE_CLOSED=NO

## E024 — Persistent unit rendering is a parallel runtime process

CLAIM=`CCmpVisualActor -> CCmpUnitRenderer -> SceneCollector` is a real renderer path for the unit actor, but unit render submission is not a serial consequence that proves every attack-event branch reached the renderer.
CHAIN_LAYER=PRESENTATION / RENDER
EDGE=VisualActor model state/position -> UnitRenderer.RenderSubmit -> SceneCollector.SubmitRecursive
SOURCE=`CCmpVisualActor.cpp`; `CCmpUnitRenderer.cpp` at the inspected source state.
SOURCE_VERSION=INSPECTED_SOURCE_STATE=a2cae4d69f...; RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
WHAT_THE_SOURCE_ACTUALLY_PROVES=The persistent unit actor is submitted under the renderer's normal visibility/frustum/LOS guards.
WHAT_IT_DOES_NOT_PROVE=Projectile, impact, corpse/death or audio convergence onto that renderer path.

B02_EVENT_TO_RENDER_CAUSAL_STITCH=REPAIRED_AS_BRANCHING_DAG
ATTACK_ANIMATION_BRANCH=SOURCE_CLOSED
PROJECTILE_RENDER_BRANCH=UNKNOWN
IMPACT_RENDER_BRANCH=UNKNOWN
DEATH_CORPSE_RENDER_BRANCH=UNKNOWN
AUDIO_OUTPUT_BRANCH=UNKNOWN

---

# C. Carry-forward source findings that survive the audit

The detailed caller/data evidence is preserved in `baseline/EVIDENCE_REGISTER_PRE_AUDIT.md`. Window 03 explicitly passed or retained the following scoped findings; they remain bounded source facts of their pinned inspected states:

- UnitAI middle path: `UnitAI.Attack -> AddOrder -> FSM -> APPROACHING/ATTACKING -> Attack.StartAttacking` — OBSERVED for the selected path.
- Movement: UnitAI range movement -> UnitMotion -> Pathfinder -> Position — OBSERVED for the selected path.
- Target legality and stance/range automatic-response prefix — OBSERVED with limits.
- GUI command transport -> command/turn queue -> `ProcessCommand` — OBSERVED transport path.
- BAR/Recoil and Warzone provide concrete counterexamples to `AI must traverse human Selection/Input` and to a universal 0 A.D.-style queue requirement.
- FRONTLINE active Battle01 has RED combat formations but no source-wired RED tactical command/target producer in the inspected active scene.
- FRONTLINE logical FIRE, ammo/damage/HP/death and transitional hidden 2D combat FX exist.
- Active `Battle3DPresentation` has no inspected `attack_fired`/shot-state consumer providing equivalent 3D muzzle/tracer/projectile/impact feedback.

N03_DETERMINISM_WORDING=REPAIRED
The command queue is described as a `turn/command-queue transport boundary`. This packet does not infer its unique design motive or guaranteed determinism from the queue path alone.

---

# D. N02 — FRONTLINE active primitive proxies: fact vs product inference

## E031A — SOURCE_FACT

CLAIM=In the inspected active Battle01 3D unit presentation path, role visuals are generated as `CylinderMesh` / `BoxMesh` proxies with runtime `StandardMaterial3D`; no imported unit mesh/texture/animation chain is wired into that active path.
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE=`scripts/battle01/battle_3d_presentation.gd`; `Battle01.tscn` at the pinned FRONTLINE source state.

## E031B — PROJECT_SPECIFIC_INFERENCE

CLAIM=That primitive active path is insufficient by itself for Sprint-01 reproduction asset delivery.
STATUS=INFERRED
GENERALIZATION_LEVEL=PROJECT_SPECIFIC_INFERENCE
SOURCE=`docs/learning/LEARNING_SPRINT_01_CONTRACT.md`; Issue #39; E031A.
RATIONALE=The Sprint contract explicitly requires a real-enough asset/content pipeline and forbids box/color semantic placeholders as the reproduction delivery.
WHAT_IT_DOES_NOT_PROVE=That primitives are inherently wrong for prototyping, or that every FRONTLINE scene must never use them.

N02_PRODUCTION_ASSET_WORDING=REPAIRED

---

# E. Real Asset Gate evidence

Detailed evidence is in `docs/learning/sprint01/ASSET_GATE.md`.

## E050 — Real combat mesh family exists with explicit provenance/licenses

CLAIM=A retained FRONTLINE production branch contains real Abrams MBT, IFV and rigged-soldier mesh families with explicit upstream source/license records.
CHAIN_LAYER=CONTENT / ASSET
SOURCE_BRANCH=dev/reference-region-v1
SOURCE_COMMIT=5f2ff1c0e86553234490063e640cef8d0a2fb9f7
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT

## E051 — Combat assets are actually imported and instantiated in Godot

CLAIM=The retained branch contains Godot `.import` metadata and `GoldenUnitsV1` loads, instantiates, sizes, positions, materials and adds the real MBT/IFV/soldier scenes to the running tree.
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE=`assets/golden_scene/...`; `scripts/production/golden/golden_units_v1.gd`; `scenes/production/GoldenSceneV1.tscn`
WHAT_IT_DOES_NOT_PROVE=Binding into active Battle01 gameplay or final product quality.

## E052 — Runtime/player-visible asset presence exists

CLAIM=Committed Godot 4.7.1 runtime evidence records 17 physical real-asset vehicles and 28 physical real-asset infantry and a 1920x1080 captured frame.
STATUS=OBSERVED
GENERALIZATION_LEVEL=SOURCE_FACT
SOURCE=`artifacts/golden_scene/runtime_evidence.md`; `runtime_metrics.json`; `golden_scene_v1_actual_1920x1080.png`
LIMITATIONS=The same evidence records `PRODUCT_PASS=NO` and approximately 7.4 FPS in that capture environment. Asset presence is not visual/performance acceptance.

COMBAT_UNIT_ASSET_FAMILY=READY
REQUIRED_ASSETS=READY
02_REPRODUCTION_ASSET_GATE=READY_FOR_AUDIT
WINDOW_02_START=NOT_AUTHORIZED

---

# F. Remaining UNKNOWN

- `U-R28-VERSION-IDENTITY`: official authoritative R28 release/tag/tree/commit -> `a2cae4d...` exact identity.
- `U-R28-PROJECTILE-RENDER`: ProjectileManager -> concrete renderer submission path.
- `U-R28-IMPACT-RENDER`: hit/impact consumer/effect -> concrete renderer submission path.
- `U-R28-DEATH-RENDER`: death/corpse/replacement -> concrete renderer submission path.
- `U-R28-AUDIO-OUTPUT`: event/audio request -> backend/output -> audible player result.
- `U-PLAYER-R28`: actual Sprint-01 R28 selected-event runtime/player-visible evidence.
- `U-PLAYER-FRONTLINE`: actual current Battle01 Sprint-01 runtime/player-visible operation evidence.
- `U-R28-PREFERENCE-DETAIL`: exhaustive automatic target preference across all states/formations, if later needed.
- `U-REPRODUCTION`: Window 02 isolated complete-chain reproduction outcome.
- `U-ENGINE-TRANSFER`: whether FRONTLINE should retain Godot or transfer any inspected architecture.

---

# G. Current gate

B01_VERSION_IDENTITY=DOWNGRADED_TO_INFERRED
B02_EVENT_TO_RENDER_CAUSAL_STITCH=REPAIRED_AS_BRANCHING_DAG
N01_AUDIT_CONTRACT_REVISION_TRACEABILITY=REPAIRED_IN_PACKET
N02_PRODUCTION_ASSET_WORDING=REPAIRED
N03_DETERMINISM_WORDING=REPAIRED
COMBAT_UNIT_ASSET_FAMILY=READY
REQUIRED_ASSETS=READY
02_REPRODUCTION_ASSET_GATE=READY_FOR_AUDIT
WINDOW_01_AUDIT_BLOCKER_RESPONSE=READY_FOR_REAUDIT
WINDOW_03_AUDIT=FAIL_PENDING_REAUDIT
WINDOW_02_START=NOT_AUTHORIZED
PRODUCT_PRODUCTION_RESUME=NO
