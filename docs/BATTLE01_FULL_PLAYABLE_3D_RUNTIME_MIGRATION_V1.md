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
NEW_GAMEPLAY_UNIT=NO

## 1. Purpose

This contract governs migration of the real playable Battle01 into the final 3D world + 2D HUD game. It is not a screenshot project, model viewer, beauty-scene project, or disconnected prototype.

The complete loop remains:
Recon / incomplete information -> formation selection and movement -> route choice -> contact -> combined-arms combat -> Central Bridgehead -> enemy counterattack -> supply / withdrawal / reserve commitment -> Industrial Objective -> victory / defeat -> restart.

Visual targets define the required runtime image quality when those gameplay states actually occur.

## 2. Current gameplay design authority

The first product pressure test returned REVISE. The revised product contract then passed the second design pressure test.

CURRENT_GAMEPLAY_DESIGN=docs/BATTLE01_REVISED_PRODUCT_CONTRACT_V2.md
DESIGN_GATE=docs/BATTLE01_PRODUCT_DESIGN_PRESSURE_TEST_V2_RESULT.md
DESIGN_GATE_RESULT=PASS

The revised contract supersedes forward-design assumptions for role effectiveness, capture/contest responsibility, ammo pressure, route identity, RED defense posture variation, RED/BLUE resupply behavior, reserve tradeoffs, commander-level intents and fixed-roster staging.

Old implementation documents remain temporary runtime references only until revised implementation replaces them.

## 3. Mandatory real-game integration

Every migration stage must live in or directly advance the actual Battle01 main runtime.

Forbidden as product substitutes:
- standalone vehicle viewers;
- detached bridge/terrain beauty scenes;
- screenshot-only staging scenes;
- separate maps not driven by real Battle01 state;
- target images as static backgrounds;
- declaring success because one camera angle looks good.

## 4. Migration stages

### STAGE_1 — 3D foundation

TASK_ID=MIGRATE_BATTLE01_3D_FOUNDATION_INTEGRATED_V1
OWNER_WINDOW=WINDOW_02_GODOT_ARCHITECTURE
STATUS=IMPLEMENTED_ON_MAIN
IMPLEMENTATION_COMMIT=a197372ab5021a5acb0bb6124d734eb84dc7aa35

Forward+, Node3D world structure, Camera3D, 3D input mapping/presentation adapter work are retained as technical infrastructure inside the real Battle01 runtime.

### DESIGN GATE — COMPLETE

PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V1=REVISE
REVISE_BATTLE01_PRODUCT_DESIGN_AFTER_PRESSURE_TEST_V1=COMPLETE
PRESSURE_TEST_BATTLE01_PRODUCT_DESIGN_V2=PASS

The game design is now strong enough to implement the revised gameplay rules, but exact balance and fun remain runtime-validation questions.

### STAGE_2 — revised gameplay implementation + 3D representation closure

STATUS=AUTHORIZED

Implement `BATTLE01_REVISED_PRODUCT_CONTRACT_V2` inside the real current Battle01 runtime.

Must include:
- fixed target-class effectiveness;
- revised ammo capacities;
- capture vs contest separation;
- North/Central/South mechanical route identity;
- three seeded authored RED pre-match defense postures;
- real BLUE and RED finite resupply;
- Formation-level RESUPPLY intent;
- revised reserve Infantry-vs-Armor tradeoff;
- commander-level MOVE/ADVANCE/HOLD/HOLD FIRE/WITHDRAW/RESUPPLY/STOP intent set;
- fixed-roster pre-battle staging;
- continued Victory/Defeat/Restart and fog-limited AI behavior;
- all of the above represented in the same real 3D-backed Battle01 world.

Stage 2 must end in an actual playable build and a player-facing decision test. Paper correctness is not enough.

### STAGE_3 — final world art and combat presentation

STATUS=BLOCKED_PENDING_REVISED_RUNTIME_PLAYTEST

Do not mass-produce final 3D assets/VFX yet.

After the revised runtime proves the intended decisions, bring the whole live Battle01 world to target-image strength: terrain/material layering, roads/river/bridge, village/industrial regions, vegetation, formal unit identity, PBR, lighting/shadows, muzzle flash, tracer, impact, explosion, smoke, wrecks, decals, readable LOD and integrated 2D HUD.

### STAGE_4 — integrated product QA

OWNER_WINDOW=WINDOW_07_INTEGRATION_QA

Final acceptance evaluates together:
PLAYABLE / FULL_BATTLE01_LOOP / MEANINGFUL_DECISIONS / RECON_FOW / FORMATION_COMMAND / COMBAT / ENEMY_AI / OBJECTIVES / LOGISTICS_REINFORCEMENT / VICTORY_DEFEAT_RESTART / VISUAL_READABILITY / TARGET_ALIGNMENT / TECHNICAL_HEALTH / PERFORMANCE.

## 5. Current authorized next task

AUTHORIZED_NEXT_TASK=IMPLEMENT_BATTLE01_REVISED_PRODUCT_RULES_V2
AUTHORIZED_NEXT_OWNER=WINDOW_02_GODOT_ARCHITECTURE_WITH_03_04_05_DOMAIN_SUPPORT

In plain language: the design revision is complete enough to build. The next job is to put the new rules into the real 3D-backed Battle01 and prove through actual play that the player now gets genuinely different decisions instead of nominal choices. Full final-art production remains blocked until that playable proof passes.
