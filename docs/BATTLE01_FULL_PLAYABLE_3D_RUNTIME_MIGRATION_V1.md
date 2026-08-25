# BATTLE01_FULL_PLAYABLE_3D_RUNTIME_MIGRATION_V1

TASK_ID=MIGRATE_BATTLE01_FULL_PLAYABLE_RUNTIME_TO_3D_V1
OWNER_WINDOW=WINDOW_00_CONTROL
STATUS=FROZEN_PROJECT_MIGRATION_CONTRACT
ENGINE=Godot 4.7.1
SOURCE_OF_TRUTH=GITHUB_MAIN
RISK_LEVEL=HIGH
PRODUCT_GOAL=FULL_PLAYABLE_BATTLE01_RTS
WORLD_TARGET=3D
HUD_TARGET=2D_CONTROL
RENDERER_TARGET=FORWARD_PLUS
MATERIAL_TARGET=PBR
BEAUTY_SCENE_IS_PRODUCT=NO
NEW_GAMEPLAY_SYSTEM=NO
NEW_GAMEPLAY_UNIT=NO
SCOPE_EXPANSION=NO

## 1. Purpose

This contract governs migration of the real playable Battle01 into the final 3D world + 2D HUD game. It is not a screenshot project, model viewer, beauty-scene project, or disconnected prototype.

The intended complete loop remains:

Recon / incomplete information -> formation selection and movement -> route choice -> contact -> combined-arms combat -> Central Bridgehead -> enemy counterattack -> supply / withdrawal / reserve commitment -> Industrial Objective -> victory / defeat -> restart.

The visual target images define the required runtime image quality and visual language when those gameplay states actually occur.

## 2. Preserve the game while changing representation

Preserve accepted gameplay semantics unless Window 00 explicitly authorizes a design revision:

- FormationDefinition data and roles;
- HP / damage / range / attack interval / ammo / speed constants;
- Formation-level selection and command semantics;
- Recon / CONTACT / CONFIRMED / LAST_KNOWN;
- LOS / smoke meaning;
- objectives;
- enemy limited-information AI;
- logistics / reinforcement / withdrawal;
- victory / defeat / restart;
- valid 2D HUD information architecture.

The migration should separate simulation from presentation where practical. Existing planar simulation may map to the 3D XZ world through an explicit adapter rather than forcing a total gameplay rewrite.

## 3. Mandatory real-game integration

Every migration stage must live in or directly advance the actual Battle01 main runtime.

Forbidden as product substitutes:

- standalone vehicle viewers;
- detached bridge or terrain beauty scenes;
- screenshot-only staging scenes;
- separate maps not driven by actual Battle01 state;
- target images used as backgrounds;
- declaring success because one camera angle looks good.

## 4. Migration stages and current state

### STAGE_1 — 3D foundation inside real Battle01

TASK_ID=MIGRATE_BATTLE01_3D_FOUNDATION_INTEGRATED_V1
OWNER_WINDOW=WINDOW_02_GODOT_ARCHITECTURE
STATUS=IMPLEMENTED_ON_MAIN_PENDING_BROADER_PRODUCT_VALIDATION
IMPLEMENTATION_COMMIT=a197372ab5021a5acb0bb6124d734eb84dc7aa35

The current main includes Forward+, Node3D world structure, Camera3D, 3D input mapping/presentation adapter work and keeps the real Battle01 simulation as the underlying gameplay state.

This foundation is retained as technical infrastructure. It is not final visual quality and is not proof that the game design itself is sufficiently mature.

### INTERMEDIATE PRODUCT DESIGN GATE — REQUIRED BEFORE STAGE 2/3 EXPANSION

TASK_ID=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1
OWNER_WINDOW=WINDOW_01_GAME_DESIGN
CONTRACT=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V1.md
STATUS=CURRENT_AUTHORIZED_TASK

Purpose: pressure-test the whole Battle01 as a game before expensive 3D gameplay closure, final-art production, large asset work or broader implementation continues.

Until this gate closes:

- keep the landed 3D foundation;
- allow focused fixes needed to keep the build bootable/testable;
- do not mass-produce final 3D assets/VFX;
- do not broadly expand Stage 2/3 based on unreviewed design assumptions;
- do not add gameplay scope merely to make the current implementation feel fuller.

### STAGE_2 — 3D gameplay representation closure

Owners: WINDOW_02 + WINDOW_03 + WINDOW_04 as applicable.
STATUS=BLOCKED_BY_PRODUCT_DESIGN_GATE

After the product-design gate passes or its required revisions are formally adjudicated, close 3D representation for formation orientation/movement, selection/commands, navigation, LOS/smoke, combat effects, AI movement/engagement, objectives and logistics in the same live game world.

### STAGE_3 — full Battle01 world art and combat presentation

Owners: WINDOW_06_UI_VISUAL + WINDOW_08_VISUAL_TARGET_ASSETS with WINDOW_02 support.
STATUS=BLOCKED_BY_PRODUCT_DESIGN_GATE

After the product design is strong enough, bring the whole live Battle01 world to target-image strength: terrain/material layering, roads/river/bridge, village/industrial regions, vegetation, formal unit visual identity, PBR, lighting/shadows, muzzle flash, tracer, impact, explosion, smoke, wrecks, decals, LOD/readability and integrated 2D HUD.

### STAGE_4 — integrated product QA

OWNER_WINDOW=WINDOW_07_INTEGRATION_QA

Final acceptance evaluates together:

PLAYABLE / FULL_BATTLE01_LOOP / MEANINGFUL_DECISIONS / RECON_FOW / FORMATION_COMMAND / COMBAT / ENEMY_AI / OBJECTIVES / LOGISTICS_REINFORCEMENT / VICTORY_DEFEAT_RESTART / VISUAL_READABILITY / TARGET_ALIGNMENT / TECHNICAL_HEALTH / PERFORMANCE.

A pretty screenshot cannot cover broken gameplay, and a mechanically correct game cannot cover failed target-image quality.

## 5. Current authorized next task

AUTHORIZED_NEXT_TASK=PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1
AUTHORIZED_NEXT_OWNER=WINDOW_01_GAME_DESIGN

In plain language: stop spending heavily for a moment and rigorously test whether the current Battle01 loop is actually interesting, readable, replayable and worth building to final quality. Keep the new 3D foundation, but do not let technical momentum outrun game design again.
