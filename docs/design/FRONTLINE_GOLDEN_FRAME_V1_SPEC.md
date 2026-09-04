# FRONTLINE GOLDEN FRAME V1 — APPROVED IMPLEMENTATION CONTRACT

STATUS=APPROVED_IMPLEMENTATION_AUTHORITY
DESIGN_ID=FRONTLINE_GOLDEN_FRAME_V1
TARGET_RESOLUTION=1920x1080
DATE=2026-09-04
PARENT_PACKAGE=docs/design/FRONTLINE_PRODUCTION_DESIGN_PACKAGE_V1.md

## 1. Purpose

This is the visual quality gate for FRONTLINE production.

The corresponding Golden Frame is not a mood board and not permission to substitute abstract proxies. If the user approves it, the production scene must be built to visibly resemble this target in camera composition, environment density, 3D asset fidelity, lighting, battle effects and HUD density.

## 2. Canonical visual targets

### Camera
- 16:9 actual gameplay frame;
- oblique high tactical camera;
- enough zoom to read individual armored vehicles and infantry groups;
- enough field of view to read multiple simultaneous battle sectors;
- terrain remains visually dominant; HUD is edge-weighted.

### World
- fully modeled 3D valley terrain, not a flat plane;
- broad river with banks and water shading;
- real bridge geometry;
- dense river-town settlement with varied buildings and a tall landmark;
- roads, intersections, agricultural fields, hedgerows, treelines, forests and hills;
- distant terrain remains populated rather than ending in an empty horizon;
- damaged buildings, fires, wrecks and smoke create battle history.

### Units
- realistic 3D armored vehicles with recognizable silhouettes;
- infantry represented physically at near/medium zoom;
- model scale coherent with roads/buildings;
- friend/foe readability comes from both physical silhouette and tactical overlay;
- no cube/rectangle delivery substitutes.

### Combat
- visible muzzle flashes;
- tracers/projectile flight;
- shell/artillery trajectories where appropriate;
- impact dust and debris;
- high-volume smoke columns;
- burning/damaged states;
- combat activity distributed across the battlefield rather than one isolated effect.

### HUD
- top center: battle state / time / objectives;
- top left: mission objectives;
- top/right edge: important alerts;
- lower left: tactical map;
- lower center: formation roster/cards;
- lower right: selected formation detail + commands;
- world-space markers and routes remain readable without hiding the 3D battle.

### Information density
The player should be able to understand the operational situation from one frame while still seeing a convincing battlefield underneath.

## 3. Non-canonical generated-image artifacts

The generated Golden Frame may contain imperfect or malformed rendered text. Those text rendering defects are NOT authoritative.

Not frozen by the image alone:
- exact vehicle model designation;
- exact score values;
- exact timer value;
- exact objective letters/count;
- exact mission wording;
- malformed AI-generated Chinese labels.

Authoritative UI wording, data fields and command labels come from the implementation specification and later approved UI detail sheet.

## 4. Minimum Golden Scene acceptance

A screenshot from the actual engine at the approved camera must show, simultaneously:

- sculpted terrain;
- river;
- bridge;
- dense town;
- forests/treelines;
- fields/roads;
- multiple real 3D vehicle models;
- physical infantry representation;
- friendly and hostile tactical overlays;
- smoke/fire/explosion/tracer effects;
- tactical map;
- formation cards;
- selected formation panel;
- mission/status/alert UI;
- no obvious primitive-box substitutes for approved production content.

A scene that only proves navigation/combat logic is NOT Golden Scene PASS.

## 5. Production implementation batches

G0_ASSET_AND_ENGINE_FEASIBILITY
- prove the selected engine/assets can reproduce the approved frame quality;
- capture fixed-camera comparison screenshot;
- reject/switch technical approach if it cannot.

G1_WORLD
- terrain, river, bridge, town, roads, fields, forests, landmarks, lighting.

G2_UNITS
- production-quality armored vehicles, infantry representation, team presentation, LOD/marker transition.

G3_COMBAT_PRESENTATION
- firing, tracers, impacts, explosions, smoke, damage, wrecks.

G4_HUD
- tactical map, formation strip, selected formation panel, mission state, alerts, world markers.

G5_LOGIC_BINDING
- formation tasks, enemy state reaction, reserve, support, combat states bound to the visible production scene.

G6_GOLDEN_SCENE_COMPLIANCE
- engine screenshot comparison against Golden Frame;
- element-by-element checklist;
- no technical PASS may override visible non-compliance.

## 6. Agent rule

Codex / WINDOW_02 receives this document plus the approved Golden Frame as an implementation contract.

FORBIDDEN:
- silently converting the river to a blue rectangle;
- silently converting buildings to cubes;
- silently converting armored vehicles to boxes/icons only;
- replacing combat VFX with numeric HP changes only;
- claiming completion because CI is green while the screenshot visibly misses the target.

Allowed:
- lower-detail production assets where necessary if they preserve silhouette, material, lighting and visual language;
- temporary internal test scenes, provided they are not presented as Golden Scene implementation.

## 7. Approval

USER_APPROVED=YES
USER_APPROVAL_DATE=2026-09-05

This Golden Frame is now the visual quality gate for the first production scene.
