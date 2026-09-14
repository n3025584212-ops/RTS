# LEARNING SPRINT 01 — END TO END CHAIN

STATUS=CONTINUE_LEARNING
WORK_ID=LEARNING_SPRINT_01_FRONTLINE_END_TO_END_EVIDENCE_GRAPH
ACTIVE_ISSUE=#39
CORE_CHAIN=docs/learning/FRONTLINE_END_TO_END_EVIDENCE_CHAIN_V1.md
EVIDENCE_REGISTER=docs/learning/sprint01/EVIDENCE_REGISTER.md
ASSET_GATE=docs/learning/sprint01/ASSET_GATE.md
AUDIT=docs/audit/AUDIT_SPRINT01_SYSTEM_CAUSAL_CHAIN_V1.md

PRIMARY_REFERENCE=0_AD_RELEASE_28
INSPECTED_SOURCE_STATE=a2cae4d69f816e9e9d7eecb6bf88f762afc0c90d
RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28
VERSION_IDENTITY=VERSION_IDENTITY_PENDING

This revision supersedes the pre-audit linear attack-to-render drawing. The underlying detailed source trace is preserved at `docs/learning/sprint01/baseline/END_TO_END_CHAIN_PRE_AUDIT.md`.

## 1. Macro graph

The project-level learning target remains:

`CONTENT -> WORLD -> INPUT -> SIMULATION -> CONTROL -> STATE -> PRESENTATION -> RENDER -> PLAYER`

This is a macro dependency graph, not a demand that every event travels through one serial function chain. Real branches, parallel presentation systems, persistent render loops and audio paths remain separate unless a caller/data edge is actually observed.

CAUSAL_MODEL=BRANCHING_CAUSAL_DAG
LINEAR_CHAIN_AS_UNIVERSAL_MODEL=REJECTED

---

# 2. Selected player ATTACK — corrected branching DAG

## A. Simulation / state branch — OBSERVED at inspected source state

```text
player contextual ATTACK
 -> typed attack command
 -> command/turn transport
 -> ProcessCommand
 -> UnitAI.Attack
 -> Attack order / FSM
 -> [if needed] APPROACHING -> UnitMotion -> Pathfinder -> Position
 -> COMBAT.ATTACKING
 -> Attack.StartAttacking
 -> PerformAttack
 -> projectile scheduling / DelayedDamage
 -> AttackEffects / Damage
 -> Health
 -> HP / death state
```

STATUS=OBSERVED
SOURCE_CLOSED_FOR_SELECTED_SIMULATION_STATE_BRANCH=YES
VERSION_NOTE=`a2cae4d...` is the inspected source state; exact authoritative official R28 identity remains pending.

## B. Attack-animation branch — OBSERVED and source-closed into unit renderer

```text
Attack.StartAttacking
 -> IID_Visual.SelectAnimation(attack_<type>)
 -> VisualActor model/animation state
 -> UnitRenderer
 -> SceneCollector.SubmitRecursive(unit model)
```

STATUS=OBSERVED
SOURCE_CLOSED=YES

This branch is event-specific at its animation input and reaches the unit renderer path.

## C. Projectile-presentation branch — prefix observed, renderer closure UNKNOWN

```text
PerformAttack
 -> ProjectileManager
 -> projectile presentation
 -> ??? concrete renderer submission
```

STATUS=UNKNOWN
OBSERVED_PREFIX=PerformAttack -> ProjectileManager
SOURCE_CLOSED=NO

## D. Impact/hit-presentation branch — UNKNOWN after the known hit/effect prefix

```text
damage / hit event
 -> impact consumer/effect
 -> ??? concrete renderer submission
```

STATUS=UNKNOWN
SOURCE_CLOSED=NO

## E. Death/corpse-presentation branch — UNKNOWN after death-state hooks

```text
Health / death
 -> death state
 -> corpse / animation / replacement
 -> ??? concrete renderer submission
```

STATUS=UNKNOWN
SOURCE_CLOSED=NO

## F. Audio branch — source hooks exist, final output closure UNKNOWN

```text
attack / order / impact / death
 -> audio event/request
 -> ??? audio system/backend/output
 -> audible player result
```

STATUS=UNKNOWN
SOURCE_CLOSED=NO

## G. Persistent unit rendering — parallel runtime path, not proof of C/D/E/F

```text
simulation/interpolated unit visual state
 -> CCmpVisualActor
 -> CCmpUnitRenderer.RenderSubmit
 -> LOS/frustum checks
 -> SceneCollector.SubmitRecursive(unit model)
```

STATUS=OBSERVED

The unit actor can be submitted every render cycle independently of whether a projectile, impact or death effect has been rendered. Therefore this path must not be appended after all attack presentation branches as if it proved their convergence.

B02_EVENT_TO_RENDER_CAUSAL_STITCH=REPAIRED_AS_BRANCHING_DAG

---

# 3. 13-layer coverage after audit repair

| Layer | Selected external source trace | FRONTLINE inspected mapping |
|---|---|---|
| 1 Map / battle space | OBSERVED at inspected source state | OBSERVED |
| 2 Unit data | OBSERVED | OBSERVED |
| 3 Asset binding | OBSERVED actor/mesh/material/animation chain | active Battle01 primitive proxy SOURCE_FACT; real retained asset family separately READY for reproduction audit |
| 4 Player selection | OBSERVED | OBSERVED |
| 5 Command routing | OBSERVED | OBSERVED |
| 6 Movement/pathfinding | OBSERVED for selected branch | OBSERVED |
| 7 Target legality/response | OBSERVED selected target; automatic response prefix OBSERVED | BLUE target path OBSERVED; active RED producer absent in inspected scene |
| 8 Fire/hit/damage/death | OBSERVED selected simulation branch | OBSERVED logical combat |
| 9 AI command generation | command injection OBSERVED; high-level selected-AI reasoning out of scope | active RED producer gap OBSERVED in inspected scene |
| 10 UI state | OBSERVED Health -> UI route | OBSERVED callbacks/signals |
| 11 Animation/VFX/audio | attack-animation branch OBSERVED; projectile/impact/death/audio closures separated and partly UNKNOWN | transitional hidden 2D FX OBSERVED; active 3D FIRE consumer gap OBSERVED |
| 12 Camera/render | unit VisualActor renderer path OBSERVED; projectile/impact/death render paths not conflated | active shell configuration OBSERVED |
| 13 PLAYER | UNKNOWN for Sprint-selected external event | UNKNOWN for new Sprint Battle01 operation |

---

# 4. Version identity boundary

The official Release-28 artifacts establish that 0.28.0/R28 source/game data was released. The current packet does not contain authoritative official evidence proving that exact release artifacts/tag/tree map exactly to `a2cae4d69f...`.

Therefore:

```text
OFFICIAL R28 RELEASE ARTIFACTS [OBSERVED]
          |
          | exact official tag/tree/commit identity
          v
      [UNKNOWN]
          |
          | third-party/version-match corroboration
          v
INSPECTED a2cae4d... SOURCE STATE [directly inspected]
```

VERSION_IDENTITY=VERSION_IDENTITY_PENDING
RELEASE_RELATION=INFERRED_VERSION_MATCH_TO_R28

All semantic source statements in this packet are statements about the inspected source state first. The R28 label is qualified by the identity caveat.

B01_VERSION_IDENTITY=DOWNGRADED_TO_INFERRED

---

# 5. FRONTLINE current mapping — fact/inference separation

## 5.1 Active Battle01 primitive unit presentation

SOURCE_FACT:

```text
formation role
 -> Battle3DPresentation role mesh
 -> CylinderMesh / BoxMesh
 -> runtime StandardMaterial3D
 -> MeshInstance3D proxy
```

STATUS=OBSERVED

PROJECT_SPECIFIC_INFERENCE:
The active primitive path is insufficient **for this Sprint-01 reproduction delivery by itself** because `LEARNING_SPRINT_01_CONTRACT.md` and Issue #39 require real enough asset/content binding and explicitly reject boxes/color placeholders as the delivered reproduction.

This is not a universal claim that primitives are invalid prototyping tools.

## 5.2 RED tactical producer

```text
loaded Battle01 RED formations
 -> roster/state wiring exists
 X-> no inspected active RED tactical command/target producer
```

STATUS=OBSERVED_SOURCE_WIRING_GAP

Historical AI files remain historical contrast and are not erased by this scoped claim.

## 5.3 FIRE -> presentation

```text
logical FIRE
 +--> ammo/damage/HP/death [OBSERVED]
 +--> transitional Formation 2D tracer/muzzle/impact/death drawing [OBSERVED]
 X--> active Battle3DPresentation equivalent 3D fire consumer [OBSERVED SOURCE-WIRING GAP]
```

The absence claim is deliberately limited to the inspected active 3D presentation path.

---

# 6. Cross-project falsification result retained

The first BAR/Recoil and Warzone counterexample pass survives audit:

```text
0 A.D. inspected path : AI API -> AI manager buffer -> command queue -> ProcessCommand
BAR/Recoil            : synced Lua -> GiveOrderToUnit -> per-unit commandAI
Warzone               : JS AI -> orderDroid* -> native droid order/action machinery
```

CROSS_PROJECT_PATTERN=INFERRED_ONLY
Supported narrow wording: automated/game-side control can hand decisions into a game-recognized command/order execution boundary, while the boundary's location and mechanics differ materially.

REJECTED=`AI must traverse the exact human Selection/Input layer`
REJECTED=`all RTS should use 0 A.D.'s turn command queue`

No architecture transfer to FRONTLINE follows from this alone.

---

# 7. Real Asset Gate handoff boundary

`docs/learning/sprint01/ASSET_GATE.md` records a retained real combat family:

```text
licensed upstream source
 -> real Abrams / IFV / soldier meshes
 -> Godot import metadata
 -> GoldenSceneV1 scene/script binding
 -> load / instantiate / add_child runtime use
 -> 17 physical real-asset vehicles + 28 real-asset infantry
 -> committed 1920x1080 runtime capture
```

COMBAT_UNIT_ASSET_FAMILY=READY
REQUIRED_ASSETS=READY
02_REPRODUCTION_ASSET_GATE=READY_FOR_AUDIT

Boundaries:
- this is asset availability/runtime-use evidence, not product visual acceptance;
- the recorded Golden Scene says `PRODUCT_PASS=NO` and ~7.4 FPS in that environment;
- these assets are not currently wired into active Battle01 gameplay;
- Window 02 must use them (or an equally evidenced family) in the isolated reproduction and produce its own real runtime evidence.

---

# 8. Remaining critical UNKNOWN

```text
U-R28-VERSION-IDENTITY
U-R28-PROJECTILE-RENDER
U-R28-IMPACT-RENDER
U-R28-DEATH-RENDER
U-R28-AUDIO-OUTPUT
U-PLAYER-R28
U-PLAYER-FRONTLINE
U-R28-PREFERENCE-DETAIL [optional deeper trace]
U-REPRODUCTION
U-ENGINE-TRANSFER
```

---

# 9. Current gate

```text
CAUSAL_MODEL=BRANCHING_CAUSAL_DAG
B01_VERSION_IDENTITY=DOWNGRADED_TO_INFERRED
VERSION_IDENTITY=VERSION_IDENTITY_PENDING
B02_EVENT_TO_RENDER_CAUSAL_STITCH=REPAIRED_AS_BRANCHING_DAG
ATTACK_ANIMATION_BRANCH=SOURCE_CLOSED
PROJECTILE_RENDER_BRANCH=UNKNOWN
IMPACT_RENDER_BRANCH=UNKNOWN
DEATH_CORPSE_RENDER_BRANCH=UNKNOWN
AUDIO_OUTPUT_BRANCH=UNKNOWN
COMBAT_UNIT_ASSET_FAMILY=READY
REQUIRED_ASSETS=READY
02_REPRODUCTION_ASSET_GATE=READY_FOR_AUDIT
WINDOW_01_AUDIT_BLOCKER_RESPONSE=READY_FOR_REAUDIT
WINDOW_03_AUDIT=FAIL_PENDING_REAUDIT
WINDOW_02_START=NOT_AUTHORIZED
PRODUCT_PRODUCTION_RESUME=NO
STATUS=CONTINUE_LEARNING
```

Window 01 does not self-authorize audit PASS, Sprint PASS, Window 02 start, or product transfer.
