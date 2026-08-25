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

This contract governs the migration of the existing playable Battle01 from its current 2D world representation to the final 3D world + 2D HUD runtime.

The migration exists to make the approved visual targets become the look of the real playable RTS. It is not a screenshot project, model viewer, beauty-scene project, or disconnected prototype.

The product remains the complete Battle01 loop:

Recon / incomplete information -> formation selection and movement -> route choice -> contact -> combined-arms combat -> Central Bridgehead -> enemy counterattack -> supply / withdrawal / reserve commitment -> Industrial Objective -> victory / defeat -> restart.

A migration stage may prove one technical axis, but no isolated view or visual demo may be treated as product completion.

## 2. Preserve the accepted game; replace the world representation

The migration must preserve current frozen/accepted gameplay semantics unless Window 00 explicitly authorizes a separate design change.

Preserve and reuse where technically practical:

- FormationDefinition data and unit roles;
- HP / damage / range / attack interval / ammo / speed constants;
- selection and Formation-level command semantics;
- Recon / CONTACT / CONFIRMED / LAST_KNOWN behavior;
- LOS and smoke gameplay semantics;
- objective capture and ownership rules;
- enemy AI behavior and limited-information rules;
- logistics, reinforcement, withdrawal and reserve flow;
- victory / defeat and restart flow;
- 2D HUD information architecture that remains valid.

The migration must not become an excuse to redesign Battle01.

## 3. Migration architecture principle

The safest default migration is to separate GAMEPLAY_SIMULATION from WORLD_PRESENTATION rather than rewriting accepted gameplay at the same time as the renderer.

During the transition, existing planar Battle01 simulation coordinates may remain authoritative and map into the 3D XZ plane through a small explicit adapter:

`Vector2(sim_x, sim_y) -> Vector3(world_x, terrain_height, world_z)`

This allows accepted Combat, AI, Objective, Recon and Formation data to continue operating while the visible world becomes 3D. Terrain height / surface contact may be resolved by the 3D world presentation/navigation layer without changing frozen gameplay meaning.

A later subsystem may move to a native 3D implementation only when required and independently verified. Do not rewrite every system merely because Node3D exists.

## 4. Mandatory real-game integration

Every migration stage must work toward the actual Battle01 main runtime.

The following are forbidden as substitutes for integration:

- a standalone IFV viewer;
- a detached bridge beauty scene;
- a staged screenshot scene without the real command loop;
- a separate map that does not use the actual Battle01 gameplay state;
- using FINAL-01 as a background image;
- declaring success because one camera view resembles a target image.

A temporary technical scene may exist only when needed to diagnose an engine feature. It is disposable and cannot satisfy a formal product gate.

## 5. Migration stages

### STAGE_1 — 3D foundation inside the real Battle01

TASK_ID=MIGRATE_BATTLE01_3D_FOUNDATION_INTEGRATED_V1
OWNER_WINDOW=WINDOW_02_GODOT_ARCHITECTURE

Goal: put the real Battle01 on the 3D runtime foundation without breaking the existing complete gameplay loop.

Required outcome:

- project renderer moved to Forward+ where supported by the accepted desktop target;
- real Battle01 main runtime gains a Node3D world root and Camera3D RTS camera;
- existing 2D Control HUD remains operational above the 3D world;
- explicit simulation-to-3D coordinate adapter exists;
- Battle01 terrain footprint, river, central bridgehead area, village region and industrial region exist in the real world scene as 3D spatial structure at implementation-quality placeholder level;
- current playable formations are represented by 3D world actors or integrated 3D proxies bound to the real Formation state;
- player can select formations and issue movement in the real Battle01;
- screen-to-world input uses the real 3D camera/ground intersection rather than a disconnected demo;
- real combat state, objectives, AI, logistics/reinforcement and victory/defeat remain reachable and functioning, even if some presentation remains transitional;
- no new gameplay systems are introduced;
- old 2D world presentation is removed only when its runtime dependency is replaced.

Stage 1 is a construction milestone, not final visual acceptance.

### STAGE_2 — 3D gameplay representation closure

Owners: WINDOW_02 + WINDOW_03 + WINDOW_04 as applicable.

Goal: make all player-facing Battle01 gameplay actions spatially coherent in the 3D world while preserving accepted rules.

Must close:

- Formation orientation and movement presentation;
- selection / drag selection / command feedback in 3D;
- route/navigation representation;
- LOS / smoke world interaction;
- combat fire/impact spatial presentation;
- enemy AI movement/engagement/return/reinforcement in the same 3D world;
- objective and logistics interactions in the same 3D world.

### STAGE_3 — full Battle01 3D world art and combat presentation

Owners: WINDOW_06_UI_VISUAL + WINDOW_08_VISUAL_TARGET_ASSETS with WINDOW_02 implementation support.

Goal: convert the integrated playable world from implementation-quality geometry/assets to target-aligned final Battle01 presentation.

Must cover the real Battle01 world, not one view:

- terrain and material layering;
- roads / river / bridge;
- village and industrial objective areas;
- vegetation and battlefield detail;
- Recon / Infantry / IFV / Supply Truck / Armor visual identity;
- PBR materials, lighting and shadows;
- muzzle flash, tracer, impact, explosion, smoke, wreck and decals;
- readable near/mid/far Formation presentation;
- 2D HUD integrated with the 3D battle.

Approved visual targets, especially FINAL-01, P0-05, P1-06 and P1-07, are visual truth for this stage.

### STAGE_4 — integrated product QA and visual closure

OWNER_WINDOW=WINDOW_07_INTEGRATION_QA

Final acceptance requires actual playable runtime evidence across the real Battle01 loop.

The final gate must evaluate together:

- PLAYABLE;
- FULL_BATTLE01_LOOP;
- MEANINGFUL_DECISIONS;
- RECON_FOW;
- FORMATION_COMMAND;
- COMBAT;
- ENEMY_AI;
- OBJECTIVES;
- LOGISTICS_REINFORCEMENT;
- VICTORY_DEFEAT_RESTART;
- VISUAL_READABILITY;
- TARGET_ALIGNMENT;
- TECHNICAL_HEALTH;
- PERFORMANCE.

A pretty screenshot cannot cover a broken gameplay gate, and a mechanically passing game cannot cover failed final target alignment.

## 6. Visual-target interpretation

The correct interpretation of "build from the target images" is:

The target image should become the appearance of the live playable game when the corresponding gameplay state actually occurs.

Do not abstract the image into line art, debug geometry, simplified tactical symbols or low-fidelity sprite replacement and call that target alignment.

UI symbols may remain stylized 2D where appropriate. World objects shown as physical vehicles, terrain, bridges, buildings, smoke, explosions or environmental depth in the visual truth must be represented as a coherent 3D game world at final visual closure.

## 7. Completion discipline and cleanup

Every stage obeys `FRONTLINE_TASK_CLOSEOUT_AUDIT_AND_CLEANUP_V1`.

At every closeout:

- report in plain language what the player can now actually do and see;
- say plainly what still remains transitional;
- remove rejected/disposable assets, evidence and obsolete implementation once no longer required;
- do not accumulate duplicate project copies or full-project ZIP backups;
- retain Git history as the normal recovery path;
- do not claim the overall 3D migration complete until Stage 4 passes.

## 8. Current authorized next task

AUTHORIZED_NEXT_TASK=MIGRATE_BATTLE01_3D_FOUNDATION_INTEGRATED_V1
AUTHORIZED_NEXT_OWNER=WINDOW_02_GODOT_ARCHITECTURE

The next task is not to build a beauty sample. It is to start converting the real playable Battle01 itself to the 3D runtime foundation while keeping the accepted RTS loop alive.
