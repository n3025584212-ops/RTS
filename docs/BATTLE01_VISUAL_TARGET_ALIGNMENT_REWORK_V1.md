# BATTLE01_VISUAL_TARGET_ALIGNMENT_REWORK_V1

TASK_ID=REWORK_BATTLE01_VISUAL_TARGET_ALIGNMENT_V1  
OWNER_WINDOW=WINDOW_06_UI_VISUAL  
STATUS=FROZEN_REWORK_GATE  
ENGINE=Godot 4.7.1  
SOURCE_OF_TRUTH=GITHUB_MAIN  
FAILED_IMPLEMENTATION_COMMIT=1f4add40242f99660c0ddbfc0475df27237e970e  
GAMEPLAY_CHANGE_ALLOWED=NO  
SCOPE_EXPANSION_ALLOWED=NO

## 0. Judgment

The implementation at `1f4add40242f99660c0ddbfc0475df27237e970e` is accepted only as functional/presentation-state coverage.

It is NOT accepted as final Battle01 visual implementation.

FUNCTIONAL_STATE_COVERAGE=PASS  
VISUAL_PRODUCT_QUALITY=FAIL  
TARGET_ALIGNMENT=FAIL  
FINAL_PRESENTATION=FAIL  
READY_FOR_WINDOW_07_FINAL_VISUAL_QA=NO

The 13 runtime screenshots prove that presentation states exist. They do not prove that the runtime belongs to the same visual product family as the approved Window 08 target assets.

## 1. Root cause to prevent from recurring

The previous implementation relied primarily on textual specification and treated target images as abstract direction. This allowed a technically valid but prototype-like implementation dominated by programmatic Panels, Labels, ProgressBars, fallback-font text and primitive drawn markers.

The next pass must treat the actual target-image binaries as first-class implementation inputs and first-class acceptance evidence.

## 2. Mandatory target assets in repository before rework begins

Before any rework code is written, the actual approved target images must exist under:

`docs/visual_targets/battle01/`

Required canonical filenames:

- `P0-01_FULL_COMBAT_HUD.png`
- `P0-02_RESERVE_DEPLOYMENT_REFERENCE.png`
- `P0-03_COMMAND_FEEDBACK.png`
- `P0-04_TERRAIN_OBJECTIVE_LAYER.png`
- `P0-05_HIGH_INTENSITY_COMBAT.png`
- `P1-06_UNIT_READABILITY_ZOOM.png`
- `P1-07_BUILDING_OBJECTIVE_STATE.png`
- `FINAL-01_FINAL_BATTLE_PRESENTATION.png`

If any of these eight actual target-image files is absent, executor result must be:

`EXECUTOR_RESULT=BLOCKED_TARGET_ASSETS_MISSING`

The executor must not substitute textual descriptions, old screenshots, roadmap thumbnails, or generated placeholder art for a missing canonical target image.

## 3. Gameplay authority still wins

Target images contain historical concepts that are no longer current gameplay authority.

The executor must preserve the target's visual language while adapting/removing obsolete mechanics such as:

- currency/mining/income tick;
- population economy;
- purchase/production queue;
- tech tree;
- A/B/C three-objective structure;
- healing/repair semantics for Supply;
- nonexistent artillery/missile/suppression/penetration/weather systems.

Current frozen Battle01 gameplay remains authoritative.

## 4. Visual truth hierarchy

For presentation work use this hierarchy:

1. `FINAL-01_FINAL_BATTLE_PRESENTATION.png` — primary overall product look.
2. P0-01 — HUD composition / battlefield-to-HUD proportion.
3. P0-03 — command-feedback visual language.
4. P0-04 — terrain/objective/rally battlefield layer.
5. P0-05 — combat density and readability under pressure.
6. P1-06 — Formation identity and NEAR/MID/FAR readability.
7. P1-07 — building/objective functional-state presentation.
8. P0-02 — decision-layer composition only, adapted from old purchase/deploy flow into current one-choice Reserve Commitment.

Text specification explains behavior. Target images define the intended presentation family.

## 5. Hard visual requirement

Pixel-perfect reproduction is not required.

However, the final runtime MUST clearly belong to the same visual product family as the approved targets in all of the following dimensions:

- battlefield occupies the dominant screen area;
- modern-war atmosphere and terrain material language;
- HUD density and panel hierarchy;
- panel shape, transparency, typography hierarchy and icon-first communication;
- Formation silhouette/marker language;
- objective integration into the battlefield;
- command route/destination treatment;
- minimap visual language;
- combat effects density;
- color/value hierarchy;
- overall sense of a finished modern tactical RTS rather than a diagnostic tool.

A reviewer seeing the target and runtime side-by-side must immediately recognize the runtime as the implementation of the same product direction.

## 6. Prototype visual patterns forbidden as final solution

The following are not sufficient as primary final presentation:

- large stacks of plain text labels;
- generic `Panel + Label + ProgressBar` composition with no designed icon/asset system;
- `ThemeDB.fallback_font` text used as the primary world-marker identity system;
- circles/crosses/letters used as the primary substitute for Formation visual identity;
- command/status words (`CAP`, `LOW AMMO`, etc.) floating as raw debug-like text when an icon/status language is expected;
- flat programmer-debug minimap styling;
- evidence screenshots composed merely to expose every state.

Programmatic drawing is allowed for supporting geometry, progress, routes and overlays, but not as a blanket replacement for the approved product visual language.

## 7. Asset implementation requirement

Executor may create/rework implementation assets needed to reproduce the approved direction, including:

- UI 9-slice/StyleBox/theme assets;
- command and status icons;
- Formation role markers and silhouettes;
- objective/rally markers;
- minimap glyphs;
- terrain/material presentation assets;
- muzzle flash, tracer, impact, destruction and smoke presentation assets;
- typography hierarchy and spacing system.

These are implementation assets, not new gameplay systems.

## 8. Target-to-runtime implementation matrix required before coding

Before modifying runtime presentation, create:

`docs/audits/BATTLE01_VISUAL_TARGET_TO_RUNTIME_PLAN_V1.md`

For every one of the eight target images document:

- TARGET_FILE
- PRESERVE
- ADAPT_TO_CURRENT_GAMEPLAY
- DO_NOT_COPY
- CURRENT_RUNTIME_GAP
- IMPLEMENTATION_ACTION
- RUNTIME_EVIDENCE_SCENE

This plan is a visual translation plan, not a new design exercise.

## 9. Required runtime comparison evidence

Do not submit isolated runtime screenshots alone.

Create:

`docs/audits/evidence/battle01_visual_alignment_v1/`

Minimum comparison pairs:

1. `TARGET_P0-01` vs `RUNTIME_OPENING_HUD`
2. `TARGET_P0-03` vs `RUNTIME_SELECTION_COMMAND`
3. `TARGET_P0-04` vs `RUNTIME_OBJECTIVE_TERRAIN`
4. `TARGET_P0-05` vs `RUNTIME_HIGH_INTENSITY`
5. `TARGET_P1-06` vs `RUNTIME_NEAR_MID_FAR`
6. `TARGET_P1-07` vs `RUNTIME_OBJECTIVE_FUNCTION_STATE`
7. `TARGET_FINAL-01` vs `RUNTIME_FINAL_BATTLE_PRESENTATION`

P0-02 must also be checked for decision hierarchy, but its obsolete economy/purchase mechanics must not be reproduced.

For each comparison, record:

- TARGET_ALIGNMENT=PASS / REVISE
- HUD_COMPOSITION
- BATTLEFIELD_VISUAL_LANGUAGE
- FORMATION_READABILITY
- OBJECTIVE_READABILITY
- ICONOGRAPHY
- TYPOGRAPHY
- COLOR_VALUE_HIERARCHY
- COMBAT_ATMOSPHERE
- DEBUG_PROTOTYPE_FEEL=YES / NO

Any `DEBUG_PROTOTYPE_FEEL=YES` is automatic REVISE.

## 10. Acceptance rule

The rework cannot pass merely because:

- all UI states exist;
- smoke tests pass;
- 13 or more screenshots were generated;
- FOW does not leak;
- no runtime errors occurred.

Those are necessary technical checks, not visual acceptance.

Final pass requires all of:

- GAMEPLAY_REGRESSION=PASS
- FOW_LEGALITY=PASS
- VISUAL_READABILITY=PASS
- TARGET_ALIGNMENT=PASS
- FINAL_PRESENTATION=PASS
- DEBUG_PROTOTYPE_FEEL=NO
- ACTUAL_RUNTIME_COMPARISON_EVIDENCE=PASS

## 11. Executor instruction

Recommended executor: Qoder Quest Agent or Codex.

The executor must READ the canonical target PNGs directly before coding.

It must not report PASS if it cannot inspect those images.

Suggested commit after successful rework:

`Rework Battle01 runtime to approved visual targets`

## 12. Current disposition

PREVIOUS_VISUAL_IMPLEMENTATION=REVISE  
KEEP_EXISTING_GAMEPLAY_WIRING=YES  
KEEP_FOW_SUPPLY_RESERVE_OBJECTIVE_LOGIC=YES  
REWORK_PRESENTATION_LAYER=YES  
DELETE_VALID_FUNCTIONAL_WORK=NO  
WINDOW_07_FINAL_VISUAL_QA=BLOCKED_UNTIL_REWORK_PASS
