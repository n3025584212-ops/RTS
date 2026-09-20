# FRONTLINE PROJECT SYSTEM V2

STATUS=ACTIVE_PROJECT_SYSTEM
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
SUPERSEDES=docs/FRONTLINE_PROJECT_SYSTEM_V1.md
ENGINE_BASELINE=Godot_4_7_1

## 1. Core production principle

FRONTLINE is built as a game, not as an RTS-engine research project.

PRODUCTION_ORDER:
USER_GOAL
-> IMPLEMENTATION_GRADE_DESIGN_PACKAGE
-> USER_APPROVAL
-> LOGIC_AND_VISIBLE_PRESENTATION_BUILD_TOGETHER
-> REAL_RUNTIME
-> VISUAL_AND_BEHAVIORAL_COMPLIANCE_REVIEW
-> HUMAN_PLAY_WHEN_REPRESENTATIVE

No production-facing feature is considered complete merely because code or CI passes.

## 2. Authority order

1. USER_EXPLICIT_DECISION
2. docs/current/CURRENT_STATE.md
3. USER_APPROVED_IMPLEMENTATION_GRADE_DESIGN_PACKAGE
4. accepted decisions / decision log
5. active implementation Issue
6. current implementation/runtime evidence
7. historical material

A user-approved design package is an implementation contract for visible player-facing content.

## 3. Implementation-grade design package

Before corresponding production implementation begins, the active design package must include:

### A. Visual master
At least one high-resolution target frame showing the intended in-game result at the actual gameplay camera language.

### B. Spatial layout
A top-down or orthographic battlefield layout showing:
- terrain zones;
- roads;
- rivers/bridges;
- settlements/buildings;
- vegetation;
- objectives;
- spawn/deployment regions;
- important movement corridors.

### C. Camera specification
- normal gameplay camera height/range;
- near/far readability expectations;
- unit screen-size targets;
- allowed pitch/yaw/zoom behavior.

### D. Unit presentation sheet
For every unit/formation family visible in the target:
- role;
- silhouette;
- relative scale;
- team identification;
- selection state;
- damage/suppression/low-ammo state;
- icon/marker behavior at distance.

### E. UI specification
- HUD regions;
- information hierarchy;
- command affordances;
- unit/formation panels;
- objectives;
- support;
- intel;
- warnings;
- minimap/tactical map;
- exact visible states needed for implementation.

### F. Combat/VFX presentation
- muzzle flash;
- tracer/projectile;
- impact;
- explosion;
- smoke;
- suppression;
- damaged/destroyed state;
- wrecks/scorch/debris where applicable.

### G. State-to-presentation map
Each important simulation state must map to player-visible feedback.

Example:
SUPPRESSED
-> movement/performance effect
-> animation/pose or movement cue
-> icon/status cue
-> audio/VFX cue
-> commander-relevant consequence

### H. Implementation mapping
For every designed element, record:
- target Godot scene/resource/script surface;
- reusable existing system if any;
- external/free/placeholder production asset source when applicable;
- whether a custom asset is required;
- completion test.

### I. Acceptance checklist
A feature is complete only when:
1. logic behaves correctly;
2. target visible element exists;
3. target presentation is recognizable against the approved design;
4. UI communicates the relevant state;
5. runtime is stable;
6. no silent replacement by boxes/unrelated placeholder art has occurred.

## 4. Greybox rule

Greyboxes are allowed only for isolated internal technical experiments.

GREYBOX_AS_DELIVERY=NO
GREYBOX_AS_APPROVED_VISUAL_IMPLEMENTATION=NO
BOXES_OR_ABSTRACT_MARKERS_MAY_NOT_REPLACE_APPROVED_VISIBLE_CONTENT=YES

If a production element cannot yet match the approved target, mark it explicitly as incomplete. Do not claim it implemented.

## 5. Build loop

APPROVED_DESIGN_PACKAGE
-> SCOPED IMPLEMENTATION ISSUE
-> ASSET ACQUISITION/CREATION
-> GAMEPLAY IMPLEMENTATION
-> PRESENTATION IMPLEMENTATION
-> INTEGRATED RUNTIME
-> FOCUSED TESTS
-> DESIGN-COMPLIANCE REVIEW
-> MERGE

Logic and visuals are one delivery stream, not separate future phases.

## 6. Evidence

TECHNICAL_PASS proves only correctness of implemented mechanics.

PRODUCTION_PASS requires:
- runtime scene;
- visual target compliance;
- player-readable state presentation;
- no hidden substitution of approved design;
- tests/regression evidence.

PRODUCT_PASS still requires later real human play when the game is representative.

## 7. Four-window routing

WINDOW_00 = Project Control / Integration
WINDOW_01 = Design / Experience / Visual Production Definition
WINDOW_02 = Development / Asset Integration / Gameplay Production
WINDOW_03 = Independent Review / Operations / Design Compliance

The windows remain routing contexts, not departments.

## 8. Current operating rule

VISUAL_PRODUCTION_RESET=ACTIVE
ALL_OLD_DESIGN_IMAGES=HISTORICAL_ONLY
NEW_IMPLEMENTATION_GRADE_DESIGN_REQUIRED=YES
USER_APPROVAL_BEFORE_PRODUCTION=YES
LOGIC_AND_VISUALS_TOGETHER=YES
GREYBOX_DELIVERY=FORBIDDEN
