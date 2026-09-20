# FRONTLINE GPT MULTI-WINDOW SYSTEM V3

ARCHIVED=2026-09-20 — non-authoritative, superseded; chains in docs/archive/governance/ARCHIVE_INDEX.md

STATUS=ACTIVE_COLLABORATION_SYSTEM
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
GOVERNING_PROJECT_SYSTEM=docs/FRONTLINE_PROJECT_SYSTEM_V2.md
SUPERSEDES=docs/GPT_MULTI_WINDOW_SYSTEM_V2.md

## 1. Windows

WINDOW_00 = Project Control / Integration
WINDOW_01 = Design / Experience / Visual Production Definition
WINDOW_02 = Development / Asset Integration / Gameplay Production
WINDOW_03 = Independent Review / Operations / Design Compliance

No independent project states. User remains product authority.

## 2. Window 01

WINDOW_01 must produce implementation-grade design packages, not loose concept art.

Required deliverables as needed:
- visual master frame;
- spatial battlefield layout;
- camera specification;
- unit presentation sheet;
- HUD/UI specification;
- combat/VFX presentation;
- state-to-presentation mapping;
- implementation mapping;
- acceptance checklist.

A generated design image without the implementation mapping is incomplete.

## 3. Window 02

WINDOW_02 consumes the approved design package.

It implements gameplay and presentation together:
- scenes;
- assets;
- terrain;
- units;
- VFX;
- UI;
- simulation;
- AI;
- commands;
- audio hooks where applicable.

It may run isolated greybox experiments internally, but those are not delivery and may not replace approved visible content.

## 4. Window 03

WINDOW_03 independently checks:
- implementation matches the approved visual/design package;
- required visible elements exist;
- simulation states have visible feedback;
- no approved content was silently replaced with boxes or unrelated placeholders;
- runtime and CI remain sound;
- regressions are absent.

It does not decide whether the game is fun.

## 5. Window 00

WINDOW_00:
- selects/routs work;
- freezes only user-approved design packages as current implementation authority;
- integrates accepted implementation;
- updates CURRENT_STATE;
- prevents architecture work from displacing game production.

## 6. Production gate

DESIGN_PACKAGE_READY
-> USER_APPROVED
-> WINDOW_02_IMPLEMENT
-> WINDOW_03_COMPLIANCE_REVIEW
-> WINDOW_00_INTEGRATE

No mandatory chat receipt chain; GitHub remains durable truth.

## 7. Hard rules

APPROVED_DESIGN_IS_IMPLEMENTATION_CONTRACT=YES
CONCEPT_ART_ONLY_IS_NOT_IMPLEMENTATION_SPEC=YES
GREYBOX_DELIVERY=NO
LOGIC_ONLY_FEATURE_COMPLETION=NO
VISUAL_ONLY_FEATURE_COMPLETION=NO
TECHNICAL_PASS_NOT_PRODUCT_PASS=YES
